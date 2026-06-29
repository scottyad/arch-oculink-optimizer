#!/usr/bin/env bash
# Proactive PCIe link monitor for Oculink eGPUs
set -euo pipefail

CHECK_INTERVAL=2
GPU_PCI_ADDR="0000:03:00.0"

echo "=== Oculink Watchdog Monitor Active ==="
while true; do
    if lspci -s "$GPU_PCI_ADDR" &>/dev/null; then
        CURRENT_SPEED=$(lspci -vvs "$GPU_PCI_ADDR" 2>/dev/null | grep -oP 'LnkSta:.*?Speed \K[\d.]+\w+/s' || echo "unknown")
        CURRENT_WIDTH=$(lspci -vvs "$GPU_PCI_ADDR" 2>/dev/null | grep -oP 'LnkSta:.*?Width x\K\d+' || echo "unknown")
        
        if [[ "$CURRENT_SPEED" == "2.5GT/s" || "$CURRENT_WIDTH" != "4" ]]; then
            echo "$(date +'%Y-%m-%d %H:%M:%S') [CRITICAL] Oculink Link Degraded: $CURRENT_SPEED x$CURRENT_WIDTH"
        fi
    fi
    sleep "$CHECK_INTERVAL"
done
