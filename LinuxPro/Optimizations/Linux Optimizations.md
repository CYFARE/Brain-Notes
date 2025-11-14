# Debian Optimizations

## Reduce SSD writes

```bash
# /etc/fstab
noatime,nodiratime,discard
```

## Use RAM Instead of disk for temp and log files

```bash
# /etc/fstab

tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
tmpfs /var/spool tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
```

## Sysctl Optimizations

For any: VM or Host system:

TCP, UDP and System Optimizations:

```bash
# /etc/sysctl.conf - High Performance Gaming/Low-Latency Configuration (Modern Kernel)

# ===== NETWORK STACK OPTIMIZATION =====

# Increase socket buffer maximums for high-bandwidth scenarios
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432

# TCP buffer auto-tuning (min default max)
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 87380 33554432

# Enable window scaling for high-speed links
net.ipv4.tcp_window_scaling = 1

# Enable timestamps for better RTT measurement (PAWS)
net.ipv4.tcp_timestamps = 1

# Enable Path MTU Discovery to prevent fragmentation
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_base_mss = 1400

# Use BBR for low latency + high throughput (Linux 4.9+)
net.ipv4.tcp_congestion_control = bbr

# Disable slow start after idle for better burst performance
net.ipv4.tcp_slow_start_after_idle = 0

# Enable Selective Acknowledgment for better loss recovery
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1

# Increase TIME_WAIT socket handling
net.ipv4.tcp_max_tw_buckets = 200000

# Increase orphan socket limit
net.ipv4.tcp_max_orphans = 65536

# UDP buffer tuning
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.udp_mem = 16777216 16777216 33554432

# Connection backlog tuning
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 4096

# Safe socket reuse
net.ipv4.tcp_tw_reuse = 1

# ===== MEMORY MANAGEMENT =====

# Aggressive dirty page writeback for responsiveness
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# Minimize swap usage
vm.swappiness = 5

# Reduce dentry cache pressure
vm.vfs_cache_pressure = 50

# Increase mmap limits for applications (Steam, etc.)
vm.max_map_count = 4194304

# Reserve adequate free memory (adjust based on RAM: 1-2% of total)
# For 16GB RAM = 262144, 32GB = 524288, 64GB = 1048576
vm.min_free_kbytes = 524288

# Disable zone reclaim to avoid NUMA stalls on single-node systems
vm.zone_reclaim_mode = 0

# Improve page fault handling
vm.page-cluster = 3

# Allow memory overcommit for games that pre-allocate
vm.overcommit_memory = 1
vm.overcommit_ratio = 50

# ===== CPU SCHEDULER (Modern Kernel 5.x+) =====

# Enable realtime scheduling for audio/gaming
kernel.sched_rt_runtime_us = 1000000

# Disable NUMA balancing for single-socket systems
kernel.numa_balancing = 0

# Modern kernels removed sched_latency/granularity parameters
# They now use a different tuning mechanism. Instead, use:
kernel.sched_migration_cost_ns = 500000

# ===== SYSTEM-WIDE LIMITS =====

# Maximum threads
kernel.threads-max = 1000000

# Maximum open files
fs.file-max = 2000000
fs.nr_open = 2000000

# ===== FILE SYSTEM & I/O =====

# Improve inotify for game launchers (Steam, Epic)
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 1048576

# ===== ADDITIONAL GAMING OPTIMIZATIONS =====

# Reduce input lag by prioritizing I/O completion
# Note: sched_wakeup_granularity removed in kernel 5.x
# Use cpuset/schedtune if you need fine-grained control

# ===== NOTES =====

# The following parameters were removed in modern kernels:
# - kernel.sched_latency_ns
# - kernel.sched_min_granularity_ns
# - kernel.sched_wakeup_granularity_ns
# Modern CFS scheduler has improved heuristics and these manual tunings
# are no longer necessary or available.

# For CPU frequency scaling, use:
# cpufreq performance governor or intel_pstate=active,performance
```

```bash
sudo sysctl -p
```

## Prioritise "reads" over "writes" - deadline

- use the following only if you want to turn off kernel security

