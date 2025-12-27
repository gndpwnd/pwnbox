---
title: "smbmap"
category: "tool"
subcategory: "enumeration"
tags: ["smb", "share-enumeration", "windows", "file-transfer", "pass-the-hash"]
last_updated: "2025-12-27"
---

# smbmap

> SMB share enumeration tool for discovering and interacting with Windows shares across networks.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Options](#key-options)
- [Common Use Cases](#common-use-cases)
- [Documentation Files](#documentation-files)

## Overview

SMBMap allows users to enumerate Samba share drives across an entire domain. It supports listing share drives, checking permissions, browsing share contents, uploading/downloading files, and executing remote commands. Features include pass-the-hash support, Kerberos authentication, and SMB signing detection.

## Installation

```bash
# Via pip (recommended)
sudo pip3 install smbmap

# Kali Linux
sudo apt install smbmap
```

## Quick Start

```bash
# List shares with credentials
smbmap -H 192.168.1.10 -u admin -p password

# Null session (anonymous)
smbmap -H 192.168.1.10

# Pass-the-hash authentication
smbmap -H 192.168.1.10 -u admin -p 'aad3b435b51404ee:da76f2c4c96028b7a6111aef4a50a94d'

# List directory contents
smbmap -H 192.168.1.10 -u admin -p password -r 'C$'

# Recursive listing with depth
smbmap -H 192.168.1.10 -u admin -p password -r 'C$\Users' --depth 2

# Download a file
smbmap -H 192.168.1.10 -u admin -p password --download 'C$\temp\passwords.txt'

# Upload a file
smbmap -H 192.168.1.10 -u admin -p password --upload /tmp/shell.exe 'C$\temp\shell.exe'

# Execute command
smbmap -H 192.168.1.10 -u admin -p password -x 'whoami'
```

## Key Options

| Option | Description |
|--------|-------------|
| `-H HOST` | Target IP or hostname |
| `--host-file FILE` | File containing list of hosts |
| `-u USERNAME` | Username (omit for null session) |
| `-p PASSWORD` | Password or NTLM hash (LMHASH:NTHASH) |
| `-d DOMAIN` | Domain name (default: WORKGROUP) |
| `-P PORT` | SMB port (default: 445) |
| `-r [PATH]` | Recursively list directory contents |
| `--depth N` | Directory traversal depth (default: 1) |
| `-x COMMAND` | Execute a command on the host |
| `-L` | List all drives (requires admin) |
| `--download PATH` | Download a file from remote system |
| `--upload SRC DST` | Upload a file to remote system |
| `-k, --kerberos` | Use Kerberos authentication |
| `--signing` | Check SMB signing status |
| `-v, --version` | Return OS version of remote host |
| `-q` | Quiet mode, only show accessible shares |
| `--no-banner` | Suppress banner output |
| `-A PATTERN` | Auto-download files matching regex pattern |
| `-F PATTERN` | Search file contents for pattern |

## Common Use Cases

```bash
# Check SMB signing across network
smbmap --host-file targets.txt --signing

# Get OS versions
smbmap --host-file targets.txt -v

# Find writable shares only
smbmap -H 192.168.1.10 -u admin -p password -q

# Search for sensitive files and auto-download
smbmap -H 192.168.1.10 -u admin -p password -r 'C$' --depth 3 -A '(password|config|credential)'

# Content search for passwords (requires admin + PowerShell)
smbmap -H 192.168.1.10 -u admin -p password -F '[Pp]assword' --search-path 'C:\Users'

# Kerberos authentication
export KRB5CCNAME='~/current.ccache'
smbmap -H dc01.domain.local -k --no-pass
```

## Documentation Files

| File | Description |
|------|-------------|
| [options.md](options.md) | Complete command-line options reference |
| [official_docs.md](official_docs.md) | Official documentation from GitHub |
