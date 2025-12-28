---
title: "WPScan"
category: "tool"
tags:
  - wordpress
  - web-scanning
  - cms-scanning
  - vulnerability-scanning
  - enumeration
sources:
  - type: github
    url: "https://github.com/wpscanteam/wpscan"
  - type: documentation
    url: "https://wpscan.com/docs"
last_updated: "2025-12-27"
---

# WPScan

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [API Token Setup](#api-token-setup)
- [Quick Start](#quick-start)
- [Common Options](#common-options)
- [Documentation](#documentation)
- [Related Tools](#related-tools)

## Overview

WPScan is a free, open-source WordPress security scanner designed to find vulnerabilities in WordPress installations. It can detect security issues in WordPress core, plugins, and themes, as well as enumerate users, perform password attacks, and identify misconfigurations.

**Key Features:**
- WordPress core, plugin, and theme vulnerability detection
- User enumeration with multiple methods
- Password brute-forcing against WordPress users
- Plugin and theme enumeration (including vulnerable versions)
- WordPress version detection
- Integration with WPVulnDB for vulnerability data
- Supports authenticated scanning
- Configurable detection modes (passive, mixed, aggressive)

## Installation

```bash
# Ruby Gem (recommended)
gem install wpscan

# Kali Linux (pre-installed, update with)
sudo apt update && sudo apt install wpscan

# Docker
docker pull wpscanteam/wpscan
docker run -it --rm wpscanteam/wpscan --url https://target.com
```

## API Token Setup

WPScan uses the WPVulnDB API for vulnerability data. Register at [wpscan.com/register](https://wpscan.com/register) for a free token (25 requests/day).

```bash
# Command line
wpscan --url https://target.com --api-token YOUR_TOKEN

# Environment variable
export WPSCAN_API_TOKEN=YOUR_TOKEN

# Config file (~/.wpscan/scan.yml)
# cli_options:
#   api_token: YOUR_TOKEN
```

## Quick Start

### Basic Scan

```bash
# Simple enumeration scan
wpscan --url https://target.com

# With API token for vulnerability data
wpscan --url https://target.com --api-token YOUR_TOKEN
```

### User Enumeration

```bash
# Enumerate users (default: 1-10)
wpscan --url https://target.com -e u

# Enumerate users 1-100
wpscan --url https://target.com -e u1-100
```

### Plugin Enumeration

```bash
# Enumerate popular plugins
wpscan --url https://target.com -e p

# Enumerate all plugins (aggressive)
wpscan --url https://target.com -e ap

# Enumerate vulnerable plugins only
wpscan --url https://target.com -e vp
```

### Theme Enumeration

```bash
# Enumerate popular themes
wpscan --url https://target.com -e t

# Enumerate all themes
wpscan --url https://target.com -e at

# Enumerate vulnerable themes only
wpscan --url https://target.com -e vt
```

### Password Attack

```bash
# Brute force with wordlist
wpscan --url https://target.com -U admin -P /usr/share/wordlists/rockyou.txt

# Multiple users
wpscan --url https://target.com -U users.txt -P passwords.txt
```

### Full Enumeration

```bash
# Comprehensive scan with all enumeration
wpscan --url https://target.com -e ap,at,u --api-token YOUR_TOKEN
```

## Common Options

| Option | Description |
|--------|-------------|
| `--url URL` | Target WordPress URL (required) |
| `-e, --enumerate` | Enumeration modes (see techniques.md) |
| `-U, --usernames` | Username(s) or file for password attack |
| `-P, --passwords` | Password wordlist for brute force |
| `--api-token TOKEN` | WPVulnDB API token |
| `-o, --output FILE` | Output to file |
| `-f, --format FORMAT` | Output format: cli, json, cli-no-color |
| `--detection-mode MODE` | passive, mixed (default), aggressive |
| `--plugins-detection MODE` | passive, mixed, aggressive |
| `--random-user-agent` | Use random User-Agent per request |
| `--force` | Skip WordPress check and force scan |
| `-t, --max-threads N` | Max threads (default: 5) |
| `--throttle MS` | Milliseconds between requests |
| `--cookie VALUE` | Cookie string for authenticated scan |
| `--proxy URL` | HTTP/SOCKS proxy (e.g., http://127.0.0.1:8080) |
| `-v, --verbose` | Verbose output |
| `--stealthy` | Use passive detection methods only |
| `--wp-content-dir DIR` | Custom wp-content directory |
| `--wp-plugins-dir DIR` | Custom plugins directory |

## Documentation

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Enumeration modes, attack techniques, and practical examples |

## Related Tools

| Tool | Purpose |
|------|---------|
| [Nuclei](../nuclei/) | General-purpose vulnerability scanner with WordPress templates |
| [Burp Suite](../burpsuite/) | Web proxy for manual WordPress testing |
| [Hydra](../hydra/) | Alternative for brute-force attacks |
| [Gobuster](../gobuster/) | Directory enumeration on WordPress sites |
| [ffuf](../ffuf/) | Fuzzing for hidden WordPress endpoints |

## Resources

- [WPScan GitHub](https://github.com/wpscanteam/wpscan)
- [WPVulnDB](https://wpscan.com/api)
- [WordPress Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Wordpress_Security_Cheat_Sheet.html)
