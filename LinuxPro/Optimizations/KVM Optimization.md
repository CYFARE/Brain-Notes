# KVM Optimization

## CPU Optimization

- Configurations = Copy Host CPU Configurations
- Topology = Manually set CPU topology
	- Socket = 1
	- Cores = Half or more than host Logical host CPUs
	- Threads = 1

## Clock Optimization

- In XML configuration, replace the associated `<clock>` config as below:

```xml
<clock offset="localtime">
	<timer name="hpet" present="no"/>
	<timer name="hypervclock" present="no"/>
</clock>
```

## CPU Pinning

- It's not usually recommended to perform this unless you have a potatoe system. This also requires a multithreaded host. Spare yourself the hastle.
- View CPU architecture using command: `lstopo`
- If command does not exist, then install it using below command and run lstopo again:

```bash
sudo apt install hwloc
```

Depending on your CPU architecture, add the following options to the XML file:

```xml
<iothreads>1</iothreads>
  <cputune>
  	<vcpupin vcpu="0" cpuset="2"/>
	<vcpupin vcpu="1" cpuset="3"/>
	<vcpupin vcpu="2" cpuset="4"/>
	<vcpupin vcpu="3" cpuset="5"/>
	<emulatorpin cpuset="0-1"/>
	<iothreadpin iothread="1" cpuset="0-1"/>
  </cputune>
```

# Warninig! Do Not Attempt!

This section is not properly working and may result in host system being corrupted if you don't know what you are doing! DO NOT ATTEMPT WITHOUT EXPERT LINUX KNOWLEDGE.

## GPU Passthrough for PopOS

### Check System Requirements

- Check if CPU virtualization is enabled using:

```bash
sudo dmesg | grep -i "VT-d"
```

### Add IOMMU

- Add IOMMU kernel stub:

```bash
sudo kernelstub --add-options "intel_iommu=on"
```

- Restart system
- Create a bash script called: `iommu.sh` in ~/ directory and add the following lines to it:

```bash
#!/bin/bash
for d in /sys/kernel/iommu_groups/*/devices/*; do
  n=${d#*/iommu_groups/*}; n=${n%%/*}
  printf 'IOMMU Group %s ' "$n"
  lspci -nns "${d##*/}"
done
```

- Run the script with command:

```bash
bash iommu.sh | grep -i "VGA"
```

- Output will be like:

```
IOMMU Group 0 00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-P Integrated Graphics Controller [8086:46a6] (rev 0c)

IOMMU Group 12 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA107BM [GeForce RTX 3050 Ti Mobile] [10de:25e0] (rev a1)
```

If the group numbers for Nvidia and Intel controller are different, then it's good to go further.

### Libvert Hooks

Run following commands:

```bash
sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' \
 -O /etc/libvirt/hooks/qemu
```

```bash
sudo chmod +x /etc/libvirt/hooks/qemu
```

```bash
sudo service libvirtd restart
```

### Hooks Structure

```
# Before a VM is started, before resources are allocated:
/etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/*

# Before a VM is started, after resources are allocated:
/etc/libvirt/hooks/qemu.d/$vmname/start/begin/*

# After a VM has started up:
/etc/libvirt/hooks/qemu.d/$vmname/started/begin/*

# After a VM has shut down, before releasing its resources:
/etc/libvirt/hooks/qemu.d/$vmname/stopped/end/*

# After a VM has shut down, after resources are released:
/etc/libvirt/hooks/qemu.d/$vmname/release/end/*
```

After everything is setup, tree folder structure will be:

```
$ tree /etc/libvirt/hooks/
/etc/libvirt/hooks/
├── qemu
└── qemu.d
    └── win10
        ├── prepare
        │   └── begin
        └── release
            └── end
```

#### Creating Hooks

##### Controller Address Conversion

- From the ~/ directory where `iommu.sh` is stores, run:

```bash
bash iommu.sh | grep -i "nvidia" | grep -i "VGA"
```

- Output should be similar to this:

```
IOMMU Group 12 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA107BM [GeForce RTX 3050 Ti Mobile] [10de:25e0] (rev a1)
```

