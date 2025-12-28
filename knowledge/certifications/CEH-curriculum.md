# CEH (Certified Ethical Hacker) Certification Curriculum

## Overview

The Certified Ethical Hacker (CEH) certification by EC-Council is the world's leading ethical hacking certification program. CEH v13, the latest version released in September 2024, integrates artificial intelligence throughout the curriculum and aligns with the MITRE ATT&CK Framework.

### Certification Details

| Attribute | Details |
|-----------|---------|
| **Exam Code** | 312-50 |
| **Exam Provider** | EC-Council (ECC) or Pearson VUE |
| **Number of Questions** | 125 multiple-choice questions |
| **Duration** | 4 hours |
| **Passing Score** | 60-85% (varies by exam form) |
| **Validity** | 3 years (renewable with continuing education) |
| **CEH Practical** | 20 challenges, 6 hours |
| **CEH Master** | Achieved by passing both Knowledge + Practical exams |

### Program Statistics
- **20 Modules** covering ethical hacking methodology
- **221+ Hands-on Labs** in iLabs environment
- **550+ Attack Techniques**
- **4,000+ Hacking and Security Tools**
- **2,500+ Pages** of student manual

---

## The 20 CEH Modules

### Module 1: Introduction to Ethical Hacking
**Key Topics:**
- Elements of Information Security (CIA Triad)
- Cyber Kill Chain Methodology
- MITRE ATT&CK Framework
- Unified Kill Chain
- Hacker Classes (Black Hat, White Hat, Gray Hat)
- Information Assurance (IA)
- Risk Management
- Incident Management
- Compliance Standards: PCI DSS, HIPAA, SOX, GDPR
- Ethical Hacking Concepts and Scope

### Module 2: Footprinting and Reconnaissance
**Key Topics:**
- Passive vs Active Reconnaissance
- OSINT (Open Source Intelligence)
- Website Footprinting
- Email Footprinting
- DNS Footprinting
- WHOIS Lookup
- Social Engineering Reconnaissance
- Google Dorking/Google Hacking

**Tools:**
- Maltego
- Shodan
- theHarvester
- Recon-ng
- FOCA
- Netcraft
- DNSDumpster
- Sherlock
- SpiderFoot

### Module 3: Scanning Networks
**Key Topics:**
- Network Scanning Concepts
- Port Scanning (TCP, UDP, SYN, ACK, FIN, XMAS, NULL)
- Service Version Detection
- OS Fingerprinting
- Banner Grabbing
- Firewall/IDS Evasion Techniques
- Vulnerability Scanning
- Network Mapping

**Tools:**
- Nmap / Zenmap
- Masscan
- Angry IP Scanner
- Netcat
- Hping3
- Nessus
- OpenVAS
- Nikto

### Module 4: Enumeration
**Key Topics:**
- NetBIOS Enumeration (Port 137, 139)
- SNMP Enumeration (Port 161, 162)
- LDAP Enumeration (Port 389)
- NFS Enumeration (Port 2049)
- SMTP Enumeration (Port 25)
- DNS Enumeration (Port 53)
- SMB Enumeration (Port 445)
- RPC Enumeration
- Active Directory Enumeration

**Tools:**
- Nbtstat
- NetBIOS Enumerator
- snmp-check
- enum4linux
- ldapsearch
- rpcclient
- smbclient
- dig / nslookup
- SuperEnum

### Module 5: Vulnerability Analysis
**Key Topics:**
- Vulnerability Assessment Concepts
- Vulnerability Classification
- CVSS (Common Vulnerability Scoring System)
- CVE (Common Vulnerabilities and Exposures)
- Vulnerability Research
- Vulnerability Assessment Reports
- Prioritizing Vulnerabilities

**Tools:**
- Nessus
- OpenVAS
- Nikto
- Qualys
- Nexpose
- GFI LanGuard

### Module 6: System Hacking
**Key Topics:**
- Password Cracking Techniques
  - Brute Force Attacks
  - Dictionary Attacks
  - Rainbow Table Attacks
  - Rule-Based Attacks
  - Hybrid Attacks
- Privilege Escalation (Horizontal & Vertical)
- Maintaining Access
- Backdoors and Trojans
- Covering Tracks
- Clearing Event Logs
- Rootkits

