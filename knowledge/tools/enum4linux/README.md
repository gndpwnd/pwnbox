---
title: "enum4linux"
category: "tool"
subcategory: "enumeration"
tags: ["smb", "windows", "samba", "enumeration", "active-directory"]
last_updated: "2025-12-27"
---

# enum4linux

> A Linux tool for enumerating information from Windows and Samba hosts via SMB.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Options](#key-options)
- [Enumeration Modules](#enumeration-modules)
- [Common Use Cases](#common-use-cases)
- [Documentation Files](#documentation-files)

## Overview

enum4linux is a tool for enumerating information from Windows and Samba systems. It is written in Perl and wraps the Samba tools (smbclient, rpcclient, net, nmblookup) to extract:

- User and group listings
- Share enumeration
- Password policy information
- OS information
- RID cycling for user enumeration

Originally based on enum.exe functionality from BindView.

## Installation

```bash
# Debian/Ubuntu/Kali (pre-installed on Kali)
sudo apt install enum4linux

# Clone from source
git clone https://github.com/CiscoCXSecurity/enum4linux.git
cd enum4linux
chmod +x enum4linux.pl

# Dependencies
sudo apt install smbclient rpcclient ldap-utils
```

## Quick Start

```bash
# Full enumeration (all modules)
enum4linux -a 10.10.10.1

# Basic enumeration with verbose output
enum4linux -v 10.10.10.1

# Enumerate with credentials
enum4linux -u 'username' -p 'password' 10.10.10.1

# Share enumeration only
enum4linux -S 10.10.10.1

# User enumeration via RID cycling
enum4linux -r 10.10.10.1

# Enumerate users and groups
enum4linux -U -G 10.10.10.1
```

## Key Options

| Option | Description |
|--------|-------------|
| `-a` | Do all simple enumeration (equivalent to -U -S -G -P -r -o -n -i) |
| `-U` | Get user list |
| `-G` | Get group list and membership |
| `-S` | Get share list |
| `-P` | Get password policy information |
| `-r` | Enumerate users via RID cycling |
| `-o` | Get OS information |
| `-n` | Do nmblookup (similar to nbtstat) |
| `-i` | Get printer information |
| `-u <user>` | Specify username for authentication |
| `-p <pass>` | Specify password for authentication |
| `-w <domain>` | Specify workgroup/domain |
| `-v` | Verbose mode |
| `-d` | Detailed mode (more verbose) |

## Enumeration Modules

| Module | Flag | Information Retrieved |
|--------|------|----------------------|
| Users | `-U` | Domain/local user accounts |
| Groups | `-G` | Groups and their members |
| Shares | `-S` | Available SMB shares |
| Password Policy | `-P` | Min/max password age, lockout policy |
| RID Cycling | `-r` | Brute-force RIDs to find users |
| OS Info | `-o` | Operating system and version |
| NetBIOS | `-n` | NetBIOS names and MAC address |
| Printers | `-i` | Shared printer information |

## Common Use Cases

```bash
# Initial reconnaissance on Windows target
enum4linux -a -v 10.10.10.1

# Anonymous enumeration (null session)
enum4linux -a -u '' -p '' 10.10.10.1

# Enumerate with domain credentials
enum4linux -a -u 'DOMAIN\user' -p 'password' -w DOMAIN 10.10.10.1

# Custom RID range for user enumeration
enum4linux -r -R 500-600 10.10.10.1

# Quick share check
enum4linux -S 10.10.10.1

# Get password policy (useful before brute-forcing)
enum4linux -P 10.10.10.1
```

## Documentation Files

| File | Description |
|------|-------------|
| [official_docs.md](official_docs.md) | Official GitHub documentation |
