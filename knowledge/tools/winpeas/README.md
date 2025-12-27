---
title: "WinPEAS"
category: "privilege-escalation"
subcategory: "windows"
os: "windows"
tags: ["privilege-escalation", "enumeration", "windows", "post-exploitation"]
sources:
  - type: github
    url: "https://github.com/peass-ng/PEASS-ng"
last_updated: "2025-12-27"
---

# WinPEAS

## Table of Contents

- [Overview](#overview)
- [Download](#download)
- [Quick Start](#quick-start)
- [Key Checks](#key-checks)
- [Documentation](#documentation)

## Overview

WinPEAS (Windows Privilege Escalation Awesome Script) is a script that searches for possible local privilege escalation paths on Windows systems. It is part of the PEASS-ng (Privilege Escalation Awesome Scripts SUITE) project.

The tool performs comprehensive enumeration and highlights potential misconfigurations using color-coded output for easy identification of security issues.

**Reference:** [HackTricks Windows Privilege Escalation Checklist](https://book.hacktricks.wiki/en/windows-hardening/checklist-windows-privilege-escalation.html)

## Download

| Version | Description | Link |
|---------|-------------|------|
| winPEASx64.exe | 64-bit executable | [Latest Release](https://github.com/peass-ng/PEASS-ng/releases/latest) |
| winPEASx86.exe | 32-bit executable | [Latest Release](https://github.com/peass-ng/PEASS-ng/releases/latest) |
| winPEASany.exe | Any CPU executable | [Latest Release](https://github.com/peass-ng/PEASS-ng/releases/latest) |
| winPEAS.bat | Batch script version | [Latest Release](https://github.com/peass-ng/PEASS-ng/releases/latest) |

## Quick Start

**Run with default checks:**

```cmd
.\winPEASx64.exe
```

**Run specific checks:**

```cmd
.\winPEASx64.exe systeminfo userinfo
```

**Run quietly (less output):**

```cmd
.\winPEASx64.exe quiet
```

**Output to file:**

```cmd
.\winPEASx64.exe log=output.txt
```

**Run batch version (for restricted environments):**

```cmd
winPEAS.bat
```

## Key Checks

| Category | Description |
|----------|-------------|
| System Info | OS version, architecture, hotfixes, environment variables |
| Users Info | Current user privileges, logged users, local groups |
| Processes | Running processes, DLL hijacking opportunities |
| Services | Unquoted paths, writable service binaries, modifiable services |
| Applications | Installed software, potential vulnerable versions |
| Network | Open ports, firewall rules, network shares |
| Credentials | Stored credentials, cached passwords, browser data |
| Files | Interesting files, writable directories, sensitive configs |
| Registry | AutoRun entries, AlwaysInstallElevated, saved credentials |
| Scheduled Tasks | Modifiable tasks, task permissions |

## Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | This file - tool overview and quick start |
| [official_docs.md](official_docs.md) | Official documentation from GitHub |

## Advisory

This tool should be used for authorized penetration testing and educational purposes only. Misuse of this software is solely the responsibility of the user.
