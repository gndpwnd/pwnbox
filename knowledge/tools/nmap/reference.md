# nmap - Reference Documentation

Source: https://nmap.org/book/nse.html

Downloaded: 2025-12-26T20:05:36.073523

---

![](/shared/images/nst-icons.svg#menu) ![](/shared/images/nst-icons.svg#close)
[ ![Home page logo](/images/sitelogo.png)](/) [Nmap.org](https://nmap.org/)
[Npcap.com](https://npcap.com/) [Seclists.org](https://seclists.org/)
[Sectools.org](https://sectools.org) [Insecure.org](https://insecure.org/)
![](/shared/images/nst-icons.svg#search)

[Download](/download.html) [Reference Guide](/book/man.html) [Book](/book/)
[Docs](/docs.html) [Zenmap GUI](/zenmap/) [In the Movies](/movies/)

  * [Nmap Network Scanning](toc.html)
  * Chapter 9. Nmap Scripting Engine

[Prev](osdetect-find-rogue-ap.html)

[Next](nse-usage.html)

# Chapter 9. Nmap Scripting Engine

Table of Contents

  * [Introduction](nse.html#nse-intro)
  * [Usage and Examples](nse-usage.html)
    * [Script Categories](nse-usage.html#nse-categories)
    * [Script Types and Phases](nse-usage.html#nse-script-types)
    * [Command-line Arguments](nse-usage.html#nse-cmd-line-args)
    * [Script Selection](nse-usage.html#nse-script-selection)
    * [Arguments to Scripts](nse-usage.html#nse-args)
    * [Complete Examples](nse-usage.html#nse-usage-examples)
  * [Script Format](nse-script-format.html)
    * [`description` Field](nse-script-format.html#nse-format-description)
    * [`categories` Field](nse-script-format.html#nse-format-categories)
    * [`author` Field ](nse-script-format.html#nse-format-author)
    * [`license` Field ](nse-script-format.html#nse-format-license)
    * [`dependencies` Field](nse-script-format.html#nse-format-dependencies)
    * [Rules](nse-script-format.html#nse-format-rules)
    * [Action](nse-script-format.html#nse-format-action)
    * [Environment Variables](nse-script-format.html#nse-format-environment)
  * [Script Language](nse-language.html)
    * [Lua Base Language](nse-language.html#nse-lua)
  * [NSE Scripts](nse-scripts.html)
  * [NSE Libraries](nse-library.html)
    * [List of All Libraries](nse-library.html#nse-library-list)
    * [Hacking NSE Libraries](nse-library.html#hacking-nse-libraries)
    * [Adding C Modules to Nselib](nse-library.html#nse-library-c-modules)
  * [Nmap API](nse-api.html)
    * [Information Passed to a Script](nse-api.html#nse-api-arguments)
    * [Network I/O API](nse-api.html#nse-api-networkio)
      * [Connect-style network I/O](nse-api.html#nse-api-networkio-connect)
      * [Raw packet network I/O](nse-api.html#nse-api-networkio-raw)
    * [Structured and Unstructured Output](nse-api.html#nse-structured-output)
      * [](nse-api.html#nse-structured-output-conventions)
    * [Exception Handling](nse-api.html#nse-exceptions)
    * [The Registry](nse-api.html#nse-api-registry)
  * [Script Writing Tutorial](nse-tutorial.html)
    * [The Head](nse-tutorial.html#nse-tutorial-head)
    * [The Rule](nse-tutorial.html#nse-tutorial-rule)
    * [The Action](nse-tutorial.html#nse-tutorial-action)
  * [Writing Script Documentation (NSEDoc)](nsedoc.html)
    * [NSE Documentation Tags](nsedoc.html#nsedoc-tags)
  * [Script Parallelism in NSE](nse-parallelism.html)
    * [Worker Threads](nse-parallelism.html#nse-parallelism-threads)
    * [Mutexes](nse-parallelism.html#nse-parallelism-mutex)
    * [Condition Variables](nse-parallelism.html#nse-parallelism-condvar)
    * [Collaborative Multithreading](nse-parallelism.html#nse-parallelism-cm)
      * [The base thread](nse-parallelism.html#nse-parallelism-base)
  * [Version Detection Using NSE](nse-vscan.html)
  * [Example Script: `finger`](nse-example-scripts.html)
  * [Implementation Details](nse-implementation.html)
    * [Initialization Phase](nse-implementation.html#nse-implementation-init)
    * [Script Scanning](nse-implementation.html#nse-implementation-scan)

## Introduction

The Nmap Scripting Engine (NSE) is one of Nmap's most powerful and flexible
features. It allows users to write (and share) simple scripts to automate a
wide variety of networking tasks. Those scripts are then executed in parallel
with the speed and efficiency you expect from Nmap. Users can rely on the
growing and diverse set of scripts distributed with Nmap, or write their own
to meet custom needs.

We designed NSE to be versatile, with the following tasks in mind:

Network discovery

    

This is Nmap's bread and butter. Examples include looking up whois data based
on the target domain, querying ARIN, RIPE, or APNIC for the target IP to
determine ownership, performing identd lookups on open ports, SNMP queries,
and listing available NFS/SMB/RPC shares and services.

More sophisticated version detection

    

The Nmap version detection system ([Chapter 7, _Service and Application
Version Detection_](vscan.html "Chapter 7. Service and Application Version
Detection")) is able to recognize thousands of different services through its
probe and regular expression signature based matching system, but it cannot
recognize everything. For example, identifying the Skype v2 service requires
two independent probes, which version detection isn't flexible enough to
handle. Nmap could also recognize more SNMP services if it tried a few hundred
different community names by brute force. Neither of these tasks are well
suited to traditional Nmap version detection, but both are easily accomplished
with NSE. For these reasons, version detection now calls NSE by default to
handle some tricky services. This is described in [the section called “Version
Detection Using NSE”](nse-vscan.html "Version Detection Using NSE").

Vulnerability detection

    

When a new vulnerability is discovered, you often want to scan your networks
quickly to identify vulnerable systems before the bad guys do. While Nmap
isn't a comprehensive [vulnerability scanner](https://sectools.org/vuln-
scanners.html), NSE is powerful enough to handle even demanding vulnerability
checks. When the Heartbleed bug affected hundreds of thousands of systems
worldwide, Nmap's developers responded with the `ssl-heartbleed` detection
script within 2 days. Many vulnerability detection scripts are already
available and we plan to distribute more as they are written.

Backdoor detection

    

Many attackers and some automated worms leave backdoors to enable later
reentry. Some of these can be detected by Nmap's regular expression based
version detection, but more complex worms and backdoors require NSE's advanced
capabilities to reliably detect. NSE has been used to detect the Double Pulsar
NSA backdoor in SMB and backdoored versions of UnrealIRCd, vsftpd, and
ProFTPd.

Vulnerability exploitation

    

As a general scripting language, NSE can even be used to exploit
vulnerabilities rather than just find them. The capability to add custom
exploit scripts may be valuable for some people (particularly penetration
testers), though we aren't planning to turn Nmap into an exploitation
framework such as [Metasploit](http://www.metasploit.com).

These listed items were our initial goals, and we expect Nmap users to come up
with even more inventive uses for NSE.

Scripts are written in the embedded [Lua programming
language](https://lua.org/), version 5.4. The language itself is well
documented in the books _[Programming in Lua, Fourth
Edition](http://www.amazon.com/dp/8590379868?tag=secbks-20)_ and _[Lua 5.2
Reference Manual](http://www.amazon.com/dp/9888381229?tag=secbks-20)_. The
reference manual, updated for Lua 5.4, is also [freely available
online](https://lua.org/manual/5.4/), as is the [first edition of _Programming
in Lua_](https://lua.org/pil/). Given the availability of these excellent
general Lua programming references, this document only covers aspects and
extensions specific to Nmap's scripting engine.

NSE is activated with the `-sC` option (or `--script` if you wish to specify a
custom set of scripts) and results are integrated into Nmap normal and XML
output.

A typical script scan is shown in the [Example 9.1](nse.html#nse-ex1
"Example 9.1. Typical NSE output"). Service scripts producing output in this
example are `ssh-hostkey`, which provides the system's RSA and DSA SSH keys,
and `rpcinfo`, which queries portmapper to enumerate available services. The
only host script producing output in this example is `smb-os-discovery`, which
collects a variety of information from SMB servers. Nmap discovered all of
this information in a third of a second.

Example 9.1. Typical NSE output

    
    
    # **nmap -sC -p22,111,139 -T4 localhost**
    
    Starting Nmap ( https://nmap.org )
    Nmap scan report for flog (127.0.0.1)
    PORT     STATE SERVICE
    22/tcp   open  ssh
    | ssh-hostkey: 1024 b1:36:0d:3f:50:dc:13:96:b2:6e:34:39:0d:9b:1a:38 (DSA)
    |_2048 77:d0:20:1c:44:1f:87:a0:30:aa:85:cf:e8:ca:4c:11 (RSA)
    111/tcp  open  rpcbind
    | rpcinfo:  
    | 100000  2,3,4    111/udp  rpcbind  
    | 100024  1      56454/udp  status   
    |_100000  2,3,4    111/tcp  rpcbind  
    139/tcp  open  netbios-ssn
    
    Host script results:
    | smb-os-discovery: Unix
    | LAN Manager: Samba 3.0.31-0.fc8
    |_Name: WORKGROUP
    
    Nmap done: 1 IP address (1 host up) scanned in 0.33 seconds
    

  

A 38-minute video introduction to NSE is available at
[`https://nmap.org/presentations/BHDC10/`](https://nmap.org/presentations/BHDC10/).
This presentation was given by Fyodor and David Fifield at Defcon and the
Black Hat Briefings in 2010.

* * *

[Prev](osdetect-find-rogue-ap.html)SOLUTION: Detect Rogue Wireless Access
Points on an Enterprise Network

[Up](toc.html)Nmap Network Scanning

[Home](toc.html)

[Next](nse-usage.html)Usage and Examples

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

