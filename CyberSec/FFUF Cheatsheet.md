# FFUF Cheatsheet

| Scenario | Command |
|---|---|
| **Basic Bruteforce** | ```ffuf -c -w /usr/share/wordlists/dirb/small.txt -u https://ffuf.io.fi/FUZZ<br>``` |
| **Mass subdomain fuzzing** | ```cat ~/RECON/usgov/doms.txt \| while read line; do ffuf -c -t 100 -mc 200,204,301,302,307 -w ~/Desktop/pays/FUZZSUBS.txt -u https://FUZZ.$line -o fuzzed_subs.txt; done<br>``` |
| **Recursive Scanning** | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi/FUZZ -recursion -recursion-depth 2<br>``` |
| **Extensions** | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi/FUZZ -e .bak, .zip<br>``` |
| **Multiple Paths** | ```ffuf -u https://W2/W1 -w ./wordlist.txt:W1,./domains.txt:W2<br>``` |
| **Subdomains** | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi -H "Host: FUZZ.ffuf.io.fi"<br>``` |
| **Filters** |  |
| Filter via HTTP status codes | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi -mc 200,301<br>``` |
| Filter via amount of lines in response | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi -ml 50<br>``` |
| Filter via HTTP response size | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi -ms 350<br>``` |
| Filter via words count in response | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi -mw 200<br>``` |
| Filter via regular expressions | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi -mr "root:"<br>``` |
| **HTTP Based Fuzzing** |  |
| Cookie-based Authentication | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi -b "sessionId=cookie_val"<br>``` |
| GET parameter fuzzing | ```ffuf -c -w /path/to/wordlist -u https://ffuf.io.fi?FUZZ=test_value<br>``` |
| POST data fuzzing | ```ffuf -c -w /path/to/wordlist -X POST -d "username=admin&password=FUZZ" -u https://ffuf.io.fi/login.php<br>``` |
| JSON POST data fuzzing | ```ffuf -w wordlist.txt -X PUT -u http://test.site/api/users/6 -H "Content-Type: application/json" -d "{'FUZZ':'test_val'}"<br>``` |
| Pass Success Commands To BURP | ```ffuf -request ~/Desktop/request.txt -w ./wordlist.txt -replay-proxy http://127.0.0.1:8080<br>``` |
