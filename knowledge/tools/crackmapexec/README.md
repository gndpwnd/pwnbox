---
title: "CrackMapExec"
category: tool
subcategory: active-directory
tags: [deprecated]
last_updated: 2025-12-27
---

# CrackMapExec

## Table of Contents

- [Deprecation Notice](#deprecation-notice)
- [Overview](#overview)
- [Legacy Quick Reference](#legacy-quick-reference)
- [Migration to NetExec](#migration-to-netexec)

## Deprecation Notice

> **WARNING: CrackMapExec is DEPRECATED and no longer maintained.**
>
> The project successor is **NetExec (nxc)**. All new users should use NetExec instead.
> See: [NetExec Documentation](../netexec/README.md)

## Overview

CrackMapExec (CME) was a post-exploitation tool for pentesting Active Directory environments. It supported multiple protocols (SMB, WinRM, LDAP, MSSQL, SSH) and could perform credential validation, command execution, and enumeration across networks.

## Legacy Quick Reference

For systems still running CME, here are basic commands:

```bash
# SMB authentication test
crackmapexec smb <target> -u <user> -p <password>

# Pass-the-hash
crackmapexec smb <target> -u <user> -H <NTLM_hash>

# Command execution
crackmapexec smb <target> -u <user> -p <password> -x "whoami"

# Enumerate shares
crackmapexec smb <target> -u <user> -p <password> --shares

# Dump SAM hashes (requires admin)
crackmapexec smb <target> -u <user> -p <password> --sam

# Spray passwords across multiple targets
crackmapexec smb targets.txt -u users.txt -p <password> --continue-on-success
```

### Protocol Options

| Protocol | Port | Use Case |
|----------|------|----------|
| smb | 445 | Windows file shares, exec |
| winrm | 5985/5986 | Remote management |
| ldap | 389/636 | AD enumeration |
| mssql | 1433 | SQL Server access |
| ssh | 22 | Linux targets |

## Migration to NetExec

NetExec uses nearly identical syntax. Replace `crackmapexec` with `nxc`:

```bash
# CrackMapExec (deprecated)
crackmapexec smb <target> -u <user> -p <password>

# NetExec (current)
nxc smb <target> -u <user> -p <password>
```

See the [NetExec documentation](../netexec/README.md) for full usage.
