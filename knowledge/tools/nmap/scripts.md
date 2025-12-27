# nmap - NSE Scripts Reference

> Comprehensive guide to Nmap Scripting Engine (NSE) for penetration testing.

## Table of Contents

- [Overview](#overview)
- [Script Categories](#script-categories)
- [Running Scripts](#running-scripts)
- [Discovery and Enumeration Scripts](#discovery-and-enumeration-scripts)
- [Vulnerability Scanning Scripts](#vulnerability-scanning-scripts)
- [Brute Force Scripts](#brute-force-scripts)
- [Default Scripts (-sC)](#default-scripts--sc)
- [Script Arguments](#script-arguments)
- [Writing Custom Scripts](#writing-custom-scripts)
- [Script Combinations for Common Scenarios](#script-combinations-for-common-scenarios)

---

## Overview

The Nmap Scripting Engine (NSE) extends nmap's functionality with over 600 scripts written in Lua. Scripts can perform:

- Service enumeration and discovery
- Vulnerability detection
- Brute force attacks
- Exploitation
- Information gathering

Scripts are located in `/usr/share/nmap/scripts/` on most Linux systems.

---

## Script Categories

| Category | Description | Example Usage |
|----------|-------------|---------------|
| `auth` | Authentication and credential scripts | `--script auth` |
| `broadcast` | Discovery via broadcast packets | `--script broadcast` |
| `brute` | Brute force password attacks | `--script brute` |
| `default` | Safe, useful scripts (same as -sC) | `--script default` or `-sC` |
| `discovery` | Network/service discovery | `--script discovery` |
| `dos` | Denial of service (use carefully!) | `--script dos` |
| `exploit` | Active exploitation scripts | `--script exploit` |
| `external` | Scripts that contact external services | `--script external` |
| `fuzzer` | Fuzzing scripts | `--script fuzzer` |
| `intrusive` | May crash services or be detected | `--script intrusive` |
| `malware` | Detect malware/backdoors | `--script malware` |
| `safe` | Won't crash services | `--script safe` |
| `version` | Enhanced version detection | `--script version` |
| `vuln` | Vulnerability detection | `--script vuln` |

---

## Running Scripts

### Basic Script Execution

```bash
# Run default scripts
nmap -sC 10.10.10.1

# Run a specific script
nmap --script smb-enum-shares 10.10.10.1

# Run multiple specific scripts
nmap --script "smb-enum-shares,smb-enum-users" 10.10.10.1

# Run all scripts in a category
nmap --script vuln 10.10.10.1

# Run scripts matching a pattern
nmap --script "smb-*" 10.10.10.1

# Combine categories with boolean operators
nmap --script "vuln and safe" 10.10.10.1
nmap --script "smb-* and not brute" 10.10.10.1

# Run multiple categories
nmap --script "discovery,vuln" 10.10.10.1
```

### Script Help and Information

```bash
# Get help for a specific script
nmap --script-help smb-enum-shares

# List all scripts
ls /usr/share/nmap/scripts/

# Search for scripts by name
ls /usr/share/nmap/scripts/ | grep smb

# Update script database
sudo nmap --script-updatedb
```

---

## Discovery and Enumeration Scripts

### SMB Enumeration

```bash
# Enumerate SMB shares
nmap -p 445 --script smb-enum-shares 10.10.10.1
nmap -p 445 --script smb-enum-shares --script-args smbusername=admin,smbpassword=pass 10.10.10.1

# Enumerate users via SMB
nmap -p 445 --script smb-enum-users 10.10.10.1

# Enumerate SMB sessions
nmap -p 445 --script smb-enum-sessions 10.10.10.1

# OS discovery via SMB
nmap -p 445 --script smb-os-discovery 10.10.10.1

# List SMB protocols/dialects
nmap -p 445 --script smb-protocols 10.10.10.1
nmap -p 445 --script smb2-security-mode 10.10.10.1

# Comprehensive SMB enumeration
nmap -p 139,445 --script "smb-enum-*" 10.10.10.1
```

**Useful SMB Scripts:**
| Script | Description |
|--------|-------------|
| `smb-enum-shares` | List available shares |
| `smb-enum-users` | Enumerate domain users |
| `smb-enum-groups` | Enumerate domain groups |
| `smb-enum-domains` | Enumerate domains |
| `smb-enum-services` | Enumerate Windows services |
| `smb-enum-processes` | List running processes |
| `smb-os-discovery` | Detect OS, domain, hostname |
| `smb-protocols` | List supported SMB protocols |
| `smb2-security-mode` | Check SMB signing configuration |
| `smb-security-mode` | Check SMB security level |

### DNS Enumeration

```bash
# DNS brute force subdomain enumeration
nmap --script dns-brute --script-args dns-brute.domain=example.com 10.10.10.1

# Custom wordlist for DNS brute force
nmap --script dns-brute --script-args dns-brute.domain=example.com,dns-brute.hostlist=/path/to/wordlist.txt 10.10.10.1

# DNS zone transfer attempt
nmap --script dns-zone-transfer --script-args dns-zone-transfer.domain=example.com -p 53 10.10.10.1

# DNS service discovery
nmap --script dns-srv-enum --script-args dns-srv-enum.domain=example.com 10.10.10.1

# DNS cache snooping
nmap --script dns-cache-snoop --script-args dns-cache-snoop.mode=timed,dns-cache-snoop.domains={google.com,facebook.com} -p 53 10.10.10.1
```

### HTTP Enumeration

```bash
# Enumerate HTTP methods
nmap -p 80,443 --script http-methods 10.10.10.1
nmap -p 80 --script http-methods --script-args http-methods.url-path='/admin/' 10.10.10.1

# HTTP title grabbing
nmap -p 80,443 --script http-title 10.10.10.1

# Directory/file enumeration
nmap -p 80 --script http-enum 10.10.10.1

# Robots.txt and sitemap
nmap -p 80 --script http-robots.txt 10.10.10.1
nmap -p 80 --script http-sitemap-generator 10.10.10.1

# Web server info
nmap -p 80 --script http-server-header 10.10.10.1
nmap -p 80 --script http-headers 10.10.10.1

# Virtual host enumeration
nmap -p 80 --script http-vhosts 10.10.10.1

# Backup file finder
nmap -p 80 --script http-backup-finder 10.10.10.1

# WordPress enumeration
nmap -p 80 --script http-wordpress-enum 10.10.10.1
nmap -p 80 --script http-wordpress-users 10.10.10.1

# Git repository exposure
nmap -p 80 --script http-git 10.10.10.1

# Comprehensive HTTP enumeration
nmap -p 80,443,8080 --script "http-enum,http-headers,http-methods,http-title" 10.10.10.1
```

**Useful HTTP Scripts:**
| Script | Description |
|--------|-------------|
| `http-enum` | Enumerate directories and files |
| `http-title` | Grab page titles |
| `http-methods` | List allowed HTTP methods |
| `http-headers` | Display HTTP headers |
| `http-robots.txt` | Read robots.txt |
| `http-git` | Detect exposed .git directories |
| `http-config-backup` | Find config file backups |
| `http-wordpress-enum` | Enumerate WordPress plugins/themes |
| `http-sql-injection` | Test for SQL injection |
| `http-shellshock` | Test for Shellshock vulnerability |

### LDAP Enumeration

```bash
# LDAP root DSE query
nmap -p 389 --script ldap-rootdse 10.10.10.1

# LDAP search
nmap -p 389 --script ldap-search 10.10.10.1

# LDAP brute force
nmap -p 389 --script ldap-brute 10.10.10.1
```

### SNMP Enumeration

```bash
# SNMP system information
nmap -sU -p 161 --script snmp-info 10.10.10.1

# SNMP brute force community strings
nmap -sU -p 161 --script snmp-brute 10.10.10.1

# SNMP interface enumeration
nmap -sU -p 161 --script snmp-interfaces 10.10.10.1

# SNMP process list
nmap -sU -p 161 --script snmp-processes 10.10.10.1

# SNMP Windows user enumeration
nmap -sU -p 161 --script snmp-win32-users 10.10.10.1

# SNMP network stats
nmap -sU -p 161 --script snmp-netstat 10.10.10.1

# Comprehensive SNMP enumeration
nmap -sU -p 161 --script "snmp-*" 10.10.10.1
```

### NFS Enumeration

```bash
# List NFS shares
nmap -p 111,2049 --script nfs-ls 10.10.10.1

# Show NFS exports
nmap -p 111,2049 --script nfs-showmount 10.10.10.1

# NFS statistics
nmap -p 111,2049 --script nfs-statfs 10.10.10.1
```

### MySQL Enumeration

```bash
# MySQL info
nmap -p 3306 --script mysql-info 10.10.10.1

# MySQL databases (requires auth)
nmap -p 3306 --script mysql-databases --script-args mysqluser=root,mysqlpass=password 10.10.10.1

# MySQL users
nmap -p 3306 --script mysql-users --script-args mysqluser=root,mysqlpass=password 10.10.10.1

# MySQL variables
nmap -p 3306 --script mysql-variables 10.10.10.1

# MySQL empty password check
nmap -p 3306 --script mysql-empty-password 10.10.10.1
```

### Other Service Enumeration

```bash
# FTP anonymous access
nmap -p 21 --script ftp-anon 10.10.10.1

# SSH algorithms
nmap -p 22 --script ssh2-enum-algos 10.10.10.1
nmap -p 22 --script ssh-hostkey 10.10.10.1

# SMTP commands/users
nmap -p 25 --script smtp-commands 10.10.10.1
nmap -p 25 --script smtp-enum-users 10.10.10.1

# POP3 capabilities
nmap -p 110 --script pop3-capabilities 10.10.10.1

# IMAP capabilities
nmap -p 143 --script imap-capabilities 10.10.10.1

# RDP encryption check
nmap -p 3389 --script rdp-enum-encryption 10.10.10.1

# VNC info
nmap -p 5900 --script vnc-info 10.10.10.1

# Redis info
nmap -p 6379 --script redis-info 10.10.10.1

# MongoDB info
nmap -p 27017 --script mongodb-info 10.10.10.1
```

---

## Vulnerability Scanning Scripts

### SMB Vulnerabilities

```bash
# Check all SMB vulnerabilities
nmap -p 445 --script "smb-vuln-*" 10.10.10.1

# EternalBlue (MS17-010) - Critical!
nmap -p 445 --script smb-vuln-ms17-010 10.10.10.1

# MS08-067 (Conficker)
nmap -p 445 --script smb-vuln-ms08-067 10.10.10.1

# MS06-025
nmap -p 445 --script smb-vuln-ms06-025 10.10.10.1

# MS07-029 (DNS RPC)
nmap -p 445 --script smb-vuln-ms07-029 10.10.10.1

# SMB double pulsar backdoor
nmap -p 445 --script smb-double-pulsar-backdoor 10.10.10.1

# Comprehensive SMB vuln scan
nmap -p 139,445 --script "smb-vuln-*" --script-args=unsafe=1 10.10.10.1
```

**Critical SMB Vulnerability Scripts:**
| Script | CVE/MS | Description |
|--------|--------|-------------|
| `smb-vuln-ms17-010` | MS17-010 | EternalBlue - Remote code execution |
| `smb-vuln-ms08-067` | MS08-067 | Conficker - Remote code execution |
| `smb-vuln-cve-2017-7494` | CVE-2017-7494 | SambaCry - Linux Samba RCE |
| `smb-vuln-ms10-054` | MS10-054 | Memory corruption DoS |
| `smb-vuln-ms10-061` | MS10-061 | Print spooler vulnerability |
| `smb-double-pulsar-backdoor` | - | NSA backdoor detection |

### HTTP Vulnerabilities

```bash
# Check all HTTP vulnerabilities
nmap -p 80,443 --script "http-vuln-*" 10.10.10.1

# Shellshock
nmap -p 80 --script http-shellshock --script-args uri=/cgi-bin/test.cgi 10.10.10.1

# Heartbleed (OpenSSL)
nmap -p 443 --script ssl-heartbleed 10.10.10.1

# HTTP slowloris DoS check
nmap -p 80 --script http-slowloris-check 10.10.10.1

# IIS WebDAV
nmap -p 80 --script http-iis-webdav-vuln 10.10.10.1

# PHP CGI argument injection
nmap -p 80 --script http-vuln-cve2012-1823 10.10.10.1

# Apache Struts
nmap -p 80 --script http-vuln-cve2017-5638 10.10.10.1
```

### SSL/TLS Vulnerabilities

```bash
# Heartbleed
nmap -p 443 --script ssl-heartbleed 10.10.10.1

# POODLE
nmap -p 443 --script ssl-poodle 10.10.10.1

# DROWN
nmap -p 443 --script ssl-drown 10.10.10.1

# CCS Injection
nmap -p 443 --script ssl-ccs-injection 10.10.10.1

# SSL certificate info
nmap -p 443 --script ssl-cert 10.10.10.1

# SSL/TLS versions and ciphers
nmap -p 443 --script ssl-enum-ciphers 10.10.10.1

# Comprehensive SSL scan
nmap -p 443 --script "ssl-*" 10.10.10.1
```

### Other Service Vulnerabilities

```bash
# FTP backdoor (vsftpd 2.3.4)
nmap -p 21 --script ftp-vsftpd-backdoor 10.10.10.1

# FTP ProFTPD backdoor
nmap -p 21 --script ftp-proftpd-backdoor 10.10.10.1

# MySQL vulnerabilities
nmap -p 3306 --script mysql-vuln-cve2012-2122 10.10.10.1

# RDP BlueKeep (CVE-2019-0708)
nmap -p 3389 --script rdp-vuln-ms12-020 10.10.10.1

# SSH vulnerabilities
nmap -p 22 --script sshv1 10.10.10.1

# IRC backdoor
nmap -p 6667 --script irc-unrealircd-backdoor 10.10.10.1

# Run all vulnerability scripts (noisy!)
nmap --script vuln 10.10.10.1
```

---

## Brute Force Scripts

### SSH Brute Force

```bash
# Basic SSH brute force
nmap -p 22 --script ssh-brute 10.10.10.1

# With custom credentials
nmap -p 22 --script ssh-brute --script-args userdb=users.txt,passdb=passwords.txt 10.10.10.1

# Single user with password list
nmap -p 22 --script ssh-brute --script-args userdb=users.txt,passdb=passwords.txt,ssh-brute.timeout=5s 10.10.10.1
```

### FTP Brute Force

```bash
# FTP brute force
nmap -p 21 --script ftp-brute 10.10.10.1

# With wordlists
nmap -p 21 --script ftp-brute --script-args userdb=users.txt,passdb=passwords.txt 10.10.10.1
```

### HTTP Brute Force

```bash
# HTTP basic auth brute force
nmap -p 80 --script http-brute 10.10.10.1

# HTTP form brute force
nmap -p 80 --script http-form-brute --script-args http-form-brute.path=/login 10.10.10.1

# With custom parameters
nmap -p 80 --script http-form-brute --script-args 'http-form-brute.path=/login.php,http-form-brute.uservar=user,http-form-brute.passvar=pass' 10.10.10.1

# WordPress brute force
nmap -p 80 --script http-wordpress-brute 10.10.10.1
nmap -p 80 --script http-wordpress-brute --script-args userdb=users.txt,passdb=passwords.txt 10.10.10.1
```

### Database Brute Force

```bash
# MySQL brute force
nmap -p 3306 --script mysql-brute 10.10.10.1

# PostgreSQL brute force
nmap -p 5432 --script pgsql-brute 10.10.10.1

# MongoDB brute force
nmap -p 27017 --script mongodb-brute 10.10.10.1

# MS SQL brute force
nmap -p 1433 --script ms-sql-brute 10.10.10.1

# Oracle brute force
nmap -p 1521 --script oracle-brute 10.10.10.1

# Redis brute force
nmap -p 6379 --script redis-brute 10.10.10.1
```

### Other Brute Force Scripts

```bash
# LDAP brute force
nmap -p 389 --script ldap-brute 10.10.10.1

# SMTP brute force
nmap -p 25 --script smtp-brute 10.10.10.1

# POP3 brute force
nmap -p 110 --script pop3-brute 10.10.10.1

# IMAP brute force
nmap -p 143 --script imap-brute 10.10.10.1

# Telnet brute force
nmap -p 23 --script telnet-brute 10.10.10.1

# VNC brute force
nmap -p 5900 --script vnc-brute 10.10.10.1

# RDP brute force (NLA)
nmap -p 3389 --script rdp-brute 10.10.10.1

# SNMP community string brute force
nmap -sU -p 161 --script snmp-brute 10.10.10.1
```

### Brute Force Script Arguments

```bash
# Common brute force arguments
--script-args userdb=/path/to/users.txt          # User wordlist
--script-args passdb=/path/to/passwords.txt      # Password wordlist
--script-args brute.firstonly=true               # Stop after first valid cred
--script-args brute.mode=creds                   # Try all user/pass combos
--script-args brute.credfile=/path/to/creds.txt  # user:pass format file
--script-args brute.threads=10                   # Number of threads
--script-args brute.delay=1s                     # Delay between attempts
```

---

## Default Scripts (-sC)

The `-sC` flag runs scripts in the "default" category. These are considered safe and useful for general scanning.

### Key Default Scripts by Service

**SSH (Port 22):**
- `ssh-hostkey` - Retrieve SSH host keys
- `ssh2-enum-algos` - Enumerate SSH2 algorithms

**FTP (Port 21):**
- `ftp-anon` - Check for anonymous FTP access
- `ftp-syst` - Get FTP system information

**SMTP (Port 25):**
- `smtp-commands` - Enumerate SMTP commands

**HTTP (Port 80/443):**
- `http-title` - Get page title
- `http-server-header` - Server header info
- `http-favicon` - Identify framework by favicon

**SMB (Port 139/445):**
- `smb-os-discovery` - OS and domain info
- `smb-security-mode` - Security settings
- `smb2-security-mode` - SMB2 security settings

**MySQL (Port 3306):**
- `mysql-info` - MySQL server information

**RDP (Port 3389):**
- `rdp-ntlm-info` - NTLM info from RDP

### Example Default Script Scan

```bash
# Standard service scan with default scripts
nmap -sC -sV -p- 10.10.10.1

# Faster scan of common ports
nmap -sC -sV --top-ports 1000 10.10.10.1

# Save all outputs
nmap -sC -sV -oA scan_results 10.10.10.1
```

---

## Script Arguments

### General Syntax

```bash
# Single argument
nmap --script smb-enum-shares --script-args smbusername=admin 10.10.10.1

# Multiple arguments
nmap --script smb-enum-shares --script-args smbusername=admin,smbpassword=pass123 10.10.10.1

# Arguments with spaces (use quotes)
nmap --script http-brute --script-args 'http-brute.path=/login,passdb=/path/to/pass.txt' 10.10.10.1

# Using argument file
nmap --script-args-file args.txt 10.10.10.1
```

### Common Script Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `smbusername` | SMB username | `smbusername=admin` |
| `smbpassword` | SMB password | `smbpassword=password` |
| `smbdomain` | SMB domain | `smbdomain=WORKGROUP` |
| `userdb` | Username wordlist | `userdb=/path/to/users.txt` |
| `passdb` | Password wordlist | `passdb=/path/to/pass.txt` |
| `unpwdb.timelimit` | Brute force time limit | `unpwdb.timelimit=30m` |
| `http.useragent` | Custom User-Agent | `http.useragent="Mozilla/5.0"` |
| `vulns.showall` | Show all vuln results | `vulns.showall` |
| `unsafe` | Enable unsafe checks | `unsafe=1` |

### SMB Authentication

```bash
# With credentials
nmap -p 445 --script smb-enum-shares --script-args smbusername=admin,smbpassword=pass,smbdomain=CORP 10.10.10.1

# With NTLM hash (pass-the-hash)
nmap -p 445 --script smb-enum-shares --script-args smbhash=aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0 10.10.10.1
```

### HTTP Arguments

```bash
# Custom paths
nmap -p 80 --script http-enum --script-args http-enum.basepath='/app/' 10.10.10.1

# Custom User-Agent
nmap -p 80 --script http-headers --script-args http.useragent="CustomBot/1.0" 10.10.10.1

# Proxy support
nmap -p 80 --script http-* --script-args http.proxy="127.0.0.1:8080" 10.10.10.1
```

---

## Writing Custom Scripts

### Script Location

```bash
# System scripts
/usr/share/nmap/scripts/

# User scripts (create if needed)
~/.nmap/scripts/
```

### Basic Script Template

```lua
-- Head section
local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"

description = [[
Brief description of what the script does.
]]

---
-- @usage
-- nmap --script my-script -p 80 <target>
--
-- @output
-- PORT   STATE SERVICE
-- 80/tcp open  http
-- |_my-script: Result text here
--
-- @args my-script.arg1 Description of argument

author = "Your Name"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discovery", "safe"}

-- Rule section - when should script run?
portrule = shortport.http

-- Action section - what does the script do?
action = function(host, port)
    local response = http.get(host, port, "/")

    if response.status == 200 then
        return "Server responded with 200 OK"
    else
        return "Server responded with " .. response.status
    end
end
```

### Script Rules

```lua
-- Port-based rule
portrule = shortport.port_or_service(80, "http")

-- Service-based rule
portrule = shortport.service("http")

-- Multiple ports
portrule = shortport.port_or_service({80, 443, 8080}, {"http", "https"})

-- Host-based rule (runs once per host)
hostrule = function(host)
    return true  -- Run for all hosts
end

-- Pre-rule (runs before scanning)
prerule = function()
    return true
end

-- Post-rule (runs after all scanning)
postrule = function()
    return true
end
```

### Useful NSE Libraries

| Library | Purpose |
|---------|---------|
| `http` | HTTP requests/responses |
| `shortport` | Port matching rules |
| `stdnse` | Standard NSE functions |
| `nmap` | Core nmap functions |
| `string` | String manipulation |
| `table` | Table utilities |
| `smb` | SMB protocol |
| `ssh2` | SSH protocol |
| `dns` | DNS queries |
| `brute` | Brute force framework |
| `creds` | Credential storage |
| `vulns` | Vulnerability reporting |

### Example: Simple HTTP Check Script

```lua
local http = require "http"
local shortport = require "shortport"
local stdnse = require "stdnse"
local string = require "string"

description = [[
Checks for the presence of a specific file on a web server.
]]

author = "Pentester"
license = "Same as Nmap"
categories = {"discovery", "safe"}

-- Script arguments
---@args http-file-check.path Path to check (default: /robots.txt)

portrule = shortport.http

action = function(host, port)
    local path = stdnse.get_script_args("http-file-check.path") or "/robots.txt"
    local response = http.get(host, port, path)

    if response.status == 200 then
        local lines = {}
        for line in string.gmatch(response.body, "[^\r\n]+") do
            table.insert(lines, line)
            if #lines >= 5 then break end  -- First 5 lines
        end
        return string.format("Found %s:\n%s", path, table.concat(lines, "\n"))
    elseif response.status == 404 then
        return stdnse.format_output(false, path .. " not found")
    else
        return stdnse.format_output(false, "HTTP " .. response.status)
    end
end
```

### Updating Script Database

```bash
# After adding new scripts, update the database
sudo nmap --script-updatedb
```

---

## Script Combinations for Common Scenarios

### Initial Reconnaissance

```bash
# Quick recon scan
nmap -sC -sV -O --top-ports 1000 -oA initial_scan 10.10.10.1

# Full port scan with scripts
nmap -sC -sV -p- -oA full_scan 10.10.10.1
```

### Web Application Testing

```bash
# Comprehensive web scan
nmap -p 80,443,8080,8443 --script "http-enum,http-headers,http-methods,http-title,http-robots.txt,http-git,http-backup-finder,http-config-backup" 10.10.10.1

# Web vulnerability scan
nmap -p 80,443 --script "http-vuln-*,http-shellshock,http-sql-injection" 10.10.10.1
```

### Active Directory / Windows

```bash
# AD enumeration
nmap -p 88,135,139,389,445,464,636,3268,3269 --script "smb-enum-*,ldap-rootdse,ldap-search,dns-srv-enum" 10.10.10.1

# Windows vulnerability check
nmap -p 139,445,3389 --script "smb-vuln-*,rdp-vuln-*" 10.10.10.1
```

### Database Servers

```bash
# MySQL
nmap -p 3306 --script "mysql-*" 10.10.10.1

# PostgreSQL
nmap -p 5432 --script "pgsql-*" 10.10.10.1

# MS SQL
nmap -p 1433 --script "ms-sql-*" 10.10.10.1

# MongoDB
nmap -p 27017 --script "mongodb-*" 10.10.10.1
```

### Network Services

```bash
# FTP
nmap -p 21 --script "ftp-*" 10.10.10.1

# SSH
nmap -p 22 --script "ssh-*" 10.10.10.1

# SMTP
nmap -p 25,465,587 --script "smtp-*" 10.10.10.1

# SNMP
nmap -sU -p 161 --script "snmp-*" 10.10.10.1
```

### Full Vulnerability Assessment

```bash
# Comprehensive vulnerability scan (noisy!)
nmap -sV --script vuln -oA vuln_scan 10.10.10.1

# Safe vulnerability scan
nmap -sV --script "vuln and safe" -oA safe_vuln_scan 10.10.10.1
```

---

## Tips and Best Practices

1. **Start with default scripts** (`-sC`) before running more aggressive scripts
2. **Use `-sV` with scripts** - many scripts need version info to work properly
3. **Check script help** before using: `nmap --script-help <script-name>`
4. **Use timing wisely** - brute force scripts can be slow; adjust with `--script-timeout`
5. **Save outputs** - always use `-oA` to save in all formats
6. **Test scripts safely** - use `--script "category and safe"` in production
7. **Update regularly** - new scripts are added frequently: `nmap --script-updatedb`

---

## References

- [NSE Documentation](https://nmap.org/book/nse.html)
- [NSE Script List](https://nmap.org/nsedoc/scripts/)
- [NSE Categories](https://nmap.org/nsedoc/categories/)
- [NSE Libraries](https://nmap.org/nsedoc/lib/)
- [Writing NSE Scripts](https://nmap.org/book/nse-tutorial.html)
