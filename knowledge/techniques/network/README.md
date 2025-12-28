---
title: Network Attack Techniques
category: techniques
tags: [network, mitm, relay]
last_updated: 2025-12-27
---

# Network Attack Techniques

This directory contains documentation for network-level attack techniques used in penetration testing and red team operations.

## Overview

Network attacks target the communication layer to intercept, modify, or redirect traffic. These techniques are fundamental to internal penetration testing and often serve as stepping stones to credential theft and lateral movement.

## Categories

### Man-in-the-Middle (MITM) Attacks

MITM attacks position the attacker between two communicating parties.

**Common Techniques:**
- ARP spoofing/poisoning
- DHCP spoofing
- DNS spoofing
- ICMP redirect
- IPv6 SLAAC attacks (mitm6)
- BGP hijacking (large scale)

**ARP Spoofing Example:**
```bash
# Using arpspoof
arpspoof -i eth0 -t TARGET_IP GATEWAY_IP
arpspoof -i eth0 -t GATEWAY_IP TARGET_IP

# Using bettercap
bettercap -iface eth0
> net.probe on
> set arp.spoof.targets TARGET_IP
> arp.spoof on
```

**Defense Evasion:** Use intermittent poisoning, limit target scope, avoid detection thresholds.

### Relay Attacks

Relay attacks forward authentication attempts to target systems.

**NTLM Relay**
- Capture NTLM auth and relay to other services
- Effective against systems without SMB signing
- Can achieve code execution or AD object manipulation

```bash
# Start Responder (capture mode)
responder -I eth0 -w -d

# Relay captured auth
ntlmrelayx.py -tf targets.txt -smb2support -i
ntlmrelayx.py -tf targets.txt --delegate-access  # RBCD attack
```

**IPv6 DNS Takeover (mitm6)**
```bash
# Become IPv6 DNS server
mitm6 -d domain.local

# Relay to LDAP/HTTP
ntlmrelayx.py -6 -t ldaps://DC_IP -wh fake.domain.local -l loot
```

### Network Poisoning

Poisoning attacks manipulate network service responses to redirect traffic.

**LLMNR/NBT-NS Poisoning**
- Respond to local name resolution broadcasts
- Capture NTLMv2 hashes for cracking
- Very effective on Windows networks

```bash
responder -I eth0 -wrf
```

**mDNS Poisoning**
- Target Apple/Linux multicast DNS
- Capture credentials from mistyped hostnames

**WPAD Poisoning**
- Serve malicious proxy configuration
- Intercept HTTP traffic
- Capture proxy authentication

### Network Sniffing

Passive interception of network traffic.

**Techniques:**
- Promiscuous mode capture
- Switch MAC flooding (CAM overflow)
- SPAN/mirror port access
- Wireless sniffing

**Tools and Usage:**
```bash
# Capture traffic
tcpdump -i eth0 -w capture.pcap

# Filter specific protocols
tcpdump -i eth0 port 21 or port 23 or port 80

# Extract credentials with net-creds
net-creds -i eth0

# Analyze with Wireshark
wireshark capture.pcap
```

**Credential Extraction:**
- HTTP Basic auth
- FTP credentials
- Telnet sessions
- SNMP community strings
- Unencrypted email (POP3/IMAP)

## Attack Workflow

1. **Network Discovery** - Map hosts, services, and topology
2. **Position** - Establish MITM through poisoning/spoofing
3. **Intercept** - Capture traffic and credentials
4. **Relay/Crack** - Use credentials for access
5. **Clean Up** - Restore network state, remove artifacts

## Related Tools

| Tool | Purpose |
|------|---------|
| Responder | LLMNR/NBT-NS/WPAD poisoning |
| mitm6 | IPv6 DNS takeover |
| Bettercap | MITM framework |
| ntlmrelayx | NTLM relay attacks |
| Wireshark | Packet analysis |
| tcpdump | Command-line capture |

## Detection Considerations

- ARP cache anomalies
- Duplicate MAC addresses
- Unusual DHCP/DNS responses
- SMB signing enforcement
- Network segmentation

## References

- [Responder Documentation](https://github.com/lgandx/Responder)
- [Bettercap Documentation](https://www.bettercap.org/)
- [The Hacker Recipes - MITM](https://www.thehacker.recipes/)
- [HackTricks - Network Attacks](https://book.hacktricks.xyz/)
