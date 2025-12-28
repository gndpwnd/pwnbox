# Nikto - Scanning Techniques

## Table of Contents

- [Basic Scans](#basic-scans)
- [Tuning Options](#tuning-options)
- [Plugin Selection](#plugin-selection)
- [SSL/TLS Scanning](#ssltls-scanning)
- [Authentication](#authentication)
- [Proxy Usage](#proxy-usage)
- [Custom Headers](#custom-headers)
- [Evasion Techniques](#evasion-techniques)
- [Database Updates](#database-updates)
- [Output Customization](#output-customization)
- [Practical Examples](#practical-examples)

---

## Basic Scans

### Standard Scan

```bash
# Basic scan against HTTP target
nikto -h http://target.com

# HTTPS target
nikto -h https://target.com

# Target with port
nikto -h target.com -p 8080

# IP address target
nikto -h 192.168.1.100
```

### Multi-Port Scanning

```bash
# Scan multiple ports
nikto -h target.com -p 80,443,8080,8443

# Scan port range
nikto -h target.com -p 80-90

# Common web ports
nikto -h target.com -p 80,443,8000,8080,8443,8888
```

### Virtual Host Scanning

```bash
# Scan specific virtual host
nikto -h 192.168.1.100 -vhost www.target.com

# Scan virtual host over SSL
nikto -h 192.168.1.100 -vhost secure.target.com -ssl
```

### Directory Targeting

```bash
# Scan specific directory
nikto -h http://target.com/webapp/

# Set root directory for all requests
nikto -h http://target.com -root /api/v1/
```

---

## Tuning Options

The `-Tuning` option controls which test categories to include or exclude.

### Tuning Categories

| Number | Category | Description |
|--------|----------|-------------|
| 0 | File Upload | Forms allowing file uploads |
| 1 | Interesting File/Logs | Logs, backup files, configs |
| 2 | Misconfiguration/Default | Default files, misconfigs |
| 3 | Information Disclosure | Paths revealing information |
| 4 | Injection (XSS/Script/HTML) | XSS and injection points |
| 5 | Remote File Retrieval (Server) | Server-side file retrieval |
| 6 | Denial of Service | DoS vulnerabilities |
| 7 | Remote File Retrieval (Web) | Web-based file retrieval |
| 8 | Command Execution | Remote shell/command exec |
| 9 | SQL Injection | SQL injection tests |
| a | Authentication Bypass | Auth bypass techniques |
| b | Software Identification | Installed software detection |
| c | Remote Source Inclusion | RFI vulnerabilities |
| d | WebService | Web service checks |
| e | Administrative Console | Admin interfaces |
| x | Reverse Tuning | Exclude specified options |

### Tuning Examples

```bash
# Include only specific tests
nikto -h http://target.com -Tuning 1234

# Focus on injection vulnerabilities (XSS, SQLi)
nikto -h http://target.com -Tuning 49

# Focus on information disclosure
nikto -h http://target.com -Tuning 13

# Check for command execution and SQLi
nikto -h http://target.com -Tuning 89

# Authentication and admin console checks
nikto -h http://target.com -Tuning ae

# Software identification only
nikto -h http://target.com -Tuning b

# Exclude DoS tests (safer scan)
nikto -h http://target.com -Tuning x6

# Exclude multiple categories
nikto -h http://target.com -Tuning x68

# Everything except DoS and file upload
nikto -h http://target.com -Tuning x06
```

### Safe Scanning (Production)

```bash
# Safe scan - exclude DoS tests
nikto -h http://target.com -Tuning x6

# Minimal footprint - info disclosure only
nikto -h http://target.com -Tuning 13b
```

---

## Plugin Selection

### List Available Plugins

```bash
nikto -list-plugins
```

### Common Plugins

| Plugin | Description |
|--------|-------------|
| `@@DEFAULT` | Default set of plugins |
| `@@ALL` | All available plugins |
| `@@NONE` | No plugins (headers only) |
| `apacheusers` | Apache user enumeration |
| `cgi` | CGI script testing |
| `cookies` | Cookie analysis |
| `dictionary` | Dictionary-based file search |
| `drupal` | Drupal CMS checks |
| `favicon` | Favicon fingerprinting |
| `headers` | HTTP header analysis |
| `httpoptions` | HTTP methods testing |
| `msgs` | Server message testing |
| `outdated` | Outdated software detection |
| `parked` | Parked domain detection |
| `paths` | Path-based testing |
| `robots` | robots.txt analysis |
| `shellshock` | Shellshock vulnerability |
| `siebel` | Siebel CRM testing |
| `ssl` | SSL/TLS testing |
| `strutshock` | Apache Struts testing |
| `tests` | Standard vulnerability tests |

### Plugin Usage

```bash
# Run all plugins (comprehensive)
nikto -h http://target.com -Plugins "@@ALL"

# Run only default plugins
nikto -h http://target.com -Plugins "@@DEFAULT"

# Headers only (quick fingerprint)
nikto -h http://target.com -Plugins "@@NONE"

# Specific plugins
nikto -h http://target.com -Plugins "robots;headers;httpoptions"

# SSL-focused scan
nikto -h https://target.com -Plugins "ssl;headers"

# CMS detection
nikto -h http://target.com -Plugins "drupal;headers"

# Shellshock check
nikto -h http://target.com -Plugins "shellshock"

# Cookie and header analysis
nikto -h http://target.com -Plugins "cookies;headers"
```

---

## SSL/TLS Scanning

### Basic SSL Scanning

```bash
# Force SSL on standard port
nikto -h target.com -ssl

# SSL on custom port
nikto -h target.com -p 8443 -ssl

# HTTPS URL (auto-detects SSL)
nikto -h https://target.com
```

### SSL-Specific Options

```bash
# Disable SSL verification (self-signed certs)
nikto -h https://target.com -nossl

# Specify SSL version
nikto -h target.com -ssl -sslversion TLSv1_2

# Check multiple SSL ports
nikto -h target.com -p 443,8443 -ssl
```

### SSL Plugin Analysis

```bash
# Detailed SSL analysis
nikto -h https://target.com -Plugins "ssl"

# SSL with headers
nikto -h https://target.com -Plugins "ssl;headers"
```

### Common SSL Findings

Nikto checks for:
- Expired certificates
- Self-signed certificates
- Weak cipher suites
- SSL/TLS version issues
- Certificate hostname mismatches
- HSTS header presence

---

## Authentication

### Basic Authentication

```bash
# HTTP Basic Auth
nikto -h http://target.com -id admin:password

# With domain (NTLM)
nikto -h http://target.com -id admin:password:domain

# URL-encoded password
nikto -h http://target.com -id "admin:p%40ssw0rd"
```

### Authentication Types

```bash
# Basic authentication (default)
nikto -h http://target.com -id user:pass

# NTLM authentication
nikto -h http://target.com -id user:pass:DOMAIN

# Digest authentication (auto-detected)
nikto -h http://target.com -id user:pass
```

### Authenticated Directory Scan

```bash
# Scan authenticated area
nikto -h http://target.com/admin/ -id admin:password

# With specific root path
nikto -h http://target.com -root /secure/ -id user:pass
```

---

## Proxy Usage

### HTTP Proxy

```bash
# Through HTTP proxy
nikto -h http://target.com -useproxy http://127.0.0.1:8080

# Through Burp Suite
nikto -h http://target.com -useproxy http://127.0.0.1:8080

# Through corporate proxy
nikto -h http://target.com -useproxy http://proxy.corp.com:3128
```

### SOCKS Proxy

```bash
# SOCKS4 proxy
nikto -h http://target.com -useproxy socks4://127.0.0.1:1080

# SOCKS5 proxy
nikto -h http://target.com -useproxy socks5://127.0.0.1:1080

# Through Tor
nikto -h http://target.com -useproxy socks5://127.0.0.1:9050
```

### Authenticated Proxy

```bash
# Proxy with credentials
nikto -h http://target.com -useproxy http://user:pass@proxy.com:8080
```

### Proxychains Integration

```bash
# Using proxychains for SOCKS support
proxychains4 nikto -h http://internal-target.com
```

---

## Custom Headers

### Adding Headers

```bash
# Custom User-Agent
nikto -h http://target.com -useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# Custom header via config
# Edit nikto.conf: USERAGENT=CustomAgent
```

### Cookie Injection

```bash
# Pass cookies (via config or command)
# Add to nikto.conf: STATIC-COOKIE=sessionid=abc123
```

### Host Header Manipulation

```bash
# Custom Host header for vhost
nikto -h 192.168.1.100 -vhost internal.target.com
```

---

## Evasion Techniques

The `-evasion` option helps bypass IDS/IPS detection.

### Evasion Methods

| Number | Technique | Description |
|--------|-----------|-------------|
| 1 | Random URI encoding | Encode characters randomly |
| 2 | Directory self-reference | Add `/./ ` to path |
| 3 | Premature URL ending | Use `%00` in requests |
| 4 | Prepend long random string | Add random data to URL |
| 5 | Fake parameter | Add fake query parameter |
| 6 | TAB as request spacer | Use TAB instead of space |
| 7 | Random case sensitivity | Randomize URL case |
| 8 | Windows directory separator | Use backslash `\` |

### Evasion Examples

```bash
# Single evasion technique
nikto -h http://target.com -evasion 1

# Multiple techniques
nikto -h http://target.com -evasion 1234

# All evasion techniques
nikto -h http://target.com -evasion 12345678

# Common IDS bypass combination
nikto -h http://target.com -evasion 147

# Directory-based evasion
nikto -h http://target.com -evasion 28
```

### Timing-Based Evasion

```bash
# Add delay between requests
nikto -h http://target.com -Pause 2

# Slow scan for stealth
nikto -h http://target.com -Pause 5 -evasion 1

# Timeout configuration
nikto -h http://target.com -timeout 15
```

### Mutation Techniques

```bash
# Mutation for file guessing
nikto -h http://target.com -mutate 1

# Multiple mutation methods
nikto -h http://target.com -mutate 123456

# Mutation with dictionary
nikto -h http://target.com -mutate 1 -mutate-options /path/to/wordlist.txt
```

---

## Database Updates

### Update Nikto Databases

```bash
# Update all databases
nikto -update

# Check database integrity
nikto -dbcheck
```

### Database Files

Located in nikto's installation directory:

| File | Purpose |
|------|---------|
| `db_tests` | Main test database |
| `db_variables` | Variable definitions |
| `db_server_msgs` | Server message patterns |
| `db_outdated` | Outdated software versions |
| `db_realms` | Authentication realms |
| `db_404_strings` | 404 response patterns |
| `db_content_search` | Content search patterns |
| `db_embedded` | Embedded device checks |
| `db_favicon` | Favicon fingerprints |
| `db_headers` | Header analysis patterns |
| `db_httpoptions` | HTTP options tests |
| `db_multiple_index` | Multiple index files |
| `db_parked_strings` | Parked domain patterns |

---

## Output Customization

### Display Options

The `-Display` option controls console output:

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

### Display Examples

```bash
# Show redirects and cookies
nikto -h http://target.com -Display 12

# Verbose with progress
nikto -h http://target.com -Display VP

# Debug mode
nikto -h http://target.com -Display D

# Show authentication-required URLs
nikto -h http://target.com -Display 4

# All display options
nikto -h http://target.com -Display 1234DEPV

# Scrub sensitive info for reporting
nikto -h http://target.com -Display S -o report.txt
```

### Output File Formats

```bash
# Plain text
nikto -h http://target.com -o results.txt -Format txt

# HTML report
nikto -h http://target.com -o report.html -Format htm

# CSV for spreadsheets
nikto -h http://target.com -o scan.csv -Format csv

# XML for parsing
nikto -h http://target.com -o scan.xml -Format xml

# JSON for automation
nikto -h http://target.com -o scan.json -Format json

# SQL for database import
nikto -h http://target.com -o scan.sql -Format sql

# Nessus NBE format
nikto -h http://target.com -o scan.nbe -Format nbe

# Auto-detect from extension
nikto -h http://target.com -o scan.xml
nikto -h http://target.com -o scan.json
```

### Time Limits

```bash
# Maximum scan time (seconds)
nikto -h http://target.com -maxtime 3600

# Run until specific time
nikto -h http://target.com -until 23:00:00
```

---

## Practical Examples

### CTF Web Server Scan

```bash
# Quick comprehensive scan
nikto -h http://target.com -Tuning x6 -o ctf_scan.html -Format htm

# Focus on info disclosure and interesting files
nikto -h http://target.com -Tuning 13b -Display V
```

### Penetration Testing

```bash
# Safe production scan
nikto -h https://target.com -ssl -Tuning x6 -Pause 1 -o pentest_scan.xml -Format xml

# Comprehensive with all plugins
nikto -h http://target.com -Plugins "@@ALL" -Tuning x6 -o full_scan.html -Format htm
```

### Internal Network Scan

```bash
# Scan through SOCKS proxy
nikto -h http://internal.target.local -useproxy socks5://127.0.0.1:1080 -Pause 2

# Multiple internal hosts
for ip in 192.168.1.{10..20}; do
    nikto -h http://$ip -o "scan_$ip.txt" -Tuning x6
done
```

### API Endpoint Scanning

```bash
# API server scan
nikto -h http://api.target.com -root /api/v1/ -Tuning 13489

# With authentication
nikto -h http://api.target.com -root /api/ -id apiuser:apikey
```

### Multiple Targets from File

```bash
# Create target file (one per line)
# targets.txt:
# http://target1.com
# http://target2.com:8080
# https://target3.com

# Scan all targets
while read target; do
    nikto -h "$target" -o "scan_$(echo $target | tr '/:' '_').txt"
done < targets.txt
```

### Bug Bounty Workflow

```bash
# 1. Quick recon scan
nikto -h https://target.com -Plugins "headers;robots;cookies" -Display V

# 2. Focused vulnerability scan
nikto -h https://target.com -Tuning 4589a -evasion 1 -Pause 1 -o vuln_scan.json -Format json

# 3. Parse results
cat vuln_scan.json | jq '.vulnerabilities[] | select(.severity == "High")'
```

### Stealth Scanning

```bash
# Low and slow scan
nikto -h http://target.com \
    -Pause 5 \
    -evasion 147 \
    -timeout 30 \
    -useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    -Tuning 13b \
    -o stealth_scan.txt
```

### CGI Directory Focus

```bash
# Scan all CGI directories
nikto -h http://target.com -Cgidirs all

# Custom CGI directories
nikto -h http://target.com -Cgidirs "/cgi-bin/,/scripts/,/cgi/"

# Skip CGI scanning
nikto -h http://target.com -Cgidirs none
```

---

## Quick Reference

### Common Flag Combinations

```bash
# Quick scan
nikto -h URL -Tuning 13b

# Safe comprehensive
nikto -h URL -Tuning x6 -Plugins "@@ALL" -o report.html -Format htm

# Stealth
nikto -h URL -Pause 3 -evasion 147 -Tuning 13

# Authenticated
nikto -h URL -id user:pass -root /admin/

# Through proxy
nikto -h URL -useproxy http://127.0.0.1:8080 -ssl

# SSL focus
nikto -h URL -ssl -Plugins "ssl;headers"
```

### Tuning Quick Reference

| Goal | Tuning |
|------|--------|
| Information disclosure | `13` |
| Injection vulnerabilities | `49` |
| Command/code execution | `89c` |
| Authentication issues | `ae` |
| Software identification | `b` |
| Safe scan (no DoS) | `x6` |
| Everything except DoS | `x6` |

---

## Resources

- [Official Documentation](https://cirt.net/Nikto2)
- [GitHub Repository](https://github.com/sullo/nikto)
- [Wiki](https://github.com/sullo/nikto/wiki)
- [Plugin Development](https://github.com/sullo/nikto/wiki/Plugin-Development)
