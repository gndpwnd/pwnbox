# Hydra Protocol Reference

This document provides detailed usage examples for each supported protocol in Hydra, with emphasis on correct syntax and common pitfalls.

## Table of Contents

- [General Syntax](#general-syntax)
- [Remote Access Protocols](#remote-access-protocols)
  - [SSH](#ssh)
  - [RDP](#rdp)
  - [VNC](#vnc)
- [File Transfer Protocols](#file-transfer-protocols)
  - [FTP](#ftp)
  - [SMB](#smb)
- [Web Protocols](#web-protocols)
  - [HTTP-GET](#http-get)
  - [HTTP-POST](#http-post)
  - [HTTP-GET-FORM](#http-get-form)
  - [HTTP-POST-FORM](#http-post-form)
  - [Capturing HTTP Parameters from Burp](#capturing-http-parameters-from-burp)
- [Database Protocols](#database-protocols)
  - [MySQL](#mysql)
  - [MSSQL](#mssql)
- [Directory Services](#directory-services)
  - [LDAP](#ldap)
- [Mail Protocols](#mail-protocols)
  - [IMAP](#imap)
  - [POP3](#pop3)
  - [SMTP](#smtp)
- [Speed Tuning](#speed-tuning)
- [Using with Proxychains](#using-with-proxychains)
- [Custom Wordlists](#custom-wordlists)

---

## General Syntax

```bash
hydra [OPTIONS] TARGET PROTOCOL [MODULE-OPTIONS]

# Alternative URL-style syntax
hydra [OPTIONS] PROTOCOL://TARGET[:PORT][/OPTIONS]
```

### Common Options

| Option | Description |
|--------|-------------|
| `-l LOGIN` | Single username |
| `-L FILE` | Username wordlist |
| `-p PASS` | Single password |
| `-P FILE` | Password wordlist |
| `-C FILE` | Colon-separated `user:pass` combo file |
| `-t TASKS` | Parallel connections per target (default: 16) |
| `-w TIME` | Max wait time for responses in seconds (default: 32) |
| `-s PORT` | Custom target port |
| `-S` | Use SSL/TLS |
| `-vV` | Verbose mode showing each attempt |
| `-f` | Stop on first valid credential found |
| `-F` | Stop on first valid credential per host |
| `-o FILE` | Output results to file |
| `-e nsr` | Additional checks: null password (n), login as pass (s), reversed (r) |

---

## Remote Access Protocols

### SSH

SSH brute forcing with rate limiting to avoid detection and lockouts.

```bash
# Basic attack with single username
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.100

# Multiple usernames, lower thread count to avoid lockouts
hydra -L users.txt -P passwords.txt -t 4 ssh://192.168.1.100

# Custom port with verbose output
hydra -l admin -P passwords.txt -s 2222 -vV ssh://192.168.1.100

# Try empty password and username as password
hydra -l admin -P passwords.txt -e ns ssh://192.168.1.100

# Stop on first valid credential
hydra -l admin -P passwords.txt -f ssh://192.168.1.100
```

**Note**: SSH servers often implement rate limiting. Use `-t 4` or lower to avoid triggering blocks.

### RDP

Remote Desktop Protocol brute forcing.

```bash
# Basic RDP attack
hydra -l administrator -P passwords.txt rdp://192.168.1.100

# With domain
hydra -l DOMAIN\\administrator -P passwords.txt rdp://192.168.1.100

# Lower threads for stability
hydra -l admin -P passwords.txt -t 1 rdp://192.168.1.100
```

**Note**: RDP is slow to brute force. Use `-t 1` for stability and consider NLA (Network Level Authentication) implications.

### VNC

VNC typically uses password-only authentication (no username).

```bash
# VNC password-only attack
hydra -P passwords.txt vnc://192.168.1.100

# Custom port
hydra -P passwords.txt -s 5901 vnc://192.168.1.100

# With specific display number (port 5900 + display)
hydra -P passwords.txt -s 5902 vnc://192.168.1.100
```

---

## File Transfer Protocols

### FTP

```bash
# Basic FTP attack
hydra -l admin -P passwords.txt ftp://192.168.1.100

# Anonymous login test
hydra -l anonymous -P passwords.txt ftp://192.168.1.100

# With verbose output
hydra -l admin -P passwords.txt -vV ftp://192.168.1.100

# FTPS (FTP over SSL)
hydra -l admin -P passwords.txt -S ftps://192.168.1.100
```

### SMB

Server Message Block / Windows file sharing.

```bash
# Basic SMB attack
hydra -l administrator -P passwords.txt smb://192.168.1.100

# With domain
hydra -l WORKGROUP\\admin -P passwords.txt smb://192.168.1.100

# SMB2/3 (modern Windows)
hydra -l admin -P passwords.txt smb2://192.168.1.100
```

---

## Web Protocols

### HTTP-GET

Basic HTTP authentication (not form-based).

```bash
# Basic HTTP auth (GET method)
hydra -l admin -P passwords.txt http-get://192.168.1.100/protected/

# With HTTPS
hydra -l admin -P passwords.txt https-get://192.168.1.100/admin/

# Custom port
hydra -l admin -P passwords.txt -s 8080 http-get://192.168.1.100/api/
```

### HTTP-POST

Basic HTTP authentication using POST method.

```bash
# Basic HTTP auth (POST method)
hydra -l admin -P passwords.txt http-post://192.168.1.100/api/auth
```

### HTTP-GET-FORM

Login forms using GET parameters. Less common than POST forms.

**Syntax**:
```
http-get-form "/path:PARAMETERS:FAILURE_STRING[:OPTIONS]"
```

```bash
# GET form login
hydra -l admin -P passwords.txt 192.168.1.100 http-get-form \
  "/login.php:username=^USER^&password=^PASS^:Invalid credentials"
```

### HTTP-POST-FORM

**This is the most commonly used and most commonly misused Hydra module.**

**Syntax**:
```
http-post-form "/path:POST_BODY:FAILURE_STRING[:OPTIONS]"
```

The three colon-separated fields are:
1. **Path**: The URL path to the login form (e.g., `/login.php`)
2. **POST Body**: Form parameters with `^USER^` and `^PASS^` placeholders
3. **Failure String**: Text that appears on FAILED login (prefix with `F=`) or success (prefix with `S=`)

#### Basic Examples

```bash
# Simple login form
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/login.php:username=^USER^&password=^PASS^:Invalid credentials"

# Using F= prefix for failure string (explicit)
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/login.php:username=^USER^&password=^PASS^:F=Login failed"

# Using S= prefix for success string (when failure message varies)
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/login.php:username=^USER^&password=^PASS^:S=Welcome"
```

#### With Additional Options

```bash
# With custom headers (cookies, referer, etc.)
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/login.php:username=^USER^&password=^PASS^:F=Invalid:H=Cookie: PHPSESSID=abc123"

# Multiple custom headers
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/login.php:username=^USER^&password=^PASS^:F=Invalid:H=Cookie: session=xyz:H=X-Requested-With: XMLHttpRequest"

# With HTTPS
hydra -l admin -P passwords.txt 192.168.1.100 https-post-form \
  "/login:user=^USER^&pass=^PASS^:F=incorrect"

# Following redirects (some apps redirect on failure)
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/login:user=^USER^&pass=^PASS^:F=Invalid:H=Accept-Language: en-US"
```

#### Common Parameter Names

Different applications use different field names:

| Application | Username Field | Password Field |
|-------------|----------------|----------------|
| Generic | `username`, `user`, `login` | `password`, `pass`, `pwd` |
| WordPress | `log` | `pwd` |
| Drupal | `name` | `pass` |
| phpMyAdmin | `pma_username` | `pma_password` |
| Joomla | `username` | `passwd` |
| Django | `username` | `password` |
| DVWA | `username` | `password` |

#### WordPress Example

```bash
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/wp-login.php:log=^USER^&pwd=^PASS^&wp-submit=Log+In:F=incorrect"
```

#### DVWA Example

```bash
# DVWA (Damn Vulnerable Web Application) login
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
  "/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:F=Login failed"
```

#### URL-Encoded Special Characters

When passwords or usernames contain special characters, they must be URL-encoded in the form body:

| Character | URL Encoding |
|-----------|--------------|
| Space | `%20` or `+` |
| `&` | `%26` |
| `=` | `%3D` |
| `?` | `%3F` |
| `#` | `%23` |
| `:` | `%3A` |

---

## Capturing HTTP Parameters from Burp

To correctly craft Hydra HTTP form attacks, capture the actual request using Burp Suite.

### Step-by-Step Process

1. **Configure Burp Proxy**: Set browser to proxy through `127.0.0.1:8080`

2. **Capture Login Request**: Attempt a login and capture the POST request in Burp

3. **Identify Key Elements**:
   - Request path (e.g., `/login.php`)
   - POST body (e.g., `username=test&password=test&submit=Login`)
   - Any required cookies or headers
   - Response content indicating failure (e.g., "Invalid username or password")

4. **Convert to Hydra Command**:

**Example Burp Capture**:
```http
POST /admin/login.php HTTP/1.1
Host: 192.168.1.100
Content-Type: application/x-www-form-urlencoded
Cookie: PHPSESSID=abc123def456
Content-Length: 45

username=admin&password=test123&remember=1&submit=Login
```

**Failed Response Contains**:
```html
<div class="error">Invalid username or password</div>
```

**Resulting Hydra Command**:
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt 192.168.1.100 http-post-form \
  "/admin/login.php:username=^USER^&password=^PASS^&remember=1&submit=Login:F=Invalid username or password:H=Cookie: PHPSESSID=abc123def456"
```

### Tips for Burp Analysis

- Look for CSRF tokens - if present, you'll need to fetch them dynamically (Hydra doesn't handle this well; consider using tools like `wfuzz` or `ffuf` instead)
- Note any JavaScript-based form modifications
- Check if the application uses JSON instead of form-urlencoded data
- Watch for anti-automation measures (CAPTCHAs, rate limiting)

---

## Database Protocols

### MySQL

```bash
# Basic MySQL attack
hydra -l root -P passwords.txt mysql://192.168.1.100

# Custom port
hydra -l root -P passwords.txt -s 3307 mysql://192.168.1.100

# With verbose output
hydra -l dbadmin -P passwords.txt -vV mysql://192.168.1.100
```

**Note**: MySQL root often doesn't allow remote connections by default. Check if `skip-networking` is enabled.

### MSSQL

```bash
# Basic MSSQL attack
hydra -l sa -P passwords.txt mssql://192.168.1.100

# Custom port
hydra -l sa -P passwords.txt -s 1433 mssql://192.168.1.100

# Windows authentication (domain)
hydra -l DOMAIN\\sqladmin -P passwords.txt mssql://192.168.1.100
```

---

## Directory Services

### LDAP

```bash
# LDAP with simple bind
hydra -l "cn=admin,dc=example,dc=com" -P passwords.txt ldap2://192.168.1.100

# LDAP v3
hydra -l "cn=admin,dc=example,dc=com" -P passwords.txt ldap3://192.168.1.100

# LDAPS (LDAP over SSL)
hydra -l "cn=admin,dc=example,dc=com" -P passwords.txt -S ldap3://192.168.1.100
```

**Common LDAP DN Formats**:
- `cn=admin,dc=example,dc=com`
- `uid=admin,ou=users,dc=example,dc=com`
- `DOMAIN\username` (Active Directory)
- `username@domain.com` (UPN format)

---

## Mail Protocols

### IMAP

```bash
# Basic IMAP attack
hydra -l user@domain.com -P passwords.txt imap://mail.domain.com

# IMAPS (IMAP over SSL, port 993)
hydra -l user -P passwords.txt -S imaps://mail.domain.com

# Plain IMAP on custom port
hydra -l user -P passwords.txt -s 143 imap://mail.domain.com
```

### POP3

```bash
# Basic POP3 attack
hydra -l user -P passwords.txt pop3://mail.domain.com

# POP3S (POP3 over SSL, port 995)
hydra -l user -P passwords.txt -S pop3s://mail.domain.com
```

### SMTP

SMTP brute forcing typically targets the AUTH mechanism.

```bash
# Basic SMTP AUTH attack
hydra -l user@domain.com -P passwords.txt smtp://mail.domain.com

# SMTPS (submission port 587 with STARTTLS)
hydra -l user@domain.com -P passwords.txt -s 587 smtp://mail.domain.com

# SMTP enum (user enumeration via VRFY/EXPN)
hydra -L users.txt -p "" smtp-enum://mail.domain.com
```

---

## Speed Tuning

### Thread Control (`-t`)

Controls parallel connections. Default is 16.

```bash
# Aggressive (fast, may trigger lockouts)
hydra -l admin -P passwords.txt -t 64 ssh://192.168.1.100

# Conservative (slower, stealthier)
hydra -l admin -P passwords.txt -t 4 ssh://192.168.1.100

# Single thread (slowest, safest)
hydra -l admin -P passwords.txt -t 1 rdp://192.168.1.100
```

**Recommended Thread Counts**:

| Protocol | Recommended `-t` | Notes |
|----------|------------------|-------|
| SSH | 4-8 | Rate limiting common |
| FTP | 8-16 | Generally stable |
| HTTP-FORM | 16-32 | Depends on server |
| RDP | 1-2 | Very slow protocol |
| VNC | 4-8 | Connection overhead |
| MySQL | 8-16 | Usually stable |

### Wait Time (`-w`)

Maximum time to wait for responses (default: 32 seconds).

```bash
# Faster timeout (for fast networks)
hydra -l admin -P passwords.txt -w 5 ssh://192.168.1.100

# Longer timeout (slow networks, VPNs)
hydra -l admin -P passwords.txt -w 60 ssh://192.168.1.100
```

### Connection Timeout (`-c`)

Time to wait in seconds between connection attempts per thread.

```bash
# Add delay between attempts (avoid rate limiting)
hydra -l admin -P passwords.txt -c 2 ssh://192.168.1.100
```

### Combined Tuning

```bash
# Fast local network attack
hydra -l admin -P passwords.txt -t 32 -w 10 http-post-form://192.168.1.100/login

# Slow, careful attack (evasion)
hydra -l admin -P passwords.txt -t 2 -w 45 -c 3 ssh://10.10.10.100

# Through slow VPN
hydra -l admin -P passwords.txt -t 4 -w 60 smb://10.10.10.100
```

---

## Using with Proxychains

When pivoting through a compromised host or using Tor/SOCKS proxies.

### Basic Usage

```bash
# Through default proxychains configuration
proxychains hydra -l admin -P passwords.txt ssh://10.10.10.100

# With reduced threads (proxy overhead)
proxychains hydra -l admin -P passwords.txt -t 4 ssh://10.10.10.100
```

### Proxychains Configuration

Edit `/etc/proxychains.conf` or `~/.proxychains/proxychains.conf`:

```ini
# For SOCKS5 proxy (e.g., ligolo-ng, chisel)
[ProxyList]
socks5 127.0.0.1 1080

# For Tor
[ProxyList]
socks4 127.0.0.1 9050
```

### Through SSH SOCKS Proxy

```bash
# Create SOCKS proxy via SSH
ssh -D 1080 -N user@pivot-host &

# Use with proxychains
proxychains hydra -l admin -P passwords.txt -t 4 ssh://internal-target
```

### Through Chisel/Ligolo-ng

```bash
# After setting up chisel/ligolo tunnel on port 1080
proxychains hydra -l admin -P passwords.txt -t 4 smb://192.168.1.100
```

### Performance Considerations

When using proxychains:
- Reduce thread count (`-t 4` or lower)
- Increase wait time (`-w 45` or higher)
- Expect significantly slower speeds
- Some protocols may not work well through proxies

```bash
# Optimized for proxy use
proxychains hydra -l admin -P passwords.txt -t 2 -w 60 ssh://10.10.10.100
```

---

## Custom Wordlists

### Using Standard Wordlists

```bash
# Kali Linux default wordlists
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.100
hydra -l admin -P /usr/share/wordlists/fasttrack.txt ftp://192.168.1.100
hydra -L /usr/share/seclists/Usernames/top-usernames-shortlist.txt -P passwords.txt ssh://192.168.1.100
```

### Custom Wordlist Paths

```bash
# From SecLists
hydra -l admin -P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt ssh://192.168.1.100

# Custom generated wordlist
hydra -l admin -P ./custom_passwords.txt http-post-form://192.168.1.100/login
```

### Combo Files (`-C`)

Colon-separated username:password format for credential stuffing.

```bash
# Create combo file
# admin:password123
# root:toor
# user:letmein

hydra -C combos.txt ssh://192.168.1.100
```

### Generating Custom Wordlists

```bash
# Using crunch
crunch 6 8 abcdefghijklmnopqrstuvwxyz0123456789 -o custom.txt

# Using CeWL for website-specific words
cewl https://target.com -d 2 -m 5 -w custom.txt

# Combine with Hydra
hydra -l admin -P custom.txt http-post-form://target.com/login:user=^USER^&pass=^PASS^:F=failed
```

### Username Generation

```bash
# Common usernames
hydra -L /usr/share/seclists/Usernames/cirt-default-usernames.txt -p Password1 ssh://192.168.1.100

# From names (first.last, flast, etc.)
# Use username-anarchy or similar tools first
./username-anarchy --input-file names.txt --select-format first.last > usernames.txt
hydra -L usernames.txt -P passwords.txt ssh://192.168.1.100
```

---

## Session Management

### Save and Restore Sessions

```bash
# Session file is created automatically on interruption
# Restore with -R
hydra -R

# Specify session file
hydra -o results.txt -b text ...  # Saves to hydra.restore by default
```

### Output Formats

```bash
# Text output
hydra -l admin -P passwords.txt -o results.txt ssh://192.168.1.100

# JSON output
hydra -l admin -P passwords.txt -o results.json -b json ssh://192.168.1.100

# JSON lines (one JSON object per line)
hydra -l admin -P passwords.txt -o results.jsonl -b jsonlines ssh://192.168.1.100
```

---

## Common Pitfalls

### HTTP Form Attacks

1. **Wrong failure string**: Test manually first to get exact error message
2. **Missing cookies/tokens**: Some forms require session cookies
3. **CSRF tokens**: Hydra doesn't handle dynamic tokens - use other tools
4. **JavaScript-only forms**: Hydra can't execute JavaScript
5. **Colon in passwords**: Use `\:` to escape or avoid wordlists with colons

### General Issues

1. **Too many threads**: Causes connection failures and false negatives
2. **Firewall blocks**: Reduce threads and add delays
3. **Account lockouts**: Use `-t 1` and `-c` with delays
4. **SSL/TLS issues**: Use `-S` flag and possibly `-O` for older SSL

### Protocol-Specific

| Protocol | Common Issue | Solution |
|----------|--------------|----------|
| SSH | Rate limiting | `-t 4` or lower |
| RDP | NLA failures | Ensure correct domain format |
| SMB | SMBv1 disabled | Use `smb2://` |
| MySQL | Remote login disabled | Check MySQL config |
| HTTP Form | CSRF tokens | Use `ffuf` or `wfuzz` instead |
