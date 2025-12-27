---
title: "Hydra"
category: "tool"
tags: ["password-cracking", "brute-force", "network-authentication", "penetration-testing"]
sources:
  - type: github
    url: "https://github.com/vanhauser-thc/thc-hydra"
  - type: manpage
    url: "https://man.archlinux.org/man/hydra.1.en"
last_updated: "2025-12-27"
---

# Hydra

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Supported Protocols](#supported-protocols)
- [Common Options](#common-options)
- [Documentation](#documentation)

## Overview

Hydra is a fast, parallelized network logon cracker supporting numerous protocols. It enables security researchers and penetration testers to demonstrate how easily unauthorized access can be gained through weak credentials.

Key features:
- Parallel connections for high-speed attacks
- Support for 50+ protocols
- Flexible credential input (single, wordlist, or generated)
- Session restore capability
- SSL/TLS support for most protocols

## Installation

```bash
# Debian/Ubuntu
sudo apt install hydra

# Arch Linux
sudo pacman -S hydra

# From source
git clone https://github.com/vanhauser-thc/thc-hydra
cd thc-hydra && ./configure && make && sudo make install
```

## Quick Start

### SSH Brute Force

```bash
# Single user, password list
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.100

# User list, password list
hydra -L users.txt -P passwords.txt -t 4 ssh://192.168.1.100
```

### FTP Brute Force

```bash
# With verbose output
hydra -l anonymous -P passwords.txt -vV ftp://192.168.1.100

# Custom port
hydra -l admin -P passwords.txt -s 2121 ftp://192.168.1.100
```

### HTTP POST Form

```bash
# Login form attack
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/login:username=^USER^&password=^PASS^:Invalid credentials"

# HTTPS with cookies
hydra -l admin -P passwords.txt -S 192.168.1.100 https-post-form \
  "/login:user=^USER^&pass=^PASS^:F=incorrect:H=Cookie: session=abc123"
```

## Supported Protocols

| Category | Protocols |
|----------|-----------|
| Remote Access | ssh, sshkey, telnet, rlogin, rsh, rexec, vnc, rdp |
| File Transfer | ftp, ftps, smb, ncp, svn |
| Mail | smtp, smtp-enum, pop3, imap |
| Web | http-get, http-post, http-head, http-get-form, http-post-form, http-proxy |
| Database | mysql, mssql, postgres, oracle, oracle-listener, oracle-sid, redis |
| Directory | ldap2, ldap3, adam6500 |
| Other | snmp, socks5, sip, xmpp, teamspeak, asterisk, cisco, cisco-enable |

## Common Options

| Option | Description |
|--------|-------------|
| `-l LOGIN` | Single username |
| `-L FILE` | Username wordlist |
| `-p PASS` | Single password |
| `-P FILE` | Password wordlist |
| `-C FILE` | Colon-separated `user:pass` file |
| `-t TASKS` | Parallel connections (default: 16) |
| `-s PORT` | Custom target port |
| `-S` | Use SSL/TLS |
| `-vV` | Verbose mode with login attempts |
| `-f` | Stop on first valid credential |
| `-o FILE` | Output results to file |
| `-R` | Restore previous session |
| `-e nsr` | Try null password (n), login as pass (s), reversed login (r) |

## Documentation

| File | Description |
|------|-------------|
| [protocols.md](./protocols.md) | Detailed protocol reference with examples |
| [official_docs.md](./official_docs.md) | Official GitHub documentation |
