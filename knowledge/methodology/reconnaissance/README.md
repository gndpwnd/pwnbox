---
title: Reconnaissance
category: methodology
tags: [osint, passive-recon, active-recon]
last_updated: 2025-12-27
---

# Reconnaissance

## Overview

Reconnaissance is the first phase of penetration testing, focused on gathering information about the target without directly interacting with systems (passive) or through direct interaction (active). The goal is to map the attack surface and identify potential entry points.

## Passive Reconnaissance

Passive recon involves collecting information without directly touching target systems. This reduces detection risk and is often performed before formal engagement begins.

### OSINT Techniques

- **Search Engines**: Google dorks, Bing, DuckDuckGo for indexed content
- **WHOIS Lookups**: Domain registration, registrar info, contact details
- **DNS Records**: MX, TXT, NS, A, AAAA records reveal infrastructure
- **Certificate Transparency**: crt.sh, Censys for subdomain discovery
- **Wayback Machine**: Historical website snapshots and removed content

### Public Records

- **Business Registries**: Company structure, subsidiaries, key personnel
- **SEC Filings**: Financial data, acquisitions, technology mentions
- **Job Postings**: Technology stack, security tools, infrastructure hints
- **GitHub/GitLab**: Code repositories, leaked credentials, API keys

### Social Media Intelligence

- **LinkedIn**: Employee enumeration, org charts, technology used
- **Twitter/X**: Company announcements, employee activities
- **Facebook/Instagram**: Physical security insights, locations
- **Pastebin/GitHub Gists**: Leaked data, credentials, configs

### DNS Reconnaissance

```bash
# Subdomain enumeration
dig +short NS target.com
dig +short MX target.com
dig +short TXT target.com

# Zone transfer attempt
dig axfr @ns1.target.com target.com

# DNS brute forcing with wordlist
dnsenum --dnsserver 8.8.8.8 -f /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt target.com
```

## Active Reconnaissance

Active recon involves direct interaction with target systems. This phase requires proper authorization.

### Network Discovery

```bash
# Host discovery
nmap -sn 192.168.1.0/24

# ARP scan (local network)
arp-scan -l

# Ping sweep
fping -a -g 192.168.1.0/24 2>/dev/null
```

### Port Scanning

```bash
# Quick TCP scan
nmap -sS -T4 --top-ports 1000 target.com

# Full TCP scan
nmap -sS -p- -T4 target.com

# UDP scan (top ports)
nmap -sU --top-ports 100 target.com

# Fast scanning with rustscan
rustscan -a target.com --ulimit 5000 -- -sV
```

### Banner Grabbing

```bash
# Netcat banner grab
nc -nv 192.168.1.10 22

# Nmap service detection
nmap -sV -sC -p 22,80,443 target.com

# Curl for web servers
curl -I https://target.com
```

### Web Application Discovery

```bash
# Directory enumeration
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt

# Virtual host discovery
gobuster vhost -u http://target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# Technology detection
whatweb http://target.com
```

## Tool Recommendations

| Purpose | Tool | Documentation |
|---------|------|---------------|
| Port Scanning | nmap | [../tools/nmap/](../tools/nmap/) |
| Fast Port Scan | rustscan | [../tools/rustscan/](../tools/rustscan/) |
| Mass Scanning | masscan | [../tools/masscan/](../tools/masscan/) |
| Directory Busting | gobuster | [../tools/gobuster/](../tools/gobuster/) |
| Directory Busting | feroxbuster | [../tools/feroxbuster/](../tools/feroxbuster/) |
| SMB Enumeration | enum4linux | [../tools/enum4linux/](../tools/enum4linux/) |
| Network Sniffing | responder | [../tools/responder/](../tools/responder/) |

## Methodology Checklist

- [ ] Identify all domains and subdomains
- [ ] Enumerate DNS records
- [ ] Search for leaked credentials/data
- [ ] Map external-facing infrastructure
- [ ] Identify technology stack
- [ ] Perform port scanning
- [ ] Document all findings

## Next Phase

After reconnaissance, proceed to [Enumeration](../enumeration/) for detailed service analysis.
