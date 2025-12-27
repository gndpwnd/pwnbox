# smbmap - Complete Options Reference

## Main Arguments

| Option | Description |
|--------|-------------|
| `-H HOST` | IP or FQDN of target |
| `--host-file FILE` | File containing a list of hosts |
| `-u, --username USERNAME` | Username, if omitted null session assumed |
| `-p, --password PASSWORD` | Password or NTLM hash (format: LMHASH:NTHASH) |
| `--prompt` | Prompt for a password |
| `-s SHARE` | Specify a share (default C$) |
| `-d DOMAIN` | Domain name (default WORKGROUP) |
| `-P PORT` | SMB port (default 445) |
| `-v, --version` | Return the OS version of the remote host |
| `--signing` | Check if host has SMB signing disabled, enabled, or required |
| `--admin` | Just report if the user is an admin |
| `--no-banner` | Remove the banner from output |
| `--no-color` | Remove color from output |
| `--no-update` | Remove "Working on it" message |
| `--timeout TIMEOUT` | Set port scan socket timeout (default 0.5 seconds) |

## Kerberos Settings

| Option | Description |
|--------|-------------|
| `-k, --kerberos` | Use Kerberos authentication |
| `--no-pass` | Use CCache file (export KRB5CCNAME='~/current.ccache') |
| `--dc-ip IP` | IP or FQDN of Domain Controller |

## Command Execution

| Option | Description |
|--------|-------------|
| `-x COMMAND` | Execute a command (e.g., 'ipconfig /all') |
| `--mode CMDMODE` | Execution method: wmi or psexec (default: wmi) |

## Share Drive Search

| Option | Description |
|--------|-------------|
| `-L` | List all drives on the specified host (requires ADMIN rights) |
| `-r [PATH]` | Recursively list dirs and files (e.g., 'email/backup') |
| `-g FILE` | Output to grep-friendly format (used with -r) |
| `--csv FILE` | Output to CSV file |
| `--dir-only` | List only directories, omit files |
| `--no-write-check` | Skip check for WRITE access |
| `-q` | Quiet mode - only show shares with READ or WRITE access |
| `--depth DEPTH` | Traverse directory tree to specific depth (default: 1) |
| `--exclude SHARE [SHARE ...]` | Exclude share(s) from searching (e.g., --exclude ADMIN$ C$) |
| `-A PATTERN` | Auto-download files matching regex pattern (requires -r) |

## File Content Search

| Option | Description |
|--------|-------------|
| `-F PATTERN` | File content search (e.g., '[Pp]assword') - requires admin and PowerShell |
| `--search-path PATH` | Specify drive/path to search (default: C:\Users) |
| `--search-timeout TIMEOUT` | Timeout in seconds before search job is killed (default: 300) |

## Filesystem Interaction

| Option | Description |
|--------|-------------|
| `--download PATH` | Download a file (e.g., 'C$\temp\passwords.txt') |
| `--upload SRC DST` | Upload a file (e.g., '/tmp/payload.exe C$\temp\payload.exe') |
| `--delete PATH` | Delete a remote file (e.g., 'C$\temp\msf.exe') |
| `--skip` | Skip delete file confirmation prompt |

## Usage Examples

### Basic Authentication

```bash
# Password authentication
smbmap -u jsmith -p password1 -d workgroup -H 192.168.0.1

# Pass-the-hash
smbmap -u jsmith -p 'aad3b435b51404eeaad3b435b51404ee:da76f2c4c96028b7a6111aef4a50a94d' -H 172.16.0.20

# Domain authentication with command execution
smbmap -u 'apadmin' -p 'asdf1234!' -d ACME -H 10.1.3.30 -x 'net group "Domain Admins" /domain'
```

### Directory Listing

```bash
# Non-recursive listing (ls)
smbmap -H 192.168.86.214 -u Administrator -p asdf1234 -r c$ -q

# Recursive listing with depth
smbmap -H 192.168.86.179 -u Administrator -p asdf1234 -r Tools --depth 2 --no-banner -q
```

### File Operations

```bash
# Auto-download files matching pattern
smbmap -H 192.168.86.179 -u Administrator -p asdf1234 -r 'c$/program files' --depth 2 -A '(password|config)'

# Content search for SSN pattern
smbmap --host-file targets.txt -u user -p pass -d domain -F '[1-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
```

### Network Scanning

```bash
# SMB signing check
smbmap --host-file targets.txt --signing

# OS version enumeration
smbmap --host-file targets.txt -v

# List drives (admin required)
smbmap -H 192.168.1.24 -u Administrator -p 'password' -L
```
