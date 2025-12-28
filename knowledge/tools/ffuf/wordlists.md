# ffuf - Wordlist Recommendations

## Table of Contents

- [SecLists Paths](#seclists-paths)
- [Common Wordlists by Scenario](#common-wordlists-by-scenario)
- [Assetnote Wordlists](#assetnote-wordlists)
- [Custom Wordlist Creation](#custom-wordlist-creation)
- [Wordlist Optimization](#wordlist-optimization)
- [Quick Reference](#quick-reference)

---

## SecLists Paths

SecLists is the most comprehensive collection of wordlists for security testing. Install location is typically `/usr/share/seclists/` on Kali Linux.

### Installation

```bash
# Kali Linux
sudo apt install -y seclists

# Git clone
git clone --depth 1 https://github.com/danielmiessler/SecLists.git /opt/seclists

# Set variable for convenience
export SECLISTS=/usr/share/seclists
```

### Directory Structure

```
SecLists/
├── Discovery/
│   ├── DNS/                    # Subdomain wordlists
│   ├── Web-Content/            # Directory/file wordlists
│   └── Infrastructure/         # Ports, SNMP, etc.
├── Fuzzing/                    # Injection payloads
│   ├── LFI/
│   ├── SQLi/
│   └── XSS/
├── Passwords/                  # Password lists
├── Usernames/                  # Username lists
└── Pattern-Matching/           # Regex patterns
```

---

## Common Wordlists by Scenario

### Directory/File Discovery

| Wordlist | Size | Best For |
|----------|------|----------|
| `Discovery/Web-Content/common.txt` | ~4,600 | Quick initial scan |
| `Discovery/Web-Content/raft-small-directories.txt` | ~20,000 | Standard CTF |
| `Discovery/Web-Content/raft-medium-directories.txt` | ~30,000 | Thorough CTF |
| `Discovery/Web-Content/raft-large-directories.txt` | ~60,000 | Comprehensive |
| `Discovery/Web-Content/directory-list-2.3-medium.txt` | ~220,000 | Deep enumeration |
| `Discovery/Web-Content/directory-list-2.3-big.txt` | ~1,270,000 | Exhaustive |

```bash
# Quick scan
ffuf -u http://target.com/FUZZ -w $SECLISTS/Discovery/Web-Content/common.txt

# Thorough scan
ffuf -u http://target.com/FUZZ -w $SECLISTS/Discovery/Web-Content/raft-medium-directories.txt

# Comprehensive
ffuf -u http://target.com/FUZZ -w $SECLISTS/Discovery/Web-Content/directory-list-2.3-medium.txt
```

### File-Specific Discovery

```bash
# Files specifically
ffuf -u http://target.com/FUZZ -w $SECLISTS/Discovery/Web-Content/raft-medium-files.txt

# Common filenames
ffuf -u http://target.com/FUZZ -w $SECLISTS/Discovery/Web-Content/quickhits.txt
```

### Subdomain Enumeration

| Wordlist | Size | Best For |
|----------|------|----------|
| `Discovery/DNS/subdomains-top1million-5000.txt` | 5,000 | Quick scan |
| `Discovery/DNS/subdomains-top1million-20000.txt` | 20,000 | Standard |
| `Discovery/DNS/subdomains-top1million-110000.txt` | 110,000 | Thorough |
| `Discovery/DNS/namelist.txt` | ~1,900 | Short names |
| `Discovery/DNS/bitquark-subdomains-top100000.txt` | 100,000 | Alternative |
| `Discovery/DNS/dns-Jhaddix.txt` | ~2,180,000 | Exhaustive |

```bash
# Quick subdomain scan
ffuf -u http://FUZZ.target.com -w $SECLISTS/Discovery/DNS/subdomains-top1million-5000.txt

# VHost discovery
ffuf -u http://target.com -H "Host: FUZZ.target.com" \
    -w $SECLISTS/Discovery/DNS/subdomains-top1million-20000.txt -fs 0
```

### API Endpoint Discovery

| Wordlist | Best For |
|----------|----------|
| `Discovery/Web-Content/api/api-endpoints.txt` | Generic API |
| `Discovery/Web-Content/api/api-endpoints-res.txt` | REST resources |
| `Discovery/Web-Content/api/objects.txt` | API objects |
| `Discovery/Web-Content/api/actions.txt` | API actions |
| `Discovery/Web-Content/api/actions-lowercase.txt` | Lowercase actions |
| `Discovery/Web-Content/swagger.txt` | Swagger/OpenAPI |

```bash
# API enumeration
ffuf -u http://target.com/api/v1/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/api/api-endpoints.txt \
    -mc 200,201,204,401,403

# Combined API wordlist
ffuf -u http://target.com/api/FUZZ \
    -w <(cat $SECLISTS/Discovery/Web-Content/api/*.txt | sort -u)
```

### Parameter Fuzzing

| Wordlist | Size | Best For |
|----------|------|----------|
| `Discovery/Web-Content/burp-parameter-names.txt` | ~6,400 | Parameter discovery |
| `Fuzzing/fuzz-Bo0oM.txt` | ~4,800 | General fuzzing |
| `Discovery/Web-Content/raft-large-words.txt` | ~120,000 | Comprehensive |

```bash
# Parameter discovery
ffuf -u "http://target.com/page?FUZZ=test" \
    -w $SECLISTS/Discovery/Web-Content/burp-parameter-names.txt

# Hidden form fields
ffuf -u http://target.com/form -X POST -d "FUZZ=value" \
    -w $SECLISTS/Discovery/Web-Content/burp-parameter-names.txt -fs 0
```

### Password Lists

| Wordlist | Size | Best For |
|----------|------|----------|
| `Passwords/Common-Credentials/10-million-password-list-top-100.txt` | 100 | Quick spray |
| `Passwords/Common-Credentials/10-million-password-list-top-1000.txt` | 1,000 | Standard spray |
| `Passwords/Common-Credentials/10-million-password-list-top-10000.txt` | 10,000 | Thorough |
| `Passwords/Common-Credentials/best1050.txt` | 1,050 | Curated list |
| `Passwords/Leaked-Databases/rockyou-75.txt` | ~60,000 | RockYou subset |
| `Passwords/darkweb2017-top10000.txt` | 10,000 | Dark web leaks |

```bash
# Password spray
ffuf -u http://target.com/login -X POST \
    -d "username=admin&password=FUZZ" \
    -w $SECLISTS/Passwords/Common-Credentials/10-million-password-list-top-1000.txt \
    -fc 401
```

### Username Lists

| Wordlist | Best For |
|----------|----------|
| `Usernames/Names/names.txt` | Common names |
| `Usernames/top-usernames-shortlist.txt` | Quick enumeration |
| `Usernames/xato-net-10-million-usernames.txt` | Comprehensive |

```bash
# Username enumeration
ffuf -u http://target.com/login -X POST \
    -d "username=FUZZ&password=invalid" \
    -w $SECLISTS/Usernames/top-usernames-shortlist.txt \
    -fr "Invalid username"
```

### Backup and Sensitive Files

```bash
# Backup files
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/CommonBackdoors.txt

# Config files
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/Common-DB-Backups.txt

# Sensitive files
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/KitchensinkDirectories.txt
```

### Technology-Specific Lists

```bash
# Apache
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/Apache.fuzz.txt

# Nginx
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/nginx.txt

# IIS
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/IIS.fuzz.txt

# Tomcat
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/tomcat.txt

# WordPress
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/CMS/wordpress.fuzz.txt

# Drupal
ffuf -u http://target.com/FUZZ \
    -w $SECLISTS/Discovery/Web-Content/CMS/Drupal.txt
```

### Injection Testing

```bash
# LFI
ffuf -u "http://target.com/page?file=FUZZ" \
    -w $SECLISTS/Fuzzing/LFI/LFI-Jhaddix.txt -fs 0

# SQLi
ffuf -u "http://target.com/search?q=FUZZ" \
    -w $SECLISTS/Fuzzing/SQLi/quick-SQLi.txt

# XSS
ffuf -u "http://target.com/search?q=FUZZ" \
    -w $SECLISTS/Fuzzing/XSS/XSS-BruteLogic.txt
```

---

## Assetnote Wordlists

Assetnote provides modern, technology-specific wordlists at [wordlists.assetnote.io](https://wordlists.assetnote.io/).

### Download

```bash
# Download specific wordlists
mkdir -p /opt/wordlists/assetnote
cd /opt/wordlists/assetnote

# Parameters
wget https://wordlists-cdn.assetnote.io/data/manual/parameters_top_1m.txt

# API routes
wget https://wordlists-cdn.assetnote.io/data/manual/raft-large-directories.txt

# Technology-specific
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_apiroutes_2024_09_30.txt
wget https://wordlists-cdn.assetnote.io/data/automated/httparchive_directories_1m_2024_09_30.txt
```

### Use Cases

```bash
# Modern API endpoints
ffuf -u http://target.com/api/FUZZ \
    -w /opt/wordlists/assetnote/httparchive_apiroutes_*.txt

# Parameter names from real-world traffic
ffuf -u "http://target.com/page?FUZZ=test" \
    -w /opt/wordlists/assetnote/parameters_top_1m.txt
```

---

## Custom Wordlist Creation

### From Target Website

```bash
# Extract words from website using cewl
cewl http://target.com -d 2 -m 5 -w custom-words.txt

# Include emails
cewl http://target.com -d 2 -m 5 -e --email_file emails.txt -w custom-words.txt

# Use with ffuf
ffuf -u http://target.com/FUZZ -w custom-words.txt
```

### From JavaScript Files

```bash
# Download JS files
wget -r -l 1 -nd -A "*.js" http://target.com -P js-files/

# Extract endpoints/words
grep -rohE '"[/][a-zA-Z0-9_/.-]+"' js-files/ | tr -d '"' | sort -u > js-endpoints.txt
grep -rohE '/[a-zA-Z0-9_/-]+' js-files/ | sort -u >> js-endpoints.txt

# Extract potential parameters
grep -rohE '[a-zA-Z_][a-zA-Z0-9_]*=' js-files/ | tr -d '=' | sort -u > js-params.txt
```

### From API Documentation

```bash
# Extract from Swagger/OpenAPI
curl -s http://target.com/swagger.json | jq -r '.paths | keys[]' > api-paths.txt
curl -s http://target.com/swagger.json | jq -r '.. | .name? // empty' > api-params.txt
```

### Combining Wordlists

```bash
# Merge and deduplicate
cat wordlist1.txt wordlist2.txt wordlist3.txt | sort -u > combined.txt

# Remove empty lines and comments
grep -v '^#' combined.txt | grep -v '^$' > clean.txt

# Create variations (uppercase, lowercase, capitalized)
cat base.txt | tr '[:lower:]' '[:upper:]' >> variations.txt
cat base.txt | tr '[:upper:]' '[:lower:]' >> variations.txt
cat base.txt | sed 's/\b\(.\)/\u\1/g' >> variations.txt
sort -u variations.txt -o variations.txt
```

### Generating Number Sequences

```bash
# Sequential numbers
seq 1 1000 > numbers-1-1000.txt

# Padded numbers
seq -w 0001 9999 > numbers-padded.txt

# Year-based
seq 2020 2025 > years.txt

# Common IDs
echo -e "1\n0\n-1\n100\n1000\n9999" > common-ids.txt
```

### Username Variations

```bash
# From name list, create variations
while read name; do
    echo "$name"
    echo "${name}1"
    echo "${name}123"
    echo "${name}2024"
    echo "${name}.admin"
    echo "admin.${name}"
done < names.txt > usernames-extended.txt
```

---

## Wordlist Optimization

### Size Reduction

```bash
# Remove duplicates
sort -u input.txt -o output.txt

# Remove short entries (less than 3 chars)
awk 'length($0) >= 3' wordlist.txt > filtered.txt

# Remove entries with special characters
grep -E '^[a-zA-Z0-9_-]+$' wordlist.txt > alphanumeric.txt

# Limit to first N entries
head -n 10000 large-wordlist.txt > top-10000.txt
```

### Speed Optimization

```bash
# Sort for better filesystem caching
sort wordlist.txt -o wordlist.txt

# Remove empty lines
sed -i '/^$/d' wordlist.txt

# Use smaller targeted wordlist first, then expand
ffuf -u http://target.com/FUZZ -w common.txt       # Quick pass
ffuf -u http://target.com/FUZZ -w raft-medium.txt  # If more needed
```

### Prioritization

```bash
# Most common entries first (requires frequency data)
sort -t, -k2 -nr wordlist-with-freq.csv | cut -d, -f1 > prioritized.txt

# Critical paths first
cat << 'EOF' > priority-paths.txt
admin
login
dashboard
config
backup
api
wp-admin
.git
.env
EOF
cat priority-paths.txt wordlist.txt | awk '!seen[$0]++' > optimized.txt
```

### Extension Handling

```bash
# Add extensions to wordlist entries
while read line; do
    echo "$line"
    echo "${line}.php"
    echo "${line}.html"
    echo "${line}.txt"
done < wordlist.txt > with-extensions.txt

# Or use ffuf's -e flag (preferred)
ffuf -u http://target.com/FUZZ -w wordlist.txt -e .php,.html,.txt
```

### Removing False Positives

```bash
# After initial scan, filter out noise
grep -v "404\|Not Found\|Error" initial-results.txt > cleaned.txt

# Create exclusion list from common false positives
echo -e "css\njs\nimages\nfonts\nstatic" > exclude.txt
grep -vFf exclude.txt wordlist.txt > filtered-wordlist.txt
```

---

## Quick Reference

### Recommended Wordlists by Task

| Task | Recommended Wordlist |
|------|---------------------|
| Quick directory scan | `common.txt` |
| Thorough directory scan | `raft-medium-directories.txt` |
| File discovery | `raft-medium-files.txt` |
| Subdomain enumeration | `subdomains-top1million-20000.txt` |
| VHost discovery | `namelist.txt` or `subdomains-top1million-5000.txt` |
| API endpoints | `api-endpoints.txt` + `api-endpoints-res.txt` |
| Parameter fuzzing | `burp-parameter-names.txt` |
| Password spray | `10-million-password-list-top-1000.txt` |
| Username enumeration | `names.txt` or `top-usernames-shortlist.txt` |
| LFI testing | `LFI-Jhaddix.txt` |
| Backup files | `CommonBackdoors.txt` |

### Full Paths (Kali Linux)

```bash
# Directory discovery
/usr/share/seclists/Discovery/Web-Content/common.txt
/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt

# Subdomains
/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
/usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt

# Parameters
/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt

# Passwords
/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt

# Usernames
/usr/share/seclists/Usernames/Names/names.txt
```

### Creating Project-Specific Wordlist

```bash
#!/bin/bash
# create-project-wordlist.sh

TARGET="$1"
OUTPUT="project-wordlist.txt"

# Start with common paths
cat /usr/share/seclists/Discovery/Web-Content/common.txt > "$OUTPUT"

# Add cewl results
cewl -d 2 -m 5 "$TARGET" >> "$OUTPUT"

# Extract from robots.txt
curl -s "$TARGET/robots.txt" | grep -E "^(Dis)?allow:" | awk '{print $2}' >> "$OUTPUT"

# Extract from sitemap
curl -s "$TARGET/sitemap.xml" | grep -oP '(?<=<loc>)[^<]+' | sed "s|$TARGET||" >> "$OUTPUT"

# Clean up
sort -u "$OUTPUT" -o "$OUTPUT"
sed -i '/^$/d' "$OUTPUT"

echo "Created $OUTPUT with $(wc -l < "$OUTPUT") entries"
```

---

## Resources

- [SecLists GitHub](https://github.com/danielmiessler/SecLists)
- [Assetnote Wordlists](https://wordlists.assetnote.io/)
- [FuzzDB](https://github.com/fuzzdb-project/fuzzdb)
- [OneListForAll](https://github.com/six2dez/OneListForAll)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
