# KVM Setup Guide

- Automated Setup script: https://github.com/haxerzin/QuickKVM/
- KVM Optimization ( [[KVM Optimization]] )

## Host Setup

- It's better to use https://github.com/haxerzin/QuickKVM/ instead of manually doing all these steps.
- DO NOT enter root terminal. Being in root terminal to avoid typing 'sudo' makes you dumb. It breaks the architecture of most apps. GNU/Linux developers intend using sudo with their apps for a reason.

Install following packages:

```bash
sudo apt -y install qemu-kvm bridge-utils qemu virt-manager virt-viewer spice-vdagent libhugetlbfs-bin libvirt-clients qemu-utils virt-manager ovmf
```

- If you face error for 'qemu' or some package not found, remove the package from install list and rerun install. This issue occurs depending on distributions, it's minor stuff. Qemu will get installed.

### KVM without root access

Type the following one by one into terminal:

```
sudo sed -i "s/#user = \"root\"/user = \"$(id -un)\"/g" /etc/libvirt/qemu.conf

sudo sed -i "s/#group = \"root\"/group = \"$(id -gn)\"/g" /etc/libvirt/qemu.conf

sudo usermod -a -G kvm $(id -un)

sudo usermod -a -G libvirt $(id -un)

sudo systemctl restart libvirtd

sudo ln -s /etc/apparmor.d/usr.sbin.libvirtd /etc/apparmor.d/disable/
```

### Making networking available to KVM

Type the following commands into terminal:

```
wget https://gitlab.com/apparmor/apparmor/-/blob/master/profiles/apparmor.d/usr.sbin.dnsmasq -O ~/usr.sbin.dnsmasq

sudo mv ~/usr.sbin.dnsmasq /etc/apparmor.d/

sudo sed -i "s/\/usr\/libexec\/libvirt_leaseshelper m,/\/usr\/libexec\/libvirt_leaseshelper mr,/g" /etc/apparmor.d/usr.sbin.dnsmasq
```

### Create libvirt config

Type the following in terminal:

```
mkdir -p ~/.config/libvirt

echo "uri_default = \"qemu:///system\"" >> ~/.config/libvirt/libvirt.conf
```

Restart the system!

## VM Setup (Windows)

- Download virtio-win from: `https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/` 
- Download Windows 11 iso from Microsoft official website

### Windows 11 / 10

- We have 2 ISO files: one is `virtio` and other is `Windows11`. We have to ensure that KVM is properly setup and virt-manager is running. Follow the steps in this article: https://haxerz.in/blog/article.php (TO EDIT LINK)

## Cassowary Setup (Win10)

### Inside Windows Guest

- Turn on Remote Desktop using Settings/
- Download and extract ZIP: https://github.com/casualsnek/cassowary/releases/
- Click setup.bat

### Inside Linux Host

Download .whl file: https://github.com/casualsnek/cassowary/releases/ & open terminal in the location.

Type the following commands in terminal:
```
sudo apt install freerdp2-x11 python3-pip python3-libvirt

pip3 install PyQt5

pip install cassowary*

echo "PATH=\$PATH:$HOME/.local/bin" >> $HOME/.profile

python3 -m cassowary -a
```

## Optimize using Tuned

In Linux host and guest, install the following:
```
sudo apt update

sudo apt install tuned tuned-utils tuned-utils-systemtap
```

Check the status of `tuned` service using: 
```
systemctl status tuned
```

### Host Setup

Check your active profile using: `tuned-adm active` and change the profile for KVM maximum performance using: 
```
sudo tuned-adm profile virtual-host
```

### Guest Setup

Check your active profile using: `tuned-adm active` and change the profile for KVM maximum performance using: 
```
sudo tuned-adm profile virtual-guest
```

#### Enable clipboard on Linux Guest

```bash
sudo apt install spice-vdagent
```

## Qemu Image Operations

### Convert QCOW2 to VDI

```bash
qemu-img convert -O vdi /var/lib/libvirt/images/kali.qcow2 ~/Documents/kali.vdi
```

### Convert VDI to QCOW2

```bash
qemu-img convert -f vdi -O qcow2 ubuntu.vdi ubuntu.qcow2
```

### Expand Image SIze

```bash
qemu-img resize disk.qcow2 +10G
```
