---
title: "smbclient"
category: tool
subcategory: enumeration
tags: ["smb", "cifs", "windows", "file-transfer", "samba", "shares"]
last_updated: 2025-12-27
---

# smbclient

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Commands](#key-commands)
- [Common Scenarios](#common-scenarios)
- [Documentation](#documentation)

## Overview

smbclient is a command-line SMB/CIFS client from the Samba suite that provides FTP-like access to Windows file shares. It enables enumeration of shares, file transfers, and interaction with SMB servers during penetration testing. SMB operates on TCP ports 139 and 445.

## Installation

```bash
# Debian/Ubuntu (pre-installed on Kali)
sudo apt install smbclient

# Verify installation
smbclient --version
```

## Quick Start

### Connecting to Shares

```bash
# List shares anonymously (null session)
smbclient -L //192.168.1.100 -N

# List shares with credentials
smbclient -L //192.168.1.100 -U user%password

# Connect to a share
smbclient //192.168.1.100/share -U user%password

# Connect with domain credentials
smbclient //192.168.1.100/share -U domain/user%password -W WORKGROUP
```

### Listing and Navigation

```bash
# Interactive session
smbclient //192.168.1.100/share -U user%pass
smb: \> ls                    # List files
smb: \> cd Documents          # Change directory
smb: \> pwd                   # Print working directory
```

### File Operations

```bash
# Download a file
smb: \> get secret.txt

# Upload a file
smb: \> put payload.exe

# Recursive download (one-liner)
smbclient //192.168.1.100/share -U user%pass -c 'recurse ON; prompt OFF; mget *'

# Non-interactive command execution
smbclient //192.168.1.100/share -U user%pass -c 'ls; get config.txt'
```

## Key Commands

| Command | Description |
|---------|-------------|
| `ls` | List directory contents |
| `cd <dir>` | Change directory |
| `get <file>` | Download file |
| `put <file>` | Upload file |
| `mget <pattern>` | Download multiple files |
| `mput <pattern>` | Upload multiple files |
| `mkdir <dir>` | Create directory |
| `rm <file>` | Delete file |
| `recurse` | Toggle recursive operations |
| `prompt` | Toggle confirmation prompts |
| `exit` | Close connection |

## Common Scenarios

### Access Administrative Shares

```bash
# C$ share (requires admin)
smbclient //192.168.1.100/C$ -U administrator%Password123

# ADMIN$ share
smbclient //192.168.1.100/ADMIN$ -U administrator%Password123
```

### Download Specific File Types

```bash
smbclient //192.168.1.100/share -U user%pass
smb: \> recurse ON
smb: \> prompt OFF
smb: \> mget *.docx
smb: \> mget *.xlsx
```

### Create Tar Backup

```bash
# Backup entire share
smbclient //192.168.1.100/share -U user%pass -Tc backup.tar *

# Restore from backup
smbclient //192.168.1.100/share -U user%pass -Tx backup.tar
```

## Documentation

| File | Description |
|------|-------------|
| [official_docs.md](official_docs.md) | Samba man page with full option reference |

## Related Tools

- **smbmap** - Share enumeration with permissions
- **enum4linux** - Comprehensive SMB enumeration
- **crackmapexec** - Windows/AD pentesting toolkit
- **impacket-smbclient** - Python SMB client
