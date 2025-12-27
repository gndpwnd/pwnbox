# Gobuster Modes - Comprehensive Guide

## Table of Contents

- [Overview](#overview)
- [Global Options](#global-options)
- [Dir Mode](#dir-mode)
- [DNS Mode](#dns-mode)
- [VHost Mode](#vhost-mode)
- [Fuzz Mode](#fuzz-mode)
- [S3 Mode](#s3-mode)
- [GCS Mode](#gcs-mode)
- [Comparison with Feroxbuster](#comparison-with-feroxbuster)
- [Wordlist Recommendations](#wordlist-recommendations)

---

## Overview

Gobuster operates in distinct modes, each designed for specific enumeration tasks:

| Mode | Purpose | Target |
|------|---------|--------|
| `dir` | Directory/file brute-forcing | Web servers |
| `dns` | DNS subdomain enumeration | DNS servers |
| `vhost` | Virtual host discovery | Web servers |
| `fuzz` | General-purpose fuzzing | Any URL parameter |
| `s3` | Amazon S3 bucket enumeration | AWS S3 |
| `gcs` | Google Cloud Storage enumeration | GCP Storage |
| `tftp` | TFTP file enumeration | TFTP servers |

---

## Global Options

These options are available across all modes:

```
-h, --help              Help for gobuster
-z, --no-progress       Don't display progress
-o, --output string     Output file to write results
-q, --quiet             Don't print the banner and other noise
-t, --threads int       Number of concurrent threads (default 10)
-v, --verbose           Verbose output (errors)
--delay duration        Time each thread waits between requests (e.g., 1500ms)
--wordlist-offset int   Resume from a given position in the wordlist
```

---

## Dir Mode

### Description

Directory/file enumeration mode discovers hidden directories and files on web servers by brute-forcing paths from a wordlist.

### Syntax

```bash
gobuster dir -u <URL> -w <WORDLIST> [options]
```

### Key Flags

| Flag | Description |
|------|-------------|
| `-u, --url` | Target URL (required) |
| `-w, --wordlist` | Path to wordlist (required) |
| `-x, --extensions` | File extensions to search (comma-separated) |
| `-s, --status-codes` | Positive status codes (default: 200,204,301,302,307,401,403,405,500) |
| `-b, --status-codes-blacklist` | Negative status codes to exclude |
| `-e, --expanded` | Expanded mode, print full URLs |
| `-r, --follow-redirect` | Follow redirects |
| `-k, --no-tls-validation` | Skip TLS certificate verification |
| `-n, --no-status` | Don't print status codes |
| `-P, --password` | Password for Basic Auth |
| `-U, --username` | Username for Basic Auth |
| `-H, --headers` | Specify HTTP headers (can use multiple times) |
| `-c, --cookies` | Cookies to use for requests |
| `-a, --useragent` | Set the User-Agent string |
| `-m, --method` | HTTP method (default: GET) |
| `-d, --discover-backup` | Also search for backup files |
| `--exclude-length` | Exclude results by response length |
| `--timeout` | HTTP timeout (default: 10s) |
| `--proxy` | Proxy URL (e.g., http://127.0.0.1:8080) |
| `--random-agent` | Use a random User-Agent |
| `--retry` | Number of retries for failed requests |
| `--retry-attempts` | Number of retry attempts |
| `--add-slash` | Append / to each request |

### Practical Examples

#### Basic Directory Scan

```bash
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt
```

#### Scan with File Extensions

```bash
# Common web extensions
gobuster dir -u http://target.com -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -x php,html,txt,js,css

# PHP-specific application
gobuster dir -u http://target.com -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -x php,phtml,php3,php4,php5,phps,inc

# ASP.NET application
gobuster dir -u http://target.com -w wordlist.txt -x aspx,asp,ashx,asmx,config

# Java application
gobuster dir -u http://target.com -w wordlist.txt -x jsp,jsf,do,action

# Backup file discovery
gobuster dir -u http://target.com -w wordlist.txt -x bak,old,backup,~,swp,orig,save
```

#### Status Code Filtering

```bash
# Only show 200 OK responses
gobuster dir -u http://target.com -w wordlist.txt -s 200

# Include redirects and errors
gobuster dir -u http://target.com -w wordlist.txt -s 200,301,302,307,401,403,500

# Blacklist specific codes (show everything except 404)
gobuster dir -u http://target.com -w wordlist.txt -b 404

# Combine: show 200,301,403 but not 404
gobuster dir -u http://target.com -w wordlist.txt -s 200,301,403 -b 404
```

#### Filtering by Response Length

```bash
# Exclude responses with specific content length (useful for custom 404 pages)
gobuster dir -u http://target.com -w wordlist.txt --exclude-length 1234

# Multiple lengths
gobuster dir -u http://target.com -w wordlist.txt --exclude-length 0,1234,5678
```

#### Authentication

```bash
# Basic authentication
gobuster dir -u http://target.com -w wordlist.txt -U admin -P password123

# Cookie-based authentication
gobuster dir -u http://target.com -w wordlist.txt -c "session=abc123; token=xyz789"

# Custom headers (Bearer token)
gobuster dir -u http://target.com -w wordlist.txt -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."

# Multiple headers
gobuster dir -u http://target.com -w wordlist.txt -H "X-Custom-Header: value" -H "X-Another: value2"
```

#### Rate Limiting and Performance

```bash
# Increase threads for faster scanning
gobuster dir -u http://target.com -w wordlist.txt -t 50

# Add delay between requests (WAF evasion)
gobuster dir -u http://target.com -w wordlist.txt --delay 100ms

# Slower, stealthier scan
gobuster dir -u http://target.com -w wordlist.txt -t 5 --delay 500ms

# Set timeout for slow servers
gobuster dir -u http://target.com -w wordlist.txt --timeout 30s
```

#### Proxy and TLS Options

```bash
# Through Burp Suite
gobuster dir -u https://target.com -w wordlist.txt --proxy http://127.0.0.1:8080 -k

# Through SOCKS proxy
gobuster dir -u http://target.com -w wordlist.txt --proxy socks5://127.0.0.1:1080

# Skip TLS verification for self-signed certs
gobuster dir -u https://target.com -w wordlist.txt -k
```

#### Output Options

```bash
# Save to file
gobuster dir -u http://target.com -w wordlist.txt -o results.txt

# Expanded URLs in output
gobuster dir -u http://target.com -w wordlist.txt -e -o results.txt

# Quiet mode (no banner)
gobuster dir -u http://target.com -w wordlist.txt -q -o results.txt
```

#### Advanced Combinations

```bash
# Full scan with extensions, auth, filtering
gobuster dir -u https://target.com \
  -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt \
  -x php,html,js,txt \
  -s 200,301,302,403 \
  -b 404 \
  -H "Authorization: Bearer token" \
  -k \
  -t 30 \
  --delay 50ms \
  -o scan_results.txt

# Backup file hunting
gobuster dir -u http://target.com \
  -w /usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt \
  -x bak,old,~,swp,backup,txt,zip,tar.gz,sql \
  -d \
  -t 20 \
  -o backup_files.txt
```

---

## DNS Mode

### Description

DNS subdomain enumeration discovers subdomains by brute-forcing DNS queries. Each word from the wordlist is prepended to the target domain and resolved.

### Syntax

```bash
gobuster dns -d <DOMAIN> -w <WORDLIST> [options]
```

### Key Flags

| Flag | Description |
|------|-------------|
| `-d, --domain` | Target domain (required) |
| `-w, --wordlist` | Path to wordlist (required) |
| `-r, --resolver` | Use custom DNS server (e.g., 8.8.8.8:53) |
| `-c, --show-cname` | Show CNAME records |
| `-i, --show-ips` | Show IP addresses |
| `--wildcard` | Force continued operation with wildcard results |
| `--timeout` | DNS resolver timeout (default: 1s) |

### Practical Examples

#### Basic Subdomain Enumeration

```bash
gobuster dns -d example.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

#### With IP Address Display

```bash
gobuster dns -d example.com -w subdomains.txt -i
```

#### Custom DNS Server

```bash
# Use Google DNS
gobuster dns -d example.com -w wordlist.txt -r 8.8.8.8:53

# Use Cloudflare DNS
gobuster dns -d example.com -w wordlist.txt -r 1.1.1.1:53

# Use target's authoritative nameserver (more accurate)
gobuster dns -d example.com -w wordlist.txt -r ns1.example.com:53
```

#### Show CNAME Records

```bash
gobuster dns -d example.com -w wordlist.txt -c -i
```

#### High-Performance DNS Scanning

```bash
# Increase threads (DNS is typically fast)
gobuster dns -d example.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t 100 -i

# With custom timeout
gobuster dns -d example.com -w wordlist.txt -t 50 --timeout 2s
```

#### Handle Wildcard Domains

```bash
# Force continue when wildcard is detected
gobuster dns -d example.com -w wordlist.txt --wildcard
```

#### Comprehensive DNS Scan

```bash
gobuster dns -d target.com \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
  -r 8.8.8.8:53 \
  -t 100 \
  -i \
  -c \
  -o dns_results.txt
```

---

## VHost Mode

### Description

Virtual host enumeration discovers virtual hosts on web servers by sending HTTP requests with different Host headers. Unlike DNS mode, this works even when subdomains don't resolve via DNS (internal hosts, development servers).

### Syntax

```bash
gobuster vhost -u <URL> -w <WORDLIST> [options]
```

### Key Flags

| Flag | Description |
|------|-------------|
| `-u, --url` | Target URL (required) |
| `-w, --wordlist` | Path to wordlist (required) |
| `--append-domain` | Append base domain to words (important!) |
| `--domain` | Domain to append (overrides parsed from URL) |
| `--exclude-length` | Exclude results by response length |
| `-r, --follow-redirect` | Follow redirects |
| `-k, --no-tls-validation` | Skip TLS verification |
| `-m, --method` | HTTP method |
| `-H, --headers` | Custom headers |
| `-c, --cookies` | Cookies to use |

### Practical Examples

#### Basic VHost Enumeration

```bash
# Append domain to words (e.g., "admin" becomes "admin.example.com")
gobuster vhost -u http://example.com -w wordlist.txt --append-domain
```

#### Without Domain Appending

```bash
# Wordlist contains full hostnames (e.g., "admin.example.com")
gobuster vhost -u http://10.10.10.10 -w full-hostnames.txt
```

#### Filter by Response Length

```bash
# Exclude default response length (catch unique virtual hosts)
gobuster vhost -u http://target.com -w wordlist.txt --append-domain --exclude-length 12345
```

#### Custom Domain Override

```bash
# Specify domain to append (different from URL)
gobuster vhost -u http://10.10.10.10 -w wordlist.txt --append-domain --domain target.com
```

#### HTTPS with Certificate Bypass

```bash
gobuster vhost -u https://target.com -w wordlist.txt --append-domain -k
```

#### Through Proxy

```bash
gobuster vhost -u http://target.com -w wordlist.txt --append-domain --proxy http://127.0.0.1:8080
```

#### Comprehensive VHost Scan

```bash
gobuster vhost -u http://10.10.10.10 \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  --append-domain \
  --domain target.htb \
  -t 50 \
  --exclude-length 0 \
  -o vhost_results.txt
```

### VHost vs DNS Mode

| Aspect | DNS Mode | VHost Mode |
|--------|----------|------------|
| Mechanism | DNS resolution | HTTP Host header |
| Works on | Public DNS | Any web server |
| Discovers | Resolvable subdomains | Virtual hosts (incl. internal) |
| Use when | Target has public DNS | IP-only access, internal domains |

---

## Fuzz Mode

### Description

General-purpose fuzzing mode replaces the `FUZZ` keyword in URLs with words from the wordlist. Useful for parameter fuzzing, API endpoint discovery, and custom fuzzing scenarios.

### Syntax

```bash
gobuster fuzz -u <URL_WITH_FUZZ> -w <WORDLIST> [options]
```

### Key Flags

| Flag | Description |
|------|-------------|
| `-u, --url` | URL containing FUZZ keyword (required) |
| `-w, --wordlist` | Path to wordlist (required) |
| `-b, --excludestatuscodes` | Status codes to exclude |
| `--exclude-length` | Exclude results by response length |
| `-r, --follow-redirect` | Follow redirects |
| `-k, --no-tls-validation` | Skip TLS verification |
| `-H, --headers` | Custom headers (can contain FUZZ) |
| `-d, --body` | Request body (for POST, can contain FUZZ) |
| `-m, --method` | HTTP method |
| `-c, --cookies` | Cookies (can contain FUZZ) |

### Practical Examples

#### GET Parameter Fuzzing

```bash
# Fuzz parameter values
gobuster fuzz -u "http://target.com/page?id=FUZZ" -w numbers.txt

# Fuzz parameter names
gobuster fuzz -u "http://target.com/page?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt
```

#### Path Segment Fuzzing

```bash
# API version fuzzing
gobuster fuzz -u "http://target.com/api/FUZZ/users" -w versions.txt

# User ID enumeration
gobuster fuzz -u "http://target.com/user/FUZZ/profile" -w user-ids.txt
```

#### Header Fuzzing

```bash
# Fuzz header values
gobuster fuzz -u "http://target.com/admin" -w wordlist.txt -H "X-Custom-Header: FUZZ"

# Fuzz for header-based authentication bypass
gobuster fuzz -u "http://target.com/admin" -w /usr/share/seclists/Miscellaneous/header-bypass.txt -H "X-Forwarded-For: FUZZ"
```

#### POST Body Fuzzing

```bash
# Fuzz login credentials
gobuster fuzz -u "http://target.com/login" \
  -w passwords.txt \
  -m POST \
  -d "username=admin&password=FUZZ" \
  -H "Content-Type: application/x-www-form-urlencoded"

# JSON body fuzzing
gobuster fuzz -u "http://target.com/api/login" \
  -w passwords.txt \
  -m POST \
  -d '{"user":"admin","pass":"FUZZ"}' \
  -H "Content-Type: application/json"
```

#### Filter False Positives

```bash
# Exclude common error codes
gobuster fuzz -u "http://target.com/api/FUZZ" -w wordlist.txt -b 404,400,500

# Exclude by response length
gobuster fuzz -u "http://target.com/?param=FUZZ" -w wordlist.txt --exclude-length 1234
```

#### Cookie Fuzzing

```bash
gobuster fuzz -u "http://target.com/dashboard" -w tokens.txt -c "session=FUZZ"
```

#### Comprehensive Fuzz Example

```bash
gobuster fuzz -u "http://target.com/api/v1/FUZZ" \
  -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt \
  -H "Authorization: Bearer token123" \
  -b 404,401 \
  --exclude-length 0 \
  -t 30 \
  -o fuzz_results.txt
```

---

## S3 Mode

### Description

Amazon S3 bucket enumeration mode discovers publicly accessible S3 buckets by brute-forcing bucket names.

### Syntax

```bash
gobuster s3 -w <WORDLIST> [options]
```

### Key Flags

| Flag | Description |
|------|-------------|
| `-w, --wordlist` | Path to wordlist (required) |
| `-m, --maxfiles` | Max files to list when listing bucket (default: 5) |
| `--debug` | Debug output |

### Practical Examples

#### Basic S3 Enumeration

```bash
gobuster s3 -w /usr/share/seclists/Discovery/Web-Content/common.txt
```

#### Company-Targeted S3 Discovery

```bash
# Create company-specific wordlist
echo -e "companyname\ncompanyname-dev\ncompanyname-prod\ncompanyname-backup\ncompanyname-data" > company-buckets.txt

gobuster s3 -w company-buckets.txt
```

#### With Debug Output

```bash
gobuster s3 -w bucket-names.txt --debug -m 10
```

#### High-Performance S3 Scanning

```bash
gobuster s3 -w /usr/share/seclists/Discovery/Cloud/s3-bucket-names.txt -t 50
```

### Common S3 Wordlist Patterns

```
{company}
{company}-backup
{company}-dev
{company}-development
{company}-prod
{company}-production
{company}-staging
{company}-test
{company}-data
{company}-assets
{company}-logs
{company}-www
{company}-static
{company}-media
{company}-uploads
```

---

## GCS Mode

### Description

Google Cloud Storage bucket enumeration mode discovers publicly accessible GCS buckets by brute-forcing bucket names.

### Syntax

```bash
gobuster gcs -w <WORDLIST> [options]
```

### Key Flags

| Flag | Description |
|------|-------------|
| `-w, --wordlist` | Path to wordlist (required) |
| `-m, --maxfiles` | Max files to list (default: 5) |
| `--debug` | Debug output |

### Practical Examples

#### Basic GCS Enumeration

```bash
gobuster gcs -w bucket-names.txt
```

#### Company-Targeted GCS Discovery

```bash
gobuster gcs -w company-buckets.txt -m 10
```

#### With Debug Output

```bash
gobuster gcs -w /usr/share/seclists/Discovery/Cloud/gcs-bucket-names.txt --debug
```

---

## Comparison with Feroxbuster

### Feature Comparison

| Feature | Gobuster | Feroxbuster |
|---------|----------|-------------|
| **Language** | Go | Rust |
| **Recursive scanning** | No (manual) | Yes (automatic) |
| **Default threads** | 10 | 50 |
| **Modes** | dir, dns, vhost, fuzz, s3, gcs, tftp | dir only |
| **Auto-calibration** | No | Yes |
| **Resume scans** | Limited | Yes (state files) |
| **Response filtering** | By status, length | By status, length, words, lines, regex |
| **Output formats** | Text | Text, JSON |
| **Progress display** | Basic | Rich (real-time stats) |

### When to Use Each

**Use Gobuster when:**
- You need DNS subdomain enumeration
- You need virtual host discovery
- You need S3/GCS bucket enumeration
- You want a simple, focused tool
- You need custom fuzzing (fuzz mode)
- Memory constraints exist

**Use Feroxbuster when:**
- You need recursive directory scanning
- You want automatic recursion handling
- You need advanced filtering options
- You want a richer output format
- You need to pause/resume scans
- You want auto-calibration

### Side-by-Side Examples

#### Directory Enumeration

```bash
# Gobuster
gobuster dir -u http://target.com -w wordlist.txt -x php,html -t 50

# Feroxbuster
feroxbuster -u http://target.com -w wordlist.txt -x php,html -t 50
```

#### With Recursion (Feroxbuster advantage)

```bash
# Feroxbuster (automatic recursion)
feroxbuster -u http://target.com -w wordlist.txt -d 3

# Gobuster (manual - must run for each found directory)
gobuster dir -u http://target.com -w wordlist.txt
gobuster dir -u http://target.com/admin/ -w wordlist.txt
gobuster dir -u http://target.com/api/ -w wordlist.txt
```

#### DNS/VHost (Gobuster advantage)

```bash
# Gobuster only - feroxbuster doesn't have these modes
gobuster dns -d target.com -w subdomains.txt
gobuster vhost -u http://target.com -w vhosts.txt --append-domain
```

---

## Wordlist Recommendations

### Directory/File Enumeration

| Wordlist | Size | Use Case |
|----------|------|----------|
| `/usr/share/wordlists/dirb/common.txt` | ~4.6K | Quick initial scan |
| `/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt` | ~30K | Medium thoroughness |
| `/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt` | ~220K | Comprehensive scan |
| `/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt` | ~1.2M | Exhaustive scan |
| `/usr/share/seclists/Discovery/Web-Content/raft-large-files.txt` | ~37K | File-specific |

### DNS Subdomains

| Wordlist | Size | Use Case |
|----------|------|----------|
| `/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt` | 5K | Quick scan |
| `/usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt` | 20K | Standard scan |
| `/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt` | 110K | Thorough scan |
| `/usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt` | ~2M | Comprehensive |

### Virtual Hosts

| Wordlist | Size | Use Case |
|----------|------|----------|
| `/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt` | 5K | Quick scan |
| `/usr/share/seclists/Discovery/DNS/namelist.txt` | ~1.9K | Curated list |
| `/usr/share/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt` | 100K | Comprehensive |

### API Endpoints

| Wordlist | Use Case |
|----------|----------|
| `/usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt` | REST APIs |
| `/usr/share/seclists/Discovery/Web-Content/api/api-endpoints-res.txt` | Resources |
| `/usr/share/seclists/Discovery/Web-Content/api/actions.txt` | API actions |

### Common File Extensions

```bash
# Web (general)
-x php,html,htm,js,css,txt

# PHP application
-x php,phtml,php3,php4,php5,php7,phps,inc,phar

# ASP.NET application
-x asp,aspx,ashx,asmx,ascx,config,dll

# Java application
-x jsp,jsf,do,action,java,class,jar,war

# Node.js application
-x js,json,ts,mjs

# Backup files
-x bak,backup,old,orig,~,swp,save,copy,tmp,temp

# Configuration files
-x conf,config,ini,env,yml,yaml,xml,json

# Database files
-x sql,db,sqlite,sqlite3,mdb

# Archives
-x zip,tar,tar.gz,tgz,rar,7z,gz
```

---

## Quick Reference

### Common Command Patterns

```bash
# Quick dir scan
gobuster dir -u URL -w /usr/share/wordlists/dirb/common.txt

# Dir with extensions
gobuster dir -u URL -w WORDLIST -x php,html,txt

# Fast DNS enumeration
gobuster dns -d DOMAIN -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -t 100

# VHost discovery
gobuster vhost -u URL -w WORDLIST --append-domain

# API parameter fuzzing
gobuster fuzz -u "URL?param=FUZZ" -w WORDLIST

# S3 bucket hunting
gobuster s3 -w /usr/share/seclists/Discovery/Cloud/s3-bucket-names.txt
```

### Performance Tuning

| Scenario | Settings |
|----------|----------|
| Fast LAN scan | `-t 100` |
| Remote server | `-t 30 --delay 50ms` |
| WAF evasion | `-t 5 --delay 500ms` |
| Stealth mode | `-t 2 --delay 2s` |
| High latency | `-t 10 --timeout 30s` |
