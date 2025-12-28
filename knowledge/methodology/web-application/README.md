---
title: Web Application Testing
category: methodology
tags:
  - web
  - owasp
  - penetration-testing
  - methodology
  - reconnaissance
  - exploitation
last_updated: 2025-12-27
---

# Web Application Testing Methodology

## Overview

Web application penetration testing is a systematic approach to identifying security vulnerabilities in web-based applications. This methodology follows industry standards including OWASP Testing Guide, PTES, and OSSTMM.

## Testing Phases

### 1. Information Gathering
- Technology fingerprinting (Wappalyzer, WhatWeb)
- Directory/file enumeration
- Subdomain discovery
- API endpoint mapping
- Source code analysis (if available)

### 2. Configuration and Deployment Testing
- Network/Infrastructure configuration
- Application platform configuration
- File extension handling
- HTTP methods testing
- Security headers analysis

### 3. Identity Management Testing
- User registration process
- Account provisioning
- Account enumeration
- Weak username/password policies

### 4. Authentication Testing
- Default credentials
- Weak lockout mechanisms
- Bypass authentication
- Password reset flaws
- Multi-factor authentication bypass

### 5. Authorization Testing
- Directory traversal
- Privilege escalation
- Insecure Direct Object References (IDOR)
- Access control bypass

### 6. Session Management Testing
- Session token analysis
- Cookie attributes
- Session fixation
- CSRF vulnerabilities

### 7. Input Validation Testing
- [SQL Injection](sql-injection.md)
- [Cross-Site Scripting (XSS)](xss.md)
- Command injection
- LDAP/XPath/XML injection
- Server-Side Template Injection (SSTI)
- File inclusion vulnerabilities

### 8. Error Handling Testing
- Error message analysis
- Stack trace exposure
- Sensitive information disclosure

### 9. Cryptography Testing
- Weak SSL/TLS configuration
- Sensitive data encryption
- Weak cryptographic algorithms

### 10. Business Logic Testing
- Workflow bypass
- Data validation flaws
- Race conditions
- Price manipulation

## OWASP Top 10 (2021)

| Rank | Vulnerability | Description |
|------|--------------|-------------|
| A01 | Broken Access Control | Restrictions not properly enforced |
| A02 | Cryptographic Failures | Sensitive data exposure |
| A03 | Injection | SQL, NoSQL, OS, LDAP injection |
| A04 | Insecure Design | Missing security controls |
| A05 | Security Misconfiguration | Default configs, verbose errors |
| A06 | Vulnerable Components | Outdated libraries/frameworks |
| A07 | Authentication Failures | Weak authentication mechanisms |
| A08 | Software/Data Integrity | Insecure CI/CD, deserialization |
| A09 | Security Logging Failures | Insufficient logging/monitoring |
| A10 | SSRF | Server-Side Request Forgery |

## Recommended Tools

### Reconnaissance
| Tool | Purpose |
|------|---------|
| Burp Suite | Web proxy and scanner |
| OWASP ZAP | Open-source web scanner |
| Nikto | Web server scanner |
| WhatWeb | Technology fingerprinting |
| Wappalyzer | Technology detection |

### Directory/Content Discovery
| Tool | Purpose |
|------|---------|
| Gobuster | Directory/DNS enumeration |
| Feroxbuster | Recursive content discovery |
| ffuf | Fast web fuzzer |
| dirsearch | Web path scanner |

### Vulnerability Scanning
| Tool | Purpose |
|------|---------|
| SQLMap | SQL injection automation |
| XSSer | XSS detection and exploitation |
| Commix | Command injection exploitation |
| tplmap | SSTI detection and exploitation |

### API Testing
| Tool | Purpose |
|------|---------|
| Postman | API development and testing |
| Insomnia | REST/GraphQL client |
| Arjun | HTTP parameter discovery |

## Quick Reference Commands

### Technology Fingerprinting
```bash
# WhatWeb
whatweb -a 3 http://target.com

# Wappalyzer CLI
wappalyzer http://target.com
```

### Directory Enumeration
```bash
# Gobuster
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt

# Feroxbuster
feroxbuster -u http://target.com -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
```

### Vulnerability Scanning
```bash
# Nikto
nikto -h http://target.com

# OWASP ZAP (headless)
zap-cli quick-scan http://target.com
```

## Security Headers to Check

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=()
```

## Testing Checklist

- [ ] Information gathering complete
- [ ] Technology stack identified
- [ ] Directory enumeration performed
- [ ] Authentication mechanisms tested
- [ ] Authorization controls tested
- [ ] Input validation vulnerabilities tested
- [ ] Session management tested
- [ ] Business logic tested
- [ ] API endpoints tested
- [ ] Security headers reviewed
- [ ] SSL/TLS configuration checked

## Related Documentation

- [SQL Injection](sql-injection.md) - Database injection attacks
- [Cross-Site Scripting](xss.md) - Client-side injection attacks
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

## References

- [OWASP Testing Guide v4.2](https://owasp.org/www-project-web-security-testing-guide/)
- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [HackTricks Web Pentesting](https://book.hacktricks.xyz/pentesting-web/)
