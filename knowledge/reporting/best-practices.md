---
title: Reporting Best Practices
category: reporting
tags:
  - documentation
  - pentest-reporting
  - professional-writing
  - evidence
  - cvss
last_updated: 2025-12-27
---

# Reporting Best Practices

## Writing Quality Guidelines

### Clarity
- Use active voice: "The attacker can execute commands" not "Commands can be executed"
- Avoid jargon when possible; define technical terms for mixed audiences
- One idea per paragraph; one finding per section
- Use bullet points for lists of items or steps

### Conciseness
- Eliminate filler words (very, really, basically, essentially)
- Get to the point quickly in executive summaries
- Technical details belong in technical sections, not summaries
- Remove redundant explanations

### Actionable Content
- Every finding must include clear remediation steps
- Prioritize findings by business impact and exploitability
- Provide specific, implementable recommendations
- Include references to vendor documentation or security standards

## Finding Documentation Standards

### Required Elements
1. **Title**: Clear, descriptive vulnerability name
2. **Severity**: CVSS score with vector string
3. **Affected Systems**: Specific hosts, URLs, or components
4. **Description**: What the vulnerability is and why it matters
5. **Evidence**: Screenshots, logs, request/response pairs
6. **Reproduction Steps**: Numbered steps anyone can follow
7. **Impact**: Business and technical consequences
8. **Remediation**: Specific fix with implementation guidance
9. **References**: CVEs, vendor advisories, OWASP links

### Evidence Requirements
- Timestamp all evidence
- Include full context (URLs, IP addresses, usernames)
- Redact sensitive data consistently (passwords, PII)
- Maintain chain of custody for legal/compliance work

## Severity Rating Guidelines (CVSS 3.1)

### Score Ranges
| Severity | CVSS Score | Color Code |
|----------|------------|------------|
| Critical | 9.0 - 10.0 | Red        |
| High     | 7.0 - 8.9  | Orange     |
| Medium   | 4.0 - 6.9  | Yellow     |
| Low      | 0.1 - 3.9  | Green      |
| Info     | 0.0        | Blue       |

### CVSS Vector Components
- **Attack Vector (AV)**: Network, Adjacent, Local, Physical
- **Attack Complexity (AC)**: Low, High
- **Privileges Required (PR)**: None, Low, High
- **User Interaction (UI)**: None, Required
- **Scope (S)**: Unchanged, Changed
- **Confidentiality (C)**: None, Low, High
- **Integrity (I)**: None, Low, High
- **Availability (A)**: None, Low, High

### Severity Justification
- Always explain your scoring rationale
- Consider environmental factors for client context
- Document any scoring adjustments and reasoning

## Executive Summary Writing Tips

### Structure
1. **Engagement Overview**: Scope, dates, methodology (2-3 sentences)
2. **Key Findings**: Top 3-5 critical/high findings in plain language
3. **Risk Summary**: Overall security posture assessment
4. **Priority Recommendations**: Top 3 actions to take immediately

### Tone and Language
- Write for non-technical executives
- Focus on business impact, not technical details
- Use analogies to explain complex concepts
- Quantify risk where possible (e.g., "affects 10,000 user accounts")

### Length
- Keep to 1-2 pages maximum
- Use graphics/charts for quick comprehension
- Include a risk rating summary table

## Technical Writing Tips

### Code and Commands
- Use monospace formatting for all code/commands
- Include full commands, not abbreviated versions
- Show expected output where relevant
- Note any environment-specific modifications needed

### Request/Response Documentation
```
POST /api/login HTTP/1.1
Host: target.example.com
Content-Type: application/json

{"username": "admin' OR '1'='1", "password": "test"}

Response: HTTP/1.1 200 OK
{"status": "authenticated", "user": "admin"}
```

### Technical Accuracy
- Verify all commands work before including
- Test reproduction steps on a clean environment
- Include version numbers for tools and systems
- Note any prerequisites or dependencies

## Evidence Capture Best Practices

### Screenshots
- Capture full window with URL bar visible
- Highlight relevant portions with annotations
- Include timestamp in filename: `finding01_sqli_2025-12-27.png`
- Use consistent naming convention throughout

### Logs and Output
- Capture complete output, not just relevant lines
- Preserve original formatting
- Include command that generated the output
- Save raw logs separately from report excerpts

### Video Evidence
- Use for complex multi-step exploits
- Keep under 2 minutes when possible
- Add narration or captions explaining actions
- Provide both video and written steps

### Tool Output
- Save raw tool output to separate files
- Include tool version and command line options
- Redact sensitive data before sharing
- Reference output files in findings

## Remediation Recommendation Guidelines

### Structure
1. **Immediate Actions**: Quick fixes to reduce risk now
2. **Short-term Fixes**: Patches and configuration changes
3. **Long-term Solutions**: Architectural improvements

### Quality Recommendations
- Be specific: "Update Apache to version 2.4.58" not "Update software"
- Provide multiple options when appropriate
- Include effort estimates (low/medium/high)
- Reference vendor documentation or guides
- Consider operational impact of fixes

### Verification Steps
- Include steps to verify remediation worked
- Suggest retesting timeline
- Note any dependencies between fixes

## Report Review Checklist

- [ ] All findings have complete required elements
- [ ] CVSS scores are accurate and justified
- [ ] Evidence supports all claims
- [ ] Reproduction steps are tested and accurate
- [ ] Executive summary is understandable by non-technical readers
- [ ] Remediation steps are specific and actionable
- [ ] Consistent formatting throughout
- [ ] No sensitive data exposed (passwords, keys, PII)
- [ ] Spell check and grammar review complete
- [ ] Report metadata (dates, version, author) is accurate
