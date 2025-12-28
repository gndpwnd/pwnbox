# PWNBOX Documentation Roadmap

## Table of Contents

- [Overview](#overview)
- [Documentation Standards](#documentation-standards)
- [Directory Structure](#directory-structure)
- [Phase 1: Documentation Refactoring](#phase-1-documentation-refactoring)
- [Phase 2: Tool Research Expansion](#phase-2-tool-research-expansion)
- [Phase 3: Automation Integration](#phase-3-automation-integration)
- [Phase 4: Methodology Documentation](#phase-4-methodology-documentation)
- [Phase 5: Reporting Templates](#phase-5-reporting-templates)
- [Phase 6: Web Application Testing](#phase-6-web-application-testing)
- [Phase 7: Evasion Techniques](#phase-7-evasion-techniques)
- [Phase 8: Cloud and Wireless](#phase-8-cloud-and-wireless)
- [Gap Analysis](#gap-analysis)
- [ResearchHub Integration](#researchhub-integration)
- [Cross-Repository Integration](#cross-repository-integration)
- [Progress Tracking](#progress-tracking)

---

## Overview

This roadmap outlines the documentation strategy for the PWNBOX knowledge base. The goal is to create comprehensive, well-organized documentation for:

1. **Tools** - 31+ penetration testing tools with usage examples
2. **Methodology** - Complete pentesting process from recon to reporting
3. **Techniques** - Attack techniques organized by platform and category
4. **Reporting** - Templates and best practices for professional reports

### Guiding Principles

1. **Every folder must have a README.md** - Serves as a table of contents for that directory
2. **Split large files into subtopics** - One document per major subtopic for better navigation
3. **Consistent structure** - All documentation follows the same organization pattern
4. **Automation-friendly** - Leverage ResearchHub and ~/system_docs/ scripts
5. **Platform coverage** - Windows, Linux, macOS, network devices, cloud

---

## Documentation Standards

### README.md Requirements

Every README.md file must include:

1. **YAML Frontmatter** - Metadata for semantic search
2. **Table of Contents** - Links to all sections and related files
3. **Brief Overview** - 2-3 sentence description
4. **Directory Contents** - List of files/folders in that directory

#### README Template (Tool Folders)

```markdown
---
title: "tool-name"
category: "tool"
subcategory: "reconnaissance|enumeration|exploitation|etc"
tags: ["tag1", "tag2"]
last_updated: "YYYY-MM-DD"
---

# Tool Name

> Brief one-line description of the tool

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Documentation Files](#documentation-files)
```

### File Organization Per Tool

| File | Required | Description |
|------|----------|-------------|
| `README.md` | Yes | Overview and table of contents |
| `official_docs.md` | Yes | Extracted official documentation |
| `options.md` | Recommended | CLI options and flags reference |
| `examples.md` | Recommended | Practical usage examples |
| `techniques.md` | Optional | Attack techniques and methodologies |

### Large File Splitting Rules

When a documentation file exceeds **500 lines**, split it into subtopic files:

- Keep README.md as the table of contents (under 200 lines)
- Create separate files for each major section
- Link all subtopic files from the README

---

## Directory Structure

### Target Structure

```
knowledge/
├── README.md                    # Knowledge base overview + TOC
├── tools/                       # Tool documentation (31+ tools)
│   ├── README.md               # Tools index by category
│   └── [tool-name]/            # Individual tool folders
├── methodology/                 # Pentesting process documentation
│   ├── README.md               # Methodology overview
│   ├── reconnaissance/         # Passive & active recon
│   ├── enumeration/            # Service & system enumeration
│   ├── exploitation/           # Initial access techniques
│   ├── post-exploitation/      # After initial access
│   ├── persistence/            # Maintaining access
│   ├── privilege-escalation/   # Windows & Linux privesc
│   ├── lateral-movement/       # Moving through network
│   ├── exfiltration/           # Data extraction
│   └── cleanup/                # Covering tracks
├── techniques/                  # Attack technique documentation
│   ├── README.md               # Techniques index
│   ├── windows/                # Windows-specific attacks
│   ├── linux/                  # Linux-specific attacks
│   ├── active-directory/       # AD attack chains
│   ├── network/                # Network-level attacks
│   └── web/                    # Web application attacks
├── reporting/                   # Report templates & guides
│   ├── README.md               # Reporting overview
│   ├── templates/              # Report templates
│   ├── findings/               # Finding write-up templates
│   └── best-practices.md       # Reporting best practices
└── references/                  # Quick reference sheets
    └── README.md               # Cheat sheets and quick refs
```

---

## Phase 1: Documentation Refactoring

**Status: COMPLETE**

**Goal:** Reorganize existing documentation with proper structure and TOCs.

### Tasks

- [x] Create `knowledge/README.md` with knowledge base overview
- [x] Create `knowledge/tools/README.md` with tool index by category
- [x] Refactor each tool README.md (31/31 - 100%)
- [x] Split large files (socat: 4306 → 6 files)

---

## Phase 2: Tool Research Expansion

**Status: IN PROGRESS**

**Goal:** Enhance tool documentation with comprehensive research.

### Research Sources

1. **Man pages** - `man <tool>` output
2. **Help output** - `<tool> --help` or `-h`
3. **Official websites** - Tool documentation sites
4. **GitHub repos** - READMEs, wikis, issues
5. **ResearchHub** - Automated web and academic research

### Research Checklist Per Tool

- [x] Command-line arguments (complete reference)
- [ ] Configuration files
- [x] Common use cases and examples
- [ ] Integration with other tools
- [ ] Troubleshooting common issues

---

## Phase 3: Automation Integration

**Status: IN PROGRESS**

**Goal:** Leverage automation scripts for research.

### Available Scripts (~/system_docs/scripts/)

| Script | Purpose |
|--------|---------|
| `pwnbox_doc_enhancer.py` | Status reports, TOC, doc extraction |
| `extract_manpages.py` | Extract man pages for tools |
| `comprehensive_doc_downloader.py` | Fetch official docs |

### Commands

```bash
# Status report
python3 ~/system_docs/scripts/pwnbox_doc_enhancer.py --status

# List missing docs
python3 ~/system_docs/scripts/pwnbox_doc_enhancer.py --missing

# Extract documentation
python3 ~/system_docs/scripts/pwnbox_doc_enhancer.py --extract-docs
```

---

## Phase 4: Methodology Documentation

**Status: NOT STARTED**

**Goal:** Document the complete penetration testing process.

### Pentesting Phases

| Phase | Description | Key Activities |
|-------|-------------|----------------|
| **1. Reconnaissance** | Information gathering | OSINT, passive recon, target profiling |
| **2. Enumeration** | Active discovery | Port scanning, service detection, user enum |
| **3. Exploitation** | Initial access | Vulnerability exploitation, credential attacks |
| **4. Post-Exploitation** | After foothold | System profiling, credential harvesting |
| **5. Persistence** | Maintain access | Backdoors, scheduled tasks, services |
| **6. Privilege Escalation** | Elevate privileges | Windows/Linux privesc techniques |
| **7. Lateral Movement** | Spread through network | Pass-the-hash, RDP, WMI |
| **8. Exfiltration** | Extract data | Data staging, covert channels |
| **9. Cleanup** | Cover tracks | Log clearing, artifact removal |
| **10. Reporting** | Document findings | Executive summary, technical details |

### Platform Coverage

- **Windows** - Desktop, Server, Active Directory
- **Linux** - Ubuntu, RHEL, Debian, Kali
- **macOS** - Desktop security
- **Network** - Routers, switches, firewalls
- **Cloud** - AWS, Azure, GCP
- **Containers** - Docker, Kubernetes

### Methodology Tasks

- [ ] Create `methodology/README.md` with phase overview
- [ ] Document each phase with techniques and tools
- [ ] Map tools to methodology phases
- [ ] Add platform-specific variations
- [ ] Include common attack chains

---

## Phase 5: Reporting Templates

**Status: NOT STARTED**

**Goal:** Create professional pentest reporting resources.

### Report Types

| Type | Audience | Focus |
|------|----------|-------|
| **Executive Summary** | C-level, Management | Business risk, impact |
| **Technical Report** | IT/Security teams | Detailed findings, remediation |
| **Vulnerability Report** | Developers | Specific issues, code fixes |
| **Compliance Report** | Auditors | Control gaps, evidence |

### Report Components

1. **Cover Page** - Client, dates, classification
2. **Executive Summary** - High-level findings, risk rating
3. **Scope & Methodology** - What was tested, how
4. **Findings Summary** - Table of all findings by severity
5. **Detailed Findings** - Each finding with evidence
6. **Remediation Roadmap** - Prioritized fix recommendations
7. **Appendices** - Raw data, tool output, evidence

### Finding Template

```markdown
## Finding: [Title]

**Severity:** Critical/High/Medium/Low/Informational
**CVSS Score:** X.X
**CWE:** CWE-XXX
**Affected Systems:** [list]

### Description
[What the vulnerability is]

### Impact
[Business/technical impact if exploited]

### Evidence
[Screenshots, code snippets, proof of concept]

### Remediation
[How to fix it, with specific steps]

### References
[CVE, vendor advisories, documentation]
```

### Reporting Tasks

- [ ] Create `reporting/README.md` with overview
- [ ] Develop executive summary template
- [ ] Create technical report template
- [ ] Build finding write-up templates
- [ ] Document CVSS scoring guide
- [ ] Add screenshot and evidence best practices

---

## Phase 6: Web Application Testing

**Status: NOT STARTED**

**Goal:** Comprehensive web application attack methodology based on OWASP and OSCP requirements.

### Topics to Cover

| Category | Techniques | Priority |
|----------|------------|----------|
| **SQL Injection** | In-band, Blind, Out-of-band, Second-order | **CRITICAL** |
| **Cross-Site Scripting** | Reflected, Stored, DOM-based | **CRITICAL** |
| **File Inclusion** | LFI, RFI, Path Traversal | **CRITICAL** |
| **Command Injection** | OS command injection, argument injection | **CRITICAL** |
| **File Upload** | Bypass techniques, web shells | HIGH |
| **SSRF** | Server-side request forgery | HIGH |
| **XXE** | XML external entity attacks | MEDIUM |
| **Deserialization** | PHP, Java, .NET object injection | MEDIUM |
| **Authentication Bypass** | Brute force, default creds, logic flaws | HIGH |

### Tools to Document

- **Burp Suite** - Complete documentation
- **ffuf** - Web fuzzing
- **sqlmap** - SQL injection automation
- **nikto** - Web server scanner
- **wpscan** - WordPress scanner

### Tasks

- [ ] Create `methodology/web-application/README.md`
- [ ] Document SQL injection techniques
- [ ] Document XSS techniques
- [ ] Document file inclusion attacks
- [ ] Add Burp Suite tool documentation
- [ ] Add ffuf and sqlmap documentation

---

## Phase 7: Evasion Techniques

**Status: NOT STARTED**

**Goal:** Document AV/EDR evasion for red team operations.

### Topics to Cover

| Technique | Platform | Priority |
|-----------|----------|----------|
| **AMSI Bypass** | Windows | **CRITICAL** |
| **AppLocker Bypass** | Windows | HIGH |
| **Defender Evasion** | Windows | HIGH |
| **ETW Patching** | Windows | MEDIUM |
| **Process Injection** | Windows | MEDIUM |
| **CLM Bypass** | PowerShell | MEDIUM |
| **LOLBAS** | Windows | HIGH |

### Tasks

- [ ] Create `techniques/evasion/README.md`
- [ ] Document AMSI bypass techniques
- [ ] Document AppLocker bypass
- [ ] Create LOLBAS reference guide

---

## Phase 8: Cloud and Wireless

**Status: NOT STARTED**

**Goal:** Extend coverage to cloud and wireless pentesting.

### Cloud Pentesting

| Platform | Topics | Priority |
|----------|--------|----------|
| **AWS** | S3 misconfig, IAM abuse, Lambda | HIGH |
| **Azure** | Azure AD, Managed Identity, Storage | HIGH |
| **GCP** | GCS, IAM, Compute | MEDIUM |
| **Kubernetes** | RBAC, secrets, escape | MEDIUM |

### Wireless Pentesting

| Topic | Tools | Priority |
|-------|-------|----------|
| WPA/WPA2 Cracking | Aircrack-ng, hashcat | MEDIUM |
| Evil Twin | hostapd, dnsmasq | MEDIUM |
| Deauth Attacks | aireplay-ng | LOW |
| WPS Attacks | reaver, bully | LOW |

### Tasks

- [ ] Create `methodology/cloud/README.md`
- [ ] Create `methodology/wireless/README.md`
- [ ] Document AWS attack patterns
- [ ] Document Azure AD attacks

---

## Gap Analysis

**Status: COMPLETE**

Based on comprehensive research of certifications (OSCP, CEH, PNPT, CRTP, CRTE, GPEN) and frameworks (PTES, OWASP, MITRE ATT&CK), a detailed gap analysis has been created.

See: [GAP_ANALYSIS.md](knowledge/GAP_ANALYSIS.md)

### Research Completed

| Research Area | File | Lines |
|---------------|------|-------|
| OSCP Curriculum | `OSCP_CURRICULUM_REFERENCE.md` | ~800 |
| CEH Curriculum | `certifications/CEH-curriculum.md` | ~600 |
| Cert Comparison | `certifications-comparison.md` | ~500 |
| Frameworks | `methodology/frameworks.md` | ~1,200 |
| AD Attacks | `techniques/active-directory/*.md` | ~3,000 |
| Windows Privesc | `techniques/windows/privilege-escalation.md` | ~800 |
| Linux Privesc | `techniques/linux/privilege-escalation.md` | ~1,000 |

### Critical Gaps Identified

1. **Web Application Testing** - No OWASP methodology
2. **Burp Suite** - Missing tool documentation
3. **AV/EDR Evasion** - No evasion techniques
4. **Cloud Pentesting** - No AWS/Azure coverage
5. **Missing Tools** - ffuf, sqlmap, Rubeus, Certify

---

## ResearchHub Integration

**Status: NEW**

**Goal:** Leverage ResearchHub for automated research instead of manual agent spawning.

### What is ResearchHub?

ResearchHub (~/denoiseai/researchhub/) provides:
- **Web search** via SearxNG metasearch
- **Academic search** (arXiv, Semantic Scholar, PubMed)
- **Deep research** with multi-phase investigation
- **Gap analysis** to identify missing documentation
- **Documentation generation** to fill gaps

### Using ResearchHub for Pwnbox

```bash
# Start ResearchHub
cd ~/denoiseai/researchhub
python main.py dashboard --watch

# Or use MCP API
uvicorn main:app --host 0.0.0.0 --port 8001
```

### Research Workflow

1. **Identify gaps** using pwnbox_doc_enhancer.py --missing
2. **Use ResearchHub** for deep research on topics:
   ```bash
   # Via MCP API
   curl -X POST http://localhost:8001/mcp/execute \
     -H "Content-Type: application/json" \
     -d '{
       "tool": "deep_research",
       "params": {
         "topic": "Windows privilege escalation techniques",
         "depth": "comprehensive",
         "output_format": "markdown"
       }
     }'
   ```
3. **Review output** and integrate into knowledge base
4. **Validate** with pwnbox_doc_enhancer.py --status

### ResearchHub Tools for Pwnbox

| Tool | Use Case |
|------|----------|
| `web_search` | Latest CVEs, exploit POCs, tool updates |
| `academic_search` | Security research papers |
| `deep_research` | Comprehensive topic research |
| `analyze_gaps` | Find missing documentation |
| `fetch_url` | Extract content from security blogs |

See: `~/system_docs/docs/researchhub-integration.md` for full guide.

---

## Cross-Repository Integration

### Related Repositories

| Repository | Domain | Tools | Status |
|------------|--------|-------|--------|
| ~/pwnbox | Network Pentesting / AD | 31 | 100% TOC |
| ~/webbox | Web Application Security | 36 | 100% TOC |
| ~/revbox | Reverse Engineering | 46 | In Progress |
| ~/system_docs | Automation Scripts | 246+ | Reference |
| ~/denoiseai/researchhub | Research Automation | - | Integration |

### Shared Standards

All repositories follow identical:
- Knowledge folder structure
- YAML frontmatter format
- README.md templates
- File naming conventions

---

## Progress Tracking

### Documentation Status

| Category | Tools | Documented | With TOC | With FM |
|----------|-------|------------|----------|---------|
| Reconnaissance | 3 | 3 | 3 | 3 |
| Enumeration | 5 | 5 | 5 | 5 |
| Active Directory | 5 | 5 | 5 | 5 |
| Exploitation | 4 | 4 | 4 | 4 |
| Password Cracking | 3 | 3 | 3 | 3 |
| Pivoting | 5 | 5 | 5 | 5 |
| Privilege Escalation | 4 | 4 | 4 | 4 |
| Networking | 2 | 2 | 2 | 2 |
| **Total** | **31** | **31** | **31** | **31** |

### Current Stats

- **Total files:** 140+
- **Total lines:** 57,000+
- **Total size:** 2.2 MB
- **TOC coverage:** 100%
- **Frontmatter coverage:** 100%

### Milestones

- [x] **M1:** All README files have table of contents
- [x] **M2:** All large files split into subtopics
- [x] **M3:** knowledge/ folder has complete README hierarchy
- [x] **M4:** Automation script created (pwnbox_doc_enhancer.py)
- [x] **M5:** Methodology documentation (9 phases)
- [x] **M6:** Reporting templates created
- [x] **M7:** ResearchHub integration documented
- [x] **M8:** Certification research completed (OSCP, CEH, PNPT, etc.)
- [x] **M9:** Gap analysis complete
- [ ] **M10:** Web application testing methodology (Phase 6)
- [ ] **M11:** Evasion techniques documentation (Phase 7)
- [ ] **M12:** Cloud and wireless pentesting (Phase 8)

---

## Changelog

| Date | Change |
|------|--------|
| 2025-12-27 | Comprehensive certification research (OSCP, CEH, PNPT, CRTP, CRTE, GPEN) |
| 2025-12-27 | Added AD attack techniques (enumeration, credential, lateral, persistence, ADCS, trusts) |
| 2025-12-27 | Added Windows/Linux privilege escalation comprehensive docs |
| 2025-12-27 | Added pentest frameworks documentation (PTES, OWASP, MITRE, etc.) |
| 2025-12-27 | Created GAP_ANALYSIS.md with certification-based gap analysis |
| 2025-12-27 | Added Phases 6, 7, 8 for web, evasion, cloud/wireless |
| 2025-12-27 | Phase 4 (Methodology) complete with 9 phases |
| 2025-12-27 | Phase 5 (Reporting) complete with templates |
| 2025-12-27 | Added ResearchHub integration section |
| 2025-12-27 | Phase 1 complete: 100% TOC and frontmatter coverage |
| 2025-12-27 | Created pwnbox_doc_enhancer.py automation script |
| 2025-12-26 | Initial tool documentation added (31 tools) |
