---
title: Finding Documentation
category: reporting
tags:
  - findings
  - vulnerabilities
  - documentation
  - cvss
last_updated: 2025-12-27
---

# Finding Documentation

Guidelines for documenting individual security findings in penetration test reports.

## Finding Template Structure

Each finding should include the following sections:

```markdown
## [FINDING-ID]: [Vulnerability Title]

**Severity**: [Critical/High/Medium/Low/Info]
**CVSS Score**: [X.X] ([Vector String])
**Affected Systems**: [Host/URL/Component]
**Status**: [New/Retest/Remediated]

### Description
[What the vulnerability is and why it matters]

### Evidence
[Screenshots, logs, request/response pairs]

### Reproduction Steps
1. [Step one]
2. [Step two]
3. [Observe result]

### Impact
[Business and technical consequences of exploitation]

### Remediation
[Specific steps to fix the vulnerability]

### References
- [CVE/CWE/OWASP links]
```

## Severity Levels

| Level | CVSS | Criteria |
|-------|------|----------|
| **Critical** | 9.0-10.0 | Remote code execution, authentication bypass, data breach |
| **High** | 7.0-8.9 | Privilege escalation, significant data exposure |
| **Medium** | 4.0-6.9 | Limited data exposure, requires user interaction |
| **Low** | 0.1-3.9 | Information disclosure, minor misconfigurations |
| **Info** | 0.0 | Best practice recommendations, observations |

## Example Finding

```markdown
## VULN-001: SQL Injection in Login Form

**Severity**: Critical
**CVSS Score**: 9.8 (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
**Affected Systems**: https://app.example.com/api/login
**Status**: New

### Description
The login endpoint is vulnerable to SQL injection through the username
parameter. An unauthenticated attacker can extract database contents,
bypass authentication, or execute commands on the database server.

### Evidence
Request:
POST /api/login HTTP/1.1
Host: app.example.com
Content-Type: application/json

{"username": "admin'--", "password": "anything"}

Response:
HTTP/1.1 200 OK
{"authenticated": true, "user": "admin", "role": "administrator"}

### Reproduction Steps
1. Navigate to https://app.example.com/login
2. Enter `admin'--` as the username
3. Enter any value for password
4. Click "Login"
5. Observe successful authentication as admin

### Impact
- Complete authentication bypass
- Full database read/write access
- Potential remote code execution via xp_cmdshell
- Affects all 50,000 user accounts

### Remediation
1. Implement parameterized queries for all database operations
2. Use an ORM with built-in SQL injection protection
3. Apply input validation and sanitization
4. Deploy a web application firewall as defense-in-depth

### References
- CWE-89: SQL Injection
- OWASP SQL Injection Prevention Cheat Sheet
```

## Finding ID Convention

Use consistent prefixes for finding IDs:

- `VULN-XXX`: Confirmed vulnerabilities
- `WEAK-XXX`: Weaknesses/misconfigurations
- `INFO-XXX`: Informational findings
- `RETEST-XXX`: Remediation verification

## Related Documentation

- [Best Practices](../best-practices.md) - Writing guidelines
- [Templates](../templates/README.md) - Report templates
