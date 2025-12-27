---
title: "PWNBOX Knowledge Base"
category: "index"
tags: ["knowledge-base", "penetration-testing", "documentation"]
last_updated: "2025-12-27"
---

# PWNBOX Knowledge Base

> Comprehensive documentation for network penetration testing and Active Directory security tools.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Tools](#tools)
- [Methodology](#methodology)
- [Techniques](#techniques)
- [References](#references)
- [Contributing](#contributing)

## Overview

This knowledge base contains detailed documentation for 33 penetration testing tools commonly used in network security assessments, CTF competitions, and Active Directory engagements.

All documentation follows a consistent structure:
- **README.md** - Tool overview and table of contents
- **official_docs.md** - Official documentation from source
- **options.md** - Command-line options reference
- **examples.md** - Practical usage examples

## Directory Structure

```
knowledge/
├── README.md              # This file
├── tools/                 # Tool documentation (33 tools)
│   ├── README.md         # Tool index by category
│   └── [tool-name]/      # Individual tool folders
├── methodology/          # Pentesting methodology guides
├── techniques/           # Attack technique documentation
└── references/           # Quick reference sheets
```

## Tools

See [tools/README.md](tools/README.md) for the complete tool index organized by category.

### Quick Links by Category

| Category | Tools |
|----------|-------|
| **Reconnaissance** | [nmap](tools/nmap/) • [masscan](tools/masscan/) • [rustscan](tools/rustscan/) |
| **Enumeration** | [gobuster](tools/gobuster/) • [feroxbuster](tools/feroxbuster/) • [enum4linux](tools/enum4linux/) • [smbclient](tools/smbclient/) • [smbmap](tools/smbmap/) |
| **Active Directory** | [bloodhound](tools/bloodhound/) • [kerbrute](tools/kerbrute/) • [responder](tools/responder/) • [crackmapexec](tools/crackmapexec/) • [netexec](tools/netexec/) |
| **Exploitation** | [impacket](tools/impacket/) • [evil-winrm](tools/evil-winrm/) • [metasploit-framework](tools/metasploit-framework/) • [msfvenom](tools/msfvenom/) |
| **Password Cracking** | [hashcat](tools/hashcat/) • [john](tools/john/) • [hydra](tools/hydra/) |
| **Pivoting** | [chisel](tools/chisel/) • [ligolo-ng](tools/ligolo-ng/) • [proxychains](tools/proxychains/) • [ssh](tools/ssh/) • [socat](tools/socat/) |
| **Privilege Escalation** | [linpeas](tools/linpeas/) • [winpeas](tools/winpeas/) • [pspy](tools/pspy/) • [mimikatz](tools/mimikatz/) |
| **Networking** | [nc](tools/nc/) • [rlwrap](tools/rlwrap/) |

## Methodology

Documentation for pentesting methodologies and workflows.

*Currently in development*

## Techniques

Attack technique documentation organized by category.

*Currently in development*

## References

Quick reference sheets and cheat sheets.

*Currently in development*

## Contributing

When adding new documentation:

1. Follow the structure defined in [ROADMAP.md](../ROADMAP.md)
2. Include YAML frontmatter in all markdown files
3. Add table of contents to README files
4. Keep README files under 200 lines
5. Split large files (>500 lines) into subtopics

---

*Last updated: 2025-12-27*
