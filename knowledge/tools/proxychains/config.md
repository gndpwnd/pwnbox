# ProxyChains Configuration Guide

Complete configuration reference for proxychains/proxychains-ng.

## Table of Contents

- [Configuration File Locations](#configuration-file-locations)
- [Configuration File Format](#configuration-file-format)
- [Proxy Types](#proxy-types)
- [Chain Modes](#chain-modes)
- [DNS Settings](#dns-settings)
- [Timeout Configuration](#timeout-configuration)
- [Environment Variables](#environment-variables)
- [Complete Configuration Example](#complete-configuration-example)

## Configuration File Locations

ProxyChains searches for configuration in the following order (first match wins):

| Priority | Location | Description |
|----------|----------|-------------|
| 1 | Environment variable | `PROXYCHAINS_CONF_FILE=/path/to/config` |
| 2 | Command-line flag | `proxychains4 -f /path/to/config` |
| 3 | Current directory | `./proxychains.conf` |
| 4 | User config | `~/.proxychains/proxychains.conf` |
| 5 | System config | `/etc/proxychains.conf` or `/etc/proxychains4.conf` |

### Creating User Configuration

```bash
# Create user config directory
mkdir -p ~/.proxychains

# Copy system config as starting point
cp /etc/proxychains4.conf ~/.proxychains/proxychains.conf

# Or create minimal config
cat > ~/.proxychains/proxychains.conf << 'EOF'
dynamic_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
socks5 127.0.0.1 1080
EOF
```

### Multiple Configuration Profiles

Create different configs for different scenarios:

```bash
# Tor configuration
~/.proxychains/tor.conf

# Chisel SOCKS proxy
~/.proxychains/chisel.conf

# SSH dynamic forwarding
~/.proxychains/ssh.conf

# Use specific config
proxychains4 -f ~/.proxychains/tor.conf curl http://example.com
```

## Configuration File Format

The configuration file uses an INI-like format with the following sections:

```ini
# Comments start with #
# Blank lines are ignored

# Chain mode (uncomment only ONE)
#strict_chain
dynamic_chain
#round_robin_chain
#random_chain

# Proxy DNS requests (recommended)
proxy_dns

# Quiet mode (suppress startup banner)
#quiet_mode

# Timeouts in milliseconds
tcp_read_time_out 15000
tcp_connect_time_out 8000

# For random_chain mode
#chain_len = 2

# Local subnet bypass (optional)
#localnet 127.0.0.0/255.0.0.0
#localnet 10.0.0.0/255.0.0.0
#localnet 192.168.0.0/255.255.0.0

# Proxy list section (REQUIRED)
[ProxyList]
# format: type host port [user pass]
socks5 127.0.0.1 1080
```

## Proxy Types

ProxyChains supports three proxy types:

### SOCKS4

```ini
[ProxyList]
socks4 127.0.0.1 1080
socks4 192.168.1.100 9050
```

**Characteristics:**
- No authentication support
- IPv4 only
- No UDP support
- No DNS resolution through proxy (use SOCKS4a variant internally)

### SOCKS5

```ini
[ProxyList]
# Without authentication
socks5 127.0.0.1 1080

# With authentication
socks5 192.168.1.100 1080 username password
```

**Characteristics:**
- Full authentication support (username/password)
- IPv4 and IPv6 support
- UDP support (limited in proxychains)
- DNS resolution through proxy supported
- **Recommended for most use cases**

### HTTP (CONNECT)

```ini
[ProxyList]
# Without authentication
http 192.168.1.1 8080

# With authentication
http 10.0.0.1 3128 proxyuser proxypass
```

**Characteristics:**
- Uses HTTP CONNECT method
- Authentication via Basic auth
- Limited to TCP connections
- Typically port 8080 or 3128
- Works with corporate proxies

### Mixed Proxy Types

You can chain different proxy types:

```ini
[ProxyList]
# Traffic flows: client -> http -> socks5 -> socks4 -> target
http   10.0.0.1 8080 user pass
socks5 192.168.1.100 1080
socks4 172.16.0.50 9050
```

## Chain Modes

### dynamic_chain (Recommended)

Skip dead proxies and continue with the next in the list.

```ini
dynamic_chain

[ProxyList]
socks5 127.0.0.1 1080   # If dead, skip to next
socks5 127.0.0.1 1081   # Use this one
socks5 127.0.0.1 1082   # Or this one
```

**Use when:**
- Proxy availability is uncertain
- You want fault tolerance
- Exact chain path is not critical

### strict_chain

Use all proxies in exact order; fail if any proxy is dead.

```ini
strict_chain

[ProxyList]
socks5 127.0.0.1 1080   # Must work
socks5 192.168.1.50 1080  # Then this
socks5 10.10.10.1 1080   # Then this
```

**Use when:**
- You need traffic to traverse specific hosts
- All proxies are expected to be available
- Chain order matters for routing

### round_robin_chain

Distribute connections across proxies in round-robin fashion.

```ini
round_robin_chain
chain_len = 1  # Number of proxies per chain

[ProxyList]
socks5 127.0.0.1 1080
socks5 127.0.0.1 1081
socks5 127.0.0.1 1082
```

**Use when:**
- Load balancing across multiple proxies
- Distributing traffic sources
- High-volume operations

### random_chain

Pick random proxies from the list for each connection.

```ini
random_chain
chain_len = 2  # Use 2 random proxies per chain

[ProxyList]
socks5 proxy1.example.com 1080
socks5 proxy2.example.com 1080
socks5 proxy3.example.com 1080
socks5 proxy4.example.com 1080
```

**Use when:**
- Maximum anonymity desired
- Traffic pattern obfuscation
- Multiple proxy options available

## DNS Settings

### proxy_dns

Route DNS queries through the proxy chain (recommended for anonymity):

```ini
proxy_dns
```

**Behavior:**
- DNS queries are resolved through the proxy
- Prevents DNS leaks
- Required for .onion addresses with Tor
- May be slower but more private

### No proxy_dns

Comment out or omit `proxy_dns` to resolve DNS locally:

```ini
# proxy_dns  # Commented out - local DNS resolution
```

**Behavior:**
- DNS resolved by local system resolver
- Faster resolution
- May leak DNS queries to local network
- Cannot access .onion or internal hostnames

### Custom DNS Server (proxychains-ng)

Set a specific DNS server for proxy DNS resolution:

```bash
# Via environment variable
export PROXY_DNS_SERVER=8.8.8.8
proxychains4 curl http://example.com

# Or in config (proxychains-ng only)
# dns_server 8.8.8.8
```

### Remote DNS Subnet

Control which DNS queries go through the proxy:

```ini
# Only proxy DNS for non-local addresses
remote_dns_subnet 224
```

The value 224 means only resolve addresses with first octet >= 224 locally.

## Timeout Configuration

### tcp_read_time_out

Maximum time to wait for data after connection is established:

```ini
# Default: 15000 (15 seconds)
tcp_read_time_out 15000

# Increase for slow proxies/networks
tcp_read_time_out 30000

# Decrease for faster failure detection
tcp_read_time_out 5000
```

### tcp_connect_time_out

Maximum time to wait for TCP connection to proxy:

```ini
# Default: 8000 (8 seconds)
tcp_connect_time_out 8000

# Increase for high-latency proxies
tcp_connect_time_out 20000

# Decrease for local proxies
tcp_connect_time_out 3000
```

### Recommended Timeout Settings

| Scenario | connect_time_out | read_time_out |
|----------|-----------------|---------------|
| Local proxy (localhost) | 3000 | 10000 |
| LAN proxy | 5000 | 15000 |
| Internet proxy | 10000 | 20000 |
| Tor/High-latency | 20000 | 60000 |
| Multiple hops | 15000 | 30000 |

## Environment Variables

### PROXYCHAINS_SOCKS5_HOST and PROXYCHAINS_SOCKS5_PORT

Quick SOCKS5 proxy setup without config file:

```bash
export PROXYCHAINS_SOCKS5_HOST=127.0.0.1
export PROXYCHAINS_SOCKS5_PORT=1080
proxychains4 curl http://example.com
```

**Note:** These override the config file proxy list.

### PROXYCHAINS_CONF_FILE

Specify configuration file path:

```bash
export PROXYCHAINS_CONF_FILE=/path/to/custom.conf
proxychains4 nmap -sT target
```

### PROXY_DNS_SERVER

Custom DNS server for proxy DNS resolution:

```bash
export PROXY_DNS_SERVER=8.8.8.8
proxychains4 nslookup example.com
```

### LD_PRELOAD

ProxyChains uses LD_PRELOAD to intercept network calls. You can see this:

```bash
# Verbose output shows the preload
proxychains4 -q env | grep LD_PRELOAD
```

## Complete Configuration Example

### General Purpose Configuration

```ini
# ~/.proxychains/proxychains.conf
# General purpose proxychains configuration

# Use dynamic chain - skip dead proxies
dynamic_chain

# Proxy DNS requests through the chain
proxy_dns

# Suppress output (uncomment for less verbose)
#quiet_mode

# Timeouts (milliseconds)
tcp_read_time_out 15000
tcp_connect_time_out 8000

# Don't proxy connections to these networks
localnet 127.0.0.0/255.0.0.0
localnet 10.0.0.0/255.0.0.0
localnet 172.16.0.0/255.240.0.0
localnet 192.168.0.0/255.255.0.0

[ProxyList]
# Add your proxies here
# type  host  port  [user  pass]
socks5 127.0.0.1 1080
```

### Tor Configuration

```ini
# ~/.proxychains/tor.conf
# Configuration for Tor

strict_chain
proxy_dns

tcp_read_time_out 60000
tcp_connect_time_out 30000

[ProxyList]
socks5 127.0.0.1 9050
```

### Multi-Hop Pivoting Configuration

```ini
# ~/.proxychains/pivot.conf
# Multi-hop through compromised hosts

strict_chain
proxy_dns

tcp_read_time_out 30000
tcp_connect_time_out 15000

[ProxyList]
# First hop: SSH SOCKS on attacker machine
socks5 127.0.0.1 1080
# Second hop: Chisel on first pivot
socks5 127.0.0.1 1081
# Third hop: Ligolo on second pivot
socks5 127.0.0.1 1082
```

## Localnet Bypass

Exclude local networks from proxying:

```ini
# Don't proxy localhost
localnet 127.0.0.0/255.0.0.0

# Don't proxy private networks
localnet 10.0.0.0/255.0.0.0
localnet 172.16.0.0/255.240.0.0
localnet 192.168.0.0/255.255.0.0

# Don't proxy link-local
localnet 169.254.0.0/255.255.0.0
```

**Important:** Be careful with localnet in penetration testing - you may want to proxy connections to private networks if they are on the remote side.

## See Also

- [README.md](README.md) - Overview and installation
- [examples.md](examples.md) - Practical usage examples
- [official_docs.md](official_docs.md) - Upstream documentation
