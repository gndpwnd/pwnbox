---
title: "nmap"
category: "tool"
tags: ["tool-documentation"]
sources:
  - type: manpage
    url: "https://man.archlinux.org/man/nmap.1.en"
  - type: readme
    url: "https://github.com/nmap/nmap"
last_updated: "2025-12-26"
---

# nmap

## Man Page

# **nmap -A -T4 scanme.nmap.org**
Nmap scan report for scanme.nmap.org (74.207.244.221)
Host is up (0.029s latency).
rDNS record for 74.207.244.221: li86-221.members.linode.com
Not shown: 995 closed ports
PORT     STATE    SERVICE     VERSION
22/tcp   open     ssh         OpenSSH 5.3p1 Debian 3ubuntu7 (protocol 2.0)
| ssh-hostkey: 1024 8d:60:f1:7c:ca:b7:3d:0a:d6:67:54:9d:69:d9:b9:dd (DSA)
|_2048 79:f8:09:ac:d4:e2:32:42:10:49:d3:bd:20:82:85:ec (RSA)
80/tcp   open     http        Apache httpd 2.2.14 ((Ubuntu))
|_http-title: Go ahead and ScanMe!
646/tcp  filtered ldp
1720/tcp filtered H.323/Q.931
9929/tcp open     nping-echo  Nping echo
Device type: general purpose
Running: Linux 2.6.X
OS CPE: cpe:/o:linux:linux_kernel:2.6.39
OS details: Linux 2.6.39
Network Distance: 11 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:kernel
TRACEROUTE (using port 53/tcp)
HOP RTT      ADDRESS
[Cut first 10 hops for brevity]
11  17.65 ms li86-221.members.linode.com (74.207.244.221)
Nmap done: 1 IP address (1 host up) scanned in 14.40 seconds

## README

Nmap [![Build Status](https://travis-ci.org/nmap/nmap.svg?branch=master)](https://travis-ci.org/nmap/nmap) [![Language grade: C/C++](https://img.shields.io/lgtm/grade/cpp/g/nmap/nmap.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/nmap/nmap/context:cpp) [![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/nmap/nmap.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/nmap/nmap/context:python) [![Total alerts](https://img.shields.io/lgtm/alerts/g/nmap/nmap.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/nmap/nmap/alerts/)
====

Nmap is released under a custom license, which is based on (but not compatible
with) GPLv2. The Nmap license allows free usage by end users, and we also offer
a commercial license for companies that wish to redistribute Nmap technology
with their products. See [Nmap Copyright and Licensing](https://nmap.org/book/man-legal.html)
for full details.

The latest version of this software as well as binary installers for Windows,
macOS, and Linux (RPM) are available from
[Nmap.org](https://nmap.org/download.html)

Full documentation is also available
[on the Nmap.org website](https://nmap.org/docs.html).

Questions and suggestions may be sent to
[the Nmap-dev mailing list](https://nmap.org/mailman/listinfo/dev).

Installing
----------
Ideally, you should be able to just type:

    ./configure
    make
    make install

For far more in-depth compilation, installation, and removal notes, read the
[Nmap Install Guide](https://nmap.org/book/install.html) on Nmap.org.

Using Nmap
----------
Nmap has a lot of features, but getting started is as easy as running `nmap
scanme.nmap.org`. Running `nmap` without any parameters will give a helpful
list of the most common options, which are discussed in depth in [the man
page](https://nmap.org/book/man.html). Users who prefer a graphical interface
can use the included [Zenmap front-end](https://nmap.org/zenmap/).

Contributing
------------
Information about filing bug reports and contributing to the Nmap project can
be found in the [HACKING](HACKING) and [CONTRIBUTING.md](CONTRIBUTING.md)
files.


