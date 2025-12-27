---
title: "rlwrap"
category: tool
subcategory: networking
tags: ["readline", "shell", "history", "cli", "wrapper", "reverse-shell"]
last_updated: 2025-12-27
---

# rlwrap

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Key Options](#key-options)
- [Documentation](#documentation)

## Overview

rlwrap (readline wrapper) wraps any command-line program to provide GNU Readline features: line editing (arrow keys), persistent command history, and tab completion. Essential for making reverse shells usable by adding arrow key navigation and command history that raw shells lack.

## Installation

```bash
# Debian/Ubuntu (pre-installed on Kali)
sudo apt install rlwrap

# Verify
rlwrap --version
```

## Quick Start

The primary use case: wrapping netcat for reverse shell listeners.

```bash
# Basic netcat listener with readline support
rlwrap nc -lvnp 4444

# Benefits when shell connects:
# - Up/Down arrows for command history
# - Left/Right arrows for line editing
# - Backspace works properly
# - Ctrl+R for reverse history search
```

Create an alias for convenience:

```bash
alias listen='rlwrap nc -lvnp'
# Usage: listen 4444
```

## Key Options

| Option | Description |
|--------|-------------|
| `-a` | Always remain in readline mode (force it for stubborn programs) |
| `-c` | Enable filename tab completion |
| `-r` | Remember words from I/O for completion |
| `-f FILE` | Load completion words from file |
| `-H FILE` | Use custom history file |
| `-s N` | Limit history size (default: 300) |
| `-p COLOR` | Set prompt color (Red, Green, Blue, etc.) |

**Examples:**

```bash
rlwrap -a -c nc -lvnp 4444          # Force readline + file completion
rlwrap -r nc -lvnp 4444             # Learn words for completion
rlwrap -H ~/.shells/target1 nc -lvnp 4444  # Separate history per target
```

## Documentation

| File | Description |
|------|-------------|
| [use-cases.md](docs/use-cases.md) | SQL*Plus, custom completions, workflows |
| [configuration.md](docs/configuration.md) | Environment variables, persistent setup |
| [tips.md](docs/tips.md) | Best practices and limitations |

**Related tools:** nc, ncat, socat, pwncat, screen/tmux
