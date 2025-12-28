---
title: Wireless Penetration Testing Overview
category: methodology
tags:
  - wireless
  - wifi
  - pentesting
  - 802.11
  - wpa
  - wep
last_updated: 2025-12-28
---

# Wireless Penetration Testing Overview

Comprehensive guide to wireless network security assessment, covering protocols, tools, and attack methodologies.

## Table of Contents

- [Introduction](#introduction)
- [Wireless Security Standards](#wireless-security-standards)
- [Hardware Requirements](#hardware-requirements)
- [Legal Considerations](#legal-considerations)
- [Common Tools Overview](#common-tools-overview)
- [Technique Documentation](#technique-documentation)
- [Quick Reference](#quick-reference)

## Introduction

Wireless penetration testing evaluates the security of 802.11 wireless networks. This involves assessing encryption protocols, authentication mechanisms, and client/AP configurations to identify vulnerabilities that could allow unauthorized access or data interception.

### Scope of Wireless Assessments

| Assessment Type | Description |
|----------------|-------------|
| Infrastructure Testing | Evaluate APs, controllers, and network segmentation |
| Client Testing | Assess wireless client security and configurations |
| Protocol Analysis | Examine encryption and authentication implementations |
| Physical Security | Test signal leakage and rogue AP detection |

## Wireless Security Standards

### WEP (Wired Equivalent Privacy)

- **Status**: Deprecated and insecure
- **Encryption**: RC4 stream cipher with 24-bit IV
- **Vulnerabilities**: IV collision attacks, statistical analysis
- **Cracking Time**: Minutes with sufficient traffic

### WPA (Wi-Fi Protected Access)

- **Encryption**: TKIP (Temporal Key Integrity Protocol)
- **Authentication**: PSK or 802.1X/EAP
- **Vulnerabilities**: TKIP weaknesses, offline dictionary attacks
- **Status**: Legacy, should be upgraded

### WPA2 (802.11i)

- **Encryption**: AES-CCMP (mandatory), TKIP (optional)
- **Authentication**: PSK or 802.1X/EAP
- **Vulnerabilities**: KRACK attack, offline handshake cracking
- **Status**: Current standard, widely deployed

### WPA3 (802.11w)

- **Encryption**: AES-GCMP-256
- **Key Exchange**: SAE (Simultaneous Authentication of Equals)
- **Features**: Forward secrecy, protected management frames
- **Vulnerabilities**: Dragonblood attacks (patched in most implementations)
- **Status**: Latest standard, adoption growing

## Hardware Requirements

### Wireless Adapters

Essential features for penetration testing:

| Feature | Requirement |
|---------|-------------|
| Monitor Mode | Required for passive capture |
| Packet Injection | Required for active attacks |
| Chipset | Atheros, Ralink, or Realtek recommended |
| Frequency Bands | 2.4GHz minimum, 5GHz preferred |

### Recommended Adapters

| Adapter | Chipset | Bands | Notes |
|---------|---------|-------|-------|
| Alfa AWUS036ACH | RTL8812AU | 2.4/5GHz | Excellent range |
| Alfa AWUS036NHA | AR9271 | 2.4GHz | Great compatibility |
| TP-Link TL-WN722N v1 | AR9271 | 2.4GHz | Budget option |
| Panda PAU09 | RT5572 | 2.4/5GHz | Dual-band support |

### Enabling Monitor Mode

```bash
# Check interface capabilities
iw list | grep -A 10 "Supported interface modes"

# Identify wireless interfaces
iwconfig

# Enable monitor mode with airmon-ng
airmon-ng check kill
airmon-ng start wlan0

# Manual monitor mode
ip link set wlan0 down
iw dev wlan0 set type monitor
ip link set wlan0 up
```

## Legal Considerations

**Wireless penetration testing requires explicit authorization.**

### Requirements Before Testing

1. **Written Authorization**: Obtain signed permission from network owner
2. **Scope Definition**: Clearly define target networks (BSSID, ESSID)
3. **Time Constraints**: Agree on testing windows
4. **Boundaries**: Define physical and logical boundaries
5. **Third-Party Networks**: Ensure no interference with neighboring networks

### Legal Framework

| Jurisdiction | Relevant Laws |
|--------------|---------------|
| United States | CFAA, Wiretap Act, state laws |
| European Union | GDPR, national cybercrime laws |
| United Kingdom | Computer Misuse Act |

> **Warning**: Unauthorized wireless network access is a criminal offense in most jurisdictions.

## Common Tools Overview

### Aircrack-ng Suite

Primary toolset for wireless security testing:

| Tool | Purpose |
|------|---------|
| `airmon-ng` | Manage monitor mode |
| `airodump-ng` | Capture and analyze packets |
| `aireplay-ng` | Packet injection and attacks |
| `aircrack-ng` | Crack WEP/WPA keys |
| `airbase-ng` | Create fake access points |

### Additional Tools

| Tool | Purpose |
|------|---------|
| `Kismet` | Wireless network detector and sniffer |
| `Wireshark` | Packet analysis |
| `Hashcat` | GPU-accelerated cracking |
| `hostapd` | Access point daemon |
| `wifite` | Automated wireless auditing |
| `Bettercap` | Network attacks and monitoring |

## Technique Documentation

| Document | Description |
|----------|-------------|
| [WPA Cracking](wpa-cracking.md) | WPA/WPA2/WPA3 attack techniques |
| [Evil Twin Attacks](evil-twin.md) | Rogue AP and credential harvesting |
| [Reconnaissance](reconnaissance.md) | Network discovery and enumeration |

## Quick Reference

### Common Commands

```bash
# Start monitor mode
airmon-ng start wlan0

# Scan for networks
airodump-ng wlan0mon

# Target specific network
airodump-ng -c <channel> --bssid <BSSID> -w capture wlan0mon

# Deauthentication attack
aireplay-ng -0 10 -a <BSSID> -c <CLIENT> wlan0mon

# Crack captured handshake
aircrack-ng -w wordlist.txt capture-01.cap
```

### Interface Naming

| Original | Monitor Mode |
|----------|--------------|
| wlan0 | wlan0mon |
| wlan1 | wlan1mon |

---

*See individual technique files for detailed attack procedures.*
