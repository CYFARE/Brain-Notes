
# One Liners

## IP Enumeration

```bash
D="target.com"; { asnmap -d "$D" | dnsx -silent; curl -s "https://urlscan.io/api/v1/search/?q=domain:$D&size=10000" | jq -r '.results[]?.page?.ip//empty'; curl -s "https://www.virustotal.com/vtapi/v2/domain/report?domain=$D&apikey=[key]" | jq -r '..|.ip_address?//empty'; curl -s "https://subdomainfinder.c99.nl/scans/2025-12-29/$D"; } | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u > ip.txt
```

## Subdomain Gathering

```bash
D="target.com"; { subfinder -d "$D" -all -recursive; findomain -t "$D"; amass enum -passive -d "$D" -norecursive -noalts; Subenum -d "$D"; chaos -d "$D"; github-subdomain -d "$D"; assetfinder --subs-only "$D"; echo "$D" | subdog; tldfinder -d "$D"; bbot -t "$D" -f subdomain-enum; oneforall --target "$D" --brute False run; curl -s "https://crt.sh/?q=%25.$D&output=json" | jq -r '.[].name_value? // empty' | sed 's/\*\.//g'; curl -s -H "APIKEY: <KEY>" "https://api.securitytrails.com/v1/domain/$D/subdomains" | jq -r '.subdomains[]? // empty' | awk -v d="$D" '{print $1"."d}'; } 2>/dev/null | grep -Eo "([a-zA-Z0-9._-]+\.)+$D" | sort -u > allsubs.txt && puredns resolve -r resolvers.txt -w resolved.txt < allsubs.txt && subfinder -dL resolved.txt -all -recursive -o subfinder_recursive.txt
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
nuclei -ut && nuclei -l live_web.txt -t cves/ -t exposures/ -t misconfiguration/ -severity critical,high,medium -o nuclei_results.txt && subzy run --targets resolved.txt
```

## Archive Hunting

```bash
D="target.com"; waymore -i "$D" -mode U -oU urls.txt && katana -u "$D" -kf robotstxt,sitemapxml -o katana_urls.txt && cat urls.txt katana_urls.txt 2>/dev/null | sort -u > allurls.txt && grep -iE "(.*\.dat$|.*\.rtf$|.*\.xls$|.*\.ppt$|.*\.sdf$|.*\.odf$|.*\.pptx$|.*\.xlsx$|.*\.exe$|.*\.lnk$|.*\.7z$|.*\.bin$|.*\.part$|.*\.pdb$|.*\.cgi$|.*\.crdownload$|.*\.ini$|.*\.zipx$|.*\.bak$|.*\.torrent$|.*\.jar$|.*\.sys$|.*\.deb$|.*\.sh$|.*\.docm$|.*\.mdb$|.*\.xla$|.*\.zip$|.*\.tar\.gz$|.*\.txt$|.*\.json$|.*\.csv$|.*\.pdf$|.*\.doc$|.*\.docx$|.*\.js$|.*\.xml$|.*\.GIT$|.*\.git$|.*\.pem$|.*\.bash_history$|.*\.db$|.*\.key$|.*\.tar$|.*\.log$|.*\.sql$|.*\.accdb$|.*\.dbf$|.*\.apk$|.*\.cer$|.*\.cfg$|.*\.rar$|.*\.sln$|.*\.tmp$|.*\.dll$|.*\.iso$|.*\.swf$|.*\.conf$|.*\.ovpn$|.*\.bak$|.*\.ps1$|.*\.kdbx$|.*\.lst$|.*\.htaccess$|.*\.htpasswd$)" allurls.txt | tee sensitive_files.txt
```

## JS Hunting

```bash
{ grep -i "\.js$" urls.txt 2>/dev/null; cat resolved.txt 2>/dev/null | subjs; cat resolved.txt 2>/dev/null | getJS --complete; } | sort -u | httpx -mc 200 -silent > js_files.txt && xargs -P 20 -I {} curl -sL "{}" < js_files.txt | grep -aoP "(?<=(\"|\'|\`))\/[a-zA-Z0-9_?&=\/\-\#\.]*(?=(\"|\'|\`))" | sort -u > endpoints.txt && nuclei -l js_files.txt -tags token,key,api,exposure -silent -o js_secrets.txt
```

## Vulnerability Fuzzing

```bash
D="target.com"; arjun -i live_web.txt -m GET -oT params.txt; cat live_web.txt 2>/dev/null | gf lfi | qsreplace "FUZZ" | while read url; do ffuf -u "$url" -w lfi_payloads.txt -mr "root:"; done; cat urls.txt 2>/dev/null | gf xss | uro | Gxss -p Rxss | dalfox pipe; ffuf -u "https://$D/FUZZ" -w <(cat FUZZSUBS_CYFARE_1.txt FUZZSUBS_CYFARE_2.txt 2>/dev/null | sort -u) -e .php,.zip -mc 200,302 -o dir_fuzz.txt
```