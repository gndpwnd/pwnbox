# socat Advanced Techniques and Address Options

This document covers advanced address options, option groups, and techniques for using socat effectively.

## Address Option Concepts

Address options are applied to address specifications to control how addresses are opened and how data channels behave.

### Option Syntax

```bash
ADDRESS:param1:param2,option1,option2=value
```

### Option Groups

Each option belongs to one or more groups. Options can only be used with address types that support their groups:

| Group | Description |
|-------|-------------|
| FD | File descriptor operations |
| SOCKET | Socket operations |
| IP4/IP6 | IP version specific |
| TCP | TCP specific options |
| UDP | UDP specific options |
| LISTEN | Listening socket options |
| CHILD | Child process/fork options |
| RANGE | Access control options |
| EXEC | Program execution options |
| FORK | Fork behavior options |
| TERMIOS | Terminal I/O control |
| PTY | Pseudo-terminal options |
| OPENSSL | SSL/TLS options |
| RETRY | Retry behavior |
| NAMED | Filesystem entry options |
| OPEN | File open flags |

## File Descriptor Options (FD Group)

### Locking

| Option | Description |
|--------|-------------|
| `setlk` | Set discretionary write lock on file |
| `setlkw` | Set blocking write lock |
| `setlk-rd` | Set discretionary read lock |
| `setlkw-rd` | Set blocking read lock |
| `flock-ex` | Blocking exclusive advisory lock |
| `flock-ex-nb` | Non-blocking exclusive lock |
| `flock-sh` | Blocking shared advisory lock |
| `flock-sh-nb` | Non-blocking shared lock |
| `lock` | Platform-appropriate lock |

### Ownership and Permissions

| Option | Description |
|--------|-------------|
| `user=<user>` | Set owner of stream |
| `user-late=<user>` | Set owner after opening |
| `group=<group>` | Set group of stream |
| `group-late=<group>` | Set group after opening |
| `mode=<mode>` | Set permissions |
| `perm-late=<mode>` | Set permissions after opening |

### File Behavior

| Option | Description |
|--------|-------------|
| `append` | Always write to end of file |
| `nonblock` | Non-blocking mode |
| `binary` | Binary mode (Cygwin) |
| `text` | Text mode (Cygwin) |
| `cloexec` | Close on exec |

### Connection Handling

| Option | Description |
|--------|-------------|
| `cool-write` | Don't error on EPIPE/ECONNRESET, just notice |
| `end-close` | Just close() instead of shutdown() |
| `shut-none` | Don't do anything on shutdown |
| `shut-down` | Use shutdown(SHUT_WR) |
| `shut-close` | Use close() |
| `shut-null` | Send zero-sized packet on EOF |
| `null-eof` | Treat empty packets as EOF |

### ioctl Operations

| Option | Description |
|--------|-------------|
| `ioctl-void=<request>` | Call ioctl with NULL argument |
| `ioctl-int=<req>:<val>` | Call ioctl with int argument |
| `ioctl-intp=<req>:<val>` | Call ioctl with pointer to int |
| `ioctl-bin=<req>:<val>` | Call ioctl with binary data |
| `ioctl-string=<req>:<val>` | Call ioctl with string |

## Named Entry Options (NAMED Group)

| Option | Description |
|--------|-------------|
| `user-early=<user>` | Change owner before access |
| `group-early=<group>` | Change group before access |
| `perm-early=<mode>` | Change permissions before access |
| `unlink-early` | Remove file before opening |
| `unlink` | Remove after user-early, before open |
| `unlink-late` | Remove after opening |
| `unlink-close` | Remove when closing (default for sockets/pipes) |

## Open Flags (OPEN Group)

| Option | Description |
|--------|-------------|
| `creat` | Create file if doesn't exist |
| `excl` | With creat, fail if exists |
| `trunc` | Truncate file to size 0 |
| `rdonly` | Open read-only |
| `wronly` | Open write-only |
| `dsync` | Block write until metadata written |
| `rsync` | Block write until metadata written |
| `sync` | Block write until data written |
| `largefile` | Allow files > 2^31 bytes |
| `noatime` | Don't update access time |
| `noctty` | Don't make controlling terminal |
| `nofollow` | Don't follow symlinks |

## Seek Options (REG Group)

