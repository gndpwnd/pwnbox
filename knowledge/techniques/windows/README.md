---
title: Windows Attack Techniques
category: techniques
tags: [windows, privilege-escalation, persistence]
last_updated: 2025-12-27
---

# Windows Attack Techniques

This directory contains documentation for Windows-specific attack techniques used in penetration testing and red team operations.

## Overview

Windows environments present unique attack surfaces due to their architecture, security mechanisms, and common misconfigurations. Understanding these techniques is essential for both offensive security professionals and defenders.

## Categories

### UAC Bypass

User Account Control (UAC) bypass techniques exploit weaknesses in Windows privilege elevation mechanisms.

**Common Techniques:**
- Fodhelper bypass (fileless, no disk write)
- Eventvwr.exe registry hijacking
- Computerdefaults.exe exploitation
- DiskCleanup scheduled task abuse
- CMSTP.exe COM object hijacking

**Detection:** Monitor registry changes in `HKCU\Software\Classes\` and process creation with elevated tokens.

### Token Manipulation

Token manipulation involves stealing or impersonating security tokens to gain elevated privileges.

**Common Techniques:**
- Token impersonation (SeImpersonatePrivilege)
- Token duplication
- Primary token theft
- Potato attacks (Hot/Rotten/Juicy/Sweet Potato)
- PrintSpoofer exploitation

**Required Privileges:** SeImpersonatePrivilege, SeAssignPrimaryTokenPrivilege

### DLL Hijacking

DLL hijacking exploits the Windows DLL search order to load malicious libraries.

**Common Techniques:**
- DLL search order hijacking
- Phantom DLL loading
- DLL side-loading
- Known DLLs bypass
- WinSxS exploitation

**Targets:** Applications with missing DLLs, unsigned DLL loading, writable PATH directories.

### Service Exploitation

Windows services run with elevated privileges and are common privilege escalation targets.

**Common Techniques:**
- Unquoted service paths
- Weak service permissions (modifiable binpath)
- Service binary replacement
- Service registry key modification
- Insecure service dependencies

**Enumeration Tools:** PowerUp, WinPEAS, accesschk.exe

## Privilege Escalation Workflow

1. **Enumerate** - Gather system information and identify misconfigurations
2. **Analyze** - Evaluate potential attack vectors and their likelihood of success
3. **Exploit** - Execute the most reliable technique for the target environment
4. **Verify** - Confirm elevated access and maintain persistence if needed

## Related Tools

| Tool | Purpose |
|------|---------|
| PowerUp | PowerShell privilege escalation scanner |
| WinPEAS | Windows privilege escalation enumeration |
| BeRoot | Privilege escalation path detector |
| Seatbelt | Security-focused host enumeration |
| SharpUp | C# port of PowerUp |

## Quick Reference Commands

```powershell
# Check current privileges
whoami /priv

# List running services
Get-Service | Where-Object {$_.Status -eq "Running"}

# Find unquoted service paths
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows"

# Check service permissions
accesschk.exe -uwcqv "Authenticated Users" * /accepteula
```

## Detailed Guides

- **[Privilege Escalation](privilege-escalation.md)** - Comprehensive Windows privilege escalation techniques including:
  - Service misconfigurations (unquoted paths, weak permissions, insecure executables)
  - Registry exploits (AlwaysInstallElevated, Autorun keys)
  - Scheduled tasks exploitation
  - DLL hijacking (search order, phantom DLL)
  - Token impersonation (Potato attacks, SeImpersonate)
  - UAC bypass techniques
  - Kernel exploits
  - Credential harvesting locations
  - Notable vulnerabilities (PrintNightmare, ZeroLogon, EternalBlue)

## References

- [PayloadsAllTheThings - Windows Privesc](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [HackTricks - Windows Local Privilege Escalation](https://book.hacktricks.xyz/)
- [LOLBAS Project](https://lolbas-project.github.io/)
