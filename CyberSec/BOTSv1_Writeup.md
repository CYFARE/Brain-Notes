# CyberDefenders CTF

## Boss of The Soc v1

## VM Setup

1. Download VM from cyberdefenders.org
2. Import OVA using Virtualbox
3. Once machine is started, no need to login. Just visit 127.0.0.1:8000 on host machine
4. Splunk enterprise is accessible

## Questions

1. Whats the software used for hunting and log collection (similar question 1)
2. What is the likely IP address of someone from the Po1s0n1vy group scanning imreallynotbatman.com for web application vulnerabilities?
3. What company created the web vulnerability scanner used by Po1s0n1vy? Type the company name. (For example, "Microsoft" or "Oracle")
4. What content management system is imreallynotbatman.com likely using? (Please do not include punctuation such as . , ! ? in your answer. We are looking for alpha characters only.)
5. What is the name of the file that defaced the imreallynotbatman.com website? Please submit only the name of the file with the extension (For example, "notepad.exe" or "favicon.ico").
6. This attack used dynamic DNS to resolve to the malicious IP. What is the fully qualified domain name (FQDN) associated with this attack?
7. What IP address has Po1s0n1vy tied to domains that are pre-staged to attack Wayne Enterprises?
8. Based on the data gathered from this attack and common open-source intelligence sources for domain names, what is the email address most likely associated with the Po1s0n1vy APT group?
9. What IP address is likely attempting a brute force password attack against imreallynotbatman.com?
10. What is the name of the executable uploaded by Po1s0n1vy? Please include the file extension. (For example, "notepad.exe" or "favicon.ico")
11. What is the MD5 hash of the executable uploaded?
12. GCPD reported that common TTP (Tactics, Techniques, Procedures) for the Po1s0n1vy APT group, if initial compromise fails, is to send a spear-phishing email with custom malware attached to their intended target. This malware is usually connected to Po1s0n1vy's initial attack infrastructure. Using research techniques, provide the SHA256 hash of this malware.
13. What is the special hex code associated with the customized malware discussed in question 12? (Hint: It's not in Splunk)
14. One of Po1s0n1vy's staged domains has some disjointed "unique" whois information. Concatenate the two codes together and submit them as a single answer.
15. What was the first brute force password used?
16. One of the passwords in the brute force attack is James Brodsky's favorite Coldplay song. Hint: we are looking for a six-character word on this one. Which is it?
17. What was the correct password for admin access to the content management system running "imreallynotbatman.com"?
18. What was the average password length used in the password brute-forcing attempt? (Round to a closest whole integer. For example "5" not "5.23213")
19. How many seconds elapsed between the brute force password scan identified the correct password and the compromised login? Round to 2 decimal places.
20. How many unique passwords were attempted in the brute force attempt?
21. What was the most likely IP address of we8105desk in 24AUG2016?
22. Amongst the Suricata signatures that detected the Cerber malware, which one alerted the fewest number of times? Submit ONLY the signature ID value as the answer. (No punctuation, just 7 integers.)
23. What fully qualified domain name (FQDN) makes the Cerber ransomware attempt to direct the user to at the end of its encryption phase?
24. What was the first suspicious domain visited by we8105desk in 24AUG2016?
25. During the initial Cerber infection a VB script is run. The entire script from this execution, pre-pended by the name of the launching .exe, can be found in a field in Splunk. What is the length in characters of the value of this field?
26. What is the name of the USB key inserted by Bob Smith?
27. Bob Smith's workstation (we8105desk) was connected to a file server during the ransomware outbreak. What is the IP address of the file server?
28. How many distinct PDFs did the ransomware encrypt on the remote file server?
29. The VBScript found in question 25 launches 121214.tmp. What is the ParentProcessId of this initial launch?
30. The Cerber ransomware encrypts files located in Bob Smith's Windows profile. How many .txt files does it encrypt?
31. The malware downloads a file that contains the Cerber ransomware crypto code. What is the name of that file?
32. Now that you know the name of the ransomware's encryptor file, what obfuscation technique does it likely use?


### Recon

### Events

> 955807

Query:

```
| eventcount index=botsv1
```

### Hosts

> 7

```
192.168.2.50

192.168.250.1

splunk-02

suricata-ids.waynecorpinc.local

we1149srv

we8105desk

we9041srv
```

Query:
```
| metadata type=hosts
| stats values(host)
```

### Log Sources

> 20

```
WinRegistry

XmlWinEventLog:Microsoft-Windows-Sysmon/Operational

fgt_event

fgt_traffic

fgt_utm

iis

nessus:scan

stream:dhcp

stream:dns

stream:http

stream:icmp

stream:ip

stream:ldap

stream:mapi

stream:sip

stream:smb

stream:snmp

stream:tcp

suricata

wineventlog
```

Query:

```
| metadata type=sourcetypes
| stats values(sourcetype)
```

### Log sources used in each host

Query:

```
| tstats count by host sourcetype | sort host -count
```

## Answers + Methodology

### Answer 1

> splunk

Software name is there on the dashboard

### Answer 2

> 40.80.148.42

- We are given that the group has defaced the website, so there must be HTTP calls  made for scanning vulnerabilities or similar bulk connections.
- We will find the source and destination ip requests for domain: imreallynotbatman.com using the following query:
` imreallynotbatman.com | stats count by c_ip | sort -count `
- We find that 40.80.148.42 is the ip sending max counts
- After modifying the query for finding the max requests by this c_ip to the server, we can find more information:
` imreallynotbatman.com source="stream:http" c_ip="40.80.148.42" | sort -count `


### Answer 3

> Acunetix

If we look at the header logs, we can find the following log:
```
   src_headers: POST /joomla/index.php/component/search/ HTTP/1.1 Content-Length: 78 Content-Type: application/x-www-form-urlencoded Referer: http://imreallynotbatman.com:80/ Cookie: ae72c62a4936b238523950a4f26f67d0=v7ikb3m59romokqmbiet3vphv3 Host: imreallynotbatman.com Connection: Keep-alive Accept-Encoding: gzip,deflate User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.21 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.21 Acunetix-Product: WVS/10.0 (Acunetix Web Vulnerability Scanner - Free Edition) Acunetix-Scanning-agreement: Third Party Scanning PROHIBITED Acunetix-User-agreement: http://www.acunetix.com/wvs/disc.htm Accept: */*
```

We can notice the last section called `src_headers` has `Acunectix Web Vulnerability Scanner` in it

### Answer 4

> Joomla

Using the same headers, we will find url paths such as: `/joomla/`

### Answer 5

> poisonivy-is-coming-for-you-batman.jpeg

- We will find the dest_ip of the webserver of imreallynotbatman.com using the extracted fields
- We find an IP: `192.168.250.70`
- We will pass the c_ip as this new IP for gathering web server information and search requests URLs: `index="botsv1" c_ip="192.168.250.70" | stats count by url`
- We can see the following url: `index="botsv1" c_ip="192.168.250.70" stats count by url` we can find the jpeg image coming from another website

### Answer 6

>prankglassinebracket.jumpingcrab.com

After adding the JPEG file url to query, we can see the logs in detail and get the FQDN

### Answer 7

> 23.22.63.114

If we search the 2 unique IP addresses on VirusTotal, this answer IP address turns out to point to our attacker FQDN: https://www.virustotal.com/gui/ip-address/23.22.63.114/relations

### Answer 8

> lillian.rose@po1s0n1vy.com

Open threatcrowd.org or maltego and we will get the email associated to the domain name OR we can find it on historical whois information inside mailing address

### Answer 9

> 23.22.63.114

We use the following splunk query: `index="botsv1" imreallynotbatman.com http_method=POST sourcetype="stream:http" | stats count by src, form_data` and get this IP bruteforcing against admin account

### Answer 10

> 3791.exe

We query splunk for multipart-/form-data with custom filter to find the filename= text inside the logs. Then we filter by any .exe file and find this filename along with another php filename called: `agent.php`: `index="botsv1" sourcetype="stream:http" dest="192.168.250.70" "multipart/form-data" "filename=" "3791.exe" | head 1`

### Answer 11

> AAE3F5A29935E6ABCC2C2754D12A9AF0

We find the checksum in overall logs using the following splunk query: `index="botsv1" "3791.exe" "MD5" source="WinEventLog:Microsoft-Windows-Sysmon/Operational" CommandLine="3791.exe"`


### Answer 12

> 9709473ab351387aab9e816eff3910b9f28a7a70202e250ed46dba8f820f34a8

We went on virustotal and get the SHA-256 of related screen saver file

### Answer 13

> 53 74 65 76 65 20 42 72 61 6e 74 27 73 20 42 65 61 72 64 20 69 73 20 61 20 70 6f 77 65 72 66 75 6c 20 74 68 69 6e 67 2e 20 46 69 6e 64 20 74 68 69 73 20 6d 65 73 73 61 67 65 20 61 6e 64 20 61 73 6b 20 68 69 6d 20 74 6f 20 62 75 79 20 79 6f 75 20 61 20 62 65 65 72 21 21 21

Grabbed from comment section on VT

### Answer 14

> 31 73 74 32 66 69 6E 64 67 65 74 73 66 72 65 65 62 65 65 72 66 72 6F 6D 72 79 61 6E 66 69 6E 64 68 69 6D 74 6F 67 65 74

We try to find the domains associated / hosted on the IP: `23.22.63.114` from virustotal: https://www.virustotal.com/gui/ip-address/23.22.63.114/relations

We get the following similar domains with few name differences:

```
waynecorinc.com
wanecorpinc.com
wynecorpinc.com
wayneorpinc.com
wayncorpinc.com
waynecrpinc.com
waynecorpnc.com
```

After trying to conduct whois search, none of the domain is currently hosted of used by anyone, so we try to find historical whois information using: https://www.whoxy.com/whois-history/demo.php

We find the following company name and mailing address:

```
company name: 31 73 74 32 66 69 6E 64 67 65 74 73 66 72 65 65 62 65 65 72
mailing address: 66 72 6F 6D 72 79 61 6E 66 69 6E 64 68 69 6D 74 6F 67 65 74
```

### Answer 15

> 12345678

We use the following search query to get the answer:

```
index="botsv1" imreallynotbatman.com sourcetype="stream:http" http_method=POST form_data=*username*passwd* 
| rex field=form_data "username=(?<user>\w+)" 
| rex field=form_data "passwd=(?<pw>\w+)"
| table _time, user, pw 
| sort by _time
```

### Answer 16

> yellow

We filtered all six character passwords and compared to all coldplay songs name that have 6 characters. Query used: 

```
index="botsv1" imreallynotbatman.com sourcetype="stream:http" http_method=POST form_data=*username*passwd* 
| rex field=form_data "passwd=(?<pw>\w+)" 
| eval lenpw=len(pw) 
| search lenpw=6
| table pw, lenpw
```

### Answer 17

> batman

We use the following query:

```
index="botsv1" imreallynotbatman.com sourcetype="stream:http" http_method=POST form_data=*username*passwd* 
| rex field=form_data "passwd=(?<pw>\w+)"
```

And look at form_data to get the password

### Answer 18

> 6

Using the following query: 

```
index="botsv1" imreallynotbatman.com sourcetype="stream:http" http_method=POST form_data=*username*passwd* 
| rex field=form_data "passwd=(?<pw>\w+)"
| eval pwlen=len(pw) 
| stats avg(pwlen) as avglen
```

### Answer 19

> 92.17

We calculated the duration using the following query:

```
index="botsv1" imreallynotbatman.com sourcetype="stream:http" http_method=POST form_data=*username*passwd* 
| rex field=form_data "passwd=(?<pw>\w+)"
| search pw="batman" 
| transaction pw
| eval dur=round(duration,2)
| table dur
```

### Answer 20

> 412

We sorted the passwords used by unique and removed duplicates using the query:

```
index="botsv1" imreallynotbatman.com sourcetype="stream:http" http_method=POST form_data=*username*passwd* 
| rex field=form_data "passwd=(?<pw>\w+)"
| uniq 
| dedup pw
| table pw
```

### Answer 21

> 192.168.250.100

Query: 
```
we8105desk 
|  stats count by src_ip
```

### Answer 22

> 2816763

Type the query to get suricata logs with 'cerber' keyword: 

```
[2816763](http://127.0.0.1:8000/en-US/app/search/search?q=search%20index%3D%22botsv1%22%20sourcetype%3D%22suricata%22%20%22Cerber%22&display.page.search.mode=smart&dispatch.sample_ratio=1&workload_pool=&earliest=0&latest=now&display.page.search.tab=events&display.general.type=events&display.prefs.statistics.count=100&sid=1660737108.204#)
```

Then check alert_signature_id field on left side column

### Answer 23

> cerberhhyed5frqa.xmfir0.win

Following query:

```
index="botsv1" src_ip="192.168.250.100" sourcetype="stream:dns" "*cerber*"
| uniq 
| dedup queries 
| table queries
```

### Answer 24

> solidaritedeproximite.org

Query:

```
index="botsv1" src_ip="192.168.250.100" sourcetype="stream:dns" NOT query=*.local AND NOT query=*.arpa AND NOT query=*isatap* AND NOT query=*.microsoft* AND NOT query=*.microsoft* AND NOT query=*.windows* AND query=*.*
| uniq 
| dedup queries 
| table _time desc, queries
```

And we sort by date

### Answer 25

> 4490

- We will get xml windows event logs and find any vbs script using: `index="botsv1" sourcetype="xmlwineventlog:microsoft-windows-sysmon/operational" *.vbs`
- We need to filter commandline field to get all data inside it & evaluate the length of this field
- Final query:

```
index="botsv1" sourcetype="xmlwineventlog:microsoft-windows-sysmon/operational" *.vbs *we8105desk*
| rex "\’CommandLine\’>(?<cmdline>[^<]+)<\/Data>"
| eval length=len(cmdline)
| table _time,cmdline,length
```

### Answer 26

> MIRANDA_PRI

Query:

```
index="botsv1" sourcetype="winregistry" friendlyname 
|  table data
```

### Answer 27

> 192.168.250.20

Using the query: 

```
index="botsv1" src_ip=192.168.250.100 sourcetype="stream:smb"
| stats count by path
```

### Answer 28

> 257

Query:

```
index="botsv1" *.pdf sourcetype=wineventlog dest=we9041srv.waynecorpinc.local Source_Address="192.168.250.100" 
| dedup Relative_Target_Name
| stats count
```

### Answer 29

> 3968

Query:

```
index="botsv1" 121214.tmp wscript
```

Then look for the field 'parent_process_id' on left hand interesting fields

### Answer 30

> 406

Query:

```
index="botsv1" we8105desk sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" TargetFilename="C:\\Users\\bob.smith.WAYNECORPINC\\*.txt"
| stats dc(TargetFilename)
```

### Answer 31

> mhtr.jpg

We have to find it in: `solidaritedeproximite.org` for the system: `we8105desk` whose IP address is `192.168.250.100`. After that we find http_url inside interesting fields to find the JPG file:

```
index="botsv1" sourcetype="suricata" src_ip=192.168.250.100 solidaritedeproximite.org "http.url"="/mhtr.jpg"
```

Alternatively, we can add the http_url result in table:

```
index="botsv1" sourcetype="suricata" src_ip=192.168.250.100 solidaritedeproximite.org 
| table http.url
```

### Answer 32

> Steganography

Concealed code inside image
