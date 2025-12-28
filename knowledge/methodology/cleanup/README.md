---
title: Cleanup
category: methodology
tags: [cleanup, anti-forensics, log-clearing]
last_updated: 2025-12-27
---

# Cleanup

## Overview

Cleanup involves removing evidence of an attack from compromised systems. In penetration testing, this is performed to restore systems to their original state.

**Ethical Considerations:**
- Always document what was modified during testing
- Cleanup is mandatory in authorized penetration tests
- Restore original configurations when possible
- Provide detailed logs to the client

> **Warning:** In real engagements, thorough cleanup documentation helps clients understand what was accessed and modified.

---

## Windows Cleanup

### Event Log Clearing

```powershell
# Clear specific event logs
wevtutil cl Security
wevtutil cl System
wevtutil cl Application

# Clear all logs (PowerShell)
Get-EventLog -List | ForEach-Object { Clear-EventLog $_.Log }

# Using Metasploit
meterpreter > clearev
```

### Prefetch and Recent Files

```powershell
# Clear Prefetch (requires admin)
del /q C:\Windows\Prefetch\*

# Clear Recent files
del /q %APPDATA%\Microsoft\Windows\Recent\*

# Clear temp files
del /q %TEMP%\*
```

### Remove Persistence Mechanisms

```powershell
# Remove registry keys
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Backdoor" /f

# Remove scheduled tasks
schtasks /delete /tn "SystemUpdate" /f

# Remove services
sc delete backdoor
```

### PowerShell History

```powershell
# Clear PSReadLine history
Remove-Item (Get-PSReadlineOption).HistorySavePath

# Clear current session
Clear-History
```

---

## Linux Cleanup

### Bash History

```bash
# Clear history file
cat /dev/null > ~/.bash_history

# Clear current session history
history -c

# Prevent history logging (set before attack)
unset HISTFILE
export HISTSIZE=0
```

### Log Files

```bash
# Clear auth logs
cat /dev/null > /var/log/auth.log
cat /dev/null > /var/log/secure

# Clear syslog
cat /dev/null > /var/log/syslog
cat /dev/null > /var/log/messages

# Clear wtmp/btmp (login records)
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/btmp

# Clear lastlog
cat /dev/null > /var/log/lastlog
```

### Remove Persistence

```bash
# Remove cron jobs
crontab -r

# Remove systemd services
systemctl disable backdoor.service
rm /etc/systemd/system/backdoor.service

# Remove SSH keys
sed -i '/attacker@host/d' ~/.ssh/authorized_keys
```

### Temporary Files

```bash
# Remove uploaded tools
rm -rf /tmp/tools /dev/shm/payload

# Clear /tmp
rm -rf /tmp/*
```

---

## Cleanup Checklist

| Category | Items to Remove |
|----------|-----------------|
| Logs | Event logs, auth logs, syslog |
| History | Bash history, PowerShell history |
| Persistence | Registry, services, cron, SSH keys |
| Files | Uploaded tools, payloads, temp files |
| Network | Tunnels, proxies, port forwards |
