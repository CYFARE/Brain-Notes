Choose and pick from the following safe optimization settings for Windows 11:

```powershell

# admin + strict mode
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw "Run PowerShell as Administrator." }
$ErrorActionPreference = 'Stop'

# power plan: Ultimate Performance + aggressive CPU policy
$dup     = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
$upGUID  = ([regex]::Match($dup,'([0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12})')).Value
powercfg -setactive $upGUID
$SUB_PROCESSOR = '54533251-82be-4824-96c1-47b60b740d00'
$MINPROC       = '893dee8e-2bef-41e0-89c6-b55d0929964c'
$MAXPROC       = 'bc5038f7-23e0-4960-96da-33abaf5935ec'
$BOOST         = 'be337238-0d82-4146-a960-4f3749d470c7'
$IDLEDISABLE   = '5d76a2ca-e8c0-402f-a133-2158492d58ad'
$COREPARKMIN   = '0cc5b647-c1df-4637-891a-dec35c318583'
powercfg -setacvalueindex $upGUID $SUB_PROCESSOR $MINPROC 100
powercfg -setdcvalueindex $upGUID $SUB_PROCESSOR $MINPROC 100
powercfg -setacvalueindex $upGUID $SUB_PROCESSOR $MAXPROC 100
powercfg -setdcvalueindex $upGUID $SUB_PROCESSOR $MAXPROC 100
powercfg -setacvalueindex $upGUID $SUB_PROCESSOR $BOOST 2
powercfg -setdcvalueindex $upGUID $SUB_PROCESSOR $BOOST 2
powercfg -setacvalueindex $upGUID $SUB_PROCESSOR $IDLEDISABLE 1
powercfg -setdcvalueindex $upGUID $SUB_PROCESSOR $IDLEDISABLE 1
powercfg -setacvalueindex $upGUID $SUB_PROCESSOR $COREPARKMIN 100
powercfg -setdcvalueindex $upGUID $SUB_PROCESSOR $COREPARKMIN 100
powercfg -S $upGUID

# hibernation off
powercfg /h off

# disable Fault Tolerant Heap + clear stores
New-Item -Path 'HKLM:\SOFTWARE\Microsoft' -Name 'FTH' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\FTH' -Name 'Enabled' -Type DWord -Value 0
Remove-Item -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Recurse -Force -ErrorAction SilentlyContinue

# kill power throttling
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'PowerThrottling' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -Type DWord -Value 1

# enable HAGS
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Type DWord -Value 2

# multimedia scheduling: unlock network + prioritize games
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'NetworkThrottlingIndex' -Type DWord -Value 4294967295
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' -Name 'SystemResponsiveness'    -Type DWord -Value 0
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks' -Name 'Games' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' -Name 'GPU Priority'        -Type DWord -Value 8
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' -Name 'Priority'            -Type DWord -Value 6
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' -Name 'Scheduling Category' -Type String -Value 'High'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' -Name 'SFIO Priority'       -Type String -Value 'High'

# visual effects: best performance + instant UI
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'VisualEffects' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Type DWord -Value 2
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations'   -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewAlphaSelect' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewShadow'      -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MenuShowDelay'       -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'UserPreferencesMask' -Type Binary -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes' -Name 'Personalize' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Type DWord -Value 0

# startup optimization: zero startup delay
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'Serialize' -Force | Out-Null
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' -Name 'StartupDelayInMSec' -PropertyType DWord -Value 0 -Force | Out-Null

# ntfs fast-paths
fsutil behavior set DisableLastAccess 1
fsutil behavior set disable8dot3 1
fsutil behavior set memoryusage 2
fsutil behavior set mftzone 2
fsutil behavior set disabledeletenotify 0

# network stack: low-latency tcp + rss
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global rss=enabled
netsh int tcp set global chimney=disabled
netsh int tcp set global dca=enabled
netsh int tcp set global ecncapability=disabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global congestionprovider=ctcp

# nagle off + ack optimizations on active nics
Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object {
  $guid = $_.InterfaceGuid.ToString('B')
  $path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
  New-Item -Path $path -Force | Out-Null
  New-ItemProperty -Path $path -Name 'TcpAckFrequency' -PropertyType DWord -Value 1 -Force | Out-Null
  New-ItemProperty -Path $path -Name 'TCPNoDelay'      -PropertyType DWord -Value 1 -Force | Out-Null
  New-ItemProperty -Path $path -Name 'TcpDelAckTicks'  -PropertyType DWord -Value 0 -Force | Out-Null
}

# game dvr / game bar off
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'GameDVR' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled'              -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_FSEBehaviorMode'      -Type DWord -Value 2
Set-ItemProperty -Path 'HKCU:\System\GameConfigStore' -Name 'GameDVR_HonorUserFSEBehaviorMode' -Type DWord -Value 1
New-Item -Path 'HKCU:\SOFTWARE\Microsoft' -Name 'GameBar' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\GameBar' -Name 'ShowGameBar' -Type DWord -Value 0

# background services trimmed
Stop-Service -Name 'SysMain' -Force -ErrorAction SilentlyContinue;  Set-Service 'SysMain'      -StartupType Disabled
Stop-Service -Name 'WSearch' -Force -ErrorAction SilentlyContinue;  Set-Service 'WSearch'      -StartupType Disabled
Stop-Service -Name 'DiagTrack' -Force -ErrorAction SilentlyContinue; Set-Service 'DiagTrack'    -StartupType Disabled
Stop-Service -Name 'dmwappushsvc' -Force -ErrorAction SilentlyContinue; Set-Service 'dmwappushsvc' -StartupType Disabled
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion' -Name 'DeliveryOptimization' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization' -Name 'DODownloadMode' -Type DWord -Value 0

# memory manager: no compression
Disable-MMAgent -MemoryCompression

# reserved storage off
dism /Online /Set-ReservedStorageState /State:Disabled

# foreground priority bias
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' -Name 'Win32PrioritySeparation' -Type DWord -Value 38

# reboot recommended after applying
Restart-Computer -Force
```