# nmap - Official Documentation

Source: https://nmap.org/book/man.html

Downloaded: 2025-12-26T20:05:34.565946

---

![](/shared/images/nst-icons.svg#menu) ![](/shared/images/nst-icons.svg#close)
[ ![Home page logo](/images/sitelogo.png)](/) [Nmap.org](https://nmap.org/)
[Npcap.com](https://npcap.com/) [Seclists.org](https://seclists.org/)
[Sectools.org](https://sectools.org) [Insecure.org](https://insecure.org/)
![](/shared/images/nst-icons.svg#search)

[Download](/download.html) [Reference Guide](/book/man.html) [Book](/book/)
[Docs](/docs.html) [Zenmap GUI](/zenmap/) [In the Movies](/movies/)

  * [Nmap Network Scanning](toc.html)
  * Chapter 15. Nmap Reference Guide

[Prev](data-files-replacing-data-files.html)

[Next](man-briefoptions.html)

# Chapter 15. Nmap Reference Guide

Table of Contents

  * [Description](man.html#man-description)
  * [Options Summary](man-briefoptions.html)
  * [Target Specification](man-target-specification.html)
  * [Host Discovery](man-host-discovery.html)
  * [Port Scanning Basics](man-port-scanning-basics.html)
  * [Port Scanning Techniques](man-port-scanning-techniques.html)
  * [Port Specification and Scan Order](man-port-specification.html)
  * [Service and Version Detection](man-version-detection.html)
  * [OS Detection](man-os-detection.html)
  * [Nmap Scripting Engine (NSE)](man-nse.html)
  * [Timing and Performance](man-performance.html)
  * [Firewall/IDS Evasion and Spoofing](man-bypass-firewalls-ids.html)
  * [Output](man-output.html)
  * [Miscellaneous Options](man-misc-options.html)
  * [Runtime Interaction](man-runtime-interaction.html)
  * [Examples](man-examples.html)
  * [Nmap Book](man-book.html)
  * [Bugs](man-bugs.html)
  * [Authors](man-author.html)
  * [Legal Notices](man-legal.html)
    * [Nmap Copyright and Licensing](man-legal.html#nmap-copyright)
    * [Creative Commons License for this Nmap Guide](man-legal.html#man-copyright)
    * [Source Code Availability and Community Contributions](man-legal.html#source-contrib)
    * [No Warranty](man-legal.html#no-warranty)
    * [Inappropriate Usage](man-legal.html#inappropriate-usage)
    * [Third-Party Software and Funding Notices](man-legal.html#third-party-soft)
    * [United States Export Control](man-legal.html#us-export)

## Name

nmap — Network exploration tool and security / port scanner

## Synopsis

`nmap` [ _`<Scan Type>`_ ...] [ _`<Options>`_ ] { _`<target specification>`_ }

## Description

![\[Note\]](images/note.png)| Note  
---|---  
This document describes the very latest version of Nmap available from
[`https://nmap.org/download.html`](https://nmap.org/download.html) or
[`https://nmap.org/dist/?C=M&O=D`](https://nmap.org/dist/?C=M&O=D). Please
ensure you are using the latest version before reporting that a feature
doesn't work as described.  
  
Nmap (“Network Mapper”) is an open source tool for network exploration and
security auditing. It was designed to rapidly scan large networks, although it
works fine against single hosts. Nmap uses raw IP packets in novel ways to
determine what hosts are available on the network, what services (application
name and version) those hosts are offering, what operating systems (and OS
versions) they are running, what type of packet filters/firewalls are in use,
and dozens of other characteristics. While Nmap is commonly used for security
audits, many systems and network administrators find it useful for routine
tasks such as network inventory, managing service upgrade schedules, and
monitoring host or service uptime.

The output from Nmap is a list of scanned targets, with supplemental
information on each depending on the options used. Key among that information
is the “interesting ports table”. That table lists the port number and
protocol, service name, and state. The state is either `open`, `filtered`,
`closed`, or `unfiltered`. `Open` means that an application on the target
machine is listening for connections/packets on that port. `Filtered` means
that a firewall, filter, or other network obstacle is blocking the port so
that Nmap cannot tell whether it is `open` or `closed`. `Closed` ports have no
application listening on them, though they could open up at any time. Ports
are classified as `unfiltered` when they are responsive to Nmap's probes, but
Nmap cannot determine whether they are open or closed. Nmap reports the state
combinations `open|filtered` and `closed|filtered` when it cannot determine
which of the two states describe a port. The port table may also include
software version details when version detection has been requested. When an IP
protocol scan is requested (`-sO`), Nmap provides information on supported IP
protocols rather than listening ports.

In addition to the interesting ports table, Nmap can provide further
information on targets, including reverse DNS names, operating system guesses,
device types, and MAC addresses.

A typical Nmap scan is shown in [Example 15.1](man.html#man-ex-repscan
"Example 15.1. A representative Nmap scan"). The only Nmap arguments used in
this example are `-A`, to enable OS and version detection, script scanning,
and traceroute; `-T4` for faster execution; and then the hostname.

Example 15.1. A representative Nmap scan

    
    
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
    

  

The newest version of Nmap can be obtained from
[`https://nmap.org`](https://nmap.org). The newest version of this man page is
available at
[`https://nmap.org/book/man.html`](https://nmap.org/book/man.html). It is also
included as a chapter of [_Nmap Network Scanning: The Official Nmap Project
Guide to Network Discovery and Security Scanning_](https://nmap.org/book/).

* * *

[Prev](data-files-replacing-data-files.html)Using Customized Data Files

[Up](toc.html)Nmap Network Scanning

[Home](toc.html)

[Next](man-briefoptions.html)Options Summary

![](/shared/images/nst-icons.svg#search)

## [Nmap Security Scanner](https://nmap.org/)

  * [Ref Guide](https://nmap.org/book/man.html)
  * [Install Guide](https://nmap.org/book/install.html)
  * [Docs](https://nmap.org/docs.html)
  * [Download](https://nmap.org/download.html)
  * [Nmap OEM](https://nmap.org/oem/) 

## [Npcap packet capture](https://npcap.com/)

  * [User's Guide](https://npcap.com/guide/)
  * [API docs](https://npcap.com/guide/npcap-devguide.html#npcap-api)
  * [Download](https://npcap.com/#download)
  * [Npcap OEM](https://npcap.com/oem/) 

## [Security Lists](https://seclists.org/)

  * [Nmap Announce](https://seclists.org/nmap-announce/)
  * [Nmap Dev](https://seclists.org/nmap-dev/)
  * [Full Disclosure](https://seclists.org/fulldisclosure/)
  * [Open Source Security](https://seclists.org/oss-sec/)
  * [BreachExchange](https://seclists.org/dataloss/) 

## [Security Tools](https://sectools.org)

  * [Vuln scanners](https://sectools.org/tag/vuln-scanners/)
  * [Password audit](https://sectools.org/tag/pass-audit/)
  * [Web scanners](https://sectools.org/tag/web-scanners/)
  * [Wireless](https://sectools.org/tag/wireless/)
  * [Exploitation](https://sectools.org/tag/sploits/) 

## [About](https://insecure.org/)

  * [About/Contact](https://insecure.org/fyodor/)
  * [Privacy](https://insecure.org/privacy.html)
  * [Advertising](https://insecure.org/advertising.html)
  * [Nmap Public Source License](https://nmap.org/npsl/) 

[ ![](/shared/images/nst-icons.svg#twitter) ](https://twitter.com/nmap "Visit
us on Twitter") [ ![](/shared/images/nst-icons.svg#facebook)
](https://facebook.com/nmap "Visit us on Facebook") [ ![](/shared/images/nst-
icons.svg#github) ](https://github.com/nmap/ "Visit us on Github") [
![](/shared/images/nst-icons.svg#reddit) ](https://reddit.com/r/nmap/ "Discuss
Nmap on Reddit")

