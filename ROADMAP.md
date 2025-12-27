# PWNBOX Documentation Roadmap

## Table of Contents

- [Overview](#overview)
- [Documentation Standards](#documentation-standards)
- [Directory Structure](#directory-structure)
- [Phase 1: Documentation Refactoring](#phase-1-documentation-refactoring)
- [Phase 2: Research Expansion](#phase-2-research-expansion)
- [Phase 3: Automation Integration](#phase-3-automation-integration)
- [Cross-Repository Integration](#cross-repository-integration)
- [Progress Tracking](#progress-tracking)

---

## Overview

This roadmap outlines the documentation strategy for the PWNBOX knowledge base. The goal is to create comprehensive, well-organized documentation for all penetration testing tools while maintaining consistency across related repositories (webbox, revbox, system_docs).

### Guiding Principles

1. **Every folder must have a README.md** - Serves as a table of contents for that directory
2. **Split large files into subtopics** - One document per major subtopic for better navigation
3. **Consistent structure** - All tool documentation follows the same organization pattern
4. **Automation-friendly** - Documentation should integrate with ~/system_docs/ scripts

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

## Overview

2-3 sentences explaining what the tool does and when to use it.

## Installation

Package manager commands or installation instructions.

## Quick Start

Most common usage examples.

## Documentation Files

| File | Description |
|------|-------------|
| [official_docs.md](official_docs.md) | Official documentation |
| [options.md](options.md) | Command-line options reference |
| [examples.md](examples.md) | Usage examples and techniques |
```

### File Organization Per Tool

Each tool folder should contain:

| File | Required | Description |
|------|----------|-------------|
| `README.md` | Yes | Overview and table of contents |
| `official_docs.md` | Yes | Extracted official documentation |
| `options.md` | Recommended | CLI options and flags reference |
| `examples.md` | Recommended | Practical usage examples |
| `techniques.md` | Optional | Attack techniques and methodologies |
| `scripts.md` | Optional | Helper scripts (NSE, modules, etc.) |
| `troubleshooting.md` | Optional | Common issues and solutions |

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
├── tools/
│   ├── README.md               # Tools index by category
│   ├── nmap/
│   │   ├── README.md           # Nmap overview + TOC
│   │   ├── official_docs.md    # Official documentation
│   │   ├── options.md          # Command-line options
│   │   ├── scripts.md          # NSE scripts reference
│   │   └── examples.md         # Usage examples
│   └── [other tools]/
├── methodology/
│   └── README.md               # Pentesting methodology guides
├── techniques/
│   └── README.md               # Attack technique documentation
└── references/
    └── README.md               # Quick reference sheets
```

---

## Phase 1: Documentation Refactoring

**Goal:** Reorganize existing documentation with proper structure and TOCs.

### Tasks

- [ ] Create `knowledge/README.md` with knowledge base overview
- [ ] Create `knowledge/tools/README.md` with tool index by category
- [ ] Refactor each tool README.md:
  - [ ] Add table of contents
  - [ ] Add documentation files table
  - [ ] Keep under 200 lines (split if needed)
- [ ] Split large files (>500 lines):
  - [ ] socat (4306 lines) - Split into subtopics
  - [ ] ssh (1233 lines) - Split into subtopics
  - [ ] masscan (649 lines) - Consider splitting
  - [ ] evil-winrm (603 lines) - Consider splitting

### Tools Requiring Refactoring (33 total)

**Reconnaissance:** nmap, masscan, rustscan
**Enumeration:** gobuster, feroxbuster, enum4linux, smbclient, smbmap
**Active Directory:** bloodhound, kerbrute, responder, crackmapexec, netexec
**Exploitation:** impacket, evil-winrm, metasploit-framework, msfvenom
**Password Cracking:** hashcat, john, hydra
**Pivoting:** chisel, ligolo-ng, proxychains, ssh, socat
**Privilege Escalation:** linpeas, winpeas, pspy, mimikatz
**Networking:** nc, rlwrap

---

## Phase 2: Research Expansion

**Goal:** Enhance documentation with comprehensive research.

### Research Sources

1. **Man pages** - `man <tool>` output
2. **Help output** - `<tool> --help` or `-h`
3. **Official websites** - Tool documentation sites
4. **GitHub repos** - READMEs, wikis, issues
5. **Package managers** - apt, pacman descriptions
6. **Blogs/tutorials** - Practical usage guides

### Research Checklist Per Tool

- [ ] Command-line arguments (complete reference)
- [ ] GUI interaction (if applicable)
- [ ] Configuration files
- [ ] Common use cases and examples
- [ ] Integration with other tools
- [ ] Tips and tricks
- [ ] Troubleshooting common issues

### Priority Order

1. **High Priority** - Core tools used in most engagements
2. **Medium Priority** - Specialized tools for specific scenarios
3. **Low Priority** - Utility tools and helpers

---

## Phase 3: Automation Integration

**Goal:** Leverage ~/system_docs/ scripts for research automation.

### Available Scripts (in ~/system_docs/scripts/)

| Script | Purpose |
|--------|---------|
| `extract_manpages.py` | Extract man pages for tools |
| `extract_readmes.py` | Scrape GitHub/GitLab READMEs |
| `comprehensive_doc_downloader.py` | Fetch official docs from 60+ sites |
| `bulk_tool_docs.py` | Batch download docs |
| `download_to_repo.py` | Distribute docs to external repos |

### Automation Workflow

1. Use `extract_domain_tools.py` to identify tools in pwnbox
2. Cross-reference with `unified_tools.json` (7,005 tools database)
3. Run `extract_manpages.py` for CLI documentation
4. Run `comprehensive_doc_downloader.py` for official docs
5. Use `download_to_repo.py` to sync to pwnbox knowledge folder

### New Scripts to Create

Store in `~/system_docs/scripts/`:

- [ ] `generate_toc.py` - Auto-generate table of contents for README files
- [ ] `split_large_docs.py` - Split files exceeding line threshold
- [ ] `validate_structure.py` - Verify folder structure compliance
- [ ] `sync_tool_manifest.py` - Keep tools_manifest.json in sync

---

## Cross-Repository Integration

### Related Repositories

| Repository | Domain | Tools Count |
|------------|--------|-------------|
| ~/pwnbox | Network Pentesting / AD | 33 |
| ~/webbox | Web Application Security | 36 |
| ~/revbox | Reverse Engineering | 46 |
| ~/system_docs | System Administration | 246+ |

### Shared Standards

All repositories follow identical:
- Knowledge folder structure
- YAML frontmatter format
- README.md templates
- File naming conventions

### Data Sources

- `~/system_docs/data/processed/unified_tools.json` - 7,005 tools database
- `~/system_docs/data/priority_tools.json` - 237 priority tools
- `~/system_docs/data/domain_tools_analysis.json` - Cross-repo tool mapping

---

## Progress Tracking

### Documentation Status

| Category | Tools | Documented | Refactored | Complete |
|----------|-------|------------|------------|----------|
| Reconnaissance | 3 | 3 | 0 | 0 |
| Enumeration | 5 | 5 | 0 | 0 |
| Active Directory | 5 | 5 | 0 | 0 |
| Exploitation | 4 | 4 | 0 | 0 |
| Password Cracking | 3 | 3 | 0 | 0 |
| Pivoting | 5 | 5 | 0 | 0 |
| Privilege Escalation | 4 | 4 | 0 | 0 |
| Networking | 2 | 2 | 0 | 0 |
| **Total** | **33** | **33** | **0** | **0** |

### Milestones

- [ ] **M1:** All README files have table of contents
- [ ] **M2:** All large files split into subtopics
- [ ] **M3:** knowledge/ folder has complete README hierarchy
- [ ] **M4:** Automation scripts created and tested
- [ ] **M5:** All 33 tools have comprehensive documentation

---

## Changelog

| Date | Change |
|------|--------|
| 2025-12-27 | Created initial roadmap with documentation standards |
| 2025-12-26 | Initial tool documentation added (33 tools) |
