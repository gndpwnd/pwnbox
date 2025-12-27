# socat - Official Documentation

Source: http://www.dest-unreach.org/socat/doc/socat.html

Downloaded: 2025-12-26T20:14:20.633291

---

* * *

# socat

## CONTENTS

[NAME](socat.html#NAME)  
[SYNOPSIS](socat.html#SYNOPSIS)  
[DESCRIPTION](socat.html#DESCRIPTION)  
[OPTIONS](socat.html#OPTIONS)  
[ADDRESS SPECIFICATIONS](socat.html#ADDRESS_SPECIFICATIONS)  
[ADDRESS TYPES](socat.html#ADDRESS_TYPES)  
[ADDRESS OPTIONS](socat.html#ADDRESS_OPTIONS)  
[DATA VALUES](socat.html#VALUES)  
[EXAMPLES](socat.html#EXAMPLES)  
[DIAGNOSTICS](socat.html#DIAGNOSTICS)  
[FILES](socat.html#FILES)  
[ENVIRONMENT VARIABLES](socat.html#ENVIRONMENT_VARIABLES)  
[CREDITS](socat.html#CREDITS)  
[VERSION](socat.html#VERSION)  
[BUGS](socat.html#BUGS)  
[SEE ALSO](socat.html#SEEALSO)  

## NAME

socat - Multipurpose relay (SOcket CAT)

## SYNOPSIS

`socat [options] <address> <address>`  
`socat -V`  
`socat -h[h[h]] | -?[?[?]]`  
`filan`  
`procan`

## DESCRIPTION

**Socat** is a command line based utility that establishes two bidirectional
byte streams and transfers data between them. Because the streams can be
constructed from a large set of different types of data sinks and sources (see
[address types](socat.html#ADDRESS_TYPES)), and because lots of [address
options](socat.html#ADDRESS_OPTIONS) may be applied to the streams, socat can
be used for many different purposes.

**Filan** is a utility that prints information about its active file
descriptors to stdout. It has been written for debugging **socat** , but might
be useful for other purposes too. Use the -h option to find more infos.

**Procan** is a utility that prints information about process parameters to
stdout. It has been written to better understand some UNIX process properties
and for debugging **socat** , but might be useful for other purposes too.

The life cycle of a **socat** instance typically consists of four phases.

In the _init_ phase, the command line options are parsed and logging is
initialized.

During the _open_ phase, **socat** opens the first address and afterwards the
second address. These steps are usually blocking; thus, especially for complex
address types like socks, connection requests or authentication dialogs must
be completed before the next step is started.

In the _transfer_ phase, **socat** watches both streams' read and write file
descriptors via `select()` , and, when data is available on one side _and_ can
be written to the other side, socat reads it, performs newline character
conversions if required, and writes the data to the write file descriptor of
the other stream, then continues waiting for more data in both directions.

When one of the streams effectively reaches EOF, the _closing_ phase begins.
**Socat** transfers the EOF condition to the other stream, i.e. tries to
shutdown only its write stream, giving it a chance to terminate gracefully.
For a defined time **socat** continues to transfer data in the other
direction, but then closes all remaining channels and terminates.

## OPTIONS

**Socat** provides some command line options that modify the behaviour of the
program. They have nothing to do with so called [address
options](socat.html#ADDRESS_OPTIONS) that are used as parts of [address
specifications](socat.html#ADDRESS_SPECIFICATIONS).

****`-V`****     Print version and available feature information to stdout,
and exit.

****`-h | -?`****     Print a help text to stdout describing command line options and available address types, and exit. 

****`-hh | -??`****     Like -h, plus a list of the short names of all available address options. Some options are platform dependent, so this output is helpful for checking the particular implementation. 

****`-hhh | -???`****     Like -hh, plus a list of all available address option names. 

****`-d`****     Without this option, only fatal, error, and warning messages
are printed; applying this option also prints notice messages. See
[DIAGNOSTICS](socat.html#DIAGNOSTICS) for more information.

****`-d0`****     With this option, only fatal and error messages are printed;
this restores the behaviour of **socat** up to version 1.7.4.

****`-d -d | -dd | -d2`****     Prints fatal, error, warning, and notice messages. 

****`-d -d -d | -ddd | -d3`****     Prints fatal, error, warning, notice, and info messages. 

****`-d -d -d -d | -dddd | -d4`****     Prints fatal, error, warning, notice, info, and debug messages. 

****`-D`****     Logs information about file descriptors before starting the
transfer phase.

****`--experimental`****     New features that are not well tested or are
subject to change in the future must be explicitly enabled using this option.

****`-ly[<facility>]`****     Writes messages to syslog instead of stderr;
severity as defined with -d option. With optional
[<facility>](socat.html#TYPE_FACILITY), the syslog type can be selected,
default is "daemon". Third party libraries might not obey this option.

****`-lf`**` <logfile>`**     Writes messages to <logfile>
[[filename](socat.html#TYPE_FILENAME)] instead of stderr. Some third party
libraries, in particular libwrap, might not obey this option.

****`-ls`****     Writes messages to stderr (this is the default). Some third
party libraries might not obey this option, in particular libwrap appears to
only log to syslog.

****`-lp`**`<progname>`**     Overrides the program name printed in error
messages and used for constructing environment variable names.

****`-lu`****     Extends the timestamp of error messages to microsecond
resolution. Does not work when logging to syslog.

****`-lm[<facility>]`****     Mixed log mode. During startup messages are
printed to stderr; when **socat** starts the transfer phase loop or daemon
mode (i.e. after opening all streams and before starting data transfer, or,
with listening sockets with fork option, before the first accept call), it
switches logging to syslog. With optional
[<facility>](socat.html#TYPE_FACILITY), the syslog type can be selected,
default is "daemon".

****`-lh`****     Adds hostname to log messages. Uses the value from
environment variable HOSTNAME or the value retrieved with `uname()` if
HOSTNAME is not set.

****`-v`****     Writes the transferred data not only to their target streams,
but also to stderr. The output format is text with some conversions for
readability, and prefixed with "> " or "< " indicating flow directions.

****`-x`****     Writes the transferred data not only to their target streams,
but also to stderr. The output format is hexadecimal, prefixed with "> " or "<
" indicating flow directions. Can be combined with `-v` .

****`-r<file>`****     Dumps the raw (binary) data flowing from left to right
address to the given file. The file name may contain references to environment
variables and `$$` (pid), `$PROGNAME` (see option [option
-lp](socat.html#option_lp)), `$TIMESTAMP` (uses format %Y%m%dT%H%M%S), and
`MICROS` (microseconds of daytime). These references have to be protected from
shell expansion of course.

****`-R<file>`****     Dumps the raw (binary) data flowing from right to left
address to the given file. See [option -r](socat.html#option_r) for
customization of file name.

****`-b`**`<size>`**     Sets the data transfer block <size>
[[size_t](socat.html#TYPE_SIZE_T)]. At most <size> bytes are transferred per
step. Default is 8192 bytes.

****`-s`****     By default, **socat** terminates when an error occurred to
prevent the process from running when some option could not be applied. With
this option, **socat** is sloppy with errors and tries to continue. Even with
this option, socat will exit on fatals, and will abort connection attempts
when security checks failed.

****`-S`**`<signals-bitmap>`**     Changes the set of signals that are caught
by **socat** just for printing an log message. This catching is useful to get
the information about the signal into **socat** s log, but prevents core dump
or other standard actions. The default set of these signals is SIGHUP, SIGINT,
SIGQUIT, SIGILL, SIGABRT, SIGBUS, SIGFPE, SIGSEGV, and SIGTERM; replace this
set (0x89de on Linux) with a bitmap (e.g., SIGFPE has value 8 and its bit is
0x0080).  
Note: Signals SIGHUP, SIGINT, SIGQUIT, SIGUSR1, SIGPIPE, SIGALRM, SIGTERM, and
SIGCHLD may be handled specially anyway.

****`-t`**`<timeout>`**     When one channel has reached EOF (that is not
ignored through option ([ignoreoef](??), the write part of the other channel
is shut down. Then, **socat** waits <timeout>
[[timeval](socat.html#TYPE_TIMEVAL)] seconds before terminating. When during
the timeout interval the read part of that other channel gives EOF, socat
terminates without awaiting the timeout. Default is 0.5 seconds, 0 is valid.
This timeout is only useful with addresses where write and read part can be
closed or shut down independently.

****`-T`**`<timeout>`**     Total inactivity timeout: when **socat** is
already in the transfer loop and nothing has happened for <timeout>
[[timeval](socat.html#TYPE_TIMEVAL)] seconds (no data arrived, no interrupt
occurred...) then it terminates. Up to version 1.8.0.0 "0" meant "infinite";
since version 1.8.0.1 "0" means 0 and values <0 mean infinite, default is -1.  
Useful with protocols like UDP that cannot transfer EOF.

****`-u`****     Uses unidirectional mode. The first address is only used for
reading, and the second address is only used for writing
([example](socat.html#EXAMPLE_option_u)).

****`-U`****     Uses unidirectional mode in reverse direction. The first
address is only used for writing, and the second address is only used for
reading.

****`-g`****     During address option parsing, don't check if the option is
considered useful in the given address environment. Use it if you want to
force, e.g., appliance of a socket option to a serial device.

****`-L`**`<lockfile>`**     If lockfile exists, exits with error. If lockfile
does not exist, creates it and continues, unlinks lockfile on exit.

****`-W`**`<lockfile>`**     If lockfile exists, waits until it disappears.
When lockfile does not exist, creates it and continues, unlinks lockfile on
exit.

****`-4`****     Use IP version 4 in case the addresses do not implicitly or
explicitly specify a version. Since version 1.8.0.1 this is the default.

****`-6`****     Use IP version 6 in case the addresses do not implicitly or
explicitly specify a version.

****`-0`****     Do not prefer a particular IP version; this lets passive
addresses (LISTEN, RECV, ...) serve both versions on some platforms (not BSD).

****`--statistics`****  

****`-S`****     Logs transfer statistics (bytes and blocks counters for both
directions) before terminating **socat**.  
See also [signal USR1](socat.html#signal_usr1).  
This feature is experimental and might change in future versions.

## ADDRESS SPECIFICATIONS

With the address command line arguments, the user gives **socat** instructions
and the necessary information for establishing the byte streams.

An address specification usually consists of an address type keyword, zero or
more required address parameters separated by ':' from the keyword and from
each other, and zero or more address options separated by ','.

The keyword specifies the address type (e.g., TCP4, OPEN, EXEC). For some
keywords there exist synonyms ('-' for STDIO, TCP for TCP4). Keywords are case
insensitive. For a few special address types, the keyword may be omitted:
Address specifications starting with a number are assumed to be FD (raw file
descriptor) addresses; if a '/' is found before the first ':' or ',', GOPEN
(generic file open) is assumed.

The required number and type of address parameters depend on the address type.
E.g., TCP4 requires a server specification (name or address), and a port
specification (number or service name).

Zero or more address options may be given with each address. They influence
the address in some ways. Options consist of an option keyword or an option
keyword and a value, separated by '='. Option keywords are case insensitive.
For filtering the options that are useful with an address type, each option is
member of one option group. For each address type there is a set of option
groups allowed. Only options belonging to one of these address groups may be
used (except with [option -g](socat.html#option_g)).

Address specifications following the above schema are also called _single_
address specifications. Two single addresses can be combined with "!!" to form
a _dual_ type address for one channel. Here, the first address is used by
**socat** for reading data, and the second address for writing data. There is
no way to specify an option only once for being applied to both single
addresses.

Usually, addresses are opened in read/write mode. When an address is part of a
dual address specification, or when [option -u](socat.html#option_u) or
[-U](socat.html#option_U) is used, an address might be used only for reading
or for writing. Considering this is important with some address types.

With socat version 1.5.0 and higher, the lexical analysis tries to handle
quotes and parenthesis meaningfully and allows escaping of special characters.
If one of the characters ( { [ ' is found, the corresponding closing character
- ) } ] ' - is looked for; they may also be nested. Within these constructs,
socats special characters and strings : , !! are not handled specially. All
those characters and strings can be escaped with \ or within ""

## ADDRESS TYPES

This section describes the available address types with their keywords,
parameters, and semantics.

****`CREATE:<filename>`****     Opens [<filename>](socat.html#TYPE_FILENAME)
with `creat()` and uses the file descriptor for writing. This is a write-only
address because a file opened with `creat` cannot be read from. See options
[-u](socat.html#option_u) and [-U](socat.html#option_U), and [dual
addresses](socat.html#ADDRESS_DUAL).  
Flags like O_LARGEFILE cannot be applied. If you need them use
[OPEN](socat.html#ADDRESS_OPEN) with options
[create](socat.html#OPTION_O_CREAT),[create](socat.html#OPTION_O_TRUNC).  
<filename> must be a valid existing or not existing path. If <filename> is a
named pipe, `creat()` might block; if <filename> refers to a socket, this is
an error.  
Option groups:
[FD](socat.html#GROUP_FD),[REG](socat.html#GROUP_REG),[NAMED](socat.html#GROUP_NAMED)  
Useful options: [mode](socat.html#OPTION_UMASK),
[mode](socat.html#OPTION_MODE), [user](socat.html#OPTION_USER),
[group](socat.html#OPTION_GROUP), [unlink-
early](socat.html#OPTION_UNLINK_EARLY), [unlink-
late](socat.html#OPTION_UNLINK_LATE), [append](socat.html#OPTION_APPEND)  
See also: [OPEN](socat.html#ADDRESS_OPEN), [GOPEN](socat.html#ADDRESS_GOPEN)

****`DCCP-CONNECT:<host>:<port>`** (**`DCCP:<host>:<port>`**)**
Establishes a DCCP connect to the specified <host> [[IP
address](socat.html#TYPE_IP_ADDRESS)] and <port> [[DCCP
service](socat.html#TYPE_TCP_SERVICE)] using IP version 4 or 6 depending on
address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[SCTP](socat.html#GROUP_SCTP),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [bind](socat.html#OPTION_BIND), [connect-
timeout](socat.html#OPTION_CONNECT_TIMEOUT), [tos](socat.html#OPTION_TOS),
[dccp-set-ccid](socat.html#OPTION_DCCP_SET_CCID),
[nonblock](socat.html#OPTION_O_NONBLOCK),
[sourceport](socat.html#OPTION_SOURCEPORT), [retry](socat.html#OPTION_RETRY),
[readbytes](socat.html#OPTION_READBYTES)  
See also: [DCCP4-CONNECT](socat.html#ADDRESS_DCCP4_CONNECT),
[DCCP6-CONNECT](socat.html#ADDRESS_DCCP6_CONNECT), [DCCP-
LISTEN](socat.html#ADDRESS_DCCP_LISTEN), [TCP-
CONNECT](socat.html#ADDRESS_TCP_CONNECT) [SCTP-
CONNECT](socat.html#ADDRESS_SCTP_CONNECT)

****`DCCP4-CONNECT:<host>:<port>`** (**`DCCP4:<host>:<port>`**)**     Like
[DCCP-CONNECT](socat.html#ADDRESS_DCCP_CONNECT), but only supports IPv4
protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[DCCP](socat.html#GROUP_DCCP),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  

****`DCCP6-CONNECT:<host>:<port>`** (**`DCCP6:<host>:<port>`**)**     Like
[DCCP-CONNECT](socat.html#ADDRESS_DCCP_CONNECT), but only supports IPv6
protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[DCCP](socat.html#GROUP_DCCP),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  

****`DCCP-LISTEN:<port>`** (**`DCCP-L:<port>`**)**     Listens on <port>
[[DCCP service](socat.html#TYPE_TCP_SERVICE)] and accepts an DCCP connection.
The IP version is 4 or the one specified with address option
[pf](socat.html#OPTION_PROTOCOL_FAMILY), socat option
([-4](socat.html#option_4), [-6](socat.html#option_6)), or environment
variable [SOCAT_DEFAULT_LISTEN_IP](socat.html#ENV_SOCAT_DEFAULT_LISTEN_IP).
Note that opening this address usually blocks until a client connects.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[DCCP](socat.html#GROUP_DCCP),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [fork](socat.html#OPTION_FORK),
[bind](socat.html#OPTION_BIND), [range](socat.html#OPTION_RANGE), [max-
children](socat.html#OPTION_MAX_CHILDREN),
[backlog](socat.html#OPTION_BACKLOG), [accept-
timeout](socat.html#OPTION_ACCEPT_TIMEOUT), [dccp-set-
sid](socat.html#OPTION_DCCP_SET_CCID), [su](socat.html#OPTION_SUBSTUSER),
[reuseaddr](socat.html#OPTION_SO_REUSEADDR), [retry](socat.html#OPTION_RETRY)  
See also: [DCCP4-LISTEN](socat.html#ADDRESS_DCCP4_LISTEN),
[DCCP6-LISTEN](socat.html#ADDRESS_DCCP6_LISTEN), [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN), [SCTP-
LISTEN](socat.html#ADDRESS_SCTP_LISTEN), [DCCP-
CONNECT](socat.html#ADDRESS_DCCP_CONNECT)

****`DCCP4-LISTEN:<port>`** (**`DCCP4-L:<port>`**)**     Like [DCCP-
LISTEN](socat.html#ADDRESS_DCCP_LISTEN), but only supports IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4),[DCCP](socat.html#GROUP_DCCP),[RETRY](socat.html#GROUP_RETRY)  

****`DCCP6-LISTEN:<port>`** (**`DCCP6-L:<port>`**)**     Like [DCCP-
LISTEN](socat.html#ADDRESS_DCCP_LISTEN), but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP6](socat.html#GROUP_IP6),[DCCP](socat.html#GROUP_DCCP),[RETRY](socat.html#GROUP_RETRY)  

****`EXEC:<command-line>`****     Forks a sub process that establishes
communication with its parent process and invokes the specified program with
`execvp()` . [<command-line>](socat.html#TYPE_COMMAND_LINE) is a simple
command with arguments separated by single spaces. If the program name
contains a '/', the part after the last '/' is taken as ARGV[0]. If the
program name is a relative path, the `execvp()` semantics for finding the
program via `$PATH` apply. After successful program start, **socat** writes
data to stdin of the process and reads from its stdout using a UNIX domain
socket generated by `socketpair()` per default.
([example](socat.html#EXAMPLE_ADDRESS_EXEC))  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[EXEC](socat.html#GROUP_EXEC),[FORK](socat.html#GROUP_FORK),[TERMIOS](socat.html#GROUP_TERMIOS)  
Useful options: [path](socat.html#OPTION_PATH),
[fdin](socat.html#OPTION_FDIN), [fdout](socat.html#OPTION_FDOUT),
[chroot](socat.html#OPTION_CHROOT), [su](socat.html#OPTION_SUBSTUSER),
[su-d](socat.html#OPTION_SUBSTUSER_DELAYED),
[nofork](socat.html#OPTION_NOFORK), [socktype](socat.html#OPTION_SO_TYPE),
[pty](socat.html#OPTION_PTY), [stderr](socat.html#OPTION_STDERR),
[ctty](socat.html#OPTION_CTTY), [setsid](socat.html#OPTION_SETSID),
[pipes](socat.html#OPTION_PIPES), [umask](socat.html#OPTION_UMASK),
[login](socat.html#OPTION_LOGIN), [sigint](socat.html#OPTION_SIGINT),
[sigquit](socat.html#OPTION_SIGQUIT), [netns](socat.html#OPTION_NETNS)  
See also:
[SYSTEM](socat.html#ADDRESS_SYSTEM),[SHELL](socat.html#ADDRESS_SHELL)

****`FD:<fdnum>`****     Uses the file descriptor
[<fdnum>](socat.html#TYPE_FDNUM). It must already exist as valid UN*X file
descriptor.  
Option groups: [FD](socat.html#GROUP_FD)
([TERMIOS](socat.html#GROUP_TERMIOS),[REG](socat.html#GROUP_REG),[SOCKET](socat.html#GROUP_SOCKET))  
See also: [STDIO](socat.html#ADDRESS_STDIO),
[STDIN](socat.html#ADDRESS_STDIN), [STDOUT](socat.html#ADDRESS_STDOUT),
[STDERR](socat.html#ADDRESS_STDERR)

****`GOPEN:<filename>`****     (Generic open) This address type tries to
handle any file system entry except directories usefully.
[<filename>](socat.html#TYPE_FILENAME) may be a relative or absolute path. If
it already exists, its type is checked. In case of a UNIX domain socket,
**socat** connects; if connecting fails, **socat** assumes a datagram socket
and uses `sendto()` calls. If the entry is not a socket, **socat** opens it
applying the `O_APPEND` flag. If it does not exist, it is opened with flag
`O_CREAT` as a regular file ([example](socat.html#EXAMPLE_ADDRESS_GOPEN)).  
Option groups:
[FD](socat.html#GROUP_FD),[REG](socat.html#GROUP_REG),[SOCKET](socat.html#GROUP_SOCKET),[NAMED](socat.html#GROUP_NAMED),[OPEN](socat.html#GROUP_OPEN)  
See also: [OPEN](socat.html#ADDRESS_OPEN), [CREATE](socat.html#ADDRESS_CREAT),
[UNIX-CONNECT](socat.html#ADDRESS_UNIX_CONNECT)

****`IP-SENDTO:<host>:<protocol>`****     Opens a raw IP socket. Depending on
host specification or option [pf](socat.html#OPTION_PROTOCOL_FAMILY), IP
protocol version 4 or 6 is used. It uses
[<protocol>](socat.html#TYPE_PROTOCOL) to send packets to <host> [[IP
address](socat.html#TYPE_IP_ADDRESS)] and receives packets from host, ignores
packets from other hosts. Protocol 255 uses the raw socket with the IP header
being part of the data.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6)  
Useful options: [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[ttl](socat.html#OPTION_TTL)  
See also: [IP4-SENDTO](socat.html#ADDRESS_IP4_SENDTO),
[IP6-SENDTO](socat.html#ADDRESS_IP6_SENDTO), [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM), [IP-
RECV](socat.html#ADDRESS_IP_RECV), [UDP-
SENDTO](socat.html#ADDRESS_UDP_SENDTO), [UNIX-
SENDTO](socat.html#ADDRESS_UNIX_SENDTO)

****`INTERFACE:<interface>`****     Communicates with a network connected on
an interface using raw packets including link level data.
[<interface>](socat.html#TYPE_INTERFACE) is the name of the network interface.
Currently only available on Linux.  
Option groups: [FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET)  
Useful options: [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[type](socat.html#OPTION_SO_TYPE)  
See also: [ip-recv](socat.html#ADDRESS_IP_RECV)

****`IP4-SENDTO:<host>:<protocol>`****     Like [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO), but always uses IPv4.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4)  

****`IP6-SENDTO:<host>:<protocol>`****     Like [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO), but always uses IPv6.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6)  

****`IP-DATAGRAM:<address>:<protocol>`****     Sends outgoing data to the
specified address which may in particular be a broadcast or multicast address.
Packets arriving on the local socket are checked if their source addresses
match [RANGE](socat.html#OPTION_RANGE) or
[TCPWRAP](socat.html#OPTION_TCPWRAPPERS) options. This address type can for
example be used for implementing symmetric or asymmetric broadcast or
multicast communications.  
Option groups: [FD](socat.html#GROUP_FD), [SOCKET](socat.html#GROUP_SOCKET),
[IP4](socat.html#GROUP_IP4), [IP6](socat.html#GROUP_IP6),
[RANGE](socat.html#GROUP_RANGE)  
Useful options: [bind](socat.html#OPTION_BIND),
[range](socat.html#OPTION_RANGE), [tcpwrap](socat.html#OPTION_TCPWRAPPERS),
[broadcast](socat.html#OPTION_SO_BROADCAST), [ip-multicast-
loop](socat.html#OPTION_IP_MULTICAST_LOOP), [ip-multicast-
ttl](socat.html#OPTION_IP_MULTICAST_TTL), [ip-multicast-
if](socat.html#OPTION_IP_MULTICAST_IF), [ip-add-
membership](socat.html#OPTION_IP_ADD_MEMBERSHIP), [ip-add-source-
membership](socat.html#OPTION_IP_ADD_SOURCE_MEMBERSHIP), [ipv6-join-
group](socat.html#OPTION_IPV6_JOIN_GROUP), [ipv6-join-source-
group](socat.html#OPTION_IPV6_JOIN_SOURCE_GROUP),
[ttl](socat.html#OPTION_TTL), [tos](socat.html#OPTION_TOS),
[pf](socat.html#OPTION_PROTOCOL_FAMILY)  
See also: [IP4-DATAGRAM](socat.html#ADDRESS_IP4_DATAGRAM),
[IP6-DATAGRAM](socat.html#ADDRESS_IP6_DATAGRAM), [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO), [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM), [IP-
RECV](socat.html#ADDRESS_IP_RECV), [UDP-
DATAGRAM](socat.html#ADDRESS_UDP_DATAGRAM)

****`IP4-DATAGRAM:<host>:<protocol>`****     Like [IP-
DATAGRAM](socat.html#ADDRESS_IP_DATAGRAM), but always uses IPv4.
([example](socat.html#EXAMPLE_ADDRESS_IP4_BROADCAST_CLIENT))  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[RANGE](socat.html#GROUP_RANGE)  

****`IP6-DATAGRAM:<host>:<protocol>`****     Like [IP-
DATAGRAM](socat.html#ADDRESS_IP_DATAGRAM), but always uses IPv6. Please note
that IPv6 does not know broadcasts.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[RANGE](socat.html#GROUP_RANGE)  

****`IP-RECVFROM:<protocol>`****     Opens a raw IP socket of
[<protocol>](socat.html#TYPE_PROTOCOL). Depending on option
[pf](socat.html#OPTION_PROTOCOL_FAMILY), IP protocol version 4 or 6 is used.
It receives one packet from an unspecified peer and may send one or more
answer packets to that peer. This mode is particularly useful with fork option
where each arriving packet - from arbitrary peers - is handled by its own sub
process. This allows a behaviour similar to typical UDP based servers like
ntpd or named.  
Please note that the reply packets might be fetched as incoming traffic when
sender and receiver IP address are identical because there is no port number
to distinguish the sockets.  
This address works well with IP-SENDTO address peers (see above). Protocol 255
uses the raw socket with the IP header being part of the data.  
See the [note about RECVFROM addresses](socat.html#NOTE_RECVFROM).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[fork](socat.html#OPTION_FORK), [range](socat.html#OPTION_RANGE),
[ttl](socat.html#OPTION_TTL), [broadcast](socat.html#OPTION_SO_BROADCAST)  
See also: [IP4-RECVFROM](socat.html#ADDRESS_IP4_RECVFROM),
[IP6-RECVFROM](socat.html#ADDRESS_IP6_RECVFROM), [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO), [IP-RECV](socat.html#ADDRESS_IP_RECV),
[UDP-RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), [UNIX-
RECVFROM](socat.html#ADDRESS_UNIX_RECVFROM)

****`IP4-RECVFROM:<protocol>`****     Like [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM), but always uses IPv4.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE)  

****`IP6-RECVFROM:<protocol>`****     Like [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM), but always uses IPv6.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE)  

****`IP-RECV:<protocol>`****     Opens a raw IP socket of
[<protocol>](socat.html#TYPE_PROTOCOL). Depending on option
[pf](socat.html#OPTION_PROTOCOL_FAMILY), IP protocol version 4 or 6 is used.
It receives packets from multiple unspecified peers and merges the data. No
replies are possible, this is a read-only address, see options
[-u](socat.html#option_u) and [-U](socat.html#option_U), and [dual
addresses](socat.html#ADDRESS_DUAL). It can be, e.g., addressed by socat IP-
SENDTO address peers. Protocol 255 uses the raw socket with the IP header
being part of the data.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[range](socat.html#OPTION_RANGE)  
See also: [IP4-RECV](socat.html#ADDRESS_IP4_RECV),
[IP6-RECV](socat.html#ADDRESS_IP6_RECV), [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO), [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM), [UDP-
RECV](socat.html#ADDRESS_UDP_RECV), [UNIX-RECV](socat.html#ADDRESS_UNIX_RECV)

****`IP4-RECV:<protocol>`****     Like [IP-RECV](socat.html#ADDRESS_IP_RECV),
but always uses IPv4.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[RANGE](socat.html#GROUP_RANGE)  

****`IP6-RECV:<protocol>`****     Like [IP-RECV](socat.html#ADDRESS_IP_RECV),
but always uses IPv6.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[RANGE](socat.html#GROUP_RANGE)  

****`OPEN:<filename>`****     Opens [<filename>](socat.html#TYPE_FILENAME)
using the `open()` system call ([example](socat.html#EXAMPLE_ADDRESS_OPEN)).
This operation fails on UNIX domain sockets.  
Note: This address type is rarely useful in bidirectional mode.  
Option groups:
[FD](socat.html#GROUP_FD),[REG](socat.html#GROUP_REG),[NAMED](socat.html#GROUP_NAMED),[OPEN](socat.html#GROUP_OPEN)  
Useful options: [creat](socat.html#OPTION_O_CREAT),
[excl](socat.html#OPTION_O_EXCL), [noatime](socat.html#OPTION_O_NOATIME),
[nofollow](socat.html#OPTION_NOFOLLOW), [append](socat.html#OPTION_APPEND),
[rdonly](socat.html#OPTION_RDONLY), [wronly](socat.html#OPTION_WRONLY),
[lock](socat.html#OPTION_LOCK), [readbytes](socat.html#OPTION_READBYTES),
[ignoreeof](socat.html#OPTION_IGNOREEOF)  
See also: [CREATE](socat.html#ADDRESS_CREAT),
[GOPEN](socat.html#ADDRESS_GOPEN), [UNIX-
CONNECT](socat.html#ADDRESS_UNIX_CONNECT)

****`OPENSSL:<host>:<port>`****     Tries to establish a SSL connection to
<port> [[TCP service](socat.html#TYPE_TCP_SERVICE)] on <host> [[IP
address](socat.html#TYPE_IP_ADDRESS)] using TCP/IP version 4 or 6 depending on
address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY).  
NOTE: Up to version 1.7.2.4 the server certificate was only checked for
validity against the system certificate store or
[cafile](socat.html#OPTION_OPENSSL_CAFILE) or
[capath](socat.html#OPTION_OPENSSL_CAPATH), but not for match with the
server's name or its IP address. Since version 1.7.3.0 socat checks the peer
certificate for match with the <host> parameter or the value of the [openssl-
commonname](socat.html#OPTION_OPENSSL_COMMONNAME) option. Socat tries to match
it against the certificates subject commonName, and the certificates extension
subjectAltName DNS names. Wildcards in the certificate are supported.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[OPENSSL](socat.html#GROUP_OPENSSL),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [min-proto-
version](socat.html#OPTION_OPENSSL_MIN_PROTO_VERSION),
[cipher](socat.html#OPTION_OPENSSL_CIPHERLIST),
[verify](socat.html#OPTION_OPENSSL_VERIFY),
[commonname](socat.html#OPTION_OPENSSL_COMMONNAME),
[cafile](socat.html#OPTION_OPENSSL_CAFILE),
[capath](socat.html#OPTION_OPENSSL_CAPATH),
[certificate](socat.html#OPTION_OPENSSL_CERTIFICATE),
[key](socat.html#OPTION_OPENSSL_KEY),
[compress](socat.html#OPTION_OPENSSL_COMPRESS),
[bind](socat.html#OPTION_BIND), [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[connect-timeout](socat.html#OPTION_CONNECT_TIMEOUT),
[sourceport](socat.html#OPTION_SOURCEPORT), [retry](socat.html#OPTION_RETRY)  
See also: [OPENSSL-LISTEN](socat.html#ADDRESS_OPENSSL_LISTEN),
[TCP](socat.html#ADDRESS_TCP_CONNECT)

****`OPENSSL-LISTEN:<port>`****     Listens on tcp <port> [[TCP
service](socat.html#TYPE_TCP_SERVICE)]. The IP version is 4 or the one
specified with [pf](socat.html#OPTION_PROTOCOL_FAMILY). When a connection is
accepted, this address behaves as SSL server.  
Note: You probably want to use the
[certificate](socat.html#OPTION_OPENSSL_CERTIFICATE) option with this address.  
NOTE: The client certificate is only checked for validity against
[cafile](socat.html#OPTION_OPENSSL_CAFILE) or
[capath](socat.html#OPTION_OPENSSL_CAPATH), but not for match with the
client's name or its IP address!  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[LISTEN](socat.html#GROUP_LISTEN),[OPENSSL](socat.html#GROUP_OPENSSL),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [pf](socat.html#OPTION_PROTOCOL_FAMILY), [min-proto-
version](socat.html#OPTION_OPENSSL_MIN_PROTO_VERSION),
[cipher](socat.html#OPTION_OPENSSL_CIPHERLIST),
[verify](socat.html#OPTION_OPENSSL_VERIFY),
[commonname](socat.html#OPTION_OPENSSL_COMMONNAME),
[cafile](socat.html#OPTION_OPENSSL_CAFILE),
[capath](socat.html#OPTION_OPENSSL_CAPATH),
[certificate](socat.html#OPTION_OPENSSL_CERTIFICATE),
[key](socat.html#OPTION_OPENSSL_KEY),
[compress](socat.html#OPTION_OPENSSL_COMPRESS),
[fork](socat.html#OPTION_FORK), [bind](socat.html#OPTION_BIND),
[range](socat.html#OPTION_RANGE), [tcpwrap](socat.html#OPTION_TCPWRAPPERS),
[su](socat.html#OPTION_SUBSTUSER),
[reuseaddr](socat.html#OPTION_SO_REUSEADDR), [retry](socat.html#OPTION_RETRY)  
See also: [OPENSSL](socat.html#ADDRESS_OPENSSL_CONNECT), [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN)

****`OPENSSL-DTLS-CLIENT:<host>:<port>`****     Tries to establish a DTLS
connection to <port> [[UDP service](socat.html#TYPE_UDP_SERVICE)] on <host>
[[IP address](socat.html#TYPE_IP_ADDRESS)] using UDP/IP version 4 or 6
depending on address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY).  
**Socat** checks the peer certificates subjectAltName or commonName against
the addresses option [openssl-
commonname](socat.html#OPTION_OPENSSL_COMMONNAME) or the host name. Wildcards
in the certificate are supported.  
Use **socat** option [-b](socat.html#option_b) to make datagrams small enough
to fit with overhead on the network. Use option [-T](socat.html#option_T) to
prevent indefinite hanging when peer went down quietly.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[OPENSSL](socat.html#GROUP_OPENSSL),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [min-proto-
version](socat.html#OPTION_OPENSSL_MIN_PROTO_VERSION),
[cipher](socat.html#OPTION_OPENSSL_CIPHERLIST),
[verify](socat.html#OPTION_OPENSSL_VERIFY),
[commonname](socat.html#OPTION_OPENSSL_COMMONNAME),
[cafile](socat.html#OPTION_OPENSSL_CAFILE),
[capath](socat.html#OPTION_OPENSSL_CAPATH),
[certificate](socat.html#OPTION_OPENSSL_CERTIFICATE),
[key](socat.html#OPTION_OPENSSL_KEY),
[compress](socat.html#OPTION_OPENSSL_COMPRESS),
[bind](socat.html#OPTION_BIND), [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[sourceport](socat.html#OPTION_SOURCEPORT), [retry](socat.html#OPTION_RETRY),
[rcvtimeo](socat.html#OPTION_SO_RCVTIMOE)  
See also: [OPENSSL-DTLS-SERVER](socat.html#ADDRESS_OPENSSL_DTLS_SERVER),
[OPENSSL-CONNECT](socat.html#ADDRESS_OPENSSL_CONNECT), [UDP-
CONNECT](socat.html#ADDRESS_UDP_CONNECT)

****`OPENSSL-DTLS-SERVER:<port>`****     Listens on UDP <port> [[UDP
service](socat.html#TYPE_UDP_SERVICE)]. The IP version is 4 or the one
specified with [pf](socat.html#OPTION_PROTOCOL_FAMILY). When a connection is
accepted, this address behaves as DTLS server.  
Note: You probably want to use the
[certificate](socat.html#OPTION_OPENSSL_CERTIFICATE) option with this address.  
NOTE: The client certificate is only checked for validity against
[cafile](socat.html#OPTION_OPENSSL_CAFILE) or
[capath](socat.html#OPTION_OPENSSL_CAPATH), but not for match with the
client's name or its IP address! Use **socat** option
[-b](socat.html#option_b) to make datagrams small enough to fit with overhead
on the network. Use option [-T](socat.html#option_T) to prevent indefinite
hanging when peer went down quietly.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[LISTEN](socat.html#GROUP_LISTEN),[OPENSSL](socat.html#GROUP_OPENSSL),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [pf](socat.html#OPTION_PROTOCOL_FAMILY), [min-proto-
version](socat.html#OPTION_OPENSSL_MIN_PROTO_VERSION),
[cipher](socat.html#OPTION_OPENSSL_CIPHERLIST),
[verify](socat.html#OPTION_OPENSSL_VERIFY),
[commonname](socat.html#OPTION_OPENSSL_COMMONNAME),
[cafile](socat.html#OPTION_OPENSSL_CAFILE),
[capath](socat.html#OPTION_OPENSSL_CAPATH),
[certificate](socat.html#OPTION_OPENSSL_CERTIFICATE),
[key](socat.html#OPTION_OPENSSL_KEY),
[compress](socat.html#OPTION_OPENSSL_COMPRESS),
[fork](socat.html#OPTION_FORK), [bind](socat.html#OPTION_BIND),
[range](socat.html#OPTION_RANGE), [tcpwrap](socat.html#OPTION_TCPWRAPPERS),
[su](socat.html#OPTION_SUBSTUSER),
[reuseaddr](socat.html#OPTION_SO_REUSEADDR), [retry](socat.html#OPTION_RETRY)  
[rcvtimeo](socat.html#OPTION_SO_RCVTIMOE)  
See also: [OPENSSL-DTLS-CLIENT](socat.html#ADDRESS_OPENSSL_DTLS_CLIENT),
[OPENSSL-LISTEN](socat.html#ADDRESS_OPENSSL_LISTEN), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN)

****`PIPE:<filename>`****     If [<filename>](socat.html#TYPE_FILENAME)
already exists, it is opened. If it does not exist, a named pipe is created
and opened. Beginning with socat version 1.4.3, the named pipe is removed when
the address is closed (but see option [unlink-
close](socat.html#OPTION_UNLINK_CLOSE)  
Note: When a pipe is used for both reading and writing, it works as echo
service.  
Note: When a pipe is used for both reading and writing, and socat tries to
write more bytes than the pipe can buffer (Linux 2.4: 2048 bytes), socat might
block. Consider using socat option, e.g., `-b 2048`  
Option groups:
[FD](socat.html#GROUP_FD),[NAMED](socat.html#GROUP_NAMED),[OPEN](socat.html#GROUP_OPEN)  
Useful options: [rdonly](socat.html#OPTION_RDONLY),
[nonblock](socat.html#OPTION_O_NONBLOCK), [group](socat.html#OPTION_GROUP),
[user](socat.html#OPTION_USER), [mode](socat.html#OPTION_MODE), [unlink-
early](socat.html#OPTION_UNLINK_EARLY)  
See also: [unnamed pipe](socat.html#ADDRESS_UNNAMED_PIPE)

****`PIPE`****     Creates an unnamed pipe and uses it for reading and
writing. It works as an echo, because everything written to it appears
immediately as read data.  
Note: When socat tries to write more bytes than the pipe can queue (Linux 2.4:
2048 bytes), socat might block. Consider, e.g., using option `-b 2048`  
Option groups: [FD](socat.html#GROUP_FD)  
See also: [named pipe](socat.html#ADDRESS_NAMED_PIPE),
[SOCKETPAIR](socat.html#ADDRESS_SOCKETPAIR)

****`SOCKETPAIR`****     Creates a socketpair and uses it for reading and
writing. It works as an echo, because everything written to it appears
immediately as read data. The default socket type is datagram, so it keeps
packet boundaries.  
Option groups: [FD](socat.html#GROUP_FD)  
Useful options: [socktype](socat.html#OPTION_SO_TYPE)  
See also: [unnamed pipe](socat.html#ADDRESS_UNNAMED_PIPE)

****`STALL`****     The read part of this address never provides any data nor
EOF; the write part never gets ready for writing data. This might be useful
for testing and for some special scenarios.

****`TEXT:<string>`****     The text provided as parameter is taken as input
data: it is buffered in an internal pipe and then processed as usual. The
standard conversions are performed on the string, so you may check how
parameters are parsed and prepared which is critical for addresses like EXEC.  
Output on this address is sent to `stdout`. Thus this address can replace
constructs like:  
**`echo "<string>" | socat STDIO TCP:<server>:<port>`**  
with:  
**`socat TEXT:"<string>\n" TCP:<server>:<port>`**  
Have a look at the [example with sudo](socat.html#EXAMPLE_ADDRESS_TEXT) below.

****`POSIXMQ-READ:/<mqueue>`****     Opens or creates the specified POSIX
message queue and reads messages (packets). It keeps the packet boundaries.  
This is a read-only address, see options [-u](socat.html#option_u) and
[-U](socat.html#option_U) and [dual addresses](socat.html#ADDRESS_DUAL).  
**Socat** provides this address type only on Linux because POSIX MQ is based
on UNIX filedescriptors there.  
Useful options: [posixmq-priority](socat.html#OPTION_POSIXMQ_PRIORITY),
[unlink-early](socat.html#OPTION_UNLINK_EARLY), [unlink-
close](socat.html#OPTION_UNLINK_CLOSE),
[o-nonblock](socat.html#OPTION_O_NONBLOCK),
[o-creat](socat.html#OPTION_O_CREAT), [o-excl](socat.html#OPTION_O_EXCL),
[umask](socat.html#OPTION_UMASK)

****`POSIXMQ-RECEIVE:/<mqueue>`****  

****`POSIXMQ-RECV:/<mqueue>`****     Opens or creates the specified POSIX
message queue and reads one message (packet).  
This is a read-only address. See [POSIXMQ-
READ](socat.html#ADDRESS_POSIXMQ_READ) for more info.  
Example: [POSIX MQ recv with fork](socat.html#EXAMPLE_POSIXMQ_RECV_FORK)  
Useful options: [posixmq-priority](socat.html#OPTION_POSIXMQ_PRIORITY),
[fork](socat.html#OPTION_FORK), [max-
children](socat.html#OPTION_MAX_CHILDREN), [unlink-
early](socat.html#OPTION_UNLINK_EARLY), [unlink-
close](socat.html#OPTION_UNLINK_CLOSE), [o-creat](socat.html#OPTION_O_CREAT),
[o-excl](socat.html#OPTION_O_EXCL), [umask](socat.html#OPTION_UMASK)

****`POSIXMQ-SEND:/<mqueue>`****     Opens or creates the specified POSIX
message queue and writes messages (packets).  
This is a write-only address. See [POSIXMQ-
READ](socat.html#ADDRESS_POSIXMQ_READ) for more info.  
([Example](socat.html#EXAMPLE_POSIXMQ_SEND))  
Useful options: [posixmq-priority](socat.html#OPTION_POSIXMQ_PRIORITY),
[posixmq-flush](socat.html#OPTION_POSIXMQ_FLUSH),
[fork](socat.html#OPTION_FORK), [max-
children](socat.html#OPTION_MAX_CHILDREN), [unlink-
early](socat.html#OPTION_UNLINK_EARLY), [unlink-
close](socat.html#OPTION_UNLINK_CLOSE), [o-creat](socat.html#OPTION_O_CREAT),
[o-excl](socat.html#OPTION_O_EXCL), [umask](socat.html#OPTION_UMASK)

****`POSIXMQ-WRITE:/<mqueue>`****     Does the same as [POSIXMQ-
SEND](socat.html#ADDRESS_POSIXMQ_SEND).

****`POSIXMQ-BIDIRECTIONAL:/mqueue`****  

****`POSIXMQ:/mqueue`****     Opens or creates the specified POSIX message
queue in read and/or write mode depending on context, then reads and/or writes
messages (packets). In bidirectional mode this is just another echo service.
POSIXMQ refuses bidirectional mode to prevent unwanted flushing of queue; use
POSIXMQ-BIDIRECTIONAL when needed.  
See [POSIXMQ-READ](socat.html#ADDRESS_POSIXMQ_READ) and [POSIXMQ-
SEND](socat.html#ADDRESS_POSIXMQ_SEND) for more info.

****`PROXY:<proxy>:<hostname>:<port>`****     Connects to an HTTP proxy server
on port 8080 using TCP/IP version 4 or 6 depending on address specification,
name resolution, or option [pf](socat.html#OPTION_PROTOCOL_FAMILY), and sends
a CONNECT request for hostname:port. If the proxy grants access and succeeds
to connect to the target, data transfer between socat and the target can start
([example](socat.html#EXAMPLE_PROXY_CONNECT)). Note that the traffic need not
be HTTP but can be an arbitrary protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[HTTP](socat.html#GROUP_HTTP),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [proxyport](socat.html#OPTION_PROXYPORT),
[ignorecr](socat.html#OPTION_IGNORECR),
[proxyauth](socat.html#OPTION_PROXY_AUTHORIZATION),
[resolve](socat.html#OPTION_PROXY_RESOLVE), [crnl](socat.html#OPTION_CRNL),
[bind](socat.html#OPTION_BIND), [connect-
timeout](socat.html#OPTION_CONNECT_TIMEOUT), [mss](socat.html#OPTION_MSS),
[sourceport](socat.html#OPTION_SOURCEPORT), [retry](socat.html#OPTION_RETRY)  
See also: [SOCKS](socat.html#ADDRESS_SOCKS4),
[TCP](socat.html#ADDRESS_TCP_CONNECT)

****`PTY`****     Generates a pseudo terminal (pty) and uses its master side.
Another process may open the pty's slave side using it like a serial line or
terminal. ([example](socat.html#EXAMPLE_ADDRESS_PTY)). If both the ptmx and
the openpty mechanisms are available, ptmx is used (POSIX).  
Option groups:
[FD](socat.html#GROUP_FD),[NAMED](socat.html#GROUP_NAMED),[PTY](socat.html#GROUP_PTY),[TERMIOS](socat.html#GROUP_TERMIOS)  
Useful options: [link](socat.html#OPTION_SYMBOLIC_LINK),
[openpty](socat.html#OPTION_OPENPTY), [wait-
slave](socat.html#OPTION_PTY_WAIT_SLAVE), [mode](socat.html#OPTION_MODE),
[user](socat.html#OPTION_USER), [group](socat.html#OPTION_GROUP)  
See also: [UNIX-LISTEN](socat.html#ADDRESS_UNIX_LISTEN),
[PIPE](socat.html#ADDRESS_NAMED_PIPE), [EXEC](socat.html#ADDRESS_EXEC),
[SYSTEM](socat.html#ADDRESS_SYSTEM), [SHELL](socat.html#ADDRESS_SHELL)

****`READLINE`****     Uses GNU readline and history on stdio to allow editing
and reusing input lines ([example](socat.html#EXAMPLE_ADDRESS_READLINE)). This
requires the GNU readline and history libraries. Note that stdio should be a
(pseudo) terminal device, otherwise readline does not seem to work.  
Option groups:
[FD](socat.html#GROUP_FD),[READLINE](socat.html#GROUP_READLINE),[TERMIOS](socat.html#GROUP_TERMIOS)  
Useful options: [history](socat.html#OPTION_HISTORY),
[noecho](socat.html#OPTION_NOECHO)  
See also: [STDIO](socat.html#ADDRESS_STDIO)

****`SCTP-CONNECT:<host>:<port>`****     Establishes an SCTP stream connection
to the specified <host> [[IP address](socat.html#TYPE_IP_ADDRESS)] and <port>
[[TCP service](socat.html#TYPE_TCP_SERVICE)] using IP version 4 or 6 depending
on address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[SCTP](socat.html#GROUP_SCTP),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [bind](socat.html#OPTION_BIND),
[pf](socat.html#OPTION_PROTOCOL_FAMILY), [connect-
timeout](socat.html#OPTION_CONNECT_TIMEOUT), [tos](socat.html#OPTION_TOS),
[mtudiscover](socat.html#OPTION_IP_MTU_DISCOVER),
[mtudiscover6](socat.html#OPTION_IPV6_MTU_DISCOVER), [sctp-
maxseg](socat.html#OPTION_SCTP_MAXSEG), [sctp-
nodelay](socat.html#OPTION_SCTP_NODELAY),
[nonblock](socat.html#OPTION_O_NONBLOCK),
[sourceport](socat.html#OPTION_SOURCEPORT), [retry](socat.html#OPTION_RETRY),
[readbytes](socat.html#OPTION_READBYTES)  
See also: [SCTP4-CONNECT](socat.html#ADDRESS_SCTP4_CONNECT),
[SCTP6-CONNECT](socat.html#ADDRESS_SCTP6_CONNECT), [SCTP-
LISTEN](socat.html#ADDRESS_SCTP_LISTEN), [TCP-
CONNECT](socat.html#ADDRESS_TCP_CONNECT)

****`SCTP4-CONNECT:<host>:<port>`****     Like [SCTP-
CONNECT](socat.html#ADDRESS_SCTP_CONNECT), but only supports IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[SCTP](socat.html#GROUP_SCTP),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  

****`SCTP6-CONNECT:<host>:<port>`****     Like [SCTP-
CONNECT](socat.html#ADDRESS_SCTP_CONNECT), but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[SCTP](socat.html#GROUP_SCTP),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  

****`SCTP-LISTEN:<port>`****     Listens on <port> [[TCP
service](socat.html#TYPE_TCP_SERVICE)] and accepts an SCTP connection. The IP
version is 4 or the one specified with address option
[pf](socat.html#OPTION_PROTOCOL_FAMILY), socat option
([-4](socat.html#option_4), [-6](socat.html#option_6)), or environment
variable [SOCAT_DEFAULT_LISTEN_IP](socat.html#ENV_SOCAT_DEFAULT_LISTEN_IP).
Note that opening this address usually blocks until a client connects.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[SCTP](socat.html#GROUP_SCTP),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [crnl](socat.html#OPTION_CRNL),
[fork](socat.html#OPTION_FORK), [bind](socat.html#OPTION_BIND),
[range](socat.html#OPTION_RANGE), [tcpwrap](socat.html#OPTION_TCPWRAPPERS),
[pf](socat.html#OPTION_PROTOCOL_FAMILY), [max-
children](socat.html#OPTION_MAX_CHILDREN),
[backlog](socat.html#OPTION_BACKLOG), [accept-
timeout](socat.html#OPTION_ACCEPT_TIMEOUT), [sctp-
maxseg](socat.html#OPTION_SCTP_MAXSEG), [sctp-
nodelay](socat.html#OPTION_SCTP_NODELAY), [su](socat.html#OPTION_SUBSTUSER),
[reuseaddr](socat.html#OPTION_SO_REUSEADDR), [retry](socat.html#OPTION_RETRY)  
See also: [SCTP4-LISTEN](socat.html#ADDRESS_SCTP4_LISTEN),
[SCTP6-LISTEN](socat.html#ADDRESS_SCTP6_LISTEN), [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN), [SCTP-
CONNECT](socat.html#ADDRESS_SCTP_CONNECT)

****`SCTP4-LISTEN:<port>`****     Like [SCTP-
LISTEN](socat.html#ADDRESS_SCTP_LISTEN), but only supports IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4),[SCTP](socat.html#GROUP_SCTP),[RETRY](socat.html#GROUP_RETRY)  

****`SCTP6-LISTEN:<port>`****     Like [SCTP-
LISTEN](socat.html#ADDRESS_SCTP_LISTEN), but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP6](socat.html#GROUP_IP6),[SCTP](socat.html#GROUP_SCTP),[RETRY](socat.html#GROUP_RETRY)  

****`SOCKET-CONNECT:<domain>:<protocol>:<remote-address>`****     Creates a
stream socket using the first and second given socket parameters and
`SOCK_STREAM` (see man socket(2)) and connects to the remote-address. The two
socket parameters have to be specified by [int](socat.html#TYPE_INT) numbers.
Consult your OS documentation and include files to find the appropriate
values. The remote-address must be the [data](socat.html#TYPE_DATA)
representation of a sockaddr structure without sa_family and (BSD) sa_len
components.  
Please note that you can - beyond the options of the specified groups - also
use options of higher level protocols when you apply socat option
[-g](socat.html#option_g).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [bind](socat.html#OPTION_BIND),
[setsockopt](socat.html#OPTION_SETSOCKOPT),  
See also: [TCP](socat.html#ADDRESS_TCP_CONNECT), [UDP-
CONNECT](socat.html#ADDRESS_UDP_CONNECT), [UNIX-
CONNECT](socat.html#ADDRESS_UNIX_CONNECT), [SOCKET-
LISTEN](socat.html#ADDRESS_SOCKET_LISTEN), [SOCKET-
SENDTO](socat.html#ADDRESS_SOCKET_SENDTO)

****`SOCKET-DATAGRAM:<domain>:<type>:<protocol>:<remote-address>`****
Creates a datagram socket using the first three given socket parameters (see
man socket(2)) and sends outgoing data to the remote-address. The three socket
parameters have to be specified by [int](socat.html#TYPE_INT) numbers. Consult
your OS documentation and include files to find the appropriate values. The
remote-address must be the [data](socat.html#TYPE_DATA) representation of a
sockaddr structure without sa_family and (BSD) sa_len components.  
Please note that you can - beyond the options of the specified groups - also
use options of higher level protocols when you apply socat option
[-g](socat.html#option_g).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [bind](socat.html#OPTION_BIND),
[range](socat.html#OPTION_RANGE), [setsockopt](socat.html#OPTION_SETSOCKOPT),  
See also: [UDP-DATAGRAM](socat.html#ADDRESS_UDP_DATAGRAM), [IP-
DATAGRAM](socat.html#ADDRESS_IP_DATAGRAM), [SOCKET-
SENDTO](socat.html#ADDRESS_SOCKET_SENDTO), [SOCKET-
RECV](socat.html#ADDRESS_SOCKET_RECV), [SOCKET-
RECVFROM](socat.html#ADDRESS_SOCKET_RECVFROM)

****`SOCKET-LISTEN:<domain>:<protocol>:<local-address>`****     Creates a
stream socket using the first and second given socket parameters and
`SOCK_STREAM` (see man socket(2)) and waits for incoming connections on local-
address. The two socket parameters have to be specified by
[int](socat.html#TYPE_INT) numbers. Consult your OS documentation and include
files to find the appropriate values. The local-address must be the
[data](socat.html#TYPE_DATA) representation of a sockaddr structure without
sa_family and (BSD) sa_len components.  
Please note that you can - beyond the options of the specified groups - also
use options of higher level protocols when you apply socat option
[-g](socat.html#option_g).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[RANGE](socat.html#GROUP_RANGE),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [setsockopt](socat.html#OPTION_SETSOCKOPT), [setsockopt-
listen](socat.html#OPTION_SETSOCKOPT_LISTEN),  
See also: [TCP](socat.html#ADDRESS_TCP_LISTEN), [UDP-
CONNECT](socat.html#ADDRESS_UDP_LISTEN), [UNIX-
CONNECT](socat.html#ADDRESS_UNIX_LISTEN), [SOCKET-
LISTEN](socat.html#ADDRESS_SOCKET_CONNECT), [SOCKET-
SENDTO](socat.html#ADDRESS_SOCKET_RECVFROM), [SOCKET-
SENDTO](socat.html#ADDRESS_SOCKET_RECV)

****`SOCKET-RECV:<domain>:<type>:<protocol>:<local-address>`****     Creates a
socket using the three given socket parameters (see man socket(2)) and binds
it to <local-address>. Receives arriving data. The three parameters have to be
specified by [int](socat.html#TYPE_INT) numbers. Consult your OS documentation
and include files to find the appropriate values. The local-address must be
the [data](socat.html#TYPE_DATA) representation of a sockaddr structure
without sa_family and (BSD) sa_len components.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [range](socat.html#OPTION_RANGE),
[setsockopt](socat.html#OPTION_SETSOCKOPT), [setsockopt-
listen](socat.html#OPTION_SETSOCKOPT_LISTEN)  
See also: [UDP-RECV](socat.html#ADDRESS_UDP_RECV), [IP-
RECV](socat.html#ADDRESS_IP_RECV), [UNIX-RECV](socat.html#ADDRESS_UNIX_RECV),
[SOCKET-DATAGRAM](socat.html#ADDRESS_SOCKET_DATAGRAM), [SOCKET-
SENDTO](socat.html#ADDRESS_SOCKET_SENDTO), [SOCKET-
RECVFROM](socat.html#ADDRESS_SOCKET_RECVFROM)

****`SOCKET-RECVFROM:<domain>:<type>:<protocol>:<local-address>`****
Creates a socket using the three given socket parameters (see man socket(2))
and binds it to <local-address>. Receives arriving data and sends replies back
to the sender. The first three parameters have to be specified as
[int](socat.html#TYPE_INT) numbers. Consult your OS documentation and include
files to find the appropriate values. The local-address must be the
[data](socat.html#TYPE_DATA) representation of a sockaddr structure without
sa_family and (BSD) sa_len components.  
See the [note about RECVFROM addresses](socat.html#NOTE_RECVFROM).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [fork](socat.html#OPTION_FORK),
[range](socat.html#OPTION_RANGE), [setsockopt](socat.html#OPTION_SETSOCKOPT),
[setsockopt-listen](socat.html#OPTION_SETSOCKOPT_LISTEN)  
See also: [UDP-RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM), [UNIX-
RECVFROM](socat.html#ADDRESS_UNIX_RECVFROM), [SOCKET-
DATAGRAM](socat.html#ADDRESS_SOCKET_DATAGRAM), [SOCKET-
SENDTO](socat.html#ADDRESS_SOCKET_SENDTO), [SOCKET-
RECV](socat.html#ADDRESS_SOCKET_RECV)

****`SOCKET-SENDTO:<domain>:<type>:<protocol>:<remote-address>`****
Creates a socket using the three given socket parameters (see man socket(2)).
Sends outgoing data to the given address and receives replies. The three
parameters have to be specified as [int](socat.html#TYPE_INT) numbers. Consult
your OS documentation and include files to find the appropriate values. The
remote-address must be the [data](socat.html#TYPE_DATA) representation of a
sockaddr structure without sa_family and (BSD) sa_len components.  
Option groups: [FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET)  
Useful options: [bind](socat.html#OPTION_BIND),
[setsockopt](socat.html#OPTION_SETSOCKOPT), [setsockopt-
listen](socat.html#OPTION_SETSOCKOPT_LISTEN)  
See also: [UDP-SENDTO](socat.html#ADDRESS_UDP_SENDTO), [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO), [UNIX-
SENDTO](socat.html#ADDRESS_UNIX_SENDTO), [SOCKET-
DATAGRAM](socat.html#ADDRESS_SOCKET_DATAGRAM), [SOCKET-
RECV](socat.html#ADDRESS_SOCKET_RECV) [SOCKET-
RECVFROM](socat.html#ADDRESS_SOCKET_RECVFROM)

****`ACCEPT-FD:<fdnum>`****     Expects a listening socket in <fdnum> and
accepts one or (with option [fork](socat.html#OPTION_FORK)) more connections.
This address type is useful under systemd control with "inetd mode".  
Example: ([example](socat.html#EXAMPLE_ADDRESS_ACCEPT_FD))  
Option groups: [FD](socat.html#GROUP_FD), [SOCKET](socat.html#GROUP_SOCKET),
[TCP](socat.html#GROUP_TCP), [CHILD](socat.html#GROUP_CHILD),
[RETRY](socat.html#GROUP_RETRY)  
Useful options: [fork](socat.html#OPTION_FORK),
[range](socat.html#OPTION_RANGE), [sourceport](socat.html#OPTION_SOURCEPORT),
[lowport](socat.html#OPTION_LOWPORT), [tcpwrap](socat.html#OPTION_TCPWRAPPERS)

****`SOCKS4:<socks-server>:<host>:<port>`****     Connects via <socks-server>
[[IP address](socat.html#TYPE_IP_ADDRESS)] to <host> [[IPv4
address](socat.html#TYPE_IPV4_ADDRESS)] on <port> [[TCP
service](socat.html#TYPE_TCP_SERVICE)], using socks version 4 protocol over IP
version 4 or 6 depending on address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY)
([example](socat.html#EXAMPLE_ADDRESS_SOCKS4)).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[SOCKS4](socat.html#GROUP_SOCKS),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [socksuser](socat.html#OPTION_SOCKSUSER),
[socksport](socat.html#OPTION_SOCKSPORT),
[sourceport](socat.html#OPTION_SOURCEPORT),
[pf](socat.html#OPTION_PROTOCOL_FAMILY), [retry](socat.html#OPTION_RETRY)  
See also: [SOCKS5](socat.html#ADDRESS_SOCKS5_CONNECT),
[SOCKS4A](socat.html#ADDRESS_SOCKS4A),
[PROXY](socat.html#ADDRESS_PROXY_CONNECT),
[TCP](socat.html#ADDRESS_TCP_CONNECT)

****`SOCKS4A:<socks-server>:<host>:<port>`****     like
[SOCKS4](socat.html#ADDRESS_SOCKS4), but uses socks protocol version 4a, thus
leaving host name resolution to the socks server.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[SOCKS4](socat.html#GROUP_SOCKS),[RETRY](socat.html#GROUP_RETRY)  

****`SOCKS5-CONNECT:<socks-server>:<socks-port>:<target-host>:<target-
port>`****  

****`SOCKS5-CONNECT:<socks-server>:<target-host>:<target-port>`****
Connects via <socks-server> [[IP address](socat.html#TYPE_IP_ADDRESS)] to
<target-host> [[IPv4 address](socat.html#TYPE_IPV4_ADDRESS)] on <target-port>
[[TCP service](socat.html#TYPE_TCP_SERVICE)], using socks version 5 protocol
over TCP. Currently no authentication mechanism is provided.  
Option groups: [FD](socat.html#GROUP_FD), [SOCKET](socat.html#GROUP_SOCKET),
[IP4](socat.html#GROUP_IP4), [IP6](socat.html#GROUP_IP6),
[TCP](socat.html#GROUP_TCP), [CHILD](socat.html#GROUP_CHILD),
[RETRY](socat.html#GROUP_RETRY)  
Useful options: [socksport](socat.html#OPTION_SOCKSPORT),
[socksuser](socat.html#OPTION_SOCKSUSER),
[sockspass](socat.html#OPTION_SOCKSPASS),
[sourceport](socat.html#OPTION_SOURCEPORT),
[pf](socat.html#OPTION_PROTOCOL_FAMILY), [retry](socat.html#OPTION_RETRY)  
See also: [SOCKS5-LISTEN](socat.html#ADDRESS_SOCKS5_LISTEN),
[SOCKS4](socat.html#ADDRESS_SOCKS4), [SOCKS4A](socat.html#ADDRESS_SOCKS4A),
[PROXY](socat.html#ADDRESS_PROXY_CONNECT),
[TCP](socat.html#ADDRESS_TCP_CONNECT)

****`SOCKS5-LISTEN:<socks-server>:<socks-port>:<listen-host>:<listen-
port>`****  

****`SOCKS5-LISTEN:<socks-server>:<listen-host>:<listen-port>`****
Connects to <socks-server> [[IP address](socat.html#TYPE_IP_ADDRESS)] using
socks version 5 protocol over TCP and makes it listen for incoming connections
on <listen-port> [[TCP service](socat.html#TYPE_TCP_SERVICE)], binding to
<-listen-host> [[IPv4 address](socat.html#TYPE_IPV4_ADDRESS)] Currently not
authentication mechanism is provided.  
Option groups: [FD](socat.html#GROUP_FD), [SOCKET](socat.html#GROUP_SOCKET),
[IP4](socat.html#GROUP_IP4), [IP6](socat.html#GROUP_IP6),
[TCP](socat.html#GROUP_TCP), [CHILD](socat.html#GROUP_CHILD),
[RETRY](socat.html#GROUP_RETRY)  
Useful options: [sourceport](socat.html#OPTION_SOURCEPORT),
[pf](socat.html#OPTION_PROTOCOL_FAMILY), [retry](socat.html#OPTION_RETRY)  
See also: [SOCKS5-CONNECT](socat.html#ADDRESS_SOCKS5_CONNECT),

****`STDERR`****     Uses file descriptor 2.  
This is a write-only address, see options [-u](socat.html#option_u) and
[-U](socat.html#option_U), and [dual addresses](socat.html#ADDRESS_DUAL).  
Option groups: [FD](socat.html#GROUP_FD)
([TERMIOS](socat.html#GROUP_TERMIOS),[REG](socat.html#GROUP_REG),[SOCKET](socat.html#GROUP_SOCKET))  
See also: [FD](socat.html#ADDRESS_FD)

****`STDIN`****     Uses file descriptor 0.  
This is a read-only address, see options [-u](socat.html#option_u) and
[-U](socat.html#option_U), and [dual addresses](socat.html#ADDRESS_DUAL).  
Option groups: [FD](socat.html#GROUP_FD)
([TERMIOS](socat.html#GROUP_TERMIOS),[REG](socat.html#GROUP_REG),[SOCKET](socat.html#GROUP_SOCKET))  
Useful options: [readbytes](socat.html#OPTION_READBYTES)  
See also: [FD](socat.html#ADDRESS_FD)

****`STDIO`****     Uses file descriptor 0 for reading, and 1 for writing.  
Option groups: [FD](socat.html#GROUP_FD)
([TERMIOS](socat.html#GROUP_TERMIOS),[REG](socat.html#GROUP_REG),[SOCKET](socat.html#GROUP_SOCKET))  
Useful options: [readbytes](socat.html#OPTION_READBYTES)  
See also: [FD](socat.html#ADDRESS_FD)

****`STDOUT`****     Uses file descriptor 1.  
This is a write-only address, see options [-u](socat.html#option_u) and
[-U](socat.html#option_U), and [dual addresses](socat.html#ADDRESS_DUAL).  
Option groups: [FD](socat.html#GROUP_FD)
([TERMIOS](socat.html#GROUP_TERMIOS),[REG](socat.html#GROUP_REG),[SOCKET](socat.html#GROUP_SOCKET))  
See also: [FD](socat.html#ADDRESS_FD)

****`SHELL:<shell-command>`****  

****`SHELL`****     Forks a sub process that establishes communication with
its parent process and invokes the specified program with the configured shell
($SHELL). Note that <shell-command> [[string](socat.html#TYPE_STRING)] must
not contain ',' or "!!", and that ':' and shell meta characters may have to be
protected. After successful program start, **socat** writes data to stdin of
the process and reads from its stdout.  
When invoked without parameter, this opens an interactive shell. Option
groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[EXEC](socat.html#GROUP_EXEC),[FORK](socat.html#GROUP_FORK),[TERMIOS](socat.html#GROUP_TERMIOS)  
Useful options: [path](socat.html#OPTION_PATH),
[fdin](socat.html#OPTION_FDIN), [fdout](socat.html#OPTION_FDOUT),
[chroot](socat.html#OPTION_CHROOT), [su](socat.html#OPTION_SUBSTUSER),
[su-d](socat.html#OPTION_SUBSTUSER_DELAYED),
[nofork](socat.html#OPTION_NOFORK), [socktype](socat.html#OPTION_SO_TYPE),
[pty](socat.html#OPTION_PTY), [stderr](socat.html#OPTION_STDERR),
[ctty](socat.html#OPTION_CTTY), [setsid](socat.html#OPTION_SETSID),
[pipes](socat.html#OPTION_PIPES), [umask](socat.html#OPTION_UMASK),
[sigint](socat.html#OPTION_SIGINT), [sigquit](socat.html#OPTION_SIGQUIT)  
See also: [EXEC](socat.html#ADDRESS_EXEC), [SYSTEM](socat.html#ADDRESS_SYSTEM)

****`SYSTEM:<shell-command>`****     Forks a sub process that establishes
communication with its parent process and invokes the specified program with
`system()` . Please note that <shell-command>
[[string](socat.html#TYPE_STRING)] must not contain ',' or "!!", and that
shell meta characters may have to be protected. After successful program
start, **socat** writes data to stdin of the process and reads from its
stdout.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[EXEC](socat.html#GROUP_EXEC),[FORK](socat.html#GROUP_FORK),[TERMIOS](socat.html#GROUP_TERMIOS)  
Useful options: [path](socat.html#OPTION_PATH),
[fdin](socat.html#OPTION_FDIN), [fdout](socat.html#OPTION_FDOUT),
[chroot](socat.html#OPTION_CHROOT), [su](socat.html#OPTION_SUBSTUSER),
[su-d](socat.html#OPTION_SUBSTUSER_DELAYED),
[nofork](socat.html#OPTION_NOFORK), [socktype](socat.html#OPTION_SO_TYPE),
[pty](socat.html#OPTION_PTY), [stderr](socat.html#OPTION_STDERR),
[ctty](socat.html#OPTION_CTTY), [setsid](socat.html#OPTION_SETSID),
[pipes](socat.html#OPTION_PIPES), [umask](socat.html#OPTION_UMASK),
[sigint](socat.html#OPTION_SIGINT), [sigquit](socat.html#OPTION_SIGQUIT),
[netns](socat.html#OPTION_NETNS)  
See also: [EXEC](socat.html#ADDRESS_EXEC), [SHELL](socat.html#ADDRESS_SHELL)

****`TCP:<host>:<port>`****     Connects to <port> [[TCP
service](socat.html#TYPE_TCP_SERVICE)] on <host> [[IP
address](socat.html#TYPE_IP_ADDRESS)] using TCP/IP version 4 or 6 depending on
address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [connect-timeout](socat.html#OPTION_CONNECT_TIMEOUT),
[retry](socat.html#OPTION_RETRY), [sourceport](socat.html#OPTION_SOURCEPORT),
[netns](socat.html#OPTION_NETNS), [crnl](socat.html#OPTION_CRNL),
[bind](socat.html#OPTION_BIND), [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[tos](socat.html#OPTION_TOS),
[mtudiscover](socat.html#OPTION_IP_MTU_DISCOVER),
[mtudiscover6](socat.html#OPTION_IPV6_MTU_DISCOVER),
[mss](socat.html#OPTION_MSS), [nodelay](socat.html#OPTION_TCP_NODELAY),
[nonblock](socat.html#OPTION_O_NONBLOCK),
[readbytes](socat.html#OPTION_READBYTES)  
See also: [TCP4](socat.html#ADDRESS_TCP4_CONNECT),
[TCP6](socat.html#ADDRESS_TCP6_CONNECT), [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN), [UDP](socat.html#ADDRESS_UDP_CONNECT),
[SCTP-CONNECT](socat.html#ADDRESS_SCTP_CONNECT), [UNIX-
CONNECT](socat.html#ADDRESS_UNIX_CONNECT)

****`TCP4:<host>:<port>`****     Like [TCP](socat.html#ADDRESS_TCP_CONNECT),
but only supports IPv4 protocol
([example](socat.html#EXAMPLE_ADDRESS_TCP4_CONNECT)).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[TCP](socat.html#GROUP_TCP),[RETRY](socat.html#GROUP_RETRY)  

****`TCP6:<host>:<port>`****     Like [TCP](socat.html#ADDRESS_TCP_CONNECT),
but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[RETRY](socat.html#GROUP_RETRY)  

****`TCP-LISTEN:<port>`****     Listens on <port> [[TCP
service](socat.html#TYPE_TCP_SERVICE)] and accepts a TCP/IP connection. The IP
version is 4 or the one specified with address option
[pf](socat.html#OPTION_PROTOCOL_FAMILY), socat option
([-4](socat.html#option_4), [-6](socat.html#option_6)), or environment
variable [SOCAT_DEFAULT_LISTEN_IP](socat.html#ENV_SOCAT_DEFAULT_LISTEN_IP).
Note that opening this address usually blocks until a client connects.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [crnl](socat.html#OPTION_CRNL),
[fork](socat.html#OPTION_FORK), [bind](socat.html#OPTION_BIND),
[range](socat.html#OPTION_RANGE), [tcpwrap](socat.html#OPTION_TCPWRAPPERS),
[pf](socat.html#OPTION_PROTOCOL_FAMILY), [max-
children](socat.html#OPTION_MAX_CHILDREN),
[backlog](socat.html#OPTION_BACKLOG), [accept-
timeout](socat.html#OPTION_ACCEPT_TIMEOUT), [mss](socat.html#OPTION_MSS),
[su](socat.html#OPTION_SUBSTUSER),
[reuseaddr](socat.html#OPTION_SO_REUSEADDR), [retry](socat.html#OPTION_RETRY),
[cool-write](socat.html#OPTION_COOL_WRITE)  
See also: [TCP4-LISTEN](socat.html#ADDRESS_TCP4_LISTEN),
[TCP6-LISTEN](socat.html#ADDRESS_TCP6_LISTEN), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), [SCTP-
LISTEN](socat.html#ADDRESS_SCTP_LISTEN), [UNIX-
LISTEN](socat.html#ADDRESS_UNIX_LISTEN), [OPENSSL-
LISTEN](socat.html#ADDRESS_OPENSSL_LISTEN), [TCP-
CONNECT](socat.html#ADDRESS_TCP_CONNECT)

****`TCP4-LISTEN:<port>`****     Like [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN), but only supports IPv4 protocol
([example](socat.html#EXAMPLE_ADDRESS_TCP4_LISTEN)).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4),[TCP](socat.html#GROUP_TCP),[RETRY](socat.html#GROUP_RETRY)  

****`TCP6-LISTEN:<port>`****     Like [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN), but only supports IPv6 protocol.  
Additional useful option: [ipv6only](socat.html#OPTION_IPV6_V6ONLY)  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP6](socat.html#GROUP_IP6),[TCP](socat.html#GROUP_TCP),[RETRY](socat.html#GROUP_RETRY)  

****`TUN[:<if-addr>/<bits>]`****     Creates a Linux TUN/TAP device and
optionally assigns it the address and netmask given by the parameters. The
resulting network interface is almost ready for use by other processes; socat
serves its "wire side". This address requires read and write access to the
tunnel cloning device, usually `/dev/net/tun` , as well as permission to set
some `ioctl()s`. **Option iff-up is required to immediately activate the
interface!**  
Note: If you intend to transfer packets between two Socat "wire sides" you
need a protocol that keeps packet boundaries, e.g.UDP; TCP might work with
option [nodelay](socat.html#OPTION_TCP_NODELAY).  
Option groups:
[FD](socat.html#GROUP_FD),[NAMED](socat.html#GROUP_NAMED),[OPEN](socat.html#GROUP_OPEN),[TUN](socat.html#GROUP_INTERFACE)  
Useful options: [iff-up](socat.html#OPTION_IFF_UP), [tun-
device](socat.html#OPTION_TUN_DEVICE), [tun-name](socat.html#OPTION_TUN_NAME),
[tun-type](socat.html#OPTION_TUN_TYPE), [interface-
mtu](socat.html#OPTION_INTERFACE_MTU), [iff-no-
pi](socat.html#OPTION_IFF_NO_PI), [netns](socat.html#OPTION_NETNS)  
See also: [ip-recv](socat.html#ADDRESS_IP_RECV)

****`UDP:<host>:<port>`****     Connects to <port> [[UDP
service](socat.html#TYPE_UDP_SERVICE)] on <host> [[IP
address](socat.html#TYPE_IP_ADDRESS)] using UDP/IP version 4 or 6 depending on
address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY).  
Please note that, due to UDP protocol properties, no real connection is
established; data has to be sent for `connecting' to the server, and no end-
of-file condition can be transported.  
Since version 1.8.1.0, the socket sends, when shutting down, a zero length UDP
packet that might trigger EOF on the peer (implicit option [shut-
null](socat.html#OPTION_SHUT_NULL)). Restore old behaviour with option [shut-
none](socat.html#OPTION_SHUT_NONE).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6)  
Useful options: [ttl](socat.html#OPTION_TTL), [tos](socat.html#OPTION_TOS),
[bind](socat.html#OPTION_BIND), [sourceport](socat.html#OPTION_SOURCEPORT),
[pf](socat.html#OPTION_PROTOCOL_FAMILY)  
See also: [UDP4](socat.html#ADDRESS_UDP4_CONNECT),
[UDP6](socat.html#ADDRESS_UDP6_CONNECT), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), [TCP](socat.html#ADDRESS_TCP_CONNECT),
[IP](socat.html#ADDRESS_IP_SENDTO)

****`UDP4:<host>:<port>`****     Like [UDP](socat.html#ADDRESS_UDP_CONNECT),
but only supports IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4)  

****`UDP6:<host>:<port>`****     Like [UDP](socat.html#ADDRESS_UDP_CONNECT),
but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6)  

****`UDP-DATAGRAM:<address>:<port>`****     Sends outgoing data to the
specified address which may in particular be a broadcast or multicast address.
Packets arriving on the local socket are checked for the correct remote port
only when option [sourceport](socat.html#OPTION_SOURCEPORT) is used (this is a
change with **Socat** version 1.7.4.0) and if their source addresses match
[RANGE](socat.html#OPTION_RANGE) or [TCPWRAP](socat.html#OPTION_TCPWRAPPERS)
options. This address type can for example be used for implementing symmetric
or asymmetric broadcast or multicast communications.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [bind](socat.html#OPTION_BIND),
[range](socat.html#OPTION_RANGE), [tcpwrap](socat.html#OPTION_TCPWRAPPERS),
[broadcast](socat.html#OPTION_SO_BROADCAST), [ip-multicast-
loop](socat.html#OPTION_IP_MULTICAST_LOOP), [ip-multicast-
ttl](socat.html#OPTION_IP_MULTICAST_TTL), [ip-multicast-
if](socat.html#OPTION_IP_MULTICAST_IF), [ip-add-
membership](socat.html#OPTION_IP_ADD_MEMBERSHIP), [ip-add-source-
membership](socat.html#OPTION_IP_ADD_SOURCE_MEMBERSHIP), [ipv6-join-
group](socat.html#OPTION_IPV6_JOIN_GROUP), [ipv6-join-source-
group](socat.html#OPTION_IPV6_JOIN_SOURCE_GROUP),
[ttl](socat.html#OPTION_TTL), [tos](socat.html#OPTION_TOS),
[sourceport](socat.html#OPTION_SOURCEPORT),
[pf](socat.html#OPTION_PROTOCOL_FAMILY)  
See also: [UDP4-DATAGRAM](socat.html#ADDRESS_UDP4_DATAGRAM),
[UDP6-DATAGRAM](socat.html#ADDRESS_UDP6_DATAGRAM), [UDP-
SENDTO](socat.html#ADDRESS_UDP_SENDTO), [UDP-
RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), [UDP-
RECV](socat.html#ADDRESS_UDP_RECV), [UDP-
CONNECT](socat.html#ADDRESS_UDP_CONNECT), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), [IP-
DATAGRAM](socat.html#ADDRESS_IP_DATAGRAM)

****`UDP4-DATAGRAM:<address>:<port>`****     Like [UDP-
DATAGRAM](socat.html#ADDRESS_UDP_DATAGRAM), but only supports IPv4 protocol
([example1](socat.html#EXAMPLE_ADDRESS_UDP4_BROADCAST_CLIENT),
[example2](socat.html#EXAMPLE_ADDRESS_UDP4_MULTICAST)).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),
[RANGE](socat.html#GROUP_RANGE)

****`UDP6-DATAGRAM:<address>:<port>`****     Like [UDP-
DATAGRAM](socat.html#ADDRESS_UDP_DATAGRAM), but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[RANGE](socat.html#GROUP_RANGE)

****`UDP-LISTEN:<port>`****     Waits for a UDP/IP packet arriving on <port>
[[UDP service](socat.html#TYPE_UDP_SERVICE)] and `connects' back to sender.
The accepted IP version is 4 or the one specified with option
[pf](socat.html#OPTION_PROTOCOL_FAMILY). Please note that, due to UDP protocol
properties, no real connection is established; data has to arrive from the
peer first, thus, opening this address usually blocks until a client connects.
Furthermore, no end-of-file condition is specified in UDP.  
Since version 1.8.1.0, the socket sends, when shutting down, a zero length UDP
packet that might trigger EOF on the peer (implicit option [shut-
null](socat.html#OPTION_SHUT_NULL)). Restore old behaviour with option [shut-
none](socat.html#OPTION_SHUT_NONE).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6)  
Useful options: [fork](socat.html#OPTION_FORK),
[bind](socat.html#OPTION_BIND), [range](socat.html#OPTION_RANGE),
[pf](socat.html#OPTION_PROTOCOL_FAMILY)  
See also: [UDP](socat.html#ADDRESS_UDP_CONNECT),
[UDP4-LISTEN](socat.html#ADDRESS_UDP4_LISTEN),
[UDP6-LISTEN](socat.html#ADDRESS_UDP6_LISTEN), [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN)

****`UDP4-LISTEN:<port>`****     Like [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), but only support IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP4](socat.html#GROUP_IP4)  

****`UDP6-LISTEN:<port>`****     Like [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), but only support IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE),[IP6](socat.html#GROUP_IP6)  

****`UDP-SENDTO:<host>:<port>`****     Communicates with the specified peer
socket, defined by <port> [[UDP service](socat.html#TYPE_UDP_SERVICE)] on
<host> [[IP address](socat.html#TYPE_IP_ADDRESS)], using UDP/IP version 4 or 6
depending on address specification, name resolution, or option
[pf](socat.html#OPTION_PROTOCOL_FAMILY). It sends packets to and receives
packets from that peer socket only. This address effectively implements a
datagram client. It works well with socat UDP-RECVFROM and UDP-RECV address
peers. When the peer might send data first, [UDP-
DATAGRAM](socat.html#ADDRESS_UDP_DATAGRAM) is preferable.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6)  
Useful options: [ttl](socat.html#OPTION_TTL), [tos](socat.html#OPTION_TOS),
[bind](socat.html#OPTION_BIND), [sourceport](socat.html#OPTION_SOURCEPORT),
[pf](socat.html#OPTION_PROTOCOL_FAMILY)  
See also: [UDP4-SENDTO](socat.html#ADDRESS_UDP4_SENDTO),
[UDP6-SENDTO](socat.html#ADDRESS_UDP6_SENDTO), [UDP-
RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), [UDP-
RECV](socat.html#ADDRESS_UDP_RECV), [UDP-
CONNECT](socat.html#ADDRESS_UDP_CONNECT), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO)

****`UDP4-SENDTO:<host>:<port>`****     Like [UDP-
SENDTO](socat.html#ADDRESS_UDP_SENDTO), but only supports IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4)

****`UDP6-SENDTO:<host>:<port>`****     Like [UDP-
SENDTO](socat.html#ADDRESS_UDP_SENDTO), but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6)

****`UDP-RECVFROM:<port>`****     Creates a UDP socket on <port> [[UDP
service](socat.html#TYPE_UDP_SERVICE)] using UDP/IP version 4 or 6 depending
on option [pf](socat.html#OPTION_PROTOCOL_FAMILY). It receives one packet from
an unspecified peer and may send one or more answer packets to that peer. This
mode is particularly useful with [fork](socat.html#OPTION_FORK) option where
each arriving packet - from arbitrary peers - is handled by its own sub
process. This allows a behaviour similar to typical UDP based servers like
ntpd or named. This address works well with socat UDP-SENDTO address peers.  
Note: When the second address fails before entering the transfer loop the
packet is dropped. Use option [retry](socat.html#OPTION_RETRY) or
[forever](socat.html#OPTION_FOREVER) on the second address to avoid data loss.
When you know the peer address, [UDP-
DATAGRAM](socat.html#ADDRESS_UDP_DATAGRAM) is preferable.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [fork](socat.html#OPTION_FORK), [ttl](socat.html#OPTION_TTL),
[tos](socat.html#OPTION_TOS), [bind](socat.html#OPTION_BIND),
[sourceport](socat.html#OPTION_SOURCEPORT),
[pf](socat.html#OPTION_PROTOCOL_FAMILY)  
See also: [UDP4-RECVFROM](socat.html#ADDRESS_UDP4_RECVFROM),
[UDP6-RECVFROM](socat.html#ADDRESS_UDP6_RECVFROM), [UDP-
SENDTO](socat.html#ADDRESS_UDP_SENDTO), [UDP-
RECV](socat.html#ADDRESS_UDP_RECV), [UDP-
CONNECT](socat.html#ADDRESS_UDP_CONNECT), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM), [UNIX-
RECVFROM](socat.html#ADDRESS_UNIX_RECVFROM)

****`UDP4-RECVFROM:<port>`****     Like [UDP-
RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), but only supports IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE)

****`UDP6-RECVFROM:<port>`****     Like [UDP-
RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[CHILD](socat.html#GROUP_CHILD),[RANGE](socat.html#GROUP_RANGE)

****`UDP-RECV:<port>`****     Creates a UDP socket on <port> [[UDP
service](socat.html#TYPE_UDP_SERVICE)] using UDP/IP version 4 or 6 depending
on option [pf](socat.html#OPTION_PROTOCOL_FAMILY). It receives packets from
multiple unspecified peers and merges the data. No replies are possible. It
works well with, e.g., socat [UDP-SENDTO](socat.html#ADDRESS_UDP_SENDTO)
address peers; it behaves similar to a syslog server.  
This is a read-only address, see options [-u](socat.html#option_u) and
[-U](socat.html#option_U), and [dual addresses](socat.html#ADDRESS_DUAL).  
Note: if you need the [fork](socat.html#OPTION_FORK) option, use [UDP-
RECVFROM](socat.html#ADDRESS_UDP_RECVFROM) in unidirectional mode (with
[option -u](socat.html#option_u)) instead.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[IP6](socat.html#GROUP_IP6),[RANGE](socat.html#GROUP_RANGE)  
Useful options: [pf](socat.html#OPTION_PROTOCOL_FAMILY),
[bind](socat.html#OPTION_BIND), [sourceport](socat.html#OPTION_SOURCEPORT),
[ttl](socat.html#OPTION_TTL), [tos](socat.html#OPTION_TOS)  
See also: [UDP4-RECV](socat.html#ADDRESS_UDP4_RECV),
[UDP6-RECV](socat.html#ADDRESS_UDP6_RECV), [UDP-
SENDTO](socat.html#ADDRESS_UDP_SENDTO), [UDP-
RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), [UDP-
CONNECT](socat.html#ADDRESS_UDP_CONNECT), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), [IP-RECV](socat.html#ADDRESS_IP_RECV),
[UNIX-RECV](socat.html#ADDRESS_UNIX_RECV)

****`UDP4-RECV:<port>`****     Like [UDP-RECV](socat.html#ADDRESS_UDP_RECV),
but only supports IPv4 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP4](socat.html#GROUP_IP4),[RANGE](socat.html#GROUP_RANGE)

****`UDP6-RECV:<port>`****     Like [UDP-RECV](socat.html#ADDRESS_UDP_RECV),
but only supports IPv6 protocol.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[IP6](socat.html#GROUP_IP6),[RANGE](socat.html#GROUP_RANGE)

****`UDPLITE-CONNECT:<host>:<port>`****  

****`UDPLITE4-CONNECT:<host>:<port>`****  

****`UDPLITE6-CONNECT:<host>:<port>`****  

****`UDPLITE-DATAGRAM:<address>:<port>`****  

****`UDPLITE4-DATAGRAM:<address>:<port>`****  

****`UDPLITE6-DATAGRAM:<address>:<port>`****  

****`UDPLITE-LISTEN:<port>`****  

****`UDPLITE4-LISTEN:<port>`****  

****`UDPLITE6-LISTEN:<port>`****  

****`UDPLITE-SENDTO:<host>:<port>`****  

****`UDPLITE4-SENDTO:<host>:<port>`****  

****`UDPLITE6-SENDTO:<host>:<port>`****  

****`UDPLITE-RECVFROM:<port>`****  

****`UDPLITE4-RECVFROM:<port>`****  

****`UDPLITE6-RECVFROM:<port>`****  

****`UDPLITE-RECV:<port>`****  

****`UDPLITE4-RECV:<port>`****  

****`UDPLITE6-RECV:<port>`****     The UDPLITE addresses are almost identical
to the related [UDP addresses](socat.html#ADDRESSES_UDP) but they use UDP-Lite
protocol and have the additional [UDPLITE option
group](socat.html#GROUP_UDPLITE).  

****`UNIX-CONNECT:<filename>`****     Connects to
[<filename>](socat.html#TYPE_FILENAME) assuming it is a UNIX domain socket. If
<filename> does not exist, this is an error; if <filename> is not a UNIX
domain socket, this is an error; if <filename> is a UNIX domain socket, but no
process is listening, this is an error.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[NAMED](socat.html#GROUP_NAMED),[RETRY](socat.html#GROUP_RETRY),[UNIX](socat.html#GROUP_SOCK_UNIX)  
) Useful options: [bind](socat.html#OPTION_BIND)  
See also: [UNIX-LISTEN](socat.html#ADDRESS_UNIX_LISTEN), [UNIX-
SENDTO](socat.html#ADDRESS_UNIX_SENDTO), [TCP](socat.html#ADDRESS_TCP_CONNECT)

****`UNIX-LISTEN:<filename>`****     Listens on
[<filename>](socat.html#TYPE_FILENAME) using a UNIX domain stream socket and
accepts a connection. If <filename> exists and is not a socket, this is an
error. If <filename> exists and is a UNIX domain socket, binding to the
address fails (use option [unlink-early](socat.html#OPTION_UNLINK_EARLY)!).
Note that opening this address usually blocks until a client connects.
Beginning with socat version 1.4.3, the file system entry is removed when this
address is closed (but see option [unlink-
close](socat.html#OPTION_UNLINK_CLOSE))
([example](socat.html#EXAMPLE_ADDRESS_UNIX_LISTEN)).  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[NAMED](socat.html#GROUP_NAMED),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY),[UNIX](socat.html#GROUP_SOCK_UNIX)  
Useful options: [fork](socat.html#OPTION_FORK),
[umask](socat.html#OPTION_UMASK), [mode](socat.html#OPTION_MODE),
[user](socat.html#OPTION_USER), [group](socat.html#OPTION_GROUP), [unlink-
early](socat.html#OPTION_UNLINK_EARLY)  
See also: [UNIX-CONNECT](socat.html#ADDRESS_UNIX_CONNECT), [UNIX-
RECVFROM](socat.html#ADDRESS_UNIX_RECVFROM), [UNIX-
RECV](socat.html#ADDRESS_UNIX_RECV), [TCP-
LISTEN](socat.html#ADDRESS_TCP4_LISTEN)

****`UNIX-SENDTO:<filename>`****     Communicates with the specified peer
socket, defined by [[<filename>](socat.html#TYPE_FILENAME)] assuming it is a
UNIX domain datagram socket. It sends packets to and receives packets from
that peer socket only. Please note that it might be necessary to
[bind](socat.html#OPTION_BIND) the local socket to an address (e.g.
`/tmp/sock1`, which must not exist before). This address type works well with
socat UNIX-RECVFROM and UNIX-RECV address peers.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[NAMED](socat.html#GROUP_NAMED),[UNIX](socat.html#GROUP_SOCK_UNIX)  
Useful options: [bind](socat.html#OPTION_BIND)  
See also: [UNIX-RECVFROM](socat.html#ADDRESS_UNIX_RECVFROM), [UNIX-
RECV](socat.html#ADDRESS_UNIX_RECV), [UNIX-
CONNECT](socat.html#ADDRESS_UNIX_CONNECT), [UDP-
SENDTO](socat.html#ADDRESS_UDP_SENDTO), [IP-
SENDTO](socat.html#ADDRESS_IP_SENDTO)

****`UNIX-RECVFROM:<filename>`****     Creates a UNIX domain datagram socket
[[<filename>](socat.html#TYPE_FILENAME)]. Receives one packet and may send one
or more answer packets to that peer. This mode is particularly useful with
fork option where each arriving packet - from arbitrary peers - is handled by
its own sub process. This address works well with socat UNIX-SENDTO address
peers.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[NAMED](socat.html#GROUP_NAMED),[CHILD](socat.html#GROUP_CHILD),[UNIX](socat.html#GROUP_SOCK_UNIX)  
See the [note about RECVFROM addresses](socat.html#NOTE_RECVFROM).  
Useful options: [fork](socat.html#OPTION_FORK)  
[umask](socat.html#OPTION_UMASK)  
See also: [UNIX-SENDTO](socat.html#ADDRESS_UNIX_SENDTO), [UNIX-
RECV](socat.html#ADDRESS_UNIX_RECV), [UNIX-
LISTEN](socat.html#ADDRESS_UNIX_LISTEN), [UDP-
RECVFROM](socat.html#ADDRESS_UDP_RECVFROM), [IP-
RECVFROM](socat.html#ADDRESS_IP_RECVFROM)

****`UNIX-RECV:<filename>`****     Creates a UNIX domain datagram socket
[[<filename>](socat.html#TYPE_FILENAME)]. Receives packets from multiple
unspecified peers and merges the data. No replies are possible, this is a
read-only address, see options [-u](socat.html#option_u) and
[-U](socat.html#option_U), and [dual addresses](socat.html#ADDRESS_DUAL). It
can be, e.g., addressed by socat UNIX-SENDTO address peers. It behaves similar
to a syslog server.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[NAMED](socat.html#GROUP_NAMED),[UNIX](socat.html#GROUP_SOCK_UNIX)  
Useful options: [umask](socat.html#OPTION_UMASK)  
See also: [UNIX-SENDTO](socat.html#ADDRESS_UNIX_SENDTO), [UNIX-
RECVFROM](socat.html#ADDRESS_UNIX_RECVFROM), [UNIX-
LISTEN](socat.html#ADDRESS_UNIX_LISTEN), [UDP-
RECV](socat.html#ADDRESS_UDP_RECV), [IP-RECV](socat.html#ADDRESS_IP_RECV)

****`UNIX-CLIENT:<filename>`****     Communicates with the specified peer
socket, defined by [[<filename>](socat.html#TYPE_FILENAME)] assuming it is a
UNIX domain socket. It first tries to connect and, if that fails, assumes it
is a datagram socket, thus supporting both types.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[NAMED](socat.html#GROUP_NAMED),[UNIX](socat.html#GROUP_SOCK_UNIX)  
Useful options: [bind](socat.html#OPTION_BIND)  
See also: [UNIX-CONNECT](socat.html#ADDRESS_UNIX_CONNECT), [UNIX-
SENDTO](socat.html#ADDRESS_UNIX_SENDTO), [GOPEN](socat.html#ADDRESS_GOPEN)

****`VSOCK-CONNECT:<cid>:<port>`****     Establishes a VSOCK stream connection
to the specified <cid> [[VSOCK cid](socat.html#TYPE_VSOCK_ADDRESS)] and <port>
[[VSOCK port](socat.html#TYPE_VSOCK_PORT)].  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [bind](socat.html#OPTION_BIND), [connect-
timeout](socat.html#OPTION_CONNECT_TIMEOUT), [retry](socat.html#OPTION_RETRY),
[readbytes](socat.html#OPTION_READBYTES)  
See also: [VSOCK-LISTEN](socat.html#ADDRESS_VSOCK_LISTEN),

****`VSOCK-LISTEN:<port>`****     Listens on <port> [[VSOCK
port](socat.html#TYPE_VSOCK_PORT)] and accepts a VSOCK connection. Note that
opening this address usually blocks until a client connects.  
Option groups:
[FD](socat.html#GROUP_FD),[SOCKET](socat.html#GROUP_SOCKET),[LISTEN](socat.html#GROUP_LISTEN),[CHILD](socat.html#GROUP_CHILD),[RETRY](socat.html#GROUP_RETRY)  
Useful options: [fork](socat.html#OPTION_FORK),
[bind](socat.html#OPTION_BIND), [max-
children](socat.html#OPTION_MAX_CHILDREN),
[backlog](socat.html#OPTION_BACKLOG), [su](socat.html#OPTION_SUBSTUSER),
[reuseaddr](socat.html#OPTION_SO_REUSEADDR), [retry](socat.html#OPTION_RETRY)  
See also: [VSOCK-CONNECT](socat.html#ADDRESS_VSOCK_CONNECT)

****`ABSTRACT-CONNECT:<string>`****  

****`ABSTRACT-LISTEN:<string>`****  

****`ABSTRACT-SENDTO:<string>`****  

****`ABSTRACT-RECVFROM:<string>`****  

****`ABSTRACT-RECV:<string>`****  

****`ABSTRACT-CLIENT:<string>`****     The ABSTRACT addresses are almost
identical to the related UNIX addresses except that they do not address file
system based sockets but an alternate UNIX domain address space. To achieve
this the socket address strings are prefixed with "\0" internally. This
feature is available (only?) on Linux. Option groups are the same as with the
related UNIX addresses, except that the ABSTRACT addresses are not member of
the NAMED group.  
Useful options: [netns](socat.html#OPTION_NETNS)

## ADDRESS OPTIONS

Address options can be applied to address specifications to influence the
process of opening the addresses and the properties of the resulting data
channels.

For technical reasons not every option can be applied to every address type;
e.g., applying a socket option to a regular file will fail. To catch most
useless combinations as early as in the open phase, the concept of _option
groups_ was introduced. Each option belongs to one or more option groups.
Options can be used only with address types that support at least one of their
option groups (but see [option -g](socat.html#option_g)).

Address options have data types that their values must conform to. Every
address option consists of just a keyword or a keyword followed by "=value",
where value must conform to the options type. Some address options manipulate
parameters of system calls; e.g., option sync sets the `O_SYNC` flag with the
`open()` call. Other options cause a system or library call; e.g., with option
`ttl=value' the `setsockopt(fd, SOL_IP, IP_TTL, value, sizeof(int))` call is
applied. Other options set internal **socat** variables that are used during
data transfer; e.g., `crnl' causes explicit character conversions. A few
options have more complex implementations; e.g., su-d (substuser-delayed)
inquires some user and group infos, stores them, and applies them later after
a possible `chroot()` call.

If multiple options are given to an address, their sequence in the address
specification has (almost) no effect on the sequence of their
execution/application. Instead, **socat** has built in an _option phase_ model
that tries to bring the options in a useful order. Some options exist in
different forms (e.g., unlink, unlink-early, unlink-late) to control the time
of their execution.

If the same option is specified more than once within one address
specification, with equal or different values, the effect depends on the kind
of option. Options resulting in function calls like `setsockopt()` cause
multiple invocations. With options that set parameters for a required call
like `open()` or set internal flags, the value of the last option occurrence
is effective.

The existence or semantics of many options are system dependent. **Socat**
usually does NOT try to emulate missing libc or kernel features, it just
provides an interface to the underlying system. So, if an operating system
lacks a feature, the related option is simply not available on this platform.

The following paragraphs introduce just the more common address options. For a
more comprehensive reference and to find information about canonical option
names, alias names, option phases, and platforms see file **xio.help**.  
  

  

_**FD option group**_

This option group contains options that are applied to a UN*X style file
descriptor, no matter how it was generated. Because all current **socat**
address types are file descriptor based, these options may be applied to any
address.  
Note: Some of these options are also member of another option group, that
provides another, non-fd based mechanism. For these options, it depends on the
actual address type and its option groups which mechanism is used. The second,
non-fd based mechanism is prioritized.

****`cloexec[=<bool>]`****     Sets the `FD_CLOEXEC` flag with the `fcntl()`
system call to value [<bool>](socat.html#TYPE_BOOL). If set, the file
descriptor is closed on `exec()` family function calls. **Socat** internally
handles this flag for the fds it controls, so in most cases there will be no
need to apply this option.

****`setlk[=<bool>]`****     Tries to set a discretionary write lock to the
whole file using the `fcntl(fd, F_SETLK, ...)` system call. If the file is
already locked, this call results in an error. On Linux, when the file
permissions for group are "S" (g-x,g+s), and the file system is locally
mounted with the "mand" option, the lock is mandatory, i.e. prevents other
processes from opening the file.

****`setlkw[=<bool>]`****     Tries to set a discretionary waiting write lock
to the whole file using the `fcntl(fd, F_SETLKW, ...)` system call. If the
file is already locked, this call blocks. See option
[setlk](socat.html#OPTION_SETLK_WR) for information about making this lock
mandatory.

****`setlk-rd[=<bool>]`****     Tries to set a discretionary read lock to the
whole file using the `fcntl(fd, F_SETLK, ...)` system call. If the file is
already write locked, this call results in an error. See option
[setlk](socat.html#OPTION_SETLK_WR) for information about making this lock
mandatory.

****`setlkw-rd[=<bool>]`****     Tries to set a discretionary waiting read
lock to the whole file using the `fcntl(fd, F_SETLKW, ...)` system call. If
the file is already write locked, this call blocks. See option
[setlk](socat.html#OPTION_SETLK_WR) for information about making this lock
mandatory.

****`flock-ex[=<bool>]`****     Tries to set a blocking exclusive advisory
lock to the file using the `flock(fd, LOCK_EX)` system call. **Socat** hangs
in this call if the file is locked by another process.

****`flock-ex-nb[=<bool>]`****     Tries to set a nonblocking exclusive
advisory lock to the file using the `flock(fd, LOCK_EX|LOCK_NB)` system call.
If the file is already locked, this option results in an error.

****`flock-sh[=<bool>]`****     Tries to set a blocking shared advisory lock
to the file using the `flock(fd, LOCK_SH)` system call. **Socat** hangs in
this call if the file is locked by another process.

****`flock-sh-nb[=<bool>]`****     Tries to set a nonblocking shared advisory
lock to the file using the `flock(fd, LOCK_SH|LOCK_NB)` system call. If the
file is already locked, this option results in an error.

****`lock[=<bool>]`****     Sets a blocking lock on the file. Uses the setlk
or flock mechanism depending on availability on the particular platform. If
both are available, the POSIX variant (setlkw) is used.

****`user=<user>`****     Sets the [<user>](socat.html#TYPE_USER) (owner) of
the stream. If the address is member of the NAMED option group, **socat** uses
the `chown()` system call after opening the file or binding to the UNIX domain
socket (race condition!). Without filesystem entry, **socat** sets the user of
the stream using the `fchown()` system call. These calls might require root
privilege.

****`user-late=<user>`****     Sets the owner of the fd to
[<user>](socat.html#TYPE_USER) with the `fchown()` system call after opening
or connecting the channel. This is useful only on file system entries.

****`group=<group>`****     Sets the [<group>](socat.html#TYPE_GROUP) of the
stream. If the address is member of the NAMED option group, **socat** uses the
`chown()` system call after opening the file or binding to the UNIX domain
socket (race condition!). Without filesystem entry, **socat** sets the group
of the stream with the `fchown()` system call. These calls might require group
membership or root privilege.

****`group-late=<group>`****     Sets the group of the fd to
[<group>](socat.html#TYPE_GROUP) with the `fchown()` system call after opening
or connecting the channel. This is useful only on file system entries.

****`mode=<mode>`****     Sets the <mode> [[mode_t](socat.html#TYPE_MODE_T)]
(permissions) of the stream. If the address is member of the NAMED option
group and uses the `open()` or `creat()` call, the mode is applied with these.
If the address is member of the NAMED option group without using these system
calls, **socat** uses the `chmod()` system call after opening the filesystem
entry or binding to the UNIX domain socket (race condition!). Otherwise,
**socat** sets the mode of the stream using `fchmod()` which, btw, might not
have any effect.  
These calls might require ownership or root privilege.  
Note: this option can only tighten the permissions implied by processes umask.
See option [umask](socat.html#OPTION_UMASK) to loosen permissions.

****`perm-late=<mode>`****     Sets the permissions of the fd to value <mode>
[[mode_t](socat.html#TYPE_MODE_T)] using the `fchmod()` system call after
opening or connecting the channel. This is useful only on file system entries.

****`append[=<bool>]`****     Always writes data to the actual end of file. If
the address is member of the OPEN option group, **socat** uses the `O_APPEND`
flag with the `open()` system call
([example](socat.html#EXAMPLE_OPTION_APPEND)). Otherwise, **socat** applies
the `fcntl(fd, F_SETFL, O_APPEND)` call.

****`nonblock[=<bool>]`****     Tries to open or use file in nonblocking mode.
Its only effects are that the `connect()` call of TCP addresses does not
block, and that opening a named pipe for reading does not block. If the
address is member of the OPEN option group, **socat** uses the `O_NONBLOCK`
flag with the `open()` system call. Otherwise, **socat** applies the
`fcntl(fd, F_SETFL, O_NONBLOCK)` call.

****`binary[=<bool>]`****     Opens the file in binary mode to avoid implicit
line terminator conversions (Cygwin).

****`text[=<bool>]`****     Opens the file in text mode to force implicit line
terminator conversions (Cygwin).

****`noinherit[=<bool>]`****     Does not keep this file open in a spawned
process (Cygwin).

****`cool-write[=<bool>]`****     Takes it easy when write fails with EPIPE or
ECONNRESET and logs the message with _notice_ level instead of _error_. This
prevents the log file from being filled with useless error messages when
**socat** is used as a high volume server or proxy where clients often abort
the connection. Use this option only with option
[fork](socat.html#OPTION_FORK) because otherwise it might cause **socat** to
exit with code 0 even on failure.  
This option is deprecated, consider using [option children-
shutup](socat.html#OPTION_CHILDRED_SHUTUP) instead.

****`end-close[=<bool>]`****     Changes the (address dependent) method of
ending a connection to just close the file descriptors. This is useful when
the connection is to be reused by or shared with other processes
([example](socat.html#EXAMPLE_END_CLOSE)).  
Normally, socket connections will be ended with `shutdown(2)` which terminates
the socket even if it is shared by multiple processes. `close(2)` "unlinks"
the socket from the process but keeps it active as long as there are still
links from other processes.  
Similarly, when an address of type EXEC or SYSTEM is ended, socat usually will
explicitly kill the sub process. With this option, it will just close the file
descriptors.

****`shut-none[=<bool>]`****     Changes the (address dependent) method of
shutting down the write part of a connection to not do anything.

****`shut-down[=<bool>]`****     Changes the (address dependent) method of
shutting down the write part of a connection to shutdown(fd, SHUT_WR). Is only
useful with sockets.

****`shut-close[=<bool>]`****     Changes the (address dependent) method of
shutting down the write part of a connection to close(fd).

****`shut-null[=<bool>]`****     When one address indicates EOF, **socat**
will send a zero sized packet to the write channel of the other address to
transfer the EOF condition. This is useful with UDP and other datagram
protocols. Has been tested against netcat and socat with option [null-
eof](socat.html#OPTION_NULL_EOF).

****`null-eof[=<bool>]`****     Normally **socat** will ignore empty (zero
size payload) packets arriving on datagram sockets, so it survives port scans.
With this option **socat** interprets empty datagram packets as EOF indicator
(see [shut-null](socat.html#OPTION_SHUT_NULL)).

****`ioctl-void=<request>`****     Calls `ioctl()` with the request value as
second argument and NULL as third argument. This option allows utilizing
ioctls that are not explicitly implemented in socat.

****`ioctl-int=<request>:<value>`****     Calls `ioctl()` with the request
value as second argument and the integer value as third argument.

****`ioctl-intp=<request>:<value>`****     Calls `ioctl()` with the request
value as second argument and a pointer to the integer value as third argument.

****`ioctl-bin=<request>:<value>`****     Calls `ioctl()` with the request
value as second argument and a pointer to the given data value as third
argument. This data must be specified in [<dalan>](socat.html#TYPE_DATA) form.

****`ioctl-string=<request>:<value>`****     Calls `ioctl()` with the request
value as second argument and a pointer to the given string as third argument.
[<dalan>](socat.html#TYPE_DATA) form.

  

_**NAMED option group**_

These options work on file system entries.  
Please note that, with UNIX domain client addresses, this means the bind
entry, not the target/peer entry.  
See also options [user](socat.html#OPTION_USER),
[group](socat.html#OPTION_GROUP), and [mode](socat.html#OPTION_MODE).

****`user-early=<user>`****     Changes the [<user>](socat.html#TYPE_USER)
(owner) of the file system entry before accessing it, using the `chown()`
system call. This call might require root privilege.

****`group-early=<group>`****     Changes the [<group>](socat.html#TYPE_GROUP)
of the file system entry before accessing it, using the `chown()` system call.
This call might require group membership or root privilege.

****`perm-early=<mode>`****     Changes the <mode>
[[mode_t](socat.html#TYPE_MODE_T)] of the file system entry before accessing
it, using the `chmod()` system call. This call might require ownership or root
privilege.

****`unlink-early[=<bool>]`****     Unlinks (removes) the file before opening
it and even before applying user-early etc.

****`unlink[=<bool>]`****     Unlinks (removes) the file before accessing it,
but after user-early etc.

****`unlink-late[=<bool>]`****     Unlinks (removes) the file after opening it
to make it inaccessible for other processes after a short race condition.

****`unlink-close[=<bool>]`****     Controls removal of the addresses file
system entry when closing the address. For [named
pipes](socat.html#ADDRESS_NAMED_PIPE), [UNIX domain
sockets](socat.html#ADDRESS_UNIX_LISTEN), and the [symbolic
links](socat.html#OPTION_SYMBOLIC_LINK) of [pty
addresses](socat.html#ADDRESS_PTY), the default is remove (1); for [created
files](socat.html#ADDRESS_CREAT), [opened files](socat.html#ADDRESS_OPEN), and
[generic opened files](socat.html#ADDRESS_GOPEN) the default is keep (0).
Setting this option to 1 removes the entry, 0 keeps it. No value means 1.

  

_**OPEN option group**_

The OPEN group options allow setting flags with the `open()` system call.
E.g., option `creat' sets the `O_CREAT` flag. When the used address does not
use `open()` (e.g.STDIO), the `fcntl(..., F_SETFL, ...)` call is used instead.  
See also options [append](socat.html#OPTION_APPEND) and
[nonblock](socat.html#OPTION_O_NONBLOCK).

****`creat[=<bool>]`****     Creates the file if it does not exist
([example](socat.html#EXAMPLE_OPTION_CREAT)).

****`dsync[=<bool>]`****     Blocks `write()` calls until metainfo is
physically written to media.

****`excl[=<bool>]`****     With option creat, if file exists this is an
error.

****`largefile[=<bool>]`****     On 32 bit systems, allows a file larger than
2^31 bytes.

****`noatime[=<bool>]`****     Sets the O_NOATIME options, so reads do not
change the access timestamp.

****`noctty[=<bool>]`****     Does not make this file the controlling
terminal.

****`nofollow[=<bool>]`****     Does not follow symbolic links.

****`nshare[=<bool>]`****     Does not allow sharing this file with other
processes.

****`rshare[=<bool>]`****     Does not allow other processes to open this file
for writing.

****`rsync[=<bool>]`****     Blocks `write()` until metainfo is physically
written to media.

****`sync[=<bool>]`****     Blocks `write()` until data is physically written
to media.

****`rdonly[=<bool>]`****     Opens the file for reading only.

****`wronly[=<bool>]`****     Opens the file for writing only.

****`trunc[=<bool>]`****     Truncates the file to size 0 during opening it.

  

_**REG and BLK option group**_

These options are usually applied to a UN*X file descriptor, but their
semantics make sense only on a file supporting random access.

****`seek=<offset>`****     Applies the `lseek(fd, <offset>, SEEK_SET)` (or
`lseek64` ) system call, thus positioning the file pointer absolutely to
<offset> [[off_t](socat.html#TYPE_OFF) or [off64_t](socat.html#TYPE_OFF64)].
Please note that a missing value defaults to 1, not 0.

****`seek-cur=<offset>`****     Applies the `lseek(fd, <offset>, SEEK_CUR)`
(or `lseek64` ) system call, thus positioning the file pointer <offset>
[[off_t](socat.html#TYPE_OFF) or [off64_t](socat.html#TYPE_OFF64)] bytes
relatively to its current position (which is usually 0). Please note that a
missing value defaults to 1, not 0.

****`seek-end=<offset>`****     Applies the `lseek(fd, <offset>, SEEK_END)`
(or `lseek64` ) system call, thus positioning the file pointer <offset>
[[off_t](socat.html#TYPE_OFF) or [off64_t](socat.html#TYPE_OFF64)] bytes
relatively to the files current end. Please note that a missing value defaults
to 1, not 0.

****`ftruncate=<offset>`****     Applies the `ftruncate(fd, <offset>)` (or
`ftruncate64` if available) system call, thus truncating the file at the
position <offset> [[off_t](socat.html#TYPE_OFF) or
[off64_t](socat.html#TYPE_OFF64)]. Please note that a missing value defaults
to 1, not 0.

****`secrm[=<bool>]`****  

****`unrm[=<bool>]`****  

****`compr[=<bool>]`****  

****`fs-sync[=<bool>]`****  

****`immutable[=<bool>]`****  

****`fs-append[=<bool>]`****  

****`nodump[=<bool>]`****  

****`fs-noatime[=<bool>]`****  

****`journal-data[=<bool>]`****  

****`notail[=<bool>]`****  

****`dirsync[=<bool>]`****     These options change non standard file
attributes on operating systems and file systems that support these features,
like Linux with ext2fs and successors, xfs, or reiserfs. See man 1 chattr for
information on these options. Please note that there might be a race condition
between creating the file and applying these options.

  

_**PIPE options**_

These options may be applied to pipes (fifos).

****`f-setpipe-sz=<int>`****  

****`setpipe=<int>`****     Set the number of bytes a pipe can buffer. Where
more bytes are written the writing process might block. When more bytes are
written in a single `write()` the writing process blocks and might never
recover.

  

_**General address options**_

These options may be applied to all address types. They change some process
properties that are restored after opening the address.

****`chdir=<filename>`****  

****`cd=<filename>`****     Changes the working directory. After opening the
address the master process changes back to the original working directory. Sub
processes inherit the temporary setting.

****`umask=<mode>`****     Sets the umask of the process to <mode>
[[mode_t](socat.html#TYPE_MODE_T)] before opening the address. Useful when
file system entries are created or a shell or program is invoked. Usually the
value is specified as octal number with leading '0'.  
The processes `umask` value is inherited by child processes.  
Note: umask is an inverted value: creating a file with umask=0026 results in
permissions 0640.

  

_**PROCESS option group**_

Options of this group change the process properties instead of just affecting
one data channel. For EXEC and SYSTEM addresses and for LISTEN and CONNECT
type addresses with option [fork](socat.html#OPTION_FORK), these options apply
to the child processes instead of the main **socat** process.

****`chroot=<directory>`****     Performs a `chroot()` operation to
[<directory>](socat.html#TYPE_DIRECTORY) after processing the address
([example](socat.html#EXAMPLE_OPTION_CHROOT)). This call might require root
privilege.

****`chroot-early=<directory>`****     Performs a `chroot()` operation to
[<directory>](socat.html#TYPE_DIRECTORY) before opening the address. This call
might require root privilege.

****`setgid=<group>`****     Changes the primary
[<group>](socat.html#TYPE_GROUP) of the process after processing the address.
This call might require root privilege. Please note that this option does not
drop other group related privileges.

****`setgid-early=<group>`****     Like [setgid](socat.html#OPTION_SETGID) but
is performed before opening the address.

****`setuid=<user>`****     Changes the [<user>](socat.html#TYPE_USER) (owner)
of the process after processing the address. This call might require root
privilege. Please note that this option does not drop group related
privileges. Check if option [su](socat.html#OPTION_SUBSTUSER) better fits your
needs.

****`setuid-early=<user>`****     Like [setuid](socat.html#OPTION_SETUID) but
is performed before opening the address.

****`su=<user>`****     Changes the [<user>](socat.html#TYPE_USER) (owner) and
groups of the process after processing the address
([example](socat.html#EXAMPLE_OPTION_SUBSTUSER)). This call might require root
privilege.

****`su-d=<user>`****     Short name for `substuser-delayed`. Changes the
[<user>](socat.html#TYPE_USER) (owner) and groups of the process after
processing the address
([example](socat.html#EXAMPLE_OPTION_SUBSTUSER_DELAYED)). The user and his
groups are retrieved _before_ a possible `chroot()` . This call might require
root privilege.

****`setpgid=<pid_t>`****     Makes the process a member of the specified
process group [<pid_t>](socat.html#TYPE_PID_T). If no value is given, or if
the value is 0 or 1, the process becomes leader of a new process group.

****`setsid`****     Makes the process the leader of a new session
([example](socat.html#EXAMPLE_OPTION_SETSID)).

****`netns=<net-namespace-name>`****     Before opening the address it tries
to switch to the named network namespace. After opening the address it
switches back to the previous namespace ([example with TCP
forwarder](socat.html#EXAMPLE_OPTION_NETNS), [example with virtual network
connection](socat.html#EXAMPLE_TUN_NETNS)).  
Only on Linux; requires root; use option `--experimental`.  

  

_**READLINE option group**_

These options apply to the readline address type.

****`history=<filename>`****     Reads and writes history from/to
[<filename>](socat.html#TYPE_FILENAME)
([example](socat.html#EXAMPLE_OPTION_HISTORY)).

****`noprompt`****     Since version 1.4.0, socat per default tries to
determine a prompt - that is then passed to the readline call - by remembering
the last incomplete line of the output. With this option, socat does not pass
a prompt to readline, so it begins line editing in the first column of the
terminal.

****`noecho=<pattern>`****     Specifies a regular pattern for a prompt that
prevents the following input line from being displayed on the screen and from
being added to the history. The prompt is defined as the text that was output
to the readline address after the last newline character and before an input
character was typed. The pattern is a regular expression, e.g.
"^[Pp]assword:.*$" or "([Uu]ser:|[Pp]assword:)". See regex(7) for details.
([example](socat.html#EXAMPLE_OPTION_NOECHO))

****`prompt=<string>`****     Passes the string as prompt to the readline
function. readline prints this prompt when stepping through the history. If
this string matches a constant prompt issued by an interactive program on the
other socat address, consistent look and feel can be achieved.

  

_**APPLICATION option group**_

This group contains options that work at data level. Note that these options
only apply to the "raw" data transferred by socat, but not to protocol data
used by addresses like [PROXY](socat.html#ADDRESS_PROXY_CONNECT).

****`cr`****     Converts the default line termination character NL ('\n',
0x0a) to/from CR ('\r', 0x0d) when writing/reading on this channel.

****`crnl`****     Converts the default line termination character NL ('\n',
0x0a) to/from CRNL ("\r\n", 0x0d0a) when writing/reading on this channel
([example](socat.html#EXAMPLE_OPTION_CRNL)). Note: socat simply strips all CR
characters.

****`ignoreeof`****     When EOF occurs on this channel, **socat** ignores it
and tries to read more data (like "tail -f")
([example](socat.html#EXAMPLE_OPTION_IGNOREEOF)).

****`readbytes=<bytes>`****     **socat** reads only so many bytes from this
address (the address provides only so many bytes for transfer and pretends to
be at EOF afterwards). Must be greater than 0.

****`lockfile=<filename>`****     If lockfile exists, exits with error. If
lockfile does not exist, creates it and continues, unlinks lockfile on exit.

****`waitlock=<filename>`****     If lockfile exists, waits until it
disappears. When lockfile does not exist, creates it and continues, unlinks
lockfile on exit.

****`escape=<int>`****     Specifies the numeric code of a character that
triggers EOF on the input stream. It is useful with a terminal in raw mode
([example](socat.html#EXAMPLE_OPTION_ESCAPE)).

  

_**SOCKET option group**_

These options are intended for all kinds of sockets, e.g. IP or UNIX domain.
Most are applied with a `setsockopt()` call.

****`bind=<sockname>`****     Binds the socket to the given socket address
using the `bind()` system call. The form of <sockname> is socket domain
dependent: IP4 and IP6 allow the form [hostname|hostaddress][:(service|port)]
([example](socat.html#EXAMPLE_OPTION_BIND_TCP4)), VSOCK allows the form
[cid][:(port)].  
See also: [unix-bind-tempname](socat.html#OPTION_UNIX_BIND_TEMPNAME)

****`connect-timeout=<seconds>`****     Abort the connection attempt after
<seconds> [[timeval](socat.html#TYPE_TIMEVAL)] with error status.

****`so-bindtodevice=<interface>`****     Binds the socket to the given
[<interface>](socat.html#TYPE_INTERFACE). This option might require root
privilege.

****`broadcast`****     For datagram sockets, allows sending to broadcast
addresses and receiving packets addressed to broadcast addresses.

****`debug`****     Enables socket debugging.

****`dontroute`****     Only communicates with directly connected peers, does
not use routers.

****`keepalive`****     Enables sending keepalives on the socket.

****`linger=<seconds>`****     Blocks `shutdown()` or `close()` until data
transfers have finished or the given timeout [[int](socat.html#TYPE_INT)]
expired.

****`oobinline`****     Places out-of-band data in the input data stream.

****`priority=<priority>`****     Sets the protocol defined <priority>
[[<int>](socat.html#TYPE_INT)] for outgoing packets.

****`rcvbuf=<bytes>`****     Sets the size of the receive buffer after the
`socket()` call to <bytes> [[int](socat.html#TYPE_INT)]. With TCP sockets,
this value corresponds to the socket's maximal window size.

****`rcvbuf-late=<bytes>`****     Sets the size of the receive buffer when the
socket is already connected to <bytes> [[int](socat.html#TYPE_INT)]. With TCP
sockets, this value corresponds to the socket's maximal window size.

****`so-rcvtimeo=<time>, rcvtimeo=<time>`****     Specifies the time
[[int](socat.html#TYPE_TIMEVAL)] until `recv()` , `read()` etc. functions
timeout when no data is received. Note that in the transfer phase **socat**
only calls these functions when `select()` has reported that data is
available. However this option is useful with DTLS addresses to timeout during
connection negotiation.

****`so-sndtimeo=<time>, sndtimeo=<time>`****     Like [so-
recvtimeo](socat.html#OPTION_SO_RCVTIMOE), but for `send` . Not usecase known.

****`rcvlowat=<bytes>`****     Specifies the minimum number of received bytes
[[int](socat.html#TYPE_INT)] until the socket layer will pass the buffered
data to **socat**.

****`reuseaddr[=[0|1]]`****     Allows other sockets to bind to an address
even if parts of it (e.g. the local port) are already in use by **socat**.  
With version 1.8.0, this socket option is set automatically for TCP LISTEN
addresses. If you prefer the system default (no related
`setsockopt(...SO_REUSEADDR...)` call at all), use form `reuseaddr=`.  
([example](socat.html#EXAMPLE_OPTION_SO_REUSEADDR)).

****`sndbuf=<bytes>`****     Sets the size of the send buffer after the
`socket()` call to <bytes> [[int](socat.html#TYPE_INT)].

****`sndbuf-late=<bytes>`****     Sets the size of the send buffer when the
socket is connected to <bytes> [[int](socat.html#TYPE_INT)].

****`sndlowat=<bytes>`****     Specifies the minimum number of bytes in the
send buffer until the socket layer will send the data to <bytes>
[[int](socat.html#TYPE_INT)].

****`protocol-family=<string>`**, **`pf=<string>`****     pf means protocol
family, sometimes called communication domain or address family. It forces the
use of the specified IP version or protocol. <string> can be a number or
something like "ip4" (meaning 2) or "ip6" (meaning 10). The resulting value is
used as first argument to the `socket()` or `socketpair()` calls, and in the
field `ai_family` in the `getaddrinfo()` hints. This option affects address
resolution and the required syntax of bind and range options.

****`socktype=<type>`****     Sets the type of the socket, specified as second
argument to the `socket()` or `socketpair()` calls, to <type>
[[int](socat.html#TYPE_INT)]. Address resolution is not affected by this
option. Under Linux, 1 means stream oriented socket, 2 means datagram socket,
3 means raw socket, and 5 seqpacket (stream keeping packet boundaries).
Datagrams are useful when you want to keep packet boundaries.

****`protocol`****     Sets the protocol of the socket, specified as third
argument to the `socket()` or `socketpair()` calls, to <protocol>
[[int](socat.html#TYPE_INT)]. Address resolution is not affected by this
option. 6 means TCP, 17 means UDP.

****`reuseport`****     Set the `SO_REUSEPORT` socket option.

****`so-timestamp`****     Sets the SO_TIMESTAMP socket option. This enables
receiving and logging of timestamp ancillary messages.

****`setsockopt=<level>:<optname>:<optval>`****     Invokes `setsockopt()` for
the socket with the given parameters. `level` [[int](socat.html#TYPE_INT)] is
used as second argument to `setsockopt()` and specifies the layer, e.g.
SOL_TCP for TCP (6 on Linux), or SOL_SOCKET for the socket layer (1 on Linux).
`optname` [[int](socat.html#TYPE_INT)] is the third argument to `setsockopt()`
and tells which socket option is to be set. For the actual numbers you might
have to look up the appropriate include files of your system. For the 4th and
5th `setsockopt()` parameters, `value` [[dalan](socat.html#TYPE_DATA)]
specifies an arbitrary sequence of bytes that are passed to the function per
pointer, with the automatically derived length parameter.

****`setsockopt-int=<level>:<optname>:<optval>`****     Like `setsockopt`, but
<optval> is a pointer to int [[int](socat.html#TYPE_INT)]

****`setsockopt-listen=<level>:<optname>:<optval>`****     Like `setsockopt`,
but for listen type addresses it is applied to the listening socket instead of
the connected socket.

****`setsockopt-string=<level>:<optname>:<optval>`****     Like `setsockopt`,
but <optval> is a [string](socat.html#TYPE_STRING). This string is passed to
the function with trailing null character, and the length parameter is
automatically derived from the data.

****`setsockopt-socket=<level>:<optname>:<optval>`****     Like `setsockopt`,
but is applied to the socket before other operations ( `bind()` , `connect()`
, `accept()` , ...)

****`setsockopt-connected=<level>:<optname>:<optval>`****     Like
`setsockopt`, but is applied only when the socket has been connected by a
`connect()` or `listen()` call.

  

_**UNIX option group**_

These options apply to UNIX domain based addresses.

****`bind-tempname[=/tmp/pre-XXXXXX], unix-bind-tempname[=/tmp/pre-
XXXXXX]`****     Binds to a random path or random address (on abstract
namespace sockets). This is useful with datagram client addresses (`SENDTO`,
or `CLIENT`) that are opened in child processes forked off from a common
parent process where the child processes cannot have different bind options.
In the path `X` 's get replaced with a random character sequence similar to
tempnam(3). When no argument is given **socat** takes a default like
`/tmp/fileXXXXXX` .  

****`unix-tightsocklen[=(0|1)]`****     On socket operations, pass a socket
address length that does not include the whole `struct sockaddr_un` record but
(besides other components) only the relevant part of the filename or abstract
string. Default is 1.

_**IP4 and IP6 option groups**_

These options can be used with IPv4 and IPv6 based sockets.

****`tos=<tos>`****     Sets the TOS (type of service) field of outgoing
packets to <tos> [[byte](socat.html#TYPE_BYTE)] (see RFC 791).

****`ttl=<ttl>`****     Sets the TTL (time to live) field of outgoing packets
to <ttl> [[byte](socat.html#TYPE_BYTE)].

****`ip-options=<data>`****     Sets IP options like source routing. Must be
given in binary form, recommended format is a leading "x" followed by an even
number of hex digits. This option may be used multiple times, data are
appended. E.g., to connect to host 10.0.0.1 via some gateway using a loose
source route, use the gateway as address parameter and set a loose source
route using the option `ip-options=x8307040a000001` .  
IP options are defined in RFC 791.  

****`ip-mtu-discover=<0|1|2>, mtudiscover=<0|1|2>`****     Takes 0, 1, 2 to
never, want, or always use path MTU discover on the IPv4 socket.

****`ip-pktinfo`****     Sets the IP_PKTINFO socket option. This enables
receiving and logging of ancillary messages containing destination address and
interface (Linux) ([example](socat.html#EXAMPLE_ANCILLARY)).

****`ip-recverr`****     Sets the IP_RECVERR socket option. This enables
receiving and logging of ancillary messages containing detailed error
information.

****`ip-recvopts`****     Sets the IP_RECVOPTS socket option. This enables
receiving and logging of IP options ancillary messages (Linux, *BSD).

****`ip-recvtos`****     Sets the IP_RECVTOS socket option. This enables
receiving and logging of TOS (type of service) ancillary messages (Linux).

****`ip-recvttl`****     Sets the IP_RECVTTL socket option. This enables
receiving and logging of TTL (time to live) ancillary messages (Linux, *BSD).

****`ip-recvdstaddr`****     Sets the IP_RECVDSTADDR socket option. This
enables receiving and logging of ancillary messages containing destination
address (*BSD) ([example](socat.html#EXAMPLE_ANCILLARY)).

****`ip-recvif`****     Sets the IP_RECVIF socket option. This enables
receiving and logging of interface ancillary messages (*BSD)
([example](socat.html#EXAMPLE_ANCILLARY)).

****`ip-add-membership=<multicast-address:interface-address>`****  

****`ip-add-membership=<multicast-address:interface-name>`****  

****`ip-add-membership=<multicast-address:interface-index>`****  

****`ip-add-membership=<multicast-address:interface-address:interface-
name>`****  

****`ip-add-membership=<multicast-address:interface-address:interface-
index>`****     Makes the socket member of the specified multicast group. This
only works for IPv4, see [ipv6-join-group](socat.html#OPTION_IPV6_JOIN_GROUP)
for the IPv6 variant. The option takes the IP address of the multicast group
and info about the desired network interface. The most common syntax is the
first one, while the others are only available on systems that provide `struct
mreqn` (Linux).  
The indices of active network interfaces can be shown using the utility
**procan**.

****`ip-add-source-membership=<multicast-address:interface-address:source-
address>`****     Makes the socket member of the specified multicast group for
the specified source, i.e. only multicast traffic from this address is to be
delivered. This only works for IPv4, see [ipv6-join-source-
group](socat.html#OPTION_IPV6_JOIN_SOURCE_GROUP) for the IPv6 variant. The
option takes the IP address of the multicast group, the IP address of the
desired network interface and the source IP address of the multicast traffic.

****`ipv6-join-group=<multicast-address:interface-name>`****  

****`ipv6-join-group=<multicast-address:interface-index>`****     Makes the
socket member of the specified multicast group. This only works for IPv6, see
[ip-add-membership](socat.html#OPTION_IP_ADD_MEMBERSHIP) for the IPv4 variant.
The option takes the IP address of the multicast group and info about the
desired network interface. The indices of active network interfaces can be
shown using the utility **procan**.

****`ipv6-join-source-group=<multicast-address:interface-name:source-
address>`****  

****`ipv6-join-source-group=<multicast-address:interface-index:source-
address>`****     Makes the socket member of the specified multicast group for
the specified source, i.e. only multicast traffic from this address is to be
delivered. This only works for IPv6, see [ip-add-source-
membership](socat.html#OPTION_IP_ADD_SOURCE_MEMBERSHIP) for the IPv4 variant.
The option takes the IP address of the multicast group, info about the desired
network interface and the source IP address of the multicast traffic. The
indices of active network interfaces can be shown using the utility
**procan**.  
This feature is experimental.

****`ip-multicast-if=<hostname>`****     Specifies hostname or address of the
network interface to be used for multicast traffic.

****`ip-multicast-loop[=<bool>], mcloop[=<bool>]`****     Specifies if
outgoing multicast traffic should also loop back to the interface.

****`ip-multicast-ttl=<byte>`****     Sets the TTL used for outgoing multicast
traffic. Default is 1.

****`ip-transparent`****     Sets the IP_TRANSPARENT socket option. This
option might require root privilege.

  

_**Resolver options**_

These options temporarily change the behaviour of hostname resolution. The
options of form `ai-*` affect behaviour of the `getaddrinfo()` function that
includes `/etc/hosts` and NIS based lookups.

The addresses of form `res-*` only affect DNS lookups, and only when the
result is not cached in `nscd` . These options might not work on all operating
systems or libc implementations.

****`ai-addrconfig[=0|1]`****  

****`addrconfig[=0|1]`****     Sets or unsets the AI_ADDRCONFIG flag to
prevent name resolution to address families that are not available on the
computer (e.g. IPv6). Default value is 1 in case the resolver does not get an
address family hint from Socat address or defaults.

****`ai-passive[=0|1]`****  

****`passive[=0|1]`****     Sets of unsets the AI_PASSIVE flag for
`getaddrinfo()` calls. Default is 1 for LISTEN, RECV, and RECVFROM type
addresses, and with [bind](socat.html#OPTION_BIND) option.

****`ai-v4mapped[=0|1]`****  

****`v4mapped[=0|1]`****     Sets or unsets the AI_V4MAPPED flag for
`getaddrinfo()` . With **socat** addresses requiring IPv6 addresses, this
resolves IPv4 addresses to the appropriate IPv6 address [::ffff:*:*]. For IPv6
**socat** addresses, the default is 1.

****`ai-all[=0|1]`****     Sets or unsets the AI_ALL flag for `getaddrinfo()`
.

****`res-debug`****  

****`res-aaonly`****  

****`res-usevc`****  

****`res-primary`****  

****`res-igntc`****  

****`res-recurse`****  

****`res-defnames`****  

****`res-stayopen`****  

****`res-dnsrch`****     These options set the corresponding resolver (name
resolution) option flags. Append "=0" to clear a default option. See man
resolver(5) for more information on these options. **Socat** restores the old
values after finishing the open phase of the address, so these options are
valid just for the address they are applied to.  
Please note that these flags only affect DNS resolution, but not hosts or NIS
based name resolution, and they have no effect when (g)libc retrieves the
results from `nscd` .

****`res-retrans=<int>`****     Sets the retransmission time interval of the
DNS resolver (based on an undocumented feature).

****`res-retry=<int>`****     Sets the number of retransmits of the DNS
resolver (based on an undocumented feature).

****`res-nsaddr=<ipaddr>[:<port>]`****     Tries to overwrite nameserver
settings loaded from /etc/resolv.conf by writing the given IPv4 address into
the undocumented `_res:nsaddr_list[0]` field. `/etc/hosts` is still checked by
resolver. Please note that glibc's `nscd` is always queried first when it is
running!

  

_**IP6 option group**_

These options can only be used on IPv6 based sockets. See [IP
options](socat.html#GROUP_IP) for options that can be applied to both IPv4 and
IPv6 sockets.

****`ipv6only[=<bool>]`****     Sets the IPV6_V6ONLY socket option. If 0, the
TCP stack will also accept connections using IPv4 protocol on the same port.
The default is system dependent.

****`ipv6-recvdstopts`****     Sets the IPV6_RECVDSTOPTS socket option. This
enables receiving and logging of ancillary messages containing the destination
options.

****`ipv6-recvhoplimit`****     Sets the IPV6_RECVHOPLIMIT socket option. This
enables receiving and logging of ancillary messages containing the hoplimit.

****`ipv6-recvhopopts`****     Sets the IPV6_RECVHOPOPTS socket option. This
enables receiving and logging of ancillary messages containing the hop
options.

****`ipv6-recvpktinfo`****     Sets the IPV6_RECVPKTINFO socket option. This
enables receiving and logging of ancillary messages containing destination
address and interface.

****`ipv6-unicast-hops=link(TYPE_INT)(<int>)`****     Sets the
IPV6_UNICAST_HOPS socket option. This sets the hop count limit (TTL) for
outgoing unicast packets.

****`ipv6-recvrthdr`****     Sets the IPV6_RECVRTHDR socket option. This
enables receiving and logging of ancillary messages containing routing
information.

****`ipv6-tclass`****     Sets the IPV6_TCLASS socket option. This sets the
transfer class of outgoing packets.

****`ipv6-recvtclass`****     Sets the IPV6_RECVTCLASS socket option. This
enables receiving and logging of ancillary messages containing the transfer
class.

****`ipv6-multicast-loop[=<bool>], mcloop6[=<bool>]`****     Specifies if
outgoing multicast traffic should also loop back to the interface.

****`ipv6-mtu-discover=<0|1|2>, mtudiscover6=<0|1|2>`****     Takes 0, 1, 2 to
never, want, or always use path MTU discover on the IPv6 socket.

  

_**TCP option group**_

These options may be applied to TCP sockets. They work by invoking
`setsockopt()` with the appropriate parameters.

****`cork`****     Doesn't send packets smaller than MSS (maximal segment
size).

****`defer-accept`****     While listening, accepts connections only when data
from the peer arrived.

****`keepcnt=<count>`****     Sets the number of keepalives before shutting
down the socket to <count> [[int](socat.html#TYPE_INT)].

****`keepidle=<seconds>`****     Sets the idle time before sending the first
keepalive to <seconds> [[int](socat.html#TYPE_INT)].

****`keepintvl=<seconds>`****     Sets the interval between two keepalives to
<seconds> [[int](socat.html#TYPE_INT)].

****`linger2=<seconds>`****     Sets the time to keep the socket in FIN-WAIT-2
state to <seconds> [[int](socat.html#TYPE_INT)].

****`mss=<bytes>`****     Sets the MSS (maximum segment size) after the
`socket()` call to <bytes> [[int](socat.html#TYPE_INT)]. This value is then
proposed to the peer with the SYN or SYN/ACK packet
([example](socat.html#EXAMPLE_OPTION_MSS)).

****`mss-late=<bytes>`****     Sets the MSS of the socket after connection has
been established to <bytes> [[int](socat.html#TYPE_INT)].

****`nodelay`****     Turns off the Nagle algorithm for measuring the RTT
(round trip time).

****`rfc1323`****     Enables RFC1323 TCP options: TCP window scale, round-
trip time measurement (RTTM), and protect against wrapped sequence numbers
(PAWS) (AIX).

****`stdurg`****     Enables RFC1122 compliant urgent pointer handling (AIX).

****`syncnt=<count>`****     Sets the maximal number of SYN retransmits during
connect to <count> [[int](socat.html#TYPE_INT)].

****`md5sig`****     Enables generation of MD5 digests on the packets
(FreeBSD).

****`noopt`****     Disables use of TCP options (FreeBSD, MacOSX).

****`nopush`****     sets the TCP_NOPUSH socket option (FreeBSD, MacOSX).

****`sack-disable`****     Disables use the selective acknowledge feature
(OpenBSD).

****`signature-enable`****     Enables generation of MD5 digests on the
packets (OpenBSD).

****`abort-threshold=<milliseconds>`****     Sets the time to wait for an
answer of the peer on an established connection (HP-UX).

****`conn-abort-threshold=<milliseconds>`****     Sets the time to wait for an
answer of the server during the initial connect (HP-UX).

****`keepinit`****     Sets the time to wait for an answer of the server
during connect() before giving up. Value in half seconds, default is 150 (75s)
(Tru64).

****`paws`****     Enables the "protect against wrapped sequence numbers"
feature (Tru64).

****`sackena`****     Enables selective acknowledge (Tru64).

****`tsoptena`****     Enables the time stamp option that allows RTT
recalculation on existing connections (Tru64).

  

_**UDP option group**_

This option may be applied to UDP datagram sockets.

****`udp-ignore-peerport>`****     Address UDP-DATAGRAM expects incoming
responses to come from the port specified in its second parameter. With this
option, it accepts packets coming from any port.

  

_**UDPLITE option group**_

These options may be applied to UDPLITE addresses:

****`udplite-send-cscov`****     Sets the number of bytes for which the
checksum is calculated and sent ("checksum coverage").

****`udplite-recv-cscov`****     Sets the number of bytes for which the
checksum is checked ("checksum coverage").

  

_**SCTP option group**_

These options may be applied to SCTP stream sockets.

****`sctp-nodelay`****     Sets the SCTP_NODELAY socket option that disables
the Nagle algorithm.

****`sctp-maxseg=<bytes>`****     Sets the SCTP_MAXSEG socket option to
<bytes> [[int](socat.html#TYPE_INT)]. This value is then proposed to the peer
with the SYN or SYN/ACK packet.

  

_**DCCP option group**_

These options may be applied to DCCP sockets.

****`dccp-set-ccid=<int>`****  

****`ccid=<int>`****     Selects the desired congestion control mechanism
(CCID).

  

_**UDP, TCP, SCTP, DCCP, and UDPLITE option group**_

Here we find options that are related to the network port mechanism and thus
can be used with UDP, TCP, SCTP, DCCP, and UDP-Lite client and server
addresses.

****`sourceport=<port>`****     For outgoing (client) connections, it sets the
source [<port>](socat.html#TYPE_PORT) using an extra `bind()` call. With TCP
or UDP listen addresses, socat immediately shuts down the connection if the
client does not use this sourceport. UDP-RECV, UDP-RECVFROM, UDP-SENDTO, and
UDP-DATAGRAM addresses ignore the packet when it does not match.
([example](socat.html#EXAMPLE_OPTION_SOURCEPORT)).

****`lowport`****     Outgoing (client) connections with this option use an
unused random source port between 640 and 1023 incl. On UNIX class operating
systems, this requires root privilege, and thus indicates that the client
process is authorized by local root. TCP and UDP listen addresses with this
option immediately shut down the connection if the client does not use a
sourceport <= 1023. This mechanism can provide limited authorization under
some circumstances.

  

_**SOCKS option group**_

When using SOCKS type addresses, some socks specific options can be set.

****`socksport=<tcp service>`****     Overrides the default "socks" service or
port 1080 for the socks server port with [<TCP
service>](socat.html#TYPE_TCP_SERVICE).

****`socksuser=<user>`****     Sends the <user>
[[string](socat.html#TYPE_STRING)] in the username field to the socks server.
Default is the actual user name ($LOGNAME or $USER)
([example](socat.html#EXAMPLE_OPTION_SOCKSUSER)).

****`sockspass=<string>`****     Sends the given password
[[string](socat.html#TYPE_STRING)] on username,password authentication to the
socks5 server.

  

_**HTTP option group**_

Options that can be provided with HTTP type addresses. The only HTTP address
currently implemented is [proxy-connect](socat.html#ADDRESS_PROXY_CONNECT).

****`http-version=<string>`****     Changes the default "1.0" that is sent to
the server in the initial HTTP request. Currently it has not other effect, in
particular it does not provide any means to send a Host header.

****`proxyport=<TCP service>`****     Overrides the default HTTP proxy port
8080 with [<TCP service>](socat.html#TYPE_TCP_SERVICE).

****`ignorecr`****     The HTTP protocol requires the use of CR+NL as line
terminator. When a proxy server violates this standard, socat might not
understand its answer. This option directs socat to interpret NL as line
terminator and to ignore CR in the answer. Nevertheless, socat sends CR+NL to
the proxy.

****`proxy-authorization=<username>:<password>`****     Provide "basic"
authentication to the proxy server. The argument to the option is used with a
"Proxy-Authorization: Basic" header in base64 encoded form.  
Note: username and password are visible for every user on the local machine in
the process list; username and password are transferred to the proxy server
unencrypted (base64 encoded) and might be sniffed.

****`proxy-authorization-file=<filename>`****     Like option [proxy-
authorization](socat.html#OPTION_PROXY_AUTHORIZATION), but the credentials are
read from the file and therefore not visible in the process list.  

****`resolve`****     Per default, socat sends to the proxy a CONNECT request
containing the target hostname. With this option, socat resolves the hostname
locally and sends the IP address. Please note that, according to RFC 2396,
only name resolution to IPv4 addresses is implemented.

  

_**RANGE option group**_

These options check if a connecting client should be granted access. They can
be applied to listening and receiving network sockets. tcp-wrappers options
fall into this group.

****`range=<address-range>`****     After accepting a connection, tests if the
peer is within _range_. For IPv4 addresses, address-range takes the form
address/bits, e.g. 10.0.0.0/8, or address:mask, e.g. 10.0.0.0:255.0.0.0
([example](socat.html#EXAMPLE_OPTION_RANGE)); for IPv6, it is
[ip6-address]/bits, e.g. [::1]/128. If the client address does not match,
**socat** refuses the connection attempt, issues a warning, and keeps
listening/receiving.

****`tcpwrap[=<name>]`****     Uses Wietse Venema's libwrap (tcpd) library to
determine if the client is allowed to connect. The configuration files are
/etc/hosts.allow and /etc/hosts.deny per default, see "man 5 hosts_access" for
more information. The optional <name> (type [string](socat.html#TYPE_STRING))
is passed to the wrapper functions as daemon process name
([example](socat.html#EXAMPLE_OPTION_TCPWRAPPERS)). If omitted, the basename
of socats invocation (argv[0]) is passed. If both tcpwrap and range options
are applied to an address, both conditions must be fulfilled to allow the
connection.

****`allow-table=<filename>`****     Takes the specified file instead of
/etc/hosts.allow.

****`deny-table=<filename>`****     Takes the specified file instead of
/etc/hosts.deny.

****`tcpwrap-etc=<directoryname>`****     Looks for hosts.allow and hosts.deny
in the specified directory. Is overridden by options [hosts-
allow](socat.html#OPTION_TCPWRAP_HOSTS_ALLOW_TABLE) and [hosts-
deny](socat.html#OPTION_TCPWRAP_HOSTS_DENY_TABLE).

  

_**LISTEN option group**_

Options specific to listening sockets.

****`backlog=<count>`****     Sets the backlog value passed with the
`listen()` system call to <count> [[int](socat.html#TYPE_INT)]. Default is 5.

****`accept-timeout=<seconds>`****     End waiting for a connection after
<seconds> [[timeval](socat.html#TYPE_TIMEVAL)] with error status.

  

_**CHILD option group**_

Addresses of LISTEN and CONNECT type take the [fork](socat.html#OPTION_FORK)
option to handle multiple connections via child processes.

****`fork`****     After establishing a connection, handles its channel in a
child process and keeps the parent process attempting to produce more
connections, either by listening or by connecting in a loop
([example](socat.html#EXAMPLE_OPTION_FORK)).  
OPENSSL-CONNECT and OPENSSL-LISTEN differ in when they actually fork off the
child: OPENSSL-LISTEN forks _before_ the SSL handshake, while OPENSSL-CONNECT
forks _afterwards_. [retry](socat.html#OPTION_RETRY) and
[forever](socat.html#OPTION_FOREVER) options are not inherited by the child
process.  
On some operating systems (e.g. FreeBSD) this option does not work for UDP-
LISTEN addresses.  

****`max-children=<count>`****     Limits the number of concurrent child
processes [[int](socat.html#TYPE_INT)]. Default is no limit.

****`children-shutup[=1|2|..]`****     Decreases the severity of log messages
produced by child processes. For example, with value 1 notices are logged as
info (or dropped depending on [option -dX](socat.html#option_d)), and errors
are logged as warnings but still cause termination of the child process.  
This option is intended to reduce logging of high volume servers or proxies.  
This option succeeds [option cool-write](socat.html#OPTION_COOL_WRITE).

  

_**EXEC option group**_

Options for addresses that invoke a program.

****`path=<string>`****     Overrides the PATH environment variable for
searching the program with [<string>](socat.html#TYPE_STRING). This `$PATH`
value is effective in the child process too.

****`login`****     Prefixes `argv[0]` for the `execvp()` call with '-', thus
making a shell behave as login shell.

  

_**FORK option group**_

EXEC or SYSTEM addresses invoke a program using a child process and transfer
data between **socat** and the program. The interprocess communication
mechanism can be influenced with the following options. Per default, a
`socketpair()` is created and assigned to stdin and stdout of the child
process, while stderr is inherited from the **socat** process, and the child
process uses file descriptors 0 and 1 for communicating with the main socat
process.

****`nofork`****     Does not fork a subprocess for executing the program,
instead calls execvp() or system() directly from the actual socat instance.
This avoids the overhead of another process between the program and its peer,
but introduces a lot of restrictions:

  * this option can only be applied to the second **socat** address. 
  * it cannot be applied to a part of a [dual](socat.html#ADDRESS_DUAL) address. 
  * the first socat address cannot be OPENSSL or READLINE 
  * socat options -b, -t, -D, -l, -v, -x become useless 
  * for both addresses, options ignoreeof, cr, and crnl become useless 
  * for both addresses, address specific end/shutdown handling (e.g., graceful socket shutdown) and related options become useless 
  * for the second address (the one with option nofork), options append,  cloexec, flock, user, group, mode, nonblock, perm-late, setlk, and setpgid cannot be applied. Some of these could be used on the first address though. 

****`pipes`****     Creates a pair of unnamed pipes for interprocess
communication instead of a socket pair.

****`openpty`****     Establishes communication with the sub process using a
pseudo terminal created with `openpty()` instead of the default (socketpair or
ptmx).

****`ptmx`****     Establishes communication with the sub process using a
pseudo terminal created by opening **/dev/ptmx** or **/dev/ptc** instead of
the default (socketpair).

****`pty`****     Establishes communication with the sub process using a
pseudo terminal instead of a socket pair. Creates the pty with an available
mechanism. If openpty and ptmx are both available, it uses ptmx because this
is POSIX compliant ([example](socat.html#EXAMPLE_OPTION_PTY)).

****`ctty`****     Makes the pty the controlling tty of the sub process
([example](socat.html#EXAMPLE_OPTION_CTTY)).

****`stderr`****     Directs stderr of the sub process to its output channel
by making stderr a `dup()` of stdout
([example](socat.html#EXAMPLE_OPTION_STDERR)).

****`fdin=<fdnum>`****     Assigns the sub processes input channel to its file
descriptor [<fdnum>](socat.html#TYPE_FDNUM) instead of stdin (0). The program
started from the subprocess has to use this fd for reading data from **socat**
([example](socat.html#EXAMPLE_OPTION_FDIN)).

****`fdout=<fdnum>`****     Assigns the sub processes output channel to its
file descriptor [<fdnum>](socat.html#TYPE_FDNUM) instead of stdout (1). The
program started from the subprocess has to use this fd for writing data to
**socat** ([example](socat.html#EXAMPLE_OPTION_FDOUT)).

****`sighup`** , **`sigint`** , **`sigquit`****     Has **socat** pass signals
of this type to the sub process. If no address has this option, socat
terminates on these signals.

  

Options for [address SHELL](socat.html#ADDRESS_SHELL)

****`shell=<filename>`****     Overwrites use the default shell with the named
executable, e.g. `/bin/dash`. Also sets the `SHELL` environment variable.

  

_**TERMIOS option group**_

For addresses that work on a tty (e.g., stdio, file:/dev/tty, exec:...,pty),
the terminal parameters defined in the UN*X termios mechanism are made
available as address option parameters. Please note that changes of the
parameters of your interactive terminal remain effective after **socat** 's
termination, so you might have to enter "reset" or "stty sane" in your shell
afterwards. For EXEC and SYSTEM addresses with option PTY, these options apply
to the pty by the child processes.

****`b0`****     Disconnects the terminal.

****`b19200`****     Sets the serial line speed to 19200 baud. Some other
rates are possible; use something like `socat -hh |grep ' b[1-9]'` to find all
speeds supported by your implementation.  
Note: On some operating systems, these options may not be available. Use
[ispeed](socat.html#OPTION_ISPEED) or [ospeed](socat.html#OPTION_OSPEED)
instead.

****`echo[=<bool>]`****     Enables or disables local echo.

****`icanon[=<bool>]`****     Sets or clears canonical mode, enabling line
buffering and some special characters.

****`raw`****     Sets raw mode, thus passing input and output almost
unprocessed. This option is obsolete, use option
[rawer](socat.html#OPTION_TERMIOS_RAWER) or
[cfmakeraw](socat.html#OPTION_TERMIOS_CFMAKERAW) instead.

****`rawer`****     Makes terminal rawer than [raw](socat.html#OPTION_RAW)
option. This option implicitly turns off echo.
([example](socat.html#EXAMPLE_OPTION_TERMIOS_RAWER)).

****`cfmakeraw`****     Sets raw mode by invoking `cfmakeraw()` or by
simulating this call. This option implicitly turns off echo.

****`ignbrk[=<bool>]`****     Ignores or interprets the BREAK character (e.g.,
^C)

****`brkint[=<bool>]`****  

****`bs0`****  

****`bs1`****  

****`bsdly=<0|1>`****  

****`clocal[=<bool>]`****  

`**cr0**  
**cr1**  
**cr2**  
**cr3**`     Sets the carriage return delay to 0, 1, 2, or 3, respectively. 0
means no delay, the other values are terminal dependent.

****`crdly=<0|1|2|3>`****  

****`cread[=<bool>]`****  

****`crtscts[=<bool>]`****  

`**cs5**  
**cs6**  
**cs7**  
**cs8**`     Sets the character size to 5, 6, 7, or 8 bits, respectively.

****`csize=<0|1|2|3>`****  

****`cstopb[=<bool>]`****     Sets two stop bits, rather than one.

****`dsusp=<byte>`****     Sets the value for the VDSUSP character that
suspends the current foreground process and reactivates the shell (all except
Linux).

****`echoctl[=<bool>]`****     Echos control characters in hat notation (e.g.
^A)

****`echoe[=<bool>]`****  

****`echok[=<bool>]`****  

****`echoke[=<bool>]`****  

****`echonl[=<bool>]`****  

****`echoprt[=<bool>]`****  

****`eof=<byte>`****  

****`eol=<byte>`****  

****`eol2=<byte>`****  

****`erase=<byte>`****  

****`discard=<byte>`****  

****`ff0`****  

****`ff1`****  

****`ffdly[=<bool>]`****  

****`flusho[=<bool>]`****  

****`hupcl[=<bool>]`****  

****`icrnl[=<bool>]`****  

****`iexten[=<bool>]`****  

****`igncr[=<bool>]`****  

****`ignpar[=<bool>]`****  

****`imaxbel[=<bool>]`****  

****`inlcr[=<bool>]`****  

****`inpck[=<bool>]`****  

****`intr=<byte>`****  

****`isig[=<bool>]`****  

****`ispeed=<unsigned-int>`****     Set the baud rate for incoming data on
this line.  
See also: [ospeed](socat.html#OPTION_OSPEED),
[b19200](socat.html#OPTION_B19200)

****`istrip[=<bool>]`****  

****`iuclc[=<bool>]`****  

****`ixany[=<bool>]`****  

****`ixoff[=<bool>]`****  

****`ixon[=<bool>]`****  

****`kill=<byte>`****  

****`lnext=<byte>`****  

****`min=<byte>`****  

****`nl0`****     Sets the newline delay to 0.

****`nl1`****  

****`nldly[=<bool>]`****  

****`noflsh[=<bool>]`****  

****`ocrnl[=<bool>]`****  

****`ofdel[=<bool>]`****  

****`ofill[=<bool>]`****  

****`olcuc[=<bool>]`****  

****`onlcr[=<bool>]`****  

****`onlret[=<bool>]`****  

****`onocr[=<bool>]`****  

****`opost[=<bool>]`****     Enables or disables output processing; e.g.,
converts NL to CR-NL.

****`ospeed=<unsigned-int>`****     Set the baud rate for outgoing data on
this line.  
See also: [ispeed](socat.html#OPTION_ISPEED),
[b19200](socat.html#OPTION_B19200)

****`parenb[=<bool>]`****     Enable parity generation on output and parity
checking for input.

****`parmrk[=<bool>]`****  

****`parodd[=<bool>]`****  

****`pendin[=<bool>]`****  

****`quit=<byte>`****  

****`reprint=<byte>`****  

****`sane`****     Brings the terminal to something like a useful default
state.

****`start=<byte>`****  

****`stop=<byte>`****  

****`susp=<byte>`****  

****`swtc=<byte>`****  

****`tab0`****  

****`tab1`****  

****`tab2`****  

****`tab3`****  

****`tabdly=<unsigned-int>`****  

****`time=<byte>`****  

****`tostop[=<bool>]`****  

****`vt0`****  

****`vt1`****  

****`vtdly[=<bool>]`****  

****`werase=<byte>`****  

****`xcase[=<bool>]`****  

****`xtabs`****  

****`i-pop-all`****     With UNIX System V STREAMS, removes all drivers from
the stack.

****`i-push=<string>`****     With UNIX System V STREAMS, pushes the driver
(module) with the given name ([string](socat.html#TYPE_STRING)) onto the
stack. For example, to make sure that a character device on Solaris supports
termios etc, use the following options: `i-pop-
all,i-push=ptem,i-push=ldterm,i-push=ttcompat`

****`termios-setflags=<word>:<flags>, setflags=<word>:<flags>`****     Sets
one `c_*flag` word of `struct termios` to the given value. Word 0 is
`c_iflag`, word 3 is `c_lflag`.

  

_**PTY option group**_

These options are intended for use with the [pty](socat.html#ADDRESS_PTY)
address type.

****`link=<filename>`****     Generates a symbolic link that points to the
actual pseudo terminal (pty). This might help to solve the problem that ptys
are generated with more or less unpredictable names, making it difficult to
directly access the socat generated pty automatically. With this option, the
user can specify a "fix" point in the file hierarchy that helps him to access
the actual pty ([example](socat.html#EXAMPLE_OPTION_SYMBOLIC_LINK)). Beginning
with **socat** version 1.4.3, the symbolic link is removed when the address is
closed (but see option [unlink-close](socat.html#OPTION_UNLINK_CLOSE)).

****`wait-slave`****     Blocks the open phase until a process opens the slave
side of the pty. Usually, socat continues after generating the pty with
opening the next address or with entering the transfer loop. With the wait-
slave option, socat waits until some process opens the slave side of the pty
before continuing. This option only works if the operating system provides the
`poll()` system call. And it depends on an undocumented behaviour of pty's, so
it does not work on all operating systems. It has successfully been tested on
Linux, FreeBSD, NetBSD, and on Tru64 with openpty.

****`pty-interval=<seconds>`****     When the [wait-
slave](socat.html#OPTION_PTY_WAIT_SLAVE) option is set, socat periodically
checks the HUP condition using `poll()` to find if the pty's slave side has
been opened. The default polling interval is 1s. Use the pty-interval option
[[timeval](socat.html#TYPE_TIMEVAL)] to change this value.

****`sitout-eio=<timeval>`****     The login program in Linux closes its
tty/pty and reopens it for security reasons. During this time the pty master
would get EIO on I/O operations and might terminate. With this option
**socat** tolerates EIO for the specified time. Please note that in this state
**socat** blocks traffic in both directions, even when it is not related to
this channel.

****`tiocswinsz=<col>:<row>, tiocswinsz=<col>:<row>`****     Sets the size of
a pseudo terminal.  

  

_**OPENSSL option group**_

These options apply to the [openssl](socat.html#ADDRESS_OPENSSL_CONNECT) and
[openssl-listen](socat.html#ADDRESS_OPENSSL_LISTEN) address types.

****`cipher=<cipherlist>`****     Specifies the list of ciphers that may be
used for the connection. See the man page of `ciphers` , section **CIPHER LIST
FORMAT** , for detailed information about syntax, values, and default of
<cipherlist>.  
Several cipher strings may be given, separated by ':'. Some simple cipher
strings:

**3DES**     Uses a cipher suite with triple DES.

**MD5**     Uses a cipher suite with MD5.

**aNULL**     Uses a cipher suite without authentication.

**NULL**     Does not use encryption.

**HIGH**     Uses a cipher suite with "high" encryption.  Note that the peer
must support the selected property, or the negotiation will fail.

****`method=<ssl-method>`****     This option is based on deprecated functions
and is only available when **socat** was build with option `--with-openssl-
method`. Use option [min-proto-
version](socat.html#OPTION_OPENSSL_MIN_PROTO_VERSION) and maybe [max-proto-
version](socat.html#OPTION_OPENSSL_MAX_PROTO_VERSION) instead. Sets the
protocol version to be used. Valid strings (not case sensitive) are:

**`SSL2`**     Select SSL protocol version 2.

**`SSL3`**     Select SSL protocol version 3.

**`SSL23`**     Select the best available SSL or TLS protocol.

**`TLS1`**     Select TLS protocol version 1.

**`TLS1.1`**     Select TLS protocol version 1.1.

**`TLS1.2`**     Select TLS protocol version 1.2. When this option is not
provided OpenSSL negotiates the method with its peer.

****`openssl-min-proto-version=<string>`**, **`min-proto-version=<string>`****
This option tells OpenSSL to use this or a later SSL/TLS protocol version and
refuses to accept a lower/older protocol. Valid syntax is:

**`SSL2`**     Select SSL protocol version 2.

**`SSL3`**     Select SSL protocol version 3.

**`TLS1`**  

**`TLS1.0`**     Select TLS protocol version 1.

**`TLS1.1`**     Select TLS protocol version 1.1.

**`TLS1.2`**     Select TLS protocol version 1.2.

**`TLS1.3`**     Select TLS protocol version 1.3.

****`openssl-max-proto-version=<string>`**, **`max-proto-version=<string>`****
This option is similar to [min-proto-
version](socat.html#OPTION_OPENSSL_MIN_PROTO_VERSION), however, it disallows
use of a higher protocol version. Useful for testing the peer.

****`verify[=<bool>]`****     Controls check of the peer's certificate.
Default is 1 (true). Disabling verify might open your socket for everyone,
making the encryption useless!

****`cert=<filename>`****     Specifies the file with the certificate and
private key for authentication. The certificate must be in OpenSSL format
(*.pem). With openssl-listen, use of this option is strongly recommended.
Except with cipher aNULL, "no shared ciphers" error will occur when no
certificate is given.

****`key=<filename>`****     Specifies the file with the private key. The
private key may be in this file or in the file given with the
[cert](socat.html#OPTION_OPENSSL_CERTIFICATE) option. The party that has to
proof that it is the owner of a certificate needs the private key.

****`dhparams=<filename>`****     Specifies the file with the Diffie Hellman
parameters. These parameters may also be in the file given with the
[cert](socat.html#OPTION_OPENSSL_CERTIFICATE) option in which case the
dhparams option is not needed.

****`cafile=<filename>`****     Specifies the file with the trusted (root)
authority certificates. The file must be in PEM format and should contain one
or more certificates. The party that checks the authentication of its peer
trusts only certificates that are in this file.

****`capath=<dirname>`****     Specifies the directory with the trusted (root)
certificates. The directory must contain certificates in PEM format and their
hashes (see OpenSSL documentation)

****`egd=<filename>`****     On some systems, openssl requires an explicit
source of random data. Specify the socket name where an entropy gathering
daemon like egd provides random data, e.g. /dev/egd-pool.

****`openssl-maxfraglen=<int>, maxfraglen=<int>`****     For client
connections, make a Max Fragment Length Negotiation Request to the server to
limit the maximum size fragment the server will send to us. Supported lengths
are: 512, 1024, 2048, or 4096\. Note that this option is not applicable for
[OPENSSL-LISTEN](socat.html#ADDRESS_OPENSSL_LISTEN).

****`openssl-maxsendfrag=<int>, maxsendfrag=<int>`****     Limit the maximum
size of the fragment we will send to the other side. Supported length range:
512 - 16384. Note that under [OPENSSL-
LISTEN](socat.html#ADDRESS_OPENSSL_LISTEN), the maximum fragment size may be
further limited by the client's Maximum Fragment Length Negotiation Request,
if it makes one.

****`pseudo`****     On systems where openssl cannot find an entropy source
and where no entropy gathering daemon can be utilized, this option activates a
mechanism for providing pseudo entropy. This is achieved by taking the current
time in microseconds for feeding the libc pseudo random number generator with
an initial value. openssl is then fed with output from random() calls.  
NOTE:This mechanism is not sufficient for generation of secure keys!

****`compress`****     Enable or disable the use of compression for a
connection. Setting this to "none" disables compression, setting it to "auto"
lets OpenSSL choose the best available algorithm supported by both parties.
The default is to not touch any compression-related settings. NOTE: Requires
OpenSSL 0.9.8 or higher and disabling compression with OpenSSL 0.9.8 affects
all new connections in the process.

****`commonname=<string>`****     Specify the commonname that the peer
certificate must match. With [OPENSSL-
CONNECT](socat.html#ADDRESS_OPENSSL_CONNECT) address this overrides the given
hostname or IP target address; with [OPENSSL-
LISTEN](socat.html#ADDRESS_OPENSSL_LISTEN) this turns on check of peer
certificates commonname. This option has only meaning when option
[verify](socat.html#OPTION_OPENSSL_VERIFY) is not disabled and the chosen
cipher provides a peer certificate.

****`no-sni[=<bool>]`****     Do not use the client side Server Name
Indication (SNI) feature that selects the desired server certificate.  
Note: SNI is automatically used since **socat** version 1.7.4.0 and uses
[commonname](socat.html#OPTION_OPENSSL_COMMONNAME) or the given host name.

****`snihost=<string>`****     Set the client side Server Name Indication
(SNI) host name different from the addressed server name or common name. This
might be useful when the server certificate has multiple host names or
wildcard names because the SNI host name is passed in cleartext to the server
and might be eavesdropped; with this option a mock name of the desired
certificate may be transferred.

****`fips`****     Enables FIPS mode if compiled in. For info about the FIPS
encryption implementation standard see <http://oss-institute.org/fips-
faq.html>. This mode might require that the involved certificates are
generated with a FIPS enabled version of openssl. Setting or clearing this
option on one socat address affects all OpenSSL addresses of this process.

  

_**RETRY option group**_

Options that control retry of some system calls, especially connection
attempts.

****`retry=<num>`****     Number of retries before the connection or listen
attempt is aborted. Default is 0, which means just one attempt.

****`interval=<timespec>`****     Time between consecutive attempts (seconds,
[[timespec](socat.html#TYPE_TIMESPEC)]). Default is 1 second.

****`forever`****     Performs an unlimited number of retry attempts.

  

_**INTERFACE option group**_

These options may be applied to addresses
[INTERFACE](socat.html#ADDRESS_INTERFACE) and [TUN](socat.html#ADDRESS_TUN).
These address types and options are currently only implemented on Linux
operating system.

Note regarding VLANs: On incoming packets the Linux kernel strips off the VLAN
tag before passing the data to the user space program on raw sockets. Special
measures are required to get the VLAN information, see packet(7)
PACKET_AUXDATA, and to optionally insert the tag into the packet again, use
option [retrieve-vlan](socat.html#OPTION_RETRIEVE_VLAN) when you need this.

****`retrieve-vlan`****     On packets incoming on raw sockets, retrieve the
VLAN information and insert it into the packets for further processing (Linux)

****`iff-up`****     Sets the TUN network interface status UP. Strongly
recommended.

****`iff-broadcast`****     Sets the BROADCAST flag of the TUN network
interface.

****`iff-debug`****     Sets the DEBUG flag of the TUN network interface.

****`iff-loopback`****     Sets the LOOPBACK flag of the TUN network
interface.

****`iff-pointopoint`****     Sets the POINTOPOINT flag of the TUN device.

****`iff-notrailers`****     Sets the NOTRAILERS flag of the TUN device.

****`iff-running`****     Sets the RUNNING flag of the TUN device.

****`iff-noarp`****     Sets the NOARP flag of the TUN device.

****`iff-promisc`****     Sets the PROMISC flag of the TUN device.

****`iff-allmulti`****     Sets the ALLMULTI flag of the TUN device.

****`iff-master`****     Sets the MASTER flag of the TUN device.

****`iff-slave`****     Sets the SLAVE flag of the TUN device.

****`iff-multicast`****     Sets the MULTICAST flag of the TUN device.

****`iff-portsel`****     Sets the PORTSEL flag of the TUN device.

****`iff-automedia`****     Sets the AUTOMEDIA flag of the TUN device.

****`iff-dynamic`****     Sets the DYNAMIC flag of the TUN device.

****`interface-mtu=<num> (if-mtu=<num>)`****     Sets the interfaces MTU using
the netlink interface.

  

_**TUN option group**_

Options that control Linux TUN/TAP interface device addresses.

****`tun-device=<device-file>`****     Instructs socat to take another path
for the TUN clone device. Default is `/dev/net/tun`.

****`tun-name=<if-name>`****     Gives the resulting network interface a
specific name instead of the system generated (tun0, tun1, etc.)

****`tun-type=[tun|tap]`****     Sets the type of the TUN device; use this
option to generate a TAP device. See the Linux docu for the difference between
these types. When you try to establish a tunnel between two TUN devices, their
types should be the same.

****`iff-no-pi`****     Sets the IFF_NO_PI flag which controls if the device
includes additional packet information in the tunnel. When you try to
establish a tunnel between two TUN devices, these flags should have the same
values.

  

_**POSIX-MQ option group**_

Options that may be applied to POSIX-MQ addresses.

****`posixmq-priority=<link(TYPE_UNSIGNED_INT)(unsigned int)>` (mq-prio)****
) Sets the priority of messages (packets) written to the queue, or the minimal
priority of packet to be read from the queue.

****`posixmq-flush (mq-flush)`****     "Consumes" (drops) all messages
currently in the queue before starting transfers.

****`posixmq-maxmsg=<long> (mq-maxmsg)`****     Sets the maxmsg parameter of
the POSIX message queue when creating it.  
Note: This option applies only when the queue does not already exist.  
Note: The value is restricted by kernel setting `/proc/sys/fs/mqueue/msg_max`
with system default as low as 10.

****`posixmq-msgsize=<long> (mq-msgsize)`****     Sets the msgsize parameter
of the POSIX message queue when creating it.  
Note: This option applies only when the queue does not already exist.  
Note: The value is restricted by kernel setting
`/proc/sys/fs/mqueue/msgsize_max` .

## DATA VALUES

This section explains the different data types that address parameters and
address options can take.

**address-range**     Is currently only implemented for IPv4 and IPv6. See
address-option [`range'](socat.html#OPTION_RANGE)

**bool**     "0" or "1"; if value is omitted, "1" is taken.

**byte**     An unsigned int number, read with `strtoul()` , lower or equal to
`UCHAR_MAX` .

**command-line**     A string specifying a program name and its arguments,
separated by single spaces.

**data**     This is a more general data specification, "dalan" (low level
data description language). The given text string contains information about
the target data type and value. Generally a leading character specifies the
type of the following data item. In its specific context a default data type
may exist.  
Currently only the following specifications are implemented:  

**i**     A signed integer number, stored in host byte order.  
Example: **i-1000** (Integer number -1000)

**I**     An unsigned integer number, stored in host byte order.  

**l**     A signed long integer number, stored in host byte order.  

**L**     An unsigned long integer number, stored in host byte order.  

**s**     A signed short integer number, stored in host byte order.  

**S**     An unsigned short integer number, stored in host byte order.  

**b**     A signed byte (signed char).  

**B**     An unsigned byte (unsigned char).  

**x**     Following is an even number of hex digits, stored as sequence of
bytes, the data length is the resulting number of bytes.  
Example: **x7f000001** (IP address 127.0.0.1)

**"**     Following is a string that is used with the common conversions \n \r
\t \f \b \a \e \0; the string must be closed with '"'. Please note that the
quotes and backslashes need to be escaped from shell and **socat** conversion.
No implicit \0 is appended.  
Example: **"Hello world!\n"**

**'**     A single char, with the usual conversions. Please note that the
quotes and backslashes need to be escaped from shell and **socat** conversion.  
Example: **'a'** Data items may be separated with white space without need to
repeat the type specifier again.

**directory**     A string with usual UN*X directory name semantics.

**facility**     The name of a syslog facility in lower case characters.

**fdnum**     An unsigned int type, read with `strtoul()` , specifying a UN*X
file descriptor.

**filename**     A string with usual UN*X filename semantics.

**group**     If the first character is a decimal digit, the value is read
with `strtoul()` as unsigned integer specifying a group id. Otherwise, it must
be an existing group name.

**int**     A number following the rules of the `strtol()` function with base
"0", i.e. decimal number, octal number with leading "0", or hexadecimal number
with leading "0x". The value must fit into a C int.

**interface**     A string specifying the device name of a network interface
as shown by ifconfig or procan, e.g. "eth0".

**IP address**     An IPv4 address in numbers-and-dots notation, an IPv6
address in hex notation enclosed in brackets, or a hostname that resolves to
an IPv4 or an IPv6 address.  
Examples: 127.0.0.1, [::1], www.dest-unreach.org, dns1

**IPv4 address**     An IPv4 address in numbers-and-dots notation or a
hostname that resolves to an IPv4 address.  
Examples: 127.0.0.1, www.dest-unreach.org, dns2

**IPv6 address**     An IPv6 address in hexnumbers-and-colons notation
enclosed in brackets, or a hostname that resolves to an IPv6 address.  
Examples: [::1], [1234:5678:9abc:def0:1234:5678:9abc:def0], ip6name.domain.org

**long**     A number read with `strtol()` . The value must fit into a C long.

**long long**     A number read with `strtoll()` . The value must fit into a C
long long.

**off_t**     An implementation dependent signed number, usually 32 bits, read
with strtol or strtoll.

**off64_t**     An implementation dependent signed number, usually 64 bits,
read with strtol or strtoll.

**mode_t**     An unsigned integer, read with `strtoul()` , specifying mode
(permission) bits.

**pid_t**     A number, read with `strtol()` , specifying a process id.

**port**     A uint16_t (16 bit unsigned number) specifying a TCP or UDP port,
read with `strtoul()` .

**protocol**     An unsigned 8 bit number, read with `strtoul()` .

**size_t**     An unsigned number with size_t limitations, read with `strtoul`
.

**sockname**     A socket address. See address-option
[`bind'](socat.html#OPTION_BIND)

**string**     A sequence of characters, not containing '\0' and, depending on
the position within the command line, ':', ',', or "!!". Note that you might
have to escape shell meta characters in the command line.

**TCP service**     A service name, not starting with a digit, that is
resolved by `getservbyname()` , or an unsigned int 16 bit number read with
`strtoul()` .

**timeval**     A double float specifying seconds; the number is mapped into a
struct timeval, consisting of seconds and microseconds.

**timespec**     A double float specifying seconds; the number is mapped into
a struct timespec, consisting of seconds and nanoseconds.

**UDP service**     A service name, not starting with a digit, that is
resolved by `getservbyname()` , or an unsigned int 16 bit number read with
`strtoul()` .

**unsigned int**     A number read with `strtoul()` . The value must fit into
a C unsigned int.

**user**     If the first character is a decimal digit, the value is read with
`strtoul()` as unsigned integer specifying a user id. Otherwise, it must be an
existing user name.

**VSOCK cid**     A uint32_t (32 bit unsigned number) specifying a VSOCK
Context Identifier (CID), read with `strtoul()` . There are several special
addresses: VMADDR_CID_ANY (-1U) means any address for binding; VMADDR_CID_HOST
(2) is the well-known address of the host.

**VSOCK port**     A uint32_t (32 bit unsigned number) specifying a VSOCK
port, read with `strtoul()` .

## EXAMPLES

* * *

socat - TCP4:www.domain.org:80

transfers data between [STDIO](socat.html#ADDRESS_STDIO) (-) and a
[TCP4](socat.html#ADDRESS_TCP4_CONNECT) connection to port 80 of host
www.domain.org. This example results in an interactive connection similar to
telnet or netcat. The stdin terminal parameters are not changed, so you may
close the relay with ^D or abort it with ^C.

* * *

socat -d -d \ READLINE,history=$HOME/.http_history \
TCP4:www.domain.org:www,crnl

this is similar to the previous example, but you can edit the current line in
a bash like manner ([READLINE](socat.html#ADDRESS_READLINE)) and use the
[history](socat.html#OPTION_HISTORY) file .http_history; **socat** prints
messages about progress ([-d -d](socat.html#option_d_d)). The port is
specified by service name (www), and correct network line termination
characters ([crnl](socat.html#OPTION_CRNL)) instead of NL are used.

* * *

socat \ TCP4-LISTEN:www \ TCP4:www.domain.org:www

installs a simple TCP port forwarder. With
[TCP4-LISTEN](socat.html#ADDRESS_TCP4_LISTEN) it listens on local port "www"
until a connection comes in, accepts it, then connects to the remote host
([TCP4](socat.html#ADDRESS_TCP4_CONNECT)) and starts data transfer. It will
not accept a second connection.

* * *

socat -d -d -lmlocal2 \
TCP4-LISTEN:80,bind=myaddr1,su=nobody,fork,range=10.0.0.0/8,reuseaddr \
TCP4:www.domain.org:80,bind=myaddr2

TCP port forwarder, each side bound to another local IP address
([bind](socat.html#OPTION_BIND)). This example handles an almost arbitrary
number of parallel or consecutive connections by
[fork](socat.html#OPTION_FORK)'ing a new process after each `accept()` . It
provides a little security by [su](socat.html#OPTION_SUBSTUSER)'ing to user
nobody after forking; it only permits connections from the private 10 network
([range](socat.html#OPTION_RANGE)); due to
[reuseaddr](socat.html#OPTION_SO_REUSEADDR), it allows immediate restart after
master process's termination, even if some child sockets are not completely
shut down. With [-lmlocal2](socat.html#option_lm), socat logs to stderr until
successfully reaching the accept loop. Further logging is directed to syslog
with facility local2.

* * *

socat \ TCP4-LISTEN:5555,fork,tcpwrap=script \
EXEC:/bin/myscript,chroot=/home/sandbox,su-d=sandbox,pty,stderr

a simple server that accepts connections
([TCP4-LISTEN](socat.html#ADDRESS_TCP4_LISTEN)) and
[fork](socat.html#OPTION_FORK)'s a new child process for each connection;
every child acts as single relay. The client must match the rules for daemon
process name "script" in /etc/hosts.allow and /etc/hosts.deny, otherwise it is
refused access (see "man 5 hosts_access"). For
[EXEC](socat.html#ADDRESS_EXEC)'uting the program, the child process
[chroot](socat.html#OPTION_CHROOT)'s to **/home/sandbox** ,
[su](socat.html#OPTION_SUBSTUSER)'s to user sandbox, and then starts the
program **/home/sandbox/bin/myscript**. **Socat** and myscript communicate via
a pseudo tty ([pty](socat.html#OPTION_PTY)); myscript's
[stderr](socat.html#OPTION_STDERR) is redirected to stdout, so its error
messages are transferred via **socat** to the connected client.

* * *

socat \ EXEC:"mail.sh target@domain.com",fdin=3,fdout=4 \
TCP4:mail.relay.org:25,crnl,bind=alias1.server.org,mss=512

**mail.sh** is a shell script, distributed with **socat** , that implements a
simple SMTP client. It is programmed to "speak" SMTP on its FDs 3 (in) and 4
(out). The [fdin](socat.html#OPTION_FDIN) and [fdout](socat.html#OPTION_FDOUT)
options tell **socat** to use these FDs for communication with the program.
Because mail.sh inherits stdin and stdout while **socat** does not use them,
the script can read a mail body from stdin. **Socat** makes alias1 your local
source address ([bind](socat.html#OPTION_BIND)), cares for correct network
line termination ([crnl](socat.html#OPTION_CRNL)) and sends at most 512 data
bytes per packet ([mss](socat.html#OPTION_MSS)).

* * *

socat \ -,escape=0x0f \ /dev/ttyS0,rawer,crnl

opens an interactive connection via the serial line, e.g. for talking with a
modem. [rawer](socat.html#OPTION_TERMIOS_RAWER) sets the console's and ttyS0's
terminal parameters to practicable values, [crnl](socat.html#OPTION_CRNL)
converts to correct newline characters. [escape](socat.html#OPTION_ESCAPE)
allows terminating the socat process with character control-O. Consider using
[READLINE](socat.html#ADDRESS_READLINE) instead of the first address.

* * *

socat \ UNIX-LISTEN:/tmp/.X11-unix/X1,fork \
SOCKS4:host.victim.org:127.0.0.1:6000,socksuser=nobody,sourceport=20

with [UNIX-LISTEN](socat.html#ADDRESS_UNIX_LISTEN), **socat** opens a
listening UNIX domain socket **/tmp/.X11-unix/X1**. This path corresponds to
local XWindow display :1 on your machine, so XWindow client connections to
DISPLAY=:1 are accepted. **Socat** then speaks with the
[SOCKS4](socat.html#ADDRESS_SOCKS4) server host.victim.org that might permit
[sourceport](socat.html#OPTION_SOURCEPORT) 20 based connections due to an FTP
related weakness in its static IP filters. **Socat** pretends to be invoked by
[socksuser](socat.html#OPTION_SOCKSUSER) nobody, and requests to be connected
to loopback port 6000 (only weak sockd configurations will allow this). So we
get a connection to the victims XWindow server and, if it does not require MIT
cookies or Kerberos authentication, we can start work. Please note that there
can only be one connection at a time, because TCP can establish only one
session with a given set of addresses and ports.

* * *

socat -u \ /tmp/readdata,seek-end=0,ignoreeof \ STDIO

this is an example for unidirectional data transfer
([-u](socat.html#option_u)). **Socat** transfers data from file /tmp/readdata
(implicit address [GOPEN](socat.html#ADDRESS_GOPEN)), starting at its current
end ([seek-end](socat.html#OPTION_SEEK_END)=0 lets **socat** start reading at
current end of file; use [seek](socat.html#OPTION_SEEK)=0 or no seek option to
first read the existing data) in a "tail -f" like mode
([ignoreeof](socat.html#OPTION_IGNOREEOF)). The "file" might also be a
listening UNIX domain socket (do not use a seek option then).

* * *

(sleep 5; echo PASSWORD; sleep 5; echo ls; sleep 1) | socat - \ EXEC:'ssh -l user server',pty,setsid,ctty

[EXEC](socat.html#ADDRESS_EXEC)'utes an ssh session to server. Uses a
[pty](socat.html#OPTION_PTY) for communication between **socat** and ssh,
makes it ssh's controlling tty ([ctty](socat.html#OPTION_CTTY)), and makes
this pty the owner of a new process group
([setsid](socat.html#OPTION_SETSID)), so ssh accepts the password from
**socat**.

* * *

socat -u \ TCP4-LISTEN:3334,reuseaddr,fork \ OPEN:/tmp/in.log,creat,append

implements a simple network based message collector. For each client
connecting to port 3334, a new child process is generated (option
[fork](socat.html#OPTION_FORK)). All data sent by the clients are
[append](socat.html#OPTION_APPEND)'ed to the file /tmp/in.log. If the file
does not exist, socat [creat](socat.html#OPTION_O_CREAT)'s it. Option
[reuseaddr](socat.html#OPTION_SO_REUSEADDR) allows immediate restart of the
server process.

* * *

socat \ READLINE,noecho='[Pp]assword:' \ EXEC:'ftp
ftp.server.com',pty,setsid,ctty

wraps a command line history ([READLINE](socat.html#ADDRESS_READLINE)) around
the [EXEC](socat.html#ADDRESS_EXEC)'uted ftp client utility. This allows
editing and reuse of FTP commands for relatively comfortable browsing through
the ftp directory hierarchy. The password is echoed!
[pty](socat.html#OPTION_PTY) is required to have ftp issue a prompt.
Nevertheless, there may occur some confusion with the password and FTP
prompts.

* * *

socat \ PTY,link=$HOME/dev/vmodem0,rawer,wait-slave \ EXEC:'"ssh
modemserver.us.org socat - /dev/ttyS0,nonblock,rawer"'

generates a pseudo terminal device ([PTY](socat.html#ADDRESS_PTY)) on the
client that can be reached under the symbolic
[link](socat.html#OPTION_SYMBOLIC_LINK) **$HOME/dev/vmodem0**. An application
that expects a serial line or modem can be configured to use
**$HOME/dev/vmodem0** ; its traffic will be directed to a modemserver via ssh
where another socat instance links it to **/dev/ttyS0**.

* * *

sudo socat --experimental \ TCP4-LISTEN:8000,reuseaddr,fork,netns=namespace1 \
TCP4-CONNECT:server2:8000

creates a listener in the given network namespace that accepts TCP connections
on port 8000 and forwards them to server2.

* * *

sudo socat --experimental \ TUN:192.168.2.1/24,up \
TUN:192.168.2.2/24,up,netns=namespace2

creates two virtual network interfaces, one in default namespace, the other
one in namespace2, and forwards packets between them, acting as a virtual
network connection.

* * *

socat \ TCP4-LISTEN:2022,reuseaddr,fork \
PROXY:proxy.local:www.domain.org:22,proxyport=3128,proxyauth=username:s3cr3t

starts a forwarder that accepts connections on port 2022, and directs them
through the [proxy](socat.html#ADDRESS_PROXY_CONNECT) daemon listening on port
3128 ([proxyport](socat.html#OPTION_PROXYPORT)) on host proxy.local, using the
CONNECT method, where they are authenticated as "username" with "s3cr3t"
([proxyauth](socat.html#OPTION_PROXY_AUTHORIZATION)). proxy.local should
establish connections to host www.domain.org on port 22 then.

* * *

socat - \ SSL:server:4443,cafile=./server.crt,cert=./client.pem

is an OpenSSL client that tries to establish a secure connection to an SSL
server. Option [cafile](socat.html#OPTION_OPENSSL_CAFILE) specifies a file
that contains trust certificates: we trust the server only when it presents
one of these certificates and proofs that it owns the related private key.
Otherwise the connection is terminated. With
[cert](socat.html#OPTION_OPENSSL_CERTIFICATE) a file containing the client
certificate and the associated private key is specified. This is required in
case the server wishes a client authentication; many Internet servers do not.  
The first address ('-') can be replaced by almost any other socat address.

* * *

socat \ OPENSSL-
LISTEN:4443,reuseaddr,pf=ip4,fork,cert=./server.pem,cafile=./client.crt \ PIPE

is an OpenSSL server that accepts TCP connections, presents the certificate
from the file server.pem and forces the client to present a certificate that
is verified against cafile.crt.  
The second address ('PIPE') can be replaced by almost any other socat address.  
For instructions on generating and distributing OpenSSL keys and certificates
see the additional socat docu `socat-openssl.txt`.

* * *

echo | socat -u - \ FILE:/tmp/bigfile,create,largefile,seek=100000000000

creates a 100GB+1B sparse file; this requires a file system type that supports
this (ext2, ext3, ext4, reiserfs, xfs; not minix, vfat). The operation of
writing 1 byte might take long (reiserfs: some minutes; ext2: "no" time), and
the resulting file can consume some disk space with just its inodes (reiserfs:
2MB; ext2: 16KB).

* * *

socat \ TCP-L:7777,reuseaddr,fork \ SYSTEM:'filan -i 0 -s >&2',nofork

listens for incoming TCP connections on port 7777. For each accepted
connection, invokes a shell. This shell has its stdin and stdout directly
connected to the TCP socket ([nofork](socat.html#OPTION_NOFORK)). The shell
starts filan and lets it print the socket addresses to stderr (your terminal
window).

* * *

socat \ STDIO,cfmakeraw \ SHELL,pty,setsid,ctty,stderr

creates a shell in the current terminal that provides job control, history
etc.

* * *

echo -e "\0\14\0\0\c" | socat -u - \ FILE:/usr/bin/squid.exe,seek=0x00074420

functions as primitive binary editor: it writes the 4 bytes 000 014 000 000 to
the executable /usr/bin/squid.exe at offset 0x00074420 (this was a real world
patch to make the squid executable from Cygwin run under Windows, in 2004).

* * *

socat - \ TCP:www.blackhat.org:31337,readbytes=1000

connects to an unknown service and prevents being flooded.

* * *

socat -U \ TCP:target:9999,end-close \ TCP-L:8888,reuseaddr,fork

merges data arriving from different TCP streams on port 8888 to just one
stream to target:9999. The [end-close](socat.html#OPTION_END_CLOSE) option
prevents the child processes forked off by the second address from terminating
the shared connection to 9999 (close(2) just unlinks the inode which stays
active as long as the parent process lives; shutdown(2) would actively
terminate the connection).

* * *

socat \ TCP-LISTEN:10021,reuseaddr,socktype=6,protocol=33,fork \ PIPE

is a simple DCCP echo server. DCCP is now directly provisioned in **socat** ,
however this example shows how use **socat** s TCP procedures and change the
socket type to SOCK_DCCP=6 (on Linux) and the IP protocol to IPPROTO_DCCP=33.

* * *

socat - \ TCP:<server>:10021,reuseaddr,socktype=6,protocol=33,fork

is a simple DCCP client. DCCP is now directly provisioned in **socat** ,
however this example shows how use **socat** s TCP procedures, but changes the
socket type to SOCK_DCCP=6 (on Linux) and the IP protocol to IPPROTO_DCCP=33.

* * *

socat - \ UDP4-DATAGRAM:192.168.1.0:123,sp=123,broadcast,range=192.168.1.0/24

sends a broadcast to the network 192.168.1.0/24 and receives the replies of
the timeservers there. Ignores NTP packets from hosts outside this network.

* * *

socat - \ SOCKET-
DATAGRAM:2:2:17:x007bxc0a80100x0000000000000000,bind=x007bx00000000x0000000000000000,setsockopt-
int=1:6:1,range=x0000xc0a80100x0000000000000000:x0000xffffff00x0000000000000000

is semantically equivalent to the [previous
example](socat.html#EXAMPLE_ADDRESS_UDP4_BROADCAST_CLIENT), but all parameters
are specified in generic form. the value 6 of setsockopt-int is the Linux
value for `SO_BROADCAST`.

* * *

socat - \ IP4-DATAGRAM:255.255.255.255:44,broadcast,range=10.0.0.0/8

sends a broadcast to the local network(s) using protocol 44. Accepts replies
from the private address range only.

* * *

socat - \ UDP4-DATAGRAM:224.255.0.1:6666,bind=:6666,ip-add-
membership=224.255.0.1:eth0

transfers data from stdin to the specified multicast address using UDP. Both
local and remote ports are 6666. Tells the interface eth0 to also accept
multicast packets of the given group. Multiple hosts on the local network can
run this command, so all data sent by any of the hosts will be received by all
the other ones. Note that there are many possible reasons for failure,
including IP-filters, routing issues, wrong interface selection by the
operating system, bridges, or a badly configured switch.

* * *

socat \ UDP:host2:4443 \ TUN:192.168.255.1/24,up

establishes one side of a virtual (but not private!) network with host2 where
a similar process might run, with UDP-L and tun address 192.168.255.2. They
can reach each other using the addresses 192.168.255.1 and 192.168.255.2. Note
that streaming eg.via TCP or SSL does not guarantee to retain packet
boundaries and might thus cause packet loss.

* * *

socat - \ VSOCK-CONNECT:2:1234

establishes a VSOCK connection with the host (host is always reachable with
the well-know CID=2) on 1234 port.

* * *

socat - \ VSOCK-LISTEN:1234

listens for a VSOCK connection on 1234 port.

* * *

socat - \ VSOCK-CONNECT:31:4321,bind:5555

establishes a VSOCK connection with the guest that have CID=31 on 1234 port,
binding the local socket to the 5555 port.

* * *

socat \ VSOCK-LISTEN:3333,reuseaddr,fork \ VSOCK-CONNECT:42,3333

starts a forwarder that accepts VSOCK connections on port 3333, and directs
them to the guest with CID=42 on the same port.

* * *

socat \ VSOCK-LISTEN:22,reuseaddr,fork \ TCP:localhost:22

forwards VSOCK connections from 22 port to the local SSH server. Running this
in a VM allows you to connect via SSH from the host using VSOCK, as in the
example below.

* * *

socat \ TCP4-LISTEN:22222,reuseaddr,fork \ VSOCK-CONNECT:33:22

forwards TCP connections from 22222 port to the guest with CID=33 listening on
VSOCK port 22. Running this in the host, allows you to connect via SSH running
"ssh -p 22222 user@localhost", if the guest runs the example above.

* * *

socat \ PTY,link=/var/run/ppp,rawer \ INTERFACE:hdlc0

circumvents the problem that pppd requires a serial device and thus might not
be able to work on a synchronous line that is represented by a network device.
socat creates a PTY to make pppd happy, binds to the network
[interface](socat.html#ADDRESS_INTERFACE) `hdlc0`, and can transfer data
between both devices. Use pppd on device `/var/run/ppp` then.

* * *

socat -u \ STDIO \ POSIXMQ-SEND:/queue1,unlink-early,mq-prio=10

Writes packets read from stdio (i.e., lines of input when run interactively)
into POSIX message queue, with priority 10.

* * *

socat -u \ POSIXMQ-RECV:/queue1,fork,max-children=3 \ SYSTEM:"worker.sh"

Receives messages (packets) from POSIX message queue and, for each message,
forks a sub process that reads and processes the message. At most 3 sub
processes are allowed at the same time.

* * *

socat -T 1 -d -d \ TCP-L:10081,reuseaddr,fork,crlf \ SYSTEM:"echo -e
\"\\\\\"HTTP/1.0 200 OK\\\\\nDocumentType: text/plain\\\\\n\\\\\ndate:
\$\\(date\\)\\\\\nserver:\$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\\\nclient:
\$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\\\n\\\\\"\"; cat; echo -e
\"\\\\\"\\\\\n\\\\\"\""

creates a very primitive HTTP echo server: each HTTP client that connects gets
a valid HTTP reply that contains information about the client address and port
as it is seen by the server host, the host address (which might vary on
multihomed servers), and the original client request.

* * *

socat -d -d \ UDP4-RECVFROM:9999,so-broadcast,so-timestamp,ip-pktinfo,ip-recverr,ip-recvopts,ip-recvtos,ip-recvttl!!- \ SYSTEM:'export; sleep 1' | grep SOCAT

waits for an incoming UDP packet on port 9999 and prints the environment
variables provided by socat. On BSD based systems you have to replace [`ip-
pktinfo`](socat.html#OPTION_IP_PKTINFO) with [`ip-
recvdstaddr`](socat.html#OPTION_IP_RECVDSTADDR),[`ip-
recvif`](socat.html#OPTION_IP_RECVIF). Especially of interest is
SOCAT_IP_DSTADDR: it contains the target address of the packet which may be a
unicast, multicast, or broadcast address.

* * *

echo -e "M-SEARCH * HTTP/1.1\nHOST: 239.255.255.250:1900\nMAN: \"ssdp:discover\"\nMX: 4\nST: \"ssdp:all\"\n" | \ socat - \ UDP-DATAGRAM:239.255.255.250:1900,crlf

sends an SSDP (Simple Service Discovery Protocol) query to the local network
and collects and outputs the answers received.

* * *

systemd-socket-activate -l 1077 --inetd socat ACCEPT:0,fork PIPE

`systemd-socket-activate` is a program for testing `systemd` socket activation
of daemons. With `--inetd` it waits for a connection on the specified port. It
does not accept the connection but passes the listening file descriptor as FDs
0 and 1. **Socat** accepts the waiting connection and starts data transfer.

* * *

sudo socat -u TEXT:"1" /proc/sys/net/ipv4/ip_forward

Writes text into a `/proc/sys/` file using `sudo` using **socat** TEXT address
instead of piping it to a `tee` under `sudo`.

* * *

****``****  

## DIAGNOSTICS

**Socat** uses a logging mechanism that allows filtering messages by severity.
The severities provided are more or less compatible to the appropriate syslog
priority. With one or up to four occurrences of the -d command line option,
the lowest priority of messages that are issued can be selected. Each message
contains a single uppercase character specifying the messages severity (one of
F, E, W, N, I, or D)

**FATAL:**     Conditions that require unconditional and immediate program
termination.

**ERROR:**     Conditions that prevent proper program processing. Usually the
program is terminated (see [option -s](socat.html#option_s)).

**WARNING:**     Something did not function correctly or is in a state where
correct further processing cannot be guaranteed, but might be possible.

**NOTICE:**     Interesting actions of the program, e.g. for supervising
**socat** in some kind of server mode.

**INFO:**     Description of what the program does, and maybe why it happens.
Allows monitoring the lifecycles of file descriptors.

**DEBUG:**     Description of how the program works, all system or library
calls and their results.

Log messages can be written to stderr, to a file, or to syslog.

On exit, **socat** gives status 0 if it terminated due to EOF or inactivity
timeout, with a positive value on error, and with a negative value on fatal
error.

## FILES

/usr/bin/socat  
/usr/bin/filan  
/usr/bin/procan

## SIGNALS

**SIGUSR1:**     Causes logging of current transfer statistics.  
See also [option --statistics](socat.html#option_statistics)

## ENVIRONMENT VARIABLES

Input variables carry information from the environment to socat, output
variables are set by socat for use in executed scripts and programs.

In the output variables beginning with "SOCAT" this prefix is actually
replaced by the upper case name of the executable or the value of option
[-lp](socat.html#option_lp).

****SOCAT_DEFAULT_LISTEN_IP** (input)**     (Values 4 or 6) Sets the IP
version to be used for listen, recv, and recvfrom addresses if no
[pf](socat.html#OPTION_PROTOCOL_FAMILY) (protocol-family) option is given. Is
overridden by socat options [-4](socat.html#option_4) or
[-6](socat.html#option_6).

****SOCAT_PREFERRED_RESOLVE_IP** (input)**     (Values 0, 4, or 6) Sets the IP
version to be used when resolving target host names when version is not
specified by address type, option [pf](socat.html#OPTION_PROTOCOL_FAMILY)
(protocol-family), or address format. If name resolution does not return a
matching entry, the first result (with differing IP version) is taken. With
value 0, socat always selects the first record and its IP version.

****SOCAT_MAIN_WAIT** (input)**     Specifies the time (seconds) to sleep the
main process on begin of main\\(). Useful for debugging.

****SOCAT_TRANSFER_WAIT** (input)**     Specifies the time (seconds) to sleep
the process after opening addresses before entering the transfer loop. Useful
for debugging.

****SOCAT_FORK_WAIT** (input)**     Specifies the time (seconds) to sleep the
parent and child processes after successful fork(). Useful for debugging.

****SOCAT_VERSION** (output)**     Socat sets this variable to its version
string, e.g. `"1.7.0.0"` for released versions or e.g. `"1.6.0.1+envvar"` for
temporary versions; can be used in scripts invoked by socat.

****SOCAT_PID** (output)**     Socat sets this variable to its process id. In
case of [fork](socat.html#OPTION_FORK) address option, SOCAT_PID gets the
child processes id. Forking for [exec](socat.html#ADDRESS_EXEC),
[system](socat.html#ADDRESS_SYSTEM), and [SHELL](socat.html#ADDRESS_SHELL)
does not change SOCAT_PID.

****SOCAT_PPID** (output)**     Socat sets this variable to its process id. In
case of [fork](socat.html#OPTION_FORK), SOCAT_PPID keeps the pid of the master
process.

****SOCAT_PEERADDR** (output)**     With passive socket addresses (all LISTEN
and RECVFROM addresses), this variable is set to a string describing the peers
socket address. Port information is not included.

****SOCAT_PEERPORT** (output)**     With appropriate passive socket addresses
(TCP, UDP, and SCTP - LISTEN and RECVFROM), this variable is set to a string
containing the number of the peer port.

****SOCAT_SOCKADDR** (output)**     With all LISTEN addresses, this variable
is set to a string describing the local socket address. Port information is
not included [example](socat.html#EXAMPLE_HTTPECHO)

****SOCAT_SOCKPORT** (output)**     With [TCP-
LISTEN](socat.html#ADDRESS_TCP_LISTEN), [UDP-
LISTEN](socat.html#ADDRESS_UDP_LISTEN), and [SCTP-
LISTEN](socat.html#ADDRESS_SCTP_LISTEN) addresses, this variable is set to the
local port.

****SOCAT_TIMESTAMP** (output)**     With all RECVFROM addresses where address
option [so-timestamp](socat.html#OPTION_SO_TIMESTAMP) is applied, socat sets
this variable to the resulting timestamp.

****SOCAT_IP_OPTIONS** (output)**     With all IPv4 based RECVFROM addresses
where address option [ip-recvopts](socat.html#OPTION_IP_RECVOPTS) is applied,
socat fills this variable with the IP options of the received packet.

****SOCAT_IP_DSTADDR** (output)**     With all IPv4 based RECVFROM addresses
where address option [ip-recvdstaddr](socat.html#OPTION_IP_RECVDSTADDR) (BSD)
or [ip-pktinfo](socat.html#OPTION_IP_PKTINFO) (other platforms) is applied,
socat sets this variable to the destination address of the received packet.
This is particularly useful to identify broadcast and multicast addressed
packets.

****SOCAT_IP_IF** (output)**     With all IPv4 based RECVFROM addresses where
address option [ip-recvif](socat.html#OPTION_IP_RECVIF) (BSD) or [ip-
pktinfo](socat.html#OPTION_IP_PKTINFO) (other platforms) is applied, socat
sets this variable to the name of the interface where the packet was received.

****SOCAT_IP_LOCADDR** (output)**     With all IPv4 based RECVFROM addresses
where address option [ip-pktinfo](socat.html#OPTION_IP_PKTINFO) is applied,
socat sets this variable to the address of the interface where the packet was
received.

****SOCAT_IP_TOS** (output)**     With all IPv4 based RECVFROM addresses where
address option [ip-recvtos](socat.html#OPTION_IP_RECVTOS) is applied, socat
sets this variable to the TOS (type of service) of the received packet.

****SOCAT_IP_TTL** (output)**     With all IPv4 based RECVFROM addresses where
address option [ip-recvttl](socat.html#OPTION_IP_RECVTTL) is applied, socat
sets this variable to the TTL (time to live) of the received packet.

****SOCAT_IPV6_HOPLIMIT** (output)**     With all IPv6 based RECVFROM
addresses where address option
[ipv6-recvhoplimit](socat.html#OPTION_IPV6_RECVHOPLIMIT) is applied, socat
sets this variable to the hoplimit value of the received packet.

****SOCAT_IPV6_DSTADDR** (output)**     With all IPv6 based RECVFROM addresses
where address option [ipv6-recvpktinfo](socat.html#OPTION_IPV6_RECVPKTINFO) is
applied, socat sets this variable to the destination address of the received
packet.

****SOCAT_IPV6_TCLASS** (output)**     With all IPv6 based RECVFROM addresses
where address option [ipv6-recvtclass](socat.html#OPTION_IPV6_RECVTCLASS) is
applied, **socat** sets this variable to the transfer class of the received
packet.

****SOCAT_OPENSSL_X509_ISSUER** (output)**     Issuer field from peer
certificate

****SOCAT_OPENSSL_X509_SUBJECT** (output)**     Subject field from peer
certificate

****SOCAT_OPENSSL_X509_COMMONNAME** (output)**     commonName entries from
peer certificates subject. Multiple values are separated by " // ".

****SOCAT_OPENSSL_X509_*** (output)**     all other entries from peer
certificates subject

****SOCAT_OPENSSL_X509V3_DNS** (output)**     DNS entries from peer
certificates extensions - subjectAltName field. Multiple values are separated
by " // ".

****HOSTNAME** (input)**     Is used to determine the hostname for logging
(see [-lh](socat.html#option_lh)).

****LOGNAME** (input)**     Is used as name for the socks client user name if
no [socksuser](socat.html#OPTION_SOCKSUSER) is given.  
With options [su](socat.html#OPTION_SUBSTUSER) and
[su-d](socat.html#OPTION_SUBSTUSER_DELAYED), LOGNAME is set to the given user
name.

****USER** (input)**     Is used as name for the socks client user name if no
[socksuser](socat.html#OPTION_SOCKSUSER) is given and LOGNAME is empty.  
With options [su](socat.html#OPTION_SUBSTUSER) and
[su-d](socat.html#OPTION_SUBSTUSER_DELAYED), USER is set to the given user
name.

****SHELL** (output)**     With options [su](socat.html#OPTION_SUBSTUSER) and
[su-d](socat.html#OPTION_SUBSTUSER_DELAYED), SHELL is set to the login shell
of the given user.

****PATH** (output)**     Can be set with option
[path](socat.html#OPTION_PATH) for [exec](socat.html#ADDRESS_EXEC),
[system](socat.html#ADDRESS_SYSTEM), and [SHELL](socat.html#ADDRESS_SHELL)
addresses.

****HOME** (output)**     With options [su](socat.html#OPTION_SUBSTUSER) and
[su-d](socat.html#OPTION_SUBSTUSER_DELAYED), HOME is set to the home directory
of the given user.

## CREDITS

The work of the following groups and organizations was invaluable for this
project:

The _FSF_ (GNU, <http://www.fsf.org/>) project with their free and portable
development software and lots of other useful tools and libraries.

The _Linux developers community_ (<http://www.linux.org/>) for providing a
free, open source operating system.

The _Open Group_ (<http://www.unix-systems.org/>) for making their standard
specifications available on the Internet for free.

## VERSION

This man page describes version 1.8.1 of **socat**.

## BUGS

Addresses cannot be nested, so a single socat process cannot, e.g., drive ssl
over socks.

Address option ftruncate without value uses default 1 instead of 0.

Verbose modes (-x and/or -v) display line termination characters
inconsistently when address options cr or crnl are used: They show the data
_after_ conversion in either direction.

The data transfer blocksize setting (-b) is ignored with address readline.

Send bug reports to <socat@dest-unreach.org>

## SEE ALSO

nc(1), rinetd(8), openssl(1), stunnel(8), rlwrap(1), setsid(1)

**Socat** home page <http://www.dest-unreach.org/socat/>

## AUTHOR

Gerhard Rieger <rieger@dest-unreach.org> and contributors

