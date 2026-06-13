#!/usr/bin/env bash
#
# PRO SYSTEMD SERVICE GENERATOR
# Compiles the service file and the backend monitor template for the paid tier.
# Author: Scott Alan Davis
#

SERVICE_FILE="oculink-monitor.service"
SCRIPT_FILE="oculink-daemon.sh"

echo "[*] Compiling Pro automation tier configs..."

# 1. Compile the background execution logic script
cat << 'INNER_EOF' > "$SCRIPT_FILE"
#!/usr/bin/env bash
#
# Oculink Link State Maintenance Daemon
# Automatically checks for PCIe downshifting and maintains max throughput
#

INTERVAL=5
TARGET_BUS="0000:01:00.0" # Dynamic placeholder for user's eGPU address

echo "[*] Starting Oculink Live Monitor Daemon..."

while true; do
    # Verify if device exists on the bus topology
    if lspci -s "$TARGET_BUS" > /dev/null 2>&1; then
        # Query the operational link speed status safely
        LINK_STATUS=$(lspci -vvv -s "$TARGET_BUS" | grep -i "LnkSta:" | head -n 1)
        
        if [[ "$LINK_STATUS" == *"Speed 2.5GT/s"* ]]; then
            echo "[!] Alert: Oculink link dropped to Gen 1 power-saving speed. Re-asserting registers..."
            # Call the core optimization script to force recovery state
            /usr/local/bin/optimize-system.sh --force-recovery
        fi
    fi
    sleep "$INTERVAL"
done
INNER_EOF

# 2. Compile the systemd configuration mapping block
cat << 'INNER_EOF' > "$SERVICE_FILE"
[Unit]
Description=Oculink eGPU Performance and Link-State Stability Daemon
After=multi-user.target display-manager.service
Documentation=https://github.com/your-username/arch-oculink-optimizer

[Service]
Type=simple
ExecStart=/usr/local/bin/oculink-daemon.sh
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
INNER_EOF

chmod +x "$SCRIPT_FILE"
echo "[+] Pro components generated: '$SCRIPT_FILE' and '$SERVICE_FILE' are ready."
