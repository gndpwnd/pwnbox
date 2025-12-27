---
title: "ssh"
category: "tool"
tags: ["remote-access", "tunneling", "port-forwarding", "network", "encryption"]
sources:
  - type: manpage
    url: "https://man.openbsd.org/ssh"
  - type: documentation
    url: "https://www.openssh.com/manual.html"
last_updated: "2025-12-27"
---

# ssh

OpenSSH remote login client for secure encrypted communications between two untrusted hosts over an insecure network. Supports X11 forwarding, arbitrary TCP port forwarding, and UNIX-domain socket forwarding over the secure channel.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Documentation Files](#documentation-files)
- [Basic Usage](#basic-usage)
- [Authentication Methods](#authentication-methods)
- [Common Options](#common-options)
- [Related Tools](#related-tools)

## Overview

SSH (Secure Shell) is the standard tool for secure remote login and command execution. It provides:

- Encrypted communications over insecure networks
- Multiple authentication methods (password, public key, certificates)
- Port forwarding (local, remote, dynamic/SOCKS)
- X11 forwarding for graphical applications
- Agent forwarding for key management
- Secure file transfer via SCP/SFTP

## Installation

```bash
# Debian/Ubuntu
sudo apt install openssh-client

# RHEL/CentOS/Fedora
sudo dnf install openssh-clients

# Arch Linux
sudo pacman -S openssh

# macOS (pre-installed)
# For updates: brew install openssh
```

## Quick Start

```bash
# Basic connection
ssh user@hostname

# Connect on non-standard port
ssh -p 2222 user@hostname

# Connect with specific identity file
ssh -i ~/.ssh/id_ed25519 user@hostname

# Execute remote command
ssh user@hostname 'ls -la /var/log'

# Local port forwarding (access remote service locally)
ssh -L 8080:localhost:80 user@hostname

# Dynamic SOCKS proxy
ssh -D 1080 user@hostname

# Jump through bastion host
ssh -J bastion@jump.example.com user@target.internal
```

## Documentation Files

| File | Description |
|------|-------------|
| [options.md](options.md) | Complete command-line options reference |
| [tunneling.md](tunneling.md) | SSH tunneling (local, remote, dynamic port forwarding) |
| [config.md](config.md) | SSH configuration file (~/.ssh/config) options |
| [examples.md](examples.md) | Practical usage examples and common scenarios |
| [manpage.md](manpage.md) | Full SSH man page |

## Basic Usage

```bash
# Syntax
ssh [options] [user@]hostname [command]

# URI format
ssh ssh://[user@]hostname[:port]
```

### Connection Examples

```bash
# Interactive shell
ssh admin@192.168.1.100

# Run command and exit
ssh root@server 'systemctl status nginx'

# Verbose output for debugging
ssh -v user@hostname

# Force password authentication
ssh -o PreferredAuthentications=password user@hostname
```

## Authentication Methods

1. **Public Key** (recommended) - Use ssh-keygen to create keys
2. **Password** - Interactive password prompt
3. **Certificate** - Signed certificates for scalable deployments
4. **GSSAPI/Kerberos** - Enterprise single sign-on
5. **Host-based** - Trust based on client hostname

### Key-Based Authentication Setup

```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "user@hostname"

# Copy public key to server
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server

# Or manually append to ~/.ssh/authorized_keys on server
cat ~/.ssh/id_ed25519.pub | ssh user@server 'cat >> ~/.ssh/authorized_keys'
```

## Common Options

| Option | Description |
|--------|-------------|
| `-p port` | Connect to specified port |
| `-i file` | Identity file (private key) |
| `-l user` | Login username |
| `-L [bind:]port:host:port` | Local port forwarding |
| `-R [bind:]port:host:port` | Remote port forwarding |
| `-D [bind:]port` | Dynamic SOCKS proxy |
| `-J user@host` | Jump host (ProxyJump) |
| `-N` | No remote command (for port forwarding) |
| `-f` | Go to background |
| `-v` | Verbose mode (-vv, -vvv for more) |
| `-C` | Enable compression |
| `-X` | Enable X11 forwarding |
| `-A` | Enable agent forwarding |
| `-t` | Force pseudo-terminal allocation |
| `-o option` | Set configuration option |

## Escape Characters

When connected, use these escape sequences (must follow newline):

| Escape | Description |
|--------|-------------|
| `~.` | Disconnect |
| `~^Z` | Background SSH |
| `~#` | List forwarded connections |
| `~?` | Display escape help |
| `~C` | Open command line (add/remove forwards) |
| `~R` | Request rekeying |

## Related Tools

- `ssh-keygen` - Generate and manage SSH keys
- `ssh-agent` - Authentication agent for key management
- `ssh-add` - Add keys to agent
- `ssh-copy-id` - Copy public key to remote server
- `scp` - Secure copy (file transfer)
- `sftp` - Secure FTP
- `sshd` - SSH daemon (server)

## Key Files

| File | Description |
|------|-------------|
| `~/.ssh/config` | User configuration file |
| `~/.ssh/known_hosts` | Known host keys |
| `~/.ssh/authorized_keys` | Authorized public keys (server) |
| `~/.ssh/id_ed25519` | Ed25519 private key |
| `~/.ssh/id_ed25519.pub` | Ed25519 public key |
| `~/.ssh/id_rsa` | RSA private key |
| `/etc/ssh/ssh_config` | System-wide client configuration |

## Security Considerations

- Prefer Ed25519 or RSA (4096-bit) keys over older algorithms
- Disable password authentication when possible
- Use ssh-agent with key confirmation for sensitive keys
- Enable agent forwarding only when necessary
- Regularly rotate keys and audit authorized_keys
- Use ProxyJump instead of agent forwarding when possible

## See Also

- [OpenSSH Manual](https://www.openssh.com/manual.html)
- [SSH Academy](https://www.ssh.com/academy/ssh)
