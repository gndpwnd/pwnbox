# feroxbuster - Advanced Techniques

## Table of Contents

- [Recursive Scanning Configuration](#recursive-scanning-configuration)
- [Auto-Calibration Features](#auto-calibration-features)
- [Filter Options](#filter-options)
- [Extension Handling](#extension-handling)
- [Resume Capability](#resume-capability)
- [Output Formats](#output-formats)
- [Practical Examples](#practical-examples)
- [Feroxbuster vs Gobuster Comparison](#feroxbuster-vs-gobuster-comparison)

---

## Recursive Scanning Configuration

Feroxbuster's recursive scanning is one of its most powerful features, automatically discovering and scanning subdirectories.

### Depth Control

```bash
# Default recursion depth is 4
feroxbuster -u http://target.com

# Set custom depth (1 = scan only base URL, no recursion into subdirectories)
feroxbuster -u http://target.com -d 2

# Deep recursion for thorough scanning
feroxbuster -u http://target.com -d 10

# Disable recursion entirely
feroxbuster -u http://target.com -n
# or
feroxbuster -u http://target.com --no-recursion
```

### Limiting Scan Scope

```bash
# Limit total number of requests
feroxbuster -u http://target.com -L 10000
# or
feroxbuster -u http://target.com --scan-limit 10000

# Time limit for entire scan (in seconds)
feroxbuster -u http://target.com --time-limit 3600

# Force recursion even when response doesn't indicate a directory
feroxbuster -u http://target.com --force-recursion
```

### Controlling Recursion Behavior

```bash
# Only recurse into directories matching a pattern
feroxbuster -u http://target.com --dont-scan "logout|signout|exit"

# Collect URLs but don't scan them (for later analysis)
feroxbuster -u http://target.com --collect-backups --collect-words
```

---

## Auto-Calibration Features

Auto-calibration helps feroxbuster automatically detect and filter out false positives by analyzing baseline responses.

### Basic Auto-Calibration

```bash
# Enable auto-calibration (--auto-tune or --smart)
feroxbuster -u http://target.com --auto-tune

# Auto-calibration with custom number of calibration requests
feroxbuster -u http://target.com --auto-tune

# Enable auto-filtering based on similar responses
feroxbuster -u http://target.com --auto-bail
```

### How Auto-Calibration Works

1. Feroxbuster sends requests to random non-existent paths
2. Analyzes the response characteristics (size, words, lines)
3. Creates filters to exclude responses matching the baseline
4. Continues scanning while filtering out matches

### Combining with Manual Filters

```bash
# Auto-calibration with additional manual size filter
feroxbuster -u http://target.com --auto-tune -S 1234

# Auto-calibration with status code filtering
feroxbuster -u http://target.com --auto-tune -C 404,500
```

---

## Filter Options

Feroxbuster provides extensive filtering capabilities to reduce noise and focus on relevant results.

### Size Filtering

```bash
# Filter responses by size (bytes)
feroxbuster -u http://target.com -S 0
feroxbuster -u http://target.com --filter-size 0

# Filter multiple sizes
feroxbuster -u http://target.com -S 0,1234,5678

# Filter range of sizes
feroxbuster -u http://target.com -S 0-100
```

### Word Count Filtering

```bash
# Filter by number of words in response
feroxbuster -u http://target.com -W 10
feroxbuster -u http://target.com --filter-words 10

# Multiple word counts
feroxbuster -u http://target.com -W 10,20,30
```

### Line Count Filtering

```bash
# Filter by number of lines
feroxbuster -u http://target.com -N 5
feroxbuster -u http://target.com --filter-lines 5

# Multiple line counts
feroxbuster -u http://target.com -N 5,10,15
```

### Regex Filtering

```bash
# Filter responses matching regex pattern
feroxbuster -u http://target.com --filter-regex "Page not found"

# Filter by regex in response body
feroxbuster -u http://target.com --filter-regex "404|error|not found"

# Case-insensitive regex
feroxbuster -u http://target.com --filter-regex "(?i)access denied"
```

### Status Code Filtering

```bash
# Only show specific status codes (whitelist)
feroxbuster -u http://target.com -s 200,301,302

# Filter out specific status codes (blacklist)
feroxbuster -u http://target.com -C 404,500
feroxbuster -u http://target.com --filter-status 404,500

# Common combination
feroxbuster -u http://target.com -C 404,403,500,502,503
```

### Similarity Filtering

```bash
# Filter based on response similarity percentage
feroxbuster -u http://target.com --filter-similar-to http://target.com/known-page
```

### Combining Multiple Filters

```bash
# Multiple filters for precise results
feroxbuster -u http://target.com \
    -C 404 \
    -S 0 \
    -W 10 \
    --filter-regex "not found"
```

---

## Extension Handling

### Basic Extension Scanning

```bash
# Scan for specific extensions
feroxbuster -u http://target.com -x php,html,js,txt

# Common web extensions
feroxbuster -u http://target.com -x php,asp,aspx,jsp,html,js,txt,xml,json

# Backup file extensions
feroxbuster -u http://target.com -x bak,old,backup,swp,~

# Combined approach
feroxbuster -u http://target.com -x php,html,js,txt,bak,old,zip
```

### Extension-Specific Strategies

```bash
# PHP application
feroxbuster -u http://target.com -x php,php3,php4,php5,phtml,inc

# ASP.NET application
feroxbuster -u http://target.com -x asp,aspx,ashx,asmx,config

# Java application
feroxbuster -u http://target.com -x jsp,jspx,do,action,jsf

# Configuration files
feroxbuster -u http://target.com -x conf,config,cfg,ini,env,yml,yaml,xml,json
```

### No Extension Mode

```bash
# Don't append extensions to wordlist entries that already have extensions
feroxbuster -u http://target.com -x php --dont-extract-links

# Only scan exact wordlist entries (no extensions added)
feroxbuster -u http://target.com --no-extension
```

### Add Slash Option

```bash
# Append slash to each request (useful for directory detection)
feroxbuster -u http://target.com --add-slash
```

---

## Resume Capability

Feroxbuster can save and resume scans, which is invaluable for long-running operations.

### State File Management

```bash
# Specify state file location
feroxbuster -u http://target.com --state-file /path/to/scan.state

# Resume from a previous scan
feroxbuster --resume-from /path/to/scan.state
```

### Automatic State Saving

Feroxbuster automatically saves state when:
- The scan is interrupted (Ctrl+C)
- An error occurs
- The `--state-file` option is specified

### Interactive Commands During Scan

While a scan is running, you can use keyboard shortcuts:
- `Enter` - Show current status
- `+` - Increase verbosity
- `-` - Decrease verbosity
- `q` - Graceful quit (saves state)

---

## Output Formats

### Standard Output Options

```bash
# Output to file (default format)
feroxbuster -u http://target.com -o results.txt

# JSON output
feroxbuster -u http://target.com -o results.json --json

# Quiet mode (only URLs)
feroxbuster -u http://target.com -q

# Silent mode (minimal output, good for piping)
feroxbuster -u http://target.com --silent
```

### Output File Formats

```bash
# Plain text (default)
feroxbuster -u http://target.com -o results.txt

# JSON format for parsing
feroxbuster -u http://target.com -o results.json --json

# Combine with grep-friendly output
feroxbuster -u http://target.com --silent | tee urls.txt
```

### Verbosity Control

```bash
# Verbose output (show more details)
feroxbuster -u http://target.com -v

# Very verbose
feroxbuster -u http://target.com -vv

# Debug output
feroxbuster -u http://target.com --debug-log debug.log
```

---

## Practical Examples

### Optimal Settings for CTFs

```bash
# Fast aggressive scan for CTF environments
feroxbuster -u http://target.com \
    -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
    -x php,txt,html,bak \
    -t 100 \
    -d 3 \
    --auto-tune \
    -C 404

# Quick initial recon
feroxbuster -u http://target.com \
    -w /usr/share/seclists/Discovery/Web-Content/common.txt \
    -t 200 \
    --dont-scan "logout" \
    -s 200,301,302,401,403

# Thorough CTF scan with all common extensions
feroxbuster -u http://target.com \
    -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt \
    -x php,html,txt,js,bak,old,zip,json,xml \
    -t 150 \
    -d 4 \
    --auto-tune \
    -o ctf-results.txt
```

### Handling Slow Targets

```bash
# Reduced thread count and increased timeout
feroxbuster -u http://slow-target.com \
    -t 10 \
    --timeout 30 \
    -w /path/to/wordlist.txt

# Very slow target with rate limiting
feroxbuster -u http://rate-limited.com \
    -t 5 \
    --timeout 60 \
    --rate-limit 10

# Scan with time limit to avoid endless waits
feroxbuster -u http://unstable-target.com \
    -t 20 \
    --timeout 20 \
    --time-limit 1800

# Slow target with retry on failure
feroxbuster -u http://flaky-target.com \
    -t 10 \
    --timeout 30 \
    --parallel 2
```

### Filtering Out False Positives

```bash
# Filter common false positive patterns
feroxbuster -u http://target.com \
    -C 404 \
    --filter-regex "Page not found|Error 404|Resource unavailable" \
    --auto-tune

# Filter by response size (common for WAF/error pages)
feroxbuster -u http://target.com \
    -S 0,1234 \
    -W 50 \
    --auto-tune

# Complex filtering for noisy targets
feroxbuster -u http://target.com \
    -C 404,500,502,503 \
    -S 0 \
    -N 1,2,3 \
    --filter-regex "maintenance|error|denied" \
    --auto-tune

# Filter based on similarity to known error page
feroxbuster -u http://target.com \
    --filter-similar-to http://target.com/nonexistent-page-12345
```

### Using with Proxychains

```bash
# Through SOCKS proxy (proxychains style)
proxychains4 -q feroxbuster -u http://internal-target.com \
    -t 10 \
    --timeout 30

# Direct SOCKS5 proxy support (recommended)
feroxbuster -u http://internal-target.com \
    --proxy socks5://127.0.0.1:1080 \
    -t 10 \
    --timeout 30

# Through Burp Suite for analysis
feroxbuster -u http://target.com \
    --proxy http://127.0.0.1:8080 \
    --insecure \
    -t 20

# Tor network scanning
feroxbuster -u http://onionsite.onion \
    --proxy socks5://127.0.0.1:9050 \
    -t 5 \
    --timeout 60

# Corporate proxy with authentication
feroxbuster -u http://target.com \
    --proxy http://user:pass@proxy.corp.com:8080 \
    --insecure
```

### Configuration File Usage

Feroxbuster supports TOML configuration files for persistent settings.

#### Default Config Location

- Linux: `~/.config/feroxbuster/ferox-config.toml`
- macOS: `~/Library/Application Support/feroxbuster/ferox-config.toml`
- Windows: `%APPDATA%\feroxbuster\ferox-config.toml`

#### Sample Configuration File

```toml
# ferox-config.toml

# Target and wordlist settings
wordlist = "/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt"
threads = 50
timeout = 10
depth = 4

# Extensions to check
extensions = ["php", "html", "js", "txt"]

# Status codes to include
status_codes = [200, 204, 301, 302, 307, 308, 401, 403, 405, 500]

# Filters
filter_status = [404]
filter_size = [0]

# Headers
headers = ["User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"]

# Proxy settings (uncomment as needed)
# proxy = "http://127.0.0.1:8080"
# insecure = true

# Output settings
output = "/tmp/ferox-results.txt"
json = false
quiet = false

# Recursion settings
no_recursion = false
force_recursion = false

# Scan limits
scan_limit = 0
rate_limit = 0
time_limit = "0"

# Auto-tuning
auto_tune = true
auto_bail = false

# Other options
redirects = false
add_slash = false
extract_links = true
collect_words = false
collect_backups = true
```

#### Using Custom Config File

```bash
# Use specific config file
feroxbuster -u http://target.com --config /path/to/custom-config.toml

# Override config file settings with CLI args
feroxbuster -u http://target.com --config /path/to/config.toml -t 100 -d 2
```

#### CTF-Optimized Config

```toml
# ctf-config.toml
wordlist = "/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt"
threads = 100
timeout = 10
depth = 4
extensions = ["php", "txt", "html", "bak", "old", "zip", "js"]
filter_status = [404]
auto_tune = true
extract_links = true
collect_backups = true
```

#### Stealth Config

```toml
# stealth-config.toml
wordlist = "/usr/share/seclists/Discovery/Web-Content/common.txt"
threads = 5
timeout = 30
depth = 2
rate_limit = 5
headers = [
    "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language: en-US,en;q=0.5"
]
random_agent = true
```

---

## Feroxbuster vs Gobuster Comparison

### Feature Comparison Table

| Feature | Feroxbuster | Gobuster |
|---------|-------------|----------|
| **Language** | Rust | Go |
| **Recursive Scanning** | Built-in automatic | Not supported |
| **Auto-Calibration** | Yes (`--auto-tune`) | No |
| **Resume Capability** | Yes (state files) | No |
| **Filter by Size** | Yes (`-S`) | Yes (`--exclude-length`) |
| **Filter by Words** | Yes (`-W`) | No |
| **Filter by Lines** | Yes (`-N`) | No |
| **Filter by Regex** | Yes (`--filter-regex`) | No |
| **Similarity Filtering** | Yes | No |
| **Config Files** | TOML support | No |
| **Interactive Controls** | Yes (during scan) | No |
| **Link Extraction** | Yes (from HTML) | No |
| **Backup Collection** | Yes | No |
| **DNS Mode** | No | Yes |
| **VHost Mode** | No | Yes |
| **S3/GCS Bucket Enum** | No | Yes |
| **TFTP Mode** | No | Yes |
| **Fuzz Mode** | No | Yes (with FUZZ keyword) |
| **Multiple Modes** | Web only | dir, dns, vhost, s3, gcs, tftp, fuzz |

### When to Use Feroxbuster

1. **Deep web content discovery** - Automatic recursion finds nested directories
2. **Noisy targets** - Auto-calibration and advanced filters reduce false positives
3. **Long scans** - Resume capability prevents lost progress
4. **Consistent settings** - Config files ensure reproducible scans
5. **Link extraction** - Discovers additional paths from HTML responses
6. **CTF environments** - Fast, aggressive scanning with smart filtering

### When to Use Gobuster

1. **DNS enumeration** - Subdomain discovery (`dns` mode)
2. **Virtual host discovery** - VHost enumeration (`vhost` mode)
3. **Cloud bucket enumeration** - S3/GCS bucket finding
4. **TFTP enumeration** - TFTP file discovery
5. **Custom fuzzing** - Using FUZZ keyword for parameter fuzzing
6. **Simple directory scans** - When you don't need recursion

### Example: Equivalent Commands

```bash
# Basic directory scan
# Feroxbuster
feroxbuster -u http://target.com -w wordlist.txt -x php,html

# Gobuster
gobuster dir -u http://target.com -w wordlist.txt -x php,html

# With size filtering
# Feroxbuster
feroxbuster -u http://target.com -w wordlist.txt -S 0

# Gobuster
gobuster dir -u http://target.com -w wordlist.txt --exclude-length 0

# Recursive scan (feroxbuster advantage)
# Feroxbuster - automatic recursion
feroxbuster -u http://target.com -w wordlist.txt -d 4

# Gobuster - would need to manually scan each discovered directory
gobuster dir -u http://target.com -w wordlist.txt
# Then run again for each subdirectory found
```

### Combined Workflow

For comprehensive enumeration, use both tools:

```bash
# 1. DNS enumeration with gobuster
gobuster dns -d target.com -w subdomains.txt -o subdomains.txt

# 2. VHost discovery with gobuster
gobuster vhost -u http://target.com -w vhosts.txt --append-domain

# 3. Deep web content discovery with feroxbuster
feroxbuster -u http://target.com \
    -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
    -x php,html,txt \
    --auto-tune \
    -o web-content.txt
```

---

## Quick Reference

### Most Useful Flag Combinations

```bash
# CTF speed run
feroxbuster -u URL -w WORDLIST -x php,txt,html -t 100 --auto-tune -C 404

# Stealth scan
feroxbuster -u URL -w WORDLIST -t 5 --rate-limit 5 --timeout 30 --random-agent

# Thorough scan
feroxbuster -u URL -w WORDLIST -x php,html,js,txt,bak -d 6 --auto-tune --collect-backups

# Quick recon
feroxbuster -u URL --silent -t 150 | tee discovered-urls.txt

# Proxy chain
feroxbuster -u URL --proxy socks5://127.0.0.1:1080 -t 10 --timeout 30

# Resume failed scan
feroxbuster --resume-from scan.state
```

### Filter Cheat Sheet

| Filter | Flag | Example |
|--------|------|---------|
| Size | `-S` | `-S 0,1234` |
| Words | `-W` | `-W 10,20` |
| Lines | `-N` | `-N 5` |
| Status (exclude) | `-C` | `-C 404,500` |
| Status (include) | `-s` | `-s 200,301` |
| Regex | `--filter-regex` | `--filter-regex "error"` |
| Similarity | `--filter-similar-to` | `--filter-similar-to URL` |

---

## Resources

- [Official Documentation](https://epi052.github.io/feroxbuster-docs/)
- [GitHub Repository](https://github.com/epi052/feroxbuster)
- [SecLists Wordlists](https://github.com/danielmiessler/SecLists)
- [Comparison with other tools](https://epi052.github.io/feroxbuster-docs/docs/compare/)
