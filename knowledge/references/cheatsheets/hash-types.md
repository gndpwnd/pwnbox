---
title: Hash Types Cheatsheet
category: reference
last_updated: 2025-12-27
description: Common hash types, identification, and cracking tool references
---

# Hash Types Cheatsheet

Reference for identifying and cracking common hash types.

---

## Hash Identification

### By Length

| Length | Possible Types                                    |
|--------|---------------------------------------------------|
| 32     | MD5, NTLM, MD4                                    |
| 40     | SHA-1                                             |
| 56     | SHA-224                                           |
| 64     | SHA-256, SHA3-256                                 |
| 96     | SHA-384, SHA3-384                                 |
| 128    | SHA-512, SHA3-512, Whirlpool                      |

### By Format/Prefix

| Prefix/Format            | Hash Type                      |
|--------------------------|--------------------------------|
| `$1$`                    | MD5crypt (Linux)               |
| `$2a$`, `$2b$`, `$2y$`   | bcrypt                         |
| `$5$`                    | SHA-256crypt (Linux)           |
| `$6$`                    | SHA-512crypt (Linux)           |
| `$apr1$`                 | Apache MD5                     |
| `$P$`, `$H$`             | phpass (WordPress, phpBB)      |
| `$y$`, `$7$`             | yescrypt                       |
| `{SHA}`, `{SSHA}`        | LDAP SHA                       |
| `aad3b435...` (starts)   | Empty LM hash                  |

---

## Common Hash Types

### MD5

```
Example: 5d41402abc4b2a76b9719d911017c592
Length: 32 characters
Hashcat Mode: 0
John Format: Raw-MD5
```

### MD5crypt (Linux)

```
Example: $1$salt$qJH7.N4xYta3aEG/dfqo/0
Hashcat Mode: 500
John Format: md5crypt
```

### SHA-1

```
Example: aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
Length: 40 characters
Hashcat Mode: 100
John Format: Raw-SHA1
```

### SHA-256

```
Example: 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
Length: 64 characters
Hashcat Mode: 1400
John Format: Raw-SHA256
```

### SHA-512

```
Example: cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e
Length: 128 characters
Hashcat Mode: 1700
John Format: Raw-SHA512
```

### SHA-512crypt (Linux)

```
Example: $6$rounds=5000$salt$hash...
Hashcat Mode: 1800
John Format: sha512crypt
Notes: Modern Linux default
```

### bcrypt

```
Example: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
Hashcat Mode: 3200
John Format: bcrypt
Notes: Very slow to crack, 60 chars
```

---

## Windows Hashes

### NTLM

```
Example: a4f49c406510bdcab6824ee7c30fd852
Length: 32 characters
Hashcat Mode: 1000
John Format: NT
Notes: Windows password hash
```

### LM (Legacy)

```
Example: aad3b435b51404eeaad3b435b51404ee
Length: 32 characters
Hashcat Mode: 3000
John Format: LM
Notes: Deprecated, weak
```

### NTLMv1

```
Example: u4-netntlm::kNS:338d08f8e26de93300000000000000000000000000000000:9526fb8c23a90751cdd619b6cea564742e1e4bf33006ba41:cb8086049ec4736c
Hashcat Mode: 5500
John Format: netntlm
```

### NTLMv2

```
Example: admin::N46iSNekpT:08ca45b7d7ea58ee:88dcbe4446168966a153a0064958dac6:5c7830315c7830310000000000000b45c67103d07d7b95acd12ffa11230e0000000052920b85f78d013c31cdb3b92f5d765c783030
Hashcat Mode: 5600
John Format: netntlmv2
Notes: Most common in modern Windows
```

### Net-NTLMv2 (Responder capture)

```
Hashcat Mode: 5600
John Format: netntlmv2
```

### MS Cache 2 (DCC2)

```
Example: $DCC2$10240#user#hash
Hashcat Mode: 2100
John Format: mscash2
Notes: Domain Cached Credentials
```

---

## Kerberos Hashes

### Kerberoast (TGS-REP)

```
Example: $krb5tgs$23$*user$realm$spn*$hash...
Hashcat Mode: 13100
John Format: krb5tgs
Notes: Service ticket encryption
```

### AS-REP Roast

