---
title: Attack Techniques Overview
category: techniques
tags:
  - windows
  - linux
  - active-directory
  - network
  - privilege-escalation
  - persistence
last_updated: 2025-12-27
---

# Attack Techniques

Offensive security techniques organized by target platform.

## Table of Contents

- [Overview](#overview)
- [Windows](#windows)
- [Linux](#linux)
- [Active Directory](#active-directory)
- [Network](#network)
- [MITRE ATT&CK Alignment](#mitre-attck-alignment)

## Overview

This section documents attack techniques categorized by platform and attack surface. Each subdirectory contains detailed procedures, code samples, and operational considerations.

```
techniques/
├── windows/          # Windows client and server attacks
├── linux/            # Linux privilege escalation and persistence
├── active-directory/ # AD-specific attacks (Kerberos, NTLM, delegation)
└── network/          # Network-level attacks (MITM, relay, poisoning)
```

## Windows

Techniques targeting Windows desktop and server environments.

| Category | Techniques |
|----------|------------|
| **Desktop** | UAC Bypass, Token Manipulation, DLL Hijacking, COM Hijacking, Credential Dumping (LSASS/SAM) |
| **Server** | Service Exploitation, Print Spooler (PrintNightmare), WSUS MITM, SCCM Attacks |
| **Persistence** | Registry Run Keys, Scheduled Tasks, WMI Subscriptions, Service Creation |

## Linux

Techniques for Linux privilege escalation and persistence.

| Category | Techniques |
|----------|------------|
| **Privilege Escalation** | SUID/SGID Abuse, Sudo Misconfigurations, Capabilities, Cron Exploitation, Kernel Exploits, Path Injection |
| **Persistence** | SSH Key Injection, Cron Backdoors, Systemd Services, Bashrc/Profile Hooks, PAM Backdoors |
| **Container Escapes** | Docker Socket Abuse, Privileged Container Breakout, Namespace Attacks |

## Active Directory

Techniques targeting Active Directory infrastructure.

### Kerberos Attacks

| Attack | Description |
|--------|-------------|
| AS-REP Roasting | Extract hashes for accounts without preauth |
| Kerberoasting | Request and crack service ticket hashes |
| Golden Ticket | Forge TGTs with KRBTGT hash |
| Silver Ticket | Forge service tickets for specific SPNs |
| Diamond Ticket | Modify legitimate TGTs with PAC manipulation |

### NTLM Attacks

| Attack | Description |
|--------|-------------|
| Pass-the-Hash | Authenticate using NTLM hash directly |
| NTLM Relay | Relay captured authentication to other services |
| NTLMv1 Downgrade | Force weaker authentication for cracking |

### Delegation Attacks

| Attack | Description |
|--------|-------------|
| Unconstrained | Capture TGTs from connecting users |
| Constrained | Abuse S4U2Self/S4U2Proxy for impersonation |
| RBCD | Resource-based constrained delegation abuse |

### Additional AD Attacks

DCSync, DCShadow, GPO Abuse, ACL Exploitation, AD CS Attacks (ESC1-ESC8), Shadow Credentials

## Network

Network-level attack techniques.

| Category | Techniques |
|----------|------------|
| **MITM** | ARP Spoofing, DNS Spoofing, DHCP Spoofing, IPv6 MITM |
| **Relay** | SMB Relay, LDAP/LDAPS Relay, HTTP Relay, Cross-Protocol Relay |
| **Poisoning** | LLMNR, NBT-NS, mDNS, WPAD Exploitation |
| **Sniffing** | Packet Capture, Traffic Analysis, Credential Harvesting |

## MITRE ATT&CK Alignment

Techniques align with the [MITRE ATT&CK Framework](https://attack.mitre.org/):

| Tactic | Relevant Techniques |
|--------|---------------------|
| Initial Access (TA0001) | Network attacks, phishing vectors |
| Execution (TA0002) | Code execution techniques |
| Persistence (TA0003) | Linux/Windows persistence mechanisms |
| Privilege Escalation (TA0004) | Linux/Windows privesc techniques |
| Defense Evasion (TA0005) | UAC bypass, token manipulation |
| Credential Access (TA0006) | Kerberos attacks, credential dumping |
| Lateral Movement (TA0008) | Pass-the-hash, relay attacks |

Each technique document references relevant ATT&CK technique IDs (e.g., T1003 for Credential Dumping). For interactive mapping, see the [ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/).