- Now we see after `Group 12` there is a line with number `01:00.0`, so out controller real address name will be: `pci_0000_` followed by `_01_00_0`.
- Final derived controller address: `pci_0000_01_00_0`

##### KVM Configuration

- Create a file named `kvm.conf` and place it under `/etc/libvirt/hooks/`. Add the following entries to the file:

```
## Virsh devices
VIRSH_GPU_VIDEO=pci_0000_01_00_0
```

- We can add other passthrough such as SSD, USB, Audio etc.. For each of these, find the controller using `iommu.sh`,  translate the address and add to configuration file. 
- Sample configuration with other passthrough:

```
## Virsh devices
VIRSH_GPU_VIDEO=pci_0000_0a_00_0
VIRSH_GPU_AUDIO=pci_0000_0a_00_1
VIRSH_GPU_USB=pci_0000_0a_00_2
VIRSH_GPU_SERIAL=pci_0000_0a_00_3
VIRSH_NVME_SSD=pci_0000_04_00_0
```

##### VFIO Bind & Unbind

- Create 2 scripts under `/etc/libvirt/hooks` called: `bind_vfio.sh` and `bind_vfio.sh`

- `bind_vfio.sh` will have:

```
#!/bin/bash

## Load the config file
source "/etc/libvirt/hooks/kvm.conf"

## Load vfio
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_pci

## Unbind gpu from nvidia and bind to vfio
virsh nodedev-detach $VIRSH_GPU_VIDEO
```

- `unbind_vfio.sh` will have:

```
#!/bin/bash

## Load the config file
source "/etc/libvirt/hooks/kvm.conf"

## Unbind gpu from vfio and bind to nvidia
virsh nodedev-reattach $VIRSH_GPU_VIDEO

## Unload vfio
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
```

- Give permissions to these 2 files using:

```bash
sudo chmod +x bind_vfio.sh && sudo chmod +x unbind_vfio.sh
```

- Make directory structure to look like this:

```
$ tree /etc/libvirt/hooks/
/etc/libvirt/hooks/
├── kvm.conf
├── qemu
└── qemu.d
    └── win10
        ├── prepare
        │   └── begin
        │       └── bind_vfio.sh
        └── release
            └── end
                └── unbind_vfio.sh
```

### Create Win10 Machine

#### Create Hugepages Malloc

- Create new file called `alloc_hugepages.sh` inside: `/etc/libvirt/hooks/qemu.d/win10/prepare/begin/` & `dealloc_hugepages.sh` inside `/etc/libvirt/hooks/qemu.d/win10/release/end/`

- alloc script will have:

```bash
#!/bin/bash

## Load the config file
source "/etc/libvirt/hooks/kvm.conf"

## Calculate number of hugepages to allocate from memory (in MB)
HUGEPAGES="$(($MEMORY/$(($(grep Hugepagesize /proc/meminfo | awk '{print $2}')/1024))))"

echo "Allocating hugepages..."
echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)

TRIES=0
while (( $ALLOC_PAGES != $HUGEPAGES && $TRIES < 1000 ))
do
    echo 1 > /proc/sys/vm/compact_memory            ## defrag ram
    echo $HUGEPAGES > /proc/sys/vm/nr_hugepages
    ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
    echo "Succesfully allocated $ALLOC_PAGES / $HUGEPAGES"
    let TRIES+=1
done

if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
then
    echo "Not able to allocate all hugepages. Reverting..."
    echo 0 > /proc/sys/vm/nr_hugepages
    exit 1
fi
```

- dealloc script will have:

```bash
#!/bin/bash

## Load the config file
source "/etc/libvirt/hooks/kvm.conf"

echo 0 > /proc/sys/vm/nr_hugepages
```

- Give permissions to these scripts using:

```bash
sudo chmod +x /etc/libvirt/hooks/qemu.d/win10/prepare/begin/alloc_hugepages.sh && sudo chmod +x /etc/libvirt/hooks/qemu.d/win10/release/end/dealloc_hugepages.sh
```

- Now create the VM and use this configuration
