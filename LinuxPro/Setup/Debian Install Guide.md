# Debian Installation Guide

## Downloading ISO Image

- Download Debian Stable ISO (NetInstall) from: https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/
- Direct Download Link (as of 2023): https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso
- You can download faster using axel (command line):

### Install axel

```bash
sudo apt install -y axel
```

### Download ISO using axel

```bash
cd Downloads && axel -n 32 https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso -o debian-12.10.0-netinst.iso
```

## Burning to USB

- Download Balena Etcher
- Insert USB (Sandisk 4GB minimum preffered)
- Make sure to clean & reformat USB before flashing (see section)
- Flash ISO to USB using Etcher


## Clean USB for flashing

- Insert USB

### On Windows

- Open CMD: Type `diskpart`
- Type the following commands:

```bash
list disk
select disk 1 (please change the number according your disk number!)
clean
create partition primary
assign letter=A
```

- Click on the USB partition using File Browser or simple remove and reinsert the USB
- Format options will appear. Format to FAT32!

### On GNU/Linux Systems

- Install gparted

```bash
sudo apt install -y gparted
```

- Open gparted: `sudo gparted`
- Select USB device
- Delete all partition first, then apply changes.. Error will occur, ignore all errors!
- Remove USB and insert again
- Refresh gparted menu
- Select USB and see partitions are gone. If not, then delete them. This time error will not occur
- You will have an empty partition. Now create new partition table to: `ms-dos` and apply
- Now format this partition to FAT32

## Using Debian Testing / Rolling Release

Debian testing is more stable than Arch's rolling releases, yet has most recent software, so it's a perfect mix to use for latest drivers and still not break the system!

Follow these easy steps in terminal:

### Update and dist-upgrade

```bash
sudo apt update && sudo apt dist-upgrade
```

- reboot / restart

### Clean APT

Not necessary, but it's a good practice to avoid any apt conflicts.

```bash
sudo apt update && sudo apt autoremove && sudo apt autoclean
```

### Change sources

```bash
cd ~/ && nano /etc/apt/sources.list
```

- Copy the following line:

```bash
deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware
```

- Comment everything else! DO NOT KEEP ANY OTHER SOURCE OPEN!
- Perform update & upgrade:

```bash
sudo apt update && sudo apt dist-upgrade
```

- reboot / restart
- done! Now you can apply Debian Optimizations using https://github.com/haxerzin/Brain-Notes/ for more faster performance!
