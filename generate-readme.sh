#!/usr/bin/env bash
#
# README GENERATOR FOR GITHUB PORTFOLIO
# Generates a premium storefront markdown file for the optimization project.
# Author: Scott Alan Davis
#

TARGET_README="README.md"

echo "[*] Creating premium storefront markdown..."

# Initialize file with the header and description
cat << 'STOREFRONT' > "$TARGET_README"
# 🚀 Arch Linux Performance & Oculink eGPU Optimization Engine

An automated, idempotent system tuning utility engineered specifically for **Small Form Factor (SFF) Mini PCs** running Arch Linux (`linux-zen`) paired with external graphics infrastructure (**Oculink / dedicated PCIe links**). 

This engine eliminates aggressive power-state downshifting, bypasses mobile driver thermal throttling, stabilizes LUKS storage hooks, and tunes virtual memory boundaries to guarantee zero-latency throughput for heavy developer compute, deep learning inference, and high-frame-rate rendering.

---

## ⚡ The Core Problem (Why This Exists)
Standard Linux distributions are aggressively optimized for laptop power conservation. When running a desktop discrete card (like an **NVIDIA RTX 3060 12GB**) through a dedicated Oculink interface, the kernel's default power governors constantly drop the link down to PCIe Gen 1 speeds during idle periods. 

This causes:
* **Micro-stuttering & Latency Spikes** as the link forces its way back to Gen 4 speeds under load.
* **Kernel Panics & Driver Dropouts** due to aggressive Active State Power Management (ASPM).
* **Clock-Speed Throttling** triggered by mobile-specific driver assumptions on compact hardware form factors.

**This engine locks your hardware links into absolute high-performance execution states.**

---

## 🛠️ Optimization Pillars

| Feature Pillar | Target System | Technical Mechanism |
| :--- | :--- | :--- |
| **PCIe Link Locking** | Bootloader / Bus | Complete bypass of `pcie_port_pm` and `pcie_aspm` power saving parameters. |
| **NVIDIA Rigging** | Modprobe / Driver | Injects `NVreg_Mobile=0` and forces PowerMizer registry keys to `0x1` (Max Perf). |
| **Real-Time Scheduler** | Kernel (`sysctl`) | Fine-tunes `vm.dirty_ratio` and disables split-lock mitigation performance penalties. |
| **Storage Safeguards** | Initramfs / LUKS | Verifies `sd-encrypt` sequencing directly before block device hooks prior to image rebuilds. |

---

## 📦 Fast Installation

Deploy the core optimization engine directly to your Arch installation with a single automated payload:

```bash
curl -sSL [https://raw.githubusercontent.com/your-username/arch-oculink-optimizer/main/optimize-system.sh](https://raw.githubusercontent.com/your-username/arch-oculink-optimizer/main/optimize-system.sh) | sudo bash

STOREFRONT

echo "[+] Storefront '$TARGET_README' has been generated successfully."