| Option | Description |
|--------|-------------|
| `seek=<offset>` | Absolute position |
| `seek-cur=<offset>` | Relative to current |
| `seek-end=<offset>` | Relative to end |
| `ftruncate=<offset>` | Truncate at position |

## Socket Options (SOCKET Group)

### Connection

| Option | Description |
|--------|-------------|
| `bind=<sockname>` | Bind to local address |
| `connect-timeout=<sec>` | Connection timeout |

### Socket Behavior

| Option | Description |
|--------|-------------|
| `so-bindtodevice=<if>` | Bind to interface (requires root) |
| `broadcast` | Allow broadcast addresses |
| `debug` | Enable socket debugging |
| `dontroute` | Don't use routers |
| `keepalive` | Send keepalives |
| `linger=<sec>` | Block on close until transfer complete |
| `oobinline` | Receive OOB data inline |
| `priority=<int>` | Set packet priority |
| `reuseaddr` | Allow address reuse |
| `reuseport` | Allow port reuse |
| `so-timestamp` | Enable timestamp ancillary messages |

### Buffer Sizes

| Option | Description |
|--------|-------------|
| `rcvbuf=<bytes>` | Receive buffer size |
| `rcvbuf-late=<bytes>` | Receive buffer after connect |
| `sndbuf=<bytes>` | Send buffer size |
| `sndbuf-late=<bytes>` | Send buffer after connect |
| `rcvlowat=<bytes>` | Minimum bytes before delivery |
| `sndlowat=<bytes>` | Minimum bytes before send |

### Timeouts

| Option | Description |
|--------|-------------|
| `rcvtimeo=<time>` | Receive timeout |
| `sndtimeo=<time>` | Send timeout |

### Protocol Settings

| Option | Description |
|--------|-------------|
| `pf=<string>` | Force IP version ("ip4" or "ip6") |
| `socktype=<type>` | Socket type (1=stream, 2=dgram, 3=raw) |
| `protocol=<proto>` | Protocol number (6=TCP, 17=UDP) |

### Generic setsockopt

| Option | Description |
|--------|-------------|
| `setsockopt=<lev>:<opt>:<val>` | Generic setsockopt |
| `setsockopt-int=<lev>:<opt>:<val>` | setsockopt with int |
| `setsockopt-string=<lev>:<opt>:<val>` | setsockopt with string |
| `setsockopt-listen=...` | Apply to listening socket |
| `setsockopt-socket=...` | Apply before bind/connect |
| `setsockopt-connected=...` | Apply after connect |

## IP Options (IP4/IP6 Groups)

| Option | Description |
|--------|-------------|
| `tos=<tos>` | Type of service field |
| `ttl=<ttl>` | Time to live |
| `ip-options=<data>` | IP options (source routing) |
| `mtudiscover=<0\|1\|2>` | Path MTU discovery |
| `ip-transparent` | Transparent proxy (requires root) |

### Receive Options

| Option | Description |
|--------|-------------|
| `ip-pktinfo` | Receive destination/interface info |
| `ip-recverr` | Receive error info |
| `ip-recvopts` | Receive IP options |
| `ip-recvtos` | Receive TOS |
| `ip-recvttl` | Receive TTL |
| `ip-recvdstaddr` | Receive destination (*BSD) |
| `ip-recvif` | Receive interface (*BSD) |

### Multicast

| Option | Description |
|--------|-------------|
| `ip-add-membership=<mcast>:<if>` | Join multicast group |
| `ip-add-source-membership=<mcast>:<if>:<src>` | Join source-specific multicast |
| `ip-multicast-if=<host>` | Multicast interface |
| `ip-multicast-loop` | Loopback multicast |
| `ip-multicast-ttl=<byte>` | Multicast TTL (default: 1) |

### IPv6 Specific

| Option | Description |
|--------|-------------|
| `ipv6only` | Don't accept IPv4 on IPv6 socket |
| `ipv6-join-group=<mcast>:<if>` | Join IPv6 multicast |
| `ipv6-unicast-hops=<int>` | Set hop limit |
| `ipv6-recvpktinfo` | Receive packet info |
| `ipv6-recvhoplimit` | Receive hop limit |
| `ipv6-tclass` | Set traffic class |

## TCP Options

