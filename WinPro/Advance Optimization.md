Aggressive Windows 11 optimization ps1 script. Save as win11optimize.ps1:

```powershell
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows 11 - Extreme Performance Tuning Script
.DESCRIPTION
    Aggressive low-latency, high-throughput configuration for gaming / real-time workloads.
    Disables safety nets (Spectre mitigations, memory compression, SysMain, etc.).
    REVIEW EACH SECTION before running. Reboot required.
.NOTES
    Run in an elevated PowerShell 5.1+ session.
    Back up your registry first:  reg export HKLM hklm_backup.reg /y
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ?? helpers ??????????????????????????????????????????????????????????????????
function Set-Reg([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord') {
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value
}
function Disable-Svc([string]$Name) {
    Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
    Set-Service -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
}
function Write-Section([string]$Msg) { Write-Host "`n>> $Msg" -ForegroundColor Cyan }

# ===============================================================================
# 1. POWER PLAN - Ultimate Performance, all cores pinned
# ===============================================================================
Write-Section 'Power plan: Ultimate Performance'

$dup    = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
$upGUID = ([regex]::Match($dup, '([0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12})')).Value
powercfg -setactive $upGUID

$SUB = '54533251-82be-4824-96c1-47b60b740d00'
$powerCfg = @{
    '893dee8e-2bef-41e0-89c6-b55d0929964c' = 100   # Min processor state
    'bc5038f7-23e0-4960-96da-33abaf5935ec' = 100   # Max processor state
    'be337238-0d82-4146-a960-4f3749d470c7' = 2     # Boost: aggressive
    '5d76a2ca-e8c0-402f-a133-2158492d58ad' = 1     # Idle disable
    '0cc5b647-c1df-4637-891a-dec35c318583' = 100   # Core parking min cores
    '3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb' = 0     # Core parking concurrency threshold
    'ea062031-0e34-4ff1-9b6d-eb1059334028' = 100   # Core parking max cores
    '36687f9e-e3a5-4dbf-b1dc-15eb381c6863' = 100   # Core parking min cores (perf)
    '45bcc044-d885-43e2-8605-ee0ec6e96b59' = 100   # Perf increase threshold
    '06cadf0e-64ed-448a-8927-ce7bf90eb35d' = 0     # Perf decrease threshold
    '984cf492-3bed-4488-a8f9-4286c97bf5aa' = 1     # Perf increase policy: rocket
    '40fbefc7-2e9d-4d25-a185-0cfd8574bac6' = 1     # Perf decrease policy: rocket
    '4b92d758-5a24-4851-a470-815d78aee119' = 0     # Latency sensitivity hint: override idle
    '7b224883-b3cc-4d79-819f-8374152cbe7c' = 0     # Perf time check interval (us)
    '943c8cb6-6f93-4227-ad87-e9a3feec08d1' = 0     # Perf autonomous mode: disabled
}
$prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
foreach ($setting in $powerCfg.GetEnumerator()) {
    & powercfg -setacvalueindex $upGUID $SUB $($setting.Key) $($setting.Value) 2>$null
    & powercfg -setdcvalueindex $upGUID $SUB $($setting.Key) $($setting.Value) 2>$null
}

# USB selective suspend: disabled
& powercfg -setacvalueindex $upGUID 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null
& powercfg -setdcvalueindex $upGUID 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null

# PCI Express ASPM: off
& powercfg -setacvalueindex $upGUID 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 2>$null
& powercfg -setdcvalueindex $upGUID 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 2>$null
$ErrorActionPreference = $prevEAP

powercfg -S $upGUID
powercfg /h off

# ===============================================================================
# 2. CPU SCHEDULING & PRIORITY
# ===============================================================================
Write-Section 'CPU scheduling & priority'

# Foreground boost: short quantum, variable, high fg bias (0x26 = 38 ? short/variable/3:1)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 38

# Disable Fault Tolerant Heap
Set-Reg 'HKLM:\SOFTWARE\Microsoft\FTH' 'Enabled' 0
Remove-Item 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store' -Recurse -Force -EA SilentlyContinue
Remove-Item 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Recurse -Force -EA SilentlyContinue

# Kill power throttling
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' 'PowerThrottlingOff' 1

# ===============================================================================
# 3. SPECTRE / MELTDOWN MITIGATIONS - OFF (? security trade-off)
# ===============================================================================
Write-Section 'Spectre/Meltdown mitigations: DISABLED'

Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettingsOverride'     3
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettingsOverrideMask' 3

# ===============================================================================
# 4. GPU - HAGS + MSI mode for GPU interrupt
# ===============================================================================
Write-Section 'GPU optimizations'

Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 2

# Force MSI mode on all display adapters (lower interrupt latency)
Get-PnpDevice -Class Display -Status OK -EA SilentlyContinue | ForEach-Object {
    $devPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.InstanceId)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
    if (Test-Path $devPath) {
        Set-Reg $devPath 'MSISupported' 1
    }
}

