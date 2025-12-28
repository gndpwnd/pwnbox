---
title: Linux Attack Techniques
category: techniques
tags: [linux, privilege-escalation, persistence]
last_updated: 2025-12-27
---

# Linux Attack Techniques

This directory contains documentation for Linux-specific attack techniques used in penetration testing and red team operations.

## Overview

Linux systems are prevalent in enterprise environments, from web servers to containers. Understanding privilege escalation and persistence techniques is critical for security assessments.

## Categories

### SUID/SGID Exploitation

SUID (Set User ID) and SGID (Set Group ID) binaries run with the permissions of their owner, often root.

**Common Techniques:**
- GTFOBins exploitation (nmap, vim, find, etc.)
- Custom SUID binary abuse
- Shared library injection
- Path manipulation attacks
- Race conditions in SUID programs

**Enumeration:**
```bash
find / -perm -4000 -type f 2>/dev/null  # SUID
find / -perm -2000 -type f 2>/dev/null  # SGID
```

### Sudo Exploitation

Sudo misconfigurations are among the most common privilege escalation vectors.

**Common Techniques:**
- Sudo version exploits (CVE-2021-3156 Baron Samedit)
- NOPASSWD entries abuse
- Wildcards in sudo commands
- LD_PRELOAD exploitation
- Sudo token reuse (ptrace)
- env_keep variable abuse

**Enumeration:**
```bash
sudo -l                    # List sudo permissions
sudo -V                    # Check sudo version
cat /etc/sudoers          # View sudoers (if readable)
```

### Capabilities Exploitation

Linux capabilities provide fine-grained privilege control, but can be misconfigured.

**Dangerous Capabilities:**
- `cap_setuid` - Change UID (instant root)
- `cap_setgid` - Change GID
- `cap_net_raw` - Packet sniffing
- `cap_dac_override` - Bypass file permissions
- `cap_sys_admin` - Broad administrative access

**Enumeration:**
```bash
getcap -r / 2>/dev/null
```

### Kernel Exploits

Kernel vulnerabilities provide direct privilege escalation but may cause system instability.

**Notable Exploits:**
- DirtyPipe (CVE-2022-0847)
- DirtyCow (CVE-2016-5195)
- Polkit (CVE-2021-4034 PwnKit)
- Netfilter (various CVEs)
- OverlayFS exploits

**Considerations:**
- Check kernel version: `uname -a`
- Verify exploit compatibility
- Test in isolated environment first
- Have crash recovery plan

## Privilege Escalation Workflow

1. **System Enumeration** - OS version, kernel, users, network
2. **Configuration Review** - SUID, sudo, cron, services
3. **Credential Hunting** - Config files, history, memory
4. **Exploit Selection** - Choose reliable, stable method
5. **Execution** - Run exploit and verify access

## Related Tools

| Tool | Purpose |
|------|---------|
| LinPEAS | Comprehensive Linux enumeration |
| LinEnum | Linux privilege escalation checker |
| linux-exploit-suggester | Kernel exploit suggestions |
| pspy | Process monitoring without root |
| GTFOBins | Unix binary exploitation reference |

## Quick Reference

```bash
# System information
uname -a && cat /etc/*release

# Find writable directories
find / -writable -type d 2>/dev/null

# Check cron jobs
cat /etc/crontab && ls -la /etc/cron.*

# Find config files with credentials
grep -r "password" /etc/ 2>/dev/null
```

## Detailed Guides

- **[Privilege Escalation](privilege-escalation.md)** - Comprehensive Linux privilege escalation techniques including:
  - SUID/SGID binary exploitation with GTFOBins
  - Sudo misconfigurations and sudo -l analysis
  - Linux capabilities abuse
  - Cron job exploitation
  - PATH hijacking
  - NFS no_root_squash exploitation
  - Docker/LXC container escapes
  - Kernel exploits (DirtyPipe, DirtyCow, PwnKit)
  - Writable /etc/passwd and /etc/shadow
  - SSH key theft
  - Wildcard injection attacks

## References

- [GTFOBins](https://gtfobins.github.io/)
- [PayloadsAllTheThings - Linux Privesc](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [HackTricks - Linux Privilege Escalation](https://book.hacktricks.xyz/)
