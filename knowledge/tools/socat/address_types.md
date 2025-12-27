# socat Address Types

This document covers all available address types in socat. An address specification consists of a keyword, optional parameters separated by `:`, and optional address options separated by `,`.

## Address Specification Format

```
KEYWORD:param1:param2,option1,option2=value
```

- Keywords are case insensitive
- `-` is a shortcut for STDIO
- Paths starting with `/` are assumed to be GOPEN
- Numbers are assumed to be FD addresses

## Standard I/O Addresses

| Address | Description |
|---------|-------------|
| `STDIO` | Uses FD 0 for reading, FD 1 for writing |
| `STDIN` | Uses FD 0 (read-only) |
| `STDOUT` | Uses FD 1 (write-only) |
| `STDERR` | Uses FD 2 (write-only) |
| `FD:<fdnum>` | Uses the specified file descriptor |
| `-` | Alias for STDIO |

## File Addresses

| Address | Description |
|---------|-------------|
| `OPEN:<filename>` | Opens file using open() system call |
| `CREATE:<filename>` | Creates file with creat() (write-only) |
| `GOPEN:<filename>` | Generic open - handles files, sockets, and pipes intelligently |

**Useful options**: `creat`, `excl`, `noatime`, `nofollow`, `append`, `rdonly`, `wronly`, `lock`, `readbytes`, `ignoreeof`

## Pipe Addresses

| Address | Description |
|---------|-------------|
| `PIPE:<filename>` | Opens or creates a named pipe (FIFO) |
| `PIPE` | Creates an unnamed pipe (echo behavior) |
| `SOCKETPAIR` | Creates a socketpair (keeps packet boundaries) |

## TCP Addresses

### Client (Connect)

| Address | Description |
|---------|-------------|
| `TCP:<host>:<port>` | TCP connection using IPv4 or IPv6 |
| `TCP4:<host>:<port>` | TCP connection using IPv4 only |
| `TCP6:<host>:<port>` | TCP connection using IPv6 only |

**Useful options**: `connect-timeout`, `retry`, `sourceport`, `bind`, `tos`, `mss`, `nodelay`, `nonblock`

### Server (Listen)

| Address | Description |
|---------|-------------|
| `TCP-LISTEN:<port>` | Listen for TCP connections |
| `TCP4-LISTEN:<port>` | Listen for TCP connections (IPv4 only) |
| `TCP6-LISTEN:<port>` | Listen for TCP connections (IPv6 only) |

**Useful options**: `fork`, `bind`, `range`, `tcpwrap`, `max-children`, `backlog`, `accept-timeout`, `reuseaddr`

## UDP Addresses

### Client (Connect/SendTo)

| Address | Description |
|---------|-------------|
| `UDP:<host>:<port>` | UDP "connection" to host:port |
| `UDP4:<host>:<port>` | UDP using IPv4 only |
| `UDP6:<host>:<port>` | UDP using IPv6 only |
| `UDP-SENDTO:<host>:<port>` | Send UDP datagrams to specific host |
| `UDP-DATAGRAM:<addr>:<port>` | For broadcast/multicast communications |

### Server (Listen/Receive)

| Address | Description |
|---------|-------------|
| `UDP-LISTEN:<port>` | Wait for UDP packet, "connect" back to sender |
| `UDP-RECVFROM:<port>` | Receive one packet, can reply (use with fork) |
| `UDP-RECV:<port>` | Receive from multiple peers (read-only) |

**Useful options**: `fork`, `bind`, `range`, `broadcast`, `ip-multicast-*`

## UNIX Domain Socket Addresses

### Stream (Connection-Oriented)

| Address | Description |
|---------|-------------|
| `UNIX-CONNECT:<filename>` | Connect to UNIX domain socket |
| `UNIX-LISTEN:<filename>` | Listen on UNIX domain socket |
| `UNIX-CLIENT:<filename>` | Try connect first, fallback to datagram |

### Datagram

| Address | Description |
|---------|-------------|
| `UNIX-SENDTO:<filename>` | Send datagrams to UNIX socket |
| `UNIX-RECVFROM:<filename>` | Receive datagrams (use with fork) |
| `UNIX-RECV:<filename>` | Receive from multiple peers (read-only) |

### Abstract Namespace (Linux)

| Address | Description |
|---------|-------------|
| `ABSTRACT-CONNECT:<string>` | Connect to abstract namespace socket |
| `ABSTRACT-LISTEN:<string>` | Listen on abstract namespace socket |
| `ABSTRACT-SENDTO:<string>` | Send to abstract namespace socket |
| `ABSTRACT-RECVFROM:<string>` | Receive from abstract socket |
| `ABSTRACT-RECV:<string>` | Receive only from abstract socket |
| `ABSTRACT-CLIENT:<string>` | Client with stream/datagram fallback |

## SSL/TLS Addresses

| Address | Description |
|---------|-------------|
| `OPENSSL:<host>:<port>` | SSL/TLS client connection |
| `OPENSSL-LISTEN:<port>` | SSL/TLS server |
| `OPENSSL-DTLS-CLIENT:<host>:<port>` | DTLS client (UDP-based TLS) |
| `OPENSSL-DTLS-SERVER:<port>` | DTLS server |

**Useful options**: `cert`, `key`, `cafile`, `capath`, `verify`, `cipher`, `commonname`, `min-proto-version`

## Program Execution Addresses

| Address | Description |
|---------|-------------|
| `EXEC:<command-line>` | Fork and execute program with execvp() |
| `SYSTEM:<shell-command>` | Fork and execute via system() |
| `SHELL:<shell-command>` | Fork and execute via $SHELL |

