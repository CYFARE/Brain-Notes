#!/usr/bin/env bash
###############################################################################
# optimize_debian.sh - Extreme Performance Optimization for Debian/Kali Linux
# WARNING: This script disables security mitigations, aggressively tunes the
#          kernel, and makes changes that may cause instability. USE AT YOUR
#          OWN RISK. Snapshot/backup before running.
###############################################################################

set -euo pipefail
trap 'echo "[FATAL] Line $LINENO failed. Continuing..." >&2' ERR

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*"; }
info() { echo -e "${CYAN}[i]${NC} $*"; }

[[ $EUID -ne 0 ]] && { err "Run as root: sudo $0"; exit 1; }

BACKUP_DIR="/root/optimize_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
log "Backups → $BACKUP_DIR"

backup() {
    local f="$1"
    [[ -f "$f" ]] && cp -a "$f" "$BACKUP_DIR/$(basename "$f").bak" 2>/dev/null || true
}

# Detect hardware
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))
NUM_CPUS=$(nproc)
LAST_CPU=$((NUM_CPUS - 1))
HAS_NVIDIA=$(lspci 2>/dev/null | grep -qi nvidia && echo 1 || echo 0)
HAS_INTEL_GPU=$(lspci 2>/dev/null | grep -qi "VGA.*Intel" && echo 1 || echo 0)
HAS_NVME=$(ls /dev/nvme* 2>/dev/null | head -1 && echo 1 || echo 0)
IS_SSD=0
for d in /sys/block/sd*/queue/rotational; do
    [[ -f "$d" ]] && [[ $(cat "$d") -eq 0 ]] && IS_SSD=1
done

info "RAM: ${TOTAL_RAM_GB}GB | CPUs: $NUM_CPUS | NVIDIA: $HAS_NVIDIA | NVMe: $HAS_NVME"

# Calculate tuning values based on RAM
if (( TOTAL_RAM_GB >= 64 )); then
    MIN_FREE_KB=1048576; HUGEPAGES=512
elif (( TOTAL_RAM_GB >= 32 )); then
    MIN_FREE_KB=524288;  HUGEPAGES=256
elif (( TOTAL_RAM_GB >= 16 )); then
    MIN_FREE_KB=262144;  HUGEPAGES=128
else
    MIN_FREE_KB=131072;  HUGEPAGES=64
fi

###############################################################################
# 1. INSTALL DEPENDENCIES
###############################################################################
log "Installing performance packages..."
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq

# Check package availability before installing
pkg_available() {
    apt-cache show "$1" &>/dev/null 2>&1
}

PKGS=(
    # Build essentials
    build-essential dkms linux-headers-$(uname -r)
    # Performance tools
    cpufrequtils irqbalance tuned haveged
    # Monitoring
    htop iotop sysstat lm-sensors powertop
    # Networking
    ethtool iperf3 net-tools
    # Filesystem
    util-linux
    # Compression (fastest)
    lz4 zstd pigz pbzip2
    # Low-latency audio
    rtirq-init
    # Misc
    earlyoom schedtool gamemode
)

for pkg in "${PKGS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        if pkg_available "$pkg"; then
            apt-get install -y -qq "$pkg" 2>/dev/null || warn "Could not install: $pkg"
        else
            warn "Package not available in repos, skipping: $pkg"
        fi
    fi
done

###############################################################################
# 2. SYSCTL - EXTREME TUNING
###############################################################################
log "Applying extreme sysctl configuration..."
backup /etc/sysctl.conf

cat > /etc/sysctl.d/99-extreme-performance.conf << 'SYSCTL'
# ====== NETWORK - EXTREME ======
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr

# Massive buffers
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.ipv4.tcp_rmem = 4096 1048576 67108864
net.ipv4.tcp_wmem = 4096 1048576 67108864
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.ipv4.udp_mem = 65536 131072 262144

# Fast connection handling
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_base_mss = 1400
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_abort_on_overflow = 0
net.ipv4.tcp_max_tw_buckets = 400000
net.ipv4.tcp_max_orphans = 131072
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_ecn_fallback = 1
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_notsent_lowat = 16384

# Backlog
net.core.netdev_max_backlog = 65536
net.core.netdev_budget = 600
net.core.netdev_budget_usecs = 8000
net.core.somaxconn = 8192
net.core.optmem_max = 65536

# ARP
net.ipv4.neigh.default.gc_thresh1 = 2048
net.ipv4.neigh.default.gc_thresh2 = 4096
net.ipv4.neigh.default.gc_thresh3 = 8192

