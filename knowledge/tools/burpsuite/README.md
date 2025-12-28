---
title: "Burp Suite"
category: "tool"
subcategory: "web-application-testing"
tags:
  - web
  - proxy
  - intercepting-proxy
  - vulnerability-scanner
  - penetration-testing
  - api-testing
sources:
  - https://portswigger.net/burp/documentation
  - https://portswigger.net/burp/documentation/desktop
last_updated: "2025-12-27"
---

# Burp Suite

> The industry-standard web application security testing toolkit - intercepting proxy, scanner, and extensible platform.

## Table of Contents

- [Overview](#overview)
- [Editions](#editions)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Tools](#core-tools)
- [Common Options](#common-options)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Documentation Files](#documentation-files)
- [Related Tools](#related-tools)

## Overview

Burp Suite is an integrated platform for web application security testing. It provides a comprehensive suite of tools for mapping application attack surfaces, analyzing requests and responses, and discovering vulnerabilities.

Key capabilities:
- **Intercepting Proxy** - Capture and modify HTTP/HTTPS traffic
- **Active/Passive Scanner** - Automated vulnerability detection (Pro)
- **Intruder** - Customizable automated attacks and fuzzing
- **Repeater** - Manual request manipulation and testing
- **Extensibility** - Rich extension ecosystem via BApp Store

## Editions

| Edition | Cost | Key Features |
|---------|------|--------------|
| Community | Free | Proxy, Repeater, Decoder, Comparer, Sequencer (rate-limited) |
| Professional | $449/year | Full scanner, unlimited Intruder, Collaborator, extensions |
| Enterprise | Custom | CI/CD integration, scheduled scans, team features |

## Installation

### Kali Linux (Pre-installed)

```bash
# Launch Community Edition
burpsuite

# Or via applications menu
# Applications > Web Application Analysis > burpsuite
```

### Manual Installation (All Platforms)

```bash
# Download from PortSwigger
# https://portswigger.net/burp/releases

# Linux - Run installer
chmod +x burpsuite_community_linux_*.sh
./burpsuite_community_linux_*.sh

# Or run JAR directly (requires Java 17+)
java -jar burpsuite_community.jar
```

### Java Requirements

```bash
# Check Java version
java -version

# Install Java 17+ if needed (Debian/Ubuntu)
sudo apt install openjdk-17-jdk
```

## Quick Start

### 1. Configure Browser Proxy

Set browser to use proxy `127.0.0.1:8080`:
- Firefox: Settings > Network Settings > Manual proxy
- Chrome: Use FoxyProxy or system proxy settings

### 2. Install CA Certificate

```
1. With proxy configured, visit http://burp
2. Click "CA Certificate" to download
3. Import into browser's certificate store
4. Mark as trusted for identifying websites
```

### 3. Start Intercepting

```
1. Go to Proxy > Intercept tab
2. Ensure "Intercept is on"
3. Browse target in configured browser
4. Inspect/modify requests, click Forward or Drop
```

### 4. Map the Application

```
1. Turn intercept off for passive crawling
2. Browse application thoroughly
3. Check Target > Site map for discovered content
4. Right-click items to add to scope
```

## Core Tools

| Tool | Purpose | Common Use |
|------|---------|------------|
| **Proxy** | Intercept HTTP/S traffic | Capture and modify requests/responses |
| **Target** | Site map and scope | Organize testing, define scope |
| **Repeater** | Manual request testing | Modify and resend individual requests |
| **Intruder** | Automated attacks | Fuzzing, brute-force, parameter testing |
| **Scanner** | Vulnerability scanning | Automated vuln detection (Pro only) |
| **Decoder** | Encode/decode data | Base64, URL, HTML, hex transformations |
| **Comparer** | Diff responses | Compare requests/responses side-by-side |
| **Sequencer** | Token analysis | Analyze randomness of session tokens |
| **Collaborator** | Out-of-band testing | Detect blind vulnerabilities (Pro only) |

## Common Options

### Proxy Settings

| Setting | Location | Purpose |
|---------|----------|---------|
| Proxy listener | Proxy > Options | Configure bind address/port |
| Intercept rules | Proxy > Options | Filter what to intercept |
| Response modification | Proxy > Options | Auto-modify responses |
| Match and replace | Proxy > Options | Auto-replace patterns |
| TLS pass through | Proxy > Options | Bypass SSL for specific hosts |

### Project Options

| Setting | Purpose |
|---------|---------|
| Target scope | Define in-scope hosts/URLs |
| Session handling | Maintain authentication state |
| Macro recording | Automate login sequences |
| Upstream proxy | Chain through another proxy |

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Send to Repeater |
| `Ctrl+I` | Send to Intruder |
| `Ctrl+S` | Send to Scanner (Pro) |
| `Ctrl+F` | Forward intercepted request |
| `Ctrl+D` | Drop intercepted request |
| `Ctrl+T` | Toggle intercept on/off |
| `Ctrl+Shift+T` | Switch to Target tab |
| `Ctrl+Shift+P` | Switch to Proxy tab |
| `Ctrl+Shift+R` | Switch to Repeater tab |
| `Ctrl+Shift+I` | Switch to Intruder tab |

## Documentation Files

| File | Description |
|------|-------------|
| [features.md](features.md) | Detailed feature documentation (Proxy, Repeater, Intruder, Scanner) |
| [extensions.md](extensions.md) | Extensions, BApp Store, and custom extension development |

## Related Tools

| Tool | Relationship |
|------|--------------|
| **OWASP ZAP** | Free open-source alternative |
| **mitmproxy** | CLI intercepting proxy |
| **Caido** | Modern alternative with similar features |
| **sqlmap** | SQL injection (integrates via extension) |
| **ffuf/feroxbuster** | Content discovery (complements Burp) |

## Resources

- [Official Documentation](https://portswigger.net/burp/documentation)
- [Web Security Academy](https://portswigger.net/web-security)
- [BApp Store](https://portswigger.net/bappstore)
- [PortSwigger Research](https://portswigger.net/research)
