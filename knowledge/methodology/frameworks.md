---
title: Penetration Testing Frameworks and Methodologies
category: methodology
tags:
  - frameworks
  - methodology
  - PTES
  - OWASP
  - NIST
  - OSSTMM
  - MITRE-ATT&CK
  - kill-chain
  - standards
last_updated: 2025-12-27
---

# Penetration Testing Frameworks and Methodologies

Comprehensive documentation of industry-standard penetration testing frameworks, security assessment methodologies, and attack modeling frameworks.

## Table of Contents

1. [Overview](#overview)
2. [PTES - Penetration Testing Execution Standard](#ptes---penetration-testing-execution-standard)
3. [OWASP Testing Guide](#owasp-testing-guide)
4. [NIST SP 800-115](#nist-sp-800-115)
5. [OSSTMM](#osstmm---open-source-security-testing-methodology-manual)
6. [MITRE ATT&CK Framework](#mitre-attck-framework)
7. [Cyber Kill Chain](#cyber-kill-chain)
8. [ISSAF](#issaf---information-systems-security-assessment-framework)
9. [Unified Kill Chain](#unified-kill-chain)
10. [Framework Comparison](#framework-comparison)
11. [Practical Application](#practical-application)

---

## Overview

Penetration testing methodologies provide structured approaches to security assessments. Each framework offers unique perspectives:

| Framework | Focus | Best For |
|-----------|-------|----------|
| **PTES** | End-to-end pentesting process | Comprehensive penetration tests |
| **OWASP** | Web/API application security | Web application assessments |
| **NIST 800-115** | Compliance and documentation | Federal/regulated environments |
| **OSSTMM** | Operational security metrics | Holistic security audits |
| **MITRE ATT&CK** | Adversary tactics and techniques | Threat emulation, detection |
| **Cyber Kill Chain** | Attack lifecycle phases | Defensive planning |
| **ISSAF** | Comprehensive assessment | Custom methodology development |
| **Unified Kill Chain** | Modern attack modeling | Advanced threat analysis |

---

## PTES - Penetration Testing Execution Standard

The Penetration Testing Execution Standard (PTES) is the de facto industry standard for conducting penetration tests. Created in 2009 by penetration testers for penetration testers.

### The 7 PTES Phases

#### Phase 1: Pre-Engagement Interactions

**Purpose:** Establish scope, rules, and expectations before testing begins.

| Activity | Description | Deliverables |
|----------|-------------|--------------|
| Scope Definition | Define systems, networks, and applications in scope | Scope document |
| Rules of Engagement | Establish testing limitations and boundaries | ROE document |
| Authorization | Obtain written permission | Signed authorization |
| Communication Plan | Define emergency contacts and reporting procedures | Contact matrix |
| Timeline | Establish testing windows and milestones | Project schedule |
| Legal Considerations | Review contracts, NDAs, liability | Legal documents |

**Key Questions:**
- What is the goal of the penetration test?
- What systems/networks are in scope?
- Are there any systems that must be excluded?
- What is the testing window?
- Who are the emergency contacts?

---

#### Phase 2: Intelligence Gathering

**Purpose:** Collect information about the target to identify potential attack vectors.

**Three Levels of Intelligence Gathering:**

| Level | Type | Description |
|-------|------|-------------|
| Level 1 | Compliance-driven | Primarily automated tools |
| Level 2 | Best practice | Automated + manual analysis |
| Level 3 | State-sponsored | Full scope, detailed manual analysis |

**Information Categories:**

```
Passive Reconnaissance (OSINT)
├── Domain Information
│   ├── WHOIS records
│   ├── DNS records (A, MX, NS, TXT, PTR)
│   ├── Subdomain enumeration
│   └── Certificate transparency logs
├── Organization Intelligence
│   ├── Employee names and roles
│   ├── Email format discovery
│   ├── LinkedIn/social media
│   └── Job postings (tech stack hints)
├── Technical Intelligence
│   ├── Shodan/Censys queries
│   ├── Google dorks
│   ├── Wayback Machine
│   └── Code repositories (GitHub, GitLab)
└── Infrastructure
    ├── IP ranges (ASN lookup)
    ├── Hosting providers
    └── CDN/WAF detection

Active Reconnaissance
├── Port scanning
├── Service enumeration
├── DNS zone transfers
├── Website crawling
└── Technology fingerprinting
```

---

#### Phase 3: Threat Modeling

**Purpose:** Identify and prioritize threats based on business context.

**Key Components:**

1. **Business Asset Analysis**
   - Identify critical assets and their value
   - Map business processes to technical systems
   - Understand data flows

2. **Threat Agent/Community Analysis**
   - Who would target this organization?
   - What are their capabilities?
   - What are their motivations?

3. **Attack Surface Mapping**
   - External-facing systems
   - Internal network segments
   - Third-party integrations

**Threat Model Output:**
```
Asset: Customer Database
├── Value: High (PII, financial data)
├── Threat Agents: Cybercriminals, competitors
├── Attack Vectors:
│   ├── SQL Injection via web application
│   ├── Credential theft via phishing
│   └── Insider threat
└── Priority: Critical
```

---

#### Phase 4: Vulnerability Analysis

**Purpose:** Identify and validate potential vulnerabilities.

**Testing Types:**

| Type | Description | Tools |
|------|-------------|-------|
| **Automated Scanning** | Tool-based vulnerability identification | Nessus, OpenVAS, Qualys |
| **Manual Testing** | Human-driven analysis and validation | Burp Suite, manual review |
| **Validation** | Confirm vulnerabilities are exploitable | Manual exploitation |
| **False Positive Elimination** | Remove non-exploitable findings | Manual verification |

**Vulnerability Categories:**
- Network vulnerabilities
- Web application vulnerabilities
- Configuration weaknesses
- Missing patches
- Weak credentials
- Protocol vulnerabilities

---

#### Phase 5: Exploitation

**Purpose:** Demonstrate real-world impact by exploiting validated vulnerabilities.

**Key Principles:**
- Identify the path of least resistance
- Minimize detection
- Document all attempts
- Consider business impact

**Exploitation Categories:**

```
Exploitation Techniques
├── Network Attacks
│   ├── Service exploitation (CVEs)
│   ├── Protocol attacks
│   └── Network poisoning
├── Web Application Attacks
│   ├── Injection attacks (SQLi, XSS, XXE)
│   ├── Authentication bypass
│   ├── File upload abuse
│   └── Server-side vulnerabilities
├── Client-Side Attacks
│   ├── Phishing
│   ├── Malicious documents
│   └── Browser exploitation
└── Physical/Social Engineering
    ├── Pretexting
    ├── Tailgating
    └── USB drops
```

---

#### Phase 6: Post-Exploitation

**Purpose:** Determine the value of compromised systems and expand access.

**Core Activities:**

| Activity | Description |
|----------|-------------|
| **System Profiling** | OS, architecture, installed software, users |
| **Credential Harvesting** | Extract passwords, hashes, tokens |
| **Data Discovery** | Locate sensitive files and databases |
| **Network Mapping** | Identify connected systems and segments |
| **Privilege Escalation** | Elevate to admin/root/SYSTEM |
| **Lateral Movement** | Pivot to additional systems |
| **Persistence** | Maintain access for continued testing |
| **Data Exfiltration** | Demonstrate data extraction capability |

**High-Value Targets:**
- Domain controllers
- Database servers
- File servers
- Email systems
- Backup systems
- Administrative workstations

---

#### Phase 7: Reporting

**Purpose:** Communicate findings and recommendations to stakeholders.

**Report Components:**

| Section | Audience | Content |
|---------|----------|---------|
| **Executive Summary** | Leadership | High-level findings, business risk, recommendations |
| **Technical Report** | IT/Security teams | Detailed findings, evidence, remediation steps |
| **Vulnerability Details** | Engineers | CVE references, reproduction steps, fix guidance |
| **Appendices** | Technical reference | Raw data, tool output, logs |

**Finding Format:**
```
Finding: SQL Injection in Login Form
├── Severity: Critical (CVSS 9.8)
├── Location: https://app.example.com/login
├── Description: User input not sanitized
├── Evidence: [Screenshots, payloads]
├── Impact: Database compromise, data theft
├── Remediation: Parameterized queries, input validation
└── References: OWASP SQLi, CWE-89
```

---

## OWASP Testing Guide

The OWASP Web Security Testing Guide (WSTG) is the premier resource for web application security testing. Current version: 4.2 (December 2020).

### Testing Categories (11 Categories, 90+ Tests)

#### 4.1 Information Gathering (10 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-INFO-01 | Search Engine Discovery | Google dorks, cached pages |
| WSTG-INFO-02 | Fingerprint Web Server | Server type and version |
| WSTG-INFO-03 | Review Metafiles | robots.txt, sitemap.xml |
| WSTG-INFO-04 | Enumerate Applications | Virtual hosts, subdomains |
| WSTG-INFO-05 | Review Webpage Content | Comments, metadata |
| WSTG-INFO-06 | Identify Entry Points | Input vectors, parameters |
| WSTG-INFO-07 | Map Execution Paths | Application workflow |
| WSTG-INFO-08 | Fingerprint Framework | CMS, framework detection |
| WSTG-INFO-09 | Fingerprint Application | Custom application analysis |
| WSTG-INFO-10 | Map Architecture | Infrastructure mapping |

#### 4.2 Configuration and Deployment (11 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-CONF-01 | Network Configuration | Firewalls, load balancers |
| WSTG-CONF-02 | Platform Configuration | Server hardening |
| WSTG-CONF-03 | File Extensions | Sensitive file handling |
| WSTG-CONF-04 | Backup Files | Old/backup file exposure |
| WSTG-CONF-05 | Admin Interfaces | Admin panel discovery |
| WSTG-CONF-06 | HTTP Methods | OPTIONS, TRACE, etc. |
| WSTG-CONF-07 | HSTS | Transport security headers |
| WSTG-CONF-08 | Cross-Domain Policy | CORS, crossdomain.xml |
| WSTG-CONF-09 | File Permissions | Directory listings |
| WSTG-CONF-10 | Subdomain Takeover | Dangling DNS records |
| WSTG-CONF-11 | Cloud Storage | S3, Azure blob exposure |

#### 4.3 Identity Management (5 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-IDNT-01 | Role Definitions | Privilege separation |
| WSTG-IDNT-02 | User Registration | Registration process flaws |
| WSTG-IDNT-03 | Account Provisioning | Account creation security |
| WSTG-IDNT-04 | Account Enumeration | Username discovery |
| WSTG-IDNT-05 | Username Policy | Weak username rules |

#### 4.4 Authentication (10 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-ATHN-01 | Encrypted Channel | Credential transmission |
| WSTG-ATHN-02 | Default Credentials | Factory passwords |
| WSTG-ATHN-03 | Lockout Mechanism | Brute force protection |
| WSTG-ATHN-04 | Authentication Bypass | Schema circumvention |
| WSTG-ATHN-05 | Remember Password | Password storage |
| WSTG-ATHN-06 | Browser Cache | Credential caching |
| WSTG-ATHN-07 | Password Policy | Complexity requirements |
| WSTG-ATHN-08 | Security Questions | Recovery question strength |
| WSTG-ATHN-09 | Password Reset | Reset functionality |
| WSTG-ATHN-10 | Alternative Channels | Multi-channel auth |

#### 4.5 Authorization (4 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-ATHZ-01 | Directory Traversal | Path manipulation |
| WSTG-ATHZ-02 | Authorization Bypass | Access control bypass |
| WSTG-ATHZ-03 | Privilege Escalation | Vertical/horizontal |
| WSTG-ATHZ-04 | IDOR | Insecure direct object refs |

#### 4.6 Session Management (9 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-SESS-01 | Session Schema | Token generation |
| WSTG-SESS-02 | Cookie Attributes | Secure, HttpOnly, SameSite |
| WSTG-SESS-03 | Session Fixation | Pre-set session IDs |
| WSTG-SESS-04 | Exposed Variables | Session data leakage |
| WSTG-SESS-05 | CSRF | Cross-site request forgery |
| WSTG-SESS-06 | Logout Functionality | Session termination |
| WSTG-SESS-07 | Session Timeout | Inactivity timeout |
| WSTG-SESS-08 | Session Puzzling | Variable overwrite |
| WSTG-SESS-09 | Session Hijacking | Token theft |

#### 4.7 Input Validation (19 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-INPV-01 | Reflected XSS | Non-persistent XSS |
| WSTG-INPV-02 | Stored XSS | Persistent XSS |
| WSTG-INPV-03 | HTTP Verb Tampering | Method manipulation |
| WSTG-INPV-04 | HTTP Parameter Pollution | Parameter injection |
| WSTG-INPV-05 | SQL Injection | Database injection |
| WSTG-INPV-06 | LDAP Injection | Directory injection |
| WSTG-INPV-07 | XML Injection | XML parsing attacks |
| WSTG-INPV-08 | SSI Injection | Server-side includes |
| WSTG-INPV-09 | XPath Injection | XPath query injection |
| WSTG-INPV-10 | IMAP/SMTP Injection | Mail injection |
| WSTG-INPV-11 | Code Injection | Server-side code |
| WSTG-INPV-12 | Command Injection | OS command execution |
| WSTG-INPV-13 | Format String | Format string attacks |
| WSTG-INPV-14 | Incubated Vulnerability | Delayed execution |
| WSTG-INPV-15 | HTTP Splitting/Smuggling | Request manipulation |
| WSTG-INPV-16 | Incoming Requests | Request validation |
| WSTG-INPV-17 | Host Header Injection | Virtual host attacks |
| WSTG-INPV-18 | SSTI | Server-side template injection |
| WSTG-INPV-19 | SSRF | Server-side request forgery |

#### 4.8 Error Handling (2 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-ERRH-01 | Improper Error Handling | Verbose errors |
| WSTG-ERRH-02 | Stack Traces | Exception exposure |

#### 4.9 Cryptography (4 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-CRYP-01 | Transport Security | TLS configuration |
| WSTG-CRYP-02 | Padding Oracle | CBC padding attacks |
| WSTG-CRYP-03 | Unencrypted Channels | Sensitive data in clear |
| WSTG-CRYP-04 | Weak Encryption | Algorithm strength |

#### 4.10 Business Logic (9 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-BUSL-01 | Data Validation | Business rule validation |
| WSTG-BUSL-02 | Request Forgery | Workflow manipulation |
| WSTG-BUSL-03 | Integrity Checks | Data integrity |
| WSTG-BUSL-04 | Process Timing | Race conditions |
| WSTG-BUSL-05 | Function Limits | Rate limiting |
| WSTG-BUSL-06 | Workflow Circumvention | Step skipping |
| WSTG-BUSL-07 | Application Misuse | Feature abuse |
| WSTG-BUSL-08 | File Upload Types | Allowed file types |
| WSTG-BUSL-09 | Malicious File Upload | File upload attacks |

#### 4.11 Client-Side (13 tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-CLNT-01 | DOM XSS | DOM-based XSS |
| WSTG-CLNT-02 | JavaScript Execution | Client-side code |
| WSTG-CLNT-03 | HTML Injection | HTML manipulation |
| WSTG-CLNT-04 | URL Redirect | Open redirects |
| WSTG-CLNT-05 | CSS Injection | Style injection |
| WSTG-CLNT-06 | Resource Manipulation | Client-side resources |
| WSTG-CLNT-07 | CORS | Cross-origin issues |
| WSTG-CLNT-08 | Cross Site Flashing | Flash-based attacks |
| WSTG-CLNT-09 | Clickjacking | UI redressing |
| WSTG-CLNT-10 | WebSockets | WebSocket security |
| WSTG-CLNT-11 | Web Messaging | postMessage security |
| WSTG-CLNT-12 | Browser Storage | localStorage/sessionStorage |
| WSTG-CLNT-13 | Cross Site Script Inclusion | XSSI attacks |

#### 4.12 API Testing (1+ tests)

| ID | Test | Description |
|----|------|-------------|
| WSTG-APIT-01 | GraphQL Testing | GraphQL-specific tests |

---

## NIST SP 800-115

The Technical Guide to Information Security Testing and Assessment from the National Institute of Standards and Technology.

### Four-Phase Methodology

```
┌─────────────────────────────────────────────────────────────┐
│                    NIST SP 800-115                          │
├─────────────┬─────────────┬─────────────┬─────────────────┤
│  PLANNING   │  DISCOVERY  │   ATTACK    │   REPORTING     │
│             │             │             │                 │
│ • Goals     │ • Footprint │ • Gaining   │ • Executive     │
│ • Scope     │ • Scanning  │   Access    │   Summary       │
│ • ROE       │ • Analysis  │ • Escalation│ • Technical     │
│ • Schedule  │ • Validation│ • Pivoting  │   Details       │
│ • Resources │             │ • Pillaging │ • Remediation   │
└─────────────┴─────────────┴─────────────┴─────────────────┘
```

### Phase 1: Planning

**Purpose:** Establish testing parameters and obtain authorization.

**Key Activities:**
- Define assessment objectives and scope
- Identify rules of engagement
- Establish communication plan
- Allocate resources and timeline
- Obtain written authorization
- Define success criteria

**Documentation Requirements:**
- Test plan document
- Authorization forms
- Scope definition
- Emergency contact list
- Legal agreements

---

### Phase 2: Discovery

**Purpose:** Gather information and identify vulnerabilities.

**Sub-phases:**

| Sub-phase | Activities | Tools |
|-----------|-----------|-------|
| **Footprinting** | OSINT, DNS, WHOIS | theHarvester, Recon-ng |
| **Scanning** | Port scanning, service detection | Nmap, Masscan |
| **Enumeration** | Deep service analysis | SMB, SNMP, LDAP tools |
| **Vulnerability Analysis** | Identify weaknesses | Nessus, OpenVAS |

**Information Collected:**
- Network topology
- System inventory
- Running services
- Potential vulnerabilities
- User information

---

### Phase 3: Attack

**Purpose:** Validate vulnerabilities through controlled exploitation.

**Attack Phases:**

```
Attack Execution
├── Gaining Access
│   ├── Exploit vulnerabilities
│   ├── Password attacks
│   └── Social engineering
├── Escalating Privileges
│   ├── Local privilege escalation
│   └── Domain privilege escalation
├── System Browsing
│   ├── File system exploration
│   ├── Registry/config analysis
│   └── Network discovery
├── Installing Additional Tools
│   ├── Upload utilities
│   └── Establish persistence
└── Covering Tracks
    ├── Log manipulation
    └── Artifact cleanup
```

**Key Considerations:**
- Minimize operational impact
- Document all actions
- Maintain evidence chain
- Follow approved scope

---

### Phase 4: Reporting

**Purpose:** Document findings and provide remediation guidance.

**Report Structure:**

| Section | Content | Audience |
|---------|---------|----------|
| Executive Summary | Business risk overview | C-level, management |
| Scope & Methodology | What was tested and how | All stakeholders |
| Findings Summary | Vulnerability statistics | Management, IT |
| Detailed Findings | Technical analysis | IT, security teams |
| Risk Assessment | CVSS scores, impact | Risk management |
| Remediation | Fix recommendations | Engineering |
| Appendices | Evidence, tool output | Technical reference |

---

## OSSTMM - Open Source Security Testing Methodology Manual

A peer-reviewed methodology from ISECOM focusing on measurable operational security.

### The Five Security Channels

```
┌────────────────────────────────────────────────────────────┐
│                   OSSTMM 3 Channels                        │
├─────────────┬────────────┬────────────┬──────────┬────────┤
│    HUMAN    │  PHYSICAL  │  WIRELESS  │  TELECOM │  DATA  │
│             │            │            │          │NETWORKS│
│ Social Eng. │ Buildings  │ WiFi/RF    │ VoIP     │ Wired  │
│ Training    │ Access     │ Bluetooth  │ PBX      │ Apps   │
│ Awareness   │ Barriers   │ RFID/NFC   │ Fax      │ Servers│
│ Phishing    │ Locks      │ Infrared   │ Modem    │ Cloud  │
└─────────────┴────────────┴────────────┴──────────┴────────┘
```

### Channel Details

#### 1. Human Security (HUMSEC)

Testing human interactions and security awareness.

| Test Area | Description |
|-----------|-------------|
| Phishing | Email-based social engineering |
| Vishing | Voice-based attacks |
| Pretexting | Scenario-based manipulation |
| Tailgating | Physical access through trust |
| Awareness | Security training effectiveness |

#### 2. Physical Security (PHYSSEC)

Testing physical access controls and barriers.

| Test Area | Description |
|-----------|-------------|
| Perimeter | Fences, gates, barriers |
| Building | Doors, locks, access controls |
| Surveillance | Cameras, guards, monitoring |
| Environment | HVAC, power, fire suppression |
| Asset Protection | Safes, cages, secure storage |

#### 3. Wireless Communications (SPECSEC)

Testing electromagnetic spectrum security.

| Test Area | Description |
|-----------|-------------|
| WiFi | 802.11 network security |
| Bluetooth | Pairing, discovery attacks |
| RFID/NFC | Card cloning, replay |
| Radio | RF interception, jamming |
| Infrared | IR communication security |

#### 4. Telecommunications (COMSEC)

Testing voice and data communication systems.

| Test Area | Description |
|-----------|-------------|
| PBX | Phone system security |
| VoIP | Voice over IP security |
| Voicemail | Message security |
| Fax | Fax machine security |
| Modems | War dialing, remote access |

#### 5. Data Networks (NETSEC)

Testing network infrastructure and applications.

| Test Area | Description |
|-----------|-------------|
| Firewalls | Rule analysis, bypass |
| Routers/Switches | Configuration security |
| Servers | Service hardening |
| Applications | Web, API, custom apps |
| Databases | Data access controls |

### OSSTMM Metrics: Risk Assessment Values (RAVs)

OSSTMM provides quantitative security measurement:

```
Security Metric = (Controls - Limitations) / Exposure

Where:
- Controls: Security measures in place
- Limitations: Weaknesses in controls
- Exposure: Attack surface visibility
```

### Security Test Audit Report (STAR)

Standardized reporting format including:
- Scope definition
- Testing methodology
- Findings with RAV calculations
- Attack surface quantification
- Remediation priorities

---

## MITRE ATT&CK Framework

A globally accessible knowledge base of adversary tactics and techniques based on real-world observations. Current version: 15.1 (2024).

### Enterprise Matrix: 14 Tactics

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        MITRE ATT&CK Enterprise Matrix                    │
├──────────────────────────────────────────────────────────────────────────┤
│ PRE-ATTACK                                                               │
│ ┌─────────────────┐  ┌────────────────────┐                              │
│ │ Reconnaissance  │  │ Resource           │                              │
│ │    (TA0043)     │──│ Development        │                              │
│ │                 │  │    (TA0042)        │                              │
│ └─────────────────┘  └────────────────────┘                              │
├──────────────────────────────────────────────────────────────────────────┤
│ ATTACK EXECUTION                                                         │
│ ┌──────────────┐  ┌───────────┐  ┌─────────────┐  ┌────────────────────┐ │
│ │Initial Access│──│ Execution │──│ Persistence │──│Privilege Escalation│ │
│ │  (TA0001)    │  │ (TA0002)  │  │  (TA0003)   │  │     (TA0004)       │ │
│ └──────────────┘  └───────────┘  └─────────────┘  └────────────────────┘ │
│        │                                                    │            │
│        v                                                    v            │
│ ┌──────────────┐  ┌───────────────┐  ┌──────────┐  ┌────────────────┐    │
│ │   Defense    │──│  Credential   │──│Discovery │──│    Lateral     │    │
│ │   Evasion    │  │    Access     │  │(TA0007)  │  │   Movement     │    │
│ │  (TA0005)    │  │   (TA0006)    │  │          │  │   (TA0008)     │    │
│ └──────────────┘  └───────────────┘  └──────────┘  └────────────────┘    │
├──────────────────────────────────────────────────────────────────────────┤
│ OBJECTIVE COMPLETION                                                     │
│ ┌───────────┐  ┌──────────────────┐  ┌─────────────┐  ┌────────┐        │
│ │Collection │──│Command & Control │──│ Exfiltration│──│ Impact │        │
│ │ (TA0009)  │  │    (TA0011)      │  │  (TA0010)   │  │(TA0040)│        │
│ └───────────┘  └──────────────────┘  └─────────────┘  └────────┘        │
└──────────────────────────────────────────────────────────────────────────┘
```

### Tactics Detail

| Tactic ID | Tactic | Description | Example Techniques |
|-----------|--------|-------------|-------------------|
| TA0043 | Reconnaissance | Gather target information | Active Scanning, Search Open Websites |
| TA0042 | Resource Development | Establish attack infrastructure | Acquire Infrastructure, Develop Capabilities |
| TA0001 | Initial Access | Gain entry to target | Phishing, Exploit Public-Facing App, Valid Accounts |
| TA0002 | Execution | Run malicious code | PowerShell, Command Line, Scheduled Task |
| TA0003 | Persistence | Maintain access | Registry Run Keys, Scheduled Task, Services |
| TA0004 | Privilege Escalation | Gain higher permissions | Token Manipulation, Exploitation for Privilege Escalation |
| TA0005 | Defense Evasion | Avoid detection | Obfuscation, Indicator Removal, Masquerading |
| TA0006 | Credential Access | Steal credentials | Credential Dumping, Brute Force, Keylogging |
| TA0007 | Discovery | Explore environment | Network Discovery, Account Discovery, File Discovery |
| TA0008 | Lateral Movement | Spread through network | Remote Services, Pass the Hash, RDP |
| TA0009 | Collection | Gather target data | Data from Local System, Screen Capture, Keylogging |
| TA0011 | Command and Control | Remote communication | Web Protocols, DNS, Proxy |
| TA0010 | Exfiltration | Steal data | Exfiltration Over C2, Alternative Protocol |
| TA0040 | Impact | Disrupt/destroy | Data Destruction, Ransomware, Defacement |

### Using ATT&CK for Penetration Testing

#### 1. Attack Planning

Map planned activities to ATT&CK techniques:

```
Test Scenario: Internal Network Assessment
├── Initial Access (TA0001)
│   └── T1566.001: Spearphishing Attachment
├── Execution (TA0002)
│   └── T1059.001: PowerShell
├── Privilege Escalation (TA0004)
│   └── T1068: Exploitation for Privilege Escalation
├── Credential Access (TA0006)
│   └── T1003: OS Credential Dumping
└── Lateral Movement (TA0008)
    └── T1021.002: SMB/Windows Admin Shares
```

#### 2. Adversary Emulation

Use ATT&CK to simulate specific threat actors:

| APT Group | Common Techniques |
|-----------|-------------------|
| APT29 | T1566, T1059, T1027, T1071 |
| Lazarus | T1566, T1059, T1105, T1486 |
| Volt Typhoon | T1190, T1059, T1003, T1021 |

#### 3. Detection Validation

Test security controls against specific techniques:

```bash
# Atomic Red Team - Test T1059.001 (PowerShell)
Invoke-AtomicTest T1059.001

# Test T1003.001 (LSASS Credential Dumping)
Invoke-AtomicTest T1003.001
```

#### 4. Gap Analysis

Identify untested or undetected techniques in your environment.

### Top 10 ATT&CK Techniques (2024-2025)

Based on threat intelligence data:

| Rank | Technique ID | Name | Prevalence |
|------|-------------|------|------------|
| 1 | T1059 | Command and Scripting Interpreter | Very High |
| 2 | T1486 | Data Encrypted for Impact | Very High |
| 3 | T1071 | Application Layer Protocol | High |
| 4 | T1027 | Obfuscated Files or Information | High |
| 5 | T1566 | Phishing | High |
| 6 | T1105 | Ingress Tool Transfer | High |
| 7 | T1003 | OS Credential Dumping | High |
| 8 | T1055 | Process Injection | Medium-High |
| 9 | T1021 | Remote Services | Medium-High |
| 10 | T1082 | System Information Discovery | Medium |

---

## Cyber Kill Chain

The Lockheed Martin Cyber Kill Chain, developed in 2011, models the stages of a cyberattack.

### The 7 Kill Chain Phases

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Lockheed Martin Cyber Kill Chain                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. RECONNAISSANCE ──────────────────────────────────────────────▶  │
│     Target selection, research, identifying vulnerabilities         │
│                                                                      │
│  2. WEAPONIZATION ───────────────────────────────────────────────▶  │
│     Creating/obtaining malware and exploit payloads                  │
│                                                                      │
│  3. DELIVERY ────────────────────────────────────────────────────▶  │
│     Transmitting weapon to target (email, web, USB)                  │
│                                                                      │
│  4. EXPLOITATION ────────────────────────────────────────────────▶  │
│     Triggering exploit code, gaining initial access                  │
│                                                                      │
│  5. INSTALLATION ────────────────────────────────────────────────▶  │
│     Installing malware/backdoor for persistent access                │
│                                                                      │
│  6. COMMAND & CONTROL (C2) ──────────────────────────────────────▶  │
│     Establishing remote control channel                              │
│                                                                      │
│  7. ACTIONS ON OBJECTIVES ───────────────────────────────────────▶  │
│     Achieving mission goals (data theft, destruction)                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Phase Details

| Phase | Attacker Activities | Defensive Actions |
|-------|--------------------|--------------------|
| **Reconnaissance** | OSINT, scanning, social media | Monitor for reconnaissance, minimize exposed info |
| **Weaponization** | Malware creation, exploit development | Threat intelligence, update signatures |
| **Delivery** | Phishing, watering hole, USB | Email filtering, web proxies, USB controls |
| **Exploitation** | Exploit execution, code running | Patching, IDS/IPS, endpoint protection |
| **Installation** | Backdoor, rootkit, persistence | HIDS, file integrity monitoring, EDR |
| **C2** | Encrypted channels, tunneling | Network monitoring, firewall rules, DNS inspection |
| **Actions on Objectives** | Data exfiltration, destruction | DLP, access controls, backup/recovery |

### Defensive Courses of Action

| Action | Description | Application |
|--------|-------------|-------------|
| **Detect** | Identify attacker presence | SIEM, EDR, network monitoring |
| **Deny** | Block attack vectors | Firewalls, access controls |
| **Disrupt** | Interrupt attack progression | Incident response, isolation |
| **Degrade** | Reduce attacker effectiveness | Rate limiting, deception |
| **Deceive** | Misdirect attackers | Honeypots, honeytokens |
| **Contain** | Limit attack scope | Segmentation, micro-segmentation |

### Limitations

- Linear model doesn't reflect iterative attacks
- Focused on perimeter-based attacks
- Limited coverage of insider threats
- Doesn't account for cloud-native attacks
- Post-exploitation activities not well covered

---

## ISSAF - Information Systems Security Assessment Framework

A comprehensive framework from the Open Information Systems Security Group (OISSG).

### Three Main Phases

```
┌───────────────────────────────────────────────────────────────────┐
│                            ISSAF Phases                            │
├───────────────────┬────────────────────┬─────────────────────────┤
│    PHASE 1        │      PHASE 2       │        PHASE 3          │
│    PLANNING       │     ASSESSMENT     │       REPORTING         │
│                   │                    │                         │
│ • Scope definition│ • Information      │ • Verbal reporting      │
│ • Authorization   │   gathering        │   (critical issues)     │
│ • Team selection  │ • Network mapping  │ • Written report        │
│ • Tool selection  │ • Vulnerability ID │ • Executive summary     │
│ • Timeline        │ • Penetration      │ • Technical details     │
│ • Legal review    │ • Privilege escal. │ • Remediation plan      │
│                   │ • Enumeration      │ • Cleanup verification  │
│                   │ • Compromise       │                         │
│                   │ • Data exfil       │                         │
└───────────────────┴────────────────────┴─────────────────────────┘
```

### Assessment Layers

ISSAF defines penetration testing as discrete layers:

| Layer | Activity | Description |
|-------|----------|-------------|
| 1 | Information Gathering | Technical and non-technical reconnaissance |
| 2 | Network Mapping | Identify all systems and resources |
| 3 | Vulnerability Identification | Detect vulnerabilities in targets |
| 4 | Penetration | Gain unauthorized access |
| 5 | Gaining Access & Privilege Escalation | Obtain admin-level privileges |
| 6 | Enumerating Further | Additional process and service discovery |
| 7 | Compromise Remote Users/Sites | Exploit trust relationships |

### Technical Control Assessments

ISSAF covers specialized assessment domains:

| Domain | Focus Areas |
|--------|------------|
| **Password Security** | Policy, storage, transmission |
| **Unix/Linux Security** | Hardening, privileges, services |
| **Windows Security** | AD, GPO, services, registry |
| **Database Security** | Access controls, encryption, injection |
| **Wireless Security** | WPA/WPA2/WPA3, rogue AP, client attacks |
| **Router Security** | ACLs, protocols, management |
| **Firewall Security** | Rules, bypass, management |
| **IDS/IPS Security** | Detection, evasion, tuning |
| **VPN Security** | Authentication, encryption, split tunneling |
| **Web Application** | OWASP categories, API security |
| **SAN/Storage** | Access controls, encryption |
| **VoIP Security** | SIP, RTP, eavesdropping |

### Strengths

- Links testing steps to specific tools
- Comprehensive 1,200+ page guidebook
- Customizable for specific organizations
- Covers both technical and non-technical aspects

### Limitations

- No longer actively maintained
- Some content outdated
- Very comprehensive (can be overwhelming)

---

## Unified Kill Chain

An 18-phase attack model combining the Cyber Kill Chain and MITRE ATT&CK.

### Three Cycles, 18 Phases

```
┌────────────────────────────────────────────────────────────────────┐
│                        Unified Kill Chain                          │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ╔══════════════════════════════════════════════════════════════╗ │
│  ║                    IN CYCLE (Phases 1-8)                      ║ │
│  ║  Initial compromise and foothold establishment                ║ │
│  ╠══════════════════════════════════════════════════════════════╣ │
│  ║ 1. Reconnaissance        5. Delivery                         ║ │
│  ║ 2. Resource Development  6. Exploitation                     ║ │
│  ║ 3. Weaponization         7. Installation                     ║ │
│  ║ 4. Social Engineering    8. Command & Control                ║ │
│  ╚══════════════════════════════════════════════════════════════╝ │
│                              │                                     │
│                              ▼                                     │
│  ╔══════════════════════════════════════════════════════════════╗ │
│  ║                 THROUGH CYCLE (Phases 9-14)                   ║ │
│  ║  Internal network propagation and persistence                 ║ │
│  ╠══════════════════════════════════════════════════════════════╣ │
│  ║ 9. Pivoting              12. Discovery                       ║ │
│  ║ 10. Credential Access    13. Privilege Escalation            ║ │
│  ║ 11. Persistence          14. Lateral Movement                ║ │
│  ╚══════════════════════════════════════════════════════════════╝ │
│                              │                                     │
│                              ▼                                     │
│  ╔══════════════════════════════════════════════════════════════╗ │
│  ║                   OUT CYCLE (Phases 15-18)                    ║ │
│  ║  Objective completion and impact                              ║ │
│  ╠══════════════════════════════════════════════════════════════╣ │
│  ║ 15. Collection           17. Exfiltration                    ║ │
│  ║ 16. Defense Evasion      18. Impact                          ║ │
│  ╚══════════════════════════════════════════════════════════════╝ │
│                                                                     │
│  Note: Phases may iterate and repeat throughout an attack          │
└────────────────────────────────────────────────────────────────────┘
```

### Phase Details

| Phase | Cycle | Description |
|-------|-------|-------------|
| 1. Reconnaissance | In | Information gathering about targets |
| 2. Resource Development | In | Infrastructure and capability setup |
| 3. Weaponization | In | Malware and exploit preparation |
| 4. Social Engineering | In | Human-based attack vectors |
| 5. Delivery | In | Weapon transmission to target |
| 6. Exploitation | In | Initial vulnerability exploitation |
| 7. Installation | In | Persistence establishment |
| 8. Command & Control | In | C2 channel establishment |
| 9. Pivoting | Through | Network movement setup |
| 10. Credential Access | Through | Credential theft |
| 11. Persistence | Through | Additional persistence mechanisms |
| 12. Discovery | Through | Environment mapping |
| 13. Privilege Escalation | Through | Permission elevation |
| 14. Lateral Movement | Through | Network spreading |
| 15. Collection | Out | Data gathering |
| 16. Defense Evasion | Out | Detection avoidance |
| 17. Exfiltration | Out | Data theft |
| 18. Impact | Out | Objective completion |

### Advantages Over Traditional Models

| Advantage | Description |
|-----------|-------------|
| **Non-linear** | Acknowledges iterative attack nature |
| **Comprehensive** | Covers pre-compromise through impact |
| **Modern threats** | Includes cloud, supply chain, insider threats |
| **ATT&CK aligned** | Maps to MITRE techniques |
| **Post-compromise focus** | Detailed internal propagation phases |

---

## Framework Comparison

### Scope and Focus

| Framework | Primary Focus | Scope | Best For |
|-----------|--------------|-------|----------|
| **PTES** | Penetration testing process | End-to-end pentest | Standard pentests |
| **OWASP** | Web application security | Web/API apps only | Web app testing |
| **NIST 800-115** | Compliance documentation | Federal/enterprise | Regulated industries |
| **OSSTMM** | Operational security metrics | Holistic security | Security audits |
| **MITRE ATT&CK** | Adversary behavior | Threat modeling | Red team, detection |
| **Cyber Kill Chain** | Attack lifecycle | Perimeter defense | Defensive planning |
| **ISSAF** | Comprehensive assessment | Full enterprise | Custom methodology |
| **Unified Kill Chain** | Modern attack modeling | Full attack lifecycle | Advanced threats |

### Practical Selection Guide

```
Need to conduct a standard penetration test?
└── Use PTES as primary framework

Testing web applications or APIs?
└── Combine PTES with OWASP WSTG

Working in a regulated industry (healthcare, finance, government)?
└── Use NIST SP 800-115 for compliance

Need to measure security quantitatively?
└── Apply OSSTMM metrics

Planning red team exercises or threat emulation?
└── Map activities to MITRE ATT&CK

Improving defensive capabilities?
└── Use Cyber Kill Chain for defense mapping

Developing custom methodology?
└── Reference ISSAF for comprehensive coverage

Modeling advanced persistent threats?
└── Apply Unified Kill Chain phases
```

### Combining Frameworks

Most effective approach is combining frameworks:

```
Practical Penetration Test Framework
├── Pre-Engagement (PTES)
│   └── Scope, ROE, authorization
├── Reconnaissance (PTES + ATT&CK TA0043)
│   └── OSINT, active scanning
├── Vulnerability Analysis (PTES + OWASP)
│   └── Network + web application testing
├── Exploitation (PTES + ATT&CK)
│   └── Map exploits to ATT&CK techniques
├── Post-Exploitation (PTES + ATT&CK TA0003-TA0008)
│   └── Persistence, privesc, lateral movement
├── Exfiltration (PTES + ATT&CK TA0010)
│   └── Data theft demonstration
└── Reporting (PTES + NIST 800-115)
    └── Executive summary, technical details, remediation
```

---

## Practical Application

### Mapping Methodologies to Pentest Phases

| Our Phase | PTES | OWASP | NIST | ATT&CK |
|-----------|------|-------|------|--------|
| **Reconnaissance** | Phase 2 | WSTG-INFO | Discovery | TA0043 |
| **Enumeration** | Phase 2-4 | WSTG-INFO, CONF | Discovery | TA0043, TA0007 |
| **Exploitation** | Phase 5 | WSTG-INPV | Attack | TA0001, TA0002 |
| **Post-Exploitation** | Phase 6 | - | Attack | TA0003-TA0009 |
| **Persistence** | Phase 6 | - | Attack | TA0003 |
| **Privilege Escalation** | Phase 6 | WSTG-ATHZ | Attack | TA0004 |
| **Lateral Movement** | Phase 6 | - | Attack | TA0008 |
| **Exfiltration** | Phase 6 | - | Attack | TA0010 |
| **Cleanup** | Phase 7 | - | Reporting | - |

### Checklist Template

```markdown
## Penetration Test Checklist (Framework-Aligned)

### Pre-Engagement (PTES Phase 1)
- [ ] Scope document signed
- [ ] Rules of engagement defined
- [ ] Authorization obtained
- [ ] Emergency contacts established
- [ ] Timeline agreed

### Reconnaissance (PTES Phase 2, ATT&CK TA0043)
- [ ] Passive OSINT completed
- [ ] Active scanning performed
- [ ] Target inventory created
- [ ] Attack surface mapped

### Threat Modeling (PTES Phase 3)
- [ ] Critical assets identified
- [ ] Threat agents analyzed
- [ ] Attack vectors prioritized

### Vulnerability Analysis (PTES Phase 4, OWASP WSTG)
- [ ] Automated scanning completed
- [ ] Manual testing performed
- [ ] Vulnerabilities validated
- [ ] False positives eliminated

### Exploitation (PTES Phase 5, ATT&CK TA0001-TA0002)
- [ ] Exploitation attempts documented
- [ ] Initial access achieved
- [ ] Techniques mapped to ATT&CK

### Post-Exploitation (PTES Phase 6, ATT&CK TA0003-TA0010)
- [ ] Privilege escalation attempted
- [ ] Persistence established
- [ ] Lateral movement performed
- [ ] Data identified for exfiltration
- [ ] High-value targets reached

### Reporting (PTES Phase 7, NIST 800-115)
- [ ] Executive summary written
- [ ] Technical findings documented
- [ ] Remediation recommendations provided
- [ ] Evidence compiled
- [ ] Cleanup completed and verified
```

---

## References

**PTES**
- [Penetration Testing Execution Standard](http://www.pentest-standard.org/)
- [PTES Documentation](https://pentest-standard.readthedocs.io/)

**OWASP**
- [OWASP Web Security Testing Guide v4.2](https://owasp.org/www-project-web-security-testing-guide/v42/)
- [OWASP Mobile Application Security](https://mas.owasp.org/)

**NIST**
- [NIST SP 800-115](https://csrc.nist.gov/pubs/sp/800/115/final)
- [NIST SP 800-115 PDF](https://nvlpubs.nist.gov/nistpubs/legacy/sp/nistspecialpublication800-115.pdf)

**OSSTMM**
- [OSSTMM 3 PDF](https://www.isecom.org/OSSTMM.3.pdf)
- [ISECOM Research](https://www.isecom.org/research.html)

**MITRE ATT&CK**
- [MITRE ATT&CK](https://attack.mitre.org/)
- [ATT&CK Enterprise Matrix](https://attack.mitre.org/matrices/enterprise/)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)

**Cyber Kill Chain**
- [Lockheed Martin Cyber Kill Chain](https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html)

**ISSAF**
- [ISSAF Framework PDF](https://untrustednetwork.net/files/issaf0.2.1.pdf)

**Unified Kill Chain**
- [Unified Kill Chain](https://unifiedkillchain.com/)
- [UKC White Paper](https://www.unifiedkillchain.com/assets/The-Unified-Kill-Chain.pdf)

---

*Last updated: 2025-12-27*