**Tools:**
- John the Ripper
- Hashcat
- Ophcrack
- L0phtCrack
- Cain & Abel
- RainbowCrack
- Mimikatz
- PowerSploit
- PoshC2

### Module 7: Malware Threats
**Key Topics:**
- Malware Types:
  - Viruses (File, Boot, Macro, Polymorphic, Metamorphic)
  - Worms
  - Trojans (RATs, Banking, Backdoor)
  - Ransomware (Crypto, Locker)
  - Rootkits (Kernel, User, Hypervisor)
  - Spyware/Adware
  - Botnets
  - Keyloggers
  - Fileless Malware
- Malware Distribution Techniques
- APT (Advanced Persistent Threats)
- Malware Analysis:
  - Static Analysis
  - Dynamic Analysis
  - Behavioral Analysis

**Tools:**
- IDA Pro
- OllyDbg
- Process Monitor
- Wireshark
- VirusTotal
- Cuckoo Sandbox
- PEStudio

### Module 8: Sniffing
**Key Topics:**
- Packet Sniffing Concepts
- Passive vs Active Sniffing
- MAC Flooding
- ARP Poisoning/Spoofing
- DHCP Attacks
- DNS Poisoning
- Switch Port Stealing
- CAM Table Overflow
- MITM (Man-in-the-Middle) Attacks
- VLAN Hopping

**Tools:**
- Wireshark
- Tcpdump
- Ettercap
- BetterCAP
- Cain & Abel
- Dsniff
- macof
- arpspoof

### Module 9: Social Engineering
**Key Topics:**
- Social Engineering Concepts
- Human-Based Social Engineering
- Computer-Based Social Engineering
- Mobile-Based Social Engineering
- Phishing Attacks
  - Spear Phishing
  - Whaling
  - Vishing (Voice Phishing)
  - Smishing (SMS Phishing)
- Pretexting
- Baiting
- Quid Pro Quo
- Tailgating/Piggybacking
- Dumpster Diving
- Shoulder Surfing
- Impersonation
- Insider Threats

**Tools:**
- SET (Social Engineering Toolkit)
- Gophish
- King Phisher
- Evilginx2
- BeEF

### Module 10: Denial-of-Service (DoS)
**Key Topics:**
- DoS/DDoS Attack Concepts
- Volumetric Attacks
- Protocol Attacks
- Application Layer Attacks
- SYN Flood
- UDP Flood
- ICMP Flood
- Ping of Death
- Smurf Attack
- Slowloris
- HTTP Flood
- Amplification Attacks (DNS, NTP)
- Botnets
- DoS Countermeasures

**Tools:**
- LOIC (Low Orbit Ion Cannon)
- HOIC (High Orbit Ion Cannon)
- hping3
- Slowloris
- GoldenEye
- R.U.D.Y.

### Module 11: Session Hijacking
**Key Topics:**
- Session Hijacking Concepts
- Application-Level Session Hijacking
- Network-Level Session Hijacking
- Session Token Prediction
- Session Sidejacking
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- TCP/IP Hijacking
- RST Hijacking
- Blind Hijacking
- Session Fixation

**Tools:**
- Burp Suite
- OWASP ZAP
- Firesheep
- Hamster & Ferret
- Hunt

### Module 12: Evading IDS, Firewalls, and Honeypots
**Key Topics:**
- IDS/IPS Concepts and Types
- Firewall Types and Architectures
- Honeypot Types
- IDS Evasion Techniques:
  - Fragmentation
  - Overlapping Fragments
  - TTL Manipulation
  - Session Splicing
  - Unicode Evasion
  - Polymorphic Shellcode
- Firewall Evasion Techniques:
  - IP Address Spoofing
  - Source Routing
  - Tiny Fragments
  - Proxy Servers
  - Tunneling
- NAC and Endpoint Security Evasion

**Tools:**
- Nmap (with evasion options)
- Fragroute
- Scapy
- Nessus
- snort

### Module 13: Hacking Web Servers
**Key Topics:**
- Web Server Concepts
- Web Server Attacks:
  - Directory Traversal
  - HTTP Response Splitting
  - Web Cache Poisoning
  - Server-Side Request Forgery (SSRF)
  - SSH Brute Force
  - DNS Hijacking
