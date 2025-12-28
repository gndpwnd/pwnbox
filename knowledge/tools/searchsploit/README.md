---
title: "searchsploit"
category: "tool"
subcategory: "exploitation"
tags:
  - exploit-database
  - vulnerability-research
  - exploitation
sources:
  - https://www.exploit-db.com/searchsploit
  - https://gitlab.com/exploit-database/exploitdb
  - https://github.com/offensive-security/exploitdb
last_updated: "2025-12-27"
---

# searchsploit

> Command-line search tool for Exploit-DB - the world's largest archive of public exploits and vulnerable software.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Database Updates](#database-updates)
- [Quick Start](#quick-start)
- [Common Options](#common-options)
- [Output Formats](#output-formats)
- [Documentation Files](#documentation-files)
- [Related Tools](#related-tools)

## Overview

Searchsploit is a command-line utility for searching the local copy of Exploit-DB. It enables offline exploit research, making it essential for penetration testing in restricted environments. The database contains:

- **Exploits**: Remote, local, web application, DOS, and shellcode
- **Papers**: Security research and whitepapers
- **Proof-of-Concepts**: Working exploit code for disclosed vulnerabilities

## Installation

```bash
# Kali Linux (pre-installed)
searchsploit --help

# Debian/Ubuntu
sudo apt install exploitdb

# Arch Linux
sudo pacman -S exploitdb

# Manual installation
git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb
ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

# macOS
brew install exploitdb
```

### Configuration

```bash
# Config file location
~/.searchsploit_rc

# Default paths (Kali)
/usr/share/exploitdb/          # Database root
/usr/share/exploitdb/exploits/ # Exploit files
/usr/share/exploitdb/shellcodes/ # Shellcode files
/usr/share/exploitdb/papers/   # Papers and docs
```

## Database Updates

```bash
# Update exploit database (recommended before assessments)
searchsploit -u
searchsploit --update

# Check database stats
searchsploit --stats

# Verify installation
searchsploit -h
```

## Quick Start

```bash
# Basic search (searches title and path)
searchsploit apache 2.4

# Search for specific service version
searchsploit openssh 7.2

# Search for Windows privilege escalation
searchsploit windows privilege escalation

# Search for web application exploits
searchsploit wordpress plugin

# View full path to exploit
searchsploit -p 42966

# Copy exploit to current directory
searchsploit -m 42966

# Examine exploit contents
searchsploit -x 42966

# Search with exact match
searchsploit -e "Apache 2.4.49"
```

## Common Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-c` | `--case` | Case-sensitive search |
| `-e` | `--exact` | Exact match (disables fuzzy matching) |
| `-j` | `--json` | Output in JSON format |
| `-m` | `--mirror` | Copy exploit to current directory |
| `-o` | `--overflow` | Exploit titles can overflow columns |
| `-p` | `--path` | Show full path to exploit |
| `-t` | `--title` | Search only in exploit titles |
| `-u` | `--update` | Update the exploit database |
| `-w` | `--www` | Show Exploit-DB URL instead of path |
| `-x` | `--examine` | Examine exploit with default pager |
| `--exclude` | | Exclude specific terms from search |
| `--id` | | Display EDB-ID instead of path |
| `--nmap` | | Parse nmap XML output for exploits |
| `--colour` | | Enable/disable color output |

### Filtering Options

| Option | Description |
|--------|-------------|
| `--type=<type>` | Filter by exploit type (dos, local, remote, webapps, shellcode) |
| `--platform=<platform>` | Filter by platform (linux, windows, multiple, etc.) |

## Output Formats

### Default Output

```bash
searchsploit vsftpd
```
```
--------------------------------------------- ---------------------------------
 Exploit Title                               |  Path
--------------------------------------------- ---------------------------------
vsftpd 2.3.4 - Backdoor Command Execution    | unix/remote/49757.py
vsftpd 2.3.4 - Backdoor Command Execution    | unix/remote/17491.rb
--------------------------------------------- ---------------------------------
```

### JSON Output

```bash
searchsploit -j vsftpd 2.3.4
```

### Path Output

```bash
searchsploit -p 17491
# Output: /usr/share/exploitdb/exploits/unix/remote/17491.rb
```

### Web URL Output

```bash
searchsploit -w vsftpd 2.3.4
# Shows: https://www.exploit-db.com/exploits/17491
```

## Documentation Files

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Advanced search techniques and exploit usage |

## Related Tools

| Tool | Relationship |
|------|--------------|
| [metasploit-framework](../metasploit-framework/README.md) | Many exploits have MSF modules |
| [nmap](../nmap/README.md) | Identify services to search for |
| [msfvenom](../msfvenom/README.md) | Generate payloads for exploits |

### External Resources

- [Exploit-DB Website](https://www.exploit-db.com/)
- [Exploit-DB GitLab](https://gitlab.com/exploit-database/exploitdb)
- [Google Hacking Database](https://www.exploit-db.com/google-hacking-database)
- [Exploit-DB Papers](https://www.exploit-db.com/papers)