# Conntrack (for firewalled setups)
net.netfilter.nf_conntrack_max = 262144
net.netfilter.nf_conntrack_tcp_timeout_established = 600

# IPv6 disable (if not needed — saves overhead)
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1

# ====== MEMORY - EXTREME ======
vm.dirty_ratio = 10
vm.dirty_background_ratio = 3
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
vm.swappiness = 1
vm.vfs_cache_pressure = 30
vm.max_map_count = 16777216
vm.overcommit_memory = 1
vm.overcommit_ratio = 50
vm.zone_reclaim_mode = 0
vm.page-cluster = 0
vm.compaction_proactiveness = 0
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.stat_interval = 10
vm.extfrag_threshold = 100

# ====== CPU/SCHEDULER ======
kernel.sched_rt_runtime_us = 980000
kernel.numa_balancing = 0
kernel.sched_migration_cost_ns = 5000000
kernel.sched_autogroup_enabled = 0
kernel.sched_cfs_bandwidth_slice_us = 3000
kernel.timer_migration = 0

# ====== SYSTEM LIMITS ======
kernel.threads-max = 4194304
fs.file-max = 4194304
fs.nr_open = 4194304
fs.aio-max-nr = 1048576
fs.inotify.max_user_instances = 65536
fs.inotify.max_user_watches = 4194304

# ====== SECURITY (DISABLED FOR PERF) ======
kernel.dmesg_restrict = 0
kernel.kptr_restrict = 0
kernel.yama.ptrace_scope = 0
kernel.perf_event_paranoid = -1
kernel.nmi_watchdog = 0
kernel.watchdog = 0
kernel.soft_watchdog = 0
kernel.hung_task_timeout_secs = 0

# ====== MISC ======
kernel.printk = 3 3 3 3
kernel.unprivileged_userns_clone = 1
kernel.sysrq = 1
SYSCTL

# Dynamic values
cat >> /etc/sysctl.d/99-extreme-performance.conf << EOF

# Auto-tuned for ${TOTAL_RAM_GB}GB RAM
vm.min_free_kbytes = ${MIN_FREE_KB}
EOF

sysctl --system -q 2>/dev/null || warn "Some sysctl params may not be available on this kernel"

###############################################################################
# 3. GRUB - EXTREME KERNEL PARAMETERS
###############################################################################
log "Configuring extreme GRUB parameters..."
backup /etc/default/grub

# Build CPU isolation string (isolate all but CPU 0)
if (( NUM_CPUS > 2 )); then
    ISOL_CPUS="1-$LAST_CPU"
    RCU_CPUS="1-$LAST_CPU"
else
    ISOL_CPUS=""
    RCU_CPUS=""
fi

GRUB_PARAMS="nowatchdog nmi_watchdog=0 tsc=reliable clocksource=tsc hpet=disable"
GRUB_PARAMS+=" mitigations=off no_stf_barrier noibpb noibrs nopcid nopti"
GRUB_PARAMS+=" nospec_store_bypass_disable nospectre_v1 nospectre_v2"
GRUB_PARAMS+=" spectre_v2=off spec_store_bypass_disable=off l1tf=off mds=off"
GRUB_PARAMS+=" kpti=off pti=off tsx_async_abort=off mmio_stale_data=off retbleed=off"
GRUB_PARAMS+=" gather_data_sampling=off reg_file_data_sampling=off"
GRUB_PARAMS+=" threadirqs splash loglevel=3 rd.systemd.show_status=auto"
GRUB_PARAMS+=" zswap.enabled=0 transparent_hugepage=madvise"
GRUB_PARAMS+=" hugepagesz=2M hugepages=${HUGEPAGES}"
GRUB_PARAMS+=" elevator=none nvme_load=YES nvme_core.multipath=N"
GRUB_PARAMS+=" skew_tick=1 nohz=on nohz_full=${RCU_CPUS}"
GRUB_PARAMS+=" rcu_nocbs=${RCU_CPUS} rcu_nocb_poll"
GRUB_PARAMS+=" irqaffinity=0 idle=nomwait"
GRUB_PARAMS+=" usbcore.autosuspend=-1"
GRUB_PARAMS+=" preempt=full"

# Intel-specific
if grep -qi intel /proc/cpuinfo 2>/dev/null; then
    GRUB_PARAMS+=" intel_pstate=active intel_pstate=no_hwp"
    GRUB_PARAMS+=" intel_idle.max_cstate=1 processor.max_cstate=1"
