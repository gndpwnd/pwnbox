# Gobuster - Official Documentation

Source: https://github.com/OJ/gobuster

---

## Overview

Gobuster is a tool used to brute-force:
- URIs (directories and files) in web sites
- DNS subdomains (with wildcard support)
- Virtual Host names on target web servers
- Open Amazon S3 buckets
- Open Google Cloud buckets
- TFTP servers

## Requirements

- Go 1.24 or higher (for building from source)

## Installation

### From Binary Releases

Pre-compiled binaries are available from the [releases page](https://github.com/OJ/gobuster/releases).

### Using Go Install

```bash
go install github.com/OJ/gobuster/v3@latest
```

### From Source

```bash
git clone https://github.com/OJ/gobuster.git
cd gobuster
go get && go build
```

### Docker

```bash
docker pull ghcr.io/oj/gobuster:latest
docker run ghcr.io/oj/gobuster:latest -h
```

## Available Modes

| Mode | Description |
|------|-------------|
| `dir` | Directory/file enumeration mode |
| `dns` | DNS subdomain enumeration mode |
| `fuzz` | Fuzzing mode (replaces FUZZ keyword in URL) |
| `gcs` | Google Cloud bucket enumeration mode |
| `s3` | AWS S3 bucket enumeration mode |
| `tftp` | TFTP enumeration mode |
| `vhost` | Virtual host enumeration mode (not the same as DNS!) |

## Global Flags

These flags apply to all modes:

```
Flags:
      --debug                 Enable debug output
      --delay duration        Time each thread waits between requests (e.g. 1500ms)
  -h, --help                  help for gobuster
      --no-color              Disable color output
      --no-error              Don't display errors
  -z, --no-progress           Don't display progress
  -o, --output string         Output file to write results to (defaults to stdout)
  -p, --pattern string        File containing replacement patterns
  -q, --quiet                 Don't print the banner and other noise
  -t, --threads int           Number of concurrent threads (default 10)
  -v, --verbose               Verbose output (errors)
  -w, --wordlist string       Path to the wordlist. Set to - to use STDIN.
      --wordlist-offset int   Resume from a given position in the wordlist (defaults to 0)
```

## DIR Mode

```
Usage:
  gobuster dir [flags]

Flags:
  -f, --add-slash                         Append / to each request
  -c, --cookies string                    Cookies to use for the requests
  -d, --discover-backup                   Also search for backup files by appending multiple backup extensions
      --exclude-length ints               Exclude results by content length
  -e, --expanded                          Expanded mode, print full URLs
  -x, --extensions string                 File extension(s) to search for
  -r, --follow-redirect                   Follow redirects
  -H, --headers stringArray               Specify HTTP headers, -H 'Header1: val1' -H 'Header2: val2'
  -l, --include-length                    Include the length of the body in the output
  -k, --no-tls-validation                 Skip TLS certificate verification
  -n, --no-status                         Don't print status codes
  -P, --password string                   Password for Basic Auth
      --proxy string                      Proxy to use for requests [http(s)://host:port]
      --random-agent                      Use a random User-Agent string
      --retry                             Retry on errors
      --retry-attempts int                Number of times to retry (default 3)
  -s, --status-codes string               Positive status codes (default "200,204,301,302,307,401,403,405,500")
  -b, --status-codes-blacklist string     Negative status codes (will override status-codes if set)
      --timeout duration                  HTTP Timeout (default 10s)
  -u, --url string                        The target URL
  -a, --useragent string                  Set the User-Agent string (default "gobuster/3.x")
  -U, --username string                   Username for Basic Auth
  -m, --method string                     HTTP method (default "GET")
```

## DNS Mode

```
Usage:
  gobuster dns [flags]

Flags:
  -d, --domain string      Target domain
  -r, --resolver string    Use custom DNS server (format server.com or server.com:port)
  -c, --show-cname         Show CNAME records
  -i, --show-ips           Show IP addresses
      --timeout duration   DNS resolver timeout (default 1s)
      --wildcard           Force continued operation when wildcard found
```

## VHOST Mode

```
Usage:
  gobuster vhost [flags]

Flags:
      --append-domain              Append main domain to words from wordlist (word.example.com)
  -c, --cookies string             Cookies to use for the requests
      --domain string              Domain to append when using --append-domain
      --exclude-length ints        Exclude results by content length
  -r, --follow-redirect            Follow redirects
  -H, --headers stringArray        Specify HTTP headers, -H 'Header1: val1' -H 'Header2: val2'
  -m, --method string              HTTP method (default "GET")
  -k, --no-tls-validation          Skip TLS certificate verification
  -P, --password string            Password for Basic Auth
      --proxy string               Proxy to use for requests [http(s)://host:port]
      --random-agent               Use a random User-Agent string
      --retry                      Retry on errors
      --retry-attempts int         Number of times to retry (default 3)
      --timeout duration           HTTP Timeout (default 10s)
  -u, --url string                 The target URL
  -a, --useragent string           Set the User-Agent string
  -U, --username string            Username for Basic Auth
```

## FUZZ Mode

```
Usage:
  gobuster fuzz [flags]

Flags:
  -b, --excludestatuscodes string   Negative status codes
      --exclude-length ints         Exclude results by content length
  -r, --follow-redirect             Follow redirects
  -H, --headers stringArray         Specify HTTP headers (can contain FUZZ keyword)
  -m, --method string               HTTP method (default "GET")
  -d, --body string                 Request body (can contain FUZZ keyword)
  -k, --no-tls-validation           Skip TLS certificate verification
  -P, --password string             Password for Basic Auth
      --proxy string                Proxy to use for requests
      --random-agent                Use a random User-Agent string
      --retry                       Retry on errors
      --retry-attempts int          Number of times to retry (default 3)
      --timeout duration            HTTP Timeout (default 10s)
  -u, --url string                  URL containing FUZZ keyword
  -a, --useragent string            Set the User-Agent string
  -U, --username string             Username for Basic Auth
  -c, --cookies string              Cookies (can contain FUZZ keyword)
```

## S3 Mode

```
Usage:
  gobuster s3 [flags]

Flags:
  -m, --maxfiles int    Max files to list when listing buckets (default 5)
```

## GCS Mode

```
Usage:
  gobuster gcs [flags]

Flags:
  -m, --maxfiles int    Max files to list when listing buckets (default 5)
```

## TFTP Mode

```
Usage:
  gobuster tftp [flags]

Flags:
  -s, --server string      Target TFTP server
      --timeout duration   TFTP timeout (default 1s)
```

## Usage Examples

### Directory Mode Examples

```bash
# Basic directory enumeration
gobuster dir -u https://mysite.com/path/to/folder -c 'session=123456' -t 50 -w common-files.txt -x .php,.html

# With custom headers
gobuster dir -u https://mysite.com/ -w words.txt -H "Authorization: Bearer <token>"

# Backup file discovery
gobuster dir -u https://mysite.com/ -w words.txt -d
```

### DNS Mode Examples

```bash
# Basic subdomain enumeration
gobuster dns -d mysite.com -t 50 -w common-names.txt

# With IP display
gobuster dns -d mysite.com -w common-names.txt -i

# With custom DNS server
gobuster dns -d mysite.com -w common-names.txt -r 8.8.8.8
```

### VHOST Mode Examples

```bash
# Basic vhost enumeration
gobuster vhost -u https://mysite.com -w common-vhosts.txt

# With domain appending
gobuster vhost -u https://mysite.com -w common-vhosts.txt --append-domain
```

### FUZZ Mode Examples

```bash
# Fuzz URL parameter
gobuster fuzz -u https://example.com?FUZZ=test -w parameter-names.txt

# Fuzz with POST body
gobuster fuzz -u https://example.com/login -m POST -d "user=FUZZ&pass=test" -w users.txt
```

### S3/GCS Mode Examples

```bash
# S3 bucket enumeration
gobuster s3 -w bucket-names.txt

# GCS bucket enumeration
gobuster gcs -w bucket-names.txt
```

## Patterns

Gobuster supports pattern files to generate wordlist variations:

```bash
# pattern.txt contents:
{GOBUSTER}/v1
{GOBUSTER}/v2
{GOBUSTER}/v3

# Usage
gobuster dir -u https://example.com -w words.txt -p pattern.txt
```

This will test combinations like `api/v1`, `api/v2`, `api/v3` for each word in the wordlist.

## Wordlist from STDIN

```bash
cat wordlist.txt | gobuster dir -u https://example.com -w -
```

## Resources

- **GitHub Repository**: https://github.com/OJ/gobuster
- **Releases**: https://github.com/OJ/gobuster/releases
- **Issues**: https://github.com/OJ/gobuster/issues
- **Wiki**: https://github.com/OJ/gobuster/wiki
