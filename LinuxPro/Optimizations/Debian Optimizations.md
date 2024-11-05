# Debian Optimizations

1. In /etc/fstab

## Reduce SSD writes

```
noatime,nodiratime,discard
```

## Use RAM Instead of disk for temp and log files

```
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,noatime,mode=0755 0 0
tmpfs /var/spool tmpfs defaults,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,noatime,mode=1777 0 0
```

2. /etc/sysctl.conf

## Sysctl Optimizations

For any: VM or Host system:

TCP, UDP and System Optimizations:

```
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem="4096 87380 16777216"
net.ipv4.tcp_wmem="4096 87380 16777216"
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_base_mss=1460
net.ipv4.tcp_congestion_control=westwood+
net.ipv4.tcp_slow_start_after_idle=1
net.ipv4.tcp_sack=0
net.ipv4.tcp_max_tw_buckets=200000
net.ipv4.tcp_max_orphans=200000
net.ipv4.udp_rmem_min=4096
net.ipv4.udp_wmem_min=4096
net.ipv4.udp_rmem_def=87380
net.ipv4.udp_wmem_def=87380
net.ipv4.udp_rmem_max=16777216
net.ipv4.udp_wmem_max=16777216
net.ipv4.udp_checksum=1
net.ipv4.udp_mem=16777216 16777216 16777216
net.ipv4.udp_frag=1
net.ipv4.udp_checksum_verify=0
net.ipv4.udp_timeout=300
net.core.netdev_max_backlog=10000
net.core.somaxconn=1024
net.ipv4.tcp_max_syn_backlog=1024
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_tw_recycle=1
vm.dirty_ratio=10
vm.dirty_background_ratio=5
vm.swappiness=10
vm.vfs_cache_pressure=50
kernel.sched_latency_ns=1000000
kernel.sched_migration_cost_ns=50000
kernel.sched_min_granularity_ns=1000000
vm.overcommit_memory=1
vm.overcommit_ratio=50
fs.file-max=1000000
fs.nr_open=1000000
kernel.threads-max=1000000
vm.max_map_count=262144
```

```bash
sudo sysctl -p
```


3. /etc/default/grub

## Prioritize "reads" over "writes" - deadline

```
elevator=deadline
```

## Reduce grub load time

```
GRUB_TIMEOUT=2

sudo update-grub
```

## Remove unnecessary language grab from aptitude

```
Acquire::Languages "none";
```

## TLP for reduced heating & perf improvement

DO NOT USE on bare metal installs - causes screen freeze for many users.

## Preload for improved cache management

```
sudo apt install -y preload && sudo preload
```

## Screen Tear Fix 1 - Compton

Does not work on KVM!

Installation:

```
sudo apt -y install compton && xfconf-query -c xfwm4 -p /general/use_compositing -s false
```

After Installation, add the following command to startup applications:

```
compton --backend glx --paint-on-overlay --vsync opengl-swc --no-fading-openclose
```

## Screen Tear Fix 2 - Nvidia

Follow the driver installation for kali linux / or other debian distros:
https://www.kali.org/docs/general-use/install-nvidia-drivers-on-kali-linux/

Set the nvidia powermizer settings to be 'maximum performance' mode. Add this command to startup applications (like we did for compton) :

```
nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
```

## Screen Freeze Fix

#### Intel Microcode & nonfree Firmware
We will install intel microsode and others and disable noveau if not already done after nvidia driver installation. 

Install the packages:
```
sudo apt install intel-microcode firmware-misc-nonfree
```

### Disable Noveau

Disable noveau AFTER your nvidia prop. drivers are working (check using ```nvidia-smi``` command):

1. Check if any file with *noveau blacklist* name exists inside ```/etc/modprobe.d/```
2. If not exists, create one: ```sudo touch /etc/modprobe.d/nvidia-blacklists-nouveau.conf```
3. If exists, rename it as ```nvidia-blacklists-nouveau.conf```

Now edit the content of this file using the following command:

```
sudo nano /etc/modprobe.d/nvidia-blacklists-nouveau.conf
```

Content should be:

```
blacklist nouveau
options nouveau modeset=0
```

Save the file and run the following command:

```
sudo update-initramfs -u
```

### Remove TLP

```
sudo apt remove --purge tlp tlp-rdw
```

### Extra Modprobe Configurations

Use only if facing specific issues!

Intel microcode blacklist file location:

```
/etc/modprobe.d/intel-microcode-blacklist.conf
```

Intel microcode blacklist file content:

```
# The microcode module attempts to apply a microcode update when
# it autoloads.  This is not always safe, so we block it by default.
blacklist microcode
```

Save and run following command:

```
sudo update-initramfs -u
```

AMD microcode blacklist file location:

```
/etc/modprobe.d/amd64-microcode-blacklist.conf
```

AMD microcode blacklist file content:

```
# The microcode module attempts to apply a microcode update when
# it autoloads.  This is not always safe, so we block it by default.
blacklist microcode
```

Save and run following command:

```
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
sudo apt install ttf-mscorefonts-installer
```

Create the following file (change librewolf directory to FF, check your app name using ```flatpak list```):

```
~/.var/app/io.gitlab.librewolf-community/config/fontconfig
```

Add the following code inside:

```
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

### Improvements

#### Processor Microcode

- For intel: `sudo apt install intel-microcode iucode-tool`
- For AMD: `sudo apt install amd64-microcode`
- Reboot

#### FQ-PIE Queing Discipline

- May improve network speed / latency improvements. However, it's debatable.
- In terminal: `echo 'net.core.default_qdisc = fq_pie' | sudo tee /etc/sysctl.d/90-override.conf`
- Reboot and check using: `tc qdisc show`
