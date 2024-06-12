# Linux Shell Basics

## Debian Specific Commands

### List number of lines in a file

```shell
wc -l filename.txt
```

### List contents of a file

```shell
cat filename.txt
```

### Create new folder

```shell
mkdir foldername
```

### Delete a file

```shell
rm filename
```

### Delete a folder

```shell
rm -rf foldername
```

### Delete a protected file

```shell
sudo rm filename
```

### Create empty file (1)

```shell
touch filename
```

### Create empty file (2)

```shell
printf " " > tee filename
```

### Print line with specific word in a file

```shell
cat filename | grep -i "word"
```

### Skip lines with specific word and print all else

```shell
cat filename | grep -v "word"
```

### Navigate inside a folder

```shell
cd foldername
```

### Navigate to home folder

```shell
cd
```

### Locate a file path

```shell
locate filename
```

### List contents of a folder

```shell
ls
```

### List contents of a folder with extra information

```shell
ls -l
```

### Navigate to home folder directories from any other folder

```shell
cd ~/directory_inside_your_home_folder
```

### Get status of a system service

```shell
sudo service service_name status
```

### TRIM the system

```shell
sudo fstrim -a -v
```

### Clean APT

```shell
sudo apt autoremove && sudo apt clean
```

### Copy a file to folder

```shell
sudo cp filename ~/Pictures/foldername
```

### Change ownership of a file

```shell
sudo chown username:username filename 
```

### Change ownership of all files in current folder

```shell
sudo chown username:username *
```

### Give read/write/execute/change rights to a script

```shell
sudo chmod +x scriptname.ext
```

### Run script with default script interpreter

```shell
./scriptname
```

### Terminal system resource monitoring

```shell
htop
```

### Scan current machine connections, filter for only tcp and udp with https

```shell
netstat -a | grep -E "tcp|udp" | grep -i "https"
```

### Scan system ports using tcp and udp

```shell
netstat -pn | grep -E "tcp|udp"
```

### Print only proccess id and process name

```shell
ps | awk ''{print $1"\t"$4}'
```

### Detailed processes without tl garbage

```shell
ps -aux | awk '{print $1"\t"$2"\t"$NF}'
```

### Find system users and app users

```shell
awk -F ":" '{print " | "$1" | "$6" | "$7" | "}' /etc/passwd
```

### Find installed shells

```shell
awk -F "/" '/^\// {print $NF}' /etc/shells | uniq | sort
```

### Default shell history without line numbers

```shell
history | awk '{$1=""; sub(" ", " "); print}'
```

### ZSH history without garbage

```shell
cat ~/.zsh_history | awk -F ":" '{$1="";$2=""; sub(" ", " "); print}' | awk -F ";" '{$1=""; sub(" ", " "); print}'
```

### Find installed shells

```shell
awk -F "/" '/^\// {print $NF}' /etc/shells | uniq | sort
```

### One line sys recon

```shell
printf "\n=== Routing Tables ===\n" && netstat -r && printf "\n\n=== Ports Scan ===\n" && netstat -pn | grep -E "tcp|udp" && printf "\n\n=== Active Connections ===\n" && netstat -a | grep -E "tcp|udp" | grep -i "https" && printf "\n\n=== Active Front Processes ===\n" && ps | awk '{printf $1"\t"$4}' && printf "\n\n=== Active All Processes ===\n" && ps -aux | awk '{printf $1"\t"$2"\t"$NF}' && printf "\n\n=== App Users ===\n" && awk -F ":" '{printf " | "$1" | "$6" | "$7" | "}' /etc/passwd && printf "\n\n=== Installed Shells ===\n" && awk -F "/" '/^\// {printf $NF}' /etc/shells | uniq | sort
```

### Get server header and body using Netcat

```shell
nc -v website.com 80
```

Use openssl for https traffic
