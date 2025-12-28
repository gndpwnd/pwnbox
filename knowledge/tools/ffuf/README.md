---
title: "ffuf"
category: "enumeration"
tags:
  - web-fuzzing
  - directory-discovery
  - parameter-fuzzing
  - subdomain-enumeration
  - vhost-discovery
  - content-discovery
sources:
  - type: github
    url: "https://github.com/ffuf/ffuf"
  - type: documentation
    url: "https://github.com/ffuf/ffuf/wiki"
last_updated: "2025-12-27"
---

# ffuf - Fuzz Faster U Fool

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Common Options](#common-options)
- [Filtering and Matching](#filtering-and-matching)
- [Documentation Files](#documentation-files)

## Overview

ffuf (Fuzz Faster U Fool) is a fast web fuzzer written in Go. It excels at content discovery, parameter fuzzing, virtual host discovery, and subdomain enumeration. ffuf uses the `FUZZ` keyword as a placeholder that gets replaced with wordlist entries.

**Key Features:**
- Extremely fast with configurable concurrency
- Multiple fuzzing points using FUZZ, FUZZ2, etc.
- Flexible filtering and matching options
- POST data and header fuzzing
- JSON output for automation
- Recursive directory discovery
- Rate limiting and request throttling

## Installation

```bash
# Go install (recommended, requires Go 1.16+)
go install github.com/ffuf/ffuf/v2@latest

# Kali Linux
sudo apt update && sudo apt install -y ffuf

# macOS (Homebrew)
brew install ffuf

# Download prebuilt binary
# https://github.com/ffuf/ffuf/releases
```

## Quick Start

### Basic Directory Discovery

```bash
# Simple directory scan
ffuf -u http://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt

# With file extensions
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.html,.txt,.js
```

### Virtual Host Discovery

```bash
ffuf -u http://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fs 1234
```

### Parameter Fuzzing

```bash
# GET parameter
ffuf -u "http://target.com/page?id=FUZZ" -w numbers.txt

# POST parameter
ffuf -u http://target.com/login -X POST -d "user=admin&pass=FUZZ" -w passwords.txt
```

### Subdomain Enumeration

```bash
ffuf -u http://FUZZ.target.com -w subdomains.txt -mc 200,301,302,403
```

## Common Options

### General Options

| Option | Description |
|--------|-------------|
| `-u` | Target URL with FUZZ keyword |
| `-w` | Wordlist path (use `-w wordlist:KEYWORD` for multiple) |
| `-t` | Number of concurrent threads (default: 40) |
| `-p` | Delay between requests (e.g., `0.1` for 100ms) |
| `-rate` | Rate limit (requests per second) |
| `-timeout` | HTTP request timeout in seconds (default: 10) |
| `-r` | Follow redirects |
| `-recursion` | Enable recursive scanning |
| `-recursion-depth` | Maximum recursion depth |
| `-o` | Output file path |
| `-of` | Output format: json, ejson, html, md, csv, all |

### Request Options

| Option | Description |
|--------|-------------|
| `-X` | HTTP method (GET, POST, PUT, DELETE, etc.) |
| `-H` | HTTP header (can be used multiple times) |
| `-d` | POST data |
| `-b` | Cookie data |
| `-x` | Proxy URL (http://127.0.0.1:8080) |
| `-e` | Comma-separated list of extensions |
| `-ic` | Ignore wordlist comments |

## Filtering and Matching

### Match Options (Whitelist)

| Option | Description |
|--------|-------------|
| `-mc` | Match HTTP status codes (default: 200,204,301,302,307,401,403,405,500) |
| `-ms` | Match response size |
| `-mw` | Match word count |
| `-ml` | Match line count |
| `-mr` | Match regex pattern |
| `-mt` | Match response time (milliseconds) |

### Filter Options (Blacklist)

| Option | Description |
|--------|-------------|
| `-fc` | Filter HTTP status codes |
| `-fs` | Filter response size |
| `-fw` | Filter word count |
| `-fl` | Filter line count |
| `-fr` | Filter regex pattern |
| `-ft` | Filter response time (milliseconds) |

### Auto-Calibration

```bash
# Enable auto-calibration to filter common responses
ffuf -u http://target.com/FUZZ -w wordlist.txt -ac

# Auto-calibration with custom strategy
ffuf -u http://target.com/FUZZ -w wordlist.txt -acc -acs advanced
```

## Quick Examples

```bash
# Directory discovery with status code filter
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404

# Discover hidden parameters
ffuf -u "http://target.com/page?FUZZ=test" -w params.txt -fs 1234

# VHost discovery with size filter
ffuf -u http://10.10.10.10 -H "Host: FUZZ.target.com" -w vhosts.txt -fs 0

# POST login fuzzing
ffuf -u http://target.com/login -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=FUZZ" -w passwords.txt -fc 401

# Multiple wordlists (clusterbomb mode)
ffuf -u http://target.com/FUZZ/FUZ2Z -w dirs.txt:FUZZ -w files.txt:FUZ2Z

# With extensions and recursion
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.html -recursion -recursion-depth 2

# Output to JSON, through proxy
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.json -of json -x http://127.0.0.1:8080
```

## Documentation Files

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Advanced fuzzing techniques, filtering strategies, and practical examples |
| [wordlists.md](wordlists.md) | Wordlist recommendations and optimization for different scenarios |

## Resources

- [Official GitHub](https://github.com/ffuf/ffuf)
- [ffuf Wiki](https://github.com/ffuf/ffuf/wiki)
- [SecLists](https://github.com/danielmiessler/SecLists)
- [Assetnote Wordlists](https://wordlists.assetnote.io/)
