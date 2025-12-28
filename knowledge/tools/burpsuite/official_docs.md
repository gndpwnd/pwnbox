---
title: "Burp Suite - Official Documentation Reference"
category: "tools"
tags: ["web-security", "proxy", "scanner", "burpsuite"]
last_updated: "2025-12-27"
---

# Burp Suite - Official Documentation Reference

> Comprehensive reference to Burp Suite's official documentation and resources from PortSwigger.

## Table of Contents

- [Official Resources](#official-resources)
- [Major Components](#major-components)
  - [Proxy](#proxy)
  - [Scanner](#scanner)
  - [Repeater](#repeater)
  - [Intruder](#intruder)
  - [Decoder](#decoder)
  - [Comparer](#comparer)
  - [Extender](#extender)
- [Configuration and Setup](#configuration-and-setup)
- [Common Workflows](#common-workflows)
- [Useful Extensions](#useful-extensions)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Advanced Features](#advanced-features)

---

## Official Resources

### Primary Documentation

| Resource | URL | Description |
|----------|-----|-------------|
| Official Documentation | https://portswigger.net/burp/documentation | Main documentation hub |
| Desktop Documentation | https://portswigger.net/burp/documentation/desktop | Full desktop application docs |
| Web Security Academy | https://portswigger.net/web-security | Free training with hands-on labs |
| BApp Store | https://portswigger.net/bappstore | Official extension marketplace |
| PortSwigger Research | https://portswigger.net/research | Cutting-edge security research |
| Release Notes | https://portswigger.net/burp/releases | Version history and changes |
| Support Center | https://portswigger.net/support | FAQs and troubleshooting |

### API and Extension Development

| Resource | URL |
|----------|-----|
| Extender API | https://portswigger.net/burp/extender/api |
| Extension Development Guide | https://portswigger.net/burp/documentation/desktop/extensions/creating |
| Example Extensions | https://github.com/PortSwigger/example-extensions |
| Montoya API (New) | https://portswigger.net/burp/documentation/desktop/extensions/creating/montoya-api |

### Community and Support

| Resource | URL |
|----------|-----|
| PortSwigger Forum | https://forum.portswigger.net |
| Twitter/X | https://twitter.com/PortSwigger |
| Bug Bounty Program | https://portswigger.net/burp/vulnerability-scanner |

---

## Major Components

### Proxy

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/proxy

The Proxy is the core of Burp Suite, functioning as a man-in-the-middle between the browser and target applications.

#### Key Features

| Feature | Description | Documentation |
|---------|-------------|---------------|
| Intercept | Capture and modify HTTP/HTTPS requests in real-time | [Intercepting requests](https://portswigger.net/burp/documentation/desktop/tools/proxy/intercept) |
| HTTP History | Complete log of all proxied traffic | [Using HTTP history](https://portswigger.net/burp/documentation/desktop/tools/proxy/http-history) |
| WebSocket History | Capture WebSocket messages | [WebSocket messages](https://portswigger.net/burp/documentation/desktop/tools/proxy/websocket-history) |
| Match & Replace | Automatic request/response modification | [Match and replace](https://portswigger.net/burp/documentation/desktop/tools/proxy/options#match-and-replace) |
| TLS Pass Through | Bypass SSL inspection for specific hosts | [TLS settings](https://portswigger.net/burp/documentation/desktop/tools/proxy/options#tls-pass-through) |

#### Proxy Listener Configuration

```
Location: Proxy > Proxy settings > Proxy listeners

Default Configuration:
- Bind to port: 8080
- Bind to address: 127.0.0.1 (loopback only)

Additional Options:
- Running: Toggle listener on/off
- Invisible: Support non-proxy-aware clients
- Certificate: Per-host or self-signed CA
```

#### Intercept Rules

```
Location: Proxy > Proxy settings > Request interception rules

Default Behavior:
- Intercept requests that are in target scope
- Exclude static files (images, CSS, JS)

Custom Rules:
- Match by URL, file extension, parameters
- Match by HTTP method
- Match by request body content
- Match by HTTP headers
```

#### Response Interception

```
Location: Proxy > Proxy settings > Response interception rules

Common Use Cases:
- Intercept responses containing sensitive data
- Modify security headers before reaching browser
- Inject JavaScript for client-side testing
- Remove Content-Security-Policy headers
```

#### Match and Replace

| Type | Match | Replace | Use Case |
|------|-------|---------|----------|
| Request header | `User-Agent:.*` | `User-Agent: CustomBot/1.0` | Spoof user agent |
| Request body | `password=` | `password=test123&` | Inject test data |
| Response header | `X-Frame-Options.*` | (empty) | Remove clickjacking protection |
| Response body | `</head>` | `<script>console.log('injected')</script></head>` | Client-side testing |

---

### Scanner

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/scanner (Professional/Enterprise only)

The Scanner performs automated vulnerability detection through passive analysis and active testing.

#### Scan Types

| Type | Description | Availability |
|------|-------------|--------------|
| Passive Scan | Analyzes traffic without sending requests | Automatic on all traffic |
| Active Scan | Sends payloads to detect vulnerabilities | On-demand or scheduled |
| Crawl | Discovers application content | Configurable depth/breadth |
| Audit | Tests discovered content for vulnerabilities | Configurable intensity |

#### Starting a Scan

```
Method 1: Dashboard
Dashboard > New scan > Configure scan type

Method 2: Right-click context menu
Target/Proxy > Right-click request > Scan

Method 3: Scope-based
Configure target scope > Dashboard > New scan > Crawl and audit
```

#### Scan Configuration

**Official Docs:** https://portswigger.net/burp/documentation/desktop/scanning/scan-launcher

| Option | Description |
|--------|-------------|
| Crawl Configuration | Depth, breadth, login sequences |
| Audit Configuration | Insertion points, detection methods |
| Resource Pool | Concurrent connections, request rate |
| Scope | Include/exclude URL patterns |

#### Vulnerability Categories Detected

```
Injection:
- SQL injection (error-based, blind, time-based)
- OS command injection
- LDAP injection
- XPath injection
- Server-side template injection

Cross-Site Scripting:
- Reflected XSS
- Stored XSS
- DOM-based XSS

Authentication/Authorization:
- Broken authentication
- Session management issues
- Access control bypasses

Other:
- XML External Entity (XXE)
- Server-Side Request Forgery (SSRF)
- File path traversal
- Open redirects
- Information disclosure
```

#### Scan Results

```
Location: Dashboard > Issue activity / Target > Issues

Severity Levels:
- High: Critical vulnerabilities requiring immediate attention
- Medium: Significant issues that should be addressed
- Low: Minor issues with limited impact
- Information: Non-security findings for awareness

Actions:
- Right-click > Report selected issues (HTML/XML export)
- Set false positive status
- Add notes and comments
```

---

### Repeater

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/repeater

Repeater enables manual manipulation and resending of individual HTTP requests.

#### Basic Workflow

```
1. Capture request in Proxy or find in Target
2. Right-click > Send to Repeater (Ctrl+R)
3. Modify request (URL, headers, body, method)
4. Click "Send" to submit
5. Analyze response in adjacent panel
6. Iterate with modifications
```

#### Request Editor Features

| Feature | Description |
|---------|-------------|
| Pretty | Formatted view with syntax highlighting |
| Raw | Exact HTTP request as sent |
| Hex | Hexadecimal view for binary data |
| Inspector | Parsed view of headers, cookies, parameters |

#### Response Analysis

| View | Use Case |
|------|----------|
| Pretty | Formatted HTML/JSON/XML |
| Raw | Exact server response |
| Render | Browser-like HTML rendering |
| Hex | Binary response analysis |

#### Tab Management

```
Organization:
- Rename: Double-click tab name
- Duplicate: Right-click > Duplicate tab
- Group: Create tab groups for related requests
- Color: Right-click > Highlight tab

Settings per tab:
- Follow redirections: Never/On-site/In-scope/Always
- Process cookies: Update cookie jar from responses
- Content-Length: Auto-update when body changes
```

#### Testing Techniques in Repeater

```http
# SQL Injection Testing
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin'--&password=anything

# Header Injection Testing
GET /admin HTTP/1.1
Host: target.com
X-Forwarded-For: 127.0.0.1
X-Original-URL: /admin/dashboard
X-Custom-IP-Authorization: 127.0.0.1

# HTTP Method Testing
PUT /api/users/1 HTTP/1.1
Host: target.com
Content-Type: application/json

{"role": "admin"}
```

---

### Intruder

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/intruder

Intruder performs automated customized attacks, including fuzzing, brute-forcing, and parameter testing.

#### Attack Types

| Type | Payload Sets | Behavior | Use Case |
|------|--------------|----------|----------|
| **Sniper** | 1 | One position at a time, sequentially | Single-parameter testing |
| **Battering Ram** | 1 | Same payload in all positions simultaneously | Same value across fields |
| **Pitchfork** | Multiple | Synchronized iteration (1-to-1 mapping) | Credential stuffing |
| **Cluster Bomb** | Multiple | All combinations (cartesian product) | Full brute force |

#### Position Markers

```
Location: Intruder > Positions

Syntax: §value§

Actions:
- Auto §: Automatically detect insertion points
- Add §: Wrap selected text in markers
- Clear §: Remove all markers

Example:
POST /login HTTP/1.1
Host: target.com

username=§admin§&password=§password123§
```

#### Payload Types

| Type | Description | Example |
|------|-------------|---------|
| Simple list | Static wordlist | admin, root, user |
| Runtime file | Load from file | /usr/share/wordlists/rockyou.txt |
| Numbers | Sequential or random | 1-10000, step 1 |
| Dates | Date format iteration | 2020-01-01 to 2024-12-31 |
| Brute forcer | Character set permutations | a-z, 4 chars |
| Null payloads | Empty/repeated requests | Rate limit testing |
| Character substitution | Leet speak variations | a->4, e->3 |
| Case modification | Upper/lower variations | admin, ADMIN, Admin |
| Username generator | Name format variations | jsmith, j.smith, john.smith |

#### Payload Processing

```
Location: Intruder > Payloads > Payload processing

Rules (applied in order):
1. Add prefix: "admin_"
2. Add suffix: "_test"
3. Match/Replace: regex substitution
4. Encode: URL, Base64, HTML
5. Hash: MD5, SHA-1, SHA-256
6. Reverse string

Example:
Input: password
After prefix: admin_password
After suffix: admin_password_test
After URL encode: admin_password_test (no change needed)
```

#### Grep Match/Extract

```
Grep - Match:
- Flag responses containing specific strings
- Identify success/failure patterns
- Example: Match "Invalid password" to find failed attempts

Grep - Extract:
- Extract data from responses using regex
- Example: Extract CSRF tokens, session IDs
- Regex: token="([a-f0-9]+)"

Grep - Payloads:
- Check if payload appears in response
- Useful for XSS reflection testing
```

#### Resource Pool Configuration

```
Location: Intruder > Resource pool (Pro)

Throttling Options:
- Maximum concurrent requests: 10
- Delay between requests: Fixed or random
- Start delay: Initial wait time
- Throttle on errors: Slow down on 5xx responses
```

---

### Decoder

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/decoder

Decoder transforms data between various encoding formats and generates hashes.

#### Encoding Operations

| Operation | Input | Output |
|-----------|-------|--------|
| URL | `<script>` | `%3Cscript%3E` |
| HTML | `<script>` | `&lt;script&gt;` |
| Base64 | `admin:password` | `YWRtaW46cGFzc3dvcmQ=` |
| Hex | `test` | `74657374` |
| ASCII Hex | `A` | `41` |
| Gzip | (binary compression) | (compressed data) |

#### Decoding Operations

```
Smart Decode:
- Automatically detects encoding
- Handles nested encodings
- Multiple decoding layers

Manual Decode:
- Select encoding type manually
- Chain multiple decodings

Example - Nested encoding:
Input: JTNDc2NyaXB0JTNFYWxlcnQoMSklM0MlMkZzY3JpcHQlM0U=
Step 1 (Base64): %3Cscript%3Ealert(1)%3C%2Fscript%3E
Step 2 (URL): <script>alert(1)</script>
```

#### Hash Functions

| Algorithm | Output Length | Notes |
|-----------|---------------|-------|
| MD5 | 128 bits (32 hex) | Legacy, not secure |
| SHA-1 | 160 bits (40 hex) | Deprecated |
| SHA-256 | 256 bits (64 hex) | Recommended |
| SHA-384 | 384 bits (96 hex) | Extended security |
| SHA-512 | 512 bits (128 hex) | Maximum security |

---

### Comparer

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/comparer

Comparer performs visual diff analysis between two HTTP requests or responses.

#### Usage Workflow

```
1. Select first item (Proxy, Repeater, etc.)
2. Right-click > Send to Comparer
3. Repeat for second item
4. Open Comparer tab
5. Select both items
6. Click "Words" or "Bytes"
```

#### Comparison Modes

| Mode | Description | Best For |
|------|-------------|----------|
| Words | Compare text, ignoring whitespace | Content analysis |
| Bytes | Exact byte-by-byte comparison | Binary data, exact changes |

#### Practical Use Cases

```
Authorization Testing:
- Compare admin vs. regular user responses
- Identify authorization bypass opportunities

Session Analysis:
- Compare before/after login responses
- Identify session-specific content

Parameter Impact:
- Compare responses with different parameter values
- Identify logic differences and hidden behavior

Attack Validation:
- Compare baseline vs. attack response
- Confirm vulnerability exploitation
```

---

### Extender

**Official Docs:** https://portswigger.net/burp/documentation/desktop/extensions

Extender manages BApp Store extensions and custom extension development.

#### BApp Store Installation

```
Location: Extensions > BApp Store

Steps:
1. Browse or search for extension
2. Click extension name for details
3. Click "Install" button
4. Extension appears in installed list

Note: Some extensions require Pro license
```

#### Manual Extension Installation

```
Location: Extensions > Installed > Add

Steps:
1. Select extension type (Java/Python/Ruby)
2. Browse to extension file
3. Click "Next" to load
4. Configure extension settings if prompted

File Types:
- Java: .jar files (native, no dependencies)
- Python: .py files (requires Jython)
- Ruby: .rb files (requires JRuby)
```

#### Jython/JRuby Configuration

```
Location: Extensions > Extension settings

Jython (Python extensions):
- Download: https://www.jython.org/download
- Configure: Set path to jython-standalone-x.x.x.jar

JRuby (Ruby extensions):
- Download: https://www.jruby.org/download
- Configure: Set path to jruby-complete-x.x.x.jar
```

#### Extension APIs

| API | Description |
|-----|-------------|
| IBurpExtender | Required interface for all extensions |
| IHttpListener | Intercept all HTTP traffic |
| IProxyListener | Intercept Proxy-specific traffic |
| IScannerCheck | Add custom scanner checks |
| IContextMenuFactory | Add right-click menu items |
| ITab | Create custom UI tabs |
| ISessionHandlingAction | Custom session handling logic |

---

## Configuration and Setup

### Initial Setup

**Official Docs:** https://portswigger.net/burp/documentation/desktop/getting-started

#### 1. Install Burp Suite

```bash
# Kali Linux (pre-installed)
burpsuite

# Manual installation
# Download from: https://portswigger.net/burp/releases
chmod +x burpsuite_community_linux_*.sh
./burpsuite_community_linux_*.sh

# Or run JAR directly (requires Java 17+)
java -jar burpsuite_community.jar
```

#### 2. Configure Browser Proxy

```
Browser Settings:
- Proxy: 127.0.0.1
- Port: 8080

Recommended Browser Extensions:
- FoxyProxy (Firefox/Chrome) - Easy proxy switching
- Burp Suite browser - Built-in Chromium with proxy configured
```

#### 3. Install CA Certificate

```
Steps:
1. Configure browser proxy to Burp
2. Navigate to http://burp in browser
3. Click "CA Certificate" to download
4. Import into browser certificate store
5. Mark as trusted for identifying websites

Firefox: Settings > Privacy > View Certificates > Import
Chrome: Settings > Privacy > Security > Manage certificates
```

### Project Configuration

**Official Docs:** https://portswigger.net/burp/documentation/desktop/projects

#### Project Types

| Type | Persistence | Use Case |
|------|-------------|----------|
| Temporary project | In-memory only | Quick testing |
| New project on disk | Saved to file | Long-term engagement |
| Open existing project | Load from file | Resume work |

#### Project Options

```
Location: Settings > Project

Key Settings:
- Target scope: Define in-scope hosts/URLs
- Session handling: Maintain authentication
- HTTP settings: Connection, TLS configuration
- Misc: Collaborator server settings
```

### User Options

```
Location: Settings > User

Categories:
- Connections: Upstream proxy, SOCKS, hostname resolution
- TLS: Client certificates, server certificate validation
- Display: Fonts, colors, HTTP message display
- Misc: Hotkeys, performance settings
```

---

## Common Workflows

### Web Application Testing Workflow

**Official Guide:** https://portswigger.net/burp/documentation/desktop/testing-workflow

#### 1. Reconnaissance Phase

```
Steps:
1. Configure target scope (Target > Scope settings)
2. Spider/crawl application with intercept off
3. Browse manually to discover dynamic content
4. Review Target > Site map for discovered content
5. Identify entry points and attack surface

Tools:
- Proxy (passive crawling)
- Target (site map organization)
- Spider (active discovery, if enabled)
```

#### 2. Mapping Phase

```
Steps:
1. Identify all input vectors
2. Map authentication/authorization mechanisms
3. Document API endpoints
4. Note session management patterns
5. Identify technology stack

Techniques:
- Review robots.txt, sitemap.xml
- Analyze JavaScript files for endpoints
- Check for API documentation
- Test for hidden parameters
```

#### 3. Vulnerability Discovery

```
Manual Testing:
1. Send requests to Repeater for manipulation
2. Test each parameter systematically
3. Check for injection vulnerabilities
4. Test authentication bypasses
5. Verify authorization controls

Automated Testing (Pro):
1. Configure scan settings
2. Run targeted active scans
3. Review findings in Dashboard
4. Verify findings manually
```

#### 4. Exploitation Phase

```
Steps:
1. Confirm vulnerabilities in Repeater
2. Develop working exploits
3. Document proof of concept
4. Assess impact and severity
5. Capture evidence

Tools:
- Repeater: Exploit development
- Intruder: Automated exploitation
- Collaborator: Out-of-band confirmation
```

### Authentication Testing

```
Workflow:
1. Capture login request in Proxy
2. Send to Repeater for analysis
3. Test credential stuffing with Intruder
4. Check session token strength with Sequencer
5. Test session fixation vulnerabilities
6. Verify logout functionality
```

### API Testing

```
Workflow:
1. Import API documentation (Swagger/OpenAPI)
2. Map all endpoints in Target
3. Test authentication mechanisms
4. Check authorization per endpoint
5. Test input validation
6. Look for IDOR vulnerabilities
```

---

## Useful Extensions

### Essential Extensions (BApp Store)

**BApp Store:** https://portswigger.net/bappstore

#### Traffic Analysis

| Extension | Purpose |
|-----------|---------|
| Logger++ | Advanced logging with filtering and export |
| Flow | Request organization and grouping |
| Request Highlighter | Color-code interesting requests |

#### Vulnerability Detection

| Extension | Purpose |
|-----------|---------|
| Active Scan++ | Enhanced scanning checks |
| Backslash Powered Scanner | Advanced injection detection |
| Param Miner | Hidden parameter discovery |
| HTTP Request Smuggler | Request smuggling detection |

#### Authorization Testing

| Extension | Purpose |
|-----------|---------|
| Autorize | Automatic authorization testing |
| AuthMatrix | Multi-role authorization matrix |
| Auto Repeater | Automatic request replay with modifications |

#### Exploitation

| Extension | Purpose |
|-----------|---------|
| Turbo Intruder | High-speed Python-based attacks |
| Hackvertor | Tag-based encoding/transformation |
| JWT Editor | JSON Web Token manipulation |
| SQLMap Integration | Direct sqlmap integration |

#### Productivity

| Extension | Purpose |
|-----------|---------|
| Copy As Python-Requests | Export requests as Python code |
| Burp Notes | Documentation and note-taking |
| Content Type Converter | Convert between JSON/XML/form |

---

## Keyboard Shortcuts

**Official Docs:** https://portswigger.net/burp/documentation/desktop/settings/hotkeys

### Navigation Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+T` | Switch to Target tab |
| `Ctrl+Shift+P` | Switch to Proxy tab |
| `Ctrl+Shift+R` | Switch to Repeater tab |
| `Ctrl+Shift+I` | Switch to Intruder tab |
| `Ctrl+Shift+D` | Switch to Dashboard tab |

### Proxy Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+F` | Forward intercepted request |
| `Ctrl+D` | Drop intercepted request |
| `Ctrl+T` | Toggle intercept on/off |

### Send To Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Send to Repeater |
| `Ctrl+I` | Send to Intruder |
| `Ctrl+S` | Send to Scanner (Pro) |

### Editor Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+U` | URL encode selection |
| `Ctrl+Shift+U` | URL decode selection |
| `Ctrl+B` | Base64 encode selection |
| `Ctrl+Shift+B` | Base64 decode selection |
| `Ctrl+H` | HTML encode selection |
| `Ctrl+Shift+H` | HTML decode selection |

### Search Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+F` | Find in message |
| `Ctrl+G` | Go to line |
| `Ctrl+Shift+F` | Search all project content |

---

## Advanced Features

### Macros and Session Handling

**Official Docs:** https://portswigger.net/burp/documentation/desktop/settings/sessions

#### Recording Macros

```
Location: Settings > Sessions > Macros

Steps:
1. Click "Add" to create new macro
2. Select requests from Proxy history
3. Configure parameter handling
4. Test macro execution
5. Save and name the macro

Use Cases:
- Login sequences
- CSRF token retrieval
- Multi-step processes
- State setup before testing
```

#### Session Handling Rules

```
Location: Settings > Sessions > Session handling rules

Components:
- Rule scope: Which tools and URLs apply
- Rule actions: What to do when triggered

Actions:
- Run a macro
- Update parameters from last response
- Use cookie jar
- Prompt for credentials
```

#### Example: Automatic CSRF Token Handling

```
1. Create macro that requests page with CSRF token
2. Configure to extract token from response
3. Create session handling rule:
   - Scope: Repeater, Intruder, Scanner
   - Action: Run macro before each request
   - Action: Update CSRF parameter from macro response
```

### Collaborator

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/collaborator (Professional only)

#### Overview

Burp Collaborator is an external service for detecting blind/out-of-band vulnerabilities.

#### Supported Protocols

| Protocol | Detection Use Case |
|----------|-------------------|
| HTTP/HTTPS | Blind SSRF, XXE callbacks |
| DNS | Data exfiltration, any external interaction |
| SMTP | Email header injection |

#### Generating Payloads

```
Location: Burp > Burp Collaborator client

Steps:
1. Open Collaborator client
2. Click "Copy to clipboard"
3. Insert payload in target request
4. Wait for interactions
5. Click "Poll now" to check results

Payload Format: xyz123abc.oastify.com
```

#### Example Payloads

```http
# Blind SSRF
POST /webhook HTTP/1.1
Content-Type: application/json

{"url": "http://xyz123.oastify.com"}

# XXE External Entity
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://xyz123.oastify.com">]>
<foo>&xxe;</foo>

# Blind Command Injection
; nslookup xyz123.oastify.com

# Blind SQL Injection (with external query)
'; EXEC master..xp_dirtree '\\xyz123.oastify.com\share'; --
```

### Invisible Proxying

**Official Docs:** https://portswigger.net/burp/documentation/desktop/tools/proxy/options#invisible-proxying

For intercepting traffic from non-proxy-aware clients:

```
Configuration:
1. Proxy > Proxy settings > Proxy listeners
2. Edit listener > Request handling
3. Enable "Support invisible proxying"

Additional Setup:
- Configure DNS or hosts file to redirect traffic
- May need to use specific certificates
- Useful for mobile apps and thick clients
```

### Upstream Proxies

```
Location: Settings > Network > Connections > Upstream proxy servers

Use Cases:
- Chain through corporate proxy
- Route through Tor
- Use with other security tools (e.g., sqlmap)

Configuration:
- Destination host: *.target.com
- Proxy host: 127.0.0.1
- Proxy port: 9050 (Tor)
```

### SOCKS Proxy

```
Location: Settings > Network > Connections > SOCKS proxy

Configuration:
- Use SOCKS proxy: Enable
- SOCKS proxy host: 127.0.0.1
- SOCKS proxy port: 9050

Use Cases:
- Route traffic through Tor
- Access internal networks via pivot
- Anonymize testing traffic
```

### Custom TLS Certificates

```
Location: Proxy > Proxy settings > Proxy listeners > Certificate

Options:
- Generate CA-signed per-host certificate (default)
- Generate self-signed certificate
- Use specific certificate (custom CA)

For Mobile/Thick Client Testing:
- Export CA certificate
- Install on target device
- Trust certificate for SSL
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| HTTPS not intercepting | Install CA certificate in browser |
| Slow performance | Increase memory: java -Xmx4g -jar burp.jar |
| Extension not loading | Check Jython/JRuby configuration |
| Cannot reach target | Check firewall, verify listener running |
| Certificate errors | Regenerate CA, clear browser cert cache |

### Performance Optimization

```
Memory Settings:
- Edit burp launcher or use: java -Xmx4g -jar burpsuite.jar

Reduce History Size:
- Project options > Misc > Set maximum items

Disable Unused Features:
- Turn off live scanning if not needed
- Disable extensions not in use

Filter Traffic:
- Use scope to limit captured traffic
- Filter by file extension in intercept rules
```

---

## Additional Resources

### Learning Resources

| Resource | URL |
|----------|-----|
| Web Security Academy | https://portswigger.net/web-security |
| Methodology Guide | https://portswigger.net/burp/documentation/desktop/testing-workflow |
| Video Tutorials | https://portswigger.net/burp/documentation/desktop/tutorials |

### Reference Materials

| Resource | URL |
|----------|-----|
| Scanner Issue Definitions | https://portswigger.net/kb/issues |
| Burp Suite Changelog | https://portswigger.net/burp/releases |
| Enterprise Documentation | https://portswigger.net/burp/documentation/enterprise |
