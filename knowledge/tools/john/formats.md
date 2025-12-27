# John the Ripper - Hash Formats Guide

## Table of Contents

- [Overview](#overview)
- [Identifying Hash Types](#identifying-hash-types)
- [Common Hash Formats](#common-hash-formats)
- [Using john2hash Tools](#using-john2hash-tools)
- [Format-Specific Options](#format-specific-options)
- [Practical Examples](#practical-examples)

## Overview

John the Ripper (jumbo version) supports 400+ hash formats. This guide covers identification, extraction, and cracking of the most common hash types encountered in CTFs and penetration testing.

## Identifying Hash Types

### Automatic Detection

John attempts to auto-detect hash formats when possible:

```bash
# Let John detect the format
john hashes.txt

# Show detected format without cracking
john --list=unknown hashes.txt
```

### Manual Identification

When auto-detection fails, identify hashes manually:

| Hash Pattern | Likely Format | John Format |
|--------------|---------------|-------------|
| `$1$salt$hash` | MD5-crypt (Linux) | `md5crypt` |
| `$2a$`, `$2b$`, `$2y$` | bcrypt | `bcrypt` |
| `$5$salt$hash` | SHA-256-crypt | `sha256crypt` |
| `$6$salt$hash` | SHA-512-crypt | `sha512crypt` |
| `$apr1$salt$hash` | Apache MD5 | `md5crypt-apache` |
| `$P$` or `$H$` | phpass (WordPress/phpBB) | `phpass` |
| `$y$` | yescrypt | `yescrypt` |
| 32 hex chars | MD5, NTLM, LM | `Raw-MD5`, `NT`, `LM` |
| 40 hex chars | SHA-1 | `Raw-SHA1` |
| 64 hex chars | SHA-256 | `Raw-SHA256` |
| 128 hex chars | SHA-512 | `Raw-SHA512` |

### Hash Length Quick Reference

```
16 bytes (32 hex)  -> MD5, NTLM, LM, MySQL323
20 bytes (40 hex)  -> SHA-1, MySQL4.1+
28 bytes (56 hex)  -> SHA-224
32 bytes (64 hex)  -> SHA-256
48 bytes (96 hex)  -> SHA-384
64 bytes (128 hex) -> SHA-512
```

### Listing Available Formats

```bash
# List all supported formats
john --list=formats

# Search for specific format
john --list=formats | grep -i sha

# Count total formats
john --list=formats | wc -w

# List format details
john --list=format-details
```

## Common Hash Formats

### Unix/Linux Hashes

#### Shadow File Format ($6$, $5$, $1$)

```bash
# Format: username:$id$salt$hash:...
# $1$ = MD5, $5$ = SHA-256, $6$ = SHA-512

# Extract from /etc/shadow
sudo unshadow /etc/passwd /etc/shadow > unshadowed.txt
john unshadowed.txt

# Specify format explicitly
john --format=sha512crypt hashes.txt
john --format=sha256crypt hashes.txt
john --format=md5crypt hashes.txt
```

#### DES-crypt (Legacy)

```bash
# 13 character hash (2 char salt + 11 char hash)
# Example: ab1234567890.
john --format=descrypt hashes.txt
```

### Windows Hashes

#### NTLM (NT Hash)

```bash
# 32 hex characters, case-insensitive
# Example: 32ed87bdb5fdc5e9cba88547376818d4

john --format=NT hashes.txt
```

#### LM Hash (Legacy)

```bash
# 32 hex characters, split into two 16-char halves
# Passwords > 7 chars split into two parts

john --format=LM hashes.txt
```

#### NTLM from SAM/NTDS

```bash
# Format: username:RID:LM:NT:::
# Use secretsdump output directly
john --format=NT sam_dump.txt
```

### Web Application Hashes

#### Raw MD5

```bash
# 32 hex characters
# Example: 5f4dcc3b5aa765d61d8327deb882cf99

john --format=Raw-MD5 hashes.txt
```

#### MD5 with Salt

```bash
# Various formats exist
john --format=md5($pass.$salt) hashes.txt
john --format=md5($salt.$pass) hashes.txt

# Dynamic formats for custom salting
john --format=dynamic_0 hashes.txt   # md5($p)
john --format=dynamic_1 hashes.txt   # md5($p.$s)
john --format=dynamic_2 hashes.txt   # md5(md5($p))
```

#### SHA-1, SHA-256, SHA-512

```bash
john --format=Raw-SHA1 hashes.txt
john --format=Raw-SHA256 hashes.txt
john --format=Raw-SHA512 hashes.txt
```

#### bcrypt

```bash
# Format: $2a$cost$salt+hash (60 chars total)
# Example: $2a$10$N9qo8uLOickgx2ZMRZoMye...

john --format=bcrypt hashes.txt
# Note: bcrypt is intentionally slow
```

#### WordPress/phpBB (phpass)

```bash
# Format: $P$Bsalt+hash or $H$...
john --format=phpass hashes.txt
```

### Database Hashes

#### MySQL

```bash
# MySQL 3.x/4.x (16 hex chars)
john --format=mysql hashes.txt

# MySQL 5.x+ (40 hex chars with * prefix)
# Example: *2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19
john --format=mysql-sha1 hashes.txt
```

#### PostgreSQL

```bash
# MD5 format: md5 + 32 hex chars
john --format=postgres hashes.txt
```

#### MSSQL

```bash
john --format=mssql hashes.txt
john --format=mssql05 hashes.txt
john --format=mssql12 hashes.txt
```

#### Oracle

```bash
john --format=oracle hashes.txt
john --format=oracle11 hashes.txt
john --format=oracle12c hashes.txt
```

### Network Protocol Hashes

#### Kerberos

```bash
# AS-REP Roasting (Kerberos 5 etype 23)
john --format=krb5asrep hashes.txt

# Kerberoasting (TGS)
john --format=krb5tgs hashes.txt

# Kerberos 5 Pre-Auth
john --format=krb5pa-sha1 hashes.txt
john --format=krb5pa-md5 hashes.txt
```

#### NTLM Challenge/Response

```bash
# NetNTLMv1
john --format=netntlm hashes.txt

# NetNTLMv2
john --format=netntlmv2 hashes.txt
```

## Using john2hash Tools

The jumbo version includes numerous `*2john` utilities to extract hashes from various file formats.

### Locating Tools

```bash
# Find all *2john scripts
locate '*2john*'

# Or in John's run directory
ls /usr/share/john/*2john*
ls /opt/john/run/*2john*

# Common locations
# - /usr/bin/
# - /usr/share/john/
# - /opt/john/run/
```

### SSH Private Keys (ssh2john)

Extract password hash from encrypted SSH private keys:

```bash
# Extract hash from SSH private key
ssh2john id_rsa > ssh_hash.txt

# Alternative Python version
python /usr/share/john/ssh2john.py id_rsa > ssh_hash.txt

# Crack the passphrase
john --wordlist=/usr/share/wordlists/rockyou.txt ssh_hash.txt

# Show cracked passphrase
john --show ssh_hash.txt
```

**Supported key types:**
- RSA (traditional, OpenSSH)
- DSA
- ECDSA
- Ed25519

### ZIP Archives (zip2john)

```bash
# Extract hash from password-protected ZIP
zip2john protected.zip > zip_hash.txt

# For ZipCrypto (legacy)
john --format=PKZIP zip_hash.txt

# For WinZip AES
john --format=ZIP zip_hash.txt

# Crack with wordlist
john --wordlist=/usr/share/wordlists/rockyou.txt zip_hash.txt
```

### RAR Archives (rar2john)

```bash
# Extract hash from RAR file
rar2john protected.rar > rar_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt rar_hash.txt
```

### 7-Zip Archives (7z2john)

```bash
# Extract hash
7z2john protected.7z > 7z_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt 7z_hash.txt
```

### PDF Documents (pdf2john)

```bash
# Extract hash from password-protected PDF
pdf2john protected.pdf > pdf_hash.txt

# Different PDF encryption versions
john --format=PDF pdf_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt pdf_hash.txt
```

### Microsoft Office (office2john)

```bash
# Extract from Office documents (.docx, .xlsx, .pptx)
python /usr/share/john/office2john.py protected.docx > office_hash.txt

# Legacy Office formats
python /usr/share/john/office2john.py protected.doc > office_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt office_hash.txt
```

### Keepass Databases (keepass2john)

```bash
# Extract from .kdbx (KeePass 2.x)
keepass2john database.kdbx > keepass_hash.txt

# With keyfile
keepass2john -k keyfile.key database.kdbx > keepass_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt keepass_hash.txt
```

### GPG/PGP Keys (gpg2john)

```bash
# Extract from GPG private key
gpg2john private.gpg > gpg_hash.txt
gpg2john private.asc > gpg_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt gpg_hash.txt
```

### BitLocker Volumes (bitlocker2john)

```bash
# Extract from BitLocker encrypted drive
bitlocker2john -i /dev/sda1 > bitlocker_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt bitlocker_hash.txt
```

### LUKS Volumes (luks2john)

```bash
# Extract from LUKS encrypted partition
luks2john /dev/sda1 > luks_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt luks_hash.txt
```

### Ansible Vault (ansible2john)

```bash
# Extract from Ansible vault file
ansible2john vault.yml > ansible_hash.txt

# Crack
john --wordlist=/usr/share/wordlists/rockyou.txt ansible_hash.txt
```

### Additional 2john Tools

| Tool | Purpose |
|------|---------|
| `dmg2john` | macOS disk images |
| `vncpcap2john` | VNC pcap files |
| `wpapcap2john` | WPA/WPA2 handshakes |
| `hccap2john` | Hashcat capture files |
| `pfx2john` | PKCS#12/PFX certificates |
| `putty2john` | PuTTY private keys |
| `truecrypt2john` | TrueCrypt volumes |
| `veracrypt2john` | VeraCrypt volumes |
| `krb2john` | Kerberos keytab files |
| `racf2john` | RACF password database |
| `pwsafe2john` | Password Safe databases |
| `mozilla2john` | Firefox/Thunderbird key3.db |
| `keychain2john` | macOS Keychain |
| `kwallet2john` | KDE Wallet |
| `encfs2john` | EncFS encrypted directories |
| `ecryptfs2john` | eCryptfs encrypted dirs |
| `aem2john` | AEM password hashes |
| `adxcsouf2john` | SAP CODVN hashes |
| `aix2john` | AIX password hashes |
| `androidfde2john` | Android FDE |
| `apex2john` | Oracle APEX hashes |
| `axcrypt2john` | AxCrypt files |
| `bestcrypt2john` | BestCrypt volumes |
| `bks2john` | BouncyCastle keystore |
| `ccache2john` | Kerberos ccache |
| `dashlane2john` | Dashlane exports |
| `diskcryptor2john` | DiskCryptor volumes |
| `electrum2john` | Electrum wallets |
| `enpass2john` | Enpass databases |
| `ethereum2john` | Ethereum wallets |
| `filezilla2john` | FileZilla creds |
| `fvde2john` | macOS FileVault 2 |
| `geli2john` | FreeBSD GELI |
| `hccapx2john` | WPA/WPA2 hccapx |
| `htdigest2john` | Apache htdigest |
| `ikescan2john` | IKE PSK hashes |
| `itunes2john` | iTunes backup |
| `kdcdump2john` | Kerberos KDC dump |
| `keyring2john` | GNOME Keyring |
| `keystore2john` | Java keystore |
| `kirbi2john` | Kerberos kirbi |
| `known_hosts2john` | SSH known_hosts |
| `lastpass2john` | LastPass exports |
| `libreoffice2john` | LibreOffice docs |
| `lotus2john` | Lotus Notes hashes |
| `mcafee_epo2john` | McAfee ePO |
| `monero2john` | Monero wallets |
| `money2john` | MS Money files |
| `multibit2john` | MultiBit wallets |
| `neo2john` | Neo wallets |
| `pcap2john` | Network captures |
| `pem2john` | PEM certificates |
| `pgpdisk2john` | PGP disk images |
| `pgpwde2john` | PGP WDE |
| `prosody2john` | Prosody XMPP |
| `pse2john` | SAP PSE files |
| `radius2john` | RADIUS hashes |
| `signal2john` | Signal backups |
| `sip2john` | SIP digests |
| `sipdump2john` | SIP pcap |
| `ssh2john` | SSH private keys |
| `sspr2john` | NetIQ SSPR |
| `staroffice2john` | StarOffice docs |
| `strip2john` | Strip password mgr |
| `telegram2john` | Telegram exports |
| `tezos2john` | Tezos wallets |
| `vmx2john` | VMware VMX |
| `zed2john` | Zed! encrypted files |

## Format-Specific Options

### Specifying Format

```bash
# Explicit format
john --format=Raw-SHA256 hashes.txt

# Case variations (both work)
john --format=raw-sha256 hashes.txt
john --format=RAW-SHA256 hashes.txt
```

### OpenCL/GPU Acceleration

```bash
# List OpenCL formats
john --list=formats --format=opencl

# Use OpenCL version
john --format=sha512crypt-opencl hashes.txt
john --format=NT-opencl hashes.txt

# Specify device
john --format=NT-opencl --devices=1 hashes.txt
```

### Format Categories

```bash
# Dynamic formats (for custom hash schemes)
john --list=subformats
john --format=dynamic_0 hashes.txt  # md5($p)

# List all dynamic formats
john --list=subformats | grep dynamic
```

### Hash Input Format

Different formats expect different input:

```bash
# Raw hash only
echo "5f4dcc3b5aa765d61d8327deb882cf99" > hash.txt
john --format=Raw-MD5 hash.txt

# With username
echo "admin:5f4dcc3b5aa765d61d8327deb882cf99" > hash.txt
john --format=Raw-MD5 hash.txt

# With salt (format-dependent)
echo '$dynamic_1$hash$salt' > hash.txt
john --format=dynamic_1 hash.txt
```

## Practical Examples

### CTF Scenario: Linux Shadow File

```bash
# 1. Get shadow file (from dump or privilege escalation)
cat shadow.txt
# root:$6$rounds=5000$salt$longhashhere:18000:0:99999:7:::

# 2. If you have both passwd and shadow
unshadow passwd.txt shadow.txt > combined.txt

# 3. Crack with wordlist
john --wordlist=/usr/share/wordlists/rockyou.txt combined.txt

# 4. Check progress
john --show combined.txt

# 5. For stubborn hashes, add rules
john --wordlist=/usr/share/wordlists/rockyou.txt --rules=Jumbo combined.txt
```

### CTF Scenario: SSH Key Passphrase

```bash
# 1. Found encrypted SSH key
cat id_rsa | head -2
# -----BEGIN OPENSSH PRIVATE KEY-----
# (encrypted)

# 2. Extract hash
ssh2john id_rsa > ssh_hash.txt

# 3. Crack passphrase
john --wordlist=/usr/share/wordlists/rockyou.txt ssh_hash.txt

# 4. Show result
john --show ssh_hash.txt
# id_rsa:secretpassphrase
```

### CTF Scenario: Password-Protected ZIP

```bash
# 1. Extract hash
zip2john flag.zip > zip_hash.txt

# 2. Check hash format
cat zip_hash.txt
# flag.zip/flag.txt:$pkzip2$...

# 3. Crack
john --wordlist=/usr/share/wordlists/rockyou.txt zip_hash.txt

# 4. Get password
john --show zip_hash.txt

# 5. Extract with recovered password
unzip flag.zip
# Enter password: [use cracked password]
```

### Pentest Scenario: Windows Hashes from SAM

```bash
# 1. Dump from SAM (using secretsdump, mimikatz, etc.)
cat ntlm_hashes.txt
# Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
# User:1001:aad3b435b51404eeaad3b435b51404ee:8846f7eaee8fb117ad06bdd830b7586c:::

# 2. Crack NTLM hashes
john --format=NT --wordlist=/usr/share/wordlists/rockyou.txt ntlm_hashes.txt

# 3. Show cracked
john --format=NT --show ntlm_hashes.txt
```

### Pentest Scenario: Kerberoasting

```bash
# 1. Hashes from GetUserSPNs.py or Rubeus
cat tgs_hashes.txt
# $krb5tgs$23$*svc_sql*DOMAIN.LOCAL*...

# 2. Crack
john --format=krb5tgs --wordlist=/usr/share/wordlists/rockyou.txt tgs_hashes.txt

# 3. For AS-REP roasting
john --format=krb5asrep --wordlist=/usr/share/wordlists/rockyou.txt asrep_hashes.txt
```

### Pentest Scenario: NetNTLMv2 from Responder

```bash
# 1. Captured hash from Responder
cat responder_hash.txt
# admin::DOMAIN:challenge:response:...

# 2. Crack
john --format=netntlmv2 --wordlist=/usr/share/wordlists/rockyou.txt responder_hash.txt
```

### Web Application Hashes

```bash
# 1. Dumped from database
cat webapp_hashes.txt
# admin:5f4dcc3b5aa765d61d8327deb882cf99

# 2. Identify format (32 hex = likely MD5)
# 3. Crack
john --format=Raw-MD5 --wordlist=/usr/share/wordlists/rockyou.txt webapp_hashes.txt

# For salted hashes, check application-specific format
# WordPress: $P$B...
john --format=phpass wp_hashes.txt

# Drupal 7: $S$...
john --format=drupal7 drupal_hashes.txt
```

### Batch Processing Multiple Formats

```bash
#!/bin/bash
# crack_all.sh - Try multiple formats

HASHFILE=$1
WORDLIST=/usr/share/wordlists/rockyou.txt

# Common formats to try
FORMATS=(
    "Raw-MD5"
    "Raw-SHA1"
    "Raw-SHA256"
    "NT"
    "LM"
    "bcrypt"
    "sha512crypt"
)

for fmt in "${FORMATS[@]}"; do
    echo "[*] Trying format: $fmt"
    john --format="$fmt" --wordlist="$WORDLIST" "$HASHFILE" 2>/dev/null
done

echo "[*] Results:"
john --show "$HASHFILE"
```

## Hash Format Cheatsheet

| Source | Tool | John Format |
|--------|------|-------------|
| Linux /etc/shadow ($6$) | `unshadow` | `sha512crypt` |
| Linux /etc/shadow ($5$) | `unshadow` | `sha256crypt` |
| Linux /etc/shadow ($1$) | `unshadow` | `md5crypt` |
| Windows SAM/NTDS | secretsdump | `NT` |
| SSH Private Key | `ssh2john` | auto |
| ZIP File | `zip2john` | `PKZIP` / `ZIP` |
| RAR File | `rar2john` | auto |
| 7z File | `7z2john` | auto |
| PDF | `pdf2john` | `PDF` |
| Office Documents | `office2john` | auto |
| KeePass | `keepass2john` | auto |
| Kerberos TGS | N/A | `krb5tgs` |
| Kerberos AS-REP | N/A | `krb5asrep` |
| NetNTLMv2 | Responder | `netntlmv2` |
| WordPress | DB dump | `phpass` |
| MySQL 5.x | DB dump | `mysql-sha1` |
| bcrypt | DB dump | `bcrypt` |
