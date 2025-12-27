---
title: "rlwrap"
category: "utilities"
tags: ["readline", "shell", "history", "cli", "wrapper", "reverse-shell"]
---

# rlwrap

## Overview

rlwrap (readline wrapper) is a utility that uses the GNU Readline library to provide line editing, persistent command history, and tab completion to any command-line program that lacks these features. In penetration testing, rlwrap is invaluable for making reverse shells more usable by adding arrow key navigation, command history (up/down arrows), and basic line editing capabilities that raw shells typically lack.

## Installation

rlwrap is typically pre-installed on Kali Linux. For other Debian/Ubuntu systems:

```bash
# Install rlwrap
sudo apt update
sudo apt install rlwrap

# Verify installation
rlwrap --version

# View help
rlwrap --help
```

## Basic Usage

```bash
# Basic syntax
rlwrap [options] <command> [command_arguments]

# Common options:
# -a    Always remain in readline mode
# -A    Disable terminal auto-configuration
# -c    Complete filenames
# -f    Use completion word list from file
# -H    Specify history file
# -r    Remember words from input/output for completion
# -s    Limit history size (default: 300)
# -S    Set prompt string
# -p    Set prompt color
# -e    Set extra characters that count as word delimiters
```

## Key Features

### Line Editing
- Arrow keys for cursor movement (left/right)
- Home/End keys to jump to line start/end
- Ctrl+A (start), Ctrl+E (end), Ctrl+K (kill to end)
- Backspace and Delete key support
- Word-by-word navigation with Ctrl+Left/Right

### Command History
- Up/Down arrows to navigate command history
- Ctrl+R for reverse history search
- Persistent history across sessions
- Configurable history size

### Tab Completion
- File name completion
- Custom word completion from files
- Remember words seen in input/output

### Transparency
- rlwrap aims to be transparent; the wrapped command should behave identically except for the added readline features

## Common Use Cases

### Wrapping Netcat Listener

The most common use in penetration testing:

```bash
# Basic netcat listener with readline support
rlwrap nc -lvnp 4444

# Now when you catch a reverse shell, you have:
# - Command history (up/down arrows)
# - Line editing (left/right arrows, backspace works properly)
# - Ctrl+C won't kill your shell immediately
```

### Wrapping Ncat Listener

```bash
# ncat with SSL and readline
rlwrap ncat --ssl -lvnp 4444

# ncat with access control
rlwrap ncat -lvnkp 4444 --allow 10.0.0.0/8
```

### Improving SQL*Plus (Oracle)

```bash
# SQL*Plus lacks readline by default
rlwrap sqlplus user/password@database

# Remember SQL keywords for completion
rlwrap -f sql_keywords.txt sqlplus user/password@database
```

### Wrapping Interactive Scripts

```bash
# Python REPL alternative wrapper
rlwrap python3

# Interactive shells
rlwrap /bin/sh

# Any interactive program
rlwrap ./interactive_script.sh
```

### Using Custom History File

```bash
# Specify a custom history file
rlwrap -H ~/.my_custom_history nc -lvnp 4444

# Limit history to 500 entries
rlwrap -s 500 nc -lvnp 4444
```

### Enabling File Completion

```bash
# Enable filename tab completion
rlwrap -c nc -lvnp 4444
```

### Custom Word Completion

Create a completion file with common commands:

```bash
# Create completion file
cat > ~/.rlwrap/nc_completions << 'EOF'
whoami
id
uname -a
cat /etc/passwd
ls -la
pwd
cd /tmp
wget
curl
python
python3
bash
EOF

# Use completion file
rlwrap -f ~/.rlwrap/nc_completions nc -lvnp 4444
```

### Colorized Prompt

```bash
# Set colored prompt (useful for distinguishing shells)
rlwrap -pRed nc -lvnp 4444

# Available colors: Black, Red, Green, Yellow, Blue, Magenta, Cyan, White
```

### Remember Words for Completion

```bash
# Remember all words seen in input/output for tab completion
rlwrap -r nc -lvnp 4444

# This learns usernames, paths, and other strings from the shell session
```

### Always Stay in Readline Mode

```bash
# Force readline mode even when program changes terminal settings
rlwrap -a nc -lvnp 4444

# Useful when the wrapped program tries to do its own terminal handling
```

## Penetration Testing Workflow

### Step 1: Start Listener with rlwrap

On your attack machine:
```bash
rlwrap nc -lvnp 4444
```

### Step 2: Catch Reverse Shell

When the target connects back, you have a shell with readline support.

### Step 3: Further Upgrade (Optional)

For a fully interactive TTY, you can still upgrade:
```bash
# In the caught shell:
python3 -c 'import pty; pty.spawn("/bin/bash")'
# Press Ctrl+Z to background

# In your terminal:
stty raw -echo; fg

# Back in the shell:
export TERM=xterm
stty rows 40 cols 120
```

Even without the full upgrade, rlwrap provides significant usability improvements.

## Configuration

### Environment Variables

```bash
# Set custom rlwrap home directory
export RLWRAP_HOME=~/.rlwrap

# rlwrap stores history and completion files here
```

### Default File Locations

| File | Location | Purpose |
|------|----------|---------|
| History | `~/.command_history` or `$RLWRAP_HOME/command_history` | Command history for wrapped program |
| Completions | `~/.command_completions` or `$RLWRAP_HOME/command_completions` | Custom completion words |

### Creating Persistent Configuration

```bash
# Create rlwrap home directory
mkdir -p ~/.rlwrap

# Create alias with preferred options
echo 'alias ncl="rlwrap -a -c nc -lvnp"' >> ~/.bashrc

# Usage: ncl 4444
```

## Tips and Best Practices

1. **Always Wrap Netcat Listeners**: Make it a habit to use `rlwrap nc` instead of just `nc` when catching shells.

2. **Create Aliases**: Set up bash aliases for common patterns:
   ```bash
   alias listen='rlwrap nc -lvnp'
   # Usage: listen 4444
   ```

3. **Use -a Flag for Stubborn Programs**: If readline features aren't working, try the `-a` flag to force readline mode.

4. **Build Custom Completion Files**: Create completion files for common penetration testing commands to speed up your workflow.

5. **Combine with Screen/Tmux**: Use rlwrap inside screen or tmux sessions for even more flexibility and persistence.

6. **History Search**: Use Ctrl+R to search through your command history - invaluable when repeating complex commands.

7. **Know the Limitations**: rlwrap adds usability but doesn't give you a full PTY. For features like Ctrl+C handling, vim editing, and proper signal handling, you still need a full shell upgrade.

8. **Multiple Listeners**: Each rlwrap instance can have its own history. Use the `-H` flag to maintain separate histories for different engagements.

9. **Quiet Prompts**: Use `-S ""` to suppress rlwrap's prompt if it interferes with the shell's output.

10. **Remember rlwrap in Scripts**: When scripting listener setups, include rlwrap for better interactive experience.

## Related Tools

- **nc/netcat** - Network utility commonly wrapped with rlwrap
- **ncat** - Modern netcat from Nmap project
- **socat** - Can create fully interactive PTY shells
- **pwncat** - Python-based shell handler with auto-upgrade
- **screen/tmux** - Terminal multiplexers for session management
- **stty** - Terminal settings for shell upgrades
- **python pty** - Python module for pseudo-terminal allocation
