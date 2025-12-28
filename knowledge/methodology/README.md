---
title: Penetration Testing Methodology
category: methodology
tags:
  - pentesting
  - methodology
  - offensive-security
  - red-team
  - attack-lifecycle
last_updated: 2025-12-27
---

# Penetration Testing Methodology

A structured approach to security assessments, covering the complete attack lifecycle from initial reconnaissance through cleanup.

## Table of Contents

1. [Overview](#overview)
2. [Phases](#phases)
   - [Reconnaissance](#reconnaissance)
   - [Enumeration](#enumeration)
   - [Exploitation](#exploitation)
   - [Post-Exploitation](#post-exploitation)
   - [Persistence](#persistence)
   - [Privilege Escalation](#privilege-escalation)
   - [Lateral Movement](#lateral-movement)
   - [Exfiltration](#exfiltration)
   - [Cleanup](#cleanup)
3. [Phase Flow Diagram](#phase-flow-diagram)
4. [Best Practices](#best-practices)

---

## Overview

Penetration testing follows a methodical process designed to simulate real-world attacks against target systems and networks. Each phase builds upon the previous, progressively deepening access and expanding control within the target environment.

The methodology outlined here follows industry-standard frameworks including PTES (Penetration Testing Execution Standard), OWASP Testing Guide, and MITRE ATT&CK.

---

## Phases

### Reconnaissance

**Directory:** [reconnaissance/](./reconnaissance/)

The information gathering phase where attackers collect data about the target without direct interaction (passive) or through direct probing (active).

| Type | Description | Examples |
|------|-------------|----------|
| **Passive (OSINT)** | Gathering information without touching target systems | WHOIS, DNS records, social media, Shodan, Google dorks |
| **Active** | Direct interaction with target systems | DNS zone transfers, website crawling, port scanning |

**Key Objectives:**
- Identify target IP ranges and domains
- Discover employee information and email formats
- Map external attack surface
- Gather technology stack information

---

### Enumeration

**Directory:** [enumeration/](./enumeration/)

Systematic discovery and analysis of services, ports, and potential entry points on target systems.

**Core Activities:**
- Port scanning (TCP/UDP)
- Service version detection
- OS fingerprinting
- Banner grabbing
- Directory and file enumeration
- User and share enumeration

**Common Tools:** Nmap, Masscan, RustScan, Gobuster, Feroxbuster, enum4linux

---

### Exploitation

**Directory:** [exploitation/](./exploitation/)

Leveraging discovered vulnerabilities to gain initial access to target systems.

**Attack Vectors:**
- Public exploits (CVEs, Metasploit modules)
- Web application attacks (SQLi, RCE, file upload)
- Password attacks (spraying, brute force, credential stuffing)
- Social engineering (phishing, pretexting)
- Misconfigurations (default credentials, exposed services)

**Key Considerations:**
- Validate exploits in lab environment first
- Document all exploitation attempts
- Minimize system impact and noise

---

### Post-Exploitation

**Directory:** [post-exploitation/](./post-exploitation/)

Activities performed after gaining initial access to understand the compromised system and prepare for further attacks.

**Core Activities:**
- System profiling (OS, architecture, installed software)
- User enumeration and privilege assessment
- Credential harvesting (memory, files, registries)
- Network reconnaissance from compromised host
- Identifying valuable data and pivot points

**Common Tools:** LinPEAS, WinPEAS, Mimikatz, BloodHound

---

### Persistence

**Directory:** [persistence/](./persistence/)

Establishing mechanisms to maintain access to compromised systems across reboots and credential changes.

**Techniques:**
| Platform | Methods |
|----------|---------|
| **Windows** | Scheduled tasks, services, registry keys, WMI subscriptions, DLL hijacking |
| **Linux** | Cron jobs, SSH keys, systemd services, bashrc/profile modifications |
| **Web** | Webshells, backdoored applications, rogue accounts |

**Considerations:**
- Balance stealth vs. reliability
- Use multiple persistence mechanisms
- Document all implants for cleanup

---

### Privilege Escalation

**Directory:** [privilege-escalation/](./privilege-escalation/)

Escalating from initial access to higher-privilege accounts (typically root/SYSTEM/Administrator).

**Windows Escalation Paths:**
- Token impersonation (SeImpersonatePrivilege)
- Unquoted service paths
- Weak service permissions
- AlwaysInstallElevated
- Kernel exploits

**Linux Escalation Paths:**
- SUID/SGID binaries
- Sudo misconfigurations
- Cron job abuse
- Writable service files
- Kernel exploits
- Capabilities abuse

**Common Tools:** LinPEAS, WinPEAS, PowerUp, BeRoot, GTFOBins

---

### Lateral Movement

**Directory:** [lateral-movement/](./lateral-movement/)

Spreading through the network to access additional systems and resources.

**Techniques:**
- Pass-the-Hash (PtH) / Pass-the-Ticket (PtT)
- Remote execution (WMI, PSExec, WinRM, SSH)
- RDP hijacking
- Token manipulation
- Kerberos attacks (Kerberoasting, AS-REP roasting)

**Network Pivoting:**
- SSH tunneling
- SOCKS proxies (Chisel, Ligolo-ng)
- Port forwarding

**Common Tools:** Impacket, CrackMapExec/NetExec, Evil-WinRM, Chisel

---

### Exfiltration

**Directory:** [exfiltration/](./exfiltration/)

Extracting valuable data from the target environment.

**Data Targets:**
- Credentials and secrets
- Sensitive documents
- Database contents
- Configuration files
- Source code

**Exfiltration Methods:**
- Encrypted channels (HTTPS, DNS tunneling)
- Cloud storage
- Email
- Physical media
- Steganography

**Considerations:**
- Avoid data loss prevention (DLP) triggers
- Encrypt data before exfiltration
- Use authorized channels during assessments

---

### Cleanup

**Directory:** [cleanup/](./cleanup/)

Removing artifacts and restoring systems to their original state.

**Cleanup Activities:**
- Remove tools and scripts uploaded
- Delete created accounts and credentials
- Remove persistence mechanisms
- Clear relevant logs (if authorized)
- Restore modified configurations
- Document all cleanup actions

**Critical:** Always maintain detailed notes of all changes made during the assessment for accurate cleanup.

---

## Phase Flow Diagram

```
+----------------+     +-------------+     +--------------+
| Reconnaissance | --> | Enumeration | --> | Exploitation |
+----------------+     +-------------+     +--------------+
                                                  |
                                                  v
+----------+     +--------------------+     +------------------+
|  Cleanup | <-- |    Exfiltration    | <-- | Post-Exploitation|
+----------+     +--------------------+     +------------------+
                          ^                        |
                          |                        v
                 +------------------+     +---------------------+
                 | Lateral Movement | <-- | Privilege Escalation|
                 +------------------+     +---------------------+
                          ^                        |
                          |                        v
                          +---- Persistence <------+
```

---

## Best Practices

1. **Documentation:** Maintain detailed notes throughout all phases
2. **Scope Awareness:** Stay within authorized boundaries
3. **Communication:** Report critical findings immediately
4. **Minimize Impact:** Avoid disrupting production systems
5. **Evidence Collection:** Screenshot and log all findings
6. **Iterative Process:** Phases often overlap and repeat
7. **Tool Validation:** Test tools in lab before production use
8. **Time Management:** Allocate time appropriately across phases
