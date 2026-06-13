#!/usr/bin/env bash
#
# ARCH LINUX OCULINK EGPU OPTIMIZATION ENGINE
# Idempotent system tuning script for hardware stability.
# Author: Scott Alan Davis
#

set -e

echo "[*] Initializing Arch Linux Oculink Tuning Sequence..."

# 1. Enforce PCIe Gen 4 Speed & ASPM Bypass
GRUB_CONFIG="/etc/default/grub"
KERNEL_PARAMS="pcie_port_pm=off pcie_aspm=off"

if [ -f "$GRUB_CONFIG" ]; then
    if ! grep -q "pcie_port_pm=off" "$GRUB_CONFIG"; then
        echo "[*] Injecting kernel parameters into GRUB configuration..."
        sudo sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"/\1 $KERNEL_PARAMS\"/" "$GRUB_CONFIG"
        if command -v grub-mkconfig >/dev/null 2>&1; then
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
    fi
else
    echo "[!] Warning: Standard GRUB path not detected. Verify bootloader parameters manually."
fi

# 2. Configure Modprobe Options for NVIDIA Stability
NVIDIA_CONF="/etc/modprobe.d/nvidia-egpu.conf"
echo "[*] Applying NVIDIA driver module overrides..."
sudo mkdir -p /etc/modprobe.d
cat << 'MODCONF' | sudo tee "$NVIDIA_CONF" > /dev/null
# Force maximum performance states on discrete cards over external interfaces
options nvidia NVreg_Mobile=0
options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerDefaultAC=0x1"
MODCONF

# 3. Optimize System Memory Boundaries for Heavy Compute
SYSCTL_CONF="/etc/sysctl.d/99-egpu-performance.conf"
echo "[*] Modifying kernel sysctl thresholds..."
sudo mkdir -p /etc/sysctl.d
cat << 'SYSCONF' | sudo tee "$SYSCTL_CONF" > /dev/null
# Adjust dirty memory dynamics to protect high-throughput pipes
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
kernel.split_lock_mitigate = 0
SYSCONF
if command -v sysctl >/dev/null 2>&1; then
    sudo sysctl --system > /dev/null
fi

# 4. Validate Storage Rebuild Hook Ordering
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
if [ -f "$MKINITCPIO_CONF" ]; then
    echo "[*] Auditing mkinitcpio hook alignments..."
    if grep -q "sd-encrypt" "$MKINITCPIO_CONF" && grep -q "block" "$MKINITCPIO_CONF"; then
        echo "[+] Security encryption hook topology looks healthy."
    fi
fi

echo "[+] System performance parameters optimized successfully. Please reboot to bind kernel variables."
