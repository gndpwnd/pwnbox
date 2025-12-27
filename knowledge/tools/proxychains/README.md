---
title: proxychains
category: networking
tags:
  - proxy
  - pivoting
  - tunnel
  - socks
  - tcp
version: "4.3.0"
website: https://github.com/haad/proxychains
---

# proxychains

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Quick Start](#quick-start)
- [Chaining Modes](#chaining-modes)
- [Documentation](#documentation)

## Overview

ProxyChains is a UNIX tool that redirects TCP connections through SOCKS4a/5 or HTTP proxies. It hooks network-related libc functions in dynamically linked programs via a preloaded DLL.

**Key Features:**
- Route traffic through proxy chains (SOCKS4/5, HTTP)
- Mix different proxy types in a single chain
- DNS resolution through proxy
- Support for .onion addresses with Tor

**Use Cases:**
- Bypass restrictive firewalls
- Pivot through compromised hosts
- Anonymize network traffic
- Proxy applications without native proxy support

> **Note:** Only works with dynamically linked programs using the same libc.

## Installation

```bash
# Debian/Ubuntu
sudo apt install proxychains4

# From source
git clone https://github.com/haad/proxychains.git
cd proxychains
./configure && make && sudo make install

# macOS (Homebrew)
brew install proxychains-ng
```

## Configuration

ProxyChains searches for configuration in this order:

1. Environment variables `PROXYCHAINS_SOCKS5_HOST` and `PROXYCHAINS_SOCKS5_PORT`
2. File specified by `PROXYCHAINS_CONF_FILE` or `-f` flag
3. `./proxychains.conf`
4. `~/.proxychains/proxychains.conf`
5. `/etc/proxychains.conf`

### Configuration File Example

```ini
# /etc/proxychains.conf

# Chaining mode: dynamic_chain, strict_chain, or random_chain
dynamic_chain

# Proxy DNS requests through the proxy
proxy_dns

# Timeout settings
tcp_read_time_out 15000
tcp_connect_time_out 8000

# Proxy list (type host port [user pass])
[ProxyList]
socks5 127.0.0.1 1080
socks4 192.168.1.100 9050
http   10.0.0.1 8080 user password
```

## Quick Start

### Basic Usage

```bash
# Run command through proxy chain
proxychains4 curl http://target.com

# Use custom config file
proxychains4 -f /path/to/config.conf nmap -sT target.com

# With SSH dynamic port forwarding
ssh -fN -D 1080 user@jumphost
proxychains4 firefox
```

### Environment Variables

```bash
# Quick SOCKS5 proxy setup (bypasses config file)
export PROXYCHAINS_SOCKS5_HOST=127.0.0.1
export PROXYCHAINS_SOCKS5_PORT=1080
proxychains4 curl http://target.com

# Custom DNS server
export PROXY_DNS_SERVER=8.8.8.8
proxychains4 nslookup target.com
```

### Penetration Testing Examples

```bash
# Nmap through proxy (TCP connect scan only)
proxychains4 nmap -sT -Pn -p 80,443 target.com

# Metasploit through proxy
proxychains4 msfconsole

# SSH through proxy chain
proxychains4 ssh user@internal-host
```

## Chaining Modes

| Mode | Description |
|------|-------------|
| `dynamic_chain` | Skip dead proxies, continue with next in list |
| `strict_chain` | Use all proxies in exact order (fails if any is dead) |
| `random_chain` | Random proxy order (set `chain_len` for count) |

## Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - overview and quick reference |
| [official_docs.md](official_docs.md) | Official GitHub documentation |
