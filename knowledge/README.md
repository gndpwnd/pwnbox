---
title: "PWNBOX Knowledge Base"
category: "index"
tags: ["knowledge-base", "penetration-testing", "documentation"]
last_updated: "2025-12-27"
---

# PWNBOX Knowledge Base

> Comprehensive documentation for network penetration testing and Active Directory security.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Tools](#tools)
- [Methodology](#methodology)
- [Techniques](#techniques)
- [Reporting](#reporting)
- [Contributing](#contributing)

## Overview

This knowledge base contains:
- **39 penetration testing tools** with comprehensive documentation
- **Pentesting methodology** covering all phases from recon to reporting
- **Web application testing** - OWASP methodology, injection attacks, file inclusion
- **Attack techniques** organized by platform (Windows, Linux, AD, Network, Evasion)
- **Reference materials** - Cheatsheets, certification curricula, frameworks
- **Reporting templates** and best practices for professional deliverables

## Directory Structure

```
knowledge/
├── README.md                    # This file
├── tools/                       # Tool documentation (39 tools)
│   ├── README.md               # Tool index by category
│   └── [tool-name]/            # Individual tool folders
├── methodology/                 # Pentesting process (10+ phases)
│   ├── README.md               # Methodology overview
│   ├── reconnaissance/         # OSINT, passive/active recon
│   ├── enumeration/            # Port scanning, service detection
│   ├── exploitation/           # Initial access techniques
│   ├── post-exploitation/      # System profiling, creds
│   ├── persistence/            # Maintaining access
│   ├── privilege-escalation/   # Windows & Linux privesc
│   ├── lateral-movement/       # Network spreading
│   ├── exfiltration/           # Data extraction
│   ├── cleanup/                # Covering tracks
│   └── web-application/        # Web app testing (OWASP)
├── techniques/                  # Attack techniques by platform
│   ├── README.md               # Techniques index
│   ├── windows/                # Windows attacks
│   ├── linux/                  # Linux attacks
│   ├── active-directory/       # AD attack chains
│   ├── network/                # Network-level attacks
│   └── evasion/                # AV/EDR bypass techniques
├── references/                  # Cheatsheets & quick references
│   ├── cheatsheets/            # Reverse shells, file transfers
│   └── README.md               # Reference index
├── certifications/              # Certification curricula
│   └── CEH-curriculum.md       # CEH v12 topics
└── reporting/                   # Report templates & guides
    ├── README.md               # Reporting overview
    ├── templates/              # Report templates
    ├── findings/               # Finding write-ups
    └── best-practices.md       # Writing guidelines
```

## Tools

See [tools/README.md](tools/README.md) for the complete tool index.

| Category | Tools |
|----------|-------|
| **Reconnaissance** | [nmap](tools/nmap/) • [masscan](tools/masscan/) • [rustscan](tools/rustscan/) • [nikto](tools/nikto/) |
| **Web Fuzzing** | [ffuf](tools/ffuf/) • [gobuster](tools/gobuster/) • [feroxbuster](tools/feroxbuster/) • [wpscan](tools/wpscan/) |
| **Web Exploitation** | [burpsuite](tools/burpsuite/) • [sqlmap](tools/sqlmap/) |
| **Enumeration** | [enum4linux](tools/enum4linux/) • [smbclient](tools/smbclient/) • [smbmap](tools/smbmap/) |
| **Active Directory** | [bloodhound](tools/bloodhound/) • [kerbrute](tools/kerbrute/) • [responder](tools/responder/) • [crackmapexec](tools/crackmapexec/) • [netexec](tools/netexec/) • [rubeus](tools/rubeus/) • [certipy](tools/certipy/) |
| **Exploitation** | [impacket](tools/impacket/) • [evil-winrm](tools/evil-winrm/) • [metasploit-framework](tools/metasploit-framework/) • [msfvenom](tools/msfvenom/) • [searchsploit](tools/searchsploit/) |
| **Password Cracking** | [hashcat](tools/hashcat/) • [john](tools/john/) • [hydra](tools/hydra/) |
| **Pivoting** | [chisel](tools/chisel/) • [ligolo-ng](tools/ligolo-ng/) • [proxychains](tools/proxychains/) • [ssh](tools/ssh/) • [socat](tools/socat/) |
| **Privilege Escalation** | [linpeas](tools/linpeas/) • [winpeas](tools/winpeas/) • [pspy](tools/pspy/) • [mimikatz](tools/mimikatz/) |
| **Networking** | [nc](tools/nc/) • [rlwrap](tools/rlwrap/) |

## Methodology

See [methodology/README.md](methodology/README.md) for the complete pentesting process.

| Phase | Description |
|-------|-------------|
| [Reconnaissance](methodology/reconnaissance/) | Information gathering and OSINT |
| [Enumeration](methodology/enumeration/) | Port scanning and service detection |
| [Web Application](methodology/web-application/) | OWASP testing, injection attacks |
| [Exploitation](methodology/exploitation/) | Initial access and vulnerability exploitation |
| [Post-Exploitation](methodology/post-exploitation/) | System profiling and credential harvesting |
| [Persistence](methodology/persistence/) | Maintaining access to systems |
| [Privilege Escalation](methodology/privilege-escalation/) | Elevating privileges on Windows/Linux |
| [Lateral Movement](methodology/lateral-movement/) | Spreading through the network |
| [Exfiltration](methodology/exfiltration/) | Data staging and extraction |
| [Cleanup](methodology/cleanup/) | Removing artifacts and covering tracks |

## Techniques

See [techniques/README.md](techniques/README.md) for attack techniques by platform.

| Platform | Focus Areas |
|----------|-------------|
| [Windows](techniques/windows/) | UAC bypass, token manipulation, DLL hijacking |
| [Linux](techniques/linux/) | SUID/SGID, sudo, capabilities, kernel exploits |
| [Active Directory](techniques/active-directory/) | Kerberos, NTLM, delegation, ACL abuse, ADCS |
| [Network](techniques/network/) | MITM, relay attacks, poisoning, sniffing |
| [Evasion](techniques/evasion/) | AMSI bypass, AppLocker bypass, Defender evasion |

## References

See [references/README.md](references/README.md) for quick reference materials.

| Type | Content |
|------|---------|
| [Cheatsheets](references/cheatsheets/) | Reverse shells, file transfers, hash types |
| [Frameworks](methodology/frameworks.md) | PTES, OWASP, MITRE ATT&CK, NIST |
| [Certifications](certifications/) | OSCP, CEH curriculum references |

## Reporting

See [reporting/README.md](reporting/README.md) for report templates and guidelines.

- [Best Practices](reporting/best-practices.md) - Writing quality guidelines
- [Templates](reporting/templates/) - Report and finding templates
- [Findings](reporting/findings/) - Finding documentation standards

## Contributing

When adding new documentation:

1. Follow the structure defined in [ROADMAP.md](../ROADMAP.md)
2. Include YAML frontmatter in all markdown files
3. Add table of contents to README files
4. Keep README files under 200 lines
5. Split large files (>500 lines) into subtopics

---

*Last updated: 2025-12-27*
