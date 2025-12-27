# masscan - Advanced Techniques

## Table of Contents

- [Rate Limiting and Bandwidth Control](#rate-limiting-and-bandwidth-control)
- [Randomization and Evasion](#randomization-and-evasion)
- [Output Formats and Parsing](#output-formats-and-parsing)
- [Excluding Ranges](#excluding-ranges)
- [Resume Capability](#resume-capability)
- [Integration with Nmap](#integration-with-nmap)
- [Scanner Comparison](#scanner-comparison)

## Rate Limiting and Bandwidth Control

### Understanding the Rate Parameter

The `--rate` parameter controls packets per second (pps). Default is 100 pps for safety.

```bash
# Conservative rate (safe for most networks)
masscan -p80,443 10.0.0.0/24 --rate 1000

# Moderate rate (dedicated scanning infrastructure)
masscan -p80,443 10.0.0.0/16 --rate 10000

# Aggressive rate (requires proper network infrastructure)
masscan -p80,443 10.0.0.0/8 --rate 100000

# Maximum theoretical rate (Linux with proper NIC)
masscan -p80 0.0.0.0/0 --rate 10000000
```

### Bandwidth Calculation

Packets are approximately 60 bytes each (SYN packet):

| Rate (pps) | Bandwidth | Time for /24 (256 hosts, 1000 ports) |
|------------|-----------|-------------------------------------|
| 100 | ~48 Kbps | ~42 minutes |
| 1,000 | ~480 Kbps | ~4.2 minutes |
| 10,000 | ~4.8 Mbps | ~26 seconds |
| 100,000 | ~48 Mbps | ~2.6 seconds |
| 1,000,000 | ~480 Mbps | ~0.26 seconds |

### Network Interface Considerations

```bash
# Specify interface explicitly
masscan -p80 10.0.0.0/8 --interface eth0

# Specify source IP (useful for multi-homed systems)
masscan -p80 10.0.0.0/8 --source-ip 192.168.1.100

# Specify source port (for firewall rules with banner grabbing)
masscan -p80 10.0.0.0/8 --source-port 60000
```

### Retries and Timing

```bash
# Increase retries for unreliable networks (default: 0)
masscan -p80 10.0.0.0/24 --retries 2

# Adjust wait time between retries
masscan -p80 10.0.0.0/24 --max-rate 1000 --retries 1
```

## Randomization and Evasion

### IP Address Randomization

Masscan randomizes target order by default using a cryptographic algorithm. This provides:
- Even distribution across target range
- Avoids overwhelming single subnets
- Makes traffic patterns less predictable

```bash
# Set a specific seed for reproducible scans
masscan -p80 10.0.0.0/8 --seed 12345

# Time-based seed (default behavior)
masscan -p80 10.0.0.0/8 --seed time
```

### Sharding for Distributed Scanning

Split scans across multiple machines:

```bash
# Machine 1 of 3
masscan -p80,443 10.0.0.0/8 --shard 1/3

# Machine 2 of 3
masscan -p80,443 10.0.0.0/8 --shard 2/3

# Machine 3 of 3
masscan -p80,443 10.0.0.0/8 --shard 3/3
```

### Source Port Randomization

```bash
# Use a specific source port
masscan -p80 10.0.0.0/24 --source-port 61000

# Random source ports (less consistent but harder to filter)
masscan -p80 10.0.0.0/24 --source-port 40000-60000
```

### TTL Manipulation

```bash
# Set specific TTL value
masscan -p80 10.0.0.0/24 --ttl 128
```

## Output Formats and Parsing

### Available Output Formats

```bash
# XML output (nmap-compatible)
masscan -p80,443 10.0.0.0/24 -oX results.xml

# JSON output (recommended for programmatic parsing)
masscan -p80,443 10.0.0.0/24 -oJ results.json

# Grepable output (simple text processing)
masscan -p80,443 10.0.0.0/24 -oG results.gnmap

# List output (minimal format)
masscan -p80,443 10.0.0.0/24 -oL results.txt

# Binary output (smallest, fastest to write)
masscan -p80,443 10.0.0.0/24 -oB results.bin
```

### Parsing Output Files

#### JSON Parsing

```bash
# Extract IPs with open port 80
jq -r 'select(.ports[].port == 80) | .ip' results.json

# Extract all IP:port combinations
jq -r '.ip + ":" + (.ports[].port | tostring)' results.json

# Filter by specific port
cat results.json | jq -r 'select(.ports[].port == 443) | .ip'
```

#### List Format Parsing

```bash
# Format: open tcp 80 192.168.1.1 1640000000
# Extract IPs only
awk '/^open/ {print $4}' results.txt

# Extract IP:port pairs
awk '/^open/ {print $4":"$3}' results.txt

# Filter specific port
awk '/^open.*tcp.*80/ {print $4}' results.txt
```

#### Grepable Format Parsing

```bash
# Extract hosts with specific open port
grep "80/open" results.gnmap | cut -d' ' -f2

# Count open ports per host
grep "Ports:" results.gnmap | cut -d' ' -f2 | sort | uniq -c
```

### Converting Binary Output

```bash
# Convert binary to JSON
masscan --readscan results.bin -oJ results.json

# Convert binary to XML
masscan --readscan results.bin -oX results.xml

# Convert binary to list format
masscan --readscan results.bin -oL results.txt
```

### Real-time Output

```bash
# Interactive output (default when no -o flag)
masscan -p80,443 10.0.0.0/24

# Append to file (useful for long-running scans)
masscan -p80 10.0.0.0/8 --append-output -oJ results.json
```

## Excluding Ranges

### Exclude File

Create a file with CIDR ranges to exclude:

```bash
# exclude.txt
0.0.0.0/8          # Current network
10.0.0.0/8         # Private (if not target)
127.0.0.0/8        # Loopback
169.254.0.0/16     # Link-local
172.16.0.0/12      # Private (if not target)
192.168.0.0/16     # Private (if not target)
224.0.0.0/4        # Multicast
240.0.0.0/4        # Reserved
255.255.255.255/32 # Broadcast
```

```bash
# Use exclude file
masscan -p80 0.0.0.0/0 --excludefile exclude.txt

# Combine with include file
masscan -p80 --includefile targets.txt --excludefile exclude.txt
```

### Inline Exclusions

```bash
# Exclude specific range
masscan -p80 10.0.0.0/8 --exclude 10.10.0.0/16

# Exclude multiple ranges
masscan -p80 10.0.0.0/8 --exclude 10.10.0.0/16 --exclude 10.20.0.0/16
```

### Standard Exclusion List

For internet-wide scanning, always exclude:

```bash
# Download community exclusion list
curl -o exclude.txt https://raw.githubusercontent.com/robertdavidgraham/masscan/master/data/exclude.conf

# Use with scan
masscan -p80 0.0.0.0/0 --excludefile exclude.txt --rate 10000
```

## Resume Capability

### Automatic State Saving

Masscan saves state when interrupted with Ctrl+C:

```bash
# Start a scan
masscan -p80 10.0.0.0/8 --rate 10000 -oJ results.json
# Press Ctrl+C to pause - creates paused.conf

# Resume the scan
masscan --resume paused.conf
```

### Manual State File

```bash
# Save configuration before scan
masscan -p80 10.0.0.0/8 --rate 10000 --echo > scan.conf

# Run from config (can be resumed if interrupted)
masscan -c scan.conf -oJ results.json
```

### Configuration File Format

```conf
# scan.conf
rate = 10000
output-format = json
output-filename = results.json
ports = 80,443,8080
range = 10.0.0.0/8
excludefile = exclude.txt
```

### Stateless Scanning and Resume

Since masscan is stateless, resumption works by:
1. Recording the random seed
2. Tracking index into randomized IP list
3. Skipping already-scanned addresses on resume

```bash
# Check resume file contents
cat paused.conf
# Shows: seed, index, range, and other parameters
```

## Integration with Nmap

### Basic Workflow: Masscan Discovery + Nmap Service Detection

```bash
# Step 1: Fast port discovery with masscan
masscan -p1-65535 10.0.0.0/24 --rate 10000 -oL masscan_results.txt

# Step 2: Extract unique IPs and ports
awk '/^open/ {print $4}' masscan_results.txt | sort -u > live_hosts.txt
awk '/^open/ {ports[$4] = ports[$4] ? ports[$4]","$3 : $3} END {for(ip in ports) print ip" -p"ports[ip]}' masscan_results.txt > nmap_targets.txt

# Step 3: Run nmap with service detection on discovered ports
while read line; do
    ip=$(echo $line | cut -d' ' -f1)
    ports=$(echo $line | cut -d' ' -f2)
    nmap -sV -sC $ports $ip -oA nmap_$ip
done < nmap_targets.txt
```

### Scripted Integration

```bash
#!/bin/bash
# masscan_to_nmap.sh

TARGET=$1
RATE=${2:-10000}

# Run masscan
masscan -p1-65535 $TARGET --rate $RATE -oJ masscan.json

# Parse and run nmap
jq -r '[.ip, (.ports[].port | tostring)] | @tsv' masscan.json | \
while read ip port; do
    echo "[*] Scanning $ip:$port with nmap"
    nmap -sV -sC -p$port $ip -oN "nmap_${ip}_${port}.txt"
done
```

### XML Compatibility

Masscan XML output is nmap-compatible:

```bash
# Generate nmap-compatible XML
masscan -p80,443 10.0.0.0/24 -oX results.xml

# Parse with nmap tools or custom scripts
# Works with tools expecting nmap XML format
```

## Scanner Comparison

### Masscan vs Nmap vs RustScan

| Feature | Masscan | Nmap | RustScan |
|---------|---------|------|----------|
| **Speed** | Fastest (10M pps) | Slow (stateful) | Fast (async) |
| **Service Detection** | Basic banners | Comprehensive | Uses nmap |
| **OS Detection** | No | Yes | Via nmap |
| **NSE Scripts** | No | Yes | Via nmap |
| **Accuracy** | Lower (async) | Highest | Medium |
| **Stealth** | Low (noisy) | Configurable | Low |
| **Resume** | Yes | Yes (-oA) | No |
| **Configuration** | Simple | Complex | Simple |

### Speed Comparison (Approximate)

Scanning 65535 ports on a single host:

| Scanner | Time | Notes |
|---------|------|-------|
| Masscan | ~3 seconds | At 100k pps |
| RustScan | ~3 seconds | Async batching |
| Nmap -T5 | ~15 minutes | Insane timing |
| Nmap -T4 | ~30 minutes | Aggressive timing |
| Nmap -T3 | ~2 hours | Normal timing |

### Accuracy Tradeoffs

**Masscan Limitations:**
- Stateless design may miss ports behind rate-limiting firewalls
- No retry mechanism by default
- Banner grabbing is basic
- Cannot detect service on non-standard ports accurately

**When to Use Each:**

| Scenario | Recommended Tool |
|----------|-----------------|
| Internet-wide surveys | Masscan |
| CTF/HTB initial scan | Masscan or RustScan |
| Detailed service enumeration | Nmap |
| Production network audit | Masscan + Nmap |
| Stealth scanning | Nmap (with timing options) |
| Quick all-port scan | RustScan |

### Recommended Workflow

```bash
# Phase 1: Fast discovery with masscan
masscan -p- $TARGET --rate 10000 -oL discovery.txt

# Phase 2: Service detection with nmap
ports=$(awk '/^open/ {print $3}' discovery.txt | sort -u | tr '\n' ',')
nmap -sV -sC -p${ports%,} $TARGET -oA detailed

# Alternative: Use RustScan for integrated workflow
rustscan -a $TARGET -- -sV -sC
```

### Performance Tuning Comparison

```bash
# Masscan: Optimize for speed
masscan -p80 10.0.0.0/8 --rate 1000000 --interface eth0

# Nmap: Optimize for speed (still slower)
nmap -sS -Pn -n --min-rate 10000 --max-retries 0 -p80 10.0.0.0/8

# RustScan: Optimize for speed
rustscan -a 10.0.0.0/8 -b 65535 --ulimit 65535 -p 80
```
