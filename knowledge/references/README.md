---
title: Quick Reference Guides
category: reference
last_updated: 2025-12-27
description: Collection of quick reference materials and cheatsheets for penetration testing
---

# Quick Reference Guides

This directory contains quick reference materials and cheatsheets for common penetration testing tasks.

## Overview

Reference materials are designed for rapid lookup during engagements. They provide concise, copy-paste ready commands and techniques.

## Cheatsheets

### Shells and Access

- [Reverse Shells](cheatsheets/reverse-shells.md) - One-liners and payloads for various languages and platforms
- Shell stabilization techniques
- Bind shell alternatives

### File Operations

- [File Transfers](cheatsheets/file-transfers.md) - Methods for moving files between systems
- Linux transfer techniques (wget, curl, nc, python)
- Windows transfer techniques (certutil, PowerShell, SMB)

### Password Cracking

- [Hash Types](cheatsheets/hash-types.md) - Hash identification and cracking reference
- Common hash formats with examples
- Hashcat modes and John formats

## Usage Guidelines

1. **Verify commands** - Always verify commands match your target environment
2. **Modify IPs/Ports** - Replace placeholder IPs (10.10.10.10) and ports (4444) with actual values
3. **Encoding** - Some payloads may need URL or base64 encoding depending on context
4. **OPSEC** - Consider detection when choosing techniques in real engagements

## Quick Links

| Topic | Common Use Case |
|-------|-----------------|
| [Reverse Shells](cheatsheets/reverse-shells.md) | Initial access, catching callbacks |
| [File Transfers](cheatsheets/file-transfers.md) | Moving tools and exfiltrating data |
| [Hash Types](cheatsheets/hash-types.md) | Identifying and cracking hashes |

## Contributing

When adding new cheatsheets:

1. Use YAML frontmatter with title, category, and last_updated
2. Group related commands logically
3. Include brief explanations where helpful
4. Test commands before adding
5. Note any dependencies or requirements
