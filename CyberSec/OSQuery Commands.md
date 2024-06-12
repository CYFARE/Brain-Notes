# OSQuery Commands

| No. | Description                                 | Command                                                |
|----:|---------------------------------------------|--------------------------------------------------------|
|   1 | See all tables heading                     | ```.tables```                                    |
|   2 | See all columns from schema                | ```.schema tablename```                         |
|   3 | See system info                            | ```select * from system_info;```                 |
|   4 | See users                                  | ```select username, uid, shell from users;```   |
|   5 | See a process with multi table join        | ```select p.name, p.path, pp.name as parentname, pp.path as parentpath from processes as p left outer join processes as pp on p.parent=pp.pid order by p.name;``` |
|   6 | Check process vulnerabilities               | ```select name, pid, path, display_name from services where start_type = 'auto_start' and path not like 'C:\Windows\System32\svchost.exe -k %';``` |
|   7 | See install location for program           | ```select name, install_location from programs;``` |
|   8 | See specific installed apps                | ```select name, install_location from programs where name like '%brave%';``` |
|   9 | See user directory                         | ```select uid, username, shell, directory from users;``` |
|  10 | See auto startup                           | ```select name, path, source, status from startup_items where path not like '%desktop.ini%';``` |
|  11 | See registry data                          | ```select DATA from registry where key like '(type or copy paste registry location)';``` |
|  12 | See admin level users                      | ```select users.uid, users.username, shell from user_groups inner join users on user_groups.uid = users.uid where user_groups.gid = 544;``` |
|  13 | See browser extensions                     | ```select * from chrome_extensions;```          |
|  14 | See browser extension permissions          | ```select name, permissions from chrome_extensions;``` |
|  15 | Check threats via shim based id            | ```select executable, path, description, sdb_id from appcompat_shims;``` |
|  16 | Check network-based web server problems    | ```select name, cwd, parent, pid from processes;``` |
|  17 | Check network-based problems on a specific app | ```select name, cwd, parent, pid from processes where name like '%brave.exe%';``` |
|  18 | Check processes open from remote machine by cmdline | ```select name, cwd, parent, cmdline pid from processes where name like '%brave.exe%' limit 1;``` |
|  19 | See active listening ports                 | ```select distinct processes.pid, listening_ports.port, processes.name from processes left join listening_ports using (pid);``` |
|  20 | See logged-in users                        | ```select * from logged_in_users;```            |
|  21 | See system last shutdown event             | ```select * from shutdown_events;```            |
|  22 | Check open network connections             | ```select * from open_sockets;```               |
|  23 | See installed packages (Linux)             | ```select * from packages;```                   |
|  24 | See kernel modules (Linux)                 | ```select * from kernel_modules;```             |
|  25 | See loaded drivers (Windows)               | ```select * from drivers;```                    |
|  26 | Check scheduled tasks (Windows)            | ```select * from scheduled_tasks;```            |
|  27 | See user account policy (Windows)          | ```select * from user_account_policy_data;```   |
|  28 | Check last user logon time (Windows)       | ```select * from last;```                       |
|  29 | Check ARP table (Windows)                  | ```select * from arp_cache;```                  |
|  30 | See DNS cache (Windows)                    | ```select * from dns_cache;```                  |
|  31 | Check process network connections (Windows) | ```select * from process_open_sockets;```       |
|  32 | Check process file hashes (Windows)        | ```select * from process_events where action = 'load' and path like '%.exe%';``` |
|  33 | See active users (Windows)                 | ```select * from logged_in_users;```            |
|  34 | Check USB devices (Windows)                | ```select * from usb_devices;```                |
|  35 | Check startup items (Windows)              | ```select * from startup_items;```              |
|  36 | Check browser history                      | ```select * from browser_history;```            |
|  37 | Check running processes (Linux)            | ```select * from processes;```                  |
|  38 | Check installed software (Windows)         | ```select * from programs;```                   |
|  39 | Check network interfaces (Linux)           | ```select * from interface_addresses;```        |
|  40 | Check active network connections (Linux)   | ```select * from socket_events;```              |
|  41 | See running services (Linux)               | ```select * from services;```                   |
|  42 | See user accounts (Linux)                  | ```select * from users;```                      |
|  43 | Check sudoers file (Linux)                 | ```select * from sudoers;```                    |
|  44 | Check firewall rules (Linux)               | ```select * from iptables;```                   |
|  45 | See hardware info (Linux)                  | ```select * from hardware_info;```              |
|  46 | Check startup programs (Linux)             | ```select * from startup_items;```              |
|  47 | Check cron jobs (Linux)                    | ```select * from crontab;```                    |
|  48 | Check file hashes (Linux)                  | ```select * from file_events where category = 'hash' and directory not like '/sys%' and directory not like '/dev%';``` |
|  49 | Check file permissions (Linux)             | ```select * from file where path ...``` |
