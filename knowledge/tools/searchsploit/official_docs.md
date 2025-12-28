---
title: "SearchSploit - Official Documentation Reference"
category: "tools"
tags: ["exploit-db", "exploits", "searchsploit"]
last_updated: "2025-12-27"
---

# SearchSploit - Official Documentation Reference

> Command-line search tool for Exploit-DB - a comprehensive archive of public exploits, shellcode, and security papers.

SearchSploit is the offline search utility for Exploit-DB, maintained by Offensive Security. It enables security researchers and penetration testers to quickly search through a local copy of Exploit-DB, making it invaluable for vulnerability research in air-gapped or restricted environments.

---

## Table of Contents

- [Installation and Setup](#installation-and-setup)
- [Database Updates](#database-updates)
- [Basic Search Syntax](#basic-search-syntax)
- [Advanced Search Options](#advanced-search-options)
- [Examining and Copying Exploits](#examining-and-copying-exploits)
- [Nmap Integration](#nmap-integration)
- [Output Formats](#output-formats)
- [Filtering by Platform and Type](#filtering-by-platform-and-type)
- [Online vs Offline Searching](#online-vs-offline-searching)
- [Complete Command Reference](#complete-command-reference)
- [Practical Workflows and Examples](#practical-workflows-and-examples)

---

## Installation and Setup

### Package Manager Installation

```bash
# Kali Linux (pre-installed)
searchsploit --help

# Debian/Ubuntu
sudo apt update && sudo apt install exploitdb

# Arch Linux
sudo pacman -S exploitdb

# macOS (Homebrew)
brew install exploitdb

# Fedora/RHEL
sudo dnf install exploitdb
```

### Manual Installation from Git

```bash
# Clone the official repository
git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb

# Create symbolic link for global access
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

# Alternatively, from GitHub mirror
git clone https://github.com/offensive-security/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit
```

### Directory Structure

```
/usr/share/exploitdb/              # Default database root (Kali/Debian)
/opt/exploitdb/                    # Manual installation root
    |-- exploits/                  # Exploit files organized by platform/type
    |   |-- linux/
    |   |-- windows/
    |   |-- multiple/
    |   |-- php/
    |   |-- ...
    |-- shellcodes/                # Shellcode files
    |-- papers/                    # Security research papers
    |-- files_exploits.csv         # Exploit database index
    |-- files_shellcodes.csv       # Shellcode database index
    |-- searchsploit               # The search script
    |-- .searchsploit_rc           # Configuration template
```

### Configuration File

The configuration file controls paths and behavior:

```bash
# User configuration location
~/.searchsploit_rc

# System-wide configuration
/etc/searchsploit.rc

# View current configuration
searchsploit --colour
```

**Configuration Options:**

```bash
# Example .searchsploit_rc content
git_exploitdb="/opt/exploitdb"
path_array+=("/opt/exploitdb/exploits")
path_array+=("/opt/exploitdb/shellcodes")

# CSV file paths
files_exploitdb_csv="/opt/exploitdb/files_exploits.csv"
files_shellcode_csv="/opt/exploitdb/files_shellcodes.csv"

# Color output
colour_enable=1
```

### Verifying Installation

```bash
# Check installation
searchsploit -h

# View version and stats
searchsploit --version

# Check database statistics
searchsploit --stats
```

---

## Database Updates

### Updating the Exploit Database

The local exploit database should be updated regularly to include newly published exploits and CVEs.

```bash
# Update exploit database (recommended before every assessment)
searchsploit -u
searchsploit --update

# The update process:
# 1. Performs git pull on the exploitdb repository
# 2. Downloads new exploits, shellcode, and papers
# 3. Updates the CSV index files
```

### Update Recommendations

| Scenario | Recommendation |
|----------|----------------|
| Before engagement | Always run `searchsploit -u` |
| Weekly | Recommended for active researchers |
| Air-gapped systems | Export database to portable media |
| First install | Required to populate database |

### Checking Database Statistics

```bash
# View database statistics
searchsploit --stats

# Example output:
# Exploits: 45,000+
# Shellcode: 1,500+
# Papers: 200+
```

### Manual Database Sync

```bash
# Navigate to exploitdb directory
cd /opt/exploitdb    # or /usr/share/exploitdb

# Manual git pull
git pull origin main

# For manual installations, ensure proper permissions
sudo chown -R $USER:$USER /opt/exploitdb
```

---

## Basic Search Syntax

### Fundamental Search Mechanics

SearchSploit searches through both exploit **titles** and **file paths** by default. Multiple search terms are treated with AND logic.

```bash
# Basic syntax
searchsploit [OPTIONS] <term1> [term2] [term3] ...

# Simple search - finds all Apache-related exploits
searchsploit apache

# Version-specific search - terms are AND-ed together
searchsploit apache 2.4.49

# Multiple terms narrow results
searchsploit linux kernel privilege escalation
```

### Search Term Guidelines

1. **Use software/service names**: `searchsploit openssh`
2. **Include version numbers**: `searchsploit openssh 7.2`
3. **Avoid overly specific versions**: Use `7.2` instead of `7.2p2-Ubuntu`
4. **Use vulnerability terms**: `searchsploit rce apache` or `searchsploit sql injection`
5. **Search CVE identifiers**: `searchsploit CVE-2021-44228`

### Understanding Search Results

```bash
searchsploit vsftpd 2.3.4
```

**Output Format:**

```
--------------------------------------------------------------- ----------------
 Exploit Title                                                 |  Path
--------------------------------------------------------------- ----------------
vsftpd 2.3.4 - Backdoor Command Execution (Metasploit)         | unix/remote/17491.rb
vsftpd 2.3.4 - Backdoor Command Execution                      | unix/remote/49757.py
--------------------------------------------------------------- ----------------
```

**Path Breakdown:**

| Component | Meaning |
|-----------|---------|
| `unix` | Target platform |
| `remote` | Exploit type (requires network access) |
| `17491.rb` | EDB-ID + file extension |

### Common Service Searches

```bash
# Web servers
searchsploit apache
searchsploit nginx
searchsploit iis
searchsploit tomcat

# SSH/Remote access
searchsploit openssh
searchsploit dropbear

# File transfer
searchsploit vsftpd
searchsploit proftpd
searchsploit filezilla

# Databases
searchsploit mysql
searchsploit postgresql
searchsploit mongodb

# Windows services
searchsploit smb
searchsploit rdp
searchsploit "active directory"

# CMS platforms
searchsploit wordpress
searchsploit drupal
searchsploit joomla
```

---

## Advanced Search Options

### Title-Only Search (-t, --title)

Restricts search to exploit titles only, ignoring file paths. This is useful when path directories cause unwanted matches.

```bash
# Search titles only
searchsploit -t remote code execution

# Compare difference
searchsploit wordpress           # Matches "php/webapps/..." paths
searchsploit -t wordpress        # Only matches "WordPress" in titles

# Find specific vulnerability types
searchsploit -t privilege escalation
searchsploit -t buffer overflow
searchsploit -t sql injection
```

### Exact Match Search (-e, --exact)

Disables word-splitting and fuzzy matching. Use quotes for multi-word terms.

```bash
# Exact version matching
searchsploit -e "Apache 2.4.49"

# Compare:
searchsploit apache 2.4           # Matches 2.4, 2.4.1, 2.4.49, etc.
searchsploit -e "apache 2.4"      # Matches ONLY "apache 2.4"

# Exact CVE search
searchsploit -e "CVE-2017-0144"

# Exact product names
searchsploit -e "OpenSSH 7.2p2"
searchsploit -e "Microsoft IIS 6.0"
searchsploit -e "Eternal Blue"
```

### Strict Mode (-s, --strict)

Performs strict search, similar to exact but with additional constraints.

```bash
# Strict search mode
searchsploit -s "Microsoft Exchange 2019"
```

### Web URL Output (-w, --www)

Shows Exploit-DB website URLs instead of local file paths.

```bash
# Show web URLs
searchsploit -w vsftpd 2.3.4

# Output:
# vsftpd 2.3.4 - Backdoor Command Execution | https://www.exploit-db.com/exploits/17491

# Useful for:
# - Sharing exploit references in reports
# - Accessing additional information online
# - Downloading fresh copies of exploits
```

### Excluding Terms (--exclude)

Filter out unwanted results using comma-separated exclusion terms.

```bash
# Exclude DOS/Denial of Service exploits
searchsploit apache 2.4 --exclude="Denial of Service"
searchsploit apache 2.4 --exclude="DOS"

# Exclude multiple terms
searchsploit linux kernel --exclude="Denial of Service,DOS,Ubuntu"

# Exclude specific platforms
searchsploit wordpress --exclude="Windows"

# Exclude Metasploit modules (get standalone exploits only)
searchsploit vsftpd --exclude=".rb"

# Exclude old operating systems
searchsploit windows smb --exclude="Windows XP,Windows 2000,Windows NT"
```

### Case-Sensitive Search (-c, --case)

Enable case-sensitive matching.

```bash
# Case-sensitive search
searchsploit -c "Apache"
searchsploit -c "MICROSOFT"
```

### Combining Options

Options can be combined for precise searching.

```bash
# Exact title search excluding DOS
searchsploit -t -e "Apache 2.4" --exclude="Denial of Service"

# Case-sensitive exact match
searchsploit -c -e "Microsoft Exchange"

# Title search with type filter
searchsploit -t --type=remote "Oracle WebLogic"

# Exact match with web URLs
searchsploit -w -e "WordPress 5.7"

# Full refinement example
searchsploit -t -e "Apache HTTP Server 2.4.49" --exclude="DOS" --type=remote
```

---

## Examining and Copying Exploits

### Examining Exploits (-x, --examine)

View exploit contents directly without copying files.

```bash
# Examine by EDB-ID
searchsploit -x 42966
searchsploit --examine 42966

# Examine by relative path
searchsploit -x unix/remote/17491.rb
searchsploit -x multiple/webapps/50383.py

# Examine shellcode
searchsploit -x shellcodes/linux/x86/46809.c
```

**What to Look For When Examining:**

```
1. Exploit Title and Description
   - What vulnerability does it exploit?
   - What is the CVE (if any)?

2. Author and Date
   - When was it published?
   - Is there author contact for questions?

3. Tested Versions
   - Exact software versions confirmed vulnerable
   - Operating system requirements

4. Dependencies
   - Required libraries (requests, pycryptodome, etc.)
   - Required tools (netcat, python version, etc.)

5. Usage Instructions
   - Command-line arguments
   - Required parameters

6. Hardcoded Values to Modify
   - Target IP/hostname
   - Target port
   - Attacker IP (LHOST)
   - Attacker port (LPORT)
   - File paths
   - Payload/shellcode
```

### Copying Exploits (-m, --mirror)

Copy exploits to the current working directory for modification.

```bash
# Copy by EDB-ID
searchsploit -m 42966
searchsploit --mirror 42966

# Output: Copied to: /current/directory/42966.py

# Copy by path
searchsploit -m unix/remote/17491.rb

# Copy multiple exploits at once
searchsploit -m 42966 17491 21314

# Copy shellcode
searchsploit -m shellcodes/linux/x86/46809.c
```

**Best Practice Workflow:**

```bash
# 1. Create working directory
mkdir -p ~/exploits/target_name
cd ~/exploits/target_name

# 2. Copy exploit
searchsploit -m 50383

# 3. Review before modification
cat 50383.py | head -50

# 4. Modify as needed
nano 50383.py
# or
vim 50383.py
```

### Getting Full Path (-p, --path)

Display the full filesystem path to an exploit.

```bash
# Get full path by EDB-ID
searchsploit -p 17491

# Output:
# Exploit: vsftpd 2.3.4 - Backdoor Command Execution (Metasploit)
#     URL: https://www.exploit-db.com/exploits/17491
#    Path: /usr/share/exploitdb/exploits/unix/remote/17491.rb
#
# Copied to: /tmp/17491.rb

# Use in scripts
EXPLOIT_PATH=$(searchsploit -p 17491 2>/dev/null | grep "Path:" | awk '{print $2}')
echo $EXPLOIT_PATH
```

### Showing EDB-ID (--id)

Display the Exploit-DB ID instead of the file path.

```bash
# Show EDB-ID in results
searchsploit --id vsftpd

# Output shows EDB-ID column instead of path
```

### Allow Overflow (-o, --overflow)

Allow exploit titles to overflow their column width (useful for long titles).

```bash
# Allow title overflow
searchsploit -o "Microsoft Windows Remote Desktop"

# Useful when titles are truncated
searchsploit -o wordpress plugin file upload
```

---

## Nmap Integration

SearchSploit can parse Nmap XML output to automatically find exploits for discovered services.

### Basic Nmap Integration (--nmap)

```bash
# 1. Run nmap with service detection and XML output
nmap -sV -oX scan.xml 10.10.10.1

# 2. Parse results with searchsploit
searchsploit --nmap scan.xml
```

### Streaming from Nmap

```bash
# Pipe nmap output directly
nmap -sV -oX - 10.10.10.1 | searchsploit --nmap -

# With specific ports
nmap -sV -p 21,22,80,443 -oX - 10.10.10.1 | searchsploit --nmap -
```

### Practical Nmap Workflows

```bash
# Quick service scan with exploit lookup
nmap -sV --top-ports 100 -oX services.xml 10.10.10.1
searchsploit --nmap services.xml

# Full port scan workflow
nmap -sV -p- -oX full_scan.xml 10.10.10.1
searchsploit --nmap full_scan.xml

# Aggressive scan with scripts
nmap -A -oX aggressive.xml 10.10.10.1
searchsploit --nmap aggressive.xml

# Multiple targets
nmap -sV -iL targets.txt -oX network_scan.xml
searchsploit --nmap network_scan.xml

# Quick scan and search in one line
nmap -sV -oX - 10.10.10.1 | searchsploit --nmap - 2>/dev/null
```

### Combining with JSON Output

```bash
# Parse nmap results to JSON
searchsploit -j --nmap scan.xml > exploits.json

# Extract specific information
searchsploit -j --nmap scan.xml | jq '.RESULTS_EXPLOIT[] | {title: .Title, id: .["EDB-ID"]}'
```

### Complete Recon-to-Exploit Workflow

```bash
# Step 1: Comprehensive scan
nmap -sC -sV -oA target 10.10.10.1

# Step 2: Automated exploit search
searchsploit --nmap target.xml

# Step 3: Review interesting exploits
searchsploit -x <exploit-id>

# Step 4: Copy for modification
searchsploit -m <exploit-id>

# Step 5: Modify and execute
nano <exploit-file>
python3 <exploit-file>
```

---

## Output Formats

### Default Output

Standard tabular format with title and path columns.

```bash
searchsploit vsftpd
```

```
--------------------------------------------------------------- ----------------
 Exploit Title                                                 |  Path
--------------------------------------------------------------- ----------------
vsftpd 2.3.4 - Backdoor Command Execution (Metasploit)         | unix/remote/17491.rb
vsftpd 2.3.4 - Backdoor Command Execution                      | unix/remote/49757.py
--------------------------------------------------------------- ----------------
Shellcodes: No Results
Papers: No Results
```

### JSON Output (-j, --json)

Machine-parseable JSON format for scripting and automation.

```bash
# Basic JSON output
searchsploit -j vsftpd

# Pretty-print with jq
searchsploit -j apache 2.4.49 | jq

# JSON structure example:
{
  "SEARCH": "apache 2.4.49",
  "DB_PATH_EXPLOIT": "/usr/share/exploitdb",
  "RESULTS_EXPLOIT": [
    {
      "Title": "Apache HTTP Server 2.4.49 - Path Traversal & Remote Code Execution",
      "EDB-ID": "50383",
      "Date": "2021-10-05",
      "Author": "Author Name",
      "Type": "webapps",
      "Platform": "multiple",
      "Path": "multiple/webapps/50383.py"
    }
  ],
  "RESULTS_SHELLCODE": [],
  "RESULTS_PAPER": []
}
```

### XML Output (--xml)

XML format for integration with other tools.

```bash
# XML output
searchsploit --xml vsftpd

# Save to file
searchsploit --xml apache 2.4 > results.xml
```

### Parsing JSON Results

```bash
# Extract EDB-IDs only
searchsploit -j apache 2.4 | jq -r '.RESULTS_EXPLOIT[].["EDB-ID"]'

# Extract titles
searchsploit -j openssh 7 | jq -r '.RESULTS_EXPLOIT[].Title'

# Extract paths
searchsploit -j wordpress | jq -r '.RESULTS_EXPLOIT[].Path'

# Filter by type within JSON
searchsploit -j linux kernel | jq '.RESULTS_EXPLOIT[] | select(.Type=="local")'

# Count total results
searchsploit -j apache | jq '.RESULTS_EXPLOIT | length'

# Get first result only
searchsploit -j vsftpd 2.3.4 | jq -r '.RESULTS_EXPLOIT[0]'

# Get first path for scripting
searchsploit -j vsftpd 2.3.4 | jq -r '.RESULTS_EXPLOIT[0].Path'

# Create custom output format
searchsploit -j apache 2.4 | jq -r '.RESULTS_EXPLOIT[] | "\(.["EDB-ID"]): \(.Title)"'
```

### Color Output (--colour / --color)

Control colored output.

```bash
# Disable colors (useful for scripting)
searchsploit --colour=off apache

# Enable colors explicitly
searchsploit --colour=on apache

# Alternative spelling
searchsploit --color=off apache
```

---

## Filtering by Platform and Type

### Type Filters (--type)

Filter exploits by their category/type.

| Type | Description | Common Use Cases |
|------|-------------|------------------|
| `remote` | Network-accessible exploits | Initial access, RCE without auth |
| `local` | Requires local access | Privilege escalation |
| `webapps` | Web application exploits | SQL injection, RCE, file upload |
| `dos` | Denial of Service | Availability attacks, crashing services |
| `shellcode` | Raw shellcode/payloads | Exploit development, payload crafting |

```bash
# Remote exploits (network accessible)
searchsploit --type=remote apache

# Local privilege escalation
searchsploit --type=local linux kernel

# Web application vulnerabilities
searchsploit --type=webapps wordpress

# Denial of Service
searchsploit --type=dos nginx

# Shellcode for exploit development
searchsploit --type=shellcode linux x86 reverse
```

### Platform Filters (--platform)

Filter by target operating system or platform.

**Common Platforms:**

| Platform | Description |
|----------|-------------|
| `linux` | Linux operating system |
| `windows` | Windows operating system |
| `multiple` | Cross-platform exploits |
| `unix` | Unix-like systems (BSD, etc.) |
| `php` | PHP applications |
| `java` | Java applications |
| `python` | Python applications |
| `ruby` | Ruby applications |
| `hardware` | IoT, embedded, network devices |
| `android` | Android OS and applications |
| `ios` | Apple iOS |
| `osx` | macOS/OS X |

```bash
# Linux-specific exploits
searchsploit --platform=linux kernel

# Windows-specific exploits
searchsploit --platform=windows smb

# Cross-platform exploits
searchsploit --platform=multiple apache

# PHP web applications
searchsploit --platform=php wordpress

# Java applications
searchsploit --platform=java tomcat weblogic

# Hardware/IoT exploits
searchsploit --platform=hardware router
```

### Combined Filtering

```bash
# Linux local privilege escalation
searchsploit --platform=linux --type=local privilege escalation

# Windows remote exploits
searchsploit --platform=windows --type=remote smb

# PHP web application exploits
searchsploit --platform=php --type=webapps wordpress

# Cross-platform remote exploits
searchsploit --platform=multiple --type=remote apache

# Linux kernel local exploits
searchsploit --platform=linux --type=local kernel 5

# Combine with other options
searchsploit --platform=linux --type=local -t privilege escalation --exclude="DOS"
```

---

## Online vs Offline Searching

### Offline Searching (Default)

SearchSploit operates entirely offline by default, searching the local exploit database.

**Advantages:**
- Works in air-gapped/isolated environments
- Fast search performance
- No network dependency
- OPSEC-friendly (no external queries)

**Considerations:**
- Requires regular updates (`searchsploit -u`)
- Database may be outdated without updates
- Limited to exploits in local repository

```bash
# Standard offline search
searchsploit apache 2.4.49

# Ensure database is current
searchsploit -u && searchsploit apache 2.4.49
```

### Online Resources

While SearchSploit itself is offline, you can get online URLs for reference:

```bash
# Get Exploit-DB URLs
searchsploit -w vsftpd 2.3.4

# Output includes URLs like:
# https://www.exploit-db.com/exploits/17491

# Get path which also shows URL
searchsploit -p 17491
```

### Exploit-DB Website Features

The online Exploit-DB (https://www.exploit-db.com) offers additional features:

| Feature | Description |
|---------|-------------|
| Full exploit details | Extended descriptions, references |
| CVE cross-references | Links to MITRE, NVD |
| Vulnerable applications | Download vulnerable software for testing |
| Google Hacking DB | Dorks for finding vulnerable systems |
| Papers section | Security research and whitepapers |
| Submit exploits | Contribute new exploits |

### Hybrid Workflow

```bash
# 1. Search locally for speed
searchsploit -j apache 2.4.49 | jq '.RESULTS_EXPLOIT[0]'

# 2. Get online URL for more details
searchsploit -w apache 2.4.49

# 3. Copy locally and modify
searchsploit -m 50383

# 4. Check online for updates or comments (manually)
# Visit: https://www.exploit-db.com/exploits/50383
```

---

## Complete Command Reference

### All Command-Line Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-c` | `--case` | Perform case-sensitive search |
| `-e` | `--exact` | Exact match search (no splitting) |
| `-h` | `--help` | Display help message |
| `-j` | `--json` | Output in JSON format |
| `-m <id>` | `--mirror <id>` | Copy exploit to current directory |
| `-o` | `--overflow` | Allow title column to overflow |
| `-p <id>` | `--path <id>` | Show full path to exploit |
| `-s` | `--strict` | Strict search mode |
| `-t` | `--title` | Search in titles only |
| `-u` | `--update` | Update the database |
| `-v` | `--verbose` | Verbose output |
| `-w` | `--www` | Show Exploit-DB URL |
| `-x <id>` | `--examine <id>` | View exploit contents |
| | `--colour` | Enable/disable color (on/off/auto) |
| | `--color` | Same as --colour |
| | `--exclude="term"` | Exclude results containing term |
| | `--id` | Show EDB-ID instead of path |
| | `--nmap <file.xml>` | Parse nmap XML for exploits |
| | `--platform=<p>` | Filter by platform |
| | `--type=<t>` | Filter by exploit type |
| | `--stats` | Show database statistics |
| | `--version` | Show version information |
| | `--xml` | Output in XML format |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `PAGER` | Pager for -x/--examine (default: less) |
| `EDITOR` | Editor for viewing/modifying |

---

## Practical Workflows and Examples

### Initial Access Research

```bash
# After port scanning, systematically find exploits
nmap -sV -oX scan.xml 10.10.10.1
searchsploit --nmap scan.xml

# For specific service versions found
searchsploit "Apache 2.4.49"
searchsploit -e "OpenSSH 7.2p2"
searchsploit "ProFTPD 1.3.5"

# Review and copy promising exploits
searchsploit -x 50383
searchsploit -m 50383
```

### Linux Privilege Escalation Research

```bash
# Get kernel version on target
uname -r
# Example: 5.4.0-generic

# Search for kernel exploits
searchsploit --platform=linux --type=local linux kernel 5.4

# General privilege escalation
searchsploit --type=local linux privilege escalation

# SUID binary exploits
searchsploit sudo privilege
searchsploit pkexec
searchsploit screen 4.5
searchsploit polkit

# Service-specific local exploits
searchsploit docker escape
searchsploit lxd privilege
```

### Windows Privilege Escalation Research

```bash
# Get Windows version
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"

# Search for Windows local exploits
searchsploit --platform=windows --type=local privilege escalation

# Specific Windows versions
searchsploit "Windows Server 2019" local
searchsploit "Windows 10" privilege

# Common Windows escalation vectors
searchsploit printspoofer
searchsploit potatoes windows
searchsploit "juicy potato"
searchsploit "rotten potato"
searchsploit seimpersonate
```

### Web Application Research

```bash
# CMS-specific exploits
searchsploit --type=webapps wordpress 5
searchsploit --type=webapps drupal
searchsploit --type=webapps joomla

# Plugin/theme vulnerabilities
searchsploit "wordpress plugin"
searchsploit "wp-file-manager"
searchsploit "elementor"

# Common web vulnerabilities
searchsploit --type=webapps "file upload"
searchsploit --type=webapps "sql injection"
searchsploit --type=webapps "remote code execution"
searchsploit --type=webapps "local file inclusion"

# Framework-specific
searchsploit struts
searchsploit spring4shell
searchsploit laravel
searchsploit rails
```

### Active Directory Research

```bash
# AD-specific exploits
searchsploit "active directory"
searchsploit kerberos
searchsploit "domain controller"

# Common AD attack vectors
searchsploit zerologon
searchsploit petitpotam
searchsploit printnightmare
searchsploit samaccounthook

# LDAP vulnerabilities
searchsploit ldap injection
```

### Exploit Development Reference

```bash
# Find shellcode for specific architectures
searchsploit --type=shellcode linux x86 reverse shell
searchsploit --type=shellcode linux x64 bind
searchsploit --type=shellcode windows x86 meterpreter

# Find similar exploits for reference
searchsploit "buffer overflow" format string
searchsploit "stack overflow" linux

# Copy and examine shellcode
searchsploit -m shellcodes/linux/x86/46809.c
searchsploit -x shellcodes/windows/x86/43612.c
```

### Scripted Automation Examples

```bash
# Batch search from service list
while read service; do
    echo "=== $service ==="
    searchsploit -j "$service" | jq '.RESULTS_EXPLOIT | length'
done < services.txt

# Extract all EDB-IDs for a search
searchsploit -j apache 2.4 | jq -r '.RESULTS_EXPLOIT[].["EDB-ID"]' > apache_exploits.txt

# Create exploit download script
searchsploit -j linux kernel 5 | jq -r '.RESULTS_EXPLOIT[] | "searchsploit -m \(.["EDB-ID"])"' > download_exploits.sh

# Generate report of potential exploits
echo "# Exploit Research Report" > report.md
echo "## Apache Vulnerabilities" >> report.md
searchsploit -w apache 2.4 >> report.md
```

### Quick Reference Cheat Sheet

```bash
# Before starting: Update database
searchsploit -u

# Basic workflow
searchsploit <service> <version>      # Find exploits
searchsploit -x <id>                  # Read exploit
searchsploit -m <id>                  # Copy exploit
searchsploit -w <id>                  # Get web URL

# Narrow results
searchsploit -e "<exact match>"       # Exact search
searchsploit -t <title terms>         # Title-only
searchsploit --exclude="DOS,Denial"   # Exclude terms

# Filter by category
searchsploit --type=remote <terms>    # Network exploits
searchsploit --type=local <terms>     # Priv-esc
searchsploit --type=webapps <terms>   # Web vulns

# Filter by platform
searchsploit --platform=linux <terms>
searchsploit --platform=windows <terms>

# Automation
searchsploit -j <terms> | jq          # JSON output
searchsploit --nmap scan.xml          # Nmap integration
```

---

## Additional Resources

### Official Sources

- **Exploit-DB Website**: https://www.exploit-db.com/
- **GitLab Repository**: https://gitlab.com/exploit-database/exploitdb
- **GitHub Mirror**: https://github.com/offensive-security/exploitdb

### Related Databases

- **Google Hacking Database**: https://www.exploit-db.com/google-hacking-database
- **Exploit-DB Papers**: https://www.exploit-db.com/papers
- **Shellcodes**: https://www.exploit-db.com/shellcodes

### Integration with Other Tools

| Tool | Integration |
|------|-------------|
| Nmap | `searchsploit --nmap scan.xml` |
| Metasploit | Many exploits have MSF modules (`.rb` files) |
| Nuclei | Exploit-DB IDs can map to nuclei templates |
| Burp Suite | Use EDB-IDs as references |

### Reporting Best Practices

When including exploits in penetration test reports:

1. Always cite the EDB-ID
2. Include Exploit-DB URL (`searchsploit -w`)
3. Note tested versions vs. target versions
4. Document any modifications made
5. Include CVE references when available
