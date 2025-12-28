---
title: Enumeration
category: methodology
tags: [enumeration, scanning, service-detection]
last_updated: 2025-12-27
---

# Enumeration

## Overview

Enumeration is the systematic process of extracting detailed information from discovered services. This phase follows reconnaissance and focuses on identifying users, shares, applications, and potential vulnerabilities in running services.

## Port Scanning

### Comprehensive Scanning

```bash
# Full TCP port scan with service detection
nmap -sS -sV -sC -p- -T4 -oA full_scan target.com

# Aggressive scan with OS detection
nmap -A -T4 target.com

# Script scan for vulnerabilities
nmap --script=vuln target.com
```

### UDP Scanning

```bash
# Top UDP ports
nmap -sU --top-ports 50 -T4 target.com

# Common UDP services
nmap -sU -p 53,67,68,69,123,161,162,500,514,1900 target.com
```

## Service Enumeration

### SMB Enumeration (445/139)

```bash
# Enumerate shares, users, groups
enum4linux -a target.com

# NetExec enumeration
netexec smb target.com -u '' -p '' --shares
netexec smb target.com -u 'guest' -p '' --shares --users

# SMB client connection
smbclient -L //target.com -N
smbmap -H target.com
```

### DNS Enumeration (53)

```bash
# Zone transfer
dig axfr @ns.target.com target.com

# Reverse DNS lookup
dnsrecon -r 192.168.1.0/24 -n ns.target.com

# Subdomain brute force
gobuster dns -d target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

### LDAP Enumeration (389/636)

```bash
# Anonymous bind
ldapsearch -x -H ldap://target.com -b "DC=domain,DC=com"

# Enumerate naming contexts
ldapsearch -x -H ldap://target.com -s base namingcontexts

# NetExec LDAP
netexec ldap target.com -u '' -p '' --users
```

### HTTP/HTTPS Enumeration (80/443)

```bash
# Directory enumeration
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt -x php,html,txt

# Recursive scanning
feroxbuster -u http://target.com -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt

# Technology fingerprinting
whatweb http://target.com
nikto -h http://target.com
```

### SNMP Enumeration (161)

```bash
# Community string brute force
onesixtyone -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt target.com

# SNMP walk
snmpwalk -v2c -c public target.com
```

### RPC/NFS Enumeration (111/2049)

```bash
# Show NFS exports
showmount -e target.com

# RPC info
rpcinfo -p target.com
```

## User Enumeration

### Windows/Active Directory

```bash
# Kerbrute user enumeration
kerbrute userenum -d domain.com --dc dc.domain.com /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt

# RID brute forcing
netexec smb target.com -u 'guest' -p '' --rid-brute

# LDAP user enumeration
ldapsearch -x -H ldap://target.com -b "DC=domain,DC=com" "(objectClass=user)" sAMAccountName
```

### Linux Systems

```bash
# SMTP user enumeration
smtp-user-enum -M VRFY -U /usr/share/seclists/Usernames/top-usernames-shortlist.txt -t target.com

# Finger service
finger @target.com
```

## Tool Recommendations

| Purpose | Tool | Documentation |
|---------|------|---------------|
| Port Scanning | nmap | [../tools/nmap/](../tools/nmap/) |
| SMB Enum | enum4linux | [../tools/enum4linux/](../tools/enum4linux/) |
| SMB/LDAP | netexec | [../tools/netexec/](../tools/netexec/) |
| SMB Mapping | smbmap | [../tools/smbmap/](../tools/smbmap/) |
| AD Users | kerbrute | [../tools/kerbrute/](../tools/kerbrute/) |
| Web Dirs | gobuster | [../tools/gobuster/](../tools/gobuster/) |
| Web Dirs | feroxbuster | [../tools/feroxbuster/](../tools/feroxbuster/) |
| Password Spray | hydra | [../tools/hydra/](../tools/hydra/) |

## Methodology Checklist

- [ ] Identify all open ports and services
- [ ] Enumerate SMB shares and permissions
- [ ] Extract DNS records and zone transfers
- [ ] Enumerate users via LDAP/RID/Kerberos
- [ ] Map web application structure
- [ ] Identify software versions for CVE research
- [ ] Document all credentials and access obtained

## Next Phase

After enumeration, proceed to [Exploitation](../exploitation/) to leverage discovered vulnerabilities.
