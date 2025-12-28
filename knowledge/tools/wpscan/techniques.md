# WPScan - Scanning Techniques

## Table of Contents

- [Enumeration Modes](#enumeration-modes)
- [User Enumeration](#user-enumeration)
- [Plugin Enumeration](#plugin-enumeration)
- [Theme Enumeration](#theme-enumeration)
- [Password Attacks](#password-attacks)
- [Vulnerability Detection](#vulnerability-detection)
- [Version Detection](#version-detection)
- [API Usage](#api-usage)
- [Stealthy Scanning](#stealthy-scanning)
- [Output Formats](#output-formats)
- [Practical Attack Scenarios](#practical-attack-scenarios)

---

## Enumeration Modes

The `-e` or `--enumerate` flag controls what WPScan enumerates. Multiple options can be combined with commas.

### Enumeration Options Reference

| Option | Description |
|--------|-------------|
| `vp` | Vulnerable plugins |
| `ap` | All plugins |
| `p` | Popular plugins |
| `vt` | Vulnerable themes |
| `at` | All themes |
| `t` | Popular themes |
| `tt` | Timthumbs (deprecated thumbnail script) |
| `cb` | Config backups |
| `dbe` | Database exports |
| `u` | User IDs 1-10 |
| `u1-100` | User IDs 1-100 |
| `m` | Media IDs 1-100 |
| `m1-1000` | Media IDs 1-1000 |

### Common Enumeration Combinations

```bash
# Default enumeration (plugins, themes, users)
wpscan --url https://target.com -e vp,vt,u

# Full aggressive enumeration
wpscan --url https://target.com -e ap,at,u1-100,cb,dbe,m

# Quick vulnerability check
wpscan --url https://target.com -e vp,vt

# User-focused enumeration
wpscan --url https://target.com -e u1-100

# Complete plugin/theme audit
wpscan --url https://target.com -e ap,at --api-token TOKEN
```

---

## User Enumeration

WPScan uses multiple techniques to enumerate WordPress users.

### Enumeration Methods

1. **Author Archives** - Iterating through `/?author=N`
2. **Login Error Messages** - Different errors for valid/invalid users
3. **REST API** - Accessing `/wp-json/wp/v2/users`
4. **RSS Feed** - Author information in feed
5. **Yoast SEO Sitemap** - Author sitemaps if Yoast is installed

### User Enumeration Examples

```bash
# Basic user enumeration (IDs 1-10)
wpscan --url https://target.com -e u

# Extended range enumeration
wpscan --url https://target.com -e u1-50

# Aggressive user enumeration with threading
wpscan --url https://target.com -e u1-100 -t 20

# Enumerate users via REST API only (stealthy)
wpscan --url https://target.com -e u --detection-mode passive
```

### What User Enumeration Reveals

- Usernames for password attacks
- Display names
- User IDs
- Sometimes email addresses

---

## Plugin Enumeration

Plugins are the most common source of WordPress vulnerabilities.

### Plugin Detection Modes

```bash
# Popular plugins only (fast)
wpscan --url https://target.com -e p

# All plugins (comprehensive, slower)
wpscan --url https://target.com -e ap

# Vulnerable plugins only (with API token)
wpscan --url https://target.com -e vp --api-token TOKEN

# Aggressive plugin detection
wpscan --url https://target.com -e ap --plugins-detection aggressive
```

### Plugin Detection Techniques

| Mode | Method | Speed | Coverage |
|------|--------|-------|----------|
| passive | HTML analysis, passive enumeration | Fast | Limited |
| mixed | Passive + targeted requests | Medium | Good |
| aggressive | Full directory brute-force | Slow | Complete |

### Plugin Version Detection

```bash
# Force version detection for all plugins
wpscan --url https://target.com -e ap --plugins-version-detection aggressive

# Check specific plugin
wpscan --url https://target.com --plugins-detection passive | grep -i "contact-form"
```

---

## Theme Enumeration

Themes can also contain vulnerabilities, especially commercial themes.

### Theme Detection Modes

```bash
# Popular themes
wpscan --url https://target.com -e t

# All themes
wpscan --url https://target.com -e at

# Vulnerable themes only
wpscan --url https://target.com -e vt --api-token TOKEN

# Theme version detection
wpscan --url https://target.com -e at --themes-version-detection aggressive
```

### Theme Detection Methods

- CSS/JS fingerprinting
- `style.css` header parsing
- Theme directory enumeration
- Screenshot detection

---

## Password Attacks

WPScan can perform password brute-force attacks against WordPress login.

### Basic Password Attacks

```bash
# Single user, wordlist
wpscan --url https://target.com -U admin -P /usr/share/wordlists/rockyou.txt

# Multiple users from file
wpscan --url https://target.com -U users.txt -P passwords.txt

# Stop on first valid credential
wpscan --url https://target.com -U admin -P wordlist.txt --password-attack wp-login
```

### Password Attack Methods

| Method | Endpoint | Use Case |
|--------|----------|----------|
| `wp-login` | `/wp-login.php` | Default, works on most sites |
| `xmlrpc` | `/xmlrpc.php` | Faster, if enabled |
| `xmlrpc-multicall` | `/xmlrpc.php` (multicall) | Fastest, multiple passwords per request |

```bash
# Use XML-RPC for faster attacks
wpscan --url https://target.com -U admin -P wordlist.txt --password-attack xmlrpc

# XML-RPC multicall (500 passwords per request)
wpscan --url https://target.com -U admin -P wordlist.txt --password-attack xmlrpc-multicall
```

### Optimizing Password Attacks

```bash
# Increase threads for faster attacks
wpscan --url https://target.com -U admin -P wordlist.txt -t 20

# With throttle to avoid lockouts
wpscan --url https://target.com -U admin -P wordlist.txt --throttle 500

# Combine with user enumeration
wpscan --url https://target.com -e u -P passwords.txt
```

### Bypassing Login Protections

```bash
# Random User-Agent to evade simple detection
wpscan --url https://target.com -U admin -P wordlist.txt --random-user-agent

# Through proxy for IP rotation
wpscan --url https://target.com -U admin -P wordlist.txt --proxy socks5://127.0.0.1:9050

# With custom headers
wpscan --url https://target.com -U admin -P wordlist.txt \
    --headers "X-Forwarded-For: 127.0.0.1"
```

---

## Vulnerability Detection

WPScan leverages the WPVulnDB database for comprehensive vulnerability information.

### Vulnerability Scanning

```bash
# Full vulnerability scan (requires API token)
wpscan --url https://target.com --api-token TOKEN

# Enumerate and check vulnerabilities
wpscan --url https://target.com -e vp,vt --api-token TOKEN

# Check WordPress core vulnerabilities
wpscan --url https://target.com --api-token TOKEN
```

### Vulnerability Information Includes

- CVE identifiers
- Vulnerability type (SQLi, XSS, RCE, etc.)
- Affected versions
- Fixed in version
- References and exploits
- CVSS score (where available)

### Without API Token

```bash
# Basic scan without vulnerability data
wpscan --url https://target.com

# Will show plugins/themes but no vulnerability details
# Consider registering for free token (25 requests/day)
```

---

## Version Detection

Accurate version detection is crucial for vulnerability assessment.

### WordPress Core Version

```bash
# Detect WordPress version
wpscan --url https://target.com

# Force aggressive version detection
wpscan --url https://target.com --detection-mode aggressive
```

### Version Detection Sources

- Meta generator tag
- RSS feed generator
- README.html file
- wp-includes/version.php (if accessible)
- CSS/JS version strings
- Login page fingerprinting

### Component Version Detection

```bash
# Aggressive plugin version detection
wpscan --url https://target.com -e ap --plugins-version-detection aggressive

# Aggressive theme version detection
wpscan --url https://target.com -e at --themes-version-detection aggressive

# All aggressive detection
wpscan --url https://target.com -e ap,at --detection-mode aggressive \
    --plugins-version-detection aggressive --themes-version-detection aggressive
```

---

## API Usage

The WPVulnDB API provides vulnerability data. Proper API usage is essential for effective scanning.

### API Token Management

```bash
# Command-line token
wpscan --url https://target.com --api-token YOUR_TOKEN

# Environment variable
export WPSCAN_API_TOKEN=YOUR_TOKEN
wpscan --url https://target.com

# Configuration file (~/.wpscan/scan.yml)
cat > ~/.wpscan/scan.yml << 'EOF'
cli_options:
  api_token: YOUR_TOKEN
EOF
```

### API Rate Limits

| Plan | Daily Requests | Use Case |
|------|----------------|----------|
| Free | 25 | Personal use |
| Starter | 75 | Small teams |
| Professional | 300 | Regular testing |
| Enterprise | Unlimited | Continuous scanning |

### Checking API Usage

```bash
# The scan output shows API usage
wpscan --url https://target.com --api-token TOKEN -v

# Output includes remaining API requests
```

---

## Stealthy Scanning

Minimize detection by security plugins and WAFs.

### Stealth Mode

```bash
# Built-in stealthy mode
wpscan --url https://target.com --stealthy

# This enables:
# - Random User-Agent
# - Passive detection mode
# - Throttled requests
```

### Manual Stealth Configuration

```bash
# Passive detection only
wpscan --url https://target.com --detection-mode passive

# Random User-Agent
wpscan --url https://target.com --random-user-agent

# Throttle requests (milliseconds)
wpscan --url https://target.com --throttle 2000

# Reduce threads
wpscan --url https://target.com -t 1 --throttle 3000

# Combined stealth approach
wpscan --url https://target.com \
    --detection-mode passive \
    --random-user-agent \
    --throttle 2000 \
    -t 2
```

### Evasion Techniques

```bash
# Custom User-Agent
wpscan --url https://target.com \
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Through Burp/ZAP proxy
wpscan --url https://target.com --proxy http://127.0.0.1:8080

# Through Tor
wpscan --url https://target.com --proxy socks5://127.0.0.1:9050 --throttle 5000

# Custom headers
wpscan --url https://target.com --headers "Accept-Language: en-US,en;q=0.9"
```

---

## Output Formats

WPScan supports multiple output formats for different use cases.

### Available Formats

```bash
# Default CLI output (colored)
wpscan --url https://target.com

# CLI without colors (for logs)
wpscan --url https://target.com -f cli-no-color

# JSON output (for parsing/automation)
wpscan --url https://target.com -f json

# Output to file
wpscan --url https://target.com -o report.txt

# JSON to file
wpscan --url https://target.com -f json -o report.json
```

### JSON Output Processing

```bash
# Scan and process with jq
wpscan --url https://target.com -f json | jq '.plugins'

# Extract vulnerable plugins
wpscan --url https://target.com -f json --api-token TOKEN | \
    jq '.plugins | to_entries[] | select(.value.vulnerabilities | length > 0)'

# Get list of users
wpscan --url https://target.com -e u -f json | jq '.users[].username'

# Save structured report
wpscan --url https://target.com -f json -o scan.json --api-token TOKEN
```

### Verbose Output

```bash
# Verbose mode for debugging
wpscan --url https://target.com -v

# Very verbose (includes HTTP requests)
wpscan --url https://target.com -vv
```

---

## Practical Attack Scenarios

### Scenario 1: Initial Reconnaissance

```bash
# Quick passive scan to avoid detection
wpscan --url https://target.com --stealthy

# If more info needed, progressive enumeration
wpscan --url https://target.com -e p,t,u --detection-mode passive
```

### Scenario 2: Vulnerability Assessment

```bash
# Comprehensive vulnerability scan
wpscan --url https://target.com \
    -e vp,vt,cb,dbe \
    --api-token TOKEN \
    -f json \
    -o vulnerability-report.json

# Parse for high-severity issues
cat vulnerability-report.json | jq '.plugins | to_entries[] |
    select(.value.vulnerabilities[].cvss.score >= 7.0)'
```

### Scenario 3: User Enumeration + Password Attack

```bash
# Step 1: Enumerate users
wpscan --url https://target.com -e u1-100 -f json -o users.json

# Step 2: Extract usernames
cat users.json | jq -r '.users[].username' > usernames.txt

# Step 3: Password attack with XML-RPC
wpscan --url https://target.com \
    -U usernames.txt \
    -P /usr/share/wordlists/rockyou.txt \
    --password-attack xmlrpc-multicall \
    -t 10
```

### Scenario 4: Plugin-Focused Attack

```bash
# Aggressive plugin enumeration
wpscan --url https://target.com \
    -e ap \
    --plugins-detection aggressive \
    --plugins-version-detection aggressive \
    --api-token TOKEN

# Look for known vulnerable plugins
wpscan --url https://target.com -e vp --api-token TOKEN
```

### Scenario 5: Authenticated Scan

```bash
# Scan with WordPress cookie
wpscan --url https://target.com \
    --cookie "wordpress_logged_in_xxx=admin%7C..."

# Find cookie by logging in via browser and copying from DevTools
```

### Scenario 6: Finding Config Backups

```bash
# Check for backup files
wpscan --url https://target.com -e cb

# Common backup locations checked:
# - wp-config.php~
# - wp-config.php.bak
# - wp-config.php.old
# - wp-config.php.save
# - .wp-config.php.swp
```

### Scenario 7: CTF WordPress Challenge

```bash
# Fast comprehensive scan
wpscan --url http://target.com \
    -e ap,at,u1-50,cb,dbe \
    --detection-mode aggressive \
    --plugins-detection aggressive \
    -t 20 \
    --api-token TOKEN

# Quick password spray with common passwords
wpscan --url http://target.com \
    -e u \
    -P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt \
    --password-attack xmlrpc-multicall \
    -t 50
```

### Scenario 8: Proxy Chain Scan

```bash
# Through Burp Suite for request inspection
wpscan --url https://target.com \
    --proxy http://127.0.0.1:8080 \
    --disable-tls-checks \
    -e vp,vt

# Through SOCKS proxy (Tor/SSH tunnel)
wpscan --url https://target.com \
    --proxy socks5://127.0.0.1:1080 \
    -e p,t,u
```

---

## Quick Reference

### Most Useful Commands

```bash
# Basic scan with vulns
wpscan --url URL --api-token TOKEN

# Full enumeration
wpscan --url URL -e ap,at,u1-100 --api-token TOKEN

# Password attack
wpscan --url URL -U admin -P wordlist.txt --password-attack xmlrpc-multicall

# Stealth scan
wpscan --url URL --stealthy --detection-mode passive

# JSON output for automation
wpscan --url URL -e vp,vt -f json -o report.json --api-token TOKEN
```

### Enumeration Cheat Sheet

| Goal | Command |
|------|---------|
| All plugins | `-e ap` |
| Vulnerable plugins | `-e vp` |
| All themes | `-e at` |
| Vulnerable themes | `-e vt` |
| Users 1-100 | `-e u1-100` |
| Config backups | `-e cb` |
| Database exports | `-e dbe` |
| Everything | `-e ap,at,u1-100,cb,dbe,m` |

### Detection Mode Comparison

| Mode | Description | Use Case |
|------|-------------|----------|
| passive | HTML parsing only | Stealth, WAF evasion |
| mixed | Passive + targeted | Default, balanced |
| aggressive | Full brute-force | Complete enumeration |

---

## Resources

- [WPScan Documentation](https://github.com/wpscanteam/wpscan/wiki)
- [WPVulnDB](https://wpscan.com/)
- [WordPress Security Best Practices](https://developer.wordpress.org/apis/security/)
- [Common WordPress Vulnerabilities](https://www.wordfence.com/learn/common-wordpress-vulnerabilities/)
