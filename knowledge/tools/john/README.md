---
title: "John the Ripper"
category: "password-cracking"
tags: ["password-cracking", "hash-cracking", "brute-force", "wordlist-attack"]
sources:
  - type: official
    url: "https://www.openwall.com/john/"
  - type: github
    url: "https://github.com/openwall/john"
last_updated: "2025-12-27"
---

# John the Ripper

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Wordlists and Rules](#wordlists-and-rules)
- [Documentation Files](#documentation-files)

## Overview

John the Ripper is a fast password cracker available for Unix, macOS, Windows, and other platforms. It detects weak passwords by supporting hundreds of hash types including:

- **Unix crypt(3)**: DES, MD5, Blowfish, SHA-crypt
- **Windows**: LM, NTLM hashes
- **Web applications**: MD5, SHA-1, SHA-256, SHA-512
- **Archives**: ZIP, RAR, 7z
- **Documents**: PDF, Microsoft Office
- **Other**: SSH keys, Kerberos TGTs, encrypted filesystems

The "jumbo" version (community-enhanced) adds extensive format support and is the recommended version.

## Installation

### From Package Manager

```bash
# Debian/Ubuntu
sudo apt install john

# Arch Linux
sudo pacman -S john

# macOS
brew install john-jumbo
```

### From Source (Jumbo)

```bash
git clone https://github.com/openwall/john.git
cd john/src
./configure && make -s clean && make -sj4
```

The binary will be in `../run/john`.

## Quick Start

### Basic Usage

```bash
# Crack password file with default modes
john passwd

# Show cracked passwords
john --show passwd

# Check status during cracking: press any key
# Abort and save session: press 'q' or Ctrl-C
# Resume interrupted session
john --restore
```

### Cracking Common Hash Types

```bash
# Linux shadow file (auto-detected)
john /etc/shadow

# Windows NTLM hashes
john --format=NT hashes.txt

# MD5 hashes
john --format=Raw-MD5 hashes.txt

# SHA-256 hashes
john --format=Raw-SHA256 hashes.txt

# ZIP file (extract hash first)
zip2john protected.zip > zip.hash
john zip.hash

# PDF file
pdf2john protected.pdf > pdf.hash
john pdf.hash
```

### List Supported Formats

```bash
john --list=formats
john --list=formats --format=sha
```

## Wordlists and Rules

### Using Wordlists

```bash
# Basic wordlist attack
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt

# Wordlist with rules (word mangling)
john --wordlist=wordlist.txt --rules hashes.txt

# Specific rule set
john --wordlist=wordlist.txt --rules=Jumbo hashes.txt
```

### Incremental Mode (Brute Force)

```bash
# Default incremental mode
john --incremental hashes.txt

# Specific character set
john --incremental=Digits hashes.txt
john --incremental=Alpha hashes.txt
```

## Documentation Files

| File | Description |
|------|-------------|
| [INSTALL](doc/INSTALL) | Installation instructions |
| [OPTIONS](doc/OPTIONS) | Command line options |
| [MODES](doc/MODES) | Cracking modes explained |
| [RULES](doc/RULES) | Wordlist rules syntax |
| [EXAMPLES](doc/EXAMPLES) | Usage examples |
| [FAQ](doc/FAQ) | Frequently asked questions |

See also: [Homepage](https://www.openwall.com/john/) | [GitHub](https://github.com/openwall/john) | [Wiki](https://openwall.info/wiki/john)
