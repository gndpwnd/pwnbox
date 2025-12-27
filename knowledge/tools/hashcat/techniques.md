# hashcat - Advanced Cracking Techniques

> Practical password cracking strategies for Active Directory pentesting

## Table of Contents

- [Rule-Based Attacks](#rule-based-attacks)
- [Mask Attack Patterns](#mask-attack-patterns)
- [Hybrid Attacks](#hybrid-attacks)
- [Combinator and PRINCE Attacks](#combinator-and-prince-attacks)
- [Wordlist Recommendations](#wordlist-recommendations)
- [AD-Specific Cracking Strategies](#ad-specific-cracking-strategies)
- [Performance Optimization](#performance-optimization)
- [Common Password Patterns](#common-password-patterns)

---

## Rule-Based Attacks

Rules transform wordlist entries to match common password patterns. They are essential for cracking real-world passwords.

### Best Rules to Use

Rules are located in `/usr/share/hashcat/rules/` on Kali Linux.

| Rule File | Description | Best For |
|-----------|-------------|----------|
| `best64.rule` | 64 most effective rules | Quick first-pass attacks |
| `rockyou-30000.rule` | 30k rules from rockyou analysis | Comprehensive coverage |
| `d3ad0ne.rule` | ~35k aggressive rules | Deep wordlist mutations |
| `dive.rule` | ~100k rules | Exhaustive attacks |
| `OneRuleToRuleThemAll.rule` | Optimized combined ruleset | Best overall efficiency |
| `Hob0Rules/` | Corporate password patterns | Enterprise environments |

### Rule Attack Examples

```bash
# Quick pass with best64
hashcat -m 1000 ntlm.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# Comprehensive attack with OneRule
hashcat -m 1000 ntlm.txt rockyou.txt -r /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule

# Chain multiple rule files (multiplies candidates)
hashcat -m 1000 ntlm.txt rockyou.txt -r rules/best64.rule -r rules/toggles1.rule

# Generate random rules on the fly
hashcat -m 1000 ntlm.txt rockyou.txt -g 50000
```

### Essential Rule Functions

| Function | Description | Example |
|----------|-------------|---------|
| `:` | Do nothing (passthrough) | `password` -> `password` |
| `l` | Lowercase all | `PASSWORD` -> `password` |
| `u` | Uppercase all | `password` -> `PASSWORD` |
| `c` | Capitalize first, lower rest | `pASSWORD` -> `Password` |
| `C` | Lowercase first, upper rest | `Password` -> `pASSWORD` |
| `t` | Toggle case all | `PaSsWoRd` -> `pAsSwOrD` |
| `$X` | Append character X | `password$!` -> `password!` |
| `^X` | Prepend character X | `password^1` -> `1password` |
| `sXY` | Replace X with Y | `passwordsae` -> `p@ssword` |
| `d` | Duplicate word | `password` -> `passwordpassword` |
| `r` | Reverse word | `password` -> `drowssap` |

### Custom Rules for AD Environments

Create `/usr/share/hashcat/rules/ad-corporate.rule`:

```
# Capitalize and append year + special
c $2 $0 $2 $3 $!
c $2 $0 $2 $4 $!
c $2 $0 $2 $5 $!

# Capitalize and append season/year
c $S $p $r $i $n $g $2 $0 $2 $4
c $S $u $m $m $e $r $2 $0 $2 $4
c $F $a $l $l $2 $0 $2 $4
c $W $i $n $t $e $r $2 $0 $2 $4

# Common leet speak substitutions
c sa@ so0 se3 si1
c sa@ so0 se3 si! ss$

# Append common endings
c $1 $2 $3
c $1 $2 $3 $!
c $! $! $!
c $@ $# $$

# Company name patterns (customize)
c $C $o $r $p
c $I $n $c
```

---

## Mask Attack Patterns

Masks define character sets per position for targeted brute-force attacks.

### Built-in Charsets

| Charset | Characters | Count |
|---------|------------|-------|
| `?l` | a-z | 26 |
| `?u` | A-Z | 26 |
| `?d` | 0-9 | 10 |
| `?s` | Special chars | 33 |
| `?a` | All printable | 95 |
| `?h` | Hex lowercase | 16 |
| `?H` | Hex uppercase | 16 |

### Common Password Masks

#### Basic Patterns

```bash
# 8-char lowercase (fast for simple hashes)
hashcat -m 1000 -a 3 hashes.txt ?l?l?l?l?l?l?l?l

# Capitalize first, 7 lowercase
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?l?l?l?l

# Word + 4 digits (Password1234 pattern)
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?l?l?l?l?d?d?d?d

# Word + 2 digits + special
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?l?l?l?d?d?s
```

#### Corporate Password Patterns

```bash
# Season + Year + Special (Summer2024!)
hashcat -m 1000 -a 3 hashes.txt -1 ?u?l ?1?l?l?l?l?l2024?s

# Company + digits (Corp123!)
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?d?d?d?s

# Incremental length (4-8 chars)
hashcat -m 1000 -a 3 hashes.txt ?a?a?a?a?a?a?a?a --increment --increment-min=4
```

#### Custom Charset Examples

```bash
# Common special chars only
hashcat -m 1000 -a 3 hashes.txt -1 '!@#$%' ?u?l?l?l?l?l?l?l?1

# Digits + common specials
hashcat -m 1000 -a 3 hashes.txt -1 ?d -2 '!@#$' ?u?l?l?l?l?l?1?1?2

# Keyboard walk starting positions
hashcat -m 1000 -a 3 hashes.txt -1 qweasdzxc ?1?l?l?l?l?l?l?l
```

### Mask Files (.hcmask)

Create `/usr/share/hashcat/masks/corporate.hcmask`:

```
# Word + year patterns
?u?l?l?l?l?l?l?l?d?d?d?d
?u?l?l?l?l?l?l?d?d?d?d
?u?l?l?l?l?l?d?d?d?d
?u?l?l?l?l?d?d?d?d

# Year + special suffix
?u?l?l?l?l?l?l2023!
?u?l?l?l?l?l?l2024!
?u?l?l?l?l?l?l2025!

# Word + digits + special
?u?l?l?l?l?l?l?l?d?d?s
?u?l?l?l?l?l?l?d?d?s
?u?l?l?l?l?l?d?d?s

# All lowercase with specials
?l?l?l?l?l?l?l?l?s
?l?l?l?l?l?l?l?s?s
```

Usage:
```bash
hashcat -m 1000 -a 3 hashes.txt /usr/share/hashcat/masks/corporate.hcmask
```

---

## Hybrid Attacks

Combine wordlists with masks for intelligent targeted attacks.

### Mode 6: Wordlist + Mask (Append)

```bash
# Append 4 digits to wordlist entries
hashcat -m 1000 -a 6 hashes.txt wordlist.txt ?d?d?d?d

# Append year + special
hashcat -m 1000 -a 6 hashes.txt wordlist.txt 2024?s

# Append 1-4 digits incrementally
hashcat -m 1000 -a 6 hashes.txt wordlist.txt ?d?d?d?d --increment

# Append common suffixes
hashcat -m 1000 -a 6 hashes.txt wordlist.txt -1 '!@#$' ?d?d?1
```

### Mode 7: Mask + Wordlist (Prepend)

```bash
# Prepend 2 digits
hashcat -m 1000 -a 7 hashes.txt ?d?d wordlist.txt

# Prepend special + digit
hashcat -m 1000 -a 7 hashes.txt -1 '!@#$' ?1?d wordlist.txt
```

### Hybrid with Rules

```bash
# Wordlist + mask + rules (powerful combination)
hashcat -m 1000 -a 6 hashes.txt wordlist.txt ?d?d?d?d -r rules/best64.rule

# Rules applied before mask append
hashcat -m 1000 -a 6 hashes.txt company-words.txt ?d?d?s -r rules/toggles5.rule
```

### Practical Hybrid Scenarios

```bash
# Username-based (append patterns)
hashcat -m 1000 -a 6 hashes.txt usernames.txt ?d?d?d?d
hashcat -m 1000 -a 6 hashes.txt usernames.txt 123!
hashcat -m 1000 -a 6 hashes.txt usernames.txt 2024!

# Company name variations
hashcat -m 1000 -a 6 hashes.txt company-terms.txt ?d?d?d?s -r rules/best64.rule

# First names + patterns
hashcat -m 1000 -a 6 hashes.txt firstnames.txt ?d?d?d?d -r rules/best64.rule
```

---

## Combinator and PRINCE Attacks

### Combinator Attack (Mode 1)

Combines words from two wordlists.

```bash
# Basic combination
hashcat -m 1000 -a 1 hashes.txt wordlist1.txt wordlist2.txt

# With rules on left wordlist (-j) or right wordlist (-k)
hashcat -m 1000 -a 1 hashes.txt wordlist1.txt wordlist2.txt -j '$-' -k '$!'

# Combine first names with years
hashcat -m 1000 -a 1 hashes.txt firstnames.txt years.txt

# Company terms + common words
hashcat -m 1000 -a 1 hashes.txt company-terms.txt common-suffixes.txt
```

Create supporting wordlists:

**years.txt:**
```
2020
2021
2022
2023
2024
2025
```

**common-suffixes.txt:**
```
123
1234
!
123!
!@#
```

### PRINCE Attack (princeprocessor)

PRINCE generates password candidates by combining words in various lengths and combinations.

```bash
# Install princeprocessor
git clone https://github.com/hashcat/princeprocessor.git
cd princeprocessor/src && make

# Generate candidates and pipe to hashcat
./pp64.bin wordlist.txt | hashcat -m 1000 hashes.txt

# Limit element length and count
./pp64.bin --elem-cnt-min=2 --elem-cnt-max=4 wordlist.txt | hashcat -m 1000 hashes.txt

# With minimum/maximum password length
./pp64.bin --pw-min=8 --pw-max=12 wordlist.txt | hashcat -m 1000 hashes.txt
```

### Combinator with hashcat-utils

```bash
# Install hashcat-utils
git clone https://github.com/hashcat/hashcat-utils.git
cd hashcat-utils/src && make

# Combine two wordlists to stdout
./combinator.bin wordlist1.txt wordlist2.txt | hashcat -m 1000 hashes.txt

# Generate combinations first (useful for reuse)
./combinator.bin firstnames.txt years.txt > name-year-combos.txt
```

---

## Wordlist Recommendations

### Essential Wordlists

| Wordlist | Size | Best For | Source |
|----------|------|----------|--------|
| rockyou.txt | 14M | General passwords | `/usr/share/wordlists/rockyou.txt` |
| SecLists | Varies | Targeted attacks | github.com/danielmiessler/SecLists |
| CrackStation | 1.5B | Comprehensive | crackstation.net |
| Weakpass | Varies | Updated leaks | weakpass.com |
| hashesorg | 300M+ | Unique passwords | hashes.org (archived) |

### Specialized Wordlists for AD

```bash
# Create from company website
cewl -d 3 -m 5 https://target.com -w company-words.txt

# Extract from documents
strings *.pdf *.docx | sort -u > doc-words.txt

# AD usernames as base
# Format: jsmith -> jsmith, JSmith, john.smith, etc.
cat users.txt | hashcat --stdout -r rules/best64.rule > user-mutations.txt
```

### Wordlist Processing

```bash
# Remove duplicates and sort
sort -u wordlist.txt -o wordlist-clean.txt

# Filter by length (8-16 chars)
awk 'length >= 8 && length <= 16' wordlist.txt > filtered.txt

# Combine multiple wordlists
cat list1.txt list2.txt list3.txt | sort -u > combined.txt

# Add company-specific terms
echo -e "CompanyName\nCompanyAcronym\nProductName" >> wordlist.txt
```

### Recommended Wordlist Strategy

1. **Quick wins**: rockyou.txt + best64.rule
2. **Company terms**: cewl + custom rules
3. **Usernames**: AD users + hybrid attacks
4. **Deep dive**: Large wordlists + comprehensive rules

---

## AD-Specific Cracking Strategies

### NTLM Hashes (Mode 1000)

Fastest to crack due to lack of salt.

```bash
# Quick rockyou pass
hashcat -m 1000 ntlm.txt /usr/share/wordlists/rockyou.txt -r rules/best64.rule

# Corporate password patterns
hashcat -m 1000 ntlm.txt company-words.txt -r rules/d3ad0ne.rule

# Mask attack for common patterns
hashcat -m 1000 -a 3 ntlm.txt ?u?l?l?l?l?l?l?d?d?d?d

# Hybrid with usernames
hashcat -m 1000 -a 6 ntlm.txt usernames.txt ?d?d?d?d -r rules/best64.rule
```

**Cracking Order for NTLM:**
1. Wordlist + best64
2. Hybrid username + digits
3. Common masks (?u?l?l?l?l?l?d?d?d?d)
4. Wordlist + aggressive rules
5. Incremental brute force

### NetNTLMv2 Hashes (Mode 5600)

Captured from Responder/ntlmrelayx. Slower than NTLM.

```bash
# Hash format: username::domain:challenge:response:blob
# Example: admin::CORP:1122334455667788:A1B2C3...:0101000000...

# Quick dictionary attack
hashcat -m 5600 netntlmv2.txt rockyou.txt -r rules/best64.rule

# Focus on likely passwords (speed matters)
hashcat -m 5600 netntlmv2.txt top10k.txt -r rules/OneRuleToRuleThemAll.rule

# Common corporate patterns
hashcat -m 5600 -a 3 netntlmv2.txt ?u?l?l?l?l?l2024!
hashcat -m 5600 -a 3 netntlmv2.txt Summer2024!

# Targeted with company terms
hashcat -m 5600 netntlmv2.txt company-words.txt -r rules/best64.rule -O
```

**NetNTLMv2 Strategy:**
- Focus on common passwords (slower hash)
- Use `-O` for optimized kernels
- Target seasonal/year patterns
- Company-specific wordlists essential

### Kerberos TGS-REP / Kerberoasting (Mode 13100)

```bash
# Hash format from GetUserSPNs.py / Rubeus
# $krb5tgs$23$*user$realm$spn*$hash...

# Quick pass
hashcat -m 13100 kerberos-tgs.txt rockyou.txt -r rules/best64.rule

# Service accounts often have weak passwords
hashcat -m 13100 kerberos-tgs.txt /usr/share/wordlists/rockyou.txt

# Common service account patterns
hashcat -m 13100 -a 3 kerberos-tgs.txt ?u?l?l?l?l?l?l?l?d?d?d?d
hashcat -m 13100 kerberos-tgs.txt company-words.txt -r rules/d3ad0ne.rule

# Hybrid attacks
hashcat -m 13100 -a 6 kerberos-tgs.txt service-names.txt ?d?d?d?d
```

### Kerberos AS-REP / AS-REP Roasting (Mode 18200)

```bash
# Hash format from GetNPUsers.py
# $krb5asrep$23$user@domain:hash...

# Standard attack progression
hashcat -m 18200 asrep.txt rockyou.txt -r rules/best64.rule
hashcat -m 18200 asrep.txt rockyou.txt -r rules/d3ad0ne.rule
hashcat -m 18200 -a 6 asrep.txt usernames.txt ?d?d?d?d
```

### Kerberos AES Hashes (Modes 19600, 19700, 19800, 19900)

Slower but more secure encryption types.

```bash
# AES128 TGS-REP (mode 19600)
hashcat -m 19600 aes-tgs.txt rockyou.txt -r rules/best64.rule -w 3

# AES256 TGS-REP (mode 19700)
hashcat -m 19700 aes256-tgs.txt rockyou.txt -r rules/best64.rule -w 3

# AES Pre-Auth (19800, 19900)
hashcat -m 19800 aes-preauth.txt rockyou.txt
```

### Domain Cached Credentials (DCC2) (Mode 2100)

Very slow - be strategic.

```bash
# DCC2 format: $DCC2$iterations#username#hash
# From secretsdump.py / mimikatz

# Only use focused wordlists
hashcat -m 2100 dcc2.txt top1000.txt -r rules/best64.rule -w 3

# Common patterns only
hashcat -m 2100 -a 3 dcc2.txt ?u?l?l?l?l?l?d?d?d?d -w 3

# Be patient - very slow
hashcat -m 2100 dcc2.txt company-words.txt -w 3 -O
```

### LM Hashes (Mode 3000)

Legacy but still found. Split into 7-char halves.

```bash
# LM hashes are case-insensitive and split at 7 chars
hashcat -m 3000 lm.txt -a 3 ?a?a?a?a?a?a?a

# After cracking, use results to find NTLM
# LM: ABCD -> try ABCDabcd, Abcdabcd, etc. for NTLM
```

---

## Performance Optimization

### GPU Optimization

```bash
# High workload profile
hashcat -m 1000 hashes.txt wordlist.txt -w 3

# Optimized kernels (faster, 256 char password limit)
hashcat -m 1000 hashes.txt wordlist.txt -O

# Maximum performance (headless systems)
hashcat -m 1000 hashes.txt wordlist.txt -w 4 -O

# Specify GPU devices
hashcat -m 1000 hashes.txt wordlist.txt -d 1,2

# Check available devices
hashcat -I
```

### Session Management

```bash
# Named session (for restore)
hashcat -m 1000 hashes.txt wordlist.txt --session=corp-ntlm

# Restore interrupted session
hashcat --restore --session=corp-ntlm

# Run for specific time (seconds)
hashcat -m 1000 hashes.txt wordlist.txt --runtime=3600

# Skip already cracked (use potfile)
hashcat -m 1000 hashes.txt wordlist.txt --potfile-path=corp.pot
```

### Multi-Hash Optimization

```bash
# For many hashes, hashcat optimizes automatically
# Just provide all hashes in one file

# Remove cracked hashes from file
hashcat -m 1000 hashes.txt --left > remaining.txt

# Show cracked with username
hashcat -m 1000 hashes.txt --show --username
```

### Temperature Management

```bash
# Set temperature abort threshold
hashcat -m 1000 hashes.txt wordlist.txt --hwmon-temp-abort=85

# Disable hardware monitoring (not recommended)
hashcat -m 1000 hashes.txt wordlist.txt --hwmon-disable
```

### Memory Optimization

```bash
# Reduce memory usage with segment size
hashcat -m 1000 hashes.txt wordlist.txt -c 32

# For slow hashes, use slow candidates mode
hashcat -m 2100 dcc2.txt wordlist.txt -S
```

---

## Common Password Patterns

### Pattern Categories to Target

| Pattern | Example | Mask/Rule |
|---------|---------|-----------|
| Word + Year | Password2024 | `-a 6 wordlist.txt 2024` |
| Word + Digits + Special | Password123! | `-a 6 wordlist.txt ?d?d?d?s` |
| Season + Year | Summer2024 | `-a 3 ?u?l?l?l?l?l2024` |
| Company + Pattern | Corp123! | `-a 6 company.txt ?d?d?d?s` |
| Keyboard Walks | qwerty123 | Specialized wordlists |
| Leet Speak | P@ssw0rd | Rules: `sa@ so0 se3` |
| Name + Numbers | John1234 | `-a 6 names.txt ?d?d?d?d` |

### Seasonal Password Lists

Create `seasonal-passwords.txt`:
```
Spring2024
Summer2024
Fall2024
Autumn2024
Winter2024
January2024
February2024
...
Spring2024!
Summer2024!
```

### Year Patterns

```bash
# Current and recent years
hashcat -m 1000 -a 6 hashes.txt wordlist.txt 2023
hashcat -m 1000 -a 6 hashes.txt wordlist.txt 2024
hashcat -m 1000 -a 6 hashes.txt wordlist.txt 2025

# With special char
hashcat -m 1000 -a 6 hashes.txt wordlist.txt 2024!
hashcat -m 1000 -a 6 hashes.txt wordlist.txt 2024@

# Full year range mask
hashcat -m 1000 -a 6 hashes.txt wordlist.txt 20?d?d?s
```

### Corporate Password Requirements

Target minimum complexity requirements:

```bash
# 8+ chars, upper, lower, digit, special
# Pattern: Ullllllds (Word8+digit+special)
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?l?l?l?l?d?s

# Common compliance patterns
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?l?l?l?d?d?s    # Word7+2d+s
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?l?l?d?d?d?s    # Word6+3d+s
```

### First-Pass Attack Script

```bash
#!/bin/bash
# quick-crack.sh - Fast initial cracking pass

HASHES=$1
HASHMODE=$2
WORDLIST="/usr/share/wordlists/rockyou.txt"

echo "[*] Starting quick crack for mode $HASHMODE"

# Phase 1: Straight dictionary
echo "[+] Phase 1: Dictionary attack"
hashcat -m $HASHMODE -a 0 $HASHES $WORDLIST --session=phase1 -O

# Phase 2: Best64 rules
echo "[+] Phase 2: Best64 rules"
hashcat -m $HASHMODE -a 0 $HASHES $WORDLIST -r /usr/share/hashcat/rules/best64.rule --session=phase2 -O

# Phase 3: Common masks
echo "[+] Phase 3: Common password masks"
hashcat -m $HASHMODE -a 3 $HASHES ?u?l?l?l?l?l?l?l?d?d?d?d --session=phase3 -O
hashcat -m $HASHMODE -a 3 $HASHES ?u?l?l?l?l?l?l2024?s --session=phase4 -O

# Phase 4: Hybrid
echo "[+] Phase 4: Hybrid attack"
hashcat -m $HASHMODE -a 6 $HASHES $WORDLIST ?d?d?d?d --session=phase5 -O

# Show results
echo "[*] Cracked passwords:"
hashcat -m $HASHMODE $HASHES --show
```

---

## Quick Reference

### AD Hash Mode Cheat Sheet

| Hash Type | Mode | Speed | Priority |
|-----------|------|-------|----------|
| NTLM | 1000 | Fast | High |
| NetNTLMv2 | 5600 | Medium | High |
| Kerberos TGS (RC4) | 13100 | Medium | High |
| Kerberos AS-REP | 18200 | Medium | High |
| Kerberos TGS (AES128) | 19600 | Slow | Medium |
| Kerberos TGS (AES256) | 19700 | Slow | Medium |
| DCC2 / MS Cache 2 | 2100 | Very Slow | Low |
| LM | 3000 | Fast | Legacy |

### Command Quick Reference

```bash
# Show cracked
hashcat -m MODE hashes.txt --show

# Show uncracked
hashcat -m MODE hashes.txt --left

# Benchmark hash type
hashcat -m MODE -b

# Identify hash type
hashcat --identify hash.txt

# Output to file
hashcat -m MODE hashes.txt wordlist.txt -o cracked.txt

# Output format (hash:password)
hashcat -m MODE hashes.txt wordlist.txt -o cracked.txt --outfile-format=3
```

## External Resources

- [Hashcat Wiki - Rule-based Attack](https://hashcat.net/wiki/doku.php?id=rule_based_attack)
- [Hashcat Wiki - Mask Attack](https://hashcat.net/wiki/doku.php?id=mask_attack)
- [OneRuleToRuleThemAll](https://github.com/NotSoSecure/password_cracking_rules)
- [Hob0Rules - Corporate Rules](https://github.com/praetorian-inc/Hob0Rules)
- [n0kovo's Rules Collection](https://github.com/n0kovo/hashcat-rules-collection)
- [PRINCE Algorithm Paper](https://hashcat.net/events/p14-trondheim/PRINCE-ATTACK.pdf)
