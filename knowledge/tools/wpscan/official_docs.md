---
title: "WPScan - Official Documentation Reference"
category: "tools"
tags:
  - wordpress
  - cms
  - web-scanner
  - wpscan
last_updated: "2025-12-27"
---

# WPScan - Official Documentation Reference

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [API Token Setup](#api-token-setup)
- [Basic Scanning Options](#basic-scanning-options)
- [Enumeration Modes](#enumeration-modes)
- [Detection Modes](#detection-modes)
- [Password Brute-Forcing](#password-brute-forcing)
- [Plugin Detection](#plugin-detection)
- [Theme Detection](#theme-detection)
- [Vulnerability Detection](#vulnerability-detection)
- [Output Formats](#output-formats)
- [Proxy and Authentication Options](#proxy-and-authentication-options)
- [Advanced Options](#advanced-options)
- [Practical WordPress Pentesting Examples](#practical-wordpress-pentesting-examples)
- [Complete CLI Reference](#complete-cli-reference)

---

## Overview

WPScan is a free, open-source black box WordPress security scanner written in Ruby. It is designed specifically for security professionals and WordPress administrators to test the security of WordPress installations.

**Key Capabilities:**
- WordPress core version detection and vulnerability identification
- Plugin and theme enumeration with version detection
- User enumeration via multiple techniques
- Password brute-force attacks against WordPress login
- Detection of configuration backups and database exports
- Integration with WPVulnDB for comprehensive vulnerability data
- Support for authenticated scanning
- Multiple detection modes for stealth or comprehensive scanning

**Official Resources:**
- GitHub: https://github.com/wpscanteam/wpscan
- WPScan Website: https://wpscan.com/
- WPVulnDB API: https://wpscan.com/api
- Wiki: https://github.com/wpscanteam/wpscan/wiki

---

## Installation

### Ruby Gem Installation (Recommended)

```bash
# Install via RubyGems
gem install wpscan

# Update to latest version
gem update wpscan
```

### Kali Linux

```bash
# WPScan is pre-installed on Kali Linux
# Update to latest version
sudo apt update && sudo apt install wpscan

# Or update via gem
sudo gem update wpscan
```

### Docker Installation

```bash
# Pull the official Docker image
docker pull wpscanteam/wpscan

# Run a scan using Docker
docker run -it --rm wpscanteam/wpscan --url https://target.com

# With API token
docker run -it --rm wpscanteam/wpscan --url https://target.com --api-token YOUR_TOKEN

# Save output to local file
docker run -it --rm -v $(pwd):/output wpscanteam/wpscan \
    --url https://target.com -o /output/report.txt
```

### From Source

```bash
# Clone the repository
git clone https://github.com/wpscanteam/wpscan.git
cd wpscan

# Install dependencies
bundle install

# Run WPScan
ruby wpscan.rb --url https://target.com
```

### Verify Installation

```bash
# Check version
wpscan --version

# Display help
wpscan --help

# Show detailed help with all options
wpscan -hh
```

---

## API Token Setup

WPScan uses the WPVulnDB API to provide vulnerability data for WordPress core, plugins, and themes. Without an API token, WPScan will still function but will not display vulnerability information.

### Obtaining an API Token

1. Register at https://wpscan.com/register
2. Verify your email address
3. Access your API token from the dashboard

### API Token Plans

| Plan | Daily Requests | Use Case |
|------|----------------|----------|
| Free | 25 | Personal use, learning |
| Starter | 75 | Small teams |
| Professional | 300 | Regular penetration testing |
| Enterprise | Unlimited | Continuous scanning, large organizations |

### Configuration Methods

#### Method 1: Command Line

```bash
wpscan --url https://target.com --api-token YOUR_API_TOKEN
```

#### Method 2: Environment Variable

```bash
# Set environment variable
export WPSCAN_API_TOKEN=YOUR_API_TOKEN

# Run scan (token is automatically used)
wpscan --url https://target.com
```

#### Method 3: Configuration File

Create or edit `~/.wpscan/scan.yml`:

```yaml
cli_options:
  api_token: YOUR_API_TOKEN
  # You can also set other default options here
  # format: json
  # verbose: true
```

### Checking API Usage

```bash
# The scan output shows remaining API requests
wpscan --url https://target.com --api-token TOKEN -v

# Look for: "[+] WPVulnDB API OK - X requests remaining"
```

---

## Basic Scanning Options

### Required Options

| Option | Description |
|--------|-------------|
| `--url URL` | The target WordPress URL (required for all scans) |

### Core Scan Options

```bash
# Basic scan
wpscan --url https://target.com

# Scan with API token for vulnerability data
wpscan --url https://target.com --api-token YOUR_TOKEN

# Force scan even if WordPress is not detected
wpscan --url https://target.com --force

# Scan with verbose output
wpscan --url https://target.com -v

# Very verbose (includes HTTP request details)
wpscan --url https://target.com -vv

# Update WPScan database before scanning
wpscan --update && wpscan --url https://target.com
```

### Performance Options

```bash
# Set maximum threads (default: 5)
wpscan --url https://target.com -t 10
wpscan --url https://target.com --max-threads 10

# Throttle requests (milliseconds between requests)
wpscan --url https://target.com --throttle 500

# Set request timeout (seconds)
wpscan --url https://target.com --request-timeout 30

# Set connection timeout (seconds)
wpscan --url https://target.com --connect-timeout 30
```

### Custom WordPress Paths

```bash
# Custom wp-content directory
wpscan --url https://target.com --wp-content-dir custom-content

# Custom plugins directory
wpscan --url https://target.com --wp-plugins-dir custom-content/modules

# Force wp-content directory (ignore detection)
wpscan --url https://target.com --wp-content-dir wp-content --force
```

---

## Enumeration Modes

The `-e` or `--enumerate` flag controls what components WPScan enumerates. Multiple options can be combined with commas.

### Complete Enumeration Options Reference

| Option | Full Name | Description |
|--------|-----------|-------------|
| `vp` | Vulnerable Plugins | Only plugins with known vulnerabilities |
| `ap` | All Plugins | All detected plugins (comprehensive) |
| `p` | Popular Plugins | Plugins from the popular list |
| `vt` | Vulnerable Themes | Only themes with known vulnerabilities |
| `at` | All Themes | All detected themes (comprehensive) |
| `t` | Popular Themes | Themes from the popular list |
| `tt` | Timthumbs | Timthumbs scripts (deprecated thumbnail script) |
| `cb` | Config Backups | Configuration backup files |
| `dbe` | Database Exports | Database export files |
| `u` | Users | User IDs 1-10 (default) |
| `u[1-N]` | Users Range | User IDs from 1 to N (e.g., `u1-100`) |
| `m` | Media IDs | Media attachment IDs 1-100 |
| `m[1-N]` | Media Range | Media IDs from 1 to N (e.g., `m1-1000`) |

### User Enumeration (-e u)

Enumerates WordPress users using multiple techniques:

```bash
# Enumerate users with IDs 1-10 (default)
wpscan --url https://target.com -e u

# Enumerate users with IDs 1-100
wpscan --url https://target.com -e u1-100

# Enumerate users with IDs 1-500
wpscan --url https://target.com -e u1-500
```

**User Enumeration Techniques:**
1. **Author Archives** - Requests `/?author=N` for each user ID
2. **Login Error Messages** - Different responses for valid/invalid usernames
3. **REST API** - Queries `/wp-json/wp/v2/users` endpoint
4. **RSS Feed** - Parses author information from RSS/Atom feeds
5. **Yoast SEO Sitemap** - Checks author sitemaps if plugin is present

### Plugin Enumeration (-e p, -e vp, -e ap)

```bash
# Enumerate popular plugins only (fast)
wpscan --url https://target.com -e p

# Enumerate all plugins (comprehensive, slow)
wpscan --url https://target.com -e ap

# Enumerate only vulnerable plugins (requires API token)
wpscan --url https://target.com -e vp --api-token TOKEN
```

### Theme Enumeration (-e t, -e vt, -e at)

```bash
# Enumerate popular themes only (fast)
wpscan --url https://target.com -e t

# Enumerate all themes (comprehensive, slow)
wpscan --url https://target.com -e at

# Enumerate only vulnerable themes (requires API token)
wpscan --url https://target.com -e vt --api-token TOKEN
```

### Other Enumeration Options

```bash
# Check for configuration backup files
wpscan --url https://target.com -e cb
# Checks: wp-config.php~, wp-config.php.bak, wp-config.php.old, etc.

# Check for database export files
wpscan --url https://target.com -e dbe
# Checks: *.sql files in common locations

# Check for timthumb scripts
wpscan --url https://target.com -e tt

# Enumerate media attachments
wpscan --url https://target.com -e m
wpscan --url https://target.com -e m1-1000
```

### Combined Enumeration

```bash
# Comprehensive enumeration (recommended for assessments)
wpscan --url https://target.com -e ap,at,u1-100 --api-token TOKEN

# Full enumeration with all checks
wpscan --url https://target.com -e ap,at,u1-100,cb,dbe,m --api-token TOKEN

# Quick vulnerability check
wpscan --url https://target.com -e vp,vt --api-token TOKEN

# Standard penetration test enumeration
wpscan --url https://target.com -e vp,vt,u,cb --api-token TOKEN
```

---

## Detection Modes

WPScan supports three detection modes that control how aggressively it probes the target.

### Detection Mode Options

| Mode | Description | Use Case |
|------|-------------|----------|
| `passive` | Only analyzes HTTP responses, no active probing | Stealth, WAF evasion, initial recon |
| `mixed` | Passive + targeted requests for detected components | Default, balanced approach |
| `aggressive` | Full directory brute-force and active probing | Complete enumeration, CTF, lab environments |

### Global Detection Mode

```bash
# Passive mode (stealthiest)
wpscan --url https://target.com --detection-mode passive

# Mixed mode (default)
wpscan --url https://target.com --detection-mode mixed

# Aggressive mode (most comprehensive)
wpscan --url https://target.com --detection-mode aggressive
```

### Component-Specific Detection Modes

```bash
# Aggressive plugin detection
wpscan --url https://target.com --plugins-detection aggressive

# Passive plugin detection
wpscan --url https://target.com --plugins-detection passive

# Aggressive theme detection
wpscan --url https://target.com --themes-detection aggressive

# Aggressive version detection for plugins
wpscan --url https://target.com --plugins-version-detection aggressive

# Aggressive version detection for themes
wpscan --url https://target.com --themes-version-detection aggressive
```

### Stealth Mode

```bash
# Built-in stealthy mode (combines multiple stealth options)
wpscan --url https://target.com --stealthy

# Stealthy mode is equivalent to:
wpscan --url https://target.com \
    --detection-mode passive \
    --plugins-version-detection passive \
    --random-user-agent
```

### Detection Mode Comparison

| Aspect | Passive | Mixed | Aggressive |
|--------|---------|-------|------------|
| HTTP Requests | Minimal | Moderate | Many |
| Detection Coverage | Limited | Good | Complete |
| Speed | Fast | Medium | Slow |
| Stealth | High | Medium | Low |
| WAF Evasion | Best | Moderate | Poor |
| Version Detection | Limited | Good | Best |

---

## Password Brute-Forcing

WPScan can perform password brute-force attacks against WordPress user accounts.

### Basic Password Attack

```bash
# Single user with wordlist
wpscan --url https://target.com -U admin -P /path/to/wordlist.txt

# Short form
wpscan --url https://target.com --usernames admin --passwords wordlist.txt
```

### Multiple Users

```bash
# Multiple users from file
wpscan --url https://target.com -U users.txt -P passwords.txt

# Multiple users inline
wpscan --url https://target.com -U admin,editor,author -P wordlist.txt

# Combine with user enumeration
wpscan --url https://target.com -e u -P passwords.txt
```

### Password Attack Methods

| Method | Endpoint | Speed | Notes |
|--------|----------|-------|-------|
| `wp-login` | `/wp-login.php` | Slow | Default, always works |
| `xmlrpc` | `/xmlrpc.php` | Medium | Faster if XML-RPC enabled |
| `xmlrpc-multicall` | `/xmlrpc.php` | Fast | Multiple passwords per request |

```bash
# Use XML-RPC method (faster)
wpscan --url https://target.com -U admin -P wordlist.txt --password-attack xmlrpc

# Use XML-RPC multicall (fastest)
wpscan --url https://target.com -U admin -P wordlist.txt --password-attack xmlrpc-multicall

# Default wp-login method
wpscan --url https://target.com -U admin -P wordlist.txt --password-attack wp-login
```

### Optimizing Password Attacks

```bash
# Increase threads for faster attacks
wpscan --url https://target.com -U admin -P wordlist.txt -t 20

# Throttle to avoid lockouts (milliseconds)
wpscan --url https://target.com -U admin -P wordlist.txt --throttle 500

# Combined optimization
wpscan --url https://target.com -U admin -P wordlist.txt \
    --password-attack xmlrpc-multicall \
    -t 10 \
    --throttle 100
```

### Common Wordlists

```bash
# Rockyou (Kali Linux)
wpscan --url https://target.com -U admin -P /usr/share/wordlists/rockyou.txt

# SecLists common passwords
wpscan --url https://target.com -U admin -P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt

# WordPress-specific passwords
wpscan --url https://target.com -U admin -P /usr/share/seclists/Passwords/darkweb2017-top10000.txt
```

### Bypassing Login Protections

```bash
# Random User-Agent per request
wpscan --url https://target.com -U admin -P wordlist.txt --random-user-agent

# Through proxy for IP rotation
wpscan --url https://target.com -U admin -P wordlist.txt --proxy socks5://127.0.0.1:9050

# Custom headers (bypass some WAFs)
wpscan --url https://target.com -U admin -P wordlist.txt \
    --headers "X-Forwarded-For: 127.0.0.1"
```

---

## Plugin Detection

Plugins are the most common source of WordPress vulnerabilities. WPScan provides comprehensive plugin detection capabilities.

### Plugin Enumeration Commands

```bash
# Popular plugins (fast, limited coverage)
wpscan --url https://target.com -e p

# All plugins (comprehensive, slower)
wpscan --url https://target.com -e ap

# Vulnerable plugins only (requires API)
wpscan --url https://target.com -e vp --api-token TOKEN
```

### Plugin Detection Modes

```bash
# Passive detection (stealthy)
wpscan --url https://target.com -e ap --plugins-detection passive

# Mixed detection (default)
wpscan --url https://target.com -e ap --plugins-detection mixed

# Aggressive detection (complete)
wpscan --url https://target.com -e ap --plugins-detection aggressive
```

### Plugin Version Detection

```bash
# Default version detection
wpscan --url https://target.com -e ap

# Aggressive version detection
wpscan --url https://target.com -e ap --plugins-version-detection aggressive

# Passive version detection
wpscan --url https://target.com -e ap --plugins-version-detection passive
```

### Plugin Detection Techniques

WPScan uses multiple techniques to detect plugins:

1. **Passive Detection:**
   - Parsing HTML for plugin references in CSS/JS includes
   - Checking page source for plugin-specific markers
   - Analyzing HTTP headers

2. **Aggressive Detection:**
   - Directory brute-forcing in `/wp-content/plugins/`
   - Checking for readme.txt, changelog.txt files
   - Probing known plugin file paths

### Plugin Version Detection Sources

- `readme.txt` header parsing
- `changelog.txt` analysis
- CSS/JS version query strings
- Plugin file header comments

---

## Theme Detection

### Theme Enumeration Commands

```bash
# Popular themes (fast)
wpscan --url https://target.com -e t

# All themes (comprehensive)
wpscan --url https://target.com -e at

# Vulnerable themes only
wpscan --url https://target.com -e vt --api-token TOKEN
```

### Theme Detection Modes

```bash
# Passive theme detection
wpscan --url https://target.com -e at --themes-detection passive

# Aggressive theme detection
wpscan --url https://target.com -e at --themes-detection aggressive
```

### Theme Version Detection

```bash
# Aggressive version detection
wpscan --url https://target.com -e at --themes-version-detection aggressive

# Passive version detection
wpscan --url https://target.com -e at --themes-version-detection passive
```

### Theme Detection Methods

- `style.css` header parsing (Theme Name, Version, Author)
- Theme directory enumeration
- Screenshot.png detection
- CSS/JS fingerprinting

---

## Vulnerability Detection

WPScan leverages the WPVulnDB database for comprehensive vulnerability information.

### Vulnerability Scanning

```bash
# Full vulnerability scan (requires API)
wpscan --url https://target.com --api-token YOUR_TOKEN

# Check vulnerable plugins and themes
wpscan --url https://target.com -e vp,vt --api-token TOKEN

# Comprehensive vulnerability assessment
wpscan --url https://target.com -e ap,at --api-token TOKEN
```

### Vulnerability Information Provided

- **CVE Identifiers** - Standard vulnerability identifiers
- **Vulnerability Type** - SQLi, XSS, RCE, LFI, authentication bypass, etc.
- **Affected Versions** - Version range affected by the vulnerability
- **Fixed In Version** - Version where the vulnerability was patched
- **References** - Links to exploits, advisories, and details
- **CVSS Score** - Severity rating (where available)

### WordPress Core Vulnerabilities

```bash
# Check WordPress core version and vulnerabilities
wpscan --url https://target.com --api-token TOKEN

# Force aggressive version detection
wpscan --url https://target.com --detection-mode aggressive --api-token TOKEN
```

### Without API Token

```bash
# Scan without vulnerability data
wpscan --url https://target.com

# Will enumerate plugins/themes but not show vulnerability details
# Output will indicate: "[!] No WPVulnDB API Token given"
```

---

## Output Formats

### Available Formats

| Format | Description | Use Case |
|--------|-------------|----------|
| `cli` | Colored terminal output | Interactive use (default) |
| `cli-no-color` | Plain text without ANSI colors | Logging, piping |
| `json` | JSON structured output | Automation, parsing, reporting |

### Output Commands

```bash
# Default CLI output (colored)
wpscan --url https://target.com

# CLI without colors
wpscan --url https://target.com -f cli-no-color
wpscan --url https://target.com --format cli-no-color

# JSON output
wpscan --url https://target.com -f json
wpscan --url https://target.com --format json

# Output to file
wpscan --url https://target.com -o report.txt
wpscan --url https://target.com --output report.txt

# JSON to file
wpscan --url https://target.com -f json -o report.json
```

### JSON Output Processing

```bash
# Pretty print JSON
wpscan --url https://target.com -f json | jq .

# Extract plugin information
wpscan --url https://target.com -e ap -f json | jq '.plugins'

# Get vulnerable plugins only
wpscan --url https://target.com -e ap -f json --api-token TOKEN | \
    jq '.plugins | to_entries[] | select(.value.vulnerabilities | length > 0)'

# Extract usernames
wpscan --url https://target.com -e u -f json | jq -r '.users[].username'

# Get WordPress version
wpscan --url https://target.com -f json | jq '.version.number'

# List all CVEs found
wpscan --url https://target.com -f json --api-token TOKEN | \
    jq -r '.. | .cve? // empty' | sort -u
```

### Verbose Output

```bash
# Verbose mode (more details)
wpscan --url https://target.com -v
wpscan --url https://target.com --verbose

# Very verbose (includes HTTP requests)
wpscan --url https://target.com -vv

# Debug mode (maximum verbosity)
wpscan --url https://target.com --debug
```

---

## Proxy and Authentication Options

### HTTP/HTTPS Proxy

```bash
# HTTP proxy
wpscan --url https://target.com --proxy http://127.0.0.1:8080

# HTTPS proxy
wpscan --url https://target.com --proxy https://proxy.example.com:8080

# Proxy with authentication
wpscan --url https://target.com --proxy http://user:pass@127.0.0.1:8080
```

### SOCKS Proxy

```bash
# SOCKS4 proxy
wpscan --url https://target.com --proxy socks4://127.0.0.1:1080

# SOCKS5 proxy
wpscan --url https://target.com --proxy socks5://127.0.0.1:1080

# Through Tor
wpscan --url https://target.com --proxy socks5://127.0.0.1:9050
```

### Proxy with Burp Suite

```bash
# Route through Burp for inspection
wpscan --url https://target.com --proxy http://127.0.0.1:8080

# With SSL/TLS checks disabled (for Burp's certificate)
wpscan --url https://target.com --proxy http://127.0.0.1:8080 --disable-tls-checks
```

### SSL/TLS Options

```bash
# Disable TLS certificate verification
wpscan --url https://target.com --disable-tls-checks

# Specify SSL/TLS version
wpscan --url https://target.com --ssl-version TLSv1_2

# Ignore SSL errors (self-signed certs)
wpscan --url https://target.com --disable-tls-checks
```

### HTTP Authentication

```bash
# Basic authentication
wpscan --url https://target.com --http-auth user:password

# Or use the format
wpscan --url https://user:password@target.com
```

### Cookie Authentication

```bash
# Single cookie
wpscan --url https://target.com --cookie "session=abc123"

# Multiple cookies
wpscan --url https://target.com --cookie "session=abc123; auth=xyz789"

# WordPress logged-in cookie (authenticated scan)
wpscan --url https://target.com \
    --cookie "wordpress_logged_in_xxx=admin%7C1234567890%7Chash"
```

### Custom Headers

```bash
# Single custom header
wpscan --url https://target.com --headers "Authorization: Bearer TOKEN"

# Multiple headers
wpscan --url https://target.com \
    --headers "X-Forwarded-For: 10.0.0.1" \
    --headers "X-Custom-Header: value"
```

### User-Agent Options

```bash
# Random User-Agent per request
wpscan --url https://target.com --random-user-agent

# Custom User-Agent
wpscan --url https://target.com --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```

---

## Advanced Options

### Scope Control

```bash
# Ignore main theme (useful for child themes)
wpscan --url https://target.com --main-theme <theme-name>

# Exclude paths from scan
wpscan --url https://target.com --exclude-usernames admin,editor

# Force scan on non-WordPress site
wpscan --url https://target.com --force
```

### Request Configuration

```bash
# Maximum redirects to follow
wpscan --url https://target.com --max-redirects 5

# Disable response caching
wpscan --url https://target.com --no-cache

# Clear cache before scanning
wpscan --url https://target.com --clear-cache
```

### Database Management

```bash
# Update WPScan database
wpscan --update

# Show database statistics
wpscan --stats

# Database location (default: ~/.wpscan/db/)
ls ~/.wpscan/db/
```

### Configuration File

Create `~/.wpscan/scan.yml` for default options:

```yaml
cli_options:
  api_token: YOUR_API_TOKEN
  format: json
  verbose: true
  random_user_agent: true
  throttle: 500
  detection_mode: mixed
  max_threads: 10
  # proxy: http://127.0.0.1:8080
  # disable_tls_checks: true
```

---

## Practical WordPress Pentesting Examples

### Scenario 1: Initial Reconnaissance

```bash
# Quick passive scan to avoid detection
wpscan --url https://target.com --stealthy

# Identify WordPress version, active theme, and basic info
wpscan --url https://target.com --detection-mode passive

# If more information needed
wpscan --url https://target.com -e p,t,u --detection-mode passive
```

### Scenario 2: Comprehensive Vulnerability Assessment

```bash
# Full vulnerability scan for professional assessment
wpscan --url https://target.com \
    -e ap,at,u1-100,cb,dbe \
    --api-token YOUR_TOKEN \
    --detection-mode aggressive \
    --plugins-version-detection aggressive \
    --themes-version-detection aggressive \
    -f json \
    -o vulnerability-report.json

# Parse for high-severity vulnerabilities
cat vulnerability-report.json | jq '
    .plugins | to_entries[] |
    select(.value.vulnerabilities[]?.cvss?.score >= 7.0) |
    {plugin: .key, vulns: .value.vulnerabilities}
'
```

### Scenario 3: User Enumeration and Password Attack

```bash
# Step 1: Enumerate users
wpscan --url https://target.com -e u1-100 -f json -o users.json

# Step 2: Extract usernames
cat users.json | jq -r '.users[].username' > usernames.txt

# Step 3: Password attack using XML-RPC multicall
wpscan --url https://target.com \
    -U usernames.txt \
    -P /usr/share/wordlists/rockyou.txt \
    --password-attack xmlrpc-multicall \
    -t 10

# Alternative: Combine enumeration and attack in one command
wpscan --url https://target.com \
    -e u \
    -P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt \
    --password-attack xmlrpc-multicall
```

### Scenario 4: Plugin-Focused Penetration Test

```bash
# Step 1: Enumerate all plugins with aggressive detection
wpscan --url https://target.com \
    -e ap \
    --plugins-detection aggressive \
    --plugins-version-detection aggressive \
    --api-token YOUR_TOKEN \
    -f json \
    -o plugins.json

# Step 2: Check for vulnerable plugins specifically
wpscan --url https://target.com -e vp --api-token YOUR_TOKEN

# Step 3: Parse and list vulnerable plugins
cat plugins.json | jq '
    .plugins | to_entries[] |
    select(.value.vulnerabilities | length > 0) |
    {
        name: .key,
        version: .value.version.number,
        vulnerabilities: [.value.vulnerabilities[] | {
            title: .title,
            type: .vuln_type,
            fixed_in: .fixed_in
        }]
    }
'
```

### Scenario 5: Stealth Scan Through Proxy Chain

```bash
# Through Burp Suite for traffic inspection
wpscan --url https://target.com \
    --proxy http://127.0.0.1:8080 \
    --disable-tls-checks \
    --stealthy \
    -e vp,vt

# Through Tor for anonymity
wpscan --url https://target.com \
    --proxy socks5://127.0.0.1:9050 \
    --stealthy \
    --throttle 5000 \
    -t 1

# Through SSH SOCKS tunnel
wpscan --url https://target.com \
    --proxy socks5://127.0.0.1:1080 \
    --detection-mode passive \
    --random-user-agent
```

### Scenario 6: Authenticated Scan

```bash
# Step 1: Login to WordPress via browser
# Step 2: Copy the wordpress_logged_in_* cookie from browser DevTools

# Step 3: Run authenticated scan
wpscan --url https://target.com \
    --cookie "wordpress_logged_in_abc123=admin%7C1609459200%7Chash..." \
    -e ap,at \
    --api-token YOUR_TOKEN
```

### Scenario 7: Configuration File Discovery

```bash
# Check for backup configuration files
wpscan --url https://target.com -e cb

# Files checked include:
# - wp-config.php~
# - wp-config.php.bak
# - wp-config.php.old
# - wp-config.php.save
# - wp-config.php.orig
# - wp-config.php.original
# - .wp-config.php.swp
# - wp-config.bak
# - wp-config.old

# Check for database exports
wpscan --url https://target.com -e dbe

# Combined with other enumeration
wpscan --url https://target.com -e cb,dbe,vp,vt --api-token YOUR_TOKEN
```

### Scenario 8: CTF/Lab Environment Comprehensive Scan

```bash
# Fast, aggressive scan for CTF scenarios
wpscan --url http://target.ctf \
    -e ap,at,u1-50,cb,dbe,tt \
    --detection-mode aggressive \
    --plugins-detection aggressive \
    --themes-detection aggressive \
    --plugins-version-detection aggressive \
    --themes-version-detection aggressive \
    -t 50 \
    --api-token YOUR_TOKEN

# Quick password spray
wpscan --url http://target.ctf \
    -e u \
    -P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt \
    --password-attack xmlrpc-multicall \
    -t 50 \
    --no-banner
```

### Scenario 9: Reporting and Documentation

```bash
# Generate comprehensive JSON report
wpscan --url https://target.com \
    -e ap,at,u1-100,cb,dbe \
    --api-token YOUR_TOKEN \
    -f json \
    -o full-report.json

# Generate CLI report for documentation
wpscan --url https://target.com \
    -e ap,at,u1-100 \
    --api-token YOUR_TOKEN \
    -f cli-no-color \
    -o report.txt

# Create summary from JSON
cat full-report.json | jq '{
    target: .target_url,
    wordpress_version: .version.number,
    plugins_found: (.plugins | length),
    vulnerable_plugins: [.plugins | to_entries[] | select(.value.vulnerabilities | length > 0) | .key],
    themes_found: (.themes | length),
    users_found: [.users[].username]
}'
```

### Scenario 10: Continuous Monitoring Script

```bash
#!/bin/bash
# Simple WordPress security monitoring script

TARGET="https://target.com"
API_TOKEN="YOUR_TOKEN"
OUTPUT_DIR="/var/log/wpscan"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

wpscan --url "$TARGET" \
    -e vp,vt \
    --api-token "$API_TOKEN" \
    -f json \
    -o "$OUTPUT_DIR/scan_$DATE.json" \
    --no-banner

# Check for vulnerabilities
VULNS=$(cat "$OUTPUT_DIR/scan_$DATE.json" | jq '[.. | .vulnerabilities? // empty | .[]] | length')

if [ "$VULNS" -gt 0 ]; then
    echo "WARNING: $VULNS vulnerabilities found!"
    # Send alert (email, Slack, etc.)
fi
```

---

## Complete CLI Reference

### All Command-Line Options

```
Usage: wpscan [options]

Scan Options:
    --url URL                        The WordPress URL/domain to scan
    --force                          Do not check if the target is running WordPress
    --update                         Update the WPScan database
    --no-update                      Do not update the WPScan database
    --random-user-agent              Use a random User-Agent for each request
    --user-agent VALUE               Specify custom User-Agent
    --headers HEADERS                Additional HTTP headers (can be used multiple times)
    --cookie VALUE                   String to send as cookie
    --proxy PROXY                    Use proxy (HTTP, HTTPS, SOCKS4/5)
    --disable-tls-checks             Disable SSL/TLS certificate verification
    --ssl-version VERSION            SSL version to use (SSL, TLS, etc.)
    --http-auth LOGIN:PASSWORD       HTTP Basic authentication

Enumeration Options:
    -e, --enumerate [OPTS]           Enumeration options:
                                       vp   - Vulnerable plugins
                                       ap   - All plugins
                                       p    - Popular plugins
                                       vt   - Vulnerable themes
                                       at   - All themes
                                       t    - Popular themes
                                       tt   - Timthumbs
                                       cb   - Config backups
                                       dbe  - Database exports
                                       u    - User IDs 1-10
                                       m    - Media IDs 1-100

Detection Options:
    --detection-mode MODE            Detection mode (passive, mixed, aggressive)
    --plugins-detection MODE         Plugin detection mode
    --themes-detection MODE          Theme detection mode
    --plugins-version-detection MODE Plugin version detection mode
    --themes-version-detection MODE  Theme version detection mode

Password Attack Options:
    -U, --usernames LIST             Username(s) or file containing usernames
    -P, --passwords FILE             Password wordlist file
    --password-attack TYPE           Attack type (wp-login, xmlrpc, xmlrpc-multicall)

Output Options:
    -o, --output FILE                Output to file
    -f, --format FORMAT              Output format (cli, cli-no-color, json)
    -v, --verbose                    Verbose output
    --no-banner                      Do not display WPScan banner

Performance Options:
    -t, --max-threads VALUE          Maximum threads (default: 5)
    --throttle MILLISECONDS          Milliseconds to wait between requests
    --request-timeout SECONDS        Request timeout in seconds
    --connect-timeout SECONDS        Connection timeout in seconds

Path Options:
    --wp-content-dir DIR             Custom wp-content directory
    --wp-plugins-dir DIR             Custom plugins directory

API Options:
    --api-token TOKEN                WPVulnDB API token

Other Options:
    --stealthy                       Enable stealth mode
    --clear-cache                    Clear the cache before scanning
    --no-cache                       Disable response caching
    -h, --help                       Display help
    -hh                              Display verbose help
    --version                        Display version
```

---

## Quick Reference Cheat Sheet

### Most Common Commands

```bash
# Basic scan with vulnerabilities
wpscan --url URL --api-token TOKEN

# Full enumeration
wpscan --url URL -e ap,at,u1-100 --api-token TOKEN

# Password attack
wpscan --url URL -U admin -P wordlist.txt --password-attack xmlrpc-multicall

# Stealth scan
wpscan --url URL --stealthy --detection-mode passive

# JSON output
wpscan --url URL -e vp,vt -f json -o report.json --api-token TOKEN
```

### Enumeration Quick Reference

| Goal | Command |
|------|---------|
| All plugins | `-e ap` |
| Vulnerable plugins | `-e vp` |
| Popular plugins | `-e p` |
| All themes | `-e at` |
| Vulnerable themes | `-e vt` |
| Popular themes | `-e t` |
| Users 1-100 | `-e u1-100` |
| Config backups | `-e cb` |
| Database exports | `-e dbe` |
| Complete scan | `-e ap,at,u1-100,cb,dbe,m` |

### Detection Mode Quick Reference

| Mode | Use Case |
|------|----------|
| `passive` | Stealth, WAF evasion |
| `mixed` | Balanced (default) |
| `aggressive` | Complete coverage |

### Password Attack Quick Reference

| Method | Speed | Reliability |
|--------|-------|-------------|
| `wp-login` | Slow | Always works |
| `xmlrpc` | Medium | If enabled |
| `xmlrpc-multicall` | Fast | If enabled |

---

## Resources

- **Official Repository:** https://github.com/wpscanteam/wpscan
- **WPScan Wiki:** https://github.com/wpscanteam/wpscan/wiki
- **WPVulnDB API:** https://wpscan.com/api
- **API Registration:** https://wpscan.com/register
- **WordPress Security Cheat Sheet:** https://cheatsheetseries.owasp.org/cheatsheets/Wordpress_Security_Cheat_Sheet.html
