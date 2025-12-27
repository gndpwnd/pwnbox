---
title: masscan
category: scanning
tags:
  - port-scanner
  - network
  - reconnaissance
  - high-speed
sources:
  - name: GitHub Repository
    url: https://github.com/robertdavidgraham/masscan
  - name: Man Page
    url: https://man.archlinux.org/man/masscan.8.en
last_updated: 2025-12-27
---

# masscan

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Options](#key-options)
- [Output Formats](#output-formats)
- [Banner Grabbing](#banner-grabbing)
- [Documentation](#documentation)

## Overview

Masscan is the fastest Internet port scanner. It can scan the entire Internet in under 5 minutes, transmitting 10 million packets per second from a single machine.

Key characteristics:
- **Asynchronous architecture** - Similar to scanrand, unicornscan, and ZMap
- **Custom TCP/IP stack** - Bypasses OS networking for maximum speed
- **Nmap-compatible syntax** - Familiar command-line interface
- **IPv4/IPv6 support** - Both address families simultaneously

**Important**: Masscan uses its own TCP/IP stack. Use `--src-ip` for a separate IP address or configure firewall rules to prevent conflicts with the OS stack.

## Installation

```bash
# Debian/Ubuntu
sudo apt-get install git make gcc
git clone https://github.com/robertdavidgraham/masscan
cd masscan && make
sudo make install

# Other platforms
# macOS: make (with Xcode CLI tools)
# FreeBSD: gmake
# Windows: make (MinGW) or VS10 project
```

## Quick Start

### Basic Scanning

```bash
# Scan ports on a subnet
masscan -p80,443,8080 10.0.0.0/24

# Scan port range
masscan -p1-1000 192.168.1.0/24

# Scan with IPv6
masscan -p80 10.0.0.0/8 2603:3001:2d00:da00::/112
```

### Rate Limiting

```bash
# Default: 100 packets/second
masscan -p80 10.0.0.0/8

# Increase rate (careful - can overwhelm networks)
masscan -p80 10.0.0.0/8 --rate 10000

# High-speed scanning (Linux can do 1.6M pps)
masscan -p80 10.0.0.0/8 --rate 1000000
```

### Using Configuration Files

```bash
# Export current config
masscan -p80,443 10.0.0.0/8 --echo > scan.conf

# Run from config file
masscan -c scan.conf
```

## Key Options

| Option | Description |
|--------|-------------|
| `-p <ports>` | Port(s) to scan (e.g., `80`, `1-1000`, `80,443,8080`) |
| `--rate <n>` | Packets per second (default: 100) |
| `-oX <file>` | XML output (nmap compatible) |
| `-oJ <file>` | JSON output |
| `-oG <file>` | Grepable output |
| `-oL <file>` | List output (simple) |
| `-oB <file>` | Binary output (smallest, use `--readscan` to parse) |
| `--banners` | Grab banners (requires `--source-ip` or firewall rule) |
| `--source-ip <ip>` | Spoof source IP (for banner grabbing) |
| `--source-port <n>` | Source port (firewall this port for banners) |
| `--excludefile <file>` | File with ranges to exclude |
| `-c <file>` | Configuration file |
| `--echo` | Dump current config and exit |

## Output Formats

| Format | Flag | Description |
|--------|------|-------------|
| XML | `-oX` | Nmap-compatible XML |
| JSON | `-oJ` | JSON format |
| Grepable | `-oG` | Easy command-line parsing |
| List | `-oL` | Simple `state proto port ip timestamp` |
| Binary | `-oB` | Compact format, convert with `--readscan` |

## Banner Grabbing

Banner grabbing requires preventing RST packets from the OS:

```bash
# Option 1: Use separate IP address
masscan 10.0.0.0/8 -p80 --banners --source-ip 192.168.1.200

# Option 2: Firewall the source port (Linux)
iptables -A INPUT -p tcp --dport 61000 -j DROP
masscan 10.0.0.0/8 -p80 --banners --source-port 61000
```

Supported protocols: FTP, HTTP, IMAP4, memcached, POP3, SMTP, SSH, SSL, SMBv1/v2, Telnet, RDP, VNC

## Documentation

| File | Description |
|------|-------------|
| [official_docs.md](official_docs.md) | Official GitHub documentation |
