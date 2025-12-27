# enum4linux - Practical Techniques

## Overview

This document covers practical techniques for using enum4linux to enumerate Windows and Samba hosts via SMB. Each technique includes command examples and interpretation guidance.

## Table of Contents

- [User Enumeration](#user-enumeration)
- [Share Enumeration](#share-enumeration)
- [Password Policy](#password-policy)
- [Group Membership](#group-membership)
- [RID Cycling](#rid-cycling)
- [Combined Techniques](#combined-techniques)
- [Comparison with smbmap](#comparison-with-smbmap)

---

## User Enumeration

### Basic User Listing

Enumerate domain/local users via RPC:

```bash
# Anonymous user enumeration
enum4linux -U 10.10.10.1

# With credentials
enum4linux -U -u 'username' -p 'password' 10.10.10.1

# With domain specified
enum4linux -U -u 'DOMAIN\username' -p 'password' -w DOMAIN 10.10.10.1
```

**Expected Output:**
```
 =============================
|    Users on 10.10.10.1    |
 =============================
user:[Administrator] rid:[0x1f4]
user:[Guest] rid:[0x1f5]
user:[krbtgt] rid:[0x1f6]
user:[svc_backup] rid:[0x451]
user:[jsmith] rid:[0x452]
```

### Interpreting Results

- **RID values**: Relative Identifier - unique to each user in the domain
  - `0x1f4` (500) = Administrator
  - `0x1f5` (501) = Guest
  - `0x1f6` (502) = krbtgt (Kerberos service account)
  - RIDs >= 1000 are typically regular user accounts

### Common Issues

| Issue | Solution |
|-------|----------|
| No users returned | Try RID cycling (-r) or authenticate with credentials |
| Access denied | Target may require authentication; try null session first |
| Connection refused | Check if SMB port (445/139) is open |

---

## Share Enumeration

### Basic Share Discovery

```bash
# Anonymous share enumeration
enum4linux -S 10.10.10.1

# With credentials
enum4linux -S -u 'username' -p 'password' 10.10.10.1

# Verbose output with share details
enum4linux -S -v 10.10.10.1
```

**Expected Output:**
```
 ==========================================
|    Share Enumeration on 10.10.10.1    |
 ==========================================

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share
        SYSVOL          Disk      Logon server share
        Backups         Disk      Backup share
        Users           Disk      User directories

[+] Attempting to map shares on 10.10.10.1
//10.10.10.1/ADMIN$     Mapping: DENIED, Listing: N/A
//10.10.10.1/C$         Mapping: DENIED, Listing: N/A
//10.10.10.1/IPC$       Mapping: OK, Listing: DENIED
//10.10.10.1/Backups    Mapping: OK, Listing: OK
//10.10.10.1/Users      Mapping: OK, Listing: OK
```

### Understanding Share Types

| Share Type | Description | Typical Access |
|------------|-------------|----------------|
| `ADMIN$` | Windows admin share | Admin only |
| `C$` | Default C: drive share | Admin only |
| `IPC$` | Inter-Process Communication | Often allows null session |
| `NETLOGON` | Domain logon scripts | Domain users |
| `SYSVOL` | Group Policy files | Domain users |
| Custom shares | User-created shares | Variable |

### Actionable Results

- **Mapping: OK, Listing: OK** = Full access, browse contents
- **Mapping: OK, Listing: DENIED** = Can connect but cannot list
- **Mapping: DENIED** = Cannot access share

---

## Password Policy

### Retrieving Password Policy

Understanding password policy helps with:
- Planning brute-force/spray attacks
- Identifying lockout thresholds
- Understanding password complexity requirements

```bash
# Get password policy
enum4linux -P 10.10.10.1

# With credentials for more detailed info
enum4linux -P -u 'username' -p 'password' 10.10.10.1
```

**Expected Output:**
```
 ==================================================
|    Password Policy Information for 10.10.10.1 |
 ==================================================

[+] Attaching to 10.10.10.1 using a NULL share

[+] Trying protocol 139/SMB...

[+] Password Info for Domain: DOMAIN

        [+] Minimum password length: 7
        [+] Password history length: 24
        [+] Maximum password age: 42 days
        [+] Password Complexity Flags: 000001

                [+] Domain Refuse Password Change: 0
                [+] Domain Password Store Cleartext: 0
                [+] Domain Password Lockout Admins: 0
                [+] Domain Password No Clear Change: 0
                [+] Domain Password No Anon Change: 0
                [+] Domain Password Complex: 1

        [+] Minimum password age: 1 day
        [+] Reset Account Lockout Counter: 30 minutes
        [+] Locked Account Duration: 30 minutes
        [+] Account Lockout Threshold: 5
        [+] Forced Logoff Time: Not Set
```

### Key Policy Interpretation

| Field | Importance | Notes |
|-------|------------|-------|
| Minimum password length | High | Shorter = easier to crack |
| Account Lockout Threshold | Critical | Number of failed attempts before lockout |
| Reset Account Lockout Counter | High | Time until bad password count resets |
| Password Complexity | Medium | If disabled, simpler passwords allowed |

### Pre-Attack Planning

```bash
# Check policy before password spraying
enum4linux -P 10.10.10.1

# If lockout threshold is 5 and reset is 30 minutes:
# - Try maximum 3 passwords per account
# - Wait 30+ minutes between spray attempts
```

---

## Group Membership

### Enumerating Groups

```bash
# Get groups and members
enum4linux -G 10.10.10.1

# With credentials
enum4linux -G -u 'username' -p 'password' 10.10.10.1

# Combined user and group enumeration
enum4linux -U -G 10.10.10.1
```

**Expected Output:**
```
 ==============================
|    Groups on 10.10.10.1    |
 ==============================

[+] Getting domain groups:
group:[Domain Admins] rid:[0x200]
group:[Domain Users] rid:[0x201]
group:[Domain Guests] rid:[0x202]
group:[Domain Computers] rid:[0x203]
group:[IT Admins] rid:[0x44f]
group:[Backup Operators] rid:[0x450]

[+] Getting domain group memberships:
Group 'Domain Admins' (RID: 512) has members:
        DOMAIN\Administrator
        DOMAIN\jsmith

Group 'IT Admins' (RID: 1103) has members:
        DOMAIN\helpdesk
        DOMAIN\sysadmin
```

### High-Value Groups to Target

| Group | RID | Why It Matters |
|-------|-----|----------------|
| Domain Admins | 512 | Full domain control |
| Enterprise Admins | 519 | Forest-level control |
| Administrators | 544 | Local admin rights |
| Backup Operators | 551 | Can backup/restore files |
| Account Operators | 548 | Can manage accounts |
| Server Operators | 549 | Server management rights |

### Finding Privilege Escalation Paths

```bash
# Look for interesting group memberships
enum4linux -G -v 10.10.10.1 | grep -i "admin\|backup\|operator"
```

---

## RID Cycling

### Overview

RID cycling brute-forces Relative Identifiers (RIDs) to discover users and groups that may not be returned by standard enumeration. This is especially useful when:
- Anonymous enumeration returns no users
- You suspect hidden/disabled accounts
- Standard user enumeration is blocked

### Basic RID Cycling

```bash
# Default RID range (500-550, 1000-1050)
enum4linux -r 10.10.10.1

# Custom RID range
enum4linux -r -R 500-600 10.10.10.1

# Extended range for larger domains
enum4linux -r -R 500-2000 10.10.10.1

# With credentials for better results
enum4linux -r -R 500-5000 -u 'username' -p 'password' 10.10.10.1
```

**Expected Output:**
```
 ==============================================
|    Users on 10.10.10.1 via RID cycling    |
 ==============================================
[I] Found new SID: S-1-5-21-3842939050-3880317879-2865463114
[+] Enumerating users using SID S-1-5-21-3842939050-3880317879-2865463114 and logon username '', password ''
S-1-5-21-3842939050-3880317879-2865463114-500 DOMAIN\Administrator (Local User)
S-1-5-21-3842939050-3880317879-2865463114-501 DOMAIN\Guest (Local User)
S-1-5-21-3842939050-3880317879-2865463114-502 DOMAIN\krbtgt (Local User)
S-1-5-21-3842939050-3880317879-2865463114-1103 DOMAIN\svc_backup (Local User)
S-1-5-21-3842939050-3880317879-2865463114-1104 DOMAIN\svc_sql (Local User)
S-1-5-21-3842939050-3880317879-2865463114-1105 DOMAIN\hidden_admin (Local User)
```

### RID Range Strategy

| RID Range | Contents |
|-----------|----------|
| 500-502 | Built-in accounts (Administrator, Guest, krbtgt) |
| 512-519 | Built-in groups (Domain Admins, etc.) |
| 544-552 | Local built-in groups |
| 1000+ | Custom users and groups |
| 1100-1200 | Service accounts (common range) |

### Combining with Wordlists

```bash
# RID cycle + save output for further enumeration
enum4linux -r -R 500-10000 10.10.10.1 | grep "Local User" | awk -F'\' '{print $2}' | cut -d' ' -f1 > users.txt

# Use discovered users for password spraying
```

---

## Combined Techniques

### Full Enumeration Workflow

```bash
# Step 1: Full anonymous enumeration
enum4linux -a 10.10.10.1

# Step 2: If you get credentials, re-enumerate
enum4linux -a -u 'discovered_user' -p 'password' 10.10.10.1

# Step 3: Extended RID cycling with credentials
enum4linux -r -R 500-10000 -u 'user' -p 'pass' 10.10.10.1
```

### Output to File for Analysis

```bash
# Full enumeration with detailed output
enum4linux -a -v -d 10.10.10.1 2>&1 | tee enum4linux_output.txt

# Extract just usernames
grep "^user:" enum4linux_output.txt | cut -d'[' -f2 | cut -d']' -f1 > users.txt

# Extract just shares with access
grep "Mapping: OK" enum4linux_output.txt
```

### Quick Reconnaissance Script

```bash
#!/bin/bash
TARGET=$1

echo "[*] Starting enum4linux reconnaissance on $TARGET"

echo "[+] Getting OS info..."
enum4linux -o $TARGET

echo "[+] Enumerating shares..."
enum4linux -S $TARGET

echo "[+] Getting password policy..."
enum4linux -P $TARGET

echo "[+] Attempting user enumeration..."
enum4linux -U $TARGET

echo "[+] RID cycling for additional users..."
enum4linux -r -R 500-3000 $TARGET

echo "[*] Enumeration complete"
```

---

## Comparison with smbmap

### When to Use enum4linux

| Scenario | Tool Preference |
|----------|-----------------|
| Initial domain reconnaissance | enum4linux |
| Getting password policy | enum4linux |
| RID cycling for user discovery | enum4linux |
| NetBIOS/NBNS information | enum4linux |
| Group membership enumeration | enum4linux |

### When to Use smbmap

| Scenario | Tool Preference |
|----------|-----------------|
| Listing share permissions | smbmap |
| Downloading/uploading files | smbmap |
| Recursive directory listing | smbmap |
| Command execution | smbmap |
| Pass-the-hash authentication | smbmap |
| Scanning multiple hosts | smbmap |

### Complementary Usage

```bash
# Use enum4linux for initial recon
enum4linux -a 10.10.10.1

# Use smbmap to interact with discovered shares
smbmap -H 10.10.10.1 -r 'Backups'
smbmap -H 10.10.10.1 --download 'Backups\credentials.txt'
```

### Feature Comparison

| Feature | enum4linux | smbmap |
|---------|------------|--------|
| User enumeration | Yes | No |
| Group enumeration | Yes | No |
| Password policy | Yes | No |
| RID cycling | Yes | No |
| Share listing | Basic | Detailed |
| Permission mapping | Basic | Advanced |
| File download | No | Yes |
| File upload | No | Yes |
| Command execution | No | Yes |
| Multi-host scanning | No | Yes |
| Pass-the-hash | Limited | Full |
| Kerberos auth | No | Yes |

---

## Troubleshooting

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Could not initialise samr` | Access denied to SAM | Try with credentials |
| `NT_STATUS_ACCESS_DENIED` | Insufficient permissions | Use valid credentials |
| `NT_STATUS_LOGON_FAILURE` | Wrong credentials | Verify username/password |
| `Could not negotiate protocol` | SMB version mismatch | Check SMB settings |
| `Connection refused` | Port closed or firewall | Verify 445/139 is open |

### Improving Results

1. **Try null session explicitly:**
   ```bash
   enum4linux -a -u '' -p '' 10.10.10.1
   ```

2. **Use alternative ports:**
   ```bash
   # Default uses 445, older systems may need 139
   enum4linux -a 10.10.10.1  # Will try both
   ```

3. **Increase verbosity for debugging:**
   ```bash
   enum4linux -a -v -d 10.10.10.1
   ```
