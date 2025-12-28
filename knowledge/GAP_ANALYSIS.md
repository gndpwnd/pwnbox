---
title: "Knowledge Base Gap Analysis"
category: "planning"
tags: ["gap-analysis", "roadmap", "certifications", "research"]
last_updated: "2025-12-27"
---

# Knowledge Base Gap Analysis

> Comprehensive analysis of gaps based on certification curricula and industry frameworks

## Table of Contents

- [Overview](#overview)
- [Current Coverage](#current-coverage)
- [Certification-Based Gaps](#certification-based-gaps)
- [Tool Gaps](#tool-gaps)
- [Methodology Gaps](#methodology-gaps)
- [Technique Gaps](#technique-gaps)
- [Priority Matrix](#priority-matrix)
- [Recommended Additions](#recommended-additions)

---

## Overview

This gap analysis compares the current pwnbox knowledge base against:
- **OSCP (PEN-200)** - Offensive Security Certified Professional
- **CEH v12** - Certified Ethical Hacker
- **PNPT** - Practical Network Penetration Tester
- **CRTP/CRTE** - Certified Red Team Professional/Expert
- **GPEN** - GIAC Penetration Tester
- **Industry Frameworks** - PTES, OWASP, MITRE ATT&CK

---

## Current Coverage

### What We Have

| Category | Files | Lines | Status |
|----------|-------|-------|--------|
| **Tools** | 106 | ~44,000 | 31 tools documented |
| **Methodology** | 11 | ~1,500 | 9 phases + frameworks |
| **Techniques** | 15 | ~8,000 | Windows, Linux, AD, Network |
| **Reporting** | 4 | ~500 | Templates and best practices |
| **Research** | 4 | ~3,000 | Certification curricula |
| **Total** | **140** | **~57,000** | **2.2 MB** |

### Tools Currently Documented

**Reconnaissance:** nmap, masscan, rustscan
**Enumeration:** gobuster, feroxbuster, enum4linux, smbclient, smbmap
**Active Directory:** bloodhound, kerbrute, responder, crackmapexec, netexec
**Exploitation:** impacket, evil-winrm, metasploit-framework, msfvenom
**Password Cracking:** hashcat, john, hydra
**Pivoting:** chisel, ligolo-ng, proxychains, ssh, socat
**Privilege Escalation:** linpeas, winpeas, pspy, mimikatz
**Networking:** nc, rlwrap

---

## Certification-Based Gaps

### OSCP Gaps

| Topic | Current Status | Priority |
|-------|----------------|----------|
| Web Application Attacks (SQLi, XSS, LFI/RFI) | Minimal | **HIGH** |
| Buffer Overflow (legacy but useful) | None | LOW |
| Client-Side Attacks | None | MEDIUM |
| Antivirus Evasion | None | **HIGH** |
| Locating/Fixing Public Exploits | None | MEDIUM |
| File Transfer Techniques | Partial (in tool docs) | MEDIUM |
| Report Writing | Basic templates | MEDIUM |

### CEH Gaps

| Topic | Current Status | Priority |
|-------|----------------|----------|
| Footprinting (OSINT) | Basic | MEDIUM |
| Social Engineering | None | MEDIUM |
| Malware Analysis | None | LOW |
| Wireless Hacking | None | **HIGH** |
| Mobile Hacking | None | LOW |
| IoT/OT Hacking | None | LOW |
| Cloud Security (AWS/Azure/GCP) | None | **HIGH** |
| Cryptography | None | MEDIUM |
| DoS/DDoS | None | LOW |
| Session Hijacking | Basic (in web) | MEDIUM |
| IDS/Firewall Evasion | None | MEDIUM |

### PNPT/CRTP Gaps

| Topic | Current Status | Priority |
|-------|----------------|----------|
| OSINT Deep Dive | Basic | MEDIUM |
| External Pentest Methodology | Partial | MEDIUM |
| AD Attack Chains (comprehensive) | Good | LOW |
| Report Writing & Client Debrief | Basic | MEDIUM |
| Defense Bypass (EDR, AMSI) | None | **HIGH** |

---

## Tool Gaps

### Missing High-Priority Tools

| Tool | Category | Certifications |
|------|----------|----------------|
| **Burp Suite** | Web App Testing | OSCP, CEH, eCPPT |
| **ffuf** | Web Fuzzing | OSCP, PNPT |
| **nikto** | Web Scanning | OSCP, CEH |
| **sqlmap** | SQL Injection | CEH, eCPPT |
| **wpscan** | WordPress | OSCP, CEH |
| **searchsploit** | Exploit DB | OSCP, all |
| **PowerView** | AD Enumeration | OSCP, CRTP |
| **Rubeus** | Kerberos | OSCP, CRTP, CRTE |
| **Certify/Certipy** | AD CS | CRTP, CRTE |
| **SharpHound** | AD Collection | All AD certs |
| **PrintSpoofer/GodPotato** | Token Abuse | OSCP |
| **Sliver/Havoc** | C2 Framework | GPEN, Red Team |
| **Covenant/Empire** | C2 Framework | CRTP, GPEN |

### Missing Medium-Priority Tools

| Tool | Category | Certifications |
|------|----------|----------------|
| theHarvester | OSINT | CEH, PNPT |
| Maltego | OSINT | CEH |
| Shodan | Recon | CEH, PNPT |
| Amass | Subdomain Enum | PNPT |
| Nessus/OpenVAS | Vuln Scanning | CEH, GPEN |
| Aircrack-ng | Wireless | CEH |
| Wireshark | Packet Analysis | CEH, GPEN |
| tcpdump | Packet Capture | All |
| Covenant | C2 | CRTP |
| CrackMapExec alternatives | AD | All AD |

---

## Methodology Gaps

### Missing Methodology Documentation

| Topic | Description | Priority |
|-------|-------------|----------|
| **Web Application Testing** | OWASP methodology, common vulns | **HIGH** |
| **Wireless Pentesting** | WiFi attacks, WPA cracking | MEDIUM |
| **Cloud Pentesting** | AWS/Azure/GCP attack patterns | **HIGH** |
| **Physical Security** | Badge cloning, tailgating | LOW |
| **Social Engineering** | Phishing, pretexting | MEDIUM |
| **Red Team Operations** | Full adversary simulation | MEDIUM |
| **Purple Team** | Detection validation | LOW |
| **OSINT Methodology** | Comprehensive recon guide | MEDIUM |

### Missing Framework Integration

| Framework | Status | Priority |
|-----------|--------|----------|
| PTES (full integration) | Partial | MEDIUM |
| OWASP Testing Guide | None | **HIGH** |
| MITRE ATT&CK (mapped) | Partial | MEDIUM |
| Cyber Kill Chain | Basic | LOW |
| NIST 800-115 | Reference only | LOW |

---

## Technique Gaps

### Windows Techniques Missing

| Technique | MITRE ID | Priority |
|-----------|----------|----------|
| AMSI Bypass | T1562.001 | **HIGH** |
| AppLocker Bypass | T1218 | **HIGH** |
| Constrained Language Mode Bypass | - | MEDIUM |
| LOLBAS Techniques | T1218.* | MEDIUM |
| COM Hijacking | T1546.015 | MEDIUM |
| WMI Persistence | T1546.003 | MEDIUM |
| BITS Jobs | T1197 | MEDIUM |

### Linux Techniques Missing

| Technique | MITRE ID | Priority |
|-----------|----------|----------|
| Container Escapes (advanced) | T1611 | MEDIUM |
| eBPF Attacks | - | LOW |
| Fileless Malware | T1620 | MEDIUM |
| Memory-only Payloads | T1055 | MEDIUM |

### Network Techniques Missing

| Technique | Description | Priority |
|-----------|-------------|----------|
| IPv6 Attacks | mitm6, IPv6 poisoning | MEDIUM |
| VLAN Hopping | 802.1Q attacks | LOW |
| BGP Hijacking | Routing attacks | LOW |
| DNS Tunneling | Data exfiltration | MEDIUM |
| ICMP Tunneling | Covert channels | MEDIUM |

---

## Priority Matrix

### Critical Priority (Add Immediately)

1. **Web Application Testing Methodology**
   - SQL Injection (all types)
   - XSS (reflected, stored, DOM)
   - File Inclusion (LFI/RFI)
   - Command Injection
   - File Upload Attacks
   - SSRF, XXE

2. **Burp Suite Documentation**
   - Complete tool guide
   - Intruder, Repeater, Scanner
   - Extensions

3. **AV/EDR Evasion**
   - AMSI bypass techniques
   - Defender evasion
   - AppLocker bypass

4. **Cloud Pentesting Basics**
   - AWS enumeration
   - Azure AD attacks
   - Cloud misconfigurations

### High Priority (Add Soon)

1. **Additional Tools:** ffuf, sqlmap, nikto, wpscan
2. **Rubeus/Certify** for AD attacks
3. **C2 Frameworks** overview (Sliver, Cobalt Strike concepts)
4. **Wireless Attacks** basics
5. **OSINT Methodology** expansion

### Medium Priority (Backlog)

1. Social Engineering documentation
2. Mobile/IoT basics
3. Physical security
4. Forensics awareness
5. Detection/Blue Team perspective

---

## Recommended Additions

### Immediate Actions

```
knowledge/
├── methodology/
│   └── web-application/          # NEW - OWASP methodology
│       ├── README.md
│       ├── sql-injection.md
│       ├── xss.md
│       ├── file-inclusion.md
│       ├── command-injection.md
│       └── file-upload.md
├── techniques/
│   └── evasion/                  # NEW - AV/EDR evasion
│       ├── README.md
│       ├── amsi-bypass.md
│       ├── applocker-bypass.md
│       └── defender-evasion.md
├── tools/
│   ├── burpsuite/                # NEW
│   ├── ffuf/                     # NEW
│   ├── sqlmap/                   # NEW
│   ├── rubeus/                   # NEW
│   └── certify/                  # NEW
└── references/
    ├── cheatsheets/              # NEW
    │   ├── reverse-shells.md
    │   ├── file-transfers.md
    │   └── hash-types.md
    └── resources/
        └── external-links.md
```

### Research Sources for Expansion

1. **HackTricks** - https://book.hacktricks.xyz/
2. **PayloadsAllTheThings** - https://github.com/swisskyrepo/PayloadsAllTheThings
3. **The Hacker Recipes** - https://www.thehacker.recipes/
4. **ired.team** - https://www.ired.team/
5. **GTFOBins** - https://gtfobins.github.io/
6. **LOLBAS** - https://lolbas-project.github.io/
7. **WADComs** - https://wadcoms.github.io/

---

## Next Steps

1. [ ] Create web application methodology section
2. [ ] Add Burp Suite documentation
3. [ ] Document AV/EDR evasion techniques
4. [ ] Add missing high-priority tools
5. [ ] Create reference cheatsheets
6. [ ] Map all techniques to MITRE ATT&CK
7. [ ] Add cloud pentesting basics

---

*Generated: 2025-12-27*
*Based on: OSCP, CEH, PNPT, CRTP, CRTE, GPEN curricula*
