---
title: "smbclient"
category: "enumeration"
tags: ["smb", "windows", "file-transfer", "enumeration", "samba", "shares"]
---

# smbclient

## Overview

smbclient is a command-line SMB/CIFS client that provides FTP-like functionality for accessing Windows file shares from Linux and Unix systems. It is part of the Samba suite and enables security professionals to enumerate shares, transfer files, and interact with SMB servers during penetration testing engagements. SMB (Server Message Block) operates primarily over TCP ports 139 and 445.

## Installation

smbclient is typically pre-installed on Kali Linux. For other Debian/Ubuntu systems:

```bash
# Install smbclient
sudo apt update
sudo apt install smbclient

# Verify installation
smbclient --version
```

## Basic Usage

```bash
# List shares anonymously (null session)
smbclient -L //target_ip -N

# List shares with credentials
smbclient -L //target_ip -U username%password

# Connect to a specific share
smbclient //target_ip/sharename -U username%password

# Connect with null session
smbclient //target_ip/sharename -N

# Execute a single command non-interactively
smbclient //target_ip/sharename -U username%password -c 'ls'
```

## Key Features

### Share Enumeration
- List all available shares on a target system
- Identify accessible network resources and data repositories
- Test for anonymous/null session access

### File Operations
- Download and upload files to/from shares
- Recursive directory operations
- Wildcard support for batch transfers

### Authentication Testing
- Test null sessions (anonymous access)
- Guest access verification
- Credential-based authentication
- Identify misconfigured shares and weak access controls

### Interactive Shell Commands
Once connected to a share, use these FTP-like commands:
- `ls` - List directory contents
- `cd <dir>` - Change directory
- `pwd` - Print working directory
- `get <file>` - Download a file
- `put <file>` - Upload a file
- `mget <pattern>` - Download multiple files
- `mput <pattern>` - Upload multiple files
- `mkdir <dir>` - Create directory
- `rm <file>` - Delete file
- `exit` - Close connection

## Common Use Cases

### Enumerate Shares with Null Session
```bash
# Test for anonymous access vulnerability
smbclient -L //192.168.1.100 -N

# Alternative null session syntax
smbclient -L //192.168.1.100 -U ""
# Press Enter when prompted for password
```

### Connect and Browse a Share
```bash
# Connect with credentials
smbclient //192.168.1.100/Documents -U admin%Password123

# Once connected:
smb: \> ls
smb: \> cd Confidential
smb: \> get sensitive_data.xlsx
```

### Download All Files Recursively
```bash
# Interactive method
smbclient //192.168.1.100/share -U user%pass
smb: \> mask ""
smb: \> recurse ON
smb: \> prompt OFF
smb: \> mget *

# One-liner for scripting
smbclient //192.168.1.100/share -U user%pass -c 'recurse ON; prompt OFF; mget *'
```

### Upload a File to a Share
```bash
# Interactive upload
smbclient //192.168.1.100/share -U user%pass
smb: \> put local_file.txt remote_file.txt

# Non-interactive upload
smbclient //192.168.1.100/share -U user%pass -c 'put /path/to/local_file.txt target_file.txt'
```

### Access Administrative Shares
```bash
# Access C$ administrative share (requires admin credentials)
smbclient //192.168.1.100/C$ -U administrator%Password123

# Access ADMIN$ share
smbclient //192.168.1.100/ADMIN$ -U administrator%Password123
```

### Download Specific File Types
```bash
smbclient //192.168.1.100/share -U user%pass
smb: \> recurse ON
smb: \> prompt OFF
smb: \> mget *.docx
smb: \> mget *.xlsx
smb: \> mget *.pdf
```

## Tips and Best Practices

1. **Always Test Null Sessions First**: Many misconfigured SMB servers allow anonymous access, which can reveal sensitive information without credentials.

2. **Check Multiple Share Types**: Look for hidden shares (ending with $), administrative shares (C$, ADMIN$, IPC$), and custom shares.

3. **Use the -N Flag**: The `-N` flag suppresses password prompts for null session testing.

4. **Combine with Other Tools**: Use smbclient alongside enum4linux, smbmap, and crackmapexec for comprehensive SMB enumeration.

5. **Document Everything**: Keep track of accessible shares, permissions, and sensitive files discovered during assessments.

6. **Be Aware of Logging**: SMB access is typically logged on Windows systems. Know your scope and authorization.

7. **Handle Spaces in Paths**: Use quotes around paths containing spaces:
   ```bash
   smb: \> cd "Program Files"
   ```

8. **Check Workgroup/Domain**: If connection fails, try specifying the workgroup:
   ```bash
   smbclient //target/share -U domain/user%pass -W WORKGROUP
   ```

## Related Tools

- **smbmap** - SMB share enumeration with permission mapping
- **enum4linux** - Comprehensive SMB/Samba enumeration script
- **crackmapexec** - Swiss army knife for pentesting Windows/AD environments
- **impacket-smbclient** - Python-based SMB client from Impacket suite
- **nmap** - Use NSE scripts for SMB enumeration (`smb-enum-shares`, `smb-vuln-*`)
- **rpcclient** - RPC client for Windows enumeration
- **mount.cifs** - Mount SMB shares as local filesystems