- Web Server Attack Methodology
- Web Server Vulnerability Scanning

**Tools:**
- Nikto
- wpscan
- w3af
- Burp Suite
- httprecon
- ID Serve

### Module 14: Hacking Web Applications
**Key Topics:**
- Web Application Architecture
- OWASP Top 10 Vulnerabilities
- Web Application Threats:
  - Injection Attacks
  - Broken Authentication
  - Sensitive Data Exposure
  - XML External Entities (XXE)
  - Broken Access Control
  - Security Misconfiguration
  - Cross-Site Scripting (XSS)
  - Insecure Deserialization
  - Using Components with Known Vulnerabilities
  - Insufficient Logging & Monitoring
- Web Application Hacking Methodology
- Parameter Tampering
- Cookie Poisoning
- Hidden Field Manipulation

**Tools:**
- Burp Suite
- OWASP ZAP
- Nikto
- w3af
- Wapiti
- Acunetix

### Module 15: SQL Injection
**Key Topics:**
- SQL Injection Concepts
- Types of SQL Injection:
  - In-Band SQLi (Error-Based, Union-Based)
  - Blind SQLi (Boolean-Based, Time-Based)
  - Out-of-Band SQLi
- SQL Injection Methodology
- SQL Injection Attack Techniques
- Evasion Techniques
- SQL Injection Countermeasures

**Tools:**
- SQLmap
- JSQL Injection
- Havij
- BBQSQL
- NoSQLMap
- Burp Suite

### Module 16: Hacking Wireless Networks
**Key Topics:**
- Wireless Concepts (802.11 Standards)
- Wireless Encryption:
  - WEP (Wired Equivalent Privacy)
  - WPA (Wi-Fi Protected Access)
  - WPA2 (WPA2-PSK, WPA2-Enterprise)
  - WPA3
- Wireless Threats and Attacks:
  - Rogue Access Points
  - Evil Twin Attack
  - Deauthentication Attack
  - WPA/WPA2 Cracking
  - KRACK Attack
  - Wardriving/Warchalking
  - Bluetooth Attacks (Bluejacking, Bluesnarfing)
- 4-Way Handshake Capture

**Tools:**
- Aircrack-ng Suite:
  - airmon-ng
  - airodump-ng
  - aireplay-ng
  - aircrack-ng
- Kismet
- inSSIDer
- WiFite
- Fern WiFi Cracker
- Wifiphisher
- Reaver (WPS attacks)

### Module 17: Hacking Mobile Platforms
**Key Topics:**
- Mobile Platform Attack Vectors
- OWASP Mobile Top 10
- Android Vulnerabilities and Attacks:
  - Rooting
  - APK Reverse Engineering
  - Malware
- iOS Vulnerabilities and Attacks:
  - Jailbreaking
  - App Store Bypass
- Mobile Device Management (MDM)
- BYOD Security
- Mobile App Vulnerabilities:
  - Insecure Data Storage
  - Weak Server-Side Controls
  - Insufficient Transport Layer Protection
  - Client-Side Injection

**Tools:**
- Frida
- Objection
- APKTool
- dex2jar
- JD-GUI
- MobSF (Mobile Security Framework)
- Drozer

### Module 18: IoT and OT Hacking
**Key Topics:**
- IoT Architecture
- IoT Communication Protocols (MQTT, CoAP, ZigBee, Z-Wave)
- OWASP IoT Top 10
- IoT Vulnerabilities and Threats
- IoT Attack Methodology
- IT/OT Convergence
- OT/ICS/SCADA Concepts
- OT Technologies and Protocols:
  - Modbus
  - DNP3
  - OPC
  - BACnet
- OT Vulnerabilities and Attacks
- Industrial Control System (ICS) Security

**Tools:**
- Shodan
- Censys
- Firmware Analysis Toolkit
- Binwalk
- Firmware Mod Kit
- IoTSeeker
- SCADA Shutdown Tool (educational)

### Module 19: Cloud Computing
**Key Topics:**
- Cloud Computing Concepts
- Cloud Service Models (IaaS, PaaS, SaaS)
- Cloud Deployment Models
- Container Technologies:
  - Docker Security
  - Kubernetes Security
