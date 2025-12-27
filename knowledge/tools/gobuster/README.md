---
title: "gobuster"
category: "enumeration"
tags:
  - directory-busting
  - dns-enumeration
  - vhost-discovery
  - web-fuzzing
sources:
  - type: github
    url: "https://github.com/OJ/gobuster"
last_updated: "2025-12-27"
---

# Gobuster

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Mode Comparison](#mode-comparison)
- [Documentation](#documentation)

## Overview

Gobuster is a high-performance brute-forcing tool written in Go for discovering hidden directories, files, DNS subdomains, and virtual hosts. It supports multiple enumeration modes including directory/file discovery, DNS subdomain enumeration, virtual host detection, and cloud storage bucket enumeration (S3/GCS).

**Key Features:**
- Multi-threaded scanning with configurable concurrency
- Multiple modes: dir, dns, vhost, s3, gcs, tftp, fuzz
- Pattern-based scanning and custom wordlists
- Docker support available

## Installation

```bash
# Go install (recommended, requires Go 1.24+)
go install github.com/OJ/gobuster/v3@latest

# Docker
docker pull ghcr.io/oj/gobuster:latest

# From source
git clone https://github.com/OJ/gobuster.git
cd gobuster && go build
```

Pre-compiled binaries available at [releases page](https://github.com/OJ/gobuster/releases).

## Quick Start

### Directory Mode

Enumerate directories and files on web servers.

```bash
# Basic scan
gobuster dir -u https://example.com -w /usr/share/wordlists/dirb/common.txt

# With extensions
gobuster dir -u https://example.com -w wordlist.txt -x php,html,js,txt

# With headers and status filtering
gobuster dir -u https://example.com -w wordlist.txt -H "Authorization: Bearer token" -s 200,301,302
```

### DNS Mode

Discover subdomains through DNS resolution.

```bash
# Basic subdomain enumeration
gobuster dns -d example.com -w subdomains.txt

# Custom DNS server with more threads
gobuster dns -d example.com -w wordlist.txt -r 8.8.8.8:53 -t 50
```

### VHost Mode

Discover virtual hosts on web servers.

```bash
# Virtual host discovery
gobuster vhost -u https://example.com --append-domain -w wordlist.txt
```

### Other Modes

```bash
# S3 bucket enumeration
gobuster s3 -w bucket-names.txt

# GCS bucket enumeration
gobuster gcs -w bucket-names.txt

# TFTP file discovery
gobuster tftp -s 10.0.0.1 -w wordlist.txt

# Custom fuzzing (use FUZZ keyword)
gobuster fuzz -u https://example.com?param=FUZZ -w wordlist.txt
```

### Common Options

```bash
-t <n>          # Thread count (default: 10)
-o <file>       # Output to file
-q              # Quiet mode
--delay <ms>    # Delay between requests
--timeout <s>   # Request timeout
```

## Mode Comparison

| Mode    | Purpose                          | Key Flags                    |
|---------|----------------------------------|------------------------------|
| `dir`   | Directory/file enumeration       | `-u`, `-w`, `-x`, `-s`       |
| `dns`   | Subdomain discovery              | `-d`, `-w`, `-r`, `-t`       |
| `vhost` | Virtual host detection           | `-u`, `-w`, `--append-domain`|
| `s3`    | Amazon S3 bucket enumeration     | `-w`, `--debug`              |
| `gcs`   | Google Cloud Storage enumeration | `-w`, `--debug`              |
| `tftp`  | TFTP file discovery              | `-s`, `-w`                   |
| `fuzz`  | Custom fuzzing with FUZZ keyword | `-u`, `-w`, `-H`, `-d`       |

## Documentation

| File | Description |
|------|-------------|
| [modes.md](modes.md) | Comprehensive guide to all gobuster modes with practical examples |
| [official_docs.md](official_docs.md) | Official GitHub documentation |

## Resources

- **SecLists**: https://github.com/danielmiessler/SecLists
- **FuzzDB**: https://github.com/fuzzdb-project/fuzzdb
