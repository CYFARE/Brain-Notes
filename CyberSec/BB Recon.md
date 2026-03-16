
# One Liners

## Subdomain Gathering

```bash
D="target.com"; assetfinder "$D" | grep -iE "(\.|^)$D" | anew subsall.txt && cat subsall.txt | httprobe | sed -E 's|https?://||' | sort -u | anew subs.txt
```

### Subdomain Fuzzing (Optional)

- Download 10 Million+ Subdomain Fuzzing Word-list (World's most comprehensive subdomain fuzzing wordlist curated by CYFARE!)
	- https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/FUZZSUBS_CYFARE_1.txt
	- https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/FUZZSUBS_CYFARE_2.txt

```bash
D="target.com"; cat FUZZSUBS_CYFARE_1.txt FUZZSUBS_CYFARE_2.txt | sort -u | ffuf -w -:FUZZ -u "https://FUZZ.$D/" -t 50 -v -mc all -fc 404 -o ffuf_subdomains.txt
```

## Port Mapping

```bash
dnsx -l resolved.txt -a -resp-only -silent | sort -u > ips.txt && uncover -i ips.txt -e shodan,censys,fofa -silent | anew external_ports.txt && naabu -list resolved.txt -p - -exclude-ports 80,443 -silent | anew external_ports.txt && httpx -l external_ports.txt -title -tech -status-code -silent -o live_services.txt && awk -F':' '{ports[$1] = ports[$1] ? ports[$1]","$2 : $2} END {for (ip in ports) system("nmap -sV -sC -Pn -p "ports[ip]" "ip" >> nmap_comprehensive.txt")}' external_ports.txt
```

## Nuclei Scan

```bash
nuclei -ut && nuclei -l subs.txt -t http/cves/ -t http/exposures/ -t http/misconfiguration/ -severity critical,high,medium -o nuclei_results.txt && subzy run --targets resolved.txt
```

Single:
```bash
nuclei -u target.com -t http/cves/ -t http/exposures/ -t http/misconfiguration/ -severity critical,high,medium -o nuclei_results.txt
```

## Archive Hunting

```bash
cat subs.txt | gau | anew allurls.txt && cat allurls.txt | grep -iE "\.(dat|rtf|xls|ppt|sdf|odf|pptx|xlsx|exe|lnk|7z|bin|part|pdb|cgi|crdownload|ini|zipx|bak|torrent|jar|sys|deb|sh|docm|mdb|xla|zip|tar.gz|txt|json|csv|pdf|doc|docx|js|xml|git|pem|bash_history|db|key|tar|log|sql|accdb|dbf|apk|cer|cfg|rar|sln|tmp|dll|iso|swf|conf|ovpn|ps1|kdbx|lst|htaccess|htpasswd|env|yml|yaml|config|properties|inc|old|orig|swo|swp|bkp|tar.bz2|tgz|gz|sql.gz|p12|pfx|crt|der|pub|rsa|id_rsa|sqlite|sqlite3|mdf|ibd|frm|jsp|asp|aspx|php|war|ear|passwd|shadow|md|toml|lock|pac|dump|backup|save|bz2|ldf|rdb|ppk|gpg|pgp|keystore|jks|truststore|zsh_history|history|access|error|bash|bat|cmd|py|rb|pl|ts|java|class|cpp|c|h|cs|go|rs|swift|lua|wps|ods|odt|odp|svn|hg|sudoers|ssh|pwd|rc|so|img|vhd|vmdk)" | anew allfiles.txt
```

## Web Spider

gospider:
```bash
sed 's/^/https:\/\//' subs.txt > urls.txt && gospider -S urls.txt -a -w -r --sitemap -d 10 --no-redirect -t 50 -c 20 -o output && cat output/* | grep -Ff subs.txt | anew spider.txt
```

extract js files:

```bash
awk '/^\[javascript\]/ {print $3}' output/* | anew jsfiles.txt
```

## JS Hunting

```bash
cat jsfiles.txt | while read url; do curl -sL "$url"; done | tee >(grep -aoE "/[a-zA-Z0-9_?&=/.#-]{3,}" | grep -v "^/.$" | sort -u > endpoints.txt) >(grep -ioE "apikey|api_key|token|secret|password|auth|bearer[[:space:]]*[:=][[:space:]]*[a-zA-Z0-9_.-]{10,}|eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}|AKIA[A-Z0-9]{16}" | sort -u > js_secrets.txt)
```

## Vulnerability Fuzzing

Full:
```bash
cat subs.txt | xargs -I % sh -c 'arjun -u % -m GET -oT params.txt; ffuf -u "%/FUZZ" -w /home/klx/Desktop/payloads/FUZZSUBS.txt -e .php,.zip -mc 200,302 -o dir_fuzz.txt'; cat subs.txt | gf lfi | qsreplace "FUZZ" | while read url; do ffuf -u "$url" -w lfi_payloads.txt -mr "root:"; done; cat subs.txt | gf xss | uro | Gxss -p Rxss | dalfox pipe
```

Arjun Optimized:

```bash
arjun -i subs.txt -t 100 -c 500 -T 5 -m GET -oT params.txt
```

Params + LFI + XSS:

```bash
sed -i 's|^|http://|' subs.txt && cat subs.txt | xargs -I % arjun -u % -m GET -oT params.txt; cat subs.txt | gf lfi | qsreplace "FUZZ" | while read url; do ffuf -u "$url" -w /home/klx/Desktop/payloads/lfi_payloads.txt -mr "root:"; done; cat subs.txt | gf xss | uro | Gxss -p Rxss | dalfox pipe
```