```bash
# /etc/default/grub

GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nvme_load=YES zswap.enabled=0 splash loglevel=3 elevator=none ibpb=off ibrs=off kpti=off l1tf=off mds=off mitigations=off no_stf_barrier noibpb noibrs nopcid nopti nospec_store_bypass_disable nospectre_v1 nospectre_v2 pcid=off pti=off spec_store_bypass_disable=off spectre_v2=off stf_barrier=off threadirqs rcu_nocbs=1-7 nohz_full=1-7 intel_pstate=active intel_pstate=no_hwp i915.force_probe=8086:a788 xe.force_probe=8086:a788 hugepages=128 transparent_hugepage=never nmi_watchdog=0 skew_tick=1 tsc=reliable clocksource=tsc isolcpus=1-7 idle=poll nohz=on irqaffinity=0 i915.enable_guc=3 i915.enable_psr=0 usbcore.autosuspend=-1 nvme_core.multipath=N"

# add the following for Intel P-States driver

"intel_pstate=active intel_pstate=no_hwp"
```

- Use `elevator=deadline` if not using NVMe SSD - aggressive but not as aggressive as none.

## Reduce grub load time

```bash
GRUB_TIMEOUT=2

sudo update-grub

# For ZFS (CachyOS)
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Remove unnecessary language grab from aptitude

```bash
Acquire::Languages "none";
```

## TLP for reduced heating & perf improvement

DO NOT USE on bare metal installs - causes screen freeze for many users.

## Preload for improved cache management

```bash
sudo apt install -y preload && sudo preload
```

## Screen Tear Fix 1 - Compton

Does not work on KVM!

Installation:

```bash
sudo apt -y install compton && xfconf-query -c xfwm4 -p /general/use_compositing -s false
```

After Installation, add the following command to startup applications:

```bash
compton --backend glx --paint-on-overlay --vsync opengl-swc --no-fading-openclose
```

## Screen Tear Fix 2 - Nvidia

Follow the driver installation for kali linux / or other debian distros:
https://www.kali.org/docs/general-use/install-nvidia-drivers-on-kali-linux/

Set the nvidia powermizer settings to be 'maximum performance' mode. Add this command to startup applications (like we did for compton) :

```bash
nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
```

## Screen Freeze Fix

#### Intel Microcode & nonfree Firmware
We will install intel microsode and others and disable noveau if not already done after nvidia driver installation. 

Install the packages:

```bash
sudo apt install intel-microcode firmware-misc-nonfree
```

### Disable Noveau

Disable noveau AFTER your nvidia prop. drivers are working (check using ```nvidia-smi``` command):

1. Check if any file with *noveau blacklist* name exists inside ```/etc/modprobe.d/```
2. If not exists, create one: ```sudo touch /etc/modprobe.d/nvidia-blacklists-nouveau.conf```
3. If exists, rename it as ```nvidia-blacklists-nouveau.conf```

Now edit the content of this file using the following command:

```bash
sudo nano /etc/modprobe.d/nvidia-blacklists-nouveau.conf
```

Content should be:

```bash
blacklist nouveau
options nouveau modeset=0
```

Save the file and run the following command:

```bash
sudo update-initramfs -u
```

### Remove TLP

```bash
sudo apt remove --purge tlp tlp-rdw
```

### Extra Modprobe Configurations

Use only if facing specific issues!

Intel microcode blacklist file location:

```bash
/etc/modprobe.d/intel-microcode-blacklist.conf
```

Intel microcode blacklist file content:

```bash
# The microcode module attempts to apply a microcode update when
# it autoloads.  This is not always safe, so we block it by default.
blacklist microcode
```

Save and run following command:

```bash
sudo update-initramfs -u
```

AMD microcode blacklist file location:

```bash
/etc/modprobe.d/amd64-microcode-blacklist.conf
```

AMD microcode blacklist file content:

```bash
# The microcode module attempts to apply a microcode update when
# it autoloads.  This is not always safe, so we block it by default.
blacklist microcode
```

Save and run following command:

```bash
sudo update-initramfs -u
```

## LibreOffice optimizations

1. Disable animated images and text
2. Disbale use of OpenCL
3. Disable app popups
5. Enable hardware acceleration

See *[[App Optimizations]]* for security customizations.

## LIbrewolf/Firefox Ugly Font Fix

Install mscore fonts :

```
sudo apt install ttf-mscorefonts-installer fonts-liberation fonts-liberation2 fonts-noto-cjk fonts-noto-color-emoji fonts-noto-mono fonts-noto-ui-extra fonts-roboto fonts-symbola
```

Create the following file (change librewolf directory to FF, check your app name using ```flatpak list```):

```bash
~/.var/app/io.gitlab.librewolf-community/config/fontconfig
```

Add the following code inside:

```xml
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
    <!-- Disable bitmap fonts. -->
    <selectfont><rejectfont><pattern>
        <patelt name="scalable"><bool>false</bool></patelt>
    </pattern></rejectfont></selectfont>
