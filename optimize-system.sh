#!/usr/bin/env bash
# Automated bare-metal optimization for Oculink eGPU pipelines
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: This script must be run as root (sudo)." >&2
  exit 1
fi

echo "[+] Deploying stable Oculink modprobe parameters..."
cat << 'MOD_EOF' > /etc/modprobe.d/nvidia-oculink.conf
options nvidia NVreg_Mobile=0
options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerDefaultAC=0x1"
MOD_EOF

echo "[+] Setting up performance sysctl parameters..."
cat << 'SYS_EOF' > /etc/sysctl.d/99-egpu-performance.conf
vm.dirty_ratio = 80
vm.dirty_background_ratio = 5
vm.swappiness = 10
vm.max_map_count = 1048576
kernel.split_lock_mitigate = 0
SYS_EOF

echo "[+] Enforcing PCIe stability parameters in GRUB..."
if [ -f /etc/default/grub ]; then
    if ! grep -q "pcie_port_pm=off" /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="pcie_port_pm=off pcie_aspm=off ibt=off nvidia_drm.modeset=1 /' /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
fi

echo "[+] Rebuilding initramfs..."
if [ -f /etc/mkinitcpio.conf ]; then
    mkinitcpio -P
fi

echo "[+] Optimization complete! Reboot to initialize stable link states."
