---
title: "nikto"
category: "tool"
tags:
  - web-scanning
  - vulnerability-scanner
  - reconnaissance
sources:
  - type: github
    url: "https://github.com/sullo/nikto"
  - type: documentation
    url: "https://cirt.net/Nikto2"
last_updated: "2025-12-27"
---

# Nikto

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Common Options](#common-options)
- [Output Formats](#output-formats)
- [Documentation Files](#documentation-files)
- [Related Tools](#related-tools)

## Overview

Nikto is an open-source web server scanner that performs comprehensive tests against web servers for multiple items, including over 6700 potentially dangerous files/programs, checks for outdated versions of over 1250 servers, and version-specific problems on over 270 servers.

**Key Features:**
- Identifies web server software and version
- Detects dangerous files, CGIs, and misconfigurations
- Checks for outdated software with known vulnerabilities
- Tests SSL/TLS configurations
- Multiple output formats (HTML, XML, JSON, CSV)
- Extensible plugin architecture

## Installation

### Kali Linux (Pre-installed)

```bash
# Already installed on Kali, verify with:
nikto -Version

# Update to latest
sudo apt update && sudo apt install -y nikto
```

### Debian/Ubuntu

```bash
sudo apt update && sudo apt install -y nikto
```

### From Source (Latest)

```bash
git clone https://github.com/sullo/nikto.git
cd nikto/program
perl nikto.pl -Version
```

### Docker

```bash
docker pull sullo/nikto
docker run --rm sullo/nikto -h http://target.com
```

### Update Databases

```bash
nikto -update
```

## Quick Start

### Basic Scan

```bash
nikto -h http://target.com
```

### HTTPS Target

```bash
nikto -h https://target.com -ssl
```

### Scan Specific Port

```bash
nikto -h target.com -p 8080
```

### Multiple Ports

```bash
nikto -h target.com -p 80,443,8080,8443
```

### Save Output

```bash
nikto -h http://target.com -o scan_results.txt
```

### Scan with Authentication

```bash
nikto -h http://target.com -id admin:password
```

### Scan Through Proxy

```bash
nikto -h http://target.com -useproxy http://127.0.0.1:8080
```

### Aggressive Scan (All Plugins)

```bash
nikto -h http://target.com -Plugins "@@ALL"
```

## Common Options

| Option | Description |
|--------|-------------|
| `-h, -host` | Target host (IP, hostname, or URL) |
| `-p, -port` | Port(s) to scan (default: 80) |
| `-ssl` | Force SSL mode on specified port |
| `-o, -output` | Output file path |
| `-Format` | Output format (csv, htm, txt, xml, json, nbe, sql) |
| `-Tuning` | Scan tuning to include/exclude test types |
| `-Plugins` | Plugins to run (list, select, or @@ALL) |
| `-id` | HTTP authentication (user:password) |
| `-useproxy` | Proxy URL (http://host:port) |
| `-Pause` | Pause between requests (seconds) |
| `-evasion` | IDS evasion techniques (1-8) |
| `-update` | Update databases and plugins |
| `-vhost` | Virtual host to use in Host header |
| `-maxtime` | Maximum scan time per host |

## Output Formats

| Format | Flag | Description |
|--------|------|-------------|
| Text | `-Format txt` | Plain text output (default) |
| HTML | `-Format htm` | HTML report for browsers |
| CSV | `-Format csv` | Comma-separated values |
| XML | `-Format xml` | XML structured output |
| JSON | `-Format json` | JSON format for parsing |

```bash
# HTML report
nikto -h http://target.com -o report.html -Format htm

# JSON for parsing
nikto -h http://target.com -o scan.json -Format json
```

## Documentation Files

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Scanning techniques, tuning options, evasion methods |

## Related Tools

| Tool | Purpose |
|------|---------|
| **Nmap** | Initial port scanning and service discovery |
| **Gobuster/Feroxbuster** | Directory enumeration after nikto |
| **Burp Suite/ZAP** | Manual testing and web proxying |
| **Nuclei** | CVE-specific vulnerability testing |
| **WhatWeb** | Quick web technology fingerprinting |

## Resources

- [Official Website](https://cirt.net/Nikto2)
- [GitHub Repository](https://github.com/sullo/nikto)
- [Documentation Wiki](https://github.com/sullo/nikto/wiki)
