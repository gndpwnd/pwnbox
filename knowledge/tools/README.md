---
title: "PWNBOX Tools Index"
category: "index"
tags: ["tools", "penetration-testing", "index"]
last_updated: "2025-12-27"
---

# Tools Index

> Complete index of penetration testing tools documented in the PWNBOX knowledge base.

## Table of Contents

- [Reconnaissance](#reconnaissance)
- [Enumeration](#enumeration)
- [Active Directory](#active-directory)
- [Exploitation](#exploitation)
- [Password Cracking](#password-cracking)
- [Pivoting & Tunneling](#pivoting--tunneling)
- [Privilege Escalation](#privilege-escalation)
- [Networking Utilities](#networking-utilities)

---

## Reconnaissance

Network discovery and port scanning tools.

| Tool | Description | Docs |
|------|-------------|------|
| [nmap](nmap/) | The Network Mapper - comprehensive port scanner and service detection | [README](nmap/README.md) • [Docs](nmap/official_docs.md) • [Scripts](nmap/scripts.md) |
| [masscan](masscan/) | Fast TCP port scanner, transmits 10 million packets per second | [README](masscan/README.md) • [Docs](masscan/official_docs.md) |
| [rustscan](rustscan/) | Modern port scanner with adaptive scanning | [README](rustscan/README.md) • [Docs](rustscan/official_docs.md) |

---

## Enumeration

Directory and service enumeration tools.

| Tool | Description | Docs |
|------|-------------|------|
| [gobuster](gobuster/) | Directory/file & DNS busting tool | [README](gobuster/README.md) • [Docs](gobuster/official_docs.md) |
| [feroxbuster](feroxbuster/) | Fast, recursive content discovery tool | [README](feroxbuster/README.md) • [Docs](feroxbuster/official_docs.md) |
| [enum4linux](enum4linux/) | Tool for enumerating information from Windows and Samba systems | [README](enum4linux/README.md) • [Docs](enum4linux/official_docs.md) |
| [smbclient](smbclient/) | FTP-like client to access SMB/CIFS resources | [README](smbclient/README.md) • [Docs](smbclient/official_docs.md) |
| [smbmap](smbmap/) | SMB share enumeration tool | [README](smbmap/README.md) • [Docs](smbmap/official_docs.md) |

---

## Active Directory

Tools for Active Directory enumeration and attacks.

| Tool | Description | Docs |
|------|-------------|------|
| [bloodhound](bloodhound/) | AD relationship visualizer for attack path discovery | [README](bloodhound/README.md) • [Docs](bloodhound/official_docs.md) |
| [kerbrute](kerbrute/) | Kerberos bruteforce and enumeration tool | [README](kerbrute/README.md) • [Docs](kerbrute/official_docs.md) |
| [responder](responder/) | LLMNR/NBT-NS/MDNS poisoner and credential harvester | [README](responder/README.md) • [Docs](responder/official_docs.md) |
| [crackmapexec](crackmapexec/) | Swiss army knife for AD pentesting (deprecated) | [README](crackmapexec/README.md) |
| [netexec](netexec/) | Network execution tool (CrackMapExec successor) | [README](netexec/README.md) • [Docs](netexec/official_docs.md) |

---

## Exploitation

Exploitation frameworks and tools.

| Tool | Description | Docs |
|------|-------------|------|
| [impacket](impacket/) | Python classes for working with network protocols | [README](impacket/README.md) • [Docs](impacket/official_docs.md) |
| [evil-winrm](evil-winrm/) | Ultimate WinRM shell for pentesting | [README](evil-winrm/README.md) • [Docs](evil-winrm/official_docs.md) |
| [metasploit-framework](metasploit-framework/) | World's most used penetration testing framework | [README](metasploit-framework/README.md) • [Docs](metasploit-framework/official_docs.md) |
| [msfvenom](msfvenom/) | Payload generator for Metasploit | [README](msfvenom/README.md) • [Docs](msfvenom/official_docs.md) |

---

## Password Cracking

Password recovery and brute-force tools.

| Tool | Description | Docs |
|------|-------------|------|
| [hashcat](hashcat/) | World's fastest password recovery tool | [README](hashcat/README.md) • [Docs](hashcat/official_docs.md) • [Modes](hashcat/modes.md) |
| [john](john/) | John the Ripper password cracker | [README](john/README.md) • [Docs](john/official_docs.md) |
| [hydra](hydra/) | Fast network logon cracker | [README](hydra/README.md) • [Docs](hydra/official_docs.md) |

---

## Pivoting & Tunneling

Network pivoting and tunnel creation tools.

| Tool | Description | Docs |
|------|-------------|------|
| [chisel](chisel/) | Fast TCP/UDP tunnel over HTTP | [README](chisel/README.md) • [Docs](chisel/official_docs.md) |
| [ligolo-ng](ligolo-ng/) | Advanced tunneling/pivoting tool | [README](ligolo-ng/README.md) • [Docs](ligolo-ng/official_docs.md) |
| [proxychains](proxychains/) | Redirect TCP connections through proxy servers | [README](proxychains/README.md) • [Docs](proxychains/official_docs.md) |
| [ssh](ssh/) | Secure Shell client for remote access and tunneling | [README](ssh/README.md) • [Docs](ssh/official_docs.md) |
| [socat](socat/) | Multipurpose relay (SOcket CAT) | [README](socat/README.md) • [Docs](socat/official_docs.md) |

---

## Privilege Escalation

Privilege escalation enumeration and exploitation tools.

| Tool | Description | Docs |
|------|-------------|------|
| [linpeas](linpeas/) | Linux Privilege Escalation Awesome Script | [README](linpeas/README.md) • [Docs](linpeas/official_docs.md) |
| [winpeas](winpeas/) | Windows Privilege Escalation Awesome Script | [README](winpeas/README.md) • [Docs](winpeas/official_docs.md) |
| [pspy](pspy/) | Monitor Linux processes without root permissions | [README](pspy/README.md) • [Docs](pspy/official_docs.md) |
| [mimikatz](mimikatz/) | Windows credential extraction tool | [README](mimikatz/README.md) • [Docs](mimikatz/official_docs.md) |

---

## Networking Utilities

General networking utilities.

| Tool | Description | Docs |
|------|-------------|------|
| [nc](nc/) | Netcat - TCP/UDP network Swiss army knife | [README](nc/README.md) • [Docs](nc/official_docs.md) • [Options](nc/options.md) |
| [rlwrap](rlwrap/) | Readline wrapper for CLI tools | [README](rlwrap/README.md) • [Docs](rlwrap/official_docs.md) |

---

## Documentation Status

| Status | Count | Percentage |
|--------|-------|------------|
| Documented | 33 | 100% |
| Refactored with TOC | 0 | 0% |
| Complete | 0 | 0% |

See [ROADMAP.md](../../ROADMAP.md) for documentation standards and progress tracking.

---

*Last updated: 2025-12-27*
