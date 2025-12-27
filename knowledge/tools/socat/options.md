# socat Command-Line Options

This document covers the command-line options that modify socat's behavior. These are separate from address options which are applied to specific address specifications.

## Help and Version

| Option | Description |
|--------|-------------|
| `-V` | Print version and available feature information to stdout, and exit |
| `-h` or `-?` | Print help text describing command line options and available address types |
| `-hh` or `-??` | Like -h, plus a list of short names of all available address options |
| `-hhh` or `-???` | Like -hh, plus a list of all available address option names |

## Logging Options

### Debug Levels

| Option | Description |
|--------|-------------|
| `-d` | Print notice messages (in addition to fatal, error, warning) |
| `-d0` | Print only fatal and error messages |
| `-dd` or `-d2` | Print fatal, error, warning, and notice messages |
| `-ddd` or `-d3` | Print fatal, error, warning, notice, and info messages |
| `-dddd` or `-d4` | Print fatal, error, warning, notice, info, and debug messages |
| `-D` | Log information about file descriptors before starting transfer phase |

### Log Destinations

| Option | Description |
|--------|-------------|
| `-ls` | Write messages to stderr (default) |
| `-lf <logfile>` | Write messages to specified file instead of stderr |
| `-ly[<facility>]` | Write messages to syslog instead of stderr. Default facility is "daemon" |
| `-lm[<facility>]` | Mixed log mode: stderr during startup, then syslog after entering transfer/daemon mode |

### Log Formatting

| Option | Description |
|--------|-------------|
| `-lp<progname>` | Override program name printed in error messages |
| `-lu` | Extend timestamp of error messages to microsecond resolution |
| `-lh` | Add hostname to log messages |

## Data Transfer Options

| Option | Description |
|--------|-------------|
| `-v` | Write transferred data to stderr in text format with readability conversions |
| `-x` | Write transferred data to stderr in hexadecimal format. Can be combined with -v |
| `-r <file>` | Dump raw (binary) data flowing from left to right address to specified file |
| `-R <file>` | Dump raw (binary) data flowing from right to left address to specified file |
| `-b<size>` | Set data transfer block size (default: 8192 bytes) |

## Direction Options

| Option | Description |
|--------|-------------|
| `-u` | Unidirectional mode: first address for reading only, second for writing only |
| `-U` | Unidirectional mode in reverse: first address for writing only, second for reading only |

## Timeout Options

| Option | Description |
|--------|-------------|
| `-t<timeout>` | Shutdown timeout in seconds after one channel reaches EOF (default: 0.5) |
| `-T<timeout>` | Total inactivity timeout in seconds. Values <0 mean infinite |

## IP Version Options

| Option | Description |
|--------|-------------|
| `-4` | Use IP version 4 (default since version 1.8.0.1) |
| `-6` | Use IP version 6 |
| `-0` | No IP version preference; let passive addresses serve both versions |

## Lock File Options

| Option | Description |
|--------|-------------|
| `-L<lockfile>` | Exit with error if lockfile exists; otherwise create it and continue. Unlinks on exit |
| `-W<lockfile>` | Wait if lockfile exists until it disappears. Creates it and continues, unlinks on exit |

## Miscellaneous Options

| Option | Description |
|--------|-------------|
| `--experimental` | Enable new features that are not well tested or subject to change |
| `-s` | Sloppy mode: continue despite non-fatal errors (does not bypass security checks) |
| `-S<signals-bitmap>` | Change the set of signals that are caught for logging purposes |
| `-g` | Don't check if address options are useful for the given address type |
| `--statistics` or `-S` | Log transfer statistics (bytes/blocks counters) before terminating (experimental) |

## Log Severity Levels

When using debug options, messages are categorized by severity:

| Level | Description |
|-------|-------------|
| **F** (FATAL) | Conditions requiring immediate program termination |
| **E** (ERROR) | Conditions preventing proper processing (usually causes termination) |
| **W** (WARNING) | Issues that may affect correct processing but allow continuation |
| **N** (NOTICE) | Interesting program actions, useful for server monitoring |
| **I** (INFO) | Description of program actions and file descriptor lifecycles |
| **D** (DEBUG) | Detailed information about program internals, system calls, and results |

## Exit Status

- **0**: Terminated due to EOF or inactivity timeout
- **Positive**: Terminated due to error
- **Negative**: Terminated due to fatal error

## Signals

| Signal | Effect |
|--------|--------|
| `SIGUSR1` | Log current transfer statistics |

## Environment Variables (Input)

| Variable | Description |
|----------|-------------|
| `SOCAT_DEFAULT_LISTEN_IP` | Values 4 or 6. Sets IP version for listen/recv/recvfrom addresses |
| `SOCAT_PREFERRED_RESOLVE_IP` | Values 0, 4, or 6. Sets preferred IP version for hostname resolution |
| `SOCAT_MAIN_WAIT` | Seconds to sleep at beginning of main() for debugging |
| `SOCAT_TRANSFER_WAIT` | Seconds to sleep after opening addresses before transfer loop |
| `SOCAT_FORK_WAIT` | Seconds to sleep parent and child processes after fork() |
| `HOSTNAME` | Used to determine hostname for logging with -lh |
| `LOGNAME` | Used as socks client username if socksuser not given |
| `USER` | Fallback for LOGNAME for socks client username |

## Environment Variables (Output)

| Variable | Description |
|----------|-------------|
| `SOCAT_VERSION` | Socat version string (e.g., "1.7.0.0") |
| `SOCAT_PID` | Process ID (child ID after fork with fork option) |
| `SOCAT_PPID` | Parent process ID (master process ID after fork) |
| `SOCAT_PEERADDR` | Peer socket address (for LISTEN and RECVFROM addresses) |
| `SOCAT_PEERPORT` | Peer port number (for TCP, UDP, SCTP) |
| `SOCAT_SOCKADDR` | Local socket address (for LISTEN addresses) |
| `SOCAT_SOCKPORT` | Local port (for TCP-LISTEN, UDP-LISTEN, SCTP-LISTEN) |
| `SOCAT_TIMESTAMP` | Timestamp from so-timestamp option |
| `SOCAT_IP_OPTIONS` | IP options from ip-recvopts option |
| `SOCAT_IP_DSTADDR` | Destination address from ip-recvdstaddr/ip-pktinfo |
| `SOCAT_IP_IF` | Interface name from ip-recvif/ip-pktinfo |
| `SOCAT_IP_LOCADDR` | Interface address from ip-pktinfo |
| `SOCAT_IP_TOS` | Type of service from ip-recvtos |
| `SOCAT_IP_TTL` | Time to live from ip-recvttl |
| `SOCAT_IPV6_HOPLIMIT` | Hop limit from ipv6-recvhoplimit |
| `SOCAT_IPV6_DSTADDR` | Destination address from ipv6-recvpktinfo |
| `SOCAT_IPV6_TCLASS` | Transfer class from ipv6-recvtclass |
| `SOCAT_OPENSSL_X509_ISSUER` | Issuer field from peer certificate |
| `SOCAT_OPENSSL_X509_SUBJECT` | Subject field from peer certificate |
| `SOCAT_OPENSSL_X509_COMMONNAME` | CommonName from peer certificate subject |
