---
title: BloodHound
category: tool
subcategory: active-directory
tags:
  - active-directory
  - enumeration
  - attack-path
  - graph-database
  - sharphound
last_updated: 2025-12-27
---

# BloodHound

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
  - [Data Collection with SharpHound](#data-collection-with-sharphound)
  - [Importing Data](#importing-data)
  - [Common Queries](#common-queries)
- [Documentation Files](#documentation-files)

## Overview

BloodHound is an Active Directory relationship visualizer that uses graph theory to reveal hidden attack paths. It maps relationships between AD objects (users, groups, computers, GPOs) to identify privilege escalation routes to Domain Admin.

**Note:** BloodHound Legacy (v4) has been deprecated. Use [BloodHound Community Edition](https://github.com/SpecterOps/BloodHound) instead.

Key capabilities:
- Visualize AD trust relationships and permissions
- Identify shortest paths to high-value targets
- Discover unintended privilege escalation paths
- Map Kerberos delegation configurations
- Analyze Group Policy relationships

## Installation

### BloodHound Community Edition (Docker)

```bash
# Clone the repository
git clone https://github.com/SpecterOps/BloodHound.git
cd BloodHound

# Start with Docker Compose
docker compose up -d

# Access web interface at https://localhost:8080
# Default credentials shown in container logs
docker compose logs bloodhound | grep "Initial Password"
```

### SharpHound Collector

Download from [BloodHound releases](https://github.com/SpecterOps/BloodHound/releases) or use the built-in collector in BHCE.

## Quick Start

### Data Collection with SharpHound

```powershell
# Basic collection (all methods)
.\SharpHound.exe -c All

# Stealth collection (no computer connections)
.\SharpHound.exe -c DCOnly

# Targeted collection with specific domain
.\SharpHound.exe -c All -d target.local

# Collection with alternate credentials
.\SharpHound.exe -c All -d target.local --ldapusername user --ldappassword pass

# Session collection only (run multiple times for coverage)
.\SharpHound.exe -c Session --loop --loopduration 02:00:00
```

Collection methods:
- `Default` - Group membership, local admins, sessions, ACLs
- `All` - All collection methods
- `DCOnly` - Data from Domain Controllers only (stealthier)
- `Session` - User session data
- `ACL` - ACL data for all objects
- `Trusts` - Domain trust mappings

### Importing Data

1. Log into BloodHound CE web interface
2. Navigate to **File Ingest** or drag-and-drop
3. Upload the generated `.zip` file from SharpHound
4. Wait for ingestion to complete

### Common Queries

Built-in queries (Analysis tab):
- **Find Shortest Paths to Domain Admins** - Primary attack path discovery
- **Find Principals with DCSync Rights** - Identify DCSync-capable accounts
- **Find Computers with Unsupported OS** - Legacy system discovery
- **Find Kerberoastable Users** - SPN-enabled service accounts
- **Find AS-REP Roastable Users** - Accounts without pre-auth

Custom Cypher queries:
```cypher
# Shortest path from owned user to Domain Admin
MATCH p=shortestPath((u:User {owned:true})-[*1..]->(g:Group {name:"DOMAIN ADMINS@DOMAIN.LOCAL"}))
RETURN p

# Find all Kerberoastable users with path to DA
MATCH (u:User {hasspn:true})
MATCH p=shortestPath((u)-[*1..]->(g:Group {name:"DOMAIN ADMINS@DOMAIN.LOCAL"}))
RETURN p

# Computers where Domain Users have local admin
MATCH (g:Group {name:"DOMAIN USERS@DOMAIN.LOCAL"})-[:AdminTo]->(c:Computer)
RETURN c.name
```

## Documentation Files

| File | Description |
|------|-------------|
| [queries.md](queries.md) | Comprehensive Cypher queries and SharpHound collection guide |
| [official_docs.md](official_docs.md) | Official documentation reference |
| [github.md](github.md) | GitHub repository information |

## References

- [BloodHound CE GitHub](https://github.com/SpecterOps/BloodHound)
- [BloodHound CE Documentation](https://bloodhound.specterops.io/)
- [Community Edition Quickstart](https://bloodhound.specterops.io/get-started/quickstart/community-edition-quickstart)