fi

# AMD-specific
if grep -qi amd /proc/cpuinfo 2>/dev/null; then
    GRUB_PARAMS+=" amd_pstate=active"
    GRUB_PARAMS+=" processor.max_cstate=1 idle=nomwait"
fi

# Update GRUB
sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"${GRUB_PARAMS}\"|" /etc/default/grub
sed -i 's|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=1|' /etc/default/grub

# Add if not present
grep -q "GRUB_TIMEOUT=" /etc/default/grub || echo "GRUB_TIMEOUT=1" >> /etc/default/grub

update-grub 2>/dev/null || grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || warn "GRUB update failed"

###############################################################################
# 4. I/O SCHEDULER & STORAGE
###############################################################################
log "Configuring I/O and storage optimizations..."

# NVMe udev rules
cat > /etc/udev/rules.d/71-nvme-perf.rules << 'EOF'
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="4096"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/read_ahead_kb}="2048"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/io_poll}="1"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/io_poll_delay}="-1"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/add_random}="0"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/rq_affinity}="2"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nomerges}="1"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/wbt_lat_usec}="0"
EOF

# SATA SSD rules
cat > /etc/udev/rules.d/72-ssd-perf.rules << 'EOF'
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/nr_requests}="2048"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/read_ahead_kb}="1024"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/add_random}="0"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/rq_affinity}="2"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/wbt_lat_usec}="0"
EOF

udevadm control --reload-rules && udevadm trigger 2>/dev/null || true

# fstab tmpfs mounts
backup /etc/fstab
for mnt in "/tmp" "/var/log" "/var/spool" "/var/tmp"; do
    if ! grep -q "tmpfs $mnt" /etc/fstab; then
        echo "tmpfs $mnt tmpfs defaults,noatime,nosuid,nodev,mode=1777,size=2G 0 0" >> /etc/fstab
    fi
done

# SSD TRIM timer
systemctl enable fstrim.timer 2>/dev/null || true

###############################################################################
# 5. IRQ AFFINITY & CPU GOVERNOR
###############################################################################
log "Configuring IRQ affinity and CPU governor..."

backup /etc/default/irqbalance
cat > /etc/default/irqbalance << EOF
IRQBALANCE_ONESHOT=0
IRQBALANCE_BANNED_CPUS=0
ENABLED=1
EOF
systemctl restart irqbalance 2>/dev/null || true

# CPU governor → performance
cat > /etc/default/cpufrequtils << EOF
GOVERNOR="performance"
EOF

# Systemd service for performance governor
cat > /etc/systemd/system/cpu-performance.service << 'EOF'
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "$f" 2>/dev/null; done'
ExecStart=/bin/bash -c 'for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo performance > "$f" 2>/dev/null; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable cpu-performance.service 2>/dev/null || true

# Apply now
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance > "$f" 2>/dev/null || true
done

###############################################################################
# 6. NVIDIA OPTIMIZATIONS
###############################################################################
if [[ "$HAS_NVIDIA" == "1" ]]; then
    log "Applying NVIDIA optimizations..."

    backup /etc/modprobe.d/nvidia.conf
    cat > /etc/modprobe.d/nvidia.conf << 'EOF'
options nvidia NVreg_EnablePCIeGen3=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_InitializeSystemMemoryAllocations=0
options nvidia NVreg_DynamicPowerManagement=0x00
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_EnableStreamMemOPs=1
options nvidia NVreg_RemapLimit=0x7fffffff
options nvidia NVreg_TemporaryFilePath=/var/tmp
options nvidia NVreg_EnableS0ixPowerManagement=0
options nvidia NVreg_EnablePCIERelaxedOrderingMode=1
options nvidia NVreg_EnableResizableBar=1
options nvidia NVreg_EnableGPUFirmware=1
options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
options nvidia NVreg_RegistryDwords="RMForcePState=0;PowerMizerEnable=0x1;PerfLevelSrc=0x2222;PowerMizerLevel=0x3;PowerMizerDefault=0x3;PowerMizerDefaultAC=0x3"
EOF

    # Persistence mode
    if command -v nvidia-smi &>/dev/null; then
        cat > /etc/systemd/system/nvidia-max-perf.service << 'NVEOF'
