# RustScan - Techniques and Configuration

This document covers advanced RustScan techniques, configuration options, and practical workflows for effective port scanning.

## Table of Contents

- [Speed Configuration](#speed-configuration)
- [Nmap Integration](#nmap-integration)
- [Custom Scripts](#custom-scripts)
- [Accessible Mode](#accessible-mode)
- [Greppable Output](#greppable-output)
- [Configuration File](#configuration-file)
- [Proxychains Usage](#proxychains-usage)
- [Practical Workflows](#practical-workflows)
- [Comparison with Other Scanners](#comparison-with-other-scanners)

---

## Speed Configuration

RustScan's speed is controlled by three primary parameters: batch size, timeout, and ulimit.

### Batch Size (-b, --batch-size)

The batch size determines how many ports are scanned simultaneously. Higher values increase speed but may overwhelm the target or network.

```bash
# Default batch size (4500)
rustscan -a 192.168.1.1

# Aggressive scan (faster, may miss ports on unstable networks)
rustscan -a 192.168.1.1 -b 8000

# Conservative scan (slower, more reliable on congested networks)
rustscan -a 192.168.1.1 -b 1000

# Very aggressive (use with caution)
rustscan -a 192.168.1.1 -b 65535
```

**Recommended batch sizes:**

| Scenario | Batch Size | Notes |
|----------|-----------|-------|
| Local network | 4500-8000 | Default is usually fine |
| Internet targets | 1500-3000 | More conservative for reliability |
| VPN/Unstable connection | 500-1000 | Prevent packet loss |
| CTF/Lab environment | 5000-10000 | Speed over stealth |
| Stealth scan | 100-500 | Slower, less detectable |

### Timeout (-t, --timeout)

Timeout in milliseconds for each port connection attempt.

```bash
# Default timeout (1500ms)
rustscan -a 192.168.1.1

# Faster timeout (may miss slow services)
rustscan -a 192.168.1.1 -t 500

# Longer timeout (for latent networks or VPN)
rustscan -a 192.168.1.1 -t 3000

# Very patient (for extremely slow targets)
rustscan -a 192.168.1.1 -t 5000
```

### Ulimit (-u, --ulimit)

Controls the maximum number of file descriptors (open connections) allowed.

```bash
# Increase ulimit for faster scanning
rustscan -a 192.168.1.1 -u 5000

# Maximum aggressive (may hit system limits)
rustscan -a 192.168.1.1 -u 10000
```

**Note:** If you get "Too many open files" errors, either decrease the ulimit value or increase your system's file descriptor limit:

```bash
# Check current limit
ulimit -n

# Temporarily increase (requires root)
ulimit -n 10000

# Or use RustScan's built-in adjustment
rustscan -a 192.168.1.1 -u 5000
```

### Combined Speed Tuning

```bash
# Fast local scan
rustscan -a 192.168.1.1 -b 8000 -t 500 -u 6000

# Reliable internet scan
rustscan -a target.com -b 1500 -t 2000

# Maximum speed (lab environment only)
rustscan -a 192.168.1.1 -b 65535 -t 500 -u 10000

# Stealth/slow scan
rustscan -a target.com -b 100 -t 3000
```

---

## Nmap Integration

RustScan's primary purpose is fast port discovery, then passing results to Nmap for detailed analysis.

### Basic Integration

Use `--` to pass arguments to Nmap after RustScan discovers open ports:

```bash
# Service version detection
rustscan -a 192.168.1.1 -- -sV

# Default scripts + version detection
rustscan -a 192.168.1.1 -- -sC -sV

# Aggressive scan (OS, version, scripts, traceroute)
rustscan -a 192.168.1.1 -- -A

# Specific port range with Nmap
rustscan -a 192.168.1.1 -p 1-1000 -- -sV -sC
```

### Nmap Script Categories

```bash
# Vulnerability scanning
rustscan -a 192.168.1.1 -- --script vuln

# Safe scripts only
rustscan -a 192.168.1.1 -- --script safe

# Multiple categories
rustscan -a 192.168.1.1 -- --script "vuln,safe"

# Specific script
rustscan -a 192.168.1.1 -- --script http-enum

# Script with arguments
rustscan -a 192.168.1.1 -- --script http-brute --script-args http-brute.path=/admin
```

### Output Formats

```bash
# All Nmap output formats
rustscan -a 192.168.1.1 -- -oA scan_results

# XML for parsing
rustscan -a 192.168.1.1 -- -oX scan.xml

# Grepable for quick parsing
rustscan -a 192.168.1.1 -- -oG scan.gnmap

# Combined with service detection
rustscan -a 192.168.1.1 -- -sC -sV -oA full_scan
```

### Disabling Nmap

If you only want RustScan's port discovery without Nmap follow-up:

```bash
# Port discovery only (no Nmap)
rustscan -a 192.168.1.1 --no-nmap

# Useful for quick reconnaissance
rustscan -a 192.168.1.0/24 --no-nmap -g
```

---

## Custom Scripts

RustScan supports custom scripts in Python, Lua, and Shell through the RustScan Scripting Engine (RSE).

### Script Directory

Scripts are stored in `~/.rustscan_scripts/` or can be specified with `--scripts`.

### Script Structure

Scripts must include a tags section defining when they run:

```python
#!/usr/bin/env python3
# tags = ["safe", "example"]
# developer = ["Your Name"]
# call_format = "python3 {{script}} {{ip}} {{port}}"

import sys

ip = sys.argv[1]
port = sys.argv[2]

print(f"Scanning {ip}:{port}")
# Your custom logic here
```

### Script Tags

| Tag | Description |
|-----|-------------|
| `safe` | Script is safe to run |
| `intrusive` | May cause service disruption |
| `core` | Part of RustScan core functionality |
| `example` | Example/demo script |

### Running Custom Scripts

```bash
# Run all scripts in default directory
rustscan -a 192.168.1.1 --scripts ~/.rustscan_scripts

# Run specific script directory
rustscan -a 192.168.1.1 --scripts /path/to/scripts

# Combine with Nmap
rustscan -a 192.168.1.1 --scripts ~/.rustscan_scripts -- -sV
```

### Example: HTTP Header Grabber (Python)

```python
#!/usr/bin/env python3
# tags = ["safe", "http"]
# developer = ["Example"]
# call_format = "python3 {{script}} {{ip}} {{port}}"

import sys
import http.client

ip = sys.argv[1]
port = int(sys.argv[2])

try:
    conn = http.client.HTTPConnection(ip, port, timeout=5)
    conn.request("HEAD", "/")
    response = conn.getresponse()
    print(f"[HTTP] {ip}:{port} - Status: {response.status}")
    for header, value in response.getheaders():
        print(f"  {header}: {value}")
except Exception as e:
    print(f"[HTTP] {ip}:{port} - Error: {e}")
```

---

## Accessible Mode

RustScan includes an accessibility mode for screen reader users.

```bash
# Enable accessible mode
rustscan -a 192.168.1.1 --accessible

# Combines well with greppable for automation
rustscan -a 192.168.1.1 --accessible -g
```

Accessible mode:
- Removes ASCII art and unnecessary formatting
- Provides clear, linear text output
- Compatible with screen readers
- Suitable for automation and scripting

---

## Greppable Output

The `-g` or `--greppable` flag produces machine-parseable output.

```bash
# Basic greppable output
rustscan -a 192.168.1.1 -g

# Greppable with no Nmap follow-up
rustscan -a 192.168.1.1 -g --no-nmap

# Pipe to other tools
rustscan -a 192.168.1.1 -g | grep "Open"
```

### Parsing Greppable Output

```bash
# Extract open ports
rustscan -a 192.168.1.1 -g --no-nmap | grep -oP '\d+' | sort -n | uniq

# Feed to Nmap manually
ports=$(rustscan -a 192.168.1.1 -g --no-nmap 2>/dev/null | tr ',' '\n' | grep -oP '\d+' | paste -sd,)
nmap -sV -p$ports 192.168.1.1
```

---

## Configuration File

RustScan supports TOML configuration files for persistent settings.

### Config File Location

Default location: `~/.rustscan.toml`

### Configuration Options

```toml
# ~/.rustscan.toml

# Target addresses (can be overridden by -a)
addresses = ["192.168.1.0/24"]

# Port range
ports = [1, 65535]

# Scan tuning
batch_size = 4500
timeout = 1500
ulimit = 5000

# Number of retries for failed connections
tries = 1

# Greppable output
greppable = false

# Accessible mode
accessible = false

# Skip Nmap
no_nmap = false

# Nmap command and arguments
command = ["nmap", "-sC", "-sV"]

# Scripts directory
scripts = "/home/user/.rustscan_scripts"
```

### Using Custom Config

```bash
# Use specific config file
rustscan -a 192.168.1.1 --config /path/to/config.toml

# Override config options via CLI
rustscan -a 192.168.1.1 --config ~/.rustscan.toml -b 8000
```

### Example Configurations

**Speed-focused config (lab):**

```toml
# ~/.rustscan-fast.toml
batch_size = 10000
timeout = 500
ulimit = 8000
command = ["nmap", "-sV", "--version-light"]
```

**Stealth config:**

```toml
# ~/.rustscan-stealth.toml
batch_size = 100
timeout = 3000
tries = 2
command = ["nmap", "-sV", "-T2"]
```

**CTF config:**

```toml
# ~/.rustscan-ctf.toml
batch_size = 5000
timeout = 1000
command = ["nmap", "-sC", "-sV", "-oA", "initial_scan"]
```

---

## Proxychains Usage

RustScan can be used with proxychains for anonymity or to access internal networks via pivots.

### Basic Proxychains Setup

```bash
# Basic usage (slow due to proxy overhead)
proxychains rustscan -a 10.10.10.1 -b 100 -t 5000

# More conservative for proxy reliability
proxychains rustscan -a 10.10.10.1 -b 50 -t 10000 --no-nmap
```

### Important Considerations

1. **Reduce batch size significantly** - Proxies can't handle high concurrency
2. **Increase timeout** - Proxy latency adds delay
3. **Disable Nmap or run separately** - Nmap through proxychains may need different settings

```bash
# Recommended proxychains settings
proxychains rustscan -a 10.10.10.1 -b 50 -t 10000 --no-nmap

# Then run Nmap separately on discovered ports
proxychains nmap -sT -sV -p22,80,443 10.10.10.1
```

### SOCKS Proxy Direct

For SOCKS proxies, you can also use environment variables:

```bash
# With SOCKS5 proxy
ALL_PROXY=socks5://127.0.0.1:1080 rustscan -a 10.10.10.1 -b 100 -t 5000
```

---

## Practical Workflows

### Workflow 1: Fast Initial Scan Then Detailed Nmap

```bash
# Step 1: Fast port discovery
rustscan -a target.com -b 5000 --no-nmap -g > ports.txt

# Step 2: Parse ports
ports=$(cat ports.txt | grep -oP '\d+' | sort -n | uniq | paste -sd,)

# Step 3: Detailed Nmap scan on discovered ports
nmap -sC -sV -p$ports -oA detailed_scan target.com
```

### Workflow 2: Quick CTF Reconnaissance

```bash
# All-in-one fast scan with scripts and output
rustscan -a 10.10.10.1 -b 5000 -- -sC -sV -oA initial

# Check results
cat initial.nmap
```

### Workflow 3: Network Sweep

```bash
# Quick sweep of a /24
rustscan -a 192.168.1.0/24 -b 3000 --no-nmap -g > alive_hosts.txt

# Parse and scan interesting hosts
for ip in $(cat alive_hosts.txt | grep -oP '\d+\.\d+\.\d+\.\d+' | sort -u); do
    rustscan -a $ip -- -sV -oN "scan_$ip.txt"
done
```

### Workflow 4: Specific Port Focus

```bash
# Scan common web ports across multiple hosts
rustscan -a hosts.txt -p 80,443,8080,8443 -- -sV --script http-enum

# Scan for SMB/RDP (Windows networks)
rustscan -a 192.168.1.0/24 -p 445,3389 -- -sV --script smb-enum-shares
```

### Workflow 5: Slow and Steady (IDS Evasion)

```bash
# Slow scan to avoid detection
rustscan -a target.com -b 100 -t 3000 -- -T2 -sV

# With random delay between batches (use a wrapper script)
for port_range in "1-1000" "1001-10000" "10001-65535"; do
    rustscan -a target.com -r $port_range -b 50 -t 3000 --no-nmap
    sleep $((RANDOM % 10 + 5))
done
```

---

## Comparison with Other Scanners

### RustScan vs Nmap vs Masscan

| Feature | RustScan | Nmap | Masscan |
|---------|----------|------|---------|
| **Primary Purpose** | Fast port discovery + Nmap integration | Comprehensive scanning & analysis | Maximum speed internet scanning |
| **Speed (all ports)** | ~3-10 seconds | Minutes to hours | Seconds (10M pps possible) |
| **Service Detection** | Via Nmap integration | Native (-sV) | Limited banner grabbing |
| **Script Engine** | Python/Lua/Shell + Nmap NSE | NSE (Lua) | None |
| **OS Detection** | Via Nmap | Native (-O) | None |
| **Accuracy** | High (adaptive) | Highest | Good (may miss on fast scans) |
| **Stealth Options** | Limited | Extensive | Limited |
| **UDP Scanning** | Via Nmap | Native (-sU) | Native |
| **CIDR Support** | Yes | Yes | Yes |
| **Custom TCP Stack** | No (uses OS) | Optional (raw sockets) | Yes (bypasses OS) |
| **Output Formats** | Greppable, Nmap formats | Normal, XML, Grepable, Script Kiddie | XML, JSON, Grepable, Binary |
| **Best For** | CTFs, pentests, quick recon | Detailed analysis, scripting | Internet-wide scanning, research |

### When to Use Each

**RustScan:**
- Quick port discovery on single targets or small networks
- CTF challenges where speed matters
- When you want Nmap's features with faster initial discovery
- Pentesting workflow optimization

**Nmap:**
- Detailed service enumeration and version detection
- Vulnerability scanning with NSE scripts
- OS fingerprinting
- When stealth is critical
- UDP scanning
- When accuracy is more important than speed

**Masscan:**
- Scanning entire networks or internet ranges
- Research/census-type scanning
- When you need raw packet sending speed
- Banner grabbing at scale
- When you have high-bandwidth connections

### Combined Workflow

```bash
# Masscan for large network discovery
sudo masscan -p80,443 10.0.0.0/8 --rate 10000 -oG hosts.txt

# RustScan for quick full-port on identified hosts
for ip in $(grep "Host:" hosts.txt | awk '{print $2}'); do
    rustscan -a $ip --no-nmap -g >> all_ports.txt
done

# Nmap for detailed analysis on interesting targets
nmap -sC -sV -p- target.com -oA final_scan
```
