---
title: Penetration Testing Report Writing
category: reporting
tags:
  - documentation
  - reporting
  - deliverables
  - communication
  - findings
last_updated: 2025-12-27
---

# Penetration Testing Report Writing

## Table of Contents

- [Overview](#overview)
- [Report Types](#report-types)
  - [Executive Summary](#executive-summary)
  - [Technical Report](#technical-report)
  - [Vulnerability Report](#vulnerability-report)
  - [Compliance Report](#compliance-report)
- [Report Components](#report-components)
  - [Cover Page](#cover-page)
  - [Scope and Methodology](#scope-and-methodology)
  - [Finding Severity Ratings](#finding-severity-ratings)
  - [Evidence Documentation](#evidence-documentation)
  - [Remediation Recommendations](#remediation-recommendations)
- [Templates and Findings](#templates-and-findings)
- [Best Practices](#best-practices)

## Overview

The penetration testing report is the primary deliverable of any engagement. It transforms technical findings into actionable intelligence for stakeholders at all levels. A well-written report:

- Justifies the security investment to leadership
- Provides clear remediation guidance for technical teams
- Documents evidence for compliance and audit purposes
- Serves as a baseline for measuring security improvements

The report quality often determines whether vulnerabilities get fixed. Poor documentation leads to misunderstandings, delayed remediation, and repeated findings in future assessments.

## Report Types

### Executive Summary

**Audience:** C-suite executives, board members, management

**Purpose:** High-level overview of security posture and business risk

**Content:**
- 1-2 page maximum
- Business impact focus, not technical details
- Risk ratings using simple terminology (Critical/High/Medium/Low)
- Key statistics (total findings, critical issues, attack paths)
- Strategic recommendations with cost/benefit context
- Comparison to industry benchmarks when available

### Technical Report

**Audience:** IT administrators, security teams, SOC analysts

**Purpose:** Detailed technical findings with reproduction steps

**Content:**
- Complete methodology documentation
- Detailed finding descriptions with technical context
- Step-by-step reproduction instructions
- Tool outputs, commands, and configurations
- Network diagrams and attack paths
- Specific remediation steps with configuration examples

### Vulnerability Report

**Audience:** Development teams, DevOps engineers

**Purpose:** Actionable findings for code and configuration fixes

**Content:**
- Vulnerability details mapped to affected systems/applications
- Code snippets showing vulnerable patterns
- Secure coding alternatives and fixes
- References to CWE, OWASP, and secure development guides
- Integration points for ticketing systems (Jira, GitHub Issues)

### Compliance Report

**Audience:** Auditors, compliance officers, legal teams

**Purpose:** Demonstrate security control effectiveness

**Content:**
- Mapping findings to compliance frameworks (PCI-DSS, HIPAA, SOC2)
- Control testing results (pass/fail/partial)
- Evidence of due diligence
- Gap analysis against requirements
- Attestation language and formal declarations

## Report Components

### Cover Page

Essential elements:
- Client organization name and logo
- Report title and engagement type
- Assessment date range
- Report version and classification level
- Assessor organization and contact information
- Confidentiality statement

### Scope and Methodology

Document clearly:
- In-scope IP ranges, domains, and applications
- Out-of-scope systems and restrictions
- Testing methodology (PTES, OWASP, NIST)
- Tools and techniques employed
- Testing limitations and constraints
- Rules of engagement summary

### Finding Severity Ratings

Use CVSS v3.1 for standardized severity scoring:

| Severity | CVSS Score | Description |
|----------|------------|-------------|
| Critical | 9.0 - 10.0 | Immediate exploitation risk, full system compromise |
| High | 7.0 - 8.9 | Significant risk, requires prompt remediation |
| Medium | 4.0 - 6.9 | Moderate risk, should be addressed in normal cycle |
| Low | 0.1 - 3.9 | Minor risk, fix when convenient |
| Informational | 0.0 | Best practice recommendations, no direct risk |

For each finding, document:
- CVSS base score with vector string
- Environmental factors affecting severity
- Exploitability in the specific context
- Business impact assessment

### Evidence Documentation

Evidence requirements:
- Screenshots with timestamps and context
- Tool output logs (sanitized of sensitive data)
- Request/response captures for web vulnerabilities
- Network packet captures when relevant
- Video recordings for complex attack chains

Evidence best practices:
- Blur or redact sensitive information (passwords, PII)
- Use consistent naming conventions
- Include captions explaining what evidence demonstrates
- Maintain chain of custody documentation

### Remediation Recommendations

Effective remediation guidance includes:
- Specific fix with configuration examples or code
- Short-term mitigations if full fix requires time
- Prioritization based on risk and effort
- References to vendor documentation
- Verification steps to confirm fix effectiveness
- Timeline recommendations based on severity

## Templates and Findings

Standardized resources are available in subdirectories:

- **[templates/](./templates/)** - Report templates, finding templates, cover pages
- **[findings/](./findings/)** - Reusable finding descriptions organized by category

Using templates ensures consistency across engagements and reduces report writing time while maintaining quality.

## Best Practices

**Writing Quality:**
- Write for your audience; adjust technical depth accordingly
- Use active voice and clear, concise language
- Avoid jargon when simpler terms suffice
- Have reports peer-reviewed before delivery

**Finding Documentation:**
- One finding per vulnerability class per system
- Include both technical and business impact
- Provide actionable, specific remediation steps
- Reference authoritative sources (CVE, CWE, vendor advisories)

**Process:**
- Document findings during testing, not after
- Use consistent templates across all engagements
- Version control reports and track changes
- Deliver reports securely (encrypted, verified recipients)

**Quality Assurance:**
- Verify all reproduction steps work
- Confirm evidence matches finding descriptions
- Check CVSS scores against calculator
- Proofread for spelling, grammar, and formatting