[Unit]
Description=NVIDIA Maximum Performance
After=multi-user.target nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm ENABLED
ExecStart=/usr/bin/nvidia-smi --power-limit=0
ExecStart=/usr/bin/nvidia-smi -lgc 0,9999
ExecStart=/usr/bin/nvidia-smi --compute-mode=DEFAULT
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
NVEOF
        systemctl daemon-reload
        systemctl enable nvidia-max-perf.service 2>/dev/null || true
        nvidia-smi -pm ENABLED 2>/dev/null || true
    fi

    # NVIDIA Xorg perf tweaks — ONLY if the proprietary driver is actually loaded
    # This avoids black-screen if nouveau or no nvidia driver is active
    if lsmod | grep -q "^nvidia "; then
        mkdir -p /etc/X11/xorg.conf.d/
        cat > /etc/X11/xorg.conf.d/20-nvidia-perf.conf << 'EOF'
# Only GPU perf options — do NOT define Screen/Monitor to avoid breaking DM
Section "OutputClass"
    Identifier "nvidia-perf"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "Coolbits" "31"
    Option "TripleBuffer" "True"
    Option "RegistryDwords" "PerfLevelSrc=0x2222; PowerMizerEnable=0x1; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3"
    Option "AllowIndirectGLXProtocol" "off"
EndSection
EOF
        info "NVIDIA Xorg perf config written (OutputClass — safe for DM)"
    else
        warn "NVIDIA hardware detected but driver module not loaded — skipping Xorg config"
        # Remove any leftover config from a previous run
        rm -f /etc/X11/xorg.conf.d/20-nvidia-perf.conf 2>/dev/null || true
    fi
fi

###############################################################################
# 7. ENVIRONMENT VARIABLES (GPU + PERF)
###############################################################################
log "Setting up performance environment variables..."

cat > /etc/profile.d/99-extreme-perf.sh << 'EOF'
# OpenGL
export __GL_SYNC_TO_VBLANK=0
export __GL_THREADED_OPTIMIZATIONS=1
export __GL_YIELD=USLEEP
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH=/var/tmp
export __GL_SHADER_DISK_CACHE_SIZE=4294967296
export __GL_SHOW_GRAPHICS_OSD=0
export __GL_MaxFramesAllowed=1

# NVIDIA hybrid
export __NV_PRIME_RENDER_OFFLOAD=1
export __VK_LAYER_NV_optimus=NVIDIA_only

# Vulkan
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
export DISABLE_VK_LAYER_VALVE_steam_fossilize_1=1
export RADV_PERFTEST=gpl,nggc,sam

# Mesa / AMD
export vblank_mode=0
export mesa_glthread=true
export AMD_VULKAN_ICD=RADV

# Application
export CLUTTER_PAINT=disable-dynamic-max-render-time
export MUTTER_DEBUG_FORCE_KMS_MODE=simple

# Compiler optimizations
export CFLAGS="-O3 -march=native -mtune=native -pipe -fno-plt -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"
export MAKEFLAGS="-j$(nproc)"

# Reduce journald pressure
export SYSTEMD_LOG_LEVEL=warning

# Faster DNS
export RES_OPTIONS="timeout:1 attempts:1 rotate"
EOF

chmod 644 /etc/profile.d/99-extreme-perf.sh

###############################################################################
# 8. LIMITS.CONF
###############################################################################
log "Setting process limits..."

cat > /etc/security/limits.d/99-extreme.conf << EOF
*    soft    nofile      4194304
*    hard    nofile      4194304
*    soft    nproc       4194304
*    hard    nproc       4194304
*    soft    memlock     unlimited
*    hard    memlock     unlimited
*    soft    stack       unlimited
*    hard    stack       unlimited
*    soft    core        unlimited
*    hard    core        unlimited
root soft    nofile      4194304
root hard    nofile      4194304
*    soft    nice        -20
*    hard    nice        -20
*    soft    rtprio      99
*    hard    rtprio      99
EOF

###############################################################################
# 9. SYSTEMD OPTIMIZATIONS
###############################################################################
log "Tuning systemd and disabling unnecessary services..."

# Faster journal
mkdir -p /etc/systemd/journald.conf.d/
cat > /etc/systemd/journald.conf.d/perf.conf << 'EOF'
[Journal]
Storage=volatile
SystemMaxUse=50M
RuntimeMaxUse=50M
Compress=no
Seal=no
SplitMode=none
RateLimitIntervalSec=0
EOF

# Faster login
mkdir -p /etc/systemd/logind.conf.d/
cat > /etc/systemd/logind.conf.d/perf.conf << 'EOF'
[Login]
StopIdleSessionSec=infinity
HandleLidSwitch=ignore
EOF