</fontconfig>

```

## Xanmod Kernel

### Install Kernel

- View the latest install instructions at: https://xanmod.org/#apt_repository
- As of 2023, use the following commands one by one in terminal to install xanmod kernel:

```bash
# 1. Add PGP Key
wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg

# 2. Add Repository
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list

# 3. Install Kernel
sudo apt update && sudo apt install linux-xanmod-x64v3
```

- Reboot and check using: `neofetch` command in terminal

### Which Version To Choose?

- Xanmod comes in 3 flavors:
	- Rolling Release (MAIN)
	- Long Term Support (LTS)
	- Stable Real-time (RT)

- MAIN is the BEST option for most system and it's a rolling release kernel
- DO NOT use RT unless you are using microcontrollers and similar stuff that requires "real-time clock as in 1700.00192883311hrs = 1700.00192883311hrs kind of accurate time". RT does not mean your kernel is faster. Infact, for everyday use it creates overhead. Flight systems and such critical infrastructure's "targetted" systems may use RT kernel.
- LTS should be used by servers or if you have BULLSHIT VIDEO CARD LIKE NVIDIA. Because Nvidia drivers break with each latest kernel for many devices, especially GARBAGE manufacturers like HP, Lenovo, DELL (the most extreme garbage compatibility even with WIndoze OS) - statement true as of 2023

### Udev Rules for Xanmod Kernel

Finetuning `bfq` scheduler:

- `sudo nano /etc/udev/rules.d/60-ioschedulers.rules`

```
# Set low_latency to 1 for the bfq scheduler on the specified device
ACTION=="add|change", KERNEL=="nvme0n1", ATTR{queue/scheduler}="bfq", ATTR{queue/iosched/low_latency}="1"
```

- `sudo udevadm control --reload-rules && sudo udevadm trigger`

### Improvements

#### Processor Microcode

- For intel: `sudo apt install intel-microcode iucode-tool`
- For AMD: `sudo apt install amd64-microcode`
- Reboot

#### Cake Queuing Discipline (1st Option)

- /etc/sysctl.d/90-override.conf

```
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr
```

#### FQ-PIE Queuing Discipline (2nd Option)

- May improve network speed / latency improvements. However, it's debatable.
- In terminal: `echo 'net.core.default_qdisc = fq_pie' | sudo tee /etc/sysctl.d/90-override.conf`
- Reboot and check using: `tc qdisc show`

#### IRQ Affinity

```bash
# /etc/default/irqbalance

IRQBALANCE_ONESHOT=yes
IRQBALANCE_BANNED_CPUS=0-1
```

#### NVMe Optimizations

```bash
# /etc/udev/rules.d/71-nvme.rules
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="2048"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/io_poll}="1"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/io_poll_delay}="-1"
```

#### NVIDIA Optimizations

```bash
# /etc/modprobe.d/nvidia.conf

options nvidia NVreg_EnablePCIeGen3=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_InitializeSystemMemoryAllocations=0
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_EnableStreamMemOPs=1
options nvidia NVreg_RemapLimit=0x7fffffff
options nvidia NVreg_TemporaryFilePath=/var/tmp
options nvidia NVreg_EnableS0ixPowerManagement=1
options nvidia NVreg_EnablePCIERelaxedOrderingMode=1
options nvidia NVreg_EnableResizableBar=1
options nvidia NVreg_EnableGPUFirmware=1
options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
```

```bash
# ~/.profile

# OpenGL Performance
export __GL_SYNC_TO_VBLANK=0                  # Disable vsync for benchmarks
export __GL_THREADED_OPTIMIZATIONS=1          # Multi-threaded OpenGL
export __GL_YIELD=USLEEP                      # Reduce stutter in some games
export __GL_SHADER_DISK_CACHE=1               # Cache compiled shaders
export __GL_SHADER_DISK_CACHE_PATH=/var/tmp   # Fast shader cache location
export __GL_SHOW_GRAPHICS_OSD=0               # Disable overlay

# NVIDIA-Specific
export __NV_PRIME_RENDER_OFFLOAD=1            # For PRIME laptops
export __VK_LAYER_NV_optimus=NVIDIA_only      # Force NVIDIA on hybrid systems

# Vulkan Performance
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
export DISABLE_VK_LAYER_VALVE_steam_fossilize_1=1  # Disable if causing stutter

# Application Smoothness
export vblank_mode=0                          # Mesa vsync override
export CLUTTER_PAINT=disable-dynamic-max-render-time
```