# ===============================================================================
# 5. MULTIMEDIA / GAME SCHEDULING
# ===============================================================================
Write-Section 'Multimedia & game scheduling'

$mmPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
Set-Reg $mmPath 'NetworkThrottlingIndex' 0xFFFFFFFF
Set-Reg $mmPath 'SystemResponsiveness'   0

$gamePath = "$mmPath\Tasks\Games"
Set-Reg $gamePath 'GPU Priority'        8
Set-Reg $gamePath 'Priority'            6
Set-Reg $gamePath 'Scheduling Category' 'High'   'String'
Set-Reg $gamePath 'SFIO Priority'       'High'   'String'
Set-Reg $gamePath 'Affinity'            0
Set-Reg $gamePath 'Background Only'     'False'  'String'
Set-Reg $gamePath 'Clock Rate'          10000
Set-Reg $gamePath 'Latency Sensitive'   'True'   'String'

# ===============================================================================
# 6. TIMER RESOLUTION - force 0.5 ms (bcdedit)
# ===============================================================================
Write-Section 'Timer resolution & boot config'

$prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& bcdedit /set disabledynamictick   yes       2>$null
& bcdedit /set useplatformtick      yes       2>$null
& bcdedit /set useplatformclock     no        2>$null
& bcdedit /set tscsyncpolicy        enhanced  2>$null
& bcdedit /deletevalue useplatformclock       2>$null
$ErrorActionPreference = $prevEAP

# Global timer resolution (Windows 11 22H2+ respects this)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'GlobalTimerResolutionRequests' 1

# ===============================================================================
# 7. MEMORY - no compression, no prefetch, large system cache
# ===============================================================================
Write-Section 'Memory manager'

Disable-MMAgent -MemoryCompression -EA SilentlyContinue
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'LargeSystemCache'  0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'ClearPageFileAtShutdown' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' 'EnableSuperfetch' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' 'EnablePrefetcher'  0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' 'EnableBoottrace'   0

# ===============================================================================
# 8. NTFS - aggressive fast-paths
# ===============================================================================
Write-Section 'NTFS tuning'

$prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& fsutil behavior set DisableLastAccess     1
& fsutil behavior set disable8dot3          1
& fsutil behavior set memoryusage           2
& fsutil behavior set mftzone               4    2>$null
& fsutil behavior set disabledeletenotify   0
& fsutil behavior set encryptpagingfile     0    2>$null
$ErrorActionPreference = $prevEAP

# ===============================================================================
# 9. NETWORK - low-latency TCP + Nagle off + RSS
# ===============================================================================
Write-Section 'Network stack'

$prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& netsh int tcp set global autotuninglevel=normal        2>$null
& netsh int tcp set global rss=enabled                   2>$null
& netsh int tcp set global ecncapability=disabled         2>$null
& netsh int tcp set global timestamps=disabled            2>$null
& netsh int tcp set global nonsackrttresiliency=disabled  2>$null
& netsh int tcp set global maxsynretransmissions=2        2>$null
& netsh int tcp set global initialRto=2000                2>$null
& netsh int tcp set global fastopen=enabled               2>$null
& netsh int tcp set global hystart=enabled                2>$null
& netsh int tcp set supplemental template=custom icw=10   2>$null
$ErrorActionPreference = $prevEAP

# Global TCP params
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'DefaultTTL'         64
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'MaxUserPort'         65534
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'TcpTimedWaitDelay'   30

# Per-adapter: Nagle off, fast ACKs
Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object {
    $rawGuid = $_.InterfaceGuid
    # Ensure braced format {GUID}
    if ($rawGuid -is [guid]) { $guid = '{' + $rawGuid.ToString() + '}' }
    elseif ($rawGuid -match '^[{]') { $guid = $rawGuid }
    else { $guid = '{' + $rawGuid + '}' }
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
    Set-Reg $path 'TcpAckFrequency' 1
    Set-Reg $path 'TCPNoDelay'      1
    Set-Reg $path 'TcpDelAckTicks'  0

    # Disable NIC power management
    $nic = Get-PnpDevice -InstanceId $_.PnPDeviceID -EA SilentlyContinue
    if ($nic) {
        $nicPower = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($nic.InstanceId)\Device Parameters"
        if (Test-Path $nicPower) {
            Set-Reg $nicPower 'PnPCapabilities' 0x18  # suppress power management
        }
    }

    # Adapter advanced: disable offloads that add latency, enable RSS
    $name = $_.Name
    @('Interrupt Moderation','Energy-Efficient Ethernet','Green Ethernet',
      'Power Saving Mode','Ultra Low Power Mode','Reduce Speed On Power Down',
      'Wake on Magic Packet','Wake on Pattern Match') | ForEach-Object {
        Set-NetAdapterAdvancedProperty -Name $name -DisplayName $_ -DisplayValue 'Disabled' -EA SilentlyContinue
    }
    Set-NetAdapterAdvancedProperty -Name $name -DisplayName 'Receive Side Scaling' -DisplayValue 'Enabled' -EA SilentlyContinue
}

