---
title: "ffuf - Official Documentation Reference"
category: "tools"
tags:
  - fuzzing
  - web
  - directory-bruteforce
  - ffuf
last_updated: "2025-12-27"
---

# ffuf - Official Documentation Reference

Source: https://github.com/ffuf/ffuf

> Fuzz Faster U Fool - A fast web fuzzer written in Go

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Command-Line Options](#command-line-options)
- [Fuzzing Modes](#fuzzing-modes)
- [Filter and Match Options](#filter-and-match-options)
- [Rate Limiting and Threading](#rate-limiting-and-threading)
- [Output Formats](#output-formats)
- [Wordlist Recommendations](#wordlist-recommendations)
- [Practical Examples](#practical-examples)
- [Configuration File](#configuration-file)
- [Tips and Best Practices](#tips-and-best-practices)
- [External Resources](#external-resources)

---

## Overview

ffuf (Fuzz Faster U Fool) is a fast web fuzzer written in Go. It is designed to be flexible and powerful, supporting various fuzzing modes including directory discovery, parameter fuzzing, virtual host enumeration, and subdomain discovery.

### Key Features

- **High Performance**: Written in Go with configurable concurrency (default 40 threads)
- **Flexible Fuzzing**: Uses `FUZZ` keyword as placeholder, supports multiple fuzzing points
- **Multiple Modes**: Directory, parameter, vhost, subdomain, and custom fuzzing
- **Powerful Filtering**: Match and filter by status code, size, words, lines, regex, and time
- **Auto-Calibration**: Automatically filter out common false positives
- **Output Formats**: JSON, HTML, Markdown, CSV, and extended JSON
- **Recursion**: Automatic recursive directory scanning
- **Proxy Support**: HTTP and SOCKS proxy support, including replay proxy
- **Request Customization**: Full control over HTTP method, headers, cookies, and body

---

## Installation

### Go Install (Recommended)

Requires Go 1.16 or later:

```bash
go install github.com/ffuf/ffuf/v2@latest
```

### Package Managers

```bash
# Kali Linux / Debian
sudo apt update && sudo apt install -y ffuf

# macOS (Homebrew)
brew install ffuf

# Arch Linux
sudo pacman -S ffuf

# BlackArch
sudo pacman -S ffuf
```

### From Source

```bash
git clone https://github.com/ffuf/ffuf
cd ffuf
go get
go build
```

### Pre-built Binaries

Download from: https://github.com/ffuf/ffuf/releases

### Docker

```bash
docker pull ghcr.io/ffuf/ffuf
docker run -it ghcr.io/ffuf/ffuf -u http://target/FUZZ -w /wordlist.txt
```

### Verify Installation

```bash
ffuf -V
# ffuf version: v2.1.0
```

---

## Command-Line Options

### HTTP Options

| Flag | Description | Default |
|------|-------------|---------|
| `-u` | Target URL with FUZZ keyword | Required |
| `-X` | HTTP method to use | GET |
| `-d` | POST data | - |
| `-H` | HTTP header (can be repeated) | - |
| `-b` | Cookie data | - |
| `-timeout` | HTTP request timeout in seconds | 10 |
| `-r` | Follow redirects | false |
| `-recursion` | Enable recursive scanning | false |
| `-recursion-depth` | Maximum recursion depth | 0 |
| `-recursion-strategy` | Recursion strategy: default, greedy | default |
| `-replay-proxy` | Replay matched requests through proxy | - |
| `-sni` | Target TLS SNI | - |
| `-http2` | Use HTTP2 protocol | false |

### General Options

| Flag | Description | Default |
|------|-------------|---------|
| `-w` | Wordlist file path (use -w wordlist:KEYWORD for multiple) | Required |
| `-e` | Comma-separated list of extensions (e.g., .php,.html) | - |
| `-mode` | Multi-wordlist operation mode: clusterbomb, pitchfork, sniper | clusterbomb |
| `-ic` | Ignore wordlist comments (lines starting with #) | false |
| `-request` | Load raw HTTP request from file | - |
| `-request-proto` | Protocol for raw request file | https |
| `-input-cmd` | Command to generate input | - |
| `-input-num` | Number of inputs to test (for input-cmd) | 100 |
| `-input-shell` | Shell to use for input-cmd | /bin/sh (Unix), cmd (Windows) |

### Matcher Options (Whitelist - Show Only)

| Flag | Description | Default |
|------|-------------|---------|
| `-mc` | Match HTTP status codes | 200-299,301,302,307,401,403,405,500 |
| `-ms` | Match HTTP response size | - |
| `-mw` | Match word count in response | - |
| `-ml` | Match line count in response | - |
| `-mr` | Match regex pattern in response | - |
| `-mt` | Match response time in milliseconds | - |
| `-mmode` | Matcher set operator: and, or | or |

### Filter Options (Blacklist - Hide)

| Flag | Description | Default |
|------|-------------|---------|
| `-fc` | Filter HTTP status codes | - |
| `-fs` | Filter HTTP response size | - |
| `-fw` | Filter word count in response | - |
| `-fl` | Filter line count in response | - |
| `-fr` | Filter regex pattern in response | - |
| `-ft` | Filter response time in milliseconds | - |
| `-fmode` | Filter set operator: and, or | or |

### Auto-Calibration Options

| Flag | Description | Default |
|------|-------------|---------|
| `-ac` | Automatically calibrate filtering options | false |
| `-acc` | Custom auto-calibration strings (comma-separated) | - |
| `-ach` | Per-host calibration | false |
| `-ack` | Autocalibration keyword | FUZZ |
| `-acs` | Autocalibration strategy: basic, advanced | basic |

### Performance Options

| Flag | Description | Default |
|------|-------------|---------|
| `-t` | Number of concurrent threads | 40 |
| `-p` | Delay between requests (e.g., 0.1-0.5 for range) | 0 |
| `-rate` | Rate limit (requests per second) | 0 (unlimited) |
| `-se` | Stop on spurious errors (false positives) | false |
| `-sf` | Stop when > 95% responses are filtered | false |
| `-sa` | Stop on all error cases | false |
| `-maxtime` | Maximum running time in seconds | 0 |
| `-maxtime-job` | Maximum running time per job in seconds | 0 |

### Output Options

| Flag | Description | Default |
|------|-------------|---------|
| `-o` | Output file path | - |
| `-of` | Output format: json, ejson, html, md, csv, all | json |
| `-od` | Directory for per-host output | - |
| `-or` | Don't create the output file if no results | false |
| `-s` | Silent mode (only print results) | false |
| `-v` | Verbose output (show full URLs) | false |
| `-c` | Colorize output | false |
| `-noninteractive` | Disable interactive console | false |
| `-json` | Print JSON output to stdout | false |

### Proxy Options

| Flag | Description | Default |
|------|-------------|---------|
| `-x` | HTTP proxy URL (http://127.0.0.1:8080) | - |
| `-replay-proxy` | Replay matched requests through this proxy | - |

### Other Options

| Flag | Description | Default |
|------|-------------|---------|
| `-V` | Show version information | - |
| `-h` | Show help | - |
| `-config` | Configuration file path | ~/.ffufrc |
| `-k` | Skip TLS certificate verification | false |
| `-D` | DirSearch-style wordlist compatibility | false |
| `-search` | Search for FUZZ/FUZnZ keyword in args | false |
| `-debug-log` | Write all requests and responses to file | - |

---

## Fuzzing Modes

### Directory Discovery

The primary use case - discover hidden files and directories:

```bash
# Basic directory scan
ffuf -u http://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt

# With file extensions
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.html,.txt,.js,.bak

# Filter 404 responses
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404

# Ignore wordlist comments
ffuf -u http://target.com/FUZZ -w wordlist.txt -ic

# With auto-calibration
ffuf -u http://target.com/FUZZ -w wordlist.txt -ac
```

### Parameter Fuzzing (GET)

Discover hidden GET parameters:

```bash
# Find hidden parameters
ffuf -u "http://target.com/page?FUZZ=test" -w params.txt

# Parameter value fuzzing
ffuf -u "http://target.com/page?id=FUZZ" -w numbers.txt -fc 404

# Multiple parameters
ffuf -u "http://target.com/page?user=FUZZ&role=FUZ2Z" \
    -w users.txt:FUZZ -w roles.txt:FUZ2Z

# Filter by response size difference
ffuf -u "http://target.com/page?debug=FUZZ" -w values.txt -fs 1234
```

### Parameter Fuzzing (POST)

Fuzz POST request bodies:

```bash
# Form data fuzzing
ffuf -u http://target.com/login -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=FUZZ" \
    -w passwords.txt -fc 401

# JSON body fuzzing
ffuf -u http://target.com/api/login -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"FUZZ"}' \
    -w passwords.txt -fc 401

# Discover hidden POST parameters
ffuf -u http://target.com/form -X POST \
    -d "known=value&FUZZ=test" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -w params.txt -fs 1234
```

### Virtual Host Discovery

Enumerate virtual hosts on a target server:

```bash
# Basic vhost discovery
ffuf -u http://target.com -H "Host: FUZZ.target.com" \
    -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# Filter by response size (common for vhost discovery)
ffuf -u http://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fs 0

# Filter by word count
ffuf -u http://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fw 100

# IP-based vhost discovery (when you have IP but not domain)
ffuf -u http://10.10.10.10 -H "Host: FUZZ.target.htb" -w subdomains.txt -ac

# Internal vhost discovery
ffuf -u http://internal-server -H "Host: FUZZ" -w hostnames.txt -fs 0
```

### Subdomain Enumeration

DNS-based subdomain discovery:

```bash
# Basic subdomain scan
ffuf -u http://FUZZ.target.com -w subdomains.txt -mc 200,301,302,403

# HTTPS subdomain discovery
ffuf -u https://FUZZ.target.com -w subdomains.txt -mc 200,301,302,403

# Ignore SSL errors
ffuf -u https://FUZZ.target.com -w subdomains.txt -k

# With custom timeout
ffuf -u http://FUZZ.target.com -w subdomains.txt -timeout 5
```

### Header Fuzzing

Discover functionality hidden behind specific headers:

```bash
# X-Forwarded-For header fuzzing
ffuf -u http://target.com/admin -H "X-Forwarded-For: FUZZ" \
    -w special-values.txt -fc 403

# Authorization bypass headers
ffuf -u http://target.com/admin -H "FUZZ: 127.0.0.1" \
    -w bypass-headers.txt -fc 403

# JWT token fuzzing
ffuf -u http://target.com/api/admin -H "Authorization: Bearer FUZZ" \
    -w tokens.txt -mc 200

# User-Agent fuzzing
ffuf -u http://target.com/page -H "User-Agent: FUZZ" \
    -w user-agents.txt -fs 1234
```

### Multiple Wordlists

Use multiple FUZZ keywords for complex fuzzing:

```bash
# Default keywords: FUZZ, FUZ2Z, FUZ3Z, etc.
ffuf -u http://target.com/FUZZ/FUZ2Z \
    -w dirs.txt:FUZZ -w files.txt:FUZ2Z

# Custom keywords
ffuf -u http://target.com/USERS/FILES \
    -w users.txt:USERS -w files.txt:FILES

# Three wordlists
ffuf -u http://target.com/FUZZ/FUZ2Z/FUZ3Z \
    -w dirs.txt:FUZZ -w subdirs.txt:FUZ2Z -w files.txt:FUZ3Z
```

#### Clusterbomb Mode (Default)

Tests all combinations of wordlist entries:

```bash
# All combinations (users * passwords)
ffuf -u http://target.com/login -X POST \
    -d "user=FUZZ&pass=FUZ2Z" \
    -w users.txt:FUZZ -w passwords.txt:FUZ2Z \
    -mode clusterbomb
```

#### Pitchfork Mode

Tests wordlist entries in parallel (line by line):

```bash
# Credential pairs (user1:pass1, user2:pass2, etc.)
ffuf -u http://target.com/login -X POST \
    -d "user=FUZZ&pass=FUZ2Z" \
    -w users.txt:FUZZ -w passwords.txt:FUZ2Z \
    -mode pitchfork
```

---

## Filter and Match Options

ffuf provides powerful filtering and matching capabilities to reduce noise and find relevant results.

### Match Options (Whitelist)

Match options specify what to include in results:

```bash
# Match status codes (default behavior)
ffuf -u http://target.com/FUZZ -w wordlist.txt -mc 200,301,302

# Match all codes then use filters
ffuf -u http://target.com/FUZZ -w wordlist.txt -mc all -fc 404

# Match by response size
ffuf -u http://target.com/FUZZ -w wordlist.txt -ms 1000-5000

# Match by word count
ffuf -u http://target.com/FUZZ -w wordlist.txt -mw ">100"

# Match by line count
ffuf -u http://target.com/FUZZ -w wordlist.txt -ml ">50"

# Match by regex pattern
ffuf -u http://target.com/login -X POST -d "user=admin&pass=FUZZ" \
    -w passwords.txt -mr "Welcome|Dashboard|Success"

# Match by response time (milliseconds)
ffuf -u "http://target.com/page?id=FUZZ" -w sqli.txt -mt ">3000"
```

### Filter Options (Blacklist)

Filter options specify what to exclude from results:

```bash
# Filter by status code
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404,403,500
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 400-499

# Filter by response size
ffuf -u http://target.com/FUZZ -w wordlist.txt -fs 1234
ffuf -u http://target.com/FUZZ -w wordlist.txt -fs 0,1234,5678

# Filter by word count
ffuf -u http://target.com/FUZZ -w wordlist.txt -fw 100
ffuf -u http://target.com/FUZZ -w wordlist.txt -fw 50,100,150

# Filter by line count
ffuf -u http://target.com/FUZZ -w wordlist.txt -fl 10
ffuf -u http://target.com/FUZZ -w wordlist.txt -fl 5,10,15

# Filter by regex pattern
ffuf -u http://target.com/FUZZ -w wordlist.txt -fr "Page not found"
ffuf -u http://target.com/FUZZ -w wordlist.txt -fr "(?i)error"

# Filter by response time
ffuf -u http://target.com/FUZZ -w wordlist.txt -ft "<100"
ffuf -u http://target.com/FUZZ -w wordlist.txt -ft ">5000"
```

### Auto-Calibration

Automatically determine and apply filters based on baseline responses:

```bash
# Basic auto-calibration
ffuf -u http://target.com/FUZZ -w wordlist.txt -ac

# Custom calibration strings
ffuf -u http://target.com/FUZZ -w wordlist.txt -acc "randomstring123,anothertest456"

# Advanced auto-calibration strategy
ffuf -u http://target.com/FUZZ -w wordlist.txt -acc -acs advanced

# Per-host calibration (useful for subdomain enumeration)
ffuf -u http://FUZZ.target.com -w subdomains.txt -acc -ach
```

### Operator Modes

Control how multiple matchers/filters are combined:

```bash
# Match mode: OR (default) - match if ANY condition is true
ffuf -u http://target.com/FUZZ -w wordlist.txt -mc 200,403 -mmode or

# Match mode: AND - match only if ALL conditions are true
ffuf -u http://target.com/FUZZ -w wordlist.txt -mc 200 -ms 5000 -mmode and

# Filter mode: OR (default) - filter if ANY condition is true
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404 -fs 0 -fmode or

# Filter mode: AND - filter only if ALL conditions are true
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404 -fs 0 -fmode and
```

---

## Rate Limiting and Threading

### Thread Control

```bash
# Default 40 threads
ffuf -u http://target.com/FUZZ -w wordlist.txt

# Reduce threads for slow targets or to avoid detection
ffuf -u http://target.com/FUZZ -w wordlist.txt -t 10

# Single thread for sequential requests
ffuf -u http://target.com/FUZZ -w wordlist.txt -t 1

# Increase threads for fast targets
ffuf -u http://target.com/FUZZ -w wordlist.txt -t 100

# Maximum threads (use with caution)
ffuf -u http://target.com/FUZZ -w wordlist.txt -t 200
```

### Rate Limiting

```bash
# Limit to 10 requests per second
ffuf -u http://target.com/FUZZ -w wordlist.txt -rate 10

# Very slow for stealth
ffuf -u http://target.com/FUZZ -w wordlist.txt -rate 2

# Combined with reduced threads
ffuf -u http://target.com/FUZZ -w wordlist.txt -rate 50 -t 20
```

### Request Delay

```bash
# Fixed delay in seconds
ffuf -u http://target.com/FUZZ -w wordlist.txt -p 0.5

# Random delay range
ffuf -u http://target.com/FUZZ -w wordlist.txt -p 0.1-0.5

# Combined with reduced threads
ffuf -u http://target.com/FUZZ -w wordlist.txt -p 0.2 -t 5
```

### Timeout Settings

```bash
# Default timeout (10 seconds)
ffuf -u http://target.com/FUZZ -w wordlist.txt

# Increase timeout for slow targets
ffuf -u http://target.com/FUZZ -w wordlist.txt -timeout 30

# Short timeout to skip hanging requests
ffuf -u http://target.com/FUZZ -w wordlist.txt -timeout 5
```

### Maximum Runtime

```bash
# Maximum total running time (seconds)
ffuf -u http://target.com/FUZZ -w wordlist.txt -maxtime 3600

# Maximum running time per job (seconds)
ffuf -u http://target.com/FUZZ -w wordlist.txt -maxtime-job 60
```

### Stop Conditions

```bash
# Stop on spurious errors
ffuf -u http://target.com/FUZZ -w wordlist.txt -se

# Stop when > 95% responses are filtered
ffuf -u http://target.com/FUZZ -w wordlist.txt -sf

# Stop on all error cases
ffuf -u http://target.com/FUZZ -w wordlist.txt -sa
```

---

## Output Formats

### Available Formats

| Format | Description |
|--------|-------------|
| `json` | Standard JSON output |
| `ejson` | Extended JSON with full request/response data |
| `html` | HTML report |
| `md` | Markdown format |
| `csv` | Comma-separated values |
| `all` | Generate all formats |

### Output Examples

```bash
# JSON output
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.json -of json

# Extended JSON (includes request/response)
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.json -of ejson

# HTML report
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.html -of html

# Markdown format
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.md -of md

# CSV format
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.csv -of csv

# All formats at once
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results -of all

# Per-host output directory
ffuf -u http://FUZZ.target.com -w subdomains.txt -od ./results/
```

### Output Options

```bash
# Silent mode (only print results)
ffuf -u http://target.com/FUZZ -w wordlist.txt -s

# Verbose output (show full URLs)
ffuf -u http://target.com/FUZZ -w wordlist.txt -v

# Colorized output
ffuf -u http://target.com/FUZZ -w wordlist.txt -c

# Print JSON to stdout
ffuf -u http://target.com/FUZZ -w wordlist.txt -json

# Don't create output file if no results
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.json -or

# Debug log (all requests/responses)
ffuf -u http://target.com/FUZZ -w wordlist.txt -debug-log debug.txt
```

---

## Wordlist Recommendations

### Directory Discovery

| Wordlist | Size | Use Case |
|----------|------|----------|
| `common.txt` | ~4,600 | Quick initial scan |
| `raft-small-directories.txt` | ~20,000 | Standard CTF |
| `raft-medium-directories.txt` | ~30,000 | Thorough CTF |
| `raft-large-directories.txt` | ~60,000 | Comprehensive |
| `directory-list-2.3-medium.txt` | ~220,000 | Deep enumeration |
| `directory-list-2.3-big.txt` | ~1,270,000 | Exhaustive |

### Subdomain/VHost Discovery

| Wordlist | Size | Use Case |
|----------|------|----------|
| `subdomains-top1million-5000.txt` | 5,000 | Quick scan |
| `subdomains-top1million-20000.txt` | 20,000 | Standard |
| `subdomains-top1million-110000.txt` | 110,000 | Thorough |
| `namelist.txt` | ~1,900 | Short names |
| `dns-Jhaddix.txt` | ~2,180,000 | Exhaustive |

### Parameter Fuzzing

| Wordlist | Size | Use Case |
|----------|------|----------|
| `burp-parameter-names.txt` | ~6,400 | Parameter discovery |
| `raft-large-words.txt` | ~120,000 | Comprehensive |

### Recommended Paths (Kali Linux)

```bash
# Set variable for convenience
export SECLISTS=/usr/share/seclists

# Directory discovery
$SECLISTS/Discovery/Web-Content/common.txt
$SECLISTS/Discovery/Web-Content/raft-medium-directories.txt
$SECLISTS/Discovery/Web-Content/directory-list-2.3-medium.txt

# Subdomains
$SECLISTS/Discovery/DNS/subdomains-top1million-5000.txt
$SECLISTS/Discovery/DNS/subdomains-top1million-20000.txt

# Parameters
$SECLISTS/Discovery/Web-Content/burp-parameter-names.txt

# API endpoints
$SECLISTS/Discovery/Web-Content/api/api-endpoints.txt
```

---

## Practical Examples

### CTF Web Challenge

```bash
# Aggressive discovery for CTF
ffuf -u http://target.com/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
    -e .php,.txt,.html,.bak \
    -t 100 \
    -recursion -recursion-depth 2 \
    -ac \
    -o ctf-results.json -of json
```

### API Endpoint Discovery

```bash
# REST API enumeration
ffuf -u http://target.com/api/v1/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer TOKEN" \
    -mc 200,201,204,401,403 \
    -o api-results.json -of json
```

### LFI Testing

```bash
# Local file inclusion
ffuf -u "http://target.com/page?file=FUZZ" \
    -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt \
    -fs 0 \
    -mr "root:|password|config"
```

### SQL Injection Detection

```bash
# Time-based SQLi detection
ffuf -u "http://target.com/search?q=FUZZ" \
    -w /usr/share/seclists/Fuzzing/SQLi/quick-SQLi.txt \
    -mt ">3000" \
    -t 10
```

### Stealth Scanning

```bash
# Low and slow enumeration
ffuf -u http://target.com/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/common.txt \
    -t 5 \
    -p 1-3 \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    -fc 404
```

### Authenticated Scanning

```bash
# Cookie-based authentication
ffuf -u http://target.com/admin/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt \
    -b "session=abc123; auth_token=xyz789" \
    -fc 401,403

# Header-based authentication
ffuf -u http://target.com/api/FUZZ \
    -w wordlist.txt \
    -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
    -mc 200
```

### Recursive Scanning

```bash
# Recursive with depth limit
ffuf -u http://target.com/FUZZ \
    -w wordlist.txt \
    -e .php,.html \
    -recursion \
    -recursion-depth 3 \
    -ac
```

### Backup File Discovery

```bash
# Find backup files
ffuf -u http://target.com/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt \
    -e .bak,.old,.backup,.save,.swp,~,.orig,.copy \
    -fc 404
```

### Login Brute Force

```bash
# Password brute force
ffuf -u http://target.com/login -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=FUZZ" \
    -w /usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt \
    -fc 401 \
    -fr "Invalid"

# Username enumeration
ffuf -u http://target.com/login -X POST \
    -d "username=FUZZ&password=invalid" \
    -w /usr/share/seclists/Usernames/Names/names.txt \
    -fr "Invalid username"
```

### IDOR Testing

```bash
# Numeric ID fuzzing
ffuf -u "http://target.com/api/users/FUZZ" \
    -w <(seq 1 1000) \
    -mc 200

# With authentication
ffuf -u "http://target.com/api/users/FUZZ/profile" \
    -w ids.txt \
    -H "Authorization: Bearer TOKEN" \
    -mc 200,403
```

### Proxy Integration

```bash
# Through Burp Suite
ffuf -u http://target.com/FUZZ -w wordlist.txt \
    -x http://127.0.0.1:8080

# SOCKS proxy
ffuf -u http://target.com/FUZZ -w wordlist.txt \
    -x socks5://127.0.0.1:1080

# Replay matched requests through proxy
ffuf -u http://target.com/FUZZ -w wordlist.txt \
    -replay-proxy http://127.0.0.1:8080 \
    -mc 200,403

# With proxychains
proxychains4 -q ffuf -u http://internal.target/FUZZ -w wordlist.txt
```

### Complete Enumeration Workflow

```bash
# Step 1: Quick directory scan
ffuf -u http://target.com/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/common.txt \
    -e .php,.html,.txt \
    -o step1.json -of json

# Step 2: VHost discovery
ffuf -u http://target.com -H "Host: FUZZ.target.com" \
    -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
    -ac \
    -o vhosts.json -of json

# Step 3: Deep scan on interesting directories
ffuf -u http://target.com/admin/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
    -recursion -recursion-depth 3 \
    -e .php,.bak,.txt \
    -ac \
    -o admin-deep.json -of json

# Step 4: Parameter fuzzing
ffuf -u "http://target.com/page.php?FUZZ=test" \
    -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
    -fs 1234 \
    -o params.json -of json
```

---

## Configuration File

ffuf supports configuration files for default options. The default location is `~/.ffufrc`.

### Configuration File Format

```toml
# ~/.ffufrc

[general]
colors = true
verbose = false
delay = ""
maxtime = 0
threads = 40

[http]
timeout = 10
followredirects = false
headers = ["User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)"]

[input]
ignore_wordlist_comments = true

[output]
outputformat = "json"

[filter]
status = "200-299,301,302,307,401,403,405,500"

[matcher]
# Default matchers
```

### Using Custom Config

```bash
# Specify config file
ffuf -config /path/to/config.toml -u http://target.com/FUZZ -w wordlist.txt
```

---

## Tips and Best Practices

### General Tips

1. **Always start with auto-calibration** (`-ac`) to automatically filter common false positives
2. **Use smaller wordlists first**, then expand if needed
3. **Check the response size** to identify what to filter (run without filters first)
4. **Use `-s` for scripting** to get clean output
5. **Use `-o` to save results** for later analysis

### Performance Tips

1. **Adjust threads based on target** - Start with default (40) and adjust
2. **Use rate limiting** (`-rate`) for sensitive targets or to avoid WAF
3. **Use delay** (`-p`) for stealth or rate-limited targets
4. **Set appropriate timeouts** - Lower for faster scans, higher for slow targets

### Filtering Tips

1. **Run initial scan without filters** to see response patterns
2. **Use response size filtering** (`-fs`) for vhost discovery
3. **Combine filters** for better accuracy
4. **Use regex filtering** (`-fr`) for custom error messages

### Output Tips

1. **Use JSON output** (`-of json`) for programmatic processing
2. **Use extended JSON** (`-of ejson`) when you need full request/response
3. **Use HTML output** (`-of html`) for reports
4. **Use `-v` for verbose** output with full URLs

---

## External Resources

### Official Resources

- [GitHub Repository](https://github.com/ffuf/ffuf)
- [ffuf Wiki](https://github.com/ffuf/ffuf/wiki)
- [Releases](https://github.com/ffuf/ffuf/releases)
- [Issue Tracker](https://github.com/ffuf/ffuf/issues)

### Wordlists

- [SecLists](https://github.com/danielmiessler/SecLists) - Comprehensive security wordlists
- [Assetnote Wordlists](https://wordlists.assetnote.io/) - Modern, technology-specific wordlists
- [FuzzDB](https://github.com/fuzzdb-project/fuzzdb) - Fuzzing database
- [OneListForAll](https://github.com/six2dez/OneListForAll) - Curated wordlist collection

### Tutorials and Guides

- [ffuf Tutorial - HackTricks](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/ffuf)
- [Content Discovery with ffuf - TryHackMe](https://tryhackme.com/room/ffuf)
- [Web Fuzzing with ffuf - OSCP Guide](https://oscp.infosecsanyam.in/web-fuzzing)

### Related Tools

- [gobuster](https://github.com/OJ/gobuster) - Directory/file brute-forcer
- [feroxbuster](https://github.com/epi052/feroxbuster) - Recursive content discovery
- [wfuzz](https://github.com/xmendez/wfuzz) - Web application fuzzer
- [dirsearch](https://github.com/maurosoria/dirsearch) - Web path scanner

---

## Version History

| Version | Release Date | Notable Changes |
|---------|--------------|-----------------|
| v2.1.0 | 2023 | HTTP/2 support, improved filtering |
| v2.0.0 | 2022 | Major refactor, new matching modes |
| v1.5.0 | 2021 | Recursion improvements |
| v1.4.0 | 2021 | Auto-calibration enhancements |
| v1.3.0 | 2020 | Replay proxy feature |

---

## License

ffuf is released under the MIT License. See [LICENSE](https://github.com/ffuf/ffuf/blob/master/LICENSE) for details.