| Option | Description |
|--------|-------------|
| `cork` | Don't send partial packets |
| `defer-accept` | Only accept when data arrives |
| `nodelay` | Disable Nagle algorithm |
| `mss=<bytes>` | Maximum segment size |
| `mss-late=<bytes>` | MSS after connection |
| `keepcnt=<n>` | Keepalive count |
| `keepidle=<sec>` | Keepalive idle time |
| `keepintvl=<sec>` | Keepalive interval |
| `syncnt=<n>` | SYN retransmit count |

### Port Options (TCP/UDP/SCTP/DCCP)

| Option | Description |
|--------|-------------|
| `sourceport=<port>` | Source port for client; filter for server |
| `lowport` | Use random port 640-1023 (requires root) |

## Listen Options

| Option | Description |
|--------|-------------|
| `backlog=<count>` | Listen backlog (default: 5) |
| `accept-timeout=<sec>` | Timeout waiting for connection |

## Range/Access Control Options

| Option | Description |
|--------|-------------|
| `range=<addr-range>` | Allow only matching addresses |
| `tcpwrap[=<name>]` | Use libwrap for access control |
| `allow-table=<file>` | Custom hosts.allow |
| `deny-table=<file>` | Custom hosts.deny |
| `tcpwrap-etc=<dir>` | Custom tcpwrap directory |

**Range format**: `10.0.0.0/8` or `10.0.0.0:255.0.0.0` (IPv4), `[::1]/128` (IPv6)

## Child/Fork Options

| Option | Description |
|--------|-------------|
| `fork` | Handle each connection in child process |
| `max-children=<n>` | Limit concurrent children |
| `children-shutup=<n>` | Reduce child log severity |

## Exec/Fork Options

### Process Control

| Option | Description |
|--------|-------------|
| `path=<string>` | Override PATH for program search |
| `login` | Prefix argv[0] with '-' for login shell |
| `nofork` | Don't fork, exec directly (restrictions apply) |

### IPC Method

| Option | Description |
|--------|-------------|
| `pipes` | Use unnamed pipes instead of socketpair |
| `pty` | Use pseudo-terminal |
| `openpty` | Use openpty() for pty |
| `ptmx` | Use /dev/ptmx for pty |

### Process Environment

| Option | Description |
|--------|-------------|
| `ctty` | Make pty controlling terminal |
| `stderr` | Redirect stderr to stdout |
| `fdin=<fd>` | Use custom FD for child's input |
| `fdout=<fd>` | Use custom FD for child's output |
| `sighup`, `sigint`, `sigquit` | Pass signals to child |
| `shell=<file>` | Use specific shell |

## Process Options

| Option | Description |
|--------|-------------|
| `chroot=<dir>` | chroot after opening address |
| `chroot-early=<dir>` | chroot before opening |
| `setgid=<group>` | Change primary group |
| `setuid=<user>` | Change user |
| `su=<user>` | Change user and groups |
| `su-d=<user>` | Like su, but resolve before chroot |
| `setpgid=<pid>` | Join/create process group |
| `setsid` | Become session leader |
| `netns=<name>` | Switch network namespace (Linux, root, experimental) |
| `chdir=<dir>` | Change working directory |
| `umask=<mode>` | Set umask |

## PTY Options

| Option | Description |
|--------|-------------|
| `link=<filename>` | Create symlink to pty |
| `wait-slave` | Wait for slave to be opened |
| `pty-interval=<sec>` | Polling interval for wait-slave |
| `sitout-eio=<time>` | Tolerate EIO during tty reopen |

## OpenSSL Options

### Protocol

| Option | Description |
|--------|-------------|
| `min-proto-version=<ver>` | Minimum protocol (SSL2, SSL3, TLS1, TLS1.1, TLS1.2, TLS1.3) |
| `max-proto-version=<ver>` | Maximum protocol version |
| `cipher=<list>` | Cipher list (3DES, HIGH, aNULL, etc.) |
| `compress` | Enable/disable compression |
| `fips` | Enable FIPS mode |

### Certificates

| Option | Description |
|--------|-------------|
| `cert=<file>` | Certificate and private key file |
| `key=<file>` | Private key file |
| `dhparams=<file>` | DH parameters file |
| `cafile=<file>` | Trusted CA certificates |
| `capath=<dir>` | Directory of trusted certs |
| `verify` | Verify peer certificate (default: on) |
| `commonname=<name>` | Expected CN in peer cert |

### SNI

| Option | Description |
|--------|-------------|
| `no-sni` | Disable SNI |
| `snihost=<name>` | Override SNI hostname |

