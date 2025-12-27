---
title: "feroxbuster"
category: "tool"
subcategory: "enumeration"
tags:
  - web
  - directory-bruteforce
  - content-discovery
  - recursive-scanning
  - rust
last_updated: "2025-12-27"
---

# feroxbuster

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Options](#key-options)
- [Documentation Files](#documentation-files)

## Overview

feroxbuster is a fast, recursive content discovery tool written in Rust. It performs forced browsing attacks to enumerate and access resources not directly referenced by web applications but still accessible to attackers.

Key features:
- **Fast** - Written in Rust for high performance
- **Recursive** - Automatically discovers and scans subdirectories
- **Flexible** - Supports multiple wordlists, extensions, and filters
- **Proxy support** - Route traffic through Burp or SOCKS proxies

## Installation

### Kali Linux (Recommended)

```bash
sudo apt update && sudo apt install -y feroxbuster
```

### Linux/macOS (via script)

```bash
curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash -s $HOME/.local/bin
```

### macOS (Homebrew)

```bash
brew install feroxbuster
```

### Windows (Winget)

```powershell
winget install epi052.feroxbuster
```

### Update

```bash
feroxbuster --update
```

## Quick Start

### Basic scan

```bash
feroxbuster -u http://target.com
```

### Scan with extensions

```bash
feroxbuster -u http://target.com -x php,html,js,txt
```

### Custom wordlist with threads

```bash
feroxbuster -u http://target.com -w /path/to/wordlist.txt -t 100
```

### Proxy through Burp

```bash
feroxbuster -u http://target.com --insecure --proxy http://127.0.0.1:8080
```

### Non-recursive with custom headers

```bash
feroxbuster -u http://target.com --no-recursion -H "Authorization: Bearer TOKEN"
```

### Filter by status codes

```bash
feroxbuster -u http://target.com -s 200,301,302 --redirects
```

### Output to file

```bash
feroxbuster -u http://target.com -o results.txt
```

## Key Options

| Option | Description |
|--------|-------------|
| `-u, --url` | Target URL (required) |
| `-w, --wordlist` | Path to wordlist |
| `-x, --extensions` | File extensions to check (e.g., php,html,js) |
| `-t, --threads` | Number of concurrent threads (default: 50) |
| `-d, --depth` | Maximum recursion depth (default: 4) |
| `-o, --output` | Output file path |
| `-s, --status-codes` | Status codes to include (default: 200-299,301,302,307,308,401,403,405,500) |
| `-n, --no-recursion` | Disable recursive scanning |
| `-H, --headers` | Custom HTTP headers |
| `--proxy` | Proxy URL (HTTP or SOCKS5) |
| `--insecure` | Disable TLS certificate verification |
| `--redirects` | Follow redirects |
| `-q, --quiet` | Suppress banner and status output |
| `--silent` | Only output URLs (for piping) |

## Documentation Files

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Advanced techniques, filters, auto-calibration, and practical examples |
| [official_docs.md](official_docs.md) | Comprehensive official documentation |
| [github.md](github.md) | GitHub repository information |

## Resources

- [Official Documentation](https://epi052.github.io/feroxbuster-docs/)
- [GitHub Repository](https://github.com/epi052/feroxbuster)
- [Releases](https://github.com/epi052/feroxbuster/releases)