# ===============================================================================
# 10. VISUAL EFFECTS - stripped to minimum
# ===============================================================================
Write-Section 'Visual effects: best performance'

Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'  'VisualFXSetting'    2
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'       'TaskbarAnimations'  0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'       'ListviewAlphaSelect' 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'       'ListviewShadow'     0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'       'MenuShowDelay'      0
Set-Reg 'HKCU:\Control Panel\Desktop' 'UserPreferencesMask' ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) 'Binary'
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'      'EnableTransparency' 0
Set-Reg 'HKCU:\Control Panel\Desktop'                                              'DragFullWindows'    '0' 'String'
Set-Reg 'HKCU:\Control Panel\Desktop\WindowMetrics'                                'MinAnimate'         '0' 'String'

# Startup delay: zero
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0

# ===============================================================================
# 11. GAME BAR / DVR - fully killed
# ===============================================================================
Write-Section 'Game Bar / DVR: disabled'

Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'    'AllowGameDVR'                  0
Set-Reg 'HKCU:\System\GameConfigStore'                          'GameDVR_Enabled'               0
Set-Reg 'HKCU:\System\GameConfigStore'                          'GameDVR_FSEBehaviorMode'       2
Set-Reg 'HKCU:\System\GameConfigStore'                          'GameDVR_HonorUserFSEBehaviorMode' 1
Set-Reg 'HKCU:\System\GameConfigStore'                          'GameDVR_DXGIHonorFSEWindowsCompatible' 1
Set-Reg 'HKCU:\System\GameConfigStore'                          'GameDVR_EFSEFeatureFlags'      0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\GameBar'                      'ShowStartupPanel'              0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\GameBar'                      'GamePanelStartupTipIndex'      3
Set-Reg 'HKCU:\SOFTWARE\Microsoft\GameBar'                      'AllowAutoGameMode'             1
Set-Reg 'HKCU:\SOFTWARE\Microsoft\GameBar'                      'AutoGameModeEnabled'           1
Set-Reg 'HKCU:\SOFTWARE\Microsoft\GameBar'                      'UseNexusForGameBarEnabled'     0

# ===============================================================================
# 12. SERVICES - strip background overhead
# ===============================================================================
Write-Section 'Disabling unnecessary services'

@(
    'SysMain',          # Superfetch
    'WSearch',          # Windows Search indexer
    'DiagTrack',        # Telemetry
    'dmwappushsvc',     # WAP push
    'MapsBroker',       # Offline maps
    'PcaSvc',           # Program Compatibility Assistant
    'lfsvc',            # Geolocation
    'WerSvc',           # Error Reporting
    'Fax',              # Fax
    'RetailDemo',       # Retail demo
    'wisvc',            # Windows Insider
    'TabletInputService' # Touch keyboard (if no touch screen)
) | ForEach-Object { Disable-Svc $_ }

# Delivery Optimization: LAN only (0 = off, 1 = LAN)
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' 'DODownloadMode' 0

# ===============================================================================
# 13. TELEMETRY & BACKGROUND NOISE - silenced
# ===============================================================================
Write-Section 'Telemetry & scheduled task cleanup'

Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0

# Disable noisy scheduled tasks
$tasksToDisable = @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
    '\Microsoft\Windows\Autochk\Proxy',
    '\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem'
)
$prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
foreach ($t in $tasksToDisable) {
    & schtasks /Change /TN $t /Disable 2>$null
}
$ErrorActionPreference = $prevEAP

# ===============================================================================
# 14. USB POWER MANAGEMENT - all hubs always on
# ===============================================================================
Write-Section 'USB power management: disabled'

Get-PnpDevice -Class USB -Status OK -EA SilentlyContinue | ForEach-Object {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.InstanceId)\Device Parameters"
    if (Test-Path $path) {
        Set-Reg $path 'EnhancedPowerManagementEnabled' 0
        Set-Reg $path 'AllowIdleIrpInD3'               0
        Set-Reg $path 'SelectiveSuspendEnabled'         0
    }
}

# ===============================================================================
# 15. RESERVED STORAGE - reclaim space
# ===============================================================================
Write-Section 'Reserved storage: off'
$prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& dism /Online /Set-ReservedStorageState /State:Disabled 2>$null
$ErrorActionPreference = $prevEAP

# ===============================================================================
# DONE - reboot
# ===============================================================================
Write-Host "`n[OK] All optimizations applied. Rebooting in 10 seconds..." -ForegroundColor Green
Write-Host '  Press Ctrl+C to cancel reboot.' -ForegroundColor Yellow
Start-Sleep -Seconds 10
Restart-Computer -Force
```