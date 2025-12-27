# BloodHound Cypher Queries Reference

A comprehensive guide to BloodHound queries for Active Directory penetration testing, including built-in pre-canned queries, custom Cypher queries for common attack paths, and SharpHound collection tips.

## Table of Contents

- [Built-in Pre-Canned Queries](#built-in-pre-canned-queries)
- [Custom Cypher Queries](#custom-cypher-queries)
  - [Kerberoastable Users](#kerberoastable-users)
  - [AS-REP Roastable Users](#as-rep-roastable-users)
  - [DCSync Rights](#dcsync-rights)
  - [Paths to Domain Admin](#paths-to-domain-admin)
  - [Unconstrained Delegation](#unconstrained-delegation)
  - [Constrained Delegation](#constrained-delegation)
  - [Group Membership Chains](#group-membership-chains)
- [Attack Path Discovery Queries](#attack-path-discovery-queries)
- [SharpHound Collection Tips](#sharphound-collection-tips)
  - [Collection Methods](#collection-methods)
  - [Stealth Options](#stealth-options)
  - [LDAP vs Session Collection](#ldap-vs-session-collection)
- [Query Syntax Reference](#query-syntax-reference)

---

## Built-in Pre-Canned Queries

BloodHound CE includes several pre-built queries accessible from the Analysis tab. Understanding these helps identify quick wins during engagements.

### Domain Information

| Query | Description | Use Case |
|-------|-------------|----------|
| **Find all Domain Admins** | Lists members of Domain Admins group | Identify high-value targets |
| **Find Shortest Paths to Domain Admins** | Shows attack paths from any node to DA | Primary attack path discovery |
| **Map Domain Trusts** | Visualizes trust relationships | Cross-domain attack planning |

### Credential Attacks

| Query | Description | Use Case |
|-------|-------------|----------|
| **Find Kerberoastable Users** | Users with SPNs set | Offline password cracking targets |
| **Find AS-REP Roastable Users** | Users without Kerberos pre-auth | Offline password cracking without auth |
| **Find Principals with DCSync Rights** | Accounts that can replicate DC | Credential dumping capability |

### Privilege Escalation

| Query | Description | Use Case |
|-------|-------------|----------|
| **Find Computers with Unsupported OS** | Legacy systems (Win7, 2008, etc.) | Easy exploitation targets |
| **Find Principals with Local Admin Rights** | Who has admin where | Lateral movement planning |
| **Shortest Path from Owned Principals** | Paths from compromised accounts | Next steps after compromise |

### Delegation Attacks

| Query | Description | Use Case |
|-------|-------------|----------|
| **Find Computers with Unconstrained Delegation** | Servers that cache TGTs | TGT theft opportunities |
| **Find Computers with Constrained Delegation** | Servers with S4U2Proxy rights | Service impersonation attacks |
| **Find Users with Constrained Delegation** | User accounts with delegation | Service impersonation attacks |

---

## Custom Cypher Queries

### Kerberoastable Users

Find users with Service Principal Names (SPNs) that can be targeted for offline password cracking.

```cypher
-- All Kerberoastable users
MATCH (u:User {hasspn:true})
WHERE u.enabled = true
RETURN u.name, u.displayname, u.description, u.serviceprincipalnames
ORDER BY u.pwdlastset
```

```cypher
-- Kerberoastable users with path to Domain Admin
MATCH (u:User {hasspn:true, enabled:true})
MATCH p=shortestPath((u)-[*1..]->(g:Group))
WHERE g.objectid ENDS WITH '-512'
RETURN u.name AS User, g.name AS TargetGroup, length(p) AS PathLength
ORDER BY PathLength
```

```cypher
-- Kerberoastable users that are members of high-value groups
MATCH (u:User {hasspn:true, enabled:true})-[:MemberOf*1..]->(g:Group)
WHERE g.highvalue = true
RETURN DISTINCT u.name AS User, collect(DISTINCT g.name) AS HighValueGroups
```

```cypher
-- Kerberoastable users with weak password indicators (old passwords)
MATCH (u:User {hasspn:true, enabled:true})
WHERE u.pwdlastset < (datetime().epochseconds - (365 * 24 * 60 * 60))
RETURN u.name, u.description,
       datetime({epochSeconds: toInteger(u.pwdlastset)}) AS PasswordLastSet
ORDER BY u.pwdlastset
```

```cypher
-- Kerberoastable users with admin rights on computers
MATCH (u:User {hasspn:true, enabled:true})-[:AdminTo]->(c:Computer)
RETURN u.name AS User, collect(c.name) AS AdminOnComputers
```

### AS-REP Roastable Users

Find users that don't require Kerberos pre-authentication, allowing offline password attacks without any authentication.

```cypher
-- All AS-REP roastable users
MATCH (u:User {dontreqpreauth:true, enabled:true})
RETURN u.name, u.displayname, u.description
```

```cypher
-- AS-REP roastable users with path to Domain Admin
MATCH (u:User {dontreqpreauth:true, enabled:true})
MATCH p=shortestPath((u)-[*1..]->(g:Group))
WHERE g.objectid ENDS WITH '-512'
RETURN u.name AS User, length(p) AS HopsToDA
ORDER BY HopsToDA
```

```cypher
-- AS-REP roastable users that are also Kerberoastable
MATCH (u:User {dontreqpreauth:true, hasspn:true, enabled:true})
RETURN u.name, u.description, u.serviceprincipalnames
```

```cypher
-- AS-REP roastable users with high-value group membership
MATCH (u:User {dontreqpreauth:true, enabled:true})-[:MemberOf*1..]->(g:Group {highvalue:true})
RETURN DISTINCT u.name AS User, collect(g.name) AS HighValueGroups
```

### DCSync Rights

Find principals that can perform DCSync attacks to dump all domain credentials.

```cypher
-- All principals with DCSync rights (GetChanges AND GetChangesAll)
MATCH (n)-[:GetChanges]->(d:Domain)
MATCH (n)-[:GetChangesAll]->(d)
RETURN n.name AS Principal, n.objectid, labels(n) AS Type
```

```cypher
-- Non-default principals with DCSync rights
MATCH (n)-[:GetChanges]->(d:Domain)
MATCH (n)-[:GetChangesAll]->(d)
WHERE NOT n.objectid ENDS WITH '-516'  -- Domain Controllers
  AND NOT n.objectid ENDS WITH '-519'  -- Enterprise Admins
  AND NOT n.objectid ENDS WITH '-512'  -- Domain Admins
  AND NOT n.objectid ENDS WITH '-498'  -- Enterprise Read-Only DCs
RETURN n.name AS Principal, labels(n) AS Type, d.name AS Domain
```

```cypher
-- Users with DCSync via group membership
MATCH (u:User)-[:MemberOf*1..]->(g:Group)-[:GetChanges]->(d:Domain)
MATCH (g)-[:GetChangesAll]->(d)
RETURN u.name AS User, g.name AS ViaGroup, d.name AS Domain
```

```cypher
-- Computers with DCSync rights (unusual)
MATCH (c:Computer)-[:GetChanges]->(d:Domain)
MATCH (c)-[:GetChangesAll]->(d)
WHERE NOT c.objectid ENDS WITH '-516'
RETURN c.name AS Computer, d.name AS Domain
```

### Paths to Domain Admin

Find attack paths to Domain Admins from various starting points.

```cypher
-- Shortest paths from owned users to Domain Admins
MATCH (u:User {owned:true})
MATCH (g:Group)
WHERE g.objectid ENDS WITH '-512'
MATCH p=shortestPath((u)-[*1..]->(g))
RETURN p
```

```cypher
-- Shortest paths from all users to Domain Admin
MATCH (u:User {enabled:true})
MATCH (g:Group)
WHERE g.objectid ENDS WITH '-512'
MATCH p=shortestPath((u)-[*1..]->(g))
WHERE length(p) > 1
RETURN u.name AS User, length(p) AS PathLength
ORDER BY PathLength
LIMIT 50
```

```cypher
-- Paths to Domain Admin via specific edge types
MATCH p=shortestPath((u:User {owned:true})-[:MemberOf|AdminTo|HasSession|CanRDP|CanPSRemote|ExecuteDCOM|AllowedToDelegate|AddMember|ForceChangePassword|GenericAll|GenericWrite|Owns|WriteDacl|WriteOwner*1..]->(g:Group))
WHERE g.objectid ENDS WITH '-512'
RETURN p
```

```cypher
-- All Domain Admins (direct and nested)
MATCH (u)-[:MemberOf*1..]->(g:Group)
WHERE g.objectid ENDS WITH '-512'
RETURN DISTINCT u.name AS DomainAdmin, labels(u) AS Type
```

```cypher
-- Paths from Domain Users to Domain Admin
MATCH (du:Group)
WHERE du.objectid ENDS WITH '-513'  -- Domain Users
MATCH (da:Group)
WHERE da.objectid ENDS WITH '-512'  -- Domain Admins
MATCH p=shortestPath((du)-[*1..]->(da))
RETURN p
```

```cypher
-- Find users with direct path to DA (1-2 hops)
MATCH p=shortestPath((u:User {enabled:true})-[*1..2]->(g:Group))
WHERE g.objectid ENDS WITH '-512'
RETURN u.name AS User, length(p) AS Hops, [rel in relationships(p) | type(rel)] AS EdgeTypes
```

### Unconstrained Delegation

Find computers and users that can impersonate any user via TGT caching.

```cypher
-- All computers with unconstrained delegation (excluding DCs)
MATCH (c:Computer {unconstraineddelegation:true})
WHERE NOT c.objectid ENDS WITH '-516'
RETURN c.name, c.operatingsystem, c.description
```

```cypher
-- Unconstrained delegation computers with paths from owned users
MATCH (u:User {owned:true})
MATCH (c:Computer {unconstraineddelegation:true})
WHERE NOT c.objectid ENDS WITH '-516'
MATCH p=shortestPath((u)-[*1..]->(c))
RETURN p
```

```cypher
-- Users that can admin unconstrained delegation computers
MATCH (c:Computer {unconstraineddelegation:true})
WHERE NOT c.objectid ENDS WITH '-516'
MATCH (u:User)-[:AdminTo]->(c)
RETURN u.name AS User, c.name AS UnconstrainedDelegationComputer
```

```cypher
-- Unconstrained delegation with high-value paths
MATCH (c:Computer {unconstraineddelegation:true})
WHERE NOT c.objectid ENDS WITH '-516'
MATCH (u:User {enabled:true})-[:AdminTo]->(c)
MATCH p=shortestPath((u)-[*1..]->(g:Group {highvalue:true}))
RETURN u.name, c.name, g.name
```

```cypher
-- Users with unconstrained delegation (rare, high priority)
MATCH (u:User {unconstraineddelegation:true, enabled:true})
RETURN u.name, u.description, u.displayname
```

### Constrained Delegation

Find principals with constrained delegation that can impersonate users to specific services.

```cypher
-- All computers with constrained delegation
MATCH (c:Computer)
WHERE c.allowedtodelegate IS NOT NULL
RETURN c.name, c.allowedtodelegate
```

```cypher
-- All users with constrained delegation
MATCH (u:User {enabled:true})
WHERE u.allowedtodelegate IS NOT NULL
RETURN u.name, u.allowedtodelegate, u.description
```

```cypher
-- Constrained delegation to interesting services (LDAP, CIFS, HTTP)
MATCH (n)
WHERE n.allowedtodelegate IS NOT NULL
UNWIND n.allowedtodelegate AS delegation
WHERE delegation CONTAINS 'ldap' OR delegation CONTAINS 'cifs' OR delegation CONTAINS 'http'
RETURN n.name AS Principal, labels(n) AS Type, delegation AS DelegationTarget
```

```cypher
-- Constrained delegation targeting Domain Controllers
MATCH (n)
WHERE n.allowedtodelegate IS NOT NULL
UNWIND n.allowedtodelegate AS delegation
MATCH (dc:Computer)
WHERE dc.objectid ENDS WITH '-516'
  AND delegation CONTAINS split(dc.name, '.')[0]
RETURN n.name AS Principal, delegation AS DelegationTo, dc.name AS DomainController
```

```cypher
-- Resource-Based Constrained Delegation (RBCD) - computers allowing delegation
MATCH (c:Computer)
WHERE c.allowedtoact IS NOT NULL
RETURN c.name AS Computer, c.allowedtoact AS AllowedToActOnBehalfOf
```

```cypher
-- Principals that can write msDS-AllowedToActOnBehalfOfOtherIdentity
MATCH (n)-[:WriteAccountRestrictions]->(c:Computer)
RETURN n.name AS Principal, labels(n) AS Type, c.name AS TargetComputer
```

```cypher
-- Chain: owned user -> constrained delegation -> DC
MATCH (u:User {owned:true})
MATCH (n)
WHERE n.allowedtodelegate IS NOT NULL
UNWIND n.allowedtodelegate AS delegation
WHERE delegation CONTAINS 'ldap' OR delegation CONTAINS 'cifs'
MATCH p=shortestPath((u)-[*1..]->(n))
RETURN u.name AS OwnedUser, n.name AS DelegationPrincipal, delegation
```

### Group Membership Chains

Analyze group nesting and membership relationships.

```cypher
-- Find deeply nested group chains
MATCH p=(u:User)-[:MemberOf*1..10]->(g:Group)
WHERE g.highvalue = true
RETURN u.name AS User, length(p) AS NestingDepth,
       [n in nodes(p) | n.name] AS MembershipChain
ORDER BY NestingDepth DESC
LIMIT 50
```

```cypher
-- Groups with most members (attack surface)
MATCH (n)-[:MemberOf]->(g:Group)
RETURN g.name AS Group, count(n) AS MemberCount, labels(n) AS MemberTypes
ORDER BY MemberCount DESC
LIMIT 25
```

```cypher
-- Users in multiple high-value groups
MATCH (u:User)-[:MemberOf*1..]->(g:Group {highvalue:true})
WITH u, count(DISTINCT g) AS hvGroupCount, collect(DISTINCT g.name) AS groups
WHERE hvGroupCount > 1
RETURN u.name, hvGroupCount, groups
ORDER BY hvGroupCount DESC
```

```cypher
-- Circular group membership (rare but interesting)
MATCH p=(g:Group)-[:MemberOf*1..10]->(g)
RETURN p
```

```cypher
-- Groups that grant admin rights
MATCH (g:Group)-[:AdminTo]->(c:Computer)
RETURN g.name AS Group, count(c) AS AdminOnCount
ORDER BY AdminOnCount DESC
```

```cypher
-- Users who are members of groups they shouldn't be (orphan memberships)
MATCH (u:User {enabled:false})-[:MemberOf*1..]->(g:Group {highvalue:true})
RETURN u.name AS DisabledUser, collect(g.name) AS HighValueGroups
```

```cypher
-- Group membership chains from Domain Users
MATCH (du:Group)-[:MemberOf*1..5]->(g:Group)
WHERE du.objectid ENDS WITH '-513'
RETURN du.name, [g.name] AS ChainToGroup, length((du)-[:MemberOf*1..5]->(g)) AS Hops
ORDER BY Hops DESC
```

---

## Attack Path Discovery Queries

### ACL-Based Attack Paths

```cypher
-- Users with GenericAll on other users (password reset, etc.)
MATCH (u:User)-[:GenericAll]->(target:User)
WHERE u.enabled = true AND target.enabled = true
RETURN u.name AS Attacker, target.name AS Target
```

```cypher
-- Principals that can modify group membership
MATCH (n)-[:AddMember|GenericAll|GenericWrite|WriteOwner|WriteDacl]->(g:Group {highvalue:true})
RETURN n.name AS Principal, labels(n) AS Type, g.name AS TargetGroup,
       [r in [(n)-[r]->(g) | type(r)]] AS Edges
```

```cypher
-- WriteDACL chains to high-value targets
MATCH p=(u:User {owned:true})-[:WriteDacl*1..3]->(target)
WHERE target.highvalue = true
RETURN p
```

```cypher
-- Principals that own high-value objects
MATCH (n)-[:Owns]->(target {highvalue:true})
RETURN n.name AS Owner, labels(n) AS OwnerType, target.name AS OwnedObject
```

### Session-Based Attack Paths

```cypher
-- Find computers where Domain Admins have sessions
MATCH (da)-[:MemberOf*1..]->(g:Group)
WHERE g.objectid ENDS WITH '-512'
MATCH (c:Computer)-[:HasSession]->(da)
RETURN c.name AS Computer, da.name AS DomainAdmin
```

```cypher
-- Session-based paths from owned to high-value
MATCH (u:User {owned:true})
MATCH (c:Computer)-[:HasSession]->(hv)
WHERE hv.highvalue = true
MATCH p=shortestPath((u)-[*1..]->(c))
RETURN p
```

```cypher
-- Computers with sessions from multiple privileged users
MATCH (c:Computer)-[:HasSession]->(u:User)
MATCH (u)-[:MemberOf*1..]->(g:Group {highvalue:true})
WITH c, count(DISTINCT u) AS PrivUserSessions
WHERE PrivUserSessions > 1
RETURN c.name, PrivUserSessions
ORDER BY PrivUserSessions DESC
```

### GPO Attack Paths

```cypher
-- GPOs that affect Domain Controllers
MATCH (g:GPO)-[:GpLink]->(ou:OU)-[:Contains*1..]->(dc:Computer)
WHERE dc.objectid ENDS WITH '-516'
RETURN g.name AS GPO, ou.name AS LinkedOU, dc.name AS DomainController
```

```cypher
-- Principals that can modify GPOs affecting high-value targets
MATCH (n)-[:GenericAll|GenericWrite|WriteOwner|WriteDacl]->(g:GPO)
MATCH (g)-[:GpLink]->(container)-[:Contains*1..]->(target {highvalue:true})
RETURN n.name AS Principal, g.name AS GPO, target.name AS AffectedTarget
```

### Cross-Domain Attacks

```cypher
-- Foreign group memberships (cross-domain)
MATCH (u)-[:MemberOf]->(g:Group)
WHERE NOT u.domain = g.domain
RETURN u.name AS ForeignPrincipal, u.domain AS FromDomain,
       g.name AS Group, g.domain AS ToDomain
```

```cypher
-- Domain trust relationships
MATCH (d1:Domain)-[r]->(d2:Domain)
RETURN d1.name AS SourceDomain, type(r) AS TrustType, d2.name AS TargetDomain
```

---

## SharpHound Collection Tips

### Collection Methods

SharpHound supports various collection methods optimized for different scenarios and stealth requirements.

| Method | Description | Noise Level | Data Collected |
|--------|-------------|-------------|----------------|
| `Default` | Standard collection | Medium | Groups, LocalAdmin, Session, ACL, Trusts |
| `All` | Everything | High | All available collection methods |
| `DCOnly` | DC queries only | Low | Groups, ACL, Trusts, ObjectProps, Containers |
| `Session` | Session data only | Medium-High | User sessions on computers |
| `LoggedOn` | Logged on users | Medium | Currently logged on users |
| `Group` | Group memberships | Low | Group membership data |
| `LocalAdmin` | Local admin info | Medium | Local admin relationships |
| `RDP` | RDP users | Medium | Remote Desktop Users group |
| `DCOM` | DCOM users | Medium | Distributed COM Users |
| `PSRemote` | PS Remoting users | Medium | Remote Management Users |
| `ACL` | ACL data | Low | Access Control Lists |
| `Trusts` | Domain trusts | Low | Trust relationships |
| `GPOLocalGroup` | GPO local groups | Low | GPO-defined local groups |
| `Container` | Container hierarchy | Low | OU and Container structure |
| `ObjectProps` | Object properties | Low | User/Computer attributes |
| `ComputerOnly` | Computer info only | Medium | Computer-related data |
| `LocalGroup` | Local groups | Medium | All local group memberships |
| `SPNTargets` | SPN target info | Low | Services for delegation attacks |
| `CARegistry` | ADCS Certificate info | Low | Certificate Authority data |
| `DCRegistry` | DC registry info | Low | DC configuration |
| `CertServices` | Certificate Services | Low | PKI/ADCS enumeration |

### Collection Commands

```powershell
# Standard all-inclusive collection
.\SharpHound.exe -c All

# Multiple specific collection methods
.\SharpHound.exe -c Group,LocalAdmin,Session

# Collect with domain specification
.\SharpHound.exe -c All -d corp.local

# Collection with output directory
.\SharpHound.exe -c All --outputdirectory C:\Temp

# Collection with custom filename prefix
.\SharpHound.exe -c All --outputprefix engagement_name

# Collection excluding Domain Controllers
.\SharpHound.exe -c All --excludedcs

# Collection with LDAP filter
.\SharpHound.exe -c All --ldapfilter "(servicePrincipalName=*)"

# Target specific OUs
.\SharpHound.exe -c All --ou "OU=Workstations,DC=corp,DC=local"

# Collect Certificate Services info (ADCS attacks)
.\SharpHound.exe -c All,CertServices
```

### Stealth Options

#### Low-Noise Collection

For engagements requiring stealth, use these approaches:

```powershell
# DCOnly - Queries Domain Controllers only
# No direct computer connections, minimal network noise
.\SharpHound.exe -c DCOnly

# DCOnly with specific domain
.\SharpHound.exe -c DCOnly -d target.local

# Group collection only (very quiet)
.\SharpHound.exe -c Group,ACL,Trusts

# Disable Kerberos (use NTLM, may be quieter in some environments)
.\SharpHound.exe -c DCOnly --disablekerbsigning
```

#### Timing and Throttling

```powershell
# Add jitter to requests (random delay 0-500ms)
.\SharpHound.exe -c All --jitter 50

# Throttle requests (delay between operations)
.\SharpHound.exe -c All --throttle 1000

# Limit parallel threads
.\SharpHound.exe -c All --threads 5

# Combined stealth options
.\SharpHound.exe -c DCOnly --jitter 30 --throttle 500 --threads 3
```

#### Credential Handling

```powershell
# Use alternate credentials (for cross-trust or different user)
.\SharpHound.exe -c All --ldapusername svc_scan --ldappassword 'P@ssw0rd!'

# Use specific Domain Controller
.\SharpHound.exe -c All --domaincontroller dc01.corp.local

# Override domain discovery
.\SharpHound.exe -c All -d corp.local --domaincontroller 10.10.10.1

# Secure LDAP (LDAPS)
.\SharpHound.exe -c All --secureldap
```

### LDAP vs Session Collection

Understanding the difference between LDAP and Session collection is crucial for planning your collection strategy.

#### LDAP Collection (Low-Medium Noise)

LDAP-based collection queries Active Directory via LDAP protocol, typically to Domain Controllers.

**What it collects:**
- Group memberships
- User/Computer attributes
- ACLs and permissions
- Trust relationships
- GPO information
- Container/OU hierarchy

**Characteristics:**
- Queries Domain Controllers only
- Uses standard LDAP queries
- Relatively quiet
- May be logged in DC security logs
- Works without admin rights
- Can be done with DCOnly method

```powershell
# Pure LDAP collection
.\SharpHound.exe -c Group,ACL,Trusts,Container,ObjectProps,GPOLocalGroup
```

#### Session Collection (Higher Noise)

Session collection connects to individual computers to enumerate logged-on users and local group memberships.

**What it collects:**
- Active user sessions (who is logged in where)
- Local group memberships
- Local administrator relationships

**Characteristics:**
- Connects to each computer directly
- Uses NetSessionEnum, NetWkstaUserEnum, or Registry queries
- Higher network visibility
- May trigger security tools
- Requires network access to workstations/servers
- Best results when run multiple times

```powershell
# Session-only collection
.\SharpHound.exe -c Session

# Session looping (collect sessions over time for better coverage)
.\SharpHound.exe -c Session --loop --loopduration 02:00:00

# Session collection with loop interval
.\SharpHound.exe -c Session --loop --loopduration 04:00:00 --loopinterval 00:05:00

# Privileged session collection (requires admin, more accurate)
.\SharpHound.exe -c Session --privileged
```

### Collection Strategy Recommendations

#### Initial Reconnaissance (Stealth)

```powershell
# First pass - minimal noise
.\SharpHound.exe -c DCOnly -d corp.local
```

#### Comprehensive Collection

```powershell
# Full collection for complete graph
.\SharpHound.exe -c All -d corp.local

# Full collection with ADCS data
.\SharpHound.exe -c All,CertServices -d corp.local
```

#### Session Hunting

```powershell
# Run during business hours for best session data
.\SharpHound.exe -c Session --loop --loopduration 08:00:00 --loopinterval 00:15:00

# Combine with previous collection
.\SharpHound.exe -c Session --append
```

#### Cross-Domain Collection

```powershell
# Collect from trusted domain
.\SharpHound.exe -c All -d trusted.local --domaincontroller dc.trusted.local

# Use credentials from parent domain
.\SharpHound.exe -c All -d child.corp.local --ldapusername admin@corp.local --ldappassword 'P@ss'
```

---

## Query Syntax Reference

### Node Types

| Label | Description |
|-------|-------------|
| `User` | User accounts |
| `Computer` | Computer accounts |
| `Group` | Security groups |
| `Domain` | Domain objects |
| `GPO` | Group Policy Objects |
| `OU` | Organizational Units |
| `Container` | AD Containers |

### Common Node Properties

| Property | Description | Example |
|----------|-------------|---------|
| `name` | Object name | `ADMIN@CORP.LOCAL` |
| `enabled` | Account enabled | `true/false` |
| `owned` | Marked as owned | `true/false` |
| `highvalue` | High-value target | `true/false` |
| `hasspn` | Has SPN (Kerberoastable) | `true/false` |
| `dontreqpreauth` | AS-REP roastable | `true/false` |
| `unconstraineddelegation` | Unconstrained delegation | `true/false` |
| `allowedtodelegate` | Constrained delegation targets | `['cifs/server']` |
| `objectid` | SID | `S-1-5-21-...` |
| `pwdlastset` | Password last set epoch | `1703030400` |
| `lastlogon` | Last logon epoch | `1703030400` |

### Edge Types (Relationships)

| Edge | Description |
|------|-------------|
| `MemberOf` | Group membership |
| `AdminTo` | Local admin rights |
| `HasSession` | User session on computer |
| `CanRDP` | RDP access |
| `CanPSRemote` | PowerShell remoting |
| `ExecuteDCOM` | DCOM execution rights |
| `AllowedToDelegate` | Delegation rights |
| `AddMember` | Can add group members |
| `ForceChangePassword` | Can reset password |
| `GenericAll` | Full control |
| `GenericWrite` | Write properties |
| `Owns` | Object owner |
| `WriteDacl` | Can modify DACL |
| `WriteOwner` | Can change owner |
| `GetChanges` | DCSync (partial) |
| `GetChangesAll` | DCSync (complete) |
| `Contains` | Container hierarchy |
| `GpLink` | GPO linked to OU |
| `TrustedBy` | Domain trust |
| `WriteAccountRestrictions` | Can set RBCD |

### Useful SID Suffixes

| Suffix | Group |
|--------|-------|
| `-512` | Domain Admins |
| `-513` | Domain Users |
| `-514` | Domain Guests |
| `-515` | Domain Computers |
| `-516` | Domain Controllers |
| `-518` | Schema Admins |
| `-519` | Enterprise Admins |
| `-544` | Administrators (local) |

---

## References

- [BloodHound CE Documentation](https://bloodhound.specterops.io/)
- [BloodHound CE GitHub](https://github.com/SpecterOps/BloodHound)
- [SharpHound GitHub](https://github.com/BloodHoundAD/SharpHound)
- [Cypher Query Language](https://neo4j.com/docs/cypher-manual/current/)
- [BloodHound Cypher Cheatsheet](https://hausec.com/2019/09/09/bloodhound-cypher-cheatsheet/)