### Fragment Size

| Option | Description |
|--------|-------------|
| `maxfraglen=<size>` | Request max fragment (512, 1024, 2048, 4096) |
| `maxsendfrag=<size>` | Limit sent fragment (512-16384) |

## Retry Options

| Option | Description |
|--------|-------------|
| `retry=<n>` | Number of retry attempts |
| `interval=<sec>` | Time between retries (default: 1) |
| `forever` | Retry indefinitely |

## Terminal Options (TERMIOS)

### Basic Modes

| Option | Description |
|--------|-------------|
| `raw` | Raw mode (obsolete, use rawer) |
| `rawer` | Rawer mode with echo off |
| `cfmakeraw` | POSIX raw mode |
| `sane` | Sane terminal defaults |
| `echo` | Enable/disable echo |
| `icanon` | Canonical (line) mode |

### Serial Settings

| Option | Description |
|--------|-------------|
| `b19200`, `b9600`, etc. | Set baud rate |
| `ispeed=<rate>` | Input baud rate |
| `ospeed=<rate>` | Output baud rate |
| `cs5`, `cs6`, `cs7`, `cs8` | Character size |
| `cstopb` | Two stop bits |
| `parenb` | Enable parity |
| `parodd` | Odd parity |
| `crtscts` | Hardware flow control |

### Special Characters

| Option | Description |
|--------|-------------|
| `eof=<byte>` | EOF character |
| `erase=<byte>` | Erase character |
| `intr=<byte>` | Interrupt character |
| `kill=<byte>` | Kill line character |
| `quit=<byte>` | Quit character |
| `susp=<byte>` | Suspend character |

## Readline Options

| Option | Description |
|--------|-------------|
| `history=<file>` | History file path |
| `noprompt` | Don't detect prompt |
| `noecho=<pattern>` | Hide input matching pattern |
| `prompt=<string>` | Set explicit prompt |

## Application Options

| Option | Description |
|--------|-------------|
| `cr` | Convert NL to/from CR |
| `crnl` | Convert NL to/from CRNL |
| `ignoreeof` | Continue reading after EOF |
| `readbytes=<n>` | Read only n bytes then EOF |
| `lockfile=<file>` | Exit if lockfile exists |
| `waitlock=<file>` | Wait for lockfile to disappear |
| `escape=<int>` | Character code to trigger EOF |

## TUN/TAP Options (Linux)

| Option | Description |
|--------|-------------|
| `tun-device=<file>` | Clone device path |
| `tun-name=<name>` | Interface name |
| `tun-type=tun\|tap` | Device type |
| `iff-no-pi` | No packet info header |
| `iff-up` | Bring interface up (required!) |
| `iff-broadcast` | Set broadcast flag |
| `iff-promisc` | Promiscuous mode |
| `retrieve-vlan` | Restore VLAN tags |

## POSIX-MQ Options

| Option | Description |
|--------|-------------|
| `posixmq-priority` | Message priority |
| `posixmq-flush` | Drop existing messages |
| `posixmq-maxmsg` | Max messages in queue |
| `posixmq-msgsize` | Max message size |

## Resolver Options

| Option | Description |
|--------|-------------|
| `ai-addrconfig` | Only use available address families |
| `ai-passive` | Passive socket (for listen) |
| `ai-v4mapped` | Map IPv4 to IPv6 |
| `res-debug` | Resolver debug mode |
| `res-usevc` | Use TCP for DNS |
| `res-retry=<n>` | DNS retry count |
| `res-nsaddr=<ip>:<port>` | Override nameserver |

## Data Types Reference

| Type | Description |
|------|-------------|
| `bool` | 0 or 1 (1 if omitted) |
| `byte` | 0-255 |
| `int` | Signed integer (decimal, 0x hex, 0 octal) |
| `mode_t` | Permission bits (octal recommended) |
| `timeval` | Floating point seconds |
| `data` | Binary data in dalan format |

### Dalan Format (Binary Data)

| Prefix | Meaning |
|--------|---------|
| `x` | Hex bytes (e.g., `x7f000001`) |
| `"..."` | String with escapes |
| `'c'` | Single character |
| `i`, `I` | Signed/unsigned int |
| `l`, `L` | Signed/unsigned long |
| `s`, `S` | Signed/unsigned short |
| `b`, `B` | Signed/unsigned byte |
