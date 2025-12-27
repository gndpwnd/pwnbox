---
title: RustScan
category: reconnaissance
tags:
  - port-scanning
  - network
  - rust
  - nmap-integration
source: https://github.com/RustScan/RustScan
last_updated: 2025-12-27
---

# RustScan

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Nmap Integration](#nmap-integration)
- [Key Options](#key-options)
- [Documentation](#documentation)

## Overview

RustScan is a modern, fast port scanner written in Rust. It can scan all 65,535 ports in seconds and automatically integrates with Nmap for service detection and script scanning. Key features include:

- Scans all ports in approximately 3 seconds
- Automatic Nmap integration for detailed service analysis
- Adaptive learning to optimize scan performance
- Scripting engine supporting Python, Lua, and Shell
- CIDR notation and file input support

## Installation

### Package Managers

```bash
# macOS
brew install rustscan

# Arch Linux
pacman -S rustscan

# Cargo (official)
cargo install rustscan
```

### Docker

```bash
docker pull rustscan/rustscan:latest
docker run -it --rm rustscan/rustscan:latest <target>
```

### Binary Release

Download from [GitHub Releases](https://github.com/RustScan/RustScan/releases).

## Quick Start

### Basic Scan

```bash
# Scan a single target
rustscan -a 192.168.1.1

# Scan multiple targets
rustscan -a 192.168.1.1,192.168.1.2

# Scan from file
rustscan -a targets.txt
```

### Adjusting Speed

```bash
# Fast scan (increase batch size)
rustscan -a 192.168.1.1 -b 5000

# Slower, stealthier scan
rustscan -a 192.168.1.1 -b 500 --timeout 2000
```

## Nmap Integration

RustScan automatically pipes discovered ports to Nmap. Use `--` to pass arguments to Nmap:

```bash
# Basic service detection
rustscan -a 192.168.1.1 -- -sV

# Service detection with scripts
rustscan -a 192.168.1.1 -- -sC -sV

# Aggressive scan
rustscan -a 192.168.1.1 -- -A

# Specific Nmap scripts
rustscan -a 192.168.1.1 -- --script vuln
```

## Key Options

| Option | Description |
|--------|-------------|
| `-a, --addresses` | Target IP addresses or hostnames |
| `-p, --ports` | Specific ports to scan |
| `-r, --range` | Port range (e.g., 1-1000) |
| `-b, --batch-size` | Number of ports scanned concurrently (default: 4500) |
| `-t, --timeout` | Timeout per port in milliseconds |
| `-u, --ulimit` | Adjust ulimit for more concurrent connections |
| `--accessible` | Accessibility mode for screen readers |
| `-g, --greppable` | Output in greppable format |

## Documentation

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Advanced techniques, speed tuning, and workflows |
| [official_docs.md](official_docs.md) | Official usage guide and configuration |
| [github.md](github.md) | GitHub repository information |
