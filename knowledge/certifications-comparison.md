---
title: "Penetration Testing Certifications Comparison"
category: "reference"
tags: ["certifications", "PNPT", "eJPT", "eCPPT", "GPEN", "CRTP", "CRTE", "OSEP"]
last_updated: "2025-12-27"
---

# Penetration Testing Certifications Comparison

> Comprehensive research on major penetration testing certifications, their curricula, tools, and focus areas.

## Table of Contents

- [Overview](#overview)
- [Certification Profiles](#certification-profiles)
  - [PNPT - Practical Network Penetration Tester](#pnpt---practical-network-penetration-tester)
  - [eJPT - eLearnSecurity Junior Penetration Tester](#ejpt---elearnsecurity-junior-penetration-tester)
  - [eCPPT - eLearnSecurity Certified Professional Penetration Tester](#ecppt---elearnsecurity-certified-professional-penetration-tester)
  - [GPEN - GIAC Penetration Tester](#gpen---giac-penetration-tester)
  - [CRTP - Certified Red Team Professional](#crtp---certified-red-team-professional)
  - [CRTE - Certified Red Team Expert](#crte---certified-red-team-expert)
  - [OSEP - Offensive Security Experienced Penetration Tester](#osep---offensive-security-experienced-penetration-tester)
- [Comparison Matrix](#comparison-matrix)
- [Tool Coverage Matrix](#tool-coverage-matrix)
- [Technique Coverage Matrix](#technique-coverage-matrix)
- [Recommended Learning Paths](#recommended-learning-paths)

---

## Overview

This document compares seven major penetration testing certifications across vendors, examining their curricula, required skills, tools, and unique characteristics.

| Certification | Vendor | Level | Price | Exam Duration |
|---------------|--------|-------|-------|---------------|
| **PNPT** | TCM Security | Intermediate | $499 | 5 days + 2 days report |
| **eJPT** | INE/eLearnSecurity | Entry | ~$249 | 48 hours |
| **eCPPT** | INE/eLearnSecurity | Intermediate | ~$400 | 24 hours (v3) / 7 days (v2) |
| **GPEN** | GIAC/SANS | Intermediate-Advanced | $7,640-$8,628 | 3 hours (82 questions) |
| **CRTP** | Altered Security | Beginner-Intermediate | $249-$299 | 24 hours |
| **CRTE** | Altered Security | Intermediate-Advanced | ~$300 | 48 hours |
| **OSEP** | OffSec | Advanced | $1,749+ | 48 hours |

---

## Certification Profiles

### PNPT - Practical Network Penetration Tester

**Vendor:** TCM Security
**Level:** Intermediate
**Price:** $499 (includes training + exam)
**Exam Duration:** 5 days practical + 2 days for report + 15-min debrief

#### Course Modules

The PNPT includes **50+ hours** of video training across 5 courses:

1. **Practical Ethical Hacking** (~25 hours) - Core foundational course
   - Networking fundamentals (TCP/UDP, OSI model, subnetting)
   - Information gathering and reconnaissance
   - Scanning and enumeration
   - Exploitation basics
   - Active Directory attacks
   - Post-exploitation

2. **Open-Source Intelligence (OSINT) Fundamentals**
   - Passive reconnaissance techniques
   - Email discovery
   - Organization mapping
   - Social media intelligence

3. **External Pentest Playbook**
   - External attack surface mapping
   - Perimeter testing methodology
   - A/V and egress bypass techniques

4. **Windows Privilege Escalation**
   - Service misconfigurations
   - Token manipulation
   - Registry exploits
   - Unquoted service paths

5. **Linux Privilege Escalation**
   - SUID/SGID abuse
   - Sudo misconfigurations
   - Cron jobs
   - Kernel exploits

#### Required Skills

- Network fundamentals
- Active Directory exploitation
- A/V and egress bypassing
- Lateral and vertical movement
- Professional report writing
- Live client debrief presentation

#### Active Directory Focus

Strong emphasis on AD attacks including:
- Domain enumeration with BloodHound
- Kerberoasting and AS-REP roasting
- Pass-the-Hash / Pass-the-Ticket
- Golden/Silver ticket attacks
- Domain Controller compromise

#### What Makes It Unique

- **Live debrief requirement** - Must present findings to senior pentesters
- **No proctoring** - Complete in your own environment
- **Lifetime validity** - Does not expire (as of 04/17/2023)
- **Free retake included**
- **Full pentesting methodology** - OSINT through reporting

---

### eJPT - eLearnSecurity Junior Penetration Tester

**Vendor:** INE/eLearnSecurity
**Level:** Entry
**Price:** ~$249
**Exam Duration:** 48 hours (35 questions)
**Validity:** 3 years

#### Entry-Level Topics

The eJPT covers four main domains:

1. **Assessment Methodologies (25%)**
   - Locating network endpoints
   - Port and service identification
   - OS detection
   - Company information extraction (OSINT)
   - Vulnerability identification

2. **Host and Networking Auditing (25%)**
   - Network and system enumeration
   - User account enumeration
   - File transfer techniques
   - Password hash extraction

3. **Host and Network Penetration Testing (35%)**
   - Exploit identification and modification
   - Metasploit exploitation
   - Pivoting techniques
   - Brute-force and hash cracking

4. **Web Application Penetration Testing (15%)**
   - SQL injection (SQLi)
   - Cross-Site Scripting (XSS)
   - Local/Remote File Inclusion (LFI/RFI)
   - Directory brute-forcing
   - Brute-force login attacks

#### Methodology

Follows industry-standard PTES methodology:
1. Reconnaissance (passive/active)
2. Scanning and enumeration
3. Vulnerability analysis
4. Exploitation
5. Post-exploitation basics

#### Tools Required

| Tool | Purpose |
|------|---------|
| Nmap | Host discovery, port scanning, service enumeration |
| Metasploit | Exploitation framework |
| Burp Suite | Web application testing |
| Hydra | Brute-force attacks |
| John the Ripper | Password cracking |
| Dirb/Gobuster | Directory enumeration |
| Wireshark | Network analysis |

#### What Makes It Unique

- **True entry-level** - No prior experience required
- **Hands-on exam** - Real scenario simulation
- **Pivoting emphasis** - Critical skill tested
- **Auto-graded** - Results within hours
- **Bug bounty preparation** - Red team entry path

---

### eCPPT - eLearnSecurity Certified Professional Penetration Tester

**Vendor:** INE/eLearnSecurity
**Level:** Intermediate (2+ years experience)
**Price:** ~$400
**Exam Duration:** 24 hours (v3) / 7+7 days (v2)
**Validity:** 3 years

#### Exam Domains (eCPPTv3)

1. **Information Gathering & Reconnaissance (10%)**
   - Host discovery and port scanning
   - Service enumeration

2. **Initial Access (15%)**
   - Username enumeration
   - Password spraying
   - Brute-force attacks

3. **Web Application Penetration Testing (15%)**
   - SQL injection
   - XSS exploitation
   - Credential exfiltration

4. **Exploitation & Post-Exploitation (25%)**
   - Vulnerability exploitation
   - Privilege escalation
   - Credential harvesting

5. **Exploit Development (5%)**
   - Memory corruption attacks
   - Stack-based buffer overflows

6. **Active Directory Penetration Testing (30%)**
   - Lateral movement (Pass-the-Hash, Pass-the-Ticket)
   - AD enumeration
   - Domain privilege escalation

#### Advanced Topics

**Pivoting and Tunneling:**
- SSH tunneling and port forwarding
- Double pivoting techniques
- ProxyChains configuration
- Chisel tunneling
- Ligolo-ng
- Meterpreter routing

**Buffer Overflow:**
- Stack-based buffer overflow
- Finding offsets (EIP overwrite)
- Bad character identification
- Shellcode generation
- Return-oriented exploitation

**Privilege Escalation:**
- Windows and Linux techniques
- Token manipulation
- Service exploitation

#### Course Content (~107 hours)

| Module | Duration |
|--------|----------|
| Resource Development & Initial Access | ~22 hours |
| Web Application Attacks | ~14 hours |
| Network Security | ~17 hours |
| Exploit Development | ~7 hours |
| Post Exploitation | ~18 hours |
| Red Teaming | ~19 hours |

#### What Makes It Unique

- **Heavy pivoting focus** - Must master multi-hop access
- **Buffer overflow required** - Stack-based BOF is critical
- **Professional report** - Commercial-grade deliverable
- **Real network segmentation** - Not individual machines
- **7-day practical (v2)** - Extended realistic engagement

---

### GPEN - GIAC Penetration Tester

**Vendor:** GIAC/SANS (SEC560 course)
**Level:** Intermediate-Advanced
**Price:** $7,640-$8,628 (training + exam)
**Exam Duration:** 3 hours (82 questions)
**Passing Score:** 73%
**Validity:** 4 years (renewable ~$429-$499)

#### SEC560 Course Modules

**Section 1: Planning, Scoping, and Reconnaissance**
- Penetration testing mindset
- Infrastructure setup
- Pre-engagement planning
- OSINT and organizational reconnaissance
- Masscan and Nmap scanning

**Section 2: In-Depth Scanning and Initial Access**
- Advanced Nmap (version/OS detection, NSE)
- Password attacks
- Azure and Entra ID spraying
- Responder attacks
- Metasploit and Meterpreter

**Section 3: Post-Exploitation and Pivoting**
- Credential harvesting
- C2 establishment
- Privilege escalation (Windows/Linux)
- Lateral movement with Impacket
- SSH tunneling and pivoting

**Section 4: Active Directory and Kerberos**
- Kerberoasting
- BloodHound attack path mapping
- ADCS exploitation
- Pass-the-Ticket
- DCSync
- Golden/Silver tickets

**Section 5: Azure and Cloud**
- Azure authentication attacks
- RBAC abuse
- Managed identity exploitation
- Hybrid identity attacks

**Section 6: Capture the Flag**
- Full engagement simulation
- Team-based competition

#### Enterprise Focus

- **30+ hands-on labs**
- **Hybrid cloud coverage** - On-prem AD + Azure/Entra ID
- **Modern tooling** - Sliver C2, Empire, BloodHound
- **EDR evasion** - Detection avoidance techniques
- **Real adversary simulation** - TTP mapping

#### Tools Covered

| Category | Tools |
|----------|-------|
| Scanning | Nmap, Masscan |
| Exploitation | Metasploit, Impacket |
| C2 | Sliver, Empire |
| AD Attacks | BloodHound, Mimikatz |
| Password | Hashcat, John |
| Lateral Movement | Impacket, PSExec |

#### What Makes It Unique

- **CyberLive practical testing** - Not just multiple choice
- **Enterprise scale** - Large network scenarios
- **Azure integration** - Modern cloud attacks
- **SANS quality** - Industry gold standard
- **Open book exam** - Index preparation is key

---

### CRTP - Certified Red Team Professional

**Vendor:** Altered Security
**Level:** Beginner-Intermediate
**Price:** $249 (30 days) / $299 (bootcamp)
**Exam Duration:** 24 hours
**Validity:** 3 years (renewable free)

#### Course Syllabus

The "Attacking & Defending Active Directory" course covers:

**1. Domain Enumeration**
- PowerView enumeration
- BloodHound/SharpHound collection
- ADModule techniques
- OPSEC-conscious enumeration

**2. Local Privilege Escalation**
- Service misconfigurations
- Unquoted service paths
- DLL hijacking
- Token manipulation

**3. Lateral Movement**
- Pass-the-Hash
- Pass-the-Ticket
- Overpass-the-Hash
- Remote PowerShell
- PSRemoting

**4. Domain Privilege Escalation**
- Kerberoasting
- AS-REP Roasting
- Unconstrained delegation
- Constrained delegation
- Resource-based constrained delegation (RBCD)
- ACL abuse

**5. Domain Persistence**
- Golden Tickets
- Silver Tickets
- Skeleton Key
- DCSync
- DCShadow

**6. Cross-Trust Attacks**
- Forest trust enumeration
- SID History abuse
- Foreign Security Principals

#### Tools Focus

| Tool | Purpose |
|------|---------|
| PowerView | AD enumeration |
| BloodHound/SharpHound | Attack path mapping |
| Rubeus | Kerberos abuse |
| Mimikatz | Credential extraction |
| ADModule | Microsoft-signed enumeration |
| PowerUpSQL | SQL Server attacks |
| Certify | AD CS exploitation |

#### Defense Bypass

- AMSI bypass techniques
- Windows Defender evasion
- Microsoft Defender for Endpoint (MDE)
- Microsoft Defender for Identity (MDI)
- Script obfuscation

#### What Makes It Unique

- **PowerShell-focused** - Not Kali-centric
- **Fully patched labs** - Server 2022 environment
- **Feature abuse** - Not CVE/exploit focused
- **Manual tool installation** - Real-world simulation
- **Defense coverage** - Blue team perspective included

---

### CRTE - Certified Red Team Expert

**Vendor:** Altered Security
**Level:** Intermediate-Advanced
**Price:** ~$300
**Exam Duration:** 48 hours + 48 hours report
**Validity:** 3 years

#### Advanced Topics

Building on CRTP, CRTE covers:

**1. Advanced Cross-Forest Attacks**
- SID Filtering bypass
- Foreign Security Principals abuse
- ACL attacks across trusts
- PAM trust abuse
- Shadow security principals

**2. Azure AD Integration**
- Hybrid Identity attacks
- Azure AD Connect exploitation
- On-prem to cloud lateral movement
- PTA/PHS abuse

**3. Advanced AD CS Attacks**
- Certificate template abuse
- ESC1-ESC8 scenarios
- Golden certificate

**4. Advanced Persistence**
- AdminSDHolder
- Security descriptor modification
- gMSA abuse
- LAPS exploitation

**5. Defense Evasion**
- Advanced AMSI bypass
- Windows Defender bypass
- MDE evasion
- MDI bypass
- Application allowlisting bypass

**6. Defense Understanding**
- Red Forest architecture
- Just Enough Administration (JEA)
- Privileged Access Workstations (PAW)
- LAPS implementation
- Selective Authentication
- Deception technologies
- Windows Defender Application Control (WDAC)

#### Lab Environment

- **Multiple domains and forests**
- **Fully patched Server 2019**
- **Azure AD integration**
- **SQL Server attacks**
- **5 servers to compromise**

#### What Makes It Unique

- **Multi-forest environment** - Complex trust relationships
- **Azure hybrid identity** - Cloud attack paths
- **Defense-focused sections** - Understanding protections
- **Enterprise-scale** - Realistic large environment
- **Best value** - Comprehensive at ~$300

---

### OSEP - Offensive Security Experienced Penetration Tester

**Vendor:** OffSec (PEN-300)
**Level:** Advanced
**Price:** $1,749+
**Exam Duration:** 48 hours (proctored)
**Prerequisites:** OSCP-level experience recommended

#### PEN-300 Syllabus Modules

**1. Client-Side Code Execution**
- Microsoft Office attacks
- Macro development
- Shellcode runners
- PowerShell in-memory execution
- Proxy-aware implants

**2. Process Injection**
- DLL injection
- Reflective DLL injection
- Process hollowing
- Thread execution hijacking

**3. Antivirus Evasion**
- Signature detection bypass
- Behavioral detection bypass
- Metasploit AV bypass
- C# payload development
- VBA AV bypass

**4. Advanced AV Evasion**
- Intel architecture fundamentals
- AMSI bypass techniques
- PowerShell AMSI reflection bypass
- UAC bypass vs Defender

**5. Application Whitelisting Bypass**
- Living off the land (LOLBAS)
- Alternate data streams
- InstallUtil/RegAsm abuse
- MSBuild exploitation
- Kiosk breakouts

**6. Lateral Movement (Windows)**
- WMI and DCOM
- PSExec alternatives
- Pass-the-Hash variations
- Named pipe impersonation

**7. Lateral Movement (Linux)**
- SSH persistence and hijacking
- ControlMaster exploitation
- Ansible credential abuse
- DevOps infrastructure attacks

**8. Active Directory Exploitation**
- Unconstrained delegation
- Constrained delegation
- Resource-based constrained delegation (RBCD)
- Kerberos attacks

**9. Microsoft SQL Server Attacks**
- UNC path injection
- NTLM relay through SQL
- Linked database exploitation
- Command execution

**10. Network Evasion**
- Proxy awareness
- HTTPS inspection bypass
- IDS/IPS evasion
- DNS tunneling
- Egress filtering bypass

#### Custom Exploit Development

- C# shellcode loaders
- PowerShell obfuscation
- Custom payload generation
- Implant development
- Process injection code

#### Exam Format

- **6 machines** to compromise
- **10 flags** for full points
- **Multiple exploitation paths**
- **Sequential dependencies**
- **Professional report required**

#### What Makes It Unique

- **C# mastery required** - Heavy development focus
- **Custom tooling** - Beyond off-the-shelf
- **EDR evasion** - Modern defense bypass
- **Part of OSCE3** - With OSWE and OSED
- **True advanced level** - OSCP is prerequisite

---

## Comparison Matrix

### Topic Coverage

| Topic | PNPT | eJPT | eCPPT | GPEN | CRTP | CRTE | OSEP |
|-------|:----:|:----:|:-----:|:----:|:----:|:----:|:----:|
| **Reconnaissance** |
| OSINT | ●●● | ●● | ●● | ●●● | ● | ● | ● |
| Network Scanning | ●●● | ●●● | ●●● | ●●● | ●● | ●● | ●● |
| Service Enumeration | ●●● | ●●● | ●●● | ●●● | ●● | ●● | ●● |
| **Initial Access** |
| Web App Attacks | ●● | ●● | ●●● | ●● | ○ | ○ | ● |
| Client-Side Attacks | ●● | ● | ●● | ●● | ● | ● | ●●● |
| Password Attacks | ●●● | ●●● | ●●● | ●●● | ●● | ●● | ●● |
| **Active Directory** |
| Domain Enumeration | ●●● | ● | ●●● | ●●● | ●●● | ●●● | ●●● |
| Kerberos Attacks | ●●● | ○ | ●●● | ●●● | ●●● | ●●● | ●●● |
| Delegation Attacks | ●● | ○ | ●● | ●●● | ●●● | ●●● | ●●● |
| AD CS Attacks | ● | ○ | ●● | ●●● | ●● | ●●● | ● |
| Cross-Forest Attacks | ● | ○ | ● | ●● | ●● | ●●● | ●● |
| **Privilege Escalation** |
| Windows Privesc | ●●● | ●● | ●●● | ●●● | ●●● | ●●● | ●●● |
| Linux Privesc | ●●● | ●● | ●●● | ●●● | ● | ● | ●● |
| **Lateral Movement** |
| Pass-the-Hash | ●●● | ● | ●●● | ●●● | ●●● | ●●● | ●●● |
| Pass-the-Ticket | ●● | ○ | ●●● | ●●● | ●●● | ●●● | ●●● |
| Pivoting/Tunneling | ●● | ●●● | ●●● | ●●● | ●● | ●● | ●●● |
| **Evasion** |
| AV Bypass | ●● | ○ | ●● | ●●● | ●●● | ●●● | ●●● |
| AMSI Bypass | ● | ○ | ● | ●● | ●●● | ●●● | ●●● |
| EDR Evasion | ● | ○ | ● | ●● | ●● | ●●● | ●●● |
| App Whitelisting | ○ | ○ | ● | ●● | ●● | ●●● | ●●● |
| **Advanced** |
| Buffer Overflow | ● | ○ | ●●● | ● | ○ | ○ | ● |
| Exploit Development | ○ | ○ | ●● | ● | ○ | ○ | ●●● |
| C2 Frameworks | ●● | ● | ●● | ●●● | ● | ●● | ●●● |
| Azure/Cloud | ○ | ○ | ● | ●●● | ○ | ●●● | ● |
| **Reporting** |
| Professional Reports | ●●● | ○ | ●●● | ●● | ●● | ●●● | ●●● |
| Client Debrief | ●●● | ○ | ○ | ○ | ○ | ○ | ○ |

**Legend:** ●●● = Deep coverage | ●● = Moderate coverage | ● = Basic coverage | ○ = Not covered

---

## Tool Coverage Matrix

| Tool | PNPT | eJPT | eCPPT | GPEN | CRTP | CRTE | OSEP |
|------|:----:|:----:|:-----:|:----:|:----:|:----:|:----:|
| **Reconnaissance** |
| Nmap | ● | ● | ● | ● | ● | ● | ● |
| Masscan | ● | ○ | ● | ● | ○ | ○ | ○ |
| RustScan | ● | ○ | ○ | ○ | ○ | ○ | ○ |
| **Enumeration** |
| Gobuster/Feroxbuster | ● | ● | ● | ● | ○ | ○ | ○ |
| Enum4linux | ● | ● | ● | ● | ○ | ○ | ○ |
| SMBClient/SMBMap | ● | ● | ● | ● | ● | ● | ○ |
| **Active Directory** |
| BloodHound | ● | ○ | ● | ● | ● | ● | ● |
| PowerView | ● | ○ | ● | ● | ● | ● | ● |
| Rubeus | ● | ○ | ● | ● | ● | ● | ● |
| Mimikatz | ● | ○ | ● | ● | ● | ● | ● |
| Kerbrute | ● | ○ | ● | ● | ● | ● | ○ |
| Certify | ○ | ○ | ● | ● | ● | ● | ○ |
| **Exploitation** |
| Metasploit | ● | ● | ● | ● | ○ | ○ | ● |
| Impacket | ● | ○ | ● | ● | ● | ● | ● |
| Evil-WinRM | ● | ○ | ● | ● | ● | ● | ○ |
| CrackMapExec/NetExec | ● | ○ | ● | ● | ● | ● | ○ |
| **Password** |
| Hashcat | ● | ● | ● | ● | ● | ● | ● |
| John the Ripper | ● | ● | ● | ● | ● | ● | ● |
| Hydra | ● | ● | ● | ● | ● | ● | ○ |
| **Pivoting** |
| Chisel | ● | ○ | ● | ● | ● | ● | ● |
| Ligolo-ng | ● | ○ | ● | ● | ○ | ○ | ○ |
| ProxyChains | ● | ● | ● | ● | ● | ● | ● |
| SSH Tunneling | ● | ● | ● | ● | ● | ● | ● |
| **C2 Frameworks** |
| Sliver | ○ | ○ | ● | ● | ○ | ○ | ● |
| Cobalt Strike | ○ | ○ | ○ | ● | ○ | ○ | ○ |
| Empire | ○ | ○ | ● | ● | ○ | ○ | ○ |
| **Post-Exploitation** |
| LinPEAS/WinPEAS | ● | ● | ● | ● | ● | ● | ○ |
| pspy | ● | ○ | ● | ● | ○ | ○ | ○ |

---

## Technique Coverage Matrix

| Technique | PNPT | eJPT | eCPPT | GPEN | CRTP | CRTE | OSEP |
|-----------|:----:|:----:|:-----:|:----:|:----:|:----:|:----:|
| **Credential Attacks** |
| Kerberoasting | ● | ○ | ● | ● | ● | ● | ● |
| AS-REP Roasting | ● | ○ | ● | ● | ● | ● | ● |
| Password Spraying | ● | ● | ● | ● | ● | ● | ● |
| Credential Stuffing | ○ | ○ | ● | ● | ○ | ○ | ● |
| NTLM Relay | ● | ○ | ● | ● | ● | ● | ● |
| DCSync | ● | ○ | ● | ● | ● | ● | ● |
| **Delegation** |
| Unconstrained | ● | ○ | ● | ● | ● | ● | ● |
| Constrained | ● | ○ | ● | ● | ● | ● | ● |
| RBCD | ● | ○ | ● | ● | ● | ● | ● |
| **Persistence** |
| Golden Ticket | ● | ○ | ● | ● | ● | ● | ● |
| Silver Ticket | ● | ○ | ● | ● | ● | ● | ● |
| Skeleton Key | ○ | ○ | ○ | ● | ● | ● | ○ |
| DCShadow | ○ | ○ | ○ | ● | ● | ● | ○ |
| **Process Injection** |
| DLL Injection | ○ | ○ | ● | ● | ○ | ○ | ● |
| Reflective DLL | ○ | ○ | ○ | ● | ○ | ○ | ● |
| Process Hollowing | ○ | ○ | ○ | ● | ○ | ○ | ● |
| **Evasion Techniques** |
| AMSI Bypass | ● | ○ | ● | ● | ● | ● | ● |
| ETW Bypass | ○ | ○ | ○ | ● | ● | ● | ● |
| WDAC Bypass | ○ | ○ | ○ | ● | ○ | ● | ● |
| Living off the Land | ● | ○ | ● | ● | ● | ● | ● |

---

## Recommended Learning Paths

### Entry to Advanced (Red Team Focus)

```
eJPT → PNPT → CRTP → CRTE → OSEP
```

### Entry to Advanced (Enterprise Focus)

```
eJPT → eCPPT → GPEN → OSEP
```

### Active Directory Specialist

```
eJPT → CRTP → CRTE → GPEN (AD sections)
```

### Web Application + Network

```
eJPT → eCPPT → OSCP → OSWE
```

### Speed Run (Already Experienced)

```
CRTP → OSEP (with GPEN for enterprise breadth)
```

---

## Summary: What Makes Each Unique

| Certification | Key Differentiator |
|---------------|-------------------|
| **PNPT** | Live client debrief; full engagement simulation; excellent value |
| **eJPT** | True entry-level; pivoting focus; accessible price point |
| **eCPPT** | Buffer overflow mastery; double pivoting; segmented networks |
| **GPEN** | Enterprise scale; Azure/cloud coverage; SANS quality; CyberLive |
| **CRTP** | PowerShell-centric AD attacks; feature abuse over CVEs |
| **CRTE** | Multi-forest complexity; Azure hybrid identity; defense coverage |
| **OSEP** | Custom exploit development; C# mastery; advanced evasion |

---

## Sources

### PNPT
- [TCM Security PNPT Certification](https://certifications.tcm-sec.com/pnpt/)
- [TCM Security Academy - Practical Ethical Hacking](https://academy.tcm-sec.com/p/practical-ethical-hacking-the-complete-course)
- [PNPT Training Overview PDF](https://certifications.tcm-sec.com/wp-content/uploads/2022/01/TCMS-PNPT-Training-Overview.pdf)

### eJPT
- [INE Security eJPT Certification](https://ine.com/security/certifications/ejpt-certification)
- [eJPT Certification Details](https://info.ine.com/ejpt/)

### eCPPT
- [INE Security eCPPT Certification](https://ine.com/security/certifications/ecppt-certification/)
- [eCPPTv2 Notes GitHub](https://github.com/dev-angelist/eCPPTv2-PTP-Notes)
- [Network Pivoting and eCPPT - Echelon Cyber](https://echeloncyber.com/intelligence/entry/network-pivoting-and-the-ecppt-exam)

### GPEN
- [GIAC GPEN Certification](https://www.giac.org/certifications/penetration-tester-gpen/)
- [SANS SEC560 Course](https://www.sans.org/cyber-security-courses/enterprise-penetration-testing)

### CRTP/CRTE
- [Altered Security CRTP](https://www.alteredsecurity.com/post/certified-red-team-professional-crtp)
- [Altered Security CRTE](https://www.alteredsecurity.com/redteamlab)
- [Altered Security Red Team Labs](https://www.alteredsecurity.com/online-labs)

### OSEP
- [OffSec PEN-300 Course](https://www.offsec.com/courses/pen-300/)
- [OSEP Preparation Guide GitHub](https://github.com/deletehead/pen_300_osep_prep)
- [PEN-300 Syllabus PDF](https://www.offsec.com/documentation/PEN300-Syllabus.pdf)

---

*Last updated: 2025-12-27*
