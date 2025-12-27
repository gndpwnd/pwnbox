---
title: hashcat
category: password-cracking
tags:
  - hash-cracking
  - gpu-acceleration
  - password-recovery
  - pentesting
sources:
  - https://hashcat.net/hashcat/
  - https://github.com/hashcat/hashcat
last_updated: 2025-12-27
---

# hashcat

> World's fastest password recovery tool with GPU acceleration

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Attack Modes](#attack-modes)
- [Common Hash Types](#common-hash-types)
- [AD Pentesting Quick Reference](#ad-pentesting-quick-reference)
- [Rule-Based Attacks](#rule-based-attacks)
- [Documentation](#documentation)

## Overview

Hashcat is the world's fastest and most advanced password recovery utility. It supports:

- **300+ hash algorithms** (MD5, SHA1, bcrypt, NTLM, WPA, etc.)
- **GPU acceleration** (NVIDIA CUDA, AMD OpenCL)
- **Multiple attack modes** (dictionary, brute-force, hybrid, rules)
- **Distributed cracking** via Hashtopolis
- **Cross-platform** (Linux, Windows, macOS)

## Installation

```bash
# Kali Linux / Debian
sudo apt install hashcat

# From source
git clone https://github.com/hashcat/hashcat.git
cd hashcat && make

# Verify installation
hashcat --version
```

## Quick Start

### Dictionary Attack (Mode 0)

```bash
# Basic wordlist attack
hashcat -m 0 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt

# With rules
hashcat -m 0 -a 0 hashes.txt wordlist.txt -r /usr/share/hashcat/rules/best64.rule
```

### Brute-Force / Mask Attack (Mode 3)

```bash
# 8-char lowercase
hashcat -m 0 -a 3 hash.txt ?l?l?l?l?l?l?l?l

# Custom charset: uppercase + digits, 6 chars
hashcat -m 0 -a 3 hash.txt -1 ?u?d ?1?1?1?1?1?1
```

### Hybrid Attacks (Modes 6 & 7)

```bash
# Wordlist + mask (append 4 digits)
hashcat -m 0 -a 6 hash.txt wordlist.txt ?d?d?d?d

# Mask + wordlist (prepend 2 digits)
hashcat -m 0 -a 7 hash.txt ?d?d wordlist.txt
```

### Show Cracked Passwords

```bash
hashcat -m 0 hashes.txt --show
hashcat -m 0 hashes.txt --show --outfile-format=2  # passwords only
```

## Attack Modes

| Mode | Name       | Description                          |
|------|------------|--------------------------------------|
| 0    | Straight   | Dictionary attack                    |
| 1    | Combinator | Combine words from two wordlists     |
| 3    | Brute-force| Mask-based character permutations    |
| 6    | Hybrid     | Wordlist + mask                      |
| 7    | Hybrid     | Mask + wordlist                      |
| 9    | Association| Targeted attack with hints           |

## Common Hash Types

| Mode   | Hash Type                    | Example Use Case           |
|--------|------------------------------|----------------------------|
| 0      | MD5                          | Web apps, databases        |
| 100    | SHA1                         | Legacy systems             |
| 1000   | NTLM                         | Windows credentials        |
| 1800   | sha512crypt                  | Linux /etc/shadow          |
| 3200   | bcrypt                       | Modern web apps            |
| 5600   | NetNTLMv2                    | AD relay attacks           |
| 13100  | Kerberos TGS-REP (RC4)       | Kerberoasting              |
| 18200  | Kerberos AS-REP (RC4)        | AS-REP roasting            |
| 22000  | WPA-PBKDF2-PMKID+EAPOL       | WiFi cracking              |

Run `hashcat --example-hashes` for full list with format examples.

## AD Pentesting Quick Reference

### NTLM Hashes (Mode 1000)

```bash
# Quick rockyou + rules
hashcat -m 1000 ntlm.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# Common corporate patterns
hashcat -m 1000 -a 3 ntlm.txt ?u?l?l?l?l?l?l?d?d?d?d
hashcat -m 1000 -a 6 ntlm.txt usernames.txt ?d?d?d?d

# Deep dive with aggressive rules
hashcat -m 1000 ntlm.txt rockyou.txt -r /usr/share/hashcat/rules/d3ad0ne.rule
```

### NetNTLMv2 (Mode 5600)

```bash
# From Responder/ntlmrelayx captures
hashcat -m 5600 netntlmv2.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule -O

# Common patterns (slower hash, be strategic)
hashcat -m 5600 -a 3 netntlmv2.txt ?u?l?l?l?l?l2024!
```

### Kerberoasting TGS-REP (Mode 13100)

```bash
# From GetUserSPNs.py / Rubeus
hashcat -m 13100 kerberos.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# Service accounts often have weak passwords
hashcat -m 13100 -a 6 kerberos.txt service-words.txt ?d?d?d?d
```

### AS-REP Roasting (Mode 18200)

```bash
# From GetNPUsers.py
hashcat -m 18200 asrep.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```

### Domain Cached Credentials (Mode 2100)

```bash
# Very slow - use focused wordlists
hashcat -m 2100 dcc2.txt top1000.txt -r /usr/share/hashcat/rules/best64.rule -w 3
```

## Rule-Based Attacks

### Best Rule Files

| Rule File | Size | Use Case |
|-----------|------|----------|
| `best64.rule` | 64 rules | Quick first pass |
| `rockyou-30000.rule` | 30k rules | Comprehensive |
| `d3ad0ne.rule` | ~35k rules | Aggressive mutations |
| `OneRuleToRuleThemAll.rule` | Optimized | Best efficiency |

### Rule Attack Examples

```bash
# Single rule file
hashcat -m 1000 hashes.txt wordlist.txt -r /usr/share/hashcat/rules/best64.rule

# Chain multiple rules (multiplies candidates)
hashcat -m 1000 hashes.txt wordlist.txt -r rules/best64.rule -r rules/toggles1.rule

# Generate random rules
hashcat -m 1000 hashes.txt wordlist.txt -g 50000
```

### Common Rule Functions

| Rule | Description | Example |
|------|-------------|---------|
| `c` | Capitalize first | password -> Password |
| `$X` | Append char X | password$1 -> password1 |
| `^X` | Prepend char X | password^1 -> 1password |
| `sXY` | Replace X with Y | sae -> p@ssword |
| `u` | Uppercase all | password -> PASSWORD |
| `d` | Duplicate | pass -> passpass |

## Mask Charsets

| Charset | Description         |
|---------|---------------------|
| ?l      | a-z                 |
| ?u      | A-Z                 |
| ?d      | 0-9                 |
| ?s      | Special characters  |
| ?a      | ?l?u?d?s            |
| ?b      | 0x00-0xff           |

## Useful Options

```bash
-w 3                  # Workload profile (1=low, 3=high, 4=nightmare)
-O                    # Optimized kernels (faster, limited password length)
--force               # Ignore warnings (use with caution)
--status              # Enable status screen
--potfile-disable     # Don't save to potfile
-o cracked.txt        # Output file for cracked hashes
--username            # Ignore usernames in hash file
```

## Documentation

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | Advanced cracking techniques, AD strategies, optimization |
| [official_docs.md](official_docs.md) | Wiki content, attack guides, external resources |
| [modes.md](modes.md) | Full hash mode list, options reference, status output |

## External Resources

- [Hashcat Wiki](https://hashcat.net/wiki/)
- [Example Hashes](https://hashcat.net/wiki/doku.php?id=example_hashes)
- [Rule-based Attack Guide](https://hashcat.net/wiki/doku.php?id=rule_based_attack)
- [Hashcat Forum](https://hashcat.net/forum/)
