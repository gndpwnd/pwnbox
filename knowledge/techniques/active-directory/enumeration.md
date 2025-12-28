---
title: Active Directory Enumeration Techniques
category: techniques
subcategory: active-directory
tags: [enumeration, bloodhound, ldap, powerview, reconnaissance]
last_updated: 2025-12-27
---

# Active Directory Enumeration Techniques

## Table of Contents

- [Overview](#overview)
- [BloodHound / SharpHound](#bloodhound--sharphound)
- [LDAP Enumeration](#ldap-enumeration)
- [PowerView](#powerview)
- [AD Explorer](#ad-explorer)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Active Directory enumeration is the first critical step in AD penetration testing. It involves collecting information about users, groups, computers, trusts, ACLs, and other AD objects to identify attack paths and vulnerabilities.

**Key Objectives:**
- Map domain structure and trust relationships
- Identify privileged users and groups
- Discover misconfigured permissions (ACLs)
- Find attack paths to Domain Admin
- Locate Kerberoastable/AS-REP roastable accounts

---

## BloodHound / SharpHound

### Description

BloodHound uses graph theory to reveal hidden attack paths in Active Directory. SharpHound is the data collector component that gathers information from AD and domain-joined systems.

### Tools

| Tool | Platform | Description |
|------|----------|-------------|
| SharpHound.exe | Windows | C# collector, runs on domain-joined systems |
| SharpHound.ps1 | Windows | PowerShell version of collector |
| bloodhound-python | Linux | Python collector for remote enumeration |
| AzureHound | Cross-platform | Azure AD enumeration |

### Collection Commands

```powershell
# SharpHound - Full collection
.\SharpHound.exe -c All

# Stealth mode - DC only (no computer connections)
.\SharpHound.exe -c DCOnly

# Session collection with looping (run for extended coverage)
.\SharpHound.exe -c Session --loop --loopduration 02:00:00

# Specific domain with alternate credentials
.\SharpHound.exe -c All -d target.local --ldapusername user --ldappassword pass

# Collection methods breakdown
.\SharpHound.exe -c Default  # Groups, local admins, sessions, ACLs
.\SharpHound.exe -c ACL      # ACL data for all objects
.\SharpHound.exe -c Trusts   # Domain trust mappings
```

```bash
# bloodhound-python (from Linux)
bloodhound-python -d domain.local -u user -p password -c All -ns DC_IP

# With NTLM hash
bloodhound-python -d domain.local -u user --hashes :NTLM_HASH -c All -ns DC_IP

# Collection types
bloodhound-python -c Group,LocalAdmin,Session,Trusts,ACL
```

### Key Cypher Queries

```cypher
# Shortest path from owned principal to Domain Admins
MATCH p=shortestPath((u {owned:true})-[*1..]->(g:Group {name:"DOMAIN ADMINS@DOMAIN.LOCAL"}))
RETURN p

# Find Kerberoastable users with path to DA
MATCH (u:User {hasspn:true})
MATCH p=shortestPath((u)-[*1..]->(g:Group {name:"DOMAIN ADMINS@DOMAIN.LOCAL"}))
RETURN u.name, p

# Computers where Domain Users have local admin
MATCH (g:Group {name:"DOMAIN USERS@DOMAIN.LOCAL"})-[:AdminTo]->(c:Computer)
RETURN c.name

# Find principals with DCSync rights
MATCH (n)-[:DCSync|AllExtendedRights|GenericAll]->(d:Domain)
RETURN n.name, labels(n)

# Find AS-REP roastable users
MATCH (u:User {dontreqpreauth:true})
RETURN u.name, u.description

# Find unconstrained delegation computers
MATCH (c:Computer {unconstraineddelegation:true})
RETURN c.name
```

---

## LDAP Enumeration

### Description

LDAP (Lightweight Directory Access Protocol) provides direct access to Active Directory data. It can be queried anonymously in some environments or with valid credentials.

### Tools

| Tool | Description |
|------|-------------|
| ldapsearch | Command-line LDAP client |
| ldapdomaindump | Python tool for comprehensive AD dumps |
| ldeep | In-depth LDAP enumeration utility |
| windapsearch | Python LDAP enumeration for Windows domains |

### Common LDAP Queries

```bash
# Test anonymous bind
ldapsearch -x -H ldap://DC_IP -b "dc=domain,dc=local" "(objectClass=*)"

# Enumerate all users
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "dc=domain,dc=local" "(objectClass=user)" sAMAccountName description

# Find Domain Admins
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "dc=domain,dc=local" "(&(objectClass=group)(cn=Domain Admins))" member

# Find Kerberoastable accounts (users with SPNs)
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "dc=domain,dc=local" \
  "(&(objectClass=user)(servicePrincipalName=*)(!(cn=krbtgt))(!(samaccounttype=805306369)))" \
  sAMAccountName servicePrincipalName

# Find AS-REP Roastable accounts (no preauth required)
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "dc=domain,dc=local" \
  "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))" \
  sAMAccountName

# Find Domain Controllers
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "dc=domain,dc=local" \
  "(userAccountControl:1.2.840.113556.1.4.803:=8192)" \
  cn dNSHostName

# Enumerate computers
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "dc=domain,dc=local" \
  "(objectClass=computer)" cn operatingSystem operatingSystemVersion

# Find users with AdminCount=1 (protected by AdminSDHolder)
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "dc=domain,dc=local" \
  "(&(objectClass=user)(adminCount=1))" sAMAccountName
```

### ldapdomaindump

```bash
# Full domain dump to HTML/JSON/grep files
ldapdomaindump -u 'domain\user' -p 'password' DC_IP -o output_dir

# Over LDAPS
ldapdomaindump -u 'domain\user' -p 'password' ldaps://DC_IP:636 -o output_dir
```

### ldeep

```bash
# Comprehensive enumeration
ldeep ldap -u user -p password -d domain.local -s DC_IP all output_dir

# Specific queries
ldeep ldap -u user -p password -d domain.local -s DC_IP users
ldeep ldap -u user -p password -d domain.local -s DC_IP computers
ldeep ldap -u user -p password -d domain.local -s DC_IP trusts
ldeep ldap -u user -p password -d domain.local -s DC_IP delegations
ldeep ldap -u user -p password -d domain.local -s DC_IP gpos
```

---

## PowerView

### Description

PowerView is a PowerShell tool for Active Directory enumeration and exploitation, part of the PowerSploit framework. It provides extensive functionality for domain reconnaissance.

### Setup

```powershell
# Import PowerView
Import-Module .\PowerView.ps1

# Bypass AMSI if needed
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

# Get all commands
Get-Command -Module PowerView
```

### Domain Enumeration

```powershell
# Basic domain information
Get-Domain
Get-DomainController
Get-Forest
Get-ForestDomain
Get-DomainTrust

# Domain policy
Get-DomainPolicy
(Get-DomainPolicy)."SystemAccess"
```

### User Enumeration

```powershell
# All users with key attributes
Get-DomainUser | select samaccountname, description, pwdlastset, logoncount, badpwdcount

# Specific user details
Get-DomainUser -Identity administrator -Properties *

# Users with SPN (Kerberoastable)
Get-DomainUser -SPN | select samaccountname, serviceprincipalname

# AS-REP Roastable users
Get-DomainUser -PreauthNotRequired | select samaccountname

# Users with AdminCount (privileged)
Get-DomainUser -AdminCount | select samaccountname

# Users with SID History
Get-DomainUser -LDAPFilter '(sidHistory=*)' | select samaccountname
```

### Group Enumeration

```powershell
# All groups
Get-DomainGroup | select samaccountname, admincount, description

# Domain Admins members
Get-DomainGroupMember -Identity "Domain Admins" -Recurse

# Enterprise Admins members
Get-DomainGroupMember -Identity "Enterprise Admins" -Recurse

# Groups a user belongs to
Get-DomainGroup -UserName "targetuser" | select samaccountname
```

### Computer Enumeration

```powershell
# All computers
Get-DomainComputer | select samaccountname, operatingsystem

# Find DCs
Get-DomainController | select Name, IPAddress

# Unconstrained delegation
Get-DomainComputer -Unconstrained | select samaccountname

# Constrained delegation
Get-DomainComputer -TrustedToAuth | select samaccountname, msds-allowedtodelegateto

# LAPS enabled computers
Get-DomainComputer -LDAPFilter '(ms-mcs-admpwdexpirationtime=*)' | select samaccountname
```

### ACL Enumeration

```powershell
# Find interesting ACLs
Find-InterestingDomainAcl -ResolveGUIDs

# ACLs on specific object
Get-DomainObjectAcl -Identity "Domain Admins" -ResolveGUIDs

# Find objects where user has GenericAll
Get-DomainObjectAcl -ResolveGUIDs | ? {$_.ActiveDirectoryRights -like "*GenericAll*" -and $_.SecurityIdentifier -match "S-1-5-21-.*-1234"}

# Find WriteDACL permissions
Get-DomainObjectAcl -ResolveGUIDs | ? {$_.ActiveDirectoryRights -like "*WriteDacl*"}

# AdminSDHolder ACL
Get-DomainObjectAcl -SearchBase 'CN=AdminSDHolder,CN=System,DC=DOMAIN,DC=LOCAL' -ResolveGUIDs
```

### GPO Enumeration

```powershell
# All GPOs
Get-DomainGPO | select displayname, gpcfilesyspath

# GPOs applied to computer
Get-DomainGPO -ComputerIdentity ws01.domain.local

# GPOs that modify local groups
Get-DomainGPOLocalGroup

# Find GPO permissions
Get-DomainGPO | Get-DomainObjectAcl -ResolveGUIDs | ? {$_.ActiveDirectoryRights -like "*Write*"}
```

### Session/Logon Hunting

```powershell
# Find where users are logged in
Find-DomainUserLocation

# Find local admin access
Find-LocalAdminAccess

# Test admin access on specific computer
Test-AdminAccess -ComputerName target.domain.local

# Sessions on computer
Get-NetSession -ComputerName target.domain.local

# Logged on users
Get-NetLoggedon -ComputerName target.domain.local
```

---

## AD Explorer

### Description

AD Explorer (Sysinternals) is a GUI tool for viewing and editing Active Directory. Useful for interactive exploration and taking snapshots.

### Features

- Browse AD structure visually
- Search across all attributes
- Take snapshots for offline analysis
- Compare snapshots to detect changes
- Edit object attributes (with permissions)

### Usage

1. Download from [Sysinternals](https://docs.microsoft.com/en-us/sysinternals/downloads/adexplorer)
2. Connect to domain controller
3. Browse the directory tree
4. Use Search feature for specific queries
5. Take snapshots: File > Create Snapshot

### Snapshot Analysis

```powershell
# Take snapshot (via command line)
.\ADExplorer.exe -snapshot "" snapshot.dat

# Compare with ADExplorerSnapshot.py
python3 ADExplorerSnapshot.py snapshot.dat -o output
```

---

## Detection and Defense

### Detection Methods

| Technique | Detection |
|-----------|-----------|
| BloodHound/SharpHound | Monitor for high volume LDAP queries, unusual SPN enumeration |
| LDAP Queries | Event ID 1644 (LDAP query logging), unusual query patterns |
| PowerView | Script block logging, AMSI detections, unusual PowerShell activity |
| Session Enumeration | Event ID 4624 Type 3 from unusual sources |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 1644 | LDAP query (requires registry modification to enable) |
| 4662 | Operation on directory object |
| 4768 | TGT request (Kerberos) |
| 4769 | TGS request (Kerberos) |

### Defensive Measures

1. **Limit Query Access**: Restrict LDAP queries for sensitive attributes
2. **Tiered Administration**: Separate admin accounts for different tiers
3. **Protected Users Group**: Add privileged accounts to Protected Users
4. **Monitor BloodHound Collectors**: Alert on SharpHound, bloodhound-python activity
5. **Audit ACLs Regularly**: Use BloodHound defensively to find attack paths
6. **Restrict Anonymous LDAP**: Disable anonymous bind on domain controllers

---

## References

- [BloodHound CE Documentation](https://bloodhound.specterops.io/)
- [PowerView Documentation](https://powersploit.readthedocs.io/en/latest/Recon/)
- [LDAP Queries - Polito Inc](https://www.politoinc.com/post/ldap-queries-for-offensive-and-defensive-operations)
- [Route Zero - Advanced LDAP Enumeration](https://routezero.security/2024/12/15/advanced-ldap-enumeration-techniques-for-pentesters/)
- [ired.team - PowerView](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/active-directory-enumeration-with-powerview)
