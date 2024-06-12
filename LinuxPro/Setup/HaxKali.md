# HaxKali

## Features

- QCOW2 base ( [[KVM Setup]] )
- Xanmod Kernel Edge ( [[Debian Optimizations]] )
- SSD & VM optimizations ( [[Debian Optimizations]] )
- Sandboxed Common Apps ( [[Debian Optimizations]] )
- 500+ New Packages
- Preconfigured Custom Tools
- App Execution Security Improvements ( [[App Optimizations]] )
- App Customized For Privacy ( [[App Optimizations]] )

[[Debian Optimizations]]

[[App Optimizations]]

## Other VM Customization

### Install.sh

```bash
sudo apt install -y gospider locate xdg-desktop-portal-gtk mono-devel spice-vdagent apt-transport-https ttf-mscorefonts-installer lsd xxd preload keepassxc stacer python3-pip tor proxychains flatpak terminator gdebi gparted qbittorrent htop axel neofetch usbtop sirikali dbeaver git sqlitebrowser ruby powershell golang-go arp-scan 0trace amap arping braa thc-ipv6 dmitry dnsenum dnsmap enum4linux etherape fping gobuster hping3 ike-scan intrace irpas lbd maltego masscan nbtscan netdiscover nmap onesixtyone p0f recon-ng smbmap smtp-user-enum snmpcheck ssldump sslh sslscan sslyze swaks theharvester unicornscan ismtp python3-shodan emailharvester instaloader inspy sherlock certgraph nmapsi4 afl doona thc-ipv6 dhcpig enumiax gvm iaxflood inviteflood dsniff ohrwurm protos-sip rtpbreak rtpflood rtpinsertsound rtpmixsound sipp slowhttptest spike sipvicious thc-ssl-dos unix-privesc-check voiphopper yersinia siparmyknife sctpscan cisco-ocs cisco-torch copy-router-config burpsuite commix davtest dirb dirbuster gobuster joomscan jsql-injection nikto padbuster skipfish wfuzz whatweb wig wpscan xsser zaproxy wafw00f parsero armitage beef-xss commix thc-ipv6 jsql-injection mdbtools metasploit-framework oscanner pompem set shellnoob sidguesser sqlmap websploit unicorn-magic backdoor-factory ncat-w32 powercat dns2tcp hyperion iodine laudanum nishang proxychains proxytunnel ptunnel pwnat sbd shellter socat sslh stunnel4 udptunnel webacoo weevely windows-binaries webshells mimikatz powersploit passing-the-hash wce xspy lynis linux-exploit-suggester brutespray cewl changeme chntpw cmospwd crackle crunch fcrackzip hashcat hashid hydra john johnny pack medusa onesixtyone ophcrack-cli ophcrack pdfcrack pipal pixiewps rainbowcrack rarcrack rcracki-mt rsmangler samdump2 sipcrack sucrack thc-pptp-bruter truecrack twofi wordlists device-pharmer statsprocessor aircrack-ng airgeddon asleap bluelog blueranger bluesnarfer btscanner bluez-hcidump bully cowpatty crackle eapmd5pass fern-wifi-cracker hackrf inspectrum mdk3 mfcuk mfoc mfterm libfreefare-bin libnfc-bin pixiewps reaver redfang rfcat rtlsdr-scanner ubertooth wifi-honey wifite yersinia bettercap chaosreader darkstat dnschef dsniff sniffjoke tcpflow driftnet etherape ettercap-graphical thc-ipv6 fiked hamster-sidejack hexinject isr-evilgrade mitmproxy netsniff-ng rebind responder sslsniff sslsplit tcpreplay wifi-honey wireshark yersinia afflib-tools dumpzilla extundelete rifiuti ewf-tools cabextract autopsy binwalk sleuthkit dc3dd dcfldd ddrescue dex2jar ewf-tools extundelete foremost galleta gtkhash guymager hashdeep magicrescue missidentify pasco pdf-parser pdfid pev recoverjpeg reglookup regripper rifiuti rifiuti2 safecopy scalpel scrounge-ntfs vinetto xplico inetsim forensic-artifacts galleta gpp-decrypt guymager smartmontools yara gscanbus clang dex2jar edb-debugger gdb javasnoop rizin rizin-cutter smali eyewitness faraday-cli faraday vokoscreen impacket-scripts ngrep netsed osslsigncode arpwatch vlan nginx arping crunch davtest dc3dd dhcpig dirb dirbuster dmitry dns2tcp dnschef dnsenum dnsmap dos2unix eapmd5pass enumiax ethtool fcrackzip fping hashcat hping3 iaxflood impacket-scripts iodine isr-evilgrade john joomscan laudanum links lynis maskprocessor medusa metasploit-framework miredo miredo-server mitmproxy nasm nbtscan ncrack netdiscover nikto nmap openssh-server ophcrack-cli oscanner p0f powersploit proxychains proxytunnel ptunnel pwnat crackmapexec rainbowcrack reaver sbd set sfuzz siege skipfish smbclient smbmap smtp-user-enum snmpcheck socat spiderfoot sqlmap ssldump sslscan sslsniff tcpdump t50 thc-ipv6 thc-ssl-dos theharvester traceroute whois truecrack udptunnel unix-privesc-check webacoo webshells websploit weevely whatweb etherwake wpscan xsser yersinia beef-xss saidar hexinject arping asleap doona bully chntpw cowpatty creddump7 crunch cymothoa davtest dc3dd dcfldd ddrescue dhcpig dirb dirbuster dmitry dns2tcp dnschef dnsenum dnsrecon dnstracer dnswalk dos2unix dsniff eapmd5pass enumiax ethtool ettercap-graphical fcrackzip ferret fierce foremost fping hexinject hping3 htshells iaxflood impacket-scripts iodine isr-evilgrade john joomscan laudanum libnet1-dev libpcap-dev links lynis maskprocessor mdk3 medusa miredo mitmproxy nasm nbtscan netdiscover nishang nmap openssh-server oscanner outguess p0f payloadsallthethings powercat powersploit proxychains proxytunnel ptunnel pwnat reaver reglookup rig safecopy sbd scalpel sfuzz shellinabox siege sipcrack sipvicious skipfish smbmap smbclient smtp-user-enum snmpcheck socat spiderfoot sqldict sqlmap ssldump sslscan sslsniff steghide t50 tcpxtract tcpick tlssled tcptrace thc-ipv6 thc-ssl-dos theharvester themole traceroute whois udptunnel unix-privesc-check wce webacoo webshells websploit weevely whatweb wireshark etherwake wpscan xsser yersinia zaproxy ftester smali geany soundmodem minimodem mat2 kazam gnome-software-plugin-flatpak
git clone --depth=1 https://github.com/1N3/Sn1per.git
git clone --depth=1 https://github.com/six2dez/reconftw.git
git clone --depth=1 https://github.com/TryCatchHCF/PacketWhisper.git
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
searchsploit -u
```

### 'LS' Replaced By LSDeluxe

- Setup alias in `~/.zshrc` and `~/.bashrc` :
	- Add the following line: `alias ls='lsd'`
