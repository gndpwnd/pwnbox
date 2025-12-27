# RustScan - Official Documentation

Source: https://github.com/RustScan/RustScan

---

## Overview

RustScan is a modern port scanner written in Rust. It combines the speed of asynchronous scanning with the power of Nmap's detailed analysis. The scanner can identify all 65,535 ports in seconds, then automatically passes discovered ports to Nmap for comprehensive service detection.

## Command Reference

### Basic Syntax

```
rustscan [FLAGS] [OPTIONS] [-- <command>...]
```

### Flags

| Flag | Description |
|------|-------------|
| `--accessible` | Accessible mode for screen readers (removes banner/formatting) |
| `-g, --greppable` | Machine-parseable output format |
| `-h, --help` | Display help information |
| `--no-nmap` | Skip automatic Nmap scan after port discovery |
| `-V, --version` | Display version information |

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `-a, --addresses <addresses>` | Required | Target IP addresses, hostnames, or CIDR ranges |
| `-p, --ports <ports>` | All | Specific ports to scan (comma-separated) |
| `-r, --range <range>` | 1-65535 | Port range to scan (e.g., 1-1000) |
| `-b, --batch-size <size>` | 4500 | Number of ports scanned concurrently |
| `-t, --timeout <ms>` | 1500 | Timeout per port in milliseconds |
| `-u, --ulimit <value>` | 5000 | Maximum file descriptors |
| `--tries <count>` | 1 | Number of retry attempts per port |
| `--config <file>` | ~/.rustscan.toml | Configuration file path |
| `--scripts <path>` | None | Custom scripts directory |

### Nmap Arguments

Everything after `--` is passed directly to Nmap:

```bash
rustscan -a target.com -- -sV -sC -A
```

## Usage Examples

### Basic Scans

```bash
# Single target
rustscan -a 192.168.1.1

# Multiple targets
rustscan -a 192.168.1.1,192.168.1.2,192.168.1.3

# CIDR notation
rustscan -a 192.168.1.0/24

# From file (one target per line)
rustscan -a targets.txt

# Specific ports
rustscan -a 192.168.1.1 -p 80,443,8080

# Port range
rustscan -a 192.168.1.1 -r 1-1000
```

### Speed Tuning

```bash
# Fast scan (increase batch size)
rustscan -a 192.168.1.1 -b 8000

# Slow, reliable scan
rustscan -a target.com -b 500 -t 3000

# Handle "too many open files" error
rustscan -a 192.168.1.1 -u 3000 -b 2000
```

### Nmap Integration

```bash
# Service version detection
rustscan -a 192.168.1.1 -- -sV

# Default scripts + version
rustscan -a 192.168.1.1 -- -sC -sV

# Aggressive scan
rustscan -a 192.168.1.1 -- -A

# Vulnerability scripts
rustscan -a 192.168.1.1 -- --script vuln

# Save Nmap output
rustscan -a 192.168.1.1 -- -oA results
```

### Output Modes

```bash
# Greppable output (machine-readable)
rustscan -a 192.168.1.1 -g

# Accessible mode (screen reader friendly)
rustscan -a 192.168.1.1 --accessible

# Port discovery only (no Nmap)
rustscan -a 192.168.1.1 --no-nmap
```

## Configuration File

RustScan can be configured via a TOML file at `~/.rustscan.toml`:

```toml
# Addresses to scan (overridable via CLI)
addresses = ["192.168.1.0/24"]

# Ports (default: all)
ports = [80, 443, 8080]

# Or use a range
# range = [1, 1000]

# Performance tuning
batch_size = 4500
timeout = 1500
ulimit = 5000
tries = 1

# Output options
greppable = false
accessible = false

# Nmap integration
no_nmap = false
command = ["nmap", "-sC", "-sV"]

# Custom scripts
scripts = "/home/user/.rustscan_scripts"
```

## Scripting Engine

RustScan supports custom scripts in Python, Lua, and Shell.

### Script Format

```python
#!/usr/bin/env python3
# tags = ["safe", "example"]
# developer = ["Author Name"]
# call_format = "python3 {{script}} {{ip}} {{port}}"

import sys

ip = sys.argv[1]
port = sys.argv[2]

# Your logic here
print(f"Scanning {ip}:{port}")
```

### Running Scripts

```bash
# Use scripts from directory
rustscan -a 192.168.1.1 --scripts ~/.rustscan_scripts

# Combined with Nmap
rustscan -a 192.168.1.1 --scripts ~/.rustscan_scripts -- -sV
```

## Troubleshooting

### Too Many Open Files

If you encounter "Too many open files" errors:

```bash
# Option 1: Reduce ulimit in RustScan
rustscan -a target -u 3000 -b 2000

# Option 2: Increase system limit temporarily
ulimit -n 10000
rustscan -a target

# Option 3: Increase system limit permanently
# Add to /etc/security/limits.conf:
# * soft nofile 65535
# * hard nofile 65535
```

### Scan Too Slow

```bash
# Increase batch size
rustscan -a target -b 8000

# Reduce timeout
rustscan -a target -t 500
```

### Missing Ports

```bash
# Reduce batch size for reliability
rustscan -a target -b 1000

# Increase timeout
rustscan -a target -t 3000

# Add retries
rustscan -a target --tries 2
```

### Docker Usage

```bash
# Pull latest image
docker pull rustscan/rustscan:latest

# Run scan
docker run -it --rm rustscan/rustscan:latest -a target.com -- -sV

# With host network (better performance)
docker run -it --rm --network host rustscan/rustscan:latest -a 192.168.1.1
```

## Resources

- GitHub Repository: https://github.com/RustScan/RustScan
- Wiki: https://github.com/RustScan/RustScan/wiki
- Docker Hub: https://hub.docker.com/r/rustscan/rustscan