# Faster default timeouts
mkdir -p /etc/systemd/system.conf.d/
cat > /etc/systemd/system.conf.d/perf.conf << 'EOF'
[Manager]
DefaultTimeoutStartSec=10s
DefaultTimeoutStopSec=5s
DefaultRestartSec=100ms
DefaultLimitNOFILE=4194304
DefaultLimitNPROC=4194304
DefaultLimitMEMLOCK=infinity
CPUAffinity=0
EOF

# Disable unnecessary services — SAFE list only
# NOTE: Do NOT disable accounts-daemon (breaks GDM/LightDM login)
#       Do NOT disable wpa_supplicant (breaks NetworkManager WiFi)
#       Do NOT disable avahi-daemon blindly (some DEs depend on it)
DISABLE_SERVICES=(
    apt-daily.timer apt-daily-upgrade.timer
    man-db.timer e2scrub_all.timer
    motd-news.timer
    ModemManager.service
    cups.service cups-browsed.service
    unattended-upgrades.service
    packagekit.service
    power-profiles-daemon.service
    switcheroo-control.service
    kerneloops.service
    whoopsie.service
    apport.service
)

for svc in "${DISABLE_SERVICES[@]}"; do
    if systemctl list-unit-files "$svc" &>/dev/null 2>&1; then
        systemctl disable "$svc" 2>/dev/null || true
        systemctl stop "$svc" 2>/dev/null || true
        systemctl mask "$svc" 2>/dev/null || true
    fi
done

###############################################################################
# 10. NETWORK INTERFACE TUNING
###############################################################################
log "Tuning network interfaces..."

cat > /etc/systemd/system/nic-offload.service << 'NICEOF'
[Unit]
Description=NIC Offload Tuning
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '\
for iface in $(ls /sys/class/net/ | grep -v lo); do \
    ethtool -K "$iface" tso on gso on gro on lro on rx-checksumming on tx-checksumming on 2>/dev/null || true; \
    ethtool -G "$iface" rx 4096 tx 4096 2>/dev/null || true; \
    ethtool -C "$iface" adaptive-rx on adaptive-tx on rx-usecs 0 tx-usecs 0 2>/dev/null || true; \
    ip link set "$iface" txqueuelen 10000 2>/dev/null || true; \
done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
NICEOF
systemctl daemon-reload
systemctl enable nic-offload.service 2>/dev/null || true

###############################################################################
# 11. DNS OPTIMIZATION
###############################################################################
log "Optimizing DNS resolution..."

# Use Cloudflare + Google as fast resolvers
if command -v resolvectl &>/dev/null; then
    mkdir -p /etc/systemd/resolved.conf.d/
    cat > /etc/systemd/resolved.conf.d/perf.conf 2>/dev/null << 'EOF' || true
[Resolve]
DNS=1.1.1.1 8.8.8.8 1.0.0.1 8.8.4.4
FallbackDNS=9.9.9.9
DNSOverTLS=opportunistic
Cache=yes
CacheFromLocalhost=yes
EOF
    systemctl restart systemd-resolved 2>/dev/null || true
fi

###############################################################################
# 12. EARLYOOM - OOM KILLER
###############################################################################
if command -v earlyoom &>/dev/null || dpkg -s earlyoom &>/dev/null 2>&1; then
    log "Configuring earlyoom..."

    mkdir -p /etc/default/
    cat > /etc/default/earlyoom << 'EOF'
EARLYOOM_ARGS="-m 3 -s 5 --avoid '(Xorg|Xwayland|gnome-shell|kwin|sway|firefox|chromium)' -r 3600 -n --prefer '(cc1|cc1plus|ld|rustc)'"
EOF
    systemctl enable earlyoom 2>/dev/null || true
    systemctl restart earlyoom 2>/dev/null || true
else
    warn "earlyoom not installed, skipping"
fi

###############################################################################
# 13. GAMEMODE CONFIG
###############################################################################
if command -v gamemoded &>/dev/null || dpkg -s gamemode &>/dev/null 2>&1; then
    log "Configuring GameMode..."

    cat > /etc/gamemode.ini << 'EOF'
[general]
renice=10
ioprio=0
softrealtime=auto
reaper_freq=5
inhibit_screensaver=1