- Serverless Computing
- Cloud Security Risks (OWASP Top 10 Cloud)
- Cloud Hacking Methodology:
  - AWS Hacking
  - Microsoft Azure Hacking
  - Google Cloud Platform (GCP) Hacking
- Container Hacking
- Cloud Security Controls

**Tools:**
- Pacu (AWS exploitation)
- ScoutSuite
- CloudGoat
- TruffleHog
- S3Scanner
- kube-hunter
- Prowler

### Module 20: Cryptography
**Key Topics:**
- Cryptography Concepts
- Symmetric Encryption:
  - AES
  - DES/3DES
  - Blowfish
  - RC4
- Asymmetric Encryption:
  - RSA
  - Diffie-Hellman
  - ECC (Elliptic Curve Cryptography)
  - El Gamal
- Hash Functions:
  - MD5
  - SHA-1, SHA-256, SHA-3
  - bcrypt, Argon2
- Message Digest Functions
- Digital Signatures
- Public Key Infrastructure (PKI)
- Certificate Authorities
- Email Encryption (PGP, S/MIME)
- Disk Encryption
- Blockchain Concepts
- Quantum Cryptography
- Cryptography Attacks:
  - Birthday Attack
  - Brute Force
  - Rainbow Table
  - Known Plaintext Attack
  - Chosen Plaintext Attack
  - Side-Channel Attacks

**Tools:**
- OpenSSL
- GPG
- HashCalc
- CrypTool
- BCTextEncoder

---

## CEH Exam Domains (9 Knowledge Areas)

The 125-question exam covers these 9 domains:

| Domain | Weight | Topics |
|--------|--------|--------|
| **1. Information Security and Ethical Hacking Overview** | 6% | Fundamentals, laws, standards, controls |
| **2. Reconnaissance Techniques** | 21% | Footprinting, scanning, enumeration |
| **3. System Hacking Phases and Attack Techniques** | 17% | Password cracking, privilege escalation, malware |
| **4. Network and Perimeter Hacking** | 14% | Sniffing, DoS, session hijacking, evasion |
| **5. Web Application Hacking** | 16% | Web servers, apps, SQL injection |
| **6. Wireless Network Hacking** | 6% | WiFi, Bluetooth, wireless protocols |
| **7. Mobile, IoT, and OT Hacking** | 8% | Mobile platforms, IoT, SCADA/ICS |
| **8. Cloud Computing** | 6% | Cloud security, containers, serverless |
| **9. Cryptography** | 6% | Encryption, hashing, PKI, attacks |

---

## Attack Frameworks Covered

### Cyber Kill Chain (Lockheed Martin)
1. **Reconnaissance** - Target identification and research
2. **Weaponization** - Creating malicious payload
3. **Delivery** - Transmitting the weapon to target
4. **Exploitation** - Triggering the payload
5. **Installation** - Installing backdoor/malware
6. **Command & Control (C2)** - Remote control establishment
7. **Actions on Objectives** - Achieving goals (exfiltration, destruction)

### MITRE ATT&CK Framework
14 Tactics covering:
- Reconnaissance
- Resource Development
- Initial Access
- Execution
- Persistence
- Privilege Escalation
- Defense Evasion
- Credential Access
- Discovery
- Lateral Movement
- Collection
- Command and Control
- Exfiltration
- Impact

### 5 Phases of Ethical Hacking (EC-Council)
1. **Reconnaissance** - Information gathering
2. **Scanning** - Discovering live hosts and vulnerabilities
3. **Gaining Access** - Exploiting vulnerabilities
4. **Maintaining Access** - Persistence mechanisms
5. **Covering Tracks** - Hiding evidence

---

## Tools by Category

### Reconnaissance/Footprinting
| Tool | Purpose |
|------|---------|
| Maltego | Link analysis and data mining |
| Shodan | IoT and internet device search |
| theHarvester | Email, subdomain, host gathering |
| Recon-ng | Web reconnaissance framework |
| FOCA | Metadata extraction |
| Google Dorking | Advanced search operators |
| Netcraft | Domain/hosting information |
| DNSDumpster | DNS reconnaissance |

### Scanning
| Tool | Purpose |
|------|---------|
| Nmap/Zenmap | Port scanning, OS detection |
| Masscan | Fast port scanner |
| Nessus | Vulnerability scanner |
| OpenVAS | Open-source vulnerability scanner |
| Nikto | Web server scanner |
| Angry IP Scanner | Fast IP scanner |
| hping3 | Packet crafting |