**Useful options**: `pty`, `stderr`, `ctty`, `setsid`, `pipes`, `nofork`, `su`, `chroot`, `sigint`, `sigquit`

## Proxy Addresses

| Address | Description |
|---------|-------------|
| `PROXY:<proxy>:<host>:<port>` | HTTP CONNECT proxy |
| `SOCKS4:<server>:<host>:<port>` | SOCKS4 proxy client |
| `SOCKS4A:<server>:<host>:<port>` | SOCKS4A proxy (server-side resolution) |
| `SOCKS5-CONNECT:<server>:<host>:<port>` | SOCKS5 proxy connect |
| `SOCKS5-LISTEN:<server>:<host>:<port>` | SOCKS5 proxy listen (reverse) |

**Useful options**: `proxyport`, `proxyauth`, `socksuser`, `socksport`

## PTY Address

| Address | Description |
|---------|-------------|
| `PTY` | Create pseudo terminal, use master side |

**Useful options**: `link`, `wait-slave`, `mode`, `user`, `group`

## Readline Address

| Address | Description |
|---------|-------------|
| `READLINE` | GNU readline on stdio for line editing/history |

**Useful options**: `history`, `noecho`, `prompt`

## Raw IP Addresses

| Address | Description |
|---------|-------------|
| `IP-SENDTO:<host>:<protocol>` | Send raw IP packets |
| `IP-DATAGRAM:<addr>:<protocol>` | Raw IP for broadcast/multicast |
| `IP-RECVFROM:<protocol>` | Receive raw IP packets |
| `IP-RECV:<protocol>` | Receive only raw IP (read-only) |

IPv4/IPv6 specific variants available (e.g., `IP4-SENDTO`, `IP6-RECV`)

## SCTP Addresses

| Address | Description |
|---------|-------------|
| `SCTP-CONNECT:<host>:<port>` | SCTP stream connection |
| `SCTP-LISTEN:<port>` | SCTP server |

IPv4/IPv6 specific variants available

## DCCP Addresses

| Address | Description |
|---------|-------------|
| `DCCP-CONNECT:<host>:<port>` | DCCP connection |
| `DCCP-LISTEN:<port>` | DCCP server |

IPv4/IPv6 specific variants available

## UDP-Lite Addresses

All UDP address types have UDPLITE variants:
- `UDPLITE-CONNECT`, `UDPLITE-LISTEN`, `UDPLITE-SENDTO`
- `UDPLITE-RECVFROM`, `UDPLITE-RECV`, `UDPLITE-DATAGRAM`

## TUN/TAP Addresses (Linux)

| Address | Description |
|---------|-------------|
| `TUN[:<if-addr>/<bits>]` | Create TUN/TAP device |
| `INTERFACE:<interface>` | Communicate via raw packets on interface |

**Useful options**: `iff-up`, `tun-device`, `tun-name`, `tun-type`

## VSOCK Addresses (Virtual Sockets)

| Address | Description |
|---------|-------------|
| `VSOCK-CONNECT:<cid>:<port>` | VSOCK stream connection |
| `VSOCK-LISTEN:<port>` | VSOCK server |

Special CIDs: `-1U` (any), `2` (host)

## POSIX Message Queue Addresses (Linux)

| Address | Description |
|---------|-------------|
| `POSIXMQ-READ:/<queue>` | Read from message queue |
| `POSIXMQ-RECEIVE:/<queue>` | Receive one message |
| `POSIXMQ-SEND:/<queue>` | Write to message queue |
| `POSIXMQ-WRITE:/<queue>` | Same as SEND |
| `POSIXMQ:/<queue>` | Bidirectional message queue |

## Generic Socket Addresses

For protocols not directly supported:

| Address | Description |
|---------|-------------|
| `SOCKET-CONNECT:<domain>:<protocol>:<remote-addr>` | Generic socket connect |
| `SOCKET-LISTEN:<domain>:<protocol>:<local-addr>` | Generic socket listen |
| `SOCKET-DATAGRAM:<domain>:<type>:<protocol>:<remote-addr>` | Generic datagram |
| `SOCKET-SENDTO:<domain>:<type>:<protocol>:<remote-addr>` | Generic sendto |
| `SOCKET-RECVFROM:<domain>:<type>:<protocol>:<local-addr>` | Generic recvfrom |
| `SOCKET-RECV:<domain>:<type>:<protocol>:<local-addr>` | Generic receive only |

## Special Addresses

| Address | Description |
|---------|-------------|
| `ACCEPT-FD:<fdnum>` | Accept from existing listening socket (systemd) |

## Dual Addresses

Two single addresses can be combined with `!!` for separate read/write channels:

```bash
socat READ-ADDRESS!!WRITE-ADDRESS OTHER-ADDRESS
```

The first address is used for reading, the second for writing.

## Option Groups

Each address type supports specific option groups:

| Group | Description |
|-------|-------------|
| FD | File descriptor options |
| SOCKET | Socket-related options |
| IP4/IP6 | IP version specific options |
| TCP/UDP/SCTP | Protocol-specific options |
| LISTEN | Listening socket options |
| CHILD | Fork/child process options |
| RANGE | Access control options |
| EXEC/FORK | Program execution options |
| TERMIOS | Terminal I/O options |
| PTY | Pseudo-terminal options |
| OPENSSL | SSL/TLS options |
| RETRY | Retry behavior options |
| NAMED | Filesystem entry options |
| OPEN | File open flag options |
