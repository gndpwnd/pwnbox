# Server Hardening

## Linux 

**ports**
```bash
# Block incoming traffic on port 22 
sudo iptables -A INPUT -p tcp --dport 22 -j DROP
sudo iptables -A INPUT -p udp --dport 22 -j DROP 

# Block outgoing traffic on port 22 
sudo iptables -A OUTPUT -p tcp --sport 22 -j DROP
sudo iptables -A INPUT -p udp --dport 22 -j DROP 


# Setting default policies:
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Exceptions to default policy
iptables -A INPUT -p tcp --dport 80 -j ACCEPT       # HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT      # HTTPS
```

**services**

```
```