### Enumeration
| Tool | Purpose |
|------|---------|
| enum4linux | SMB/NetBIOS enumeration |
| snmp-check | SNMP enumeration |
| ldapsearch | LDAP queries |
| rpcclient | RPC enumeration |
| smbclient | SMB client |
| NetBIOS Enumerator | Windows enumeration |

### Exploitation
| Tool | Purpose |
|------|---------|
| Metasploit Framework | Exploitation platform |
| Burp Suite | Web app testing |
| SQLmap | SQL injection automation |
| Hydra | Password brute forcing |
| BeEF | Browser exploitation |
| Cobalt Strike | Red team operations |

### Password Cracking
| Tool | Purpose |
|------|---------|
| John the Ripper | Password cracker |
| Hashcat | GPU-accelerated cracking |
| Ophcrack | Windows password cracker |
| L0phtCrack | Windows password auditing |
| RainbowCrack | Rainbow table attacks |
| Cain & Abel | Password recovery |

### Wireless
| Tool | Purpose |
|------|---------|
| Aircrack-ng | WiFi cracking suite |
| Kismet | Wireless detector/sniffer |
| WiFite | Automated wireless attacks |
| Reaver | WPS attacks |
| Wifiphisher | Rogue AP attacks |

### Sniffing/MITM
| Tool | Purpose |
|------|---------|
| Wireshark | Packet analysis |
| Tcpdump | Command-line sniffer |
| Ettercap | MITM attacks |
| BetterCAP | Network attacks |
| Responder | LLMNR/NBT-NS poisoning |

### Post-Exploitation
| Tool | Purpose |
|------|---------|
| Mimikatz | Credential extraction |
| PowerSploit | PowerShell post-exploitation |
| Empire | Post-exploitation framework |
| BloodHound | Active Directory analysis |
| Impacket | Network protocol tools |

### Mobile Security
| Tool | Purpose |
|------|---------|
| Frida | Dynamic instrumentation |
| Objection | Runtime exploration |
| APKTool | APK reverse engineering |
| MobSF | Mobile security framework |
| Drozer | Android security assessment |

### Cloud Security
| Tool | Purpose |
|------|---------|
| Pacu | AWS exploitation |
| ScoutSuite | Multi-cloud auditing |
| TruffleHog | Secret scanning |
| kube-hunter | Kubernetes testing |
| Prowler | AWS security assessment |

---

## Countermeasures and Defenses

### Network Security
- Implement firewalls and IDS/IPS
- Network segmentation
- VLANs with proper ACLs
- Static ARP entries for critical devices
- Encrypted protocols (HTTPS, SSH, VPN)
- Regular security monitoring and logging

### System Security
- Strong password policies
- Multi-factor authentication (MFA)
- Regular patching and updates
- Endpoint Detection and Response (EDR)
- Host-based firewalls
- Application whitelisting
- Least privilege access

### Web Application Security
- Input validation and sanitization
- Parameterized queries (prevent SQLi)
- Content Security Policy (CSP)
- HTTP security headers
- Web Application Firewalls (WAF)
- Regular security assessments

### Wireless Security
- Use WPA3 encryption
- Disable WPS
- Strong, random passphrases (16+ characters)
- Hidden SSIDs (limited effectiveness)
- MAC filtering (limited effectiveness)
- Regular wireless security audits

### Cloud Security
- Identity and Access Management (IAM)
- Encryption at rest and in transit
- Security groups and NACLs
- Container security scanning
- Regular cloud security assessments
- Compliance monitoring

### Social Engineering Defenses
- Security awareness training
- Phishing simulations
- Clear security policies
- Visitor management
- Physical security controls
- Incident reporting procedures

---

## CEH Practical Exam

### Format
- **Duration:** 6 hours
- **Challenges:** 20 real-world scenarios
- **Environment:** EC-Council iLabs (cloud-based)
- **Proctoring:** Remote proctored
- **Passing Score:** 70%
- **Prerequisites:** Pass CEH Knowledge exam first

### Skills Tested
- Network scanning and enumeration
- Vulnerability analysis
- System exploitation
- Web application attacks
- SQL injection
- Wireless network attacks
- Cryptography attacks
- Malware analysis
- Evidence collection

