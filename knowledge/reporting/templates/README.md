---
title: Report Templates
category: reporting
tags:
  - templates
  - pentest-reporting
  - documentation
last_updated: 2025-12-27
---

# Report Templates

This directory contains templates for penetration testing deliverables and documentation.

## Available Templates

### Penetration Test Reports

| Template | Description | Use Case |
|----------|-------------|----------|
| `full-report.md` | Complete pentest report | Standard engagements |
| `executive-summary.md` | Standalone executive summary | Board presentations |
| `technical-report.md` | Technical-only report | Security team handoff |

### Finding Templates

| Template | Description | Use Case |
|----------|-------------|----------|
| `finding-template.md` | Single vulnerability finding | Per-finding documentation |
| `finding-critical.md` | Critical severity finding | Urgent issues |
| `finding-info.md` | Informational finding | Observations, best practices |

### Specialized Reports

| Template | Description | Use Case |
|----------|-------------|----------|
| `web-app-report.md` | Web application assessment | OWASP-focused testing |
| `network-report.md` | Network penetration test | Infrastructure testing |
| `ad-report.md` | Active Directory assessment | Domain security reviews |
| `red-team-report.md` | Red team engagement | Adversary simulation |

### Supporting Documents

| Template | Description | Use Case |
|----------|-------------|----------|
| `rules-of-engagement.md` | ROE template | Pre-engagement |
| `status-update.md` | Progress report | During engagement |
| `retest-report.md` | Remediation verification | Post-remediation |
| `debrief-slides.md` | Presentation outline | Client meetings |

## Template Usage

1. Copy the appropriate template to your working directory
2. Fill in all bracketed placeholder fields `[PLACEHOLDER]`
3. Remove any sections not applicable to the engagement
4. Add engagement-specific content and evidence
5. Review against the checklist in `best-practices.md`

## Customization

Templates follow a modular structure. Common customizations:

- **Branding**: Update header/footer with company logo
- **Sections**: Add or remove sections based on scope
- **Severity Scale**: Adjust rating scale to client requirements
- **Compliance**: Add framework-specific sections (PCI, HIPAA, etc.)

## Related Documentation

- [Best Practices](../best-practices.md) - Writing and documentation standards
- [Findings](../findings/README.md) - Finding documentation guidelines
