---
title: "Nikto - Official Documentation Reference"
category: "tools"
tags: ["web-scanner", "vulnerability-scanner", "nikto"]
last_updated: "2025-12-27"
---

# Nikto - Official Documentation Reference

## Table of Contents

- [Overview](#overview)
- [Installation and Requirements](#installation-and-requirements)
- [Basic Scanning Options](#basic-scanning-options)
- [Tuning Options for Scan Types](#tuning-options-for-scan-types)
- [Authentication Options](#authentication-options)
- [Output Formats](#output-formats)
- [SSL/TLS Options](#ssltls-options)
- [Evasion Techniques](#evasion-techniques)
- [Database Updates](#database-updates)
- [Plugin System](#plugin-system)
- [Configuration File](#configuration-file)
- [Practical Scanning Examples](#practical-scanning-examples)
- [Command Reference](#command-reference)
- [Resources](#resources)

---

## Overview

Nikto is an open-source web server vulnerability scanner that performs comprehensive tests against web servers. It is designed to identify potential security issues including:

- Over 6700 potentially dangerous files/programs
- Outdated versions of over 1250 servers
- Version-specific problems on over 270 servers
- Server configuration issues
- Default files and programs
- Insecure files and programs

**Key Characteristics:**

| Feature | Description |
|---------|-------------|
| Type | Web server vulnerability scanner |
| Language | Perl |
| License | GPL |
| Database | Regularly updated vulnerability signatures |
| Output | Multiple formats (TXT, HTML, XML, JSON, CSV) |

**Official Sources:**
- Website: https://cirt.net/Nikto2
- GitHub: https://github.com/sullo/nikto
- Wiki: https://github.com/sullo/nikto/wiki

---

## Installation and Requirements

### System Requirements

- Perl 5.x interpreter
- LibWhisker Perl module (included)
- SSL support requires Net::SSLeay module
- Network connectivity to target

### Kali Linux (Pre-installed)

```bash
# Verify installation
nikto -Version

# Update to latest version
sudo apt update && sudo apt install -y nikto
```

### Debian/Ubuntu

```bash
sudo apt update
sudo apt install -y nikto
```

### RHEL/CentOS/Fedora

```bash
# Install dependencies
sudo dnf install -y perl perl-Net-SSLeay

# Clone from source
git clone https://github.com/sullo/nikto.git
cd nikto/program
perl nikto.pl -Version
```

### From Source (Latest Version)

```bash
# Clone repository
git clone https://github.com/sullo/nikto.git
cd nikto/program

# Verify installation
perl nikto.pl -Version

# Optional: Create symlink for system-wide access
sudo ln -s $(pwd)/nikto.pl /usr/local/bin/nikto
```

### Docker Installation

```bash
# Pull official image
docker pull sullo/nikto

# Run scan
docker run --rm sullo/nikto -h http://target.com

# Run with output file
docker run --rm -v $(pwd):/tmp sullo/nikto -h http://target.com -o /tmp/report.html -Format htm
```

### Required Perl Modules

```bash
# Install SSL support
cpan Net::SSLeay
cpan LWP::Protocol::https

# Or via package manager
sudo apt install -y libnet-ssleay-perl libcrypt-ssleay-perl
```

### Verify Installation

```bash
# Check version
nikto -Version

# List available plugins
nikto -list-plugins

# Check database status
nikto -dbcheck

# Update databases
nikto -update
```

---

## Basic Scanning Options

### Target Specification (-h, -host)

The `-h` or `-host` option specifies the target to scan.

```bash
# Scan by hostname
nikto -h www.example.com

# Scan by IP address
nikto -h 192.168.1.100

# Scan full URL
nikto -h http://www.example.com

# Scan HTTPS URL (auto-enables SSL)
nikto -h https://www.example.com

# Scan with specific path
nikto -h http://www.example.com/webapp/
```

### Port Specification (-p, -port)

The `-p` or `-port` option specifies target port(s).

```bash
# Scan specific port
nikto -h target.com -p 8080

# Scan multiple ports (comma-separated)
nikto -h target.com -p 80,443,8080,8443

# Scan port range
nikto -h target.com -p 80-90

# Scan common web ports
nikto -h target.com -p 80,443,8000,8080,8443,8888,9000

# SSL on non-standard port
nikto -h target.com -p 8443 -ssl
```

### Virtual Host (-vhost)

Specify the Host header value for virtual host scanning.

```bash
# Scan virtual host
nikto -h 192.168.1.100 -vhost www.target.com

# Virtual host over SSL
nikto -h 192.168.1.100 -vhost secure.target.com -ssl -p 443

# Scan IP but use hostname in Host header
nikto -h 10.10.10.10 -vhost internal.corp.local
```

### Root Directory (-root)

Prepend a path to all requests.

```bash
# Scan specific application path
nikto -h http://target.com -root /webapp/

# Scan API endpoint
nikto -h http://target.com -root /api/v1/

# Scan admin section
nikto -h http://target.com -root /admin/
```

### CGI Directories (-Cgidirs)

Specify CGI directories to scan.

```bash
# Scan all common CGI directories
nikto -h http://target.com -Cgidirs all

# Scan specific CGI directories
nikto -h http://target.com -Cgidirs "/cgi-bin/,/scripts/,/cgi/"

# Skip CGI scanning
nikto -h http://target.com -Cgidirs none
```

### Timeout and Timing

```bash
# Set request timeout (seconds)
nikto -h http://target.com -timeout 10

# Pause between requests (seconds)
nikto -h http://target.com -Pause 2

# Maximum scan time (seconds)
nikto -h http://target.com -maxtime 3600

# Stop at specific time
nikto -h http://target.com -until 23:00:00
```

---

## Tuning Options for Scan Types

The `-Tuning` option controls which test categories to include or exclude. This is essential for focusing scans and avoiding unnecessary tests.

### Tuning Categories

| Code | Category | Description |
|------|----------|-------------|
| 0 | File Upload | Check for forms allowing file uploads |
| 1 | Interesting File/Logs | Look for interesting files, logs, backup files |
| 2 | Misconfiguration/Default | Check for default files and misconfigurations |
| 3 | Information Disclosure | Check for information disclosure paths |
| 4 | Injection (XSS/Script/HTML) | Test for XSS and script injection |
| 5 | Remote File Retrieval (Server) | Server-side file retrieval vulnerabilities |
| 6 | Denial of Service | Test for DoS vulnerabilities |
| 7 | Remote File Retrieval (Web) | Web-based file retrieval vulnerabilities |
| 8 | Command Execution | Check for remote shell/command execution |
| 9 | SQL Injection | Test for SQL injection vulnerabilities |
| a | Authentication Bypass | Check for authentication bypass issues |
| b | Software Identification | Identify installed software versions |
| c | Remote Source Inclusion | Test for remote file inclusion (RFI) |
| d | WebService | Web service specific checks |
| e | Administrative Console | Look for administrative interfaces |
| x | Reverse Tuning | Exclude specified options instead of include |

### Including Specific Tests

```bash
# Only information disclosure tests
nikto -h http://target.com -Tuning 1

# Information disclosure and interesting files
nikto -h http://target.com -Tuning 13

# Focus on injection vulnerabilities (XSS, SQLi)
nikto -h http://target.com -Tuning 49

# Check for command execution and RCE
nikto -h http://target.com -Tuning 89

# Authentication and admin console checks
nikto -h http://target.com -Tuning ae

# Software identification only (quick fingerprint)
nikto -h http://target.com -Tuning b

# Comprehensive vulnerability scan
nikto -h http://target.com -Tuning 1234589abc
```

### Excluding Specific Tests (Reverse Tuning)

Use `x` prefix to exclude categories instead of include:

```bash
# Everything except DoS tests (safe for production)
nikto -h http://target.com -Tuning x6

# Exclude DoS and file upload tests
nikto -h http://target.com -Tuning x06

# Exclude DoS, file upload, and command execution
nikto -h http://target.com -Tuning x068

# Run all tests except DoS (most common safe option)
nikto -h http://target.com -Tuning x6
```

### Recommended Tuning Combinations

| Use Case | Tuning | Description |
|----------|--------|-------------|
| Safe production scan | `x6` | All tests except DoS |
| Quick recon | `13b` | Info disclosure + software ID |
| Injection focus | `49` | XSS and SQL injection |
| RCE hunting | `89c` | Command exec and remote inclusion |
| Auth testing | `ae` | Auth bypass + admin consoles |
| Full safe scan | `x6` | Comprehensive without DoS |
| Minimal footprint | `b` | Software identification only |

---

## Authentication Options

### Basic HTTP Authentication (-id)

```bash
# Basic authentication
nikto -h http://target.com -id username:password

# With special characters (URL encode)
nikto -h http://target.com -id "admin:p%40ssw0rd"

# NTLM authentication (include domain)
nikto -h http://target.com -id username:password:DOMAIN

# Digest authentication (auto-detected)
nikto -h http://target.com -id user:pass
```

### Authenticated Scanning

```bash
# Scan protected directory
nikto -h http://target.com/admin/ -id admin:password

# Scan with root path and auth
nikto -h http://target.com -root /secure/ -id user:pass

# Comprehensive authenticated scan
nikto -h http://target.com -id admin:pass -Tuning x6 -o auth_scan.html -Format htm
```

### Proxy Configuration (-useproxy)

```bash
# HTTP proxy
nikto -h http://target.com -useproxy http://127.0.0.1:8080

# Through Burp Suite
nikto -h http://target.com -useproxy http://127.0.0.1:8080

# Corporate proxy
nikto -h http://target.com -useproxy http://proxy.corp.com:3128

# Proxy with authentication
nikto -h http://target.com -useproxy http://user:pass@proxy.corp.com:8080
```

### SOCKS Proxy Support

```bash
# SOCKS4 proxy
nikto -h http://target.com -useproxy socks4://127.0.0.1:1080

# SOCKS5 proxy
nikto -h http://target.com -useproxy socks5://127.0.0.1:1080

# Through Tor network
nikto -h http://target.com -useproxy socks5://127.0.0.1:9050

# Via SSH tunnel
nikto -h http://internal.target.local -useproxy socks5://127.0.0.1:9050
```

### Proxychains Integration

```bash
# Using proxychains for complex routing
proxychains4 nikto -h http://internal-target.local

# Configure proxychains in /etc/proxychains4.conf
# Then run normally through the proxy chain
proxychains4 nikto -h http://10.10.10.10 -Tuning x6
```

---

## Output Formats

### Output Options (-o, -output, -Format)

```bash
# Text output (default)
nikto -h http://target.com -o results.txt

# Specify format explicitly
nikto -h http://target.com -o results.txt -Format txt
```

### Available Formats

| Format | Flag | Extension | Description |
|--------|------|-----------|-------------|
| Text | `txt` | .txt | Plain text output (default) |
| HTML | `htm` | .html/.htm | Browser-viewable report |
| CSV | `csv` | .csv | Comma-separated for spreadsheets |
| XML | `xml` | .xml | Structured XML output |
| JSON | `json` | .json | JSON for parsing/automation |
| SQL | `sql` | .sql | SQL INSERT statements |
| NBE | `nbe` | .nbe | Nessus NBE format |

### Format Examples

```bash
# HTML report
nikto -h http://target.com -o report.html -Format htm

# JSON for automation
nikto -h http://target.com -o scan.json -Format json

# CSV for spreadsheet analysis
nikto -h http://target.com -o findings.csv -Format csv

# XML for tool integration
nikto -h http://target.com -o scan.xml -Format xml

# SQL for database import
nikto -h http://target.com -o findings.sql -Format sql

# Nessus format
nikto -h http://target.com -o scan.nbe -Format nbe
```

### Auto-Detection by Extension

```bash
# Format auto-detected from extension
nikto -h http://target.com -o report.html
nikto -h http://target.com -o report.xml
nikto -h http://target.com -o report.json
nikto -h http://target.com -o report.csv
```

### Display Options (-Display)

Control what is shown in console output:

| Value | Description |
|-------|-------------|
| 1 | Show redirects |
| 2 | Show cookies received |
| 3 | Show all 200/OK responses |
| 4 | Show URLs requiring authentication |
| D | Debug output |
| E | Display HTTP errors |
| P | Print progress to STDOUT |
| S | Scrub output of IPs and hostnames |
| V | Verbose output |

```bash
# Verbose with progress
nikto -h http://target.com -Display VP

# Show redirects and cookies
nikto -h http://target.com -Display 12

# Debug mode
nikto -h http://target.com -Display D

# Show auth-required URLs
nikto -h http://target.com -Display 4

# All display options
nikto -h http://target.com -Display 1234DEPV

# Scrub sensitive info for reporting
nikto -h http://target.com -Display S -o report.txt
```

---

## SSL/TLS Options

### Basic SSL Scanning

```bash
# Force SSL mode
nikto -h target.com -ssl

# HTTPS URL (auto-detects SSL)
nikto -h https://target.com

# SSL on custom port
nikto -h target.com -p 8443 -ssl

# Scan multiple SSL ports
nikto -h target.com -p 443,8443,9443 -ssl
```

### SSL Configuration Options

```bash
# Disable SSL certificate verification (self-signed certs)
nikto -h https://target.com -nossl

# Specify SSL/TLS version
nikto -h target.com -ssl -sslversion TLSv1_2

# Available SSL versions: SSLv3, TLSv1, TLSv1_1, TLSv1_2, TLSv1_3
nikto -h target.com -ssl -sslversion TLSv1_3
```

### SSL Plugin Analysis

```bash
# Detailed SSL certificate and configuration analysis
nikto -h https://target.com -Plugins "ssl"

# SSL with header analysis
nikto -h https://target.com -Plugins "ssl;headers"

# Full SSL-focused scan
nikto -h https://target.com -ssl -Plugins "ssl;headers;cookies"
```

### What Nikto Checks for SSL/TLS

- Expired certificates
- Self-signed certificates
- Certificate hostname mismatches
- Weak cipher suites
- Deprecated SSL/TLS versions (SSLv2, SSLv3)
- Missing HSTS header
- Certificate chain issues
- Known SSL vulnerabilities

### Virtual Host SSL Scanning

```bash
# Scan IP with SSL and virtual host
nikto -h 192.168.1.100 -vhost secure.example.com -ssl -p 443

# Multiple virtual hosts on same IP
nikto -h 192.168.1.100 -vhost site1.example.com -ssl
nikto -h 192.168.1.100 -vhost site2.example.com -ssl
```

---

## Evasion Techniques

The `-evasion` option provides IDS/IPS evasion capabilities to help bypass security controls during authorized testing.

### Evasion Methods

| Code | Technique | Description |
|------|-----------|-------------|
| 1 | Random URI encoding | Randomly URL-encode characters |
| 2 | Directory self-reference | Add `/./ ` to request path |
| 3 | Premature URL ending | Insert `%00` null bytes |
| 4 | Prepend long random string | Add random data before URL |
| 5 | Fake parameter | Add fake query parameter |
| 6 | TAB as request spacer | Use TAB character instead of space |
| 7 | Random case sensitivity | Randomize URL character case |
| 8 | Windows directory separator | Use backslash `\` in paths |

### Evasion Examples

```bash
# Single evasion technique (random encoding)
nikto -h http://target.com -evasion 1

# Multiple techniques
nikto -h http://target.com -evasion 1234

# All evasion techniques
nikto -h http://target.com -evasion 12345678

# Common IDS bypass combination
nikto -h http://target.com -evasion 147

# Directory-based evasion
nikto -h http://target.com -evasion 28

# Random case with encoding
nikto -h http://target.com -evasion 17
```

### Timing-Based Evasion

```bash
# Add delay between requests (seconds)
nikto -h http://target.com -Pause 2

# Slow scan for stealth
nikto -h http://target.com -Pause 5 -evasion 1

# Very slow stealth scan
nikto -h http://target.com -Pause 10 -evasion 147 -timeout 30
```

### Mutation Options (-mutate)

The mutation option guesses additional files/directories:

| Code | Description |
|------|-------------|
| 1 | Test all files with all root directories |
| 2 | Guess for password file names |
| 3 | Enumerate user names via Apache (/~user) |
| 4 | Enumerate user names via cgiwrap (/cgi-bin/cgiwrap/~user) |
| 5 | Attempt to brute force sub-domain names |
| 6 | Attempt to guess directory names |

```bash
# Enable file mutation
nikto -h http://target.com -mutate 1

# Multiple mutation methods
nikto -h http://target.com -mutate 123456

# Mutation with custom wordlist
nikto -h http://target.com -mutate 1 -mutate-options /path/to/wordlist.txt

# User enumeration via Apache
nikto -h http://target.com -mutate 3
```

### Combined Stealth Scanning

```bash
# Low and slow stealth scan
nikto -h http://target.com \
    -Pause 5 \
    -evasion 147 \
    -timeout 30 \
    -useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    -Tuning 13b \
    -o stealth_scan.txt
```

---

## Database Updates

### Update Nikto Databases

```bash
# Update all databases and plugins
nikto -update

# Check database integrity
nikto -dbcheck
```

### Database Files

Nikto databases are located in the installation directory (typically `/var/lib/nikto/databases/` or `nikto/program/databases/`):

| File | Purpose |
|------|---------|
| `db_tests` | Main vulnerability test database |
| `db_variables` | Variable definitions for tests |
| `db_server_msgs` | Server message patterns |
| `db_outdated` | Outdated software version database |
| `db_realms` | HTTP authentication realm patterns |
| `db_404_strings` | Custom 404 response patterns |
| `db_content_search` | Content search patterns |
| `db_embedded` | Embedded device signatures |
| `db_favicon` | Favicon fingerprint database |
| `db_headers` | HTTP header analysis patterns |
| `db_httpoptions` | HTTP method testing database |
| `db_multiple_index` | Multiple index file checks |
| `db_parked_strings` | Parked domain detection patterns |
| `db_dictionary` | Dictionary attack wordlist |

### Manual Database Location

```bash
# Find database location
nikto -list-plugins 2>&1 | head -5

# Common locations
ls -la /var/lib/nikto/databases/
ls -la /usr/share/nikto/databases/
ls -la ~/nikto/program/databases/
```

### Database Format

Test database entries follow this format:
```
"testid","OSVDB-ID","Tuning Type","URI","HTTP Method","Match 1","Match 1 Or","Match 1 And","Fail 1","Fail 2","Summary","HTTP Data","Headers"
```

---

## Plugin System

### List Available Plugins

```bash
nikto -list-plugins
```

### Core Plugins

| Plugin | Description |
|--------|-------------|
| `@@DEFAULT` | Default set of plugins |
| `@@ALL` | All available plugins |
| `@@NONE` | No plugins (headers only) |
| `apacheusers` | Enumerate Apache users via /~username |
| `cgi` | CGI script testing |
| `cookies` | Cookie security analysis |
| `dictionary` | Dictionary-based file discovery |
| `drupal` | Drupal CMS specific checks |
| `favicon` | Favicon fingerprinting |
| `headers` | HTTP header security analysis |
| `httpoptions` | HTTP method testing (OPTIONS, etc.) |
| `msgs` | Server message/error testing |
| `outdated` | Outdated software detection |
| `parked` | Parked domain detection |
| `paths` | Path-based vulnerability testing |
| `robots` | robots.txt analysis and testing |
| `shellshock` | Shellshock vulnerability testing |
| `siebel` | Siebel CRM specific testing |
| `ssl` | SSL/TLS certificate and config testing |
| `strutshock` | Apache Struts vulnerability testing |
| `tests` | Standard vulnerability tests |

### Plugin Usage Examples

```bash
# Run all plugins (comprehensive scan)
nikto -h http://target.com -Plugins "@@ALL"

# Run only default plugins
nikto -h http://target.com -Plugins "@@DEFAULT"

# Headers only (quick fingerprint)
nikto -h http://target.com -Plugins "@@NONE"

# Specific plugins (semicolon-separated)
nikto -h http://target.com -Plugins "robots;headers;httpoptions"

# SSL-focused scan
nikto -h https://target.com -Plugins "ssl;headers"

# CMS detection
nikto -h http://target.com -Plugins "drupal;headers"

# Shellshock vulnerability check
nikto -h http://target.com -Plugins "shellshock"

# Cookie and header security analysis
nikto -h http://target.com -Plugins "cookies;headers"

# Apache user enumeration
nikto -h http://target.com -Plugins "apacheusers"

# Dictionary-based discovery
nikto -h http://target.com -Plugins "dictionary"
```

### Plugin Information

```bash
# Get detailed plugin information
nikto -list-plugins | grep -A5 "Plugin:"

# Show plugin options
nikto -list-plugins 2>&1 | less
```

---

## Configuration File

### Configuration File Location

Nikto uses `nikto.conf` for default settings:

```bash
# Common locations
/etc/nikto.conf
/usr/share/nikto/nikto.conf
~/nikto/program/nikto.conf
```

### Key Configuration Options

```ini
# nikto.conf example settings

# Default User-Agent string
USERAGENT=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36

# Proxy settings
PROXYHOST=127.0.0.1
PROXYPORT=8080
PROXYUSER=username
PROXYPASS=password

# Static cookies to send with every request
STATIC-COOKIE=session=abc123; auth=token

# Default timeout
TIMEOUT=10

# Pause between requests
PAUSE=0

# Maximum time for entire scan
MAXTIME=0

# Enable/disable plugins by default
DEFAULTPLUGINS=@@DEFAULT

# Automatically update databases
AUTO-UPDATE=no

# SSL settings
CHECKSSLCERT=no

# Rate limiting
REQSPERSEC=0
```

### Custom User-Agent

```bash
# Command line
nikto -h http://target.com -useragent "Custom Agent String"

# Or set in nikto.conf
# USERAGENT=Custom Agent String
```

### Custom Headers

```bash
# Add custom headers via configuration file
# In nikto.conf:
# STATIC-COOKIE=sessionid=abc123; JSESSIONID=xyz789
```

---

## Practical Scanning Examples

### Basic Web Server Scan

```bash
# Simple scan
nikto -h http://target.com

# With output
nikto -h http://target.com -o scan.txt

# HTML report
nikto -h http://target.com -o report.html -Format htm
```

### CTF Web Server Enumeration

```bash
# Quick comprehensive scan (exclude DoS)
nikto -h http://target.com -Tuning x6 -o ctf_scan.html -Format htm

# Focus on info disclosure and interesting files
nikto -h http://target.com -Tuning 13b -Display V

# Check all CGI directories
nikto -h http://target.com -Cgidirs all -Tuning x6
```

### Penetration Testing Workflow

```bash
# 1. Initial reconnaissance
nikto -h http://target.com -Plugins "headers;robots;httpoptions" -Display V

# 2. Safe comprehensive scan
nikto -h http://target.com -Tuning x6 -o initial_scan.html -Format htm

# 3. Focused vulnerability testing
nikto -h http://target.com -Tuning 4589a -o vuln_scan.json -Format json

# 4. Full scan with all plugins
nikto -h http://target.com -Plugins "@@ALL" -Tuning x6 -Pause 1 -o full_scan.xml -Format xml
```

### HTTPS/SSL Target Scanning

```bash
# Basic HTTPS scan
nikto -h https://target.com

# SSL on non-standard port
nikto -h target.com -p 8443 -ssl

# SSL-focused security assessment
nikto -h https://target.com -Plugins "ssl;headers;cookies" -o ssl_report.html -Format htm

# Ignore certificate errors (self-signed)
nikto -h https://target.com -nossl
```

### Authenticated Application Scan

```bash
# Basic auth protected area
nikto -h http://target.com/admin/ -id admin:password

# Authenticated with comprehensive tuning
nikto -h http://target.com -id user:pass -root /secure/ -Tuning x6 -o auth_scan.html -Format htm

# NTLM authentication
nikto -h http://target.com -id username:password:DOMAIN
```

### Scanning Through Proxy

```bash
# Through Burp Suite for traffic analysis
nikto -h http://target.com -useproxy http://127.0.0.1:8080

# Through Tor for anonymity
nikto -h http://target.com -useproxy socks5://127.0.0.1:9050

# Through corporate proxy
nikto -h http://target.com -useproxy http://proxy.corp.local:3128
```

### Internal Network Scanning

```bash
# Scan internal host via SSH tunnel/proxy
nikto -h http://internal.target.local -useproxy socks5://127.0.0.1:1080

# Scan multiple internal hosts
for ip in 192.168.1.{10..20}; do
    nikto -h http://$ip -o "scan_${ip}.txt" -Tuning x6
done

# With virtual host header
nikto -h 10.10.10.10 -vhost internal.corp.local -Tuning x6
```

### API Endpoint Scanning

```bash
# API server scan
nikto -h http://api.target.com -root /api/v1/ -Tuning 13489

# With API authentication
nikto -h http://api.target.com -root /api/ -id apiuser:apikey

# JSON output for automation
nikto -h http://api.target.com -root /api/ -o api_scan.json -Format json
```

### Multiple Target Scanning

```bash
# From file (one target per line)
# targets.txt:
# http://target1.com
# http://target2.com:8080
# https://target3.com

while read target; do
    output=$(echo "$target" | tr '/:' '_')
    nikto -h "$target" -o "scan_${output}.txt" -Tuning x6
done < targets.txt

# Parallel scanning with GNU parallel
parallel -j 4 nikto -h {} -o scan_{#}.txt -Tuning x6 :::: targets.txt
```

### Stealth Scanning

```bash
# Low and slow for IDS evasion
nikto -h http://target.com \
    -Pause 5 \
    -evasion 147 \
    -timeout 30 \
    -useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    -Tuning 13b \
    -o stealth_scan.txt

# Minimal footprint reconnaissance
nikto -h http://target.com \
    -Plugins "@@NONE" \
    -Pause 3 \
    -Display 1234
```

### Bug Bounty Workflow

```bash
# 1. Quick recon scan
nikto -h https://target.com -Plugins "headers;robots;cookies" -Display V

# 2. Focused vulnerability scan
nikto -h https://target.com -Tuning 4589a -evasion 1 -Pause 1 -o vuln_scan.json -Format json

# 3. Parse high severity findings
cat vuln_scan.json | jq '.vulnerabilities[] | select(.OSVDB != "0")'
```

### WordPress/CMS Scanning

```bash
# Drupal CMS
nikto -h http://target.com -Plugins "drupal;headers;robots"

# Generic CMS scan
nikto -h http://target.com -Tuning 12be -Cgidirs all

# With plugin directory focus
nikto -h http://target.com -root /wp-content/plugins/ -Tuning 13
```

---

## Command Reference

### Complete Option Reference

| Option | Description |
|--------|-------------|
| `-h, -host <target>` | Target host, IP, or URL |
| `-p, -port <ports>` | Port(s) to scan (default: 80) |
| `-ssl` | Force SSL mode |
| `-nossl` | Disable SSL certificate checks |
| `-sslversion <ver>` | Specify SSL version |
| `-vhost <hostname>` | Virtual host header value |
| `-root <path>` | Prepend path to all requests |
| `-id <user:pass>` | HTTP authentication credentials |
| `-useproxy <url>` | Proxy URL |
| `-Tuning <options>` | Scan tuning options |
| `-Plugins <list>` | Plugins to use |
| `-Cgidirs <dirs>` | CGI directories |
| `-o, -output <file>` | Output file path |
| `-Format <format>` | Output format |
| `-Display <options>` | Display options |
| `-evasion <options>` | IDS evasion options |
| `-mutate <options>` | Mutation options |
| `-mutate-options <file>` | Mutation wordlist |
| `-Pause <seconds>` | Pause between requests |
| `-timeout <seconds>` | Request timeout |
| `-maxtime <seconds>` | Maximum scan time |
| `-until <time>` | Run until time (HH:MM:SS) |
| `-useragent <string>` | Custom User-Agent |
| `-update` | Update databases |
| `-dbcheck` | Check database integrity |
| `-list-plugins` | List available plugins |
| `-Version` | Show version |
| `-Help` | Show help |

### Quick Reference Commands

```bash
# Version and help
nikto -Version
nikto -Help

# Database management
nikto -update
nikto -dbcheck
nikto -list-plugins

# Basic scans
nikto -h http://target.com
nikto -h https://target.com
nikto -h target.com -p 8080

# Safe comprehensive scan
nikto -h http://target.com -Tuning x6 -o report.html -Format htm

# Stealth scan
nikto -h http://target.com -Pause 3 -evasion 147 -Tuning 13

# Authenticated scan
nikto -h http://target.com -id user:pass -root /admin/

# Through proxy
nikto -h http://target.com -useproxy http://127.0.0.1:8080

# SSL analysis
nikto -h https://target.com -Plugins "ssl;headers"
```

---

## Resources

### Official Documentation

- Official Website: https://cirt.net/Nikto2
- GitHub Repository: https://github.com/sullo/nikto
- Wiki: https://github.com/sullo/nikto/wiki
- Plugin Development: https://github.com/sullo/nikto/wiki/Plugin-Development

### Related Tools

| Tool | Purpose |
|------|---------|
| Nmap | Initial port scanning and service discovery |
| Gobuster | Directory and file brute-forcing |
| Feroxbuster | Fast directory enumeration |
| Burp Suite | Web proxy and manual testing |
| OWASP ZAP | Web application security scanner |
| Nuclei | Template-based vulnerability scanning |
| WhatWeb | Web technology fingerprinting |
| Wappalyzer | Technology detection |

### Complementary Scanning Workflow

```bash
# 1. Port scan with Nmap
nmap -sV -p 80,443,8080,8443 target.com

# 2. Web server fingerprinting with Nikto
nikto -h http://target.com -Plugins "headers;robots;httpoptions"

# 3. Directory enumeration with Gobuster
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt

# 4. Vulnerability scan with Nikto
nikto -h http://target.com -Tuning x6 -o nikto_report.html -Format htm

# 5. Deep testing with Burp Suite
nikto -h http://target.com -useproxy http://127.0.0.1:8080
```
