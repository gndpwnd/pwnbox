---
title: Privilege Escalation
category: methodology
tags: [privilege-escalation, privesc, windows, linux]
last_updated: 2025-12-27
---

# Privilege Escalation

## Overview

Privilege escalation is the process of exploiting vulnerabilities, misconfigurations, or design flaws to gain elevated access to resources that are normally protected. It typically occurs after initial access has been obtained.

**Types:**
- **Vertical (Privilege Escalation)**: Lower privilege to higher privilege (user -> admin/root)
- **Horizontal (Privilege Escalation)**: Same privilege level but different user context

## Detailed Documentation

For comprehensive techniques with step-by-step exploitation guides, see:

- **[Windows Privilege Escalation](/knowledge/techniques/windows/privilege-escalation.md)** - Complete Windows privesc guide including service exploitation, token impersonation, UAC bypass, DLL hijacking, kernel exploits, PrintNightmare, ZeroLogon, and credential harvesting
- **[Linux Privilege Escalation](/knowledge/techniques/linux/privilege-escalation.md)** - Complete Linux privesc guide including SUID/SGID, sudo abuse, capabilities, cron exploitation, kernel exploits (DirtyPipe, DirtyCow, PwnKit), container escapes, and more

## Windows Privilege Escalation

### Service Misconfigurations

**Unquoted Service Paths:**
```cmd
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows"
```

**Weak Service Permissions:**
```cmd
# Check service permissions with accesschk
accesschk.exe /accepteula -uwcqv "Authenticated Users" *
accesschk.exe /accepteula -uwcqv %USERNAME% *

# Modify vulnerable service
sc config [service] binpath= "C:\path\to\payload.exe"
sc stop [service]
sc start [service]
```

**Insecure Service Executables:**
```cmd
# Check file permissions on service binaries
icacls "C:\Program Files\Service\binary.exe"
```

### UAC Bypass

```powershell
# Check UAC level
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System

# Common bypass methods
# - fodhelper.exe bypass
# - eventvwr.exe bypass
# - sdclt.exe bypass
```

### Token Impersonation

```powershell
# Check current privileges
whoami /priv

# Key privileges for impersonation:
# - SeImpersonatePrivilege
# - SeAssignPrimaryTokenPrivilege
# - SeDebugPrivilege
```

**Potato Attacks** (when SeImpersonatePrivilege is enabled):
- JuicyPotato, RoguePotato, SweetPotato, PrintSpoofer, GodPotato

### Other Windows Vectors

- **AlwaysInstallElevated**: MSI packages install with SYSTEM privileges
- **Stored Credentials**: `cmdkey /list`, credential manager
- **Scheduled Tasks**: Writable task binaries or scripts
- **DLL Hijacking**: Missing DLLs in writable paths
- **Registry Autoruns**: Writable autorun entries

## Linux Privilege Escalation

### SUID/SGID Binaries

```bash
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Find SGID binaries
find / -perm -2000 -type f 2>/dev/null

# Check GTFOBins for exploitation methods
```

### Sudo Misconfigurations

```bash
# Check sudo permissions
sudo -l

# Common exploitable entries:
# - (ALL) NOPASSWD: /usr/bin/vim
# - (ALL) NOPASSWD: /usr/bin/python*
# - (root) NOPASSWD: /usr/bin/find
```

### Kernel Exploits

```bash
# Check kernel version
uname -a
cat /proc/version

# Notable exploits:
# - DirtyCow (CVE-2016-5195)
# - DirtyPipe (CVE-2022-0847)
# - PwnKit (CVE-2021-4034)
```

### Linux Capabilities

```bash
# Find binaries with capabilities
getcap -r / 2>/dev/null

# Dangerous capabilities:
# - cap_setuid+ep (python, perl, etc.)
# - cap_dac_override+ep
# - cap_net_bind_service+ep
```

### Other Linux Vectors

- **Writable /etc/passwd**: Add user with root UID
- **Cron Jobs**: Writable scripts or PATH hijacking
- **NFS no_root_squash**: Mount and create SUID binary
- **Writable PATH directories**: Binary hijacking
- **Docker/LXC Group**: Container escape to root

## Enumeration Methodology

1. **User Context**: Current user, groups, privileges
2. **System Info**: OS version, kernel, architecture
3. **Running Processes**: Services running as root/SYSTEM
4. **Network**: Internal services, port forwarding opportunities
5. **Credentials**: Config files, history, cached credentials
6. **Scheduled Jobs**: Cron, scheduled tasks
7. **Installed Software**: Vulnerable versions
8. **File Permissions**: Writable sensitive files/directories

## Tool Recommendations

| Tool | Platform | Purpose |
|------|----------|---------|
| LinPEAS | Linux | Comprehensive enumeration |
| WinPEAS | Windows | Comprehensive enumeration |
| linEnum | Linux | System enumeration |
| PowerUp | Windows | PowerShell privesc checks |
| BeRoot | Both | Misconfiguration detection |
| PEASS-ng | Both | Privilege escalation suite |
| pspy | Linux | Process monitoring without root |
| Seatbelt | Windows | Security-focused enumeration |

## Quick Reference

```bash
# Linux quick wins
sudo -l                              # Check sudo permissions
find / -perm -4000 2>/dev/null       # Find SUID binaries
cat /etc/crontab                     # Check cron jobs
ls -la /etc/passwd /etc/shadow       # Check file permissions
```

```cmd
# Windows quick wins
whoami /all                          # User info and privileges
systeminfo                           # System information
wmic service list brief              # List services
schtasks /query /fo LIST /v          # Scheduled tasks
```
