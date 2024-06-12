Study resource: https://4sysops.com/archives/the-smb-protocol-all-you-need-to-know/

# Attack

- SMB ports - 139 (old versions) and 445 (new versions)
- Ping target mac.hx.using: 

```bash
ping -C 4 demo.hx.local
```

- Check open ports using nmap:

```bash
nmap demo.hx.local
```

## Enumerate SMB protocol versions

```bash
nmap -p445 --script smb-protocols demo.hx.local
```

## Users & Sessions Enumeration

### Enumerate if 'guest' user exist

```bash
smbmap -u guest -p "" -d . -H demo.hx.local
```

If guest user exists, we can find all other users

### Other users enum

```bash
nmap -p445 --script smb-enum-users demo.hx.local
```

### Enumerate Logged-In Sessions

```bash
nmap -p445 --script smb-enum-sessions demo.hx.local
```

## SMB Login Bruteforce - Hydra

```bash
hydra -l administrator -P /usr/share/metasploit-framework/data/wordlists/unix_passwords.txt demo.hx.local smb
```

## Finding Permissions & Shares

```bash
smbmap -u sysadmin -p butterfly -d . -H demo.hx.local
```

# Defend

## Edit Group Policy

- Open powershell -> `gpedit.msc`

### Disable guest account status

```powershell
**Windows Settings** -> **Security Settings** -> **Local Policy** -> **Security Options** -> **Accounts: Guest account status** -> Disable
```

- Attacker won't be able to run smbmap for sessions, users, shares

### Enable password complexity policy

```powershell
**Windows Settings** -> **Security Settings** -> **Account Policy** -> **Password Policy**
```

#### Set new password for sysadmin user

- In powershell:

```powershell
net user sysadmin abc_123321
```

### Set account lockout policy

```powershell
**Windows Settings** -> **Security Settings** -> **Account Policy** -> **Account Lockout Policy** -> **Account lockout threshold**
```

## Upgrade SMB Version

- Powershell:

```powershell
Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force
```

```powershell
Disable-WindowsOptionalFeature -On.hx.-FeatureName SMB1Protocol
```

### Verify

```powershell
Get-WindowsOptionalFeature -On.hx.-FeatureName SMB1Protocol
```

```powershell
Get-SmbServerConfiguration | Select EnableSMB2Protocol
```

## Change users C:/ permission to read-only

- Goto: **My Computers** -> Right Click on the **C:\** Drive -> Properties -> Sharing -> Advance Sharing.. -> Permission
- Remove user from sharing
- For group 'Everyone' set permission to 'Read' and disable other permissions

## Enable firewall filtering

- Powershell

```powershell
Set-Service -Name MpsSvc -StartupType Automatic
```

```powershell
Start-Service -Name MpsSvc
```

```powershell
netsh advfirewall set allprofiles state on
```

### Enable IP Filter to access SMB

- Open advance firewall ksettings
- Add two firewall rules:
	- File and Printer Sharing (SMB-In)
	- File Server Remote Management (SMB-In)
- Add the rule -> Scope -> Specifiy IP to match subnet local -> 10.10.10.10
