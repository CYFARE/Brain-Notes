#!/usr/bin/env bash
#
# kvm-setup-cachyos.sh — full-featured KVM/QEMU + libvirt + virt-manager
# setup for CachyOS (Arch-based). Run as your normal user, NOT as root.
#
# v2 — verified against Arch repos (2026-08): dropped packages removed,
#      resilient to unrelated upgrade blockers (e.g. pinned NVIDIA stacks),
#      libvirtd left resident to avoid the socket-activation timeout race.

set -euo pipefail

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

# ---------- preflight ----------
[ "$(id -u)" -ne 0 ] || die "Run this as your normal user, not root."
command -v pacman >/dev/null || die "pacman not found — CachyOS/Arch only."
sudo -v || die "sudo privileges required."
grep -Eq '(vmx|svm)' /proc/cpuinfo \
  || die "No VT-x/AMD-V flag. Enable hardware virtualization in BIOS/UEFI first."

USER_NAME="$(id -un)"
GROUP_NAME="$(id -gn)"

# ---------- 1. packages ----------
pkgs=(
  # --- core hypervisor & management (replaces qemu-kvm, qemu, qemu-utils, libvirt-clients) ---
  qemu-full
  libvirt
  virt-manager      # GUI; also ships virt-install / virt-clone
  virt-viewer
  # --- firmware & emulation extras ---
  edk2-ovmf         # UEFI firmware for VMs (Debian: ovmf)
  swtpm             # TPM 2.0 emulator — Windows 11 guests
  # --- networking ---
  dnsmasq           # DHCP/DNS for the default NAT network (virbr0)
  iptables          # core; already includes the nft backend + ebtables-nft
  nftables
  radvd
  # --- virt-manager support bits ---
  dmidecode
  libosinfo
  spice-vdagent
  # --- nice-to-have ---
  virtiofsd         # host<->guest shared folders (virtio-fs)
  guestfs-tools     # virt-customize, virt-sysprep, virt-resize, ...
  # virtio-win      # uncomment: Windows guest drivers ISO (/usr/share/virtio-win/)
  # libayatana-appindicator  # uncomment: virt-manager tray icon support
)
# NOTE: bridge-utils and libhugetlbfs were dropped from the Arch repos —
# iproute2 (preinstalled) covers bridging, and libvirt manages virbr0 itself.

info "Updating system and installing the KVM stack…"
if ! sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"; then
  warn "Full system upgrade failed (unrelated pinned packages, e.g. an NVIDIA"
  warn "version lock). Falling back to installing only the KVM packages."
  warn "Resolve the blocker later and run: sudo pacman -Syu"
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
fi

# ---------- 2. services ----------
info "Enabling libvirtd at boot…"
sudo systemctl enable libvirtd.service

# ---------- 3. KVM without root ----------
info "Configuring /etc/libvirt/qemu.conf to run QEMU as $USER_NAME:$GROUP_NAME …"
sudo cp -n /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf.bak 2>/dev/null || true
sudo sed -i -E "s/^#?\s*user\s*=\s*\".*\"/user = \"$USER_NAME\"/"   /etc/libvirt/qemu.conf
sudo sed -i -E "s/^#?\s*group\s*=\s*\".*\"/group = \"$GROUP_NAME\"/" /etc/libvirt/qemu.conf

info "Adding $USER_NAME to the kvm and libvirt groups…"
sudo usermod -aG kvm "$USER_NAME"
sudo usermod -aG libvirt "$USER_NAME"
# libvirt group + libvirt's shipped polkit rule = passwordless qemu:///system.

# (Re)start via the SERVICE, not socket activation: a service-started libvirtd
# stays resident, while a socket-activated one self-terminates after 120 idle
# seconds — the cause of virt-manager's "Connection reset by peer" race.
info "Starting libvirtd (resident)…"
sudo systemctl restart libvirtd.service

# ---------- 4. default connection URI ----------
info "Setting qemu:///system as the default libvirt URI…"
mkdir -p ~/.config/libvirt
touch ~/.config/libvirt/libvirt.conf
grep -q 'uri_default' ~/.config/libvirt/libvirt.conf \
  || echo 'uri_default = "qemu:///system"' >> ~/.config/libvirt/libvirt.conf

# ---------- 5. networking ----------
# AppArmor is not active on CachyOS by default; apply the Debian-style
# dnsmasq profile fix only if it actually is.
if [ -d /sys/kernel/security/apparmor ] && command -v aa-status >/dev/null 2>&1; then
  info "AppArmor detected — applying dnsmasq profile fix…"
  tmp="$(mktemp)"
  curl -fsSL "https://gitlab.com/apparmor/apparmor/-/raw/master/profiles/apparmor.d/usr.sbin.dnsmasq" -o "$tmp"
  sudo mv "$tmp" /etc/apparmor.d/usr.sbin.dnsmasq
  sudo sed -i 's#/usr/libexec/libvirt_leaseshelper m,#/usr/libexec/libvirt_leaseshelper mr,#g' \
    /etc/apparmor.d/usr.sbin.dnsmasq
  sudo systemctl reload apparmor 2>/dev/null || true
else
  info "AppArmor not active — skipping dnsmasq profile fix (not needed on CachyOS)."
fi

info "Ensuring the default NAT network (virbr0, 192.168.122.0/24) is up and autostarted…"
if ! sudo virsh net-info default >/dev/null 2>&1; then
  if [ -f /usr/share/libvirt/networks/default.xml ]; then
    sudo virsh net-define /usr/share/libvirt/networks/default.xml
  else
    warn "No default network found — create one in virt-manager (Edit → Connection Details → Virtual Networks)."
  fi
fi
sudo virsh net-autostart default 2>/dev/null || true
if ! sudo virsh net-info default 2>/dev/null | grep -q '^Active:\s*yes'; then
  sudo virsh net-start default 2>/dev/null || true
fi

# ---------- 6. verification ----------
info "Running host validation…"
sudo virt-host-validate qemu || warn "Review the validation output above."

info "libvirtd status: $(systemctl is-active libvirtd.service) (resident: $(ps -o args= -C libvirtd | grep -c -v -- '--timeout' || true) instance without idle-timeout)"

if virsh -c qemu:///system list --all >/dev/null 2>&1; then
  ok "qemu:///system already connects as $USER_NAME (no sudo)."
else
  warn "User-session connection will work after re-login (group membership not active yet)."
fi

cat <<EOF

$(ok) KVM setup complete.

  • libvirtd is enabled at boot and running resident (no 120s idle timeout),
    so virt-manager connects instantly — no more "Connection reset by peer".
  • Your user is in the 'kvm' and 'libvirt' groups — takes effect after a
    fresh login (reboot is easiest).
  • Afterwards verify with:  virsh list --all     # works WITHOUT sudo
  • Default NAT network (virbr0) is active and autostarts on boot.
  • UEFI (edk2-ovmf) and TPM 2.0 (swtpm) are selectable in virt-manager,
    so Windows 11 installs work out of the box.

EOF

read -rp "Reboot now to apply group membership? [y/N] " ans
if [[ "${ans,,}" == "y" ]]; then
  sudo systemctl reboot
else
  warn "Log out/in (or reboot) before using virt-manager, or you'll get a permission error on qemu:///system."
fi