```
Example: $krb5asrep$23$user@domain:hash...
Hashcat Mode: 18200
John Format: krb5asrep
Notes: Users without preauth
```

---

## Web Application Hashes

### WordPress (phpass)

```
Example: $P$B4aNM28N0E.tMy/JIcnVMZbGcU16Q70
Hashcat Mode: 400
John Format: phpass
```

### Drupal 7

```
Example: $S$D...
Hashcat Mode: 7900
John Format: Drupal7
```

### Joomla

```
Example: hash:salt (MD5)
Hashcat Mode: 11
John Format: --
```

### phpBB3

```
Example: $H$9...
Hashcat Mode: 400
John Format: phpass
```

### Django (PBKDF2-SHA256)

```
Example: pbkdf2_sha256$iterations$salt$hash
Hashcat Mode: 10000
John Format: django
```

---

## Database Hashes

### MySQL 4.1+

```
Example: *2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19
Hashcat Mode: 300
John Format: mysql-sha1
Notes: Starts with *
```

### MySQL 3.x

```
Example: 606717496665bcba
Hashcat Mode: 200
John Format: mysql
```

### PostgreSQL MD5

```
Example: md5hash (prefixed with md5)
Hashcat Mode: 12
John Format: --
```

### MSSQL 2005+

```
Example: 0x0100...
Hashcat Mode: 131 (2005), 132 (2012+)
John Format: mssql05, mssql12
```

### Oracle 11g+

```
Example: S:hash
Hashcat Mode: 112
John Format: oracle11
```

---

## Quick Reference Table

| Hash Type        | Hashcat | John Format    | Length/Notes        |
|------------------|---------|----------------|---------------------|
| MD5              | 0       | Raw-MD5        | 32 chars            |
| MD5crypt         | 500     | md5crypt       | $1$ prefix          |
| SHA-1            | 100     | Raw-SHA1       | 40 chars            |
| SHA-256          | 1400    | Raw-SHA256     | 64 chars            |
| SHA-512          | 1700    | Raw-SHA512     | 128 chars           |
| SHA-512crypt     | 1800    | sha512crypt    | $6$ prefix          |
| bcrypt           | 3200    | bcrypt         | $2a/b/y$ prefix     |
| NTLM             | 1000    | NT             | 32 chars            |
| NTLMv2           | 5600    | netntlmv2      | Responder captures  |
| Kerberoast       | 13100   | krb5tgs        | $krb5tgs$ prefix    |
| AS-REP           | 18200   | krb5asrep      | $krb5asrep$ prefix  |
| WordPress        | 400     | phpass         | $P$ prefix          |
| MySQL 4.1+       | 300     | mysql-sha1     | * prefix            |
| MSSQL 2012       | 1731    | mssql12        | 0x0100 prefix       |

---

## Identification Tools

```bash
# hashid
hashid 'hash_string'
hashid -m 'hash_string'  # Show hashcat mode

# hash-identifier
hash-identifier

# haiti
haiti 'hash_string'

# Name-That-Hash
nth --text 'hash_string'
```

---

## Cracking Commands

### Hashcat

```bash
# Basic crack with wordlist
hashcat -m <mode> hash.txt wordlist.txt

# With rules
hashcat -m <mode> hash.txt wordlist.txt -r rules/best64.rule

# Show cracked
hashcat -m <mode> hash.txt --show

# Brute force
hashcat -m <mode> hash.txt -a 3 ?a?a?a?a?a?a

# Incremental
hashcat -m <mode> hash.txt -a 3 --increment ?a?a?a?a?a?a?a?a
```

### John the Ripper

```bash
# Auto-detect format
john hash.txt

# Specify format
john --format=<format> hash.txt

# With wordlist
john --wordlist=wordlist.txt hash.txt

# Show cracked
john --show hash.txt

# With rules
john --wordlist=wordlist.txt --rules hash.txt
```

---

## Tips

1. **Identify first** - Always confirm hash type before cracking
2. **Check length** - Hash length is the quickest identifier
3. **Look for prefixes** - Many algorithms have distinctive prefixes
4. **Context matters** - Where you found the hash helps identify it
5. **Start simple** - Try common wordlists before complex attacks
6. **Use rules** - Rules greatly improve wordlist effectiveness
