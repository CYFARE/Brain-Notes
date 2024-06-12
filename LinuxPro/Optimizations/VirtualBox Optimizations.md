# VirtualBox Advance Optimization

## Expand VRAM to 256

VRAM or Video Memory can be increased to 256 MB (for windows hosts) by following these steps:

- Goto Display -> Screen
- Enable 3D Acceleration
- Click OK and close VirtualBox
- Now you have to go to: C:\Program Files\Oracle\VirtualBox and open command prompt OR open command prompt and `cd "C:\Program Files\Oracle\VirtualBox"`
- Type: `vboxmanage modifyvm "Name of virtual machine" --vram 256`

## Motherboard Options

- Goto System -> Motherboard
- Enable I/O APIC
- Enable Hardware Click in UTC Time

## Enable Nested Virtualization

- Goto System -> Processor
- Enable Nested VT-x/AMD-V

If your nested option is disabled, goto the Virtualbox installation directory from command prompt (as shown in step 1) and type the following command: `VBoxManage modifyvm "Name of virtual machine" --nested-hw-virt on`

## Overclocking 200% faster

Experimental!

- Goto virtualbox installed directory and type the following command: `VBoxManage setextradata "VM name" "VBoxInternal/TM/WarpDrivePercentage" 200`
