# ffuf - Fuzzing Techniques

## Table of Contents

- [Directory and File Discovery](#directory-and-file-discovery)
- [Parameter Fuzzing](#parameter-fuzzing)
- [Virtual Host Discovery](#virtual-host-discovery)
- [Subdomain Enumeration](#subdomain-enumeration)
- [POST Data Fuzzing](#post-data-fuzzing)
- [Header Fuzzing](#header-fuzzing)
- [Multiple Wordlists](#multiple-wordlists)
- [Filtering Options](#filtering-options)
- [Matching Options](#matching-options)
- [Rate Limiting](#rate-limiting)
- [Recursive Scanning](#recursive-scanning)
- [Advanced Techniques](#advanced-techniques)
- [Practical Examples](#practical-examples)

---

## Directory and File Discovery

Basic content discovery is ffuf's primary use case.

### Basic Directory Scan

```bash
# Simple scan
ffuf -u http://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt

# With common extensions
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.html,.txt,.js,.bak

# Filter 404 responses
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404

# Case-insensitive matching (lowercase wordlist entries)
ffuf -u http://target.com/FUZZ -w wordlist.txt -ic
```

### Extension Scanning

```bash
# Multiple extensions
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.asp,.aspx,.jsp,.html

# PHP-focused
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.php3,.php4,.php5,.phtml,.inc

# Backup files
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .bak,.old,.backup,.swp,~,.save

# Configuration files
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .conf,.config,.cfg,.ini,.env,.yml,.yaml,.xml,.json
```

### Focused Discovery

```bash
# API endpoints
ffuf -u http://target.com/api/FUZZ -w api-endpoints.txt

# Admin panels
ffuf -u http://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/AdminPanels.txt

# Common backup locations
ffuf -u http://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/CommonBackdoors.txt
```

---

## Parameter Fuzzing

Discover hidden GET and POST parameters.

### GET Parameter Discovery

```bash
# Find hidden parameters
ffuf -u "http://target.com/page?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt

# Parameter value fuzzing
ffuf -u "http://target.com/page?id=FUZZ" -w numbers.txt

# Multiple parameters
ffuf -u "http://target.com/page?user=FUZZ&role=FUZ2Z" -w users.txt:FUZZ -w roles.txt:FUZ2Z

# Filter by response size (find different responses)
ffuf -u "http://target.com/page?debug=FUZZ" -w values.txt -fs 1234
```

### IDOR Testing

```bash
# Numeric ID fuzzing
ffuf -u "http://target.com/api/users/FUZZ" -w <(seq 1 1000) -mc 200

# UUID fuzzing
ffuf -u "http://target.com/api/documents/FUZZ" -w uuids.txt -mc 200

# With authentication
ffuf -u "http://target.com/api/users/FUZZ/profile" -w ids.txt \
    -H "Authorization: Bearer TOKEN" -mc 200,403
```

### Hidden Form Fields

```bash
# Discover hidden form parameters
ffuf -u http://target.com/form -X POST \
    -d "known_param=value&FUZZ=test" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -w params.txt -fs 1234
```

---

## Virtual Host Discovery

Enumerate virtual hosts on a target server.

### Basic VHost Discovery

```bash
# Discover subdomains as vhosts
ffuf -u http://target.com -H "Host: FUZZ.target.com" \
    -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# Filter by size (common false positive filter)
ffuf -u http://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fs 0

# Filter by word count
ffuf -u http://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fw 100
```

### IP-Based VHost Discovery

```bash
# When you have an IP but no domain
ffuf -u http://10.10.10.10 -H "Host: FUZZ.target.htb" -w subdomains.txt -fs 1234

# Auto-calibration for better filtering
ffuf -u http://10.10.10.10 -H "Host: FUZZ.target.htb" -w subdomains.txt -ac
```

### Internal VHost Discovery

```bash
# Discover internal applications
ffuf -u http://internal-server -H "Host: FUZZ" \
    -w /usr/share/seclists/Discovery/DNS/namelist.txt -fs 0

# With custom TLD
ffuf -u http://10.10.10.10 -H "Host: FUZZ.corp.local" -w subdomains.txt -ac
```

---

## Subdomain Enumeration

DNS-based subdomain discovery using ffuf.

### Basic Subdomain Scan

```bash
# Direct subdomain fuzzing
ffuf -u http://FUZZ.target.com -w subdomains.txt -mc 200,301,302,403

# With timeout for slow DNS
ffuf -u http://FUZZ.target.com -w subdomains.txt -timeout 5

# Filter timeout errors
ffuf -u http://FUZZ.target.com -w subdomains.txt -mc all -fc 0
```

### HTTPS Subdomain Discovery

```bash
# HTTPS with common ports
ffuf -u https://FUZZ.target.com -w subdomains.txt -mc 200,301,302,403

# Ignore SSL errors
ffuf -u https://FUZZ.target.com -w subdomains.txt -k
```

### Recursive Subdomain Discovery

```bash
# First level
ffuf -u http://FUZZ.target.com -w subdomains.txt -o level1.json -of json

# Second level (after analyzing level1)
ffuf -u http://FUZZ.subdomain.target.com -w subdomains.txt
```

---

## POST Data Fuzzing

Fuzz POST request bodies for authentication bypass, injection points, and more.

### Login Form Fuzzing

```bash
# Password brute force
ffuf -u http://target.com/login -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=FUZZ" \
    -w /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt \
    -fc 401

# Username enumeration
ffuf -u http://target.com/login -X POST \
    -d "username=FUZZ&password=invalid" \
    -w /usr/share/seclists/Usernames/Names/names.txt \
    -fr "Invalid username"

# Both username and password
ffuf -u http://target.com/login -X POST \
    -d "username=FUZZ&password=FUZ2Z" \
    -w users.txt:FUZZ -w passwords.txt:FUZ2Z -mode pitchfork
```

### JSON Body Fuzzing

```bash
# JSON API login
ffuf -u http://target.com/api/login -X POST \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"FUZZ"}' \
    -w passwords.txt -fc 401

# JSON parameter discovery
ffuf -u http://target.com/api/action -X POST \
    -H "Content-Type: application/json" \
    -d '{"FUZZ":"value"}' \
    -w params.txt -fs 0

# Nested JSON
ffuf -u http://target.com/api/user -X POST \
    -H "Content-Type: application/json" \
    -d '{"user":{"role":"FUZZ"}}' \
    -w roles.txt
```

### Form Multipart Fuzzing

```bash
# File upload bypass
ffuf -u http://target.com/upload -X POST \
    -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary" \
    -d $'------WebKitFormBoundary\r\nContent-Disposition: form-data; name="file"; filename="test.FUZZ"\r\nContent-Type: application/octet-stream\r\n\r\ntest\r\n------WebKitFormBoundary--' \
    -w extensions.txt
```

---

## Header Fuzzing

Discover functionality hidden behind specific headers.

### Custom Header Discovery

```bash
# X-Forwarded headers
ffuf -u http://target.com/admin -H "X-Forwarded-For: FUZZ" \
    -w /usr/share/seclists/Fuzzing/special-chars.txt

# Authorization bypass headers
ffuf -u http://target.com/admin -H "FUZZ: 127.0.0.1" \
    -w headers.txt -fc 403

# Common bypass headers
for header in "X-Forwarded-For" "X-Real-IP" "X-Originating-IP" "X-Remote-IP" "X-Client-IP"; do
    ffuf -u http://target.com/admin -H "$header: 127.0.0.1" -w /dev/null
done
```

### Authentication Header Fuzzing

```bash
# JWT token fuzzing
ffuf -u http://target.com/api/admin -H "Authorization: Bearer FUZZ" \
    -w tokens.txt -mc 200

# Basic auth
ffuf -u http://target.com/admin -H "Authorization: Basic FUZZ" \
    -w base64-creds.txt -fc 401

# API key discovery
ffuf -u http://target.com/api/data -H "X-API-Key: FUZZ" \
    -w apikeys.txt -fc 403
```

### User-Agent Fuzzing

```bash
# Discover mobile/bot-specific content
ffuf -u http://target.com/page -H "User-Agent: FUZZ" \
    -w /usr/share/seclists/Fuzzing/User-Agents/user-agents.txt \
    -fs 1234
```

---

## Multiple Wordlists

Use multiple FUZZ keywords for complex fuzzing scenarios.

### Keyword Syntax

```bash
# Default keywords: FUZZ, FUZ2Z, FUZ3Z, etc.
# Custom keywords with -w wordlist:KEYWORD syntax

# Two wordlists with custom keywords
ffuf -u http://target.com/USERS/FILES -w users.txt:USERS -w files.txt:FILES

# Three wordlists
ffuf -u http://target.com/FUZZ/FUZ2Z/FUZ3Z \
    -w dirs.txt:FUZZ -w subdirs.txt:FUZ2Z -w files.txt:FUZ3Z
```

### Clusterbomb Mode (Default)

Tests all combinations of wordlist entries.

```bash
# All combinations of users and passwords
ffuf -u http://target.com/login -X POST \
    -d "user=FUZZ&pass=FUZ2Z" \
    -w users.txt:FUZZ -w passwords.txt:FUZ2Z \
    -mode clusterbomb

# Directory + filename combinations
ffuf -u http://target.com/FUZZ/FUZ2Z \
    -w dirs.txt:FUZZ -w files.txt:FUZ2Z
```

### Pitchfork Mode

Tests wordlist entries in parallel (line by line).

```bash
# Credential pairs (user1:pass1, user2:pass2, etc.)
ffuf -u http://target.com/login -X POST \
    -d "user=FUZZ&pass=FUZ2Z" \
    -w users.txt:FUZZ -w passwords.txt:FUZ2Z \
    -mode pitchfork

# Known user:password pairs
ffuf -u http://target.com/login -X POST \
    -d "username=USER&password=PASS" \
    -w users.txt:USER -w passwords.txt:PASS \
    -mode pitchfork
```

---

## Filtering Options

Remove unwanted results from output.

### Filter by Status Code (-fc)

```bash
# Filter 404 Not Found
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404

# Filter multiple codes
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 404,403,500

# Filter range
ffuf -u http://target.com/FUZZ -w wordlist.txt -fc 400-499
```

### Filter by Response Size (-fs)

```bash
# Filter exact size
ffuf -u http://target.com/FUZZ -w wordlist.txt -fs 1234

# Filter multiple sizes
ffuf -u http://target.com/FUZZ -w wordlist.txt -fs 0,1234,5678

# Common for vhost discovery
ffuf -u http://target.com -H "Host: FUZZ.target.com" -w subdomains.txt -fs 0
```

### Filter by Word Count (-fw)

```bash
# Filter by word count
ffuf -u http://target.com/FUZZ -w wordlist.txt -fw 100

# Filter multiple word counts
ffuf -u http://target.com/FUZZ -w wordlist.txt -fw 50,100,150
```

### Filter by Line Count (-fl)

```bash
# Filter responses with specific line count
ffuf -u http://target.com/FUZZ -w wordlist.txt -fl 10

# Filter multiple line counts
ffuf -u http://target.com/FUZZ -w wordlist.txt -fl 5,10,15
```

### Filter by Regex (-fr)

```bash
# Filter responses containing pattern
ffuf -u http://target.com/FUZZ -w wordlist.txt -fr "Page not found"

# Case insensitive
ffuf -u http://target.com/FUZZ -w wordlist.txt -fr "(?i)error"

# Filter authentication failures
ffuf -u http://target.com/login -X POST -d "user=admin&pass=FUZZ" \
    -w passwords.txt -fr "Invalid credentials"
```

### Filter by Response Time (-ft)

```bash
# Filter fast responses (< 100ms might be cached/error)
ffuf -u http://target.com/FUZZ -w wordlist.txt -ft "<100"

# Filter slow responses (> 5000ms)
ffuf -u http://target.com/FUZZ -w wordlist.txt -ft ">5000"
```

### Auto-Calibration (-ac)

```bash
# Automatic filter calibration
ffuf -u http://target.com/FUZZ -w wordlist.txt -ac

# Advanced auto-calibration
ffuf -u http://target.com/FUZZ -w wordlist.txt -acc -acs advanced

# Per-host calibration
ffuf -u http://FUZZ.target.com -w subdomains.txt -acc -ach
```

---

## Matching Options

Include only specific responses.

### Match by Status Code (-mc)

```bash
# Match successful codes only
ffuf -u http://target.com/FUZZ -w wordlist.txt -mc 200

# Match multiple codes
ffuf -u http://target.com/FUZZ -w wordlist.txt -mc 200,301,302,403

# Match all codes (then use filters)
ffuf -u http://target.com/FUZZ -w wordlist.txt -mc all -fc 404
```

### Match by Response Size (-ms)

```bash
# Match specific size
ffuf -u http://target.com/FUZZ -w wordlist.txt -ms 5000

# Match range
ffuf -u http://target.com/FUZZ -w wordlist.txt -ms 1000-5000
```

### Match by Word Count (-mw)

```bash
# Match responses with many words (likely real content)
ffuf -u http://target.com/FUZZ -w wordlist.txt -mw ">100"
```

### Match by Line Count (-ml)

```bash
# Match responses with many lines
ffuf -u http://target.com/FUZZ -w wordlist.txt -ml ">50"
```

### Match by Regex (-mr)

```bash
# Match successful login
ffuf -u http://target.com/login -X POST -d "user=admin&pass=FUZZ" \
    -w passwords.txt -mr "Welcome|Dashboard|Success"

# Match specific content
ffuf -u http://target.com/FUZZ -w wordlist.txt -mr "admin|config|backup"
```

### Match by Response Time (-mt)

```bash
# Match slow responses (potential SQL injection)
ffuf -u "http://target.com/page?id=FUZZ" -w sqli-time.txt -mt ">3000"
```

---

## Rate Limiting

Control request rate to avoid detection or server overload.

### Requests Per Second (-rate)

```bash
# Limit to 10 requests per second
ffuf -u http://target.com/FUZZ -w wordlist.txt -rate 10

# Very slow for stealth
ffuf -u http://target.com/FUZZ -w wordlist.txt -rate 2
```

### Delay Between Requests (-p)

```bash
# Fixed delay (seconds)
ffuf -u http://target.com/FUZZ -w wordlist.txt -p 0.5

# Random delay range
ffuf -u http://target.com/FUZZ -w wordlist.txt -p 0.1-0.5

# Combined with reduced threads
ffuf -u http://target.com/FUZZ -w wordlist.txt -p 0.2 -t 5
```

### Thread Control (-t)

```bash
# Reduce threads (default 40)
ffuf -u http://target.com/FUZZ -w wordlist.txt -t 10

# Single thread for sequential requests
ffuf -u http://target.com/FUZZ -w wordlist.txt -t 1

# Increased threads for fast targets
ffuf -u http://target.com/FUZZ -w wordlist.txt -t 100
```

### Timeout Settings

```bash
# Increase timeout for slow targets
ffuf -u http://target.com/FUZZ -w wordlist.txt -timeout 30

# Short timeout to skip hanging requests
ffuf -u http://target.com/FUZZ -w wordlist.txt -timeout 5
```

---

## Recursive Scanning

Automatically discover and scan subdirectories.

### Enable Recursion

```bash
# Basic recursion
ffuf -u http://target.com/FUZZ -w wordlist.txt -recursion

# With depth limit
ffuf -u http://target.com/FUZZ -w wordlist.txt -recursion -recursion-depth 2

# Deep recursion
ffuf -u http://target.com/FUZZ -w wordlist.txt -recursion -recursion-depth 5
```

### Recursion Strategy

```bash
# Recursion with extensions
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.html \
    -recursion -recursion-depth 3

# Recursion with status filtering
ffuf -u http://target.com/FUZZ -w wordlist.txt \
    -recursion -recursion-depth 2 \
    -mc 200,301,302,403 -fc 404
```

### Recursion Performance

```bash
# Balanced recursion
ffuf -u http://target.com/FUZZ -w wordlist.txt \
    -recursion -recursion-depth 3 \
    -t 50 -rate 100

# Conservative recursion (avoid overwhelming target)
ffuf -u http://target.com/FUZZ -w wordlist.txt \
    -recursion -recursion-depth 2 \
    -t 20 -p 0.1
```

---

## Advanced Techniques

### Input from Command

```bash
# Generate sequential numbers
ffuf -u "http://target.com/user/FUZZ" -w <(seq 1 100)

# Generate from command
ffuf -u http://target.com/FUZZ -input-cmd 'cat wordlist.txt | grep admin'
```

### Output Formats

```bash
# JSON output
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.json -of json

# Extended JSON (includes request/response)
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.json -of ejson

# HTML report
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results.html -of html

# Multiple formats
ffuf -u http://target.com/FUZZ -w wordlist.txt -o results -of all
```

### Silent and Verbose Modes

```bash
# Silent mode (only results)
ffuf -u http://target.com/FUZZ -w wordlist.txt -s

# Verbose mode
ffuf -u http://target.com/FUZZ -w wordlist.txt -v

# Very verbose (debug)
ffuf -u http://target.com/FUZZ -w wordlist.txt -debug-log debug.txt
```

### Using Proxies

```bash
# HTTP proxy (Burp Suite)
ffuf -u http://target.com/FUZZ -w wordlist.txt -x http://127.0.0.1:8080

# SOCKS proxy
ffuf -u http://target.com/FUZZ -w wordlist.txt -x socks5://127.0.0.1:1080

# With proxychains
proxychains4 -q ffuf -u http://internal.target/FUZZ -w wordlist.txt
```

### Replay Proxy

```bash
# Send matching results through proxy for further analysis
ffuf -u http://target.com/FUZZ -w wordlist.txt \
    -replay-proxy http://127.0.0.1:8080 \
    -mc 200,403
```

---

## Practical Examples

### CTF Web Challenge

```bash
# Aggressive discovery for CTF
ffuf -u http://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
    -e .php,.txt,.html,.bak \
    -t 100 \
    -recursion -recursion-depth 2 \
    -ac \
    -o ctf-results.json -of json
```

### API Endpoint Discovery

```bash
# REST API enumeration
ffuf -u http://target.com/api/v1/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer TOKEN" \
    -mc 200,201,204,401,403 \
    -o api-results.json -of json
```

### LFI Testing

```bash
# Local file inclusion
ffuf -u "http://target.com/page?file=FUZZ" \
    -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt \
    -fs 0 \
    -mr "root:|password|config"
```

### SQL Injection Point Discovery

```bash
# Time-based SQLi detection
ffuf -u "http://target.com/search?q=FUZZ" \
    -w /usr/share/seclists/Fuzzing/SQLi/quick-SQLi.txt \
    -mt ">3000" \
    -t 10
```

### Stealth Scanning

```bash
# Low and slow enumeration
ffuf -u http://target.com/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/common.txt \
    -t 5 \
    -p 1-3 \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    -fc 404
```

### Cookie-Based Authentication

```bash
# Authenticated scanning
ffuf -u http://target.com/admin/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt \
    -b "session=abc123; auth_token=xyz789" \
    -fc 401,403
```

### Finding Backup Files

```bash
# Backup file discovery
ffuf -u http://target.com/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt \
    -e .bak,.old,.backup,.save,.swp,~,.orig,.copy \
    -fc 404
```

### Complete Enumeration Workflow

```bash
# Step 1: Quick directory scan
ffuf -u http://target.com/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/common.txt \
    -e .php,.html,.txt \
    -o step1.json -of json

# Step 2: VHost discovery
ffuf -u http://target.com -H "Host: FUZZ.target.com" \
    -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
    -ac \
    -o vhosts.json -of json

# Step 3: Deep scan on interesting directories
ffuf -u http://target.com/admin/FUZZ \
    -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
    -recursion -recursion-depth 3 \
    -e .php,.bak,.txt \
    -ac \
    -o admin-deep.json -of json

# Step 4: Parameter fuzzing
ffuf -u "http://target.com/page.php?FUZZ=test" \
    -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
    -fs 1234 \
    -o params.json -of json
```

---

## Resources

- [Official GitHub](https://github.com/ffuf/ffuf)
- [ffuf Wiki](https://github.com/ffuf/ffuf/wiki)
- [SecLists](https://github.com/danielmiessler/SecLists)
- [Assetnote Wordlists](https://wordlists.assetnote.io/)
