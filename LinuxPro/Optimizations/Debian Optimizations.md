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

## Reduced swappiness & changes to vfs cache pressure
```
vm.swappiness=0
vm.vfs_cache_pressure=50
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
Install mscore fonts 
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
