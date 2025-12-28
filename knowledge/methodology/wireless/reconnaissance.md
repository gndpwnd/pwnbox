---
title: Wireless Reconnaissance
category: methodology
tags:
  - wireless
  - reconnaissance
  - scanning
  - enumeration
  - kismet
  - airodump-ng
last_updated: 2025-12-28
---

# Wireless Reconnaissance

Comprehensive guide to wireless network discovery, enumeration, and signal mapping techniques for penetration testing.

## Table of Contents

- [Overview](#overview)
- [Passive vs Active Scanning](#passive-vs-active-scanning)
- [Interface Configuration](#interface-configuration)
- [Channel Hopping and Discovery](#channel-hopping-and-discovery)
- [Network Enumeration](#network-enumeration)
- [Hidden SSID Discovery](#hidden-ssid-discovery)
- [Client Enumeration](#client-enumeration)
- [Signal Strength Mapping](#signal-strength-mapping)
- [Kismet Usage](#kismet-usage)
- [Additional Tools](#additional-tools)

## Overview

Wireless reconnaissance is the first phase of wireless penetration testing, involving the discovery and enumeration of access points, clients, and network characteristics.

### Reconnaissance Objectives

| Objective | Description |
|-----------|-------------|
| Network Discovery | Identify all wireless networks in range |
| Client Enumeration | Map connected devices |
| Security Assessment | Determine encryption and authentication |
| Signal Mapping | Understand coverage areas |
| Vulnerability Identification | Find misconfigurations |

### Information Gathered

- ESSID (network name)
- BSSID (access point MAC)
- Channel and frequency
- Encryption type (WEP, WPA, WPA2, WPA3)
- Connected clients
- Signal strength and coverage

## Passive vs Active Scanning

### Passive Scanning

Monitor wireless traffic without transmitting:

| Advantage | Description |
|-----------|-------------|
| Stealthy | No transmissions to detect |
| Comprehensive | Captures all visible traffic |
| Legal | Listening is generally legal |

```bash
# Enable monitor mode
airmon-ng start wlan0

# Passive capture with airodump-ng
airodump-ng wlan0mon

# Passive capture with tcpdump
tcpdump -i wlan0mon -w wireless_capture.pcap
```

### Active Scanning

Send probe requests to discover networks:

| Advantage | Description |
|-----------|-------------|
| Faster discovery | Immediate responses |
| Hidden networks | May respond to directed probes |
| Detectable | Generates traffic |

```bash
# Active scan with iwlist
iwlist wlan0 scan

# Active scan with iw
iw dev wlan0 scan

# Active scan with nmcli
nmcli dev wifi list
```

### Comparison

| Aspect | Passive | Active |
|--------|---------|--------|
| Detection risk | Low | Higher |
| Speed | Slower | Faster |
| Hidden SSIDs | Requires client traffic | Direct probing |
| Traffic generated | None | Probe requests |

## Interface Configuration

### Basic Commands

```bash
# View wireless interfaces
iwconfig

# Detailed interface info
iw dev

# Check interface capabilities
iw list

# View interface status
ip link show wlan0
```

### iwconfig Usage

```bash
# Display wireless settings
iwconfig wlan0

# Set specific channel
iwconfig wlan0 channel 6

# Set ESSID for connection
iwconfig wlan0 essid "NetworkName"

# Set transmit power
iwconfig wlan0 txpower 20
```

### iw Command Reference

```bash
# List all wireless devices
iw dev

# Get interface info
iw dev wlan0 info

# Scan for networks
iw dev wlan0 scan

# Set interface down/up
ip link set wlan0 down
ip link set wlan0 up

# Set monitor mode
iw dev wlan0 set type monitor

# Set managed mode
iw dev wlan0 set type managed
```

## Channel Hopping and Discovery

### Understanding Channels

2.4GHz Band (802.11b/g/n):

| Region | Channels | Notes |
|--------|----------|-------|
| US/Canada | 1-11 | Most common |
| Europe | 1-13 | Extended range |
| Japan | 1-14 | Channel 14 rarely used |

5GHz Band (802.11a/n/ac/ax):

| Channel Range | Frequency | Notes |
|---------------|-----------|-------|
| 36-48 | 5.18-5.24 GHz | UNII-1, indoor |
| 52-64 | 5.26-5.32 GHz | UNII-2, DFS required |
| 100-144 | 5.5-5.72 GHz | UNII-2 Extended |
| 149-165 | 5.74-5.82 GHz | UNII-3, outdoor |

### Channel Hopping with airodump-ng

```bash
# Hop all channels (default)
airodump-ng wlan0mon

# Hop 2.4GHz only
airodump-ng --band bg wlan0mon

# Hop 5GHz only
airodump-ng --band a wlan0mon

# All bands
airodump-ng --band abg wlan0mon

# Fixed channel
airodump-ng -c 6 wlan0mon

# Multiple specific channels
airodump-ng -c 1,6,11 wlan0mon
```

### Manual Channel Control

```bash
# Set channel with iw
iw dev wlan0mon set channel 6

# Set channel with iwconfig
iwconfig wlan0mon channel 6

# Verify current channel
iwlist wlan0mon channel | grep Current
```

## Network Enumeration

### Using airodump-ng

```bash
# Basic scan with output
airodump-ng -w scan_output wlan0mon

# Output formats
airodump-ng -w scan --output-format csv,pcap,kismet wlan0mon

# Filter by encryption
airodump-ng --encrypt WPA2 wlan0mon
airodump-ng --encrypt OPN wlan0mon
```

### Reading airodump-ng Output

Upper section (Access Points):

```
BSSID              PWR  Beacons  #Data  #/s  CH   MB   ENC   CIPHER  AUTH  ESSID
AA:BB:CC:DD:EE:FF  -45  1234     567    12   6    54e  WPA2  CCMP    PSK   Network1
11:22:33:44:55:66  -67  456      23     1    11   54e  WPA2  CCMP    MGT   Enterprise
```

Lower section (Clients):

```
BSSID              STATION            PWR   Rate   Lost   Frames  Notes  Probes
AA:BB:CC:DD:EE:FF  12:34:56:78:9A:BC  -35   54e-1e 0      1234           Network1, OtherNet
(not associated)   AB:CD:EF:12:34:56  -78   0 - 1  0      56             HomeWiFi
```

### Export and Analysis

```bash
# Parse CSV output
cat scan_output-01.csv | cut -d',' -f1,14 | head -20

# Convert to other formats
airodump-ng-oui-update  # Update OUI database

# Analyze with grep
grep "WPA2" scan_output-01.csv
```

## Hidden SSID Discovery

### Detection Methods

Hidden networks broadcast beacons but with empty ESSID field:

```bash
# airodump-ng shows hidden networks as <length: X>
airodump-ng wlan0mon
# Output: <length: 10> indicates 10-character SSID
```

### Revealing Hidden SSIDs

Method 1: Wait for client probe requests

```bash
# Monitor for probe requests
airodump-ng -c <channel> --bssid <BSSID> wlan0mon
# SSID appears when client probes or connects
```

Method 2: Deauthenticate client to force reconnection

```bash
# Force client reconnection
aireplay-ng -0 5 -a <BSSID> -c <CLIENT> wlan0mon

# Watch airodump-ng for SSID reveal
```

Method 3: Active probing with mdk4

```bash
# Brute force SSID
mdk4 wlan0mon p -t <BSSID> -f ssid_wordlist.txt
```

### Creating SSID Wordlists

```bash
# Common SSIDs
echo -e "linksys\nnetgear\ndlink\nATT\nXfinity" > ssids.txt

# Generate variations
crunch 1 8 -o ssid_brute.txt
```

## Client Enumeration

### Identifying Connected Clients

```bash
# View associated clients with airodump-ng
airodump-ng -c <channel> --bssid <BSSID> wlan0mon

# Lower section shows:
# STATION (client MAC)
# PWR (client signal strength)
# Frames (activity level)
# Probes (networks client seeks)
```

### Analyzing Probe Requests

Probe requests reveal:

- Networks the client has connected to previously
- Potential attack targets (evil twin)
- Device identification

```bash
# Capture probe requests
tshark -i wlan0mon -Y "wlan.fc.type_subtype == 4" -T fields -e wlan.sa -e wlan_mgt.ssid

# Filter unique probes
tshark -i wlan0mon -Y "wlan.fc.type_subtype == 4" -T fields -e wlan.sa -e wlan_mgt.ssid | sort -u
```

### MAC Address Analysis

```bash
# Lookup vendor from MAC
# First 3 octets identify manufacturer
macchanger -l | grep "AA:BB:CC"

# Online lookup
# https://macvendors.com/
```

## Signal Strength Mapping

### Understanding Signal Metrics

| Metric | Description | Good Value |
|--------|-------------|------------|
| PWR (dBm) | Signal strength | -30 to -67 |
| Noise (dBm) | Background noise | Below -90 |
| SNR | Signal-to-noise ratio | Above 25 |

### Signal Strength Interpretation

| dBm Range | Quality | Description |
|-----------|---------|-------------|
| -30 to -50 | Excellent | Very close to AP |
| -50 to -67 | Good | Reliable connection |
| -67 to -70 | Fair | Usable |
| -70 to -80 | Weak | Intermittent issues |
| Below -80 | Poor | Unreliable |

### Using wavemon

```bash
# Install wavemon
apt install wavemon

# Run wavemon for real-time monitoring
wavemon

# Features:
# - Real-time signal graph
# - Noise level
# - Link quality
# - AP information
```

### Site Survey Tools

```bash
# Using iwlist for signal scanning
watch -n 1 "iwlist wlan0 scan | grep -E 'ESSID|Signal'"

# Continuous signal monitoring
while true; do
    iw dev wlan0 link | grep signal
    sleep 1
done
```

## Kismet Usage

### Installation and Setup

```bash
# Install Kismet
apt install kismet

# Add user to kismet group
usermod -aG kismet $USER

# Configure data sources in /etc/kismet/kismet.conf
source=wlan0:name=monitor
```

### Running Kismet

```bash
# Start Kismet server
kismet

# Access web interface
# http://localhost:2501

# Headless operation
kismet -c wlan0 --no-ncurses -t logprefix
```

### Kismet Features

| Feature | Description |
|---------|-------------|
| Multi-source | Monitor multiple interfaces |
| GPS integration | Location-tagged captures |
| Device tracking | Track devices over time |
| Alerts | Detect anomalies |
| API | Integrate with other tools |

### Kismet Output Files

```bash
# Log files created
kismetdb         # SQLite database
pcapng           # Packet capture

# Query database
kismetdb_to_pcap --in capture.kismet --out capture.pcap
```

## Additional Tools

### iwlist Commands

```bash
# Scan for networks
iwlist wlan0 scan

# View channel info
iwlist wlan0 channel

# View frequency info
iwlist wlan0 frequency

# View access point info
iwlist wlan0 ap
```

### NetworkManager CLI

```bash
# List WiFi networks
nmcli dev wifi list

# Rescan
nmcli dev wifi rescan

# Show detailed info
nmcli -f ALL dev wifi list
```

### wifite for Automated Recon

```bash
# Run wifite in recon mode
wifite --kill

# List targets without attacking
# Press Ctrl+C after discovery
```

### LinSSID (GUI)

```bash
# Install LinSSID
apt install linssid

# Run graphical scanner
linssid
```

---

*Wireless reconnaissance should only be performed on networks you own or have authorization to test.*
