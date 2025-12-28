# Searchsploit Techniques

Comprehensive guide to searching, filtering, and using exploits from Exploit-DB during penetration testing.

## Table of Contents

- [Search Techniques](#search-techniques)
  - [Basic Searches](#basic-searches)
  - [Exact Match Search](#exact-match-search)
  - [Title-Only Search](#title-only-search)
  - [Excluding Terms](#excluding-terms)
  - [Combining Filters](#combining-filters)
- [Working with Exploits](#working-with-exploits)
  - [Examining Exploits](#examining-exploits)
  - [Copying Exploits](#copying-exploits)
  - [Path Output](#path-output)
  - [Web URLs](#web-urls)
- [Output Formats](#output-formats)
  - [JSON Output](#json-output)
  - [Parsing Results](#parsing-results)
- [Filtering by Type and Platform](#filtering-by-type-and-platform)
- [Nmap Integration](#nmap-integration)
- [Modifying Exploits for Use](#modifying-exploits-for-use)
- [Common Workflows](#common-workflows)

---

## Search Techniques

### Basic Searches

Searchsploit searches both exploit titles and file paths by default. Multiple terms are treated as AND conditions.

```bash
# Search for Apache exploits
searchsploit apache

# Search for specific version
searchsploit apache 2.4.49

# Search for multiple terms (AND logic)
searchsploit oracle java

# Service + version combinations
searchsploit openssh 7.2
searchsploit proftpd 1.3
searchsploit samba 3.0

# Search for CVE
searchsploit CVE-2021-44228
searchsploit 2021-44228

# Search for vulnerability type
searchsploit buffer overflow linux
searchsploit sql injection wordpress
searchsploit rce apache
```

### Exact Match Search

The `-e` flag performs exact matching, useful when basic search returns too many results.

```bash
# Exact match (disables word-splitting and fuzzy matching)
searchsploit -e "Apache 2.4.49"

# Compare results:
searchsploit apache 2.4           # Matches "2.4", "2.4.1", "2.4.49", etc.
searchsploit -e "apache 2.4"      # Matches only "apache 2.4" exactly

# Exact version matching
searchsploit -e "OpenSSH 7.2p2"
searchsploit -e "Microsoft IIS 6.0"

# Exact CVE matching
searchsploit -e "CVE-2017-0144"
```

### Title-Only Search

The `-t` flag restricts search to exploit titles only (ignores path).

```bash
# Search titles only
searchsploit -t remote code execution

# Combine with exact match
searchsploit -t -e "Eternal Blue"

# Useful when path includes unwanted matches
searchsploit -t wordpress               # Only "wordpress" in title
searchsploit wordpress                  # Matches path like "php/webapps/..."

# Find privilege escalation exploits
searchsploit -t privilege escalation windows
searchsploit -t "local privilege escalation"
```

### Excluding Terms

Use `--exclude` to filter out unwanted results.

```bash
# Exclude DOS exploits
searchsploit apache 2.4 --exclude="Denial of Service"

# Exclude specific platforms
searchsploit wordpress --exclude="Windows"

# Exclude multiple terms (comma-separated)
searchsploit linux kernel --exclude="Denial of Service,DOS"

# Exclude Metasploit modules (if you want standalone exploits)
searchsploit vsftpd --exclude=".rb"

# Exclude old exploits
searchsploit windows smb --exclude="Windows XP,Windows 2000"
```

### Combining Filters

Combine multiple options for precise results.

```bash
# Exact title search excluding DOS
searchsploit -t -e "Apache 2.4" --exclude="Denial of Service"

# Case-sensitive exact match
searchsploit -c -e "Microsoft Exchange"

# Title search with type filter
searchsploit -t --type=remote "Oracle WebLogic"

# Platform + type filter
searchsploit --platform=linux --type=local "kernel"
```

---

## Working with Exploits

### Examining Exploits

Use `-x` to view exploit contents without copying.

```bash
# Examine exploit by EDB-ID
searchsploit -x 42966

# Examine by path
searchsploit -x unix/remote/17491.rb

# View shellcode
searchsploit -x shellcodes/linux/x86/46809.c

# Tip: Uses $PAGER (usually 'less') - press 'q' to quit
```

**What to look for when examining:**

```bash
# Key sections to review:
# - Exploit Title & Description
# - Author and Date
# - Tested Version(s)
# - Requirements (dependencies, libraries)
# - Usage instructions
# - Hardcoded values to change (IP, port, payload)
```

### Copying Exploits

Use `-m` to copy exploits to your current working directory.

```bash
# Copy by EDB-ID
searchsploit -m 42966

# Copy by path
searchsploit -m unix/remote/17491.rb

# Copy multiple exploits
searchsploit -m 42966 17491 21314

# Copy to specific directory
cd /root/exploits && searchsploit -m 42966

# Copies maintain original filename
# Output: Copied to: /root/exploits/42966.py
```

### Path Output

Use `-p` to show full filesystem path to exploit.

```bash
# Get full path for scripting
searchsploit -p 17491
# Output: /usr/share/exploitdb/exploits/unix/remote/17491.rb

# Use in scripts
EXPLOIT_PATH=$(searchsploit -p 17491 | tail -1 | awk '{print $NF}')
cp "$EXPLOIT_PATH" ./exploit.rb

# Check exploit type from path
searchsploit -p 42966 | grep -oP '(local|remote|webapps|dos|shellcode)'
```

### Web URLs

Use `-w` to show Exploit-DB website URLs.

```bash
# Show web URLs instead of local paths
searchsploit -w vsftpd 2.3.4

# Useful for sharing or documentation
searchsploit -w -j apache 2.4.49 | jq -r '.[].URL'

# Open in browser (example)
firefox $(searchsploit -w -p 17491 | grep https)
```

---

## Output Formats

### JSON Output

Use `-j` for machine-parseable JSON output.

```bash
# JSON output
searchsploit -j vsftpd

# Pretty-print with jq
searchsploit -j apache 2.4.49 | jq

# Sample JSON structure:
# {
#   "RESULTS_EXPLOIT": [
#     {
#       "Title": "Apache HTTP Server 2.4.49 - Path Traversal",
#       "EDB-ID": "50383",
#       "Path": "multiple/webapps/50383.py",
#       "Platform": "multiple",
#       "Type": "webapps"
#     }
#   ],
#   "RESULTS_SHELLCODE": [],
#   "RESULTS_PAPER": []
# }
```

### Parsing Results

```bash
# Extract EDB-IDs
searchsploit -j apache 2.4 | jq -r '.RESULTS_EXPLOIT[].["EDB-ID"]'

# Extract titles
searchsploit -j openssh 7 | jq -r '.RESULTS_EXPLOIT[].Title'

# Extract paths
searchsploit -j wordpress | jq -r '.RESULTS_EXPLOIT[].Path'

# Filter by type in JSON
searchsploit -j linux kernel | jq '.RESULTS_EXPLOIT[] | select(.Type=="local")'

# Count results
searchsploit -j apache | jq '.RESULTS_EXPLOIT | length'

# Get first result path
searchsploit -j vsftpd 2.3.4 | jq -r '.RESULTS_EXPLOIT[0].Path'
```

---

## Filtering by Type and Platform

### Type Filters

```bash
# Remote exploits only
searchsploit --type=remote apache

# Local privilege escalation
searchsploit --type=local linux kernel

# Web application exploits
searchsploit --type=webapps wordpress

# Denial of Service
searchsploit --type=dos apache

# Shellcode
searchsploit --type=shellcode linux x86
```

**Exploit Types:**

| Type | Description | Common Use |
|------|-------------|------------|
| `remote` | Network-accessible exploits | Initial access, RCE |
| `local` | Requires local access | Privilege escalation |
| `webapps` | Web application exploits | SQLi, RCE, file upload |
| `dos` | Denial of Service | Availability attacks |
| `shellcode` | Shellcode/payloads | Exploit development |

### Platform Filters

```bash
# Linux only
searchsploit --platform=linux kernel

# Windows only
searchsploit --platform=windows smb

# Multi-platform
searchsploit --platform=multiple apache

# Specific platforms
searchsploit --platform=php wordpress
searchsploit --platform=java oracle
searchsploit --platform=python django
```

**Common Platforms:**

| Platform | Examples |
|----------|----------|
| `linux` | Kernel, services, applications |
| `windows` | Windows OS, services, applications |
| `multiple` | Cross-platform exploits |
| `php` | PHP-based applications |
| `java` | Java applications, Tomcat |
| `python` | Python applications |
| `hardware` | IoT, embedded devices |
| `android` | Android OS and apps |
| `ios` | Apple iOS |

### Combined Filters

```bash
# Linux local privilege escalation
searchsploit --platform=linux --type=local privilege escalation

# Windows remote exploits
searchsploit --platform=windows --type=remote smb

# PHP web application exploits
searchsploit --platform=php --type=webapps wordpress
```

---

## Nmap Integration

Searchsploit can parse nmap XML output to automatically find exploits for discovered services.

### Basic Nmap Integration

```bash
# 1. Run nmap with XML output
nmap -sV -oX scan.xml 10.10.10.1

# 2. Parse with searchsploit
searchsploit --nmap scan.xml

# Combined in one line
nmap -sV -oX - 10.10.10.1 | searchsploit --nmap -
```

### Practical Examples

```bash
# Quick service scan with exploit lookup
nmap -sV --top-ports 100 -oX services.xml 10.10.10.1
searchsploit --nmap services.xml

# Full port scan with exploit mapping
nmap -sV -p- -oX full_scan.xml 10.10.10.1 && searchsploit --nmap full_scan.xml

# Multiple targets
nmap -sV -iL targets.txt -oX network_scan.xml
searchsploit --nmap network_scan.xml

# With JSON output for parsing
searchsploit -j --nmap scan.xml | jq '.RESULTS_EXPLOIT[] | {service: .Title, exploit: .Path}'
```

### Workflow Example

```bash
# Complete reconnaissance to exploitation workflow

# 1. Scan target
nmap -sC -sV -oA target 10.10.10.1

# 2. Find potential exploits
searchsploit --nmap target.xml

# 3. Review interesting results
searchsploit -x <exploit-id>

# 4. Copy exploit for modification
searchsploit -m <exploit-id>

# 5. Modify and run
nano <exploit-file>
python3 <exploit-file>
```

---

## Modifying Exploits for Use

Most exploits require modification before use. Here are common changes needed.

### Common Modifications

```python
# 1. Target IP/Host
target = "10.10.10.1"        # Change from example.com
port = 80                     # Verify correct port

# 2. Attacker IP (for reverse shells)
lhost = "10.10.14.5"         # Your IP
lport = 4444                  # Your listener port

# 3. Payload/Shellcode
# Replace default with msfvenom-generated payload
# msfvenom -p linux/x86/shell_reverse_tcp LHOST=10.10.14.5 LPORT=4444 -f python

# 4. Paths and URLs
path = "/vulnerable/endpoint"  # Verify target path
```

### Exploit Preparation Workflow

```bash
# 1. Copy exploit
searchsploit -m 42966
cd .

# 2. Read and understand
cat 42966.py | head -50        # Review header/usage

# 3. Check dependencies
grep -E "^import|^from" 42966.py

# 4. Install dependencies if needed
pip install requests pycryptodome

# 5. Identify variables to change
grep -E "(host|ip|target|lhost|lport|port)" 42966.py

# 6. Modify exploit
nano 42966.py
# or
sed -i 's/127.0.0.1/10.10.10.1/g' 42966.py

# 7. Test syntax
python3 -m py_compile 42966.py

# 8. Run
python3 42966.py
```

### Language-Specific Tips

**Python Exploits:**

```bash
# Check Python version
head -1 exploit.py            # #!/usr/bin/python or python3

# Python 2 to 3 conversion issues
2to3 -w exploit.py

# Common fixes
# print "text" -> print("text")
# raw_input() -> input()
```

**Ruby Exploits:**

```bash
# Often Metasploit modules - use msfconsole instead
# Standalone Ruby:
ruby exploit.rb
```

**C Exploits:**

```bash
# Compile for target architecture
gcc -o exploit exploit.c

# 32-bit on 64-bit system
gcc -m32 -o exploit exploit.c

# With specific libraries
gcc -o exploit exploit.c -lpthread -lcrypto
```

**Shellcode:**

```bash
# Compile shellcode wrapper
gcc -fno-stack-protector -z execstack -o shellcode shellcode.c
```

---

## Common Workflows

### Initial Access Research

```bash
# After port scanning, find exploits for each service
nmap -sV -oX scan.xml 10.10.10.1
searchsploit --nmap scan.xml

# Research specific service versions
searchsploit "Apache 2.4.49"
searchsploit -x 50383              # Review exploit
searchsploit -m 50383              # Copy for use
```

### Privilege Escalation Research

```bash
# Linux kernel exploits
searchsploit --type=local --platform=linux kernel

# Specific kernel version
uname -r                           # Get kernel version on target
searchsploit linux kernel 5.4

# SUID binary exploits
searchsploit sudo
searchsploit pkexec
searchsploit screen 4.5

# Windows local exploits
searchsploit --type=local --platform=windows privilege escalation
systeminfo                         # Get Windows version
searchsploit "Windows Server 2019"
```

### Web Application Research

```bash
# CMS-specific
searchsploit wordpress 5.7
searchsploit drupal 9
searchsploit joomla 3.9

# Plugin vulnerabilities
searchsploit "wordpress plugin"
searchsploit "wp-file-manager"

# Common web vulnerabilities
searchsploit --type=webapps "file upload"
searchsploit --type=webapps "sql injection"
```

### Exploit Development Reference

```bash
# Find shellcode for your needs
searchsploit --type=shellcode linux x86 reverse
searchsploit --type=shellcode windows x64 exec

# Copy and examine shellcode
searchsploit -m shellcodes/linux/x86/46809.c
searchsploit -x shellcodes/linux/x86/46809.c

# Find similar exploits for reference
searchsploit "buffer overflow" format string
```

### Quick Reference Commands

```bash
# Update before engagement
searchsploit -u

# Quick search workflow
searchsploit <service> <version>
searchsploit -x <id>              # Read it
searchsploit -m <id>              # Copy it
searchsploit -w <id>              # Get URL for more info

# Narrow down results
searchsploit -e "<exact match>"
searchsploit -t <title terms>
searchsploit --exclude="DOS,Denial"

# For automation
searchsploit -j <terms> | jq
searchsploit --nmap scan.xml
```