### Lab Environment
- Windows and Linux machines
- Kali Linux attack platform
- Vulnerable target machines
- Real-world network scenarios
- 250+ practice labs available

### Essential Tools for Practical
1. Nmap/Zenmap
2. Wireshark
3. Burp Suite
4. Metasploit
5. SQLmap
6. John the Ripper
7. Hashcat
8. Hydra

---

## Pentest Knowledge Base Topics

Based on the CEH curriculum, a comprehensive pentest knowledge base should cover:

### Reconnaissance
- [ ] OSINT techniques and tools
- [ ] DNS reconnaissance
- [ ] WHOIS lookups
- [ ] Social media intelligence
- [ ] Google dorking
- [ ] Email harvesting
- [ ] Metadata extraction

### Scanning & Enumeration
- [ ] Port scanning techniques
- [ ] Service enumeration
- [ ] OS fingerprinting
- [ ] NetBIOS/SMB enumeration
- [ ] SNMP enumeration
- [ ] LDAP enumeration
- [ ] NFS enumeration
- [ ] Active Directory enumeration

### Vulnerability Assessment
- [ ] Vulnerability scanning
- [ ] CVSS scoring
- [ ] CVE research
- [ ] Risk prioritization

### Exploitation
- [ ] Password attacks
- [ ] Privilege escalation (Windows)
- [ ] Privilege escalation (Linux)
- [ ] Web application attacks
- [ ] SQL injection
- [ ] Cross-site scripting (XSS)
- [ ] Buffer overflows
- [ ] Metasploit usage

### Post-Exploitation
- [ ] Credential harvesting
- [ ] Lateral movement
- [ ] Persistence mechanisms
- [ ] Data exfiltration
- [ ] Covering tracks

### Network Attacks
- [ ] ARP poisoning
- [ ] MITM attacks
- [ ] DNS spoofing
- [ ] Session hijacking
- [ ] DoS/DDoS attacks
- [ ] VLAN hopping

### Wireless Security
- [ ] WiFi reconnaissance
- [ ] WPA/WPA2 cracking
- [ ] Rogue access points
- [ ] Evil twin attacks
- [ ] Bluetooth attacks

### Web Application Security
- [ ] OWASP Top 10
- [ ] Injection attacks
- [ ] Authentication bypasses
- [ ] Session management
- [ ] API security

### Mobile Security
- [ ] Android security testing
- [ ] iOS security testing
- [ ] Mobile app analysis
- [ ] OWASP Mobile Top 10

### Cloud Security
- [ ] AWS security
- [ ] Azure security
- [ ] GCP security
- [ ] Container security
- [ ] Kubernetes security

### IoT/OT Security
- [ ] IoT vulnerabilities
- [ ] SCADA/ICS attacks
- [ ] Firmware analysis
- [ ] Protocol analysis

### Social Engineering
- [ ] Phishing campaigns
- [ ] Pretexting
- [ ] Physical security testing
- [ ] Security awareness

### Cryptography
- [ ] Encryption algorithms
- [ ] Hash functions
- [ ] PKI concepts
- [ ] Cryptographic attacks

### Evasion Techniques
- [ ] IDS/IPS evasion
- [ ] Firewall bypass
- [ ] Antivirus evasion
- [ ] EDR bypass

### Reporting
- [ ] Vulnerability documentation
- [ ] Risk assessment
- [ ] Remediation recommendations
- [ ] Executive summaries

---

## References and Sources

- [EC-Council CEH Official Page](https://www.eccouncil.org/train-certify/certified-ethical-hacker-ceh/)
- [EC-Council CEH v13 Announcement](https://www.eccouncil.org/cybersecurity-exchange/ethical-hacking/a-new-era-in-cybersecurity-announcing-ceh-v13/)
- [CEH v13 Brochure (PDF)](https://www.eccouncil.org/cehv13-brochure/)
- [EC-Council iLabs](https://ilabs.eccouncil.org/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Infosec Institute CEH Resources](https://www.infosecinstitute.com/resources/ceh/)
- [CISA Cybersecurity Resources](https://www.cisa.gov/)

---

*Last Updated: December 2025*
*CEH Version: v13 (312-50v13)*
