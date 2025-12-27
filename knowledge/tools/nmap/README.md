---
title: "nmap"
category: "tool"
subcategory: "reconnaissance"
tags: ["port-scanner", "network-discovery", "service-detection"]
last_updated: "2025-12-27"
---

# nmap

> The Network Mapper - comprehensive port scanner, service detection, and NSE scripting engine.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Common Scan Types](#common-scan-types)
- [Timing Templates](#timing-templates)
- [Output Formats](#output-formats)
- [Useful Options](#useful-options)
- [Documentation Files](#documentation-files)

## Overview

Nmap is a free and open source utility for network discovery and security auditing. It uses raw IP packets to determine available hosts, services, operating systems, packet filters/firewalls, and more.

## Installation

```bash
# Debian/Ubuntu/Kali
sudo apt install nmap

# Arch Linux
sudo pacman -S nmap

# macOS
brew install nmap
```

## Quick Start

```bash
# Basic scan (top 1000 ports)
nmap 10.10.10.1

# Aggressive scan with OS/version detection
nmap -A -T4 10.10.10.1

# Full TCP scan with scripts and version detection
nmap -sC -sV -p- 10.10.10.1

# UDP scan (requires root)
sudo nmap -sU -p- 10.10.10.1

# Scan multiple targets
nmap 10.10.10.1-254
nmap 10.10.10.0/24
nmap -iL targets.txt
```

## Common Scan Types

| Scan | Command | Description |
|------|---------|-------------|
| SYN scan | `nmap -sS` | Default stealth scan (requires root) |
| Connect scan | `nmap -sT` | Full TCP connection (no root needed) |
| UDP scan | `nmap -sU` | UDP port scan |
| Ping sweep | `nmap -sn` | Host discovery only, no port scan |
| Version detection | `nmap -sV` | Probe open ports for service info |
| OS detection | `nmap -O` | Detect operating system |
| Script scan | `nmap -sC` | Run default NSE scripts |
| Aggressive | `nmap -A` | OS, version, scripts, traceroute |

## Timing Templates

| Template | Flag | Use Case |
|----------|------|----------|
| Paranoid | `-T0` | IDS evasion (very slow) |
| Sneaky | `-T1` | IDS evasion |
| Polite | `-T2` | Reduced bandwidth usage |
| Normal | `-T3` | Default timing |
| Aggressive | `-T4` | Fast, reliable networks |
| Insane | `-T5` | Very fast, may miss ports |

## Output Formats

```bash
# Normal output
nmap -oN scan.txt 10.10.10.1

# XML output
nmap -oX scan.xml 10.10.10.1

# Grepable output
nmap -oG scan.gnmap 10.10.10.1

# All formats at once
nmap -oA scan 10.10.10.1
```

## Useful Options

| Option | Description |
|--------|-------------|
| `-p-` | Scan all 65535 ports |
| `-p 80,443` | Scan specific ports |
| `-p 1-1000` | Scan port range |
| `--top-ports 100` | Scan top N ports |
| `-Pn` | Skip host discovery |
| `-n` | No DNS resolution |
| `-v` / `-vv` | Increase verbosity |
| `--min-rate 1000` | Minimum packets per second |
| `--script vuln` | Run vulnerability scripts |
| `--script-args` | Pass arguments to scripts |

## Documentation Files

| File | Description |
|------|-------------|
| [official_docs.md](official_docs.md) | Official nmap documentation and man page |
| [reference.md](reference.md) | Quick reference and cheat sheet |
| [scripts.md](scripts.md) | NSE scripts reference and examples |