[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
amd_performance_level=high
nv_powermizer_mode=1
nv_core_clock_mhz_offset=100
nv_mem_clock_mhz_offset=200

[cpu]
park_cores=no
pin_cores=yes

[custom]
start=notify-send "GameMode" "Performance mode ON"
end=notify-send "GameMode" "Performance mode OFF"
EOF
else
    warn "gamemode not installed, skipping"
fi

###############################################################################
# 14. KERNEL MODULE BLACKLIST
###############################################################################
log "Blacklisting unnecessary kernel modules..."

cat > /etc/modprobe.d/blacklist-perf.conf << 'EOF'
# Watchdogs
blacklist iTCO_wdt
blacklist iTCO_vendor_support
blacklist sp5100_tco

# PC speaker
blacklist pcspkr
blacklist snd_pcsp

# Unused network
blacklist dccp
blacklist sctp
blacklist rds
blacklist tipc

# Unused filesystems
blacklist cramfs
blacklist freevxfs
blacklist jffs2
blacklist hfs
blacklist hfsplus
blacklist udf

# Firewire
blacklist firewire-ohci
blacklist firewire-sbp2

# Misc
blacklist intel_powerclamp
EOF

###############################################################################
# 15. TUNED PROFILE
###############################################################################
if command -v tuned-adm &>/dev/null; then
    log "Activating tuned latency-performance profile..."
    tuned-adm profile latency-performance 2>/dev/null || \
    tuned-adm profile throughput-performance 2>/dev/null || true
fi

###############################################################################
# 16. TRANSPARENT HUGEPAGES (madvise)
###############################################################################
log "Configuring THP..."

cat > /etc/systemd/system/thp-madvise.service << 'EOF'
[Unit]
Description=Set THP to madvise

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo madvise > /sys/kernel/mm/transparent_hugepage/enabled; echo madvise > /sys/kernel/mm/transparent_hugepage/defrag; echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable thp-madvise.service 2>/dev/null || true

###############################################################################
# 17. DISABLE MITIGATIONS AT RUNTIME (immediate)
###############################################################################
log "Applying runtime performance tweaks..."

# Disable kernel audit
auditctl -e 0 2>/dev/null || true

# Disable NMI watchdog
echo 0 > /proc/sys/kernel/nmi_watchdog 2>/dev/null || true

# Write-back caching on SSDs (if battery is not a concern)
for dev in /sys/block/sd*/device/scsi_disk/*/cache_type; do
    echo "write back" > "$dev" 2>/dev/null || true
done

# Disable add_random on all block devices
for f in /sys/block/*/queue/add_random; do
    echo 0 > "$f" 2>/dev/null || true
done

###############################################################################
# 18. APT OPTIMIZATION
###############################################################################
log "Optimizing apt..."

cat > /etc/apt/apt.conf.d/99-perf << 'EOF'
Acquire::Languages "none";
Acquire::GzipIndexes "true";
Acquire::CompressionTypes::Order:: "lz4";
APT::Install-Recommends "false";
APT::Install-Suggests "false";
Dpkg::Use-Pty "false";
EOF

###############################################################################
# 19. ZRAM (better than swap file)
###############################################################################
log "Configuring zram swap..."

if ! command -v zramctl &>/dev/null; then
    apt-get install -y -qq zram-tools 2>/dev/null || true
fi

cat > /etc/systemd/system/zram-swap.service << EOF
[Unit]
Description=ZRAM swap
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '\
modprobe zram num_devices=1; \
echo zstd > /sys/block/zram0/comp_algorithm 2>/dev/null || echo lz4 > /sys/block/zram0/comp_algorithm; \
echo $((TOTAL_RAM_KB * 1024 / 2)) > /sys/block/zram0/disksize; \
mkswap /dev/zram0; \
swapon -p 100 /dev/zram0'
ExecStop=/bin/bash -c 'swapoff /dev/zram0; echo 1 > /sys/block/zram0/reset'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable zram-swap.service 2>/dev/null || true

###############################################################################
# 20. REBUILD INITRAMFS
###############################################################################
log "Rebuilding initramfs..."
update-initramfs -u 2>/dev/null || true

###############################################################################
# SUMMARY
###############################################################################
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  EXTREME OPTIMIZATION COMPLETE${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
info "Backups saved to: $BACKUP_DIR"
echo ""
warn "IMPORTANT NOTES:"
echo "  1. ALL CPU security mitigations are DISABLED"
echo "  2. /var/log is tmpfs — logs are lost on reboot"
echo "  3. Swap is zram-compressed RAM (no disk swap)"
echo "  4. Kernel watchdogs disabled"
echo "  5. Some system services masked"
echo ""
echo -e "${YELLOW}  REBOOT REQUIRED for full effect.${NC}"
echo ""
echo -e "  Run: ${CYAN}sudo reboot${NC}"
echo ""
