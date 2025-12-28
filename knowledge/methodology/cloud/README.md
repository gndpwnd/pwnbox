---
title: Cloud Penetration Testing Methodology
category: methodology
tags:
  - cloud
  - aws
  - azure
  - gcp
  - kubernetes
  - pentesting
last_updated: 2025-12-28
---

# Cloud Penetration Testing Methodology

## Table of Contents

- [Overview](#overview)
- [Cloud Security Concepts](#cloud-security-concepts)
  - [Shared Responsibility Model](#shared-responsibility-model)
  - [Identity and Access Management (IAM)](#identity-and-access-management-iam)
- [Platform-Specific Documentation](#platform-specific-documentation)
- [Common Attack Patterns](#common-attack-patterns)
- [Essential Tools](#essential-tools)
- [Reconnaissance Workflow](#reconnaissance-workflow)

---

## Overview

Cloud penetration testing focuses on identifying security weaknesses in cloud infrastructure, services, and configurations. Unlike traditional network pentesting, cloud assessments require understanding of provider-specific services, APIs, and security models.

**Key Differences from Traditional Pentesting:**

| Aspect | Traditional | Cloud |
|--------|-------------|-------|
| Scope | Network/Host-based | API/Service-based |
| Access | Direct network access | API credentials/tokens |
| Enumeration | Port scanning | Service enumeration via APIs |
| Privilege Escalation | OS-level | IAM policy abuse |
| Data Exfiltration | Network-based | Storage service access |

---

## Cloud Security Concepts

### Shared Responsibility Model

Understanding who is responsible for what security controls:

| Layer | IaaS | PaaS | SaaS |
|-------|------|------|------|
| Data | Customer | Customer | Customer |
| Applications | Customer | Customer | Provider |
| Runtime | Customer | Provider | Provider |
| OS | Customer | Provider | Provider |
| Virtualization | Provider | Provider | Provider |
| Infrastructure | Provider | Provider | Provider |

### Identity and Access Management (IAM)

Core IAM concepts across cloud providers:

- **Principals**: Users, groups, roles, service accounts
- **Policies**: JSON/YAML documents defining permissions
- **Resources**: Cloud services and objects
- **Actions**: Operations that can be performed
- **Conditions**: Contextual restrictions on permissions

**Common IAM Weaknesses:**

1. Overly permissive policies (wildcards)
2. Unused credentials with excessive permissions
3. Cross-account trust misconfigurations
4. Missing MFA requirements
5. Long-lived access keys

---

## Platform-Specific Documentation

| Platform | Documentation | Focus Areas |
|----------|---------------|-------------|
| [AWS](aws.md) | Amazon Web Services | S3, IAM, Lambda, EC2, IMDS |
| [Azure](azure.md) | Microsoft Azure | Azure AD, Managed Identity, Key Vault |
| [GCP](gcp.md) | Google Cloud Platform | IAM, GCS, Compute Engine |
| [Kubernetes](kubernetes.md) | Container Orchestration | RBAC, Secrets, Pod Security |

---

## Common Attack Patterns

### 1. Credential Discovery
- Environment variables
- Metadata services (169.254.169.254)
- Configuration files
- Version control history

### 2. Storage Misconfiguration
- Public buckets/blobs
- Overly permissive ACLs
- Missing encryption

### 3. Privilege Escalation
- Policy attachment abuse
- Role assumption chains
- Service account impersonation

### 4. Lateral Movement
- Cross-account access
- VPC peering exploitation
- Shared service abuse

### 5. Data Exfiltration
- Storage service access
- Database snapshots
- Secrets manager enumeration

---

## Essential Tools

### Multi-Cloud Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| ScoutSuite | Multi-cloud security auditing | `pip install scoutsuite` |
| Prowler | AWS/Azure/GCP security assessment | `pip install prowler` |
| CloudSploit | Cloud security scanning | `npm install -g cloudsploit` |

### AWS-Specific Tools

| Tool | Purpose |
|------|---------|
| [Pacu](https://github.com/RhinoSecurityLabs/pacu) | AWS exploitation framework |
| [enumerate-iam](https://github.com/andresriancho/enumerate-iam) | IAM permission enumeration |
| [aws-cli](https://aws.amazon.com/cli/) | Official AWS CLI |

### Azure-Specific Tools

| Tool | Purpose |
|------|---------|
| [AADInternals](https://github.com/Gerenios/AADInternals) | Azure AD toolkit |
| [ROADtools](https://github.com/dirkjanm/ROADtools) | Azure AD exploration |
| [MicroBurst](https://github.com/NetSPI/MicroBurst) | Azure security toolkit |

### GCP-Specific Tools

| Tool | Purpose |
|------|---------|
| [gcloud](https://cloud.google.com/sdk/gcloud) | Official GCP CLI |
| [gcpwn](https://github.com/NetSPI/gcpwn) | GCP exploitation toolkit |

---

## Reconnaissance Workflow

```
1. Identify Cloud Provider
   └── DNS records, SSL certs, response headers

2. Enumerate External Assets
   └── Public buckets, exposed APIs, login portals

3. Obtain Initial Access
   └── Leaked credentials, SSRF, phishing

4. Enumerate Internal Resources
   └── IAM, services, networking

5. Privilege Escalation
   └── Policy abuse, role chaining

6. Lateral Movement
   └── Cross-account, cross-service

7. Data Access
   └── Storage, databases, secrets
```

---

## Quick Reference Commands

```bash
# AWS - Check caller identity
aws sts get-caller-identity

# Azure - Show current account
az account show

# GCP - List active account
gcloud auth list

# Kubernetes - Current context
kubectl config current-context
```

---

## See Also

- [aws.md](aws.md) - AWS Attack Patterns
- [azure.md](azure.md) - Azure Attack Patterns
- [gcp.md](gcp.md) - GCP Attack Patterns
- [kubernetes.md](kubernetes.md) - Kubernetes Security
