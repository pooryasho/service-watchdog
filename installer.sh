#!/bin/bash

set -e

# Color codes
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔧 Backhaul Watchdog Setup Script${NC}"
echo -e "${YELLOW}This script will install a watchdog for your backhaul.service"
echo -e "It will restart the service if errors are detected in logs.${NC}\n"

# Ask for backhaul service name or path
read -rp "$(echo -e ${CYAN}"🔍 Enter the name of the systemd service (default: backhaul.service): "${NC})" SERVICE_NAME
SERVICE_NAME=${SERVICE_NAME:-backhaul.service}

# Ask for the checking interval
read -rp "$(echo -e ${CYAN}"⏱️  Enter the interval to check the service (e.g., 30s, 1min) [default: 30s]: "${NC})" CHECK_INTERVAL
CHECK_INTERVAL=${CHECK_INTERVAL:-30s}

# Ask for cooldown time (in seconds)
read -rp "$(echo -e ${CYAN}"🛑 Enter cooldown time after a restart (in seconds) [default: 300]: "${NC})" COOLDOWN
COOLDOWN=${COOLDOWN:-300}

# Create watchdog directory
echo -e "${GREEN}📁 Creating /root/backhaul-watchdog directory...${NC}"
mkdir -p /root/backhaul-watchdog

# Create watchdog script
echo -e "${GREEN}📝 Writing watchdog script...${NC}"
cat > /root/backhaul-watchdog/backhaul-watchdog.sh <<EOF
#!/bin/bash

STATE_FILE="/var/tmp/backhaul_watchdog_last_action"

# Cooldown: Prevent restarts more often than every ${COOLDOWN} seconds
if [ -f "\$STATE_FILE" ]; then
    LAST_ACTION_TIME=\$(cat "\$STATE_FILE")
    NOW=\$(date +%s)
    ELAPSED=\$((NOW - LAST_ACTION_TIME))

    if [ "\$ELAPSED" -lt ${COOLDOWN} ]; then
        echo "[Watchdog] ⏳ Skipping - last restart was \$ELAPSED seconds ago"
        exit 0
    fi
fi

# Skip if SSH session is active
if who | grep -qE "ssh"; then
    echo "[Watchdog] 👤 SSH session detected, skipping restart."
    exit 0
fi

# Check for "ERROR" in last 1 line of logs
LOG_OUTPUT=\$(journalctl -u ${SERVICE_NAME} -n 1 --no-pager)

if echo "\$LOG_OUTPUT" | grep -q "ERROR"; then
    echo "[Watchdog] ❌ ERROR detected - restarting ${SERVICE_NAME}..."
    systemctl restart ${SERVICE_NAME}
    date +%s > "\$STATE_FILE"
else
    echo "[Watchdog] ✅ No error detected."
fi
EOF

chmod +x /root/backhaul-watchdog/backhaul-watchdog.sh

# Create systemd service file
echo -e "${GREEN}⚙️ Creating systemd service...${NC}"
cat > /etc/systemd/system/backhaul-watchdog.service <<EOF
[Unit]
Description=Backhaul Watchdog
After=network.target

[Service]
Type=oneshot
ExecStart=/root/backhaul-watchdog/backhaul-watchdog.sh
EOF

# Create systemd timer file
echo -e "${GREEN}🕒 Creating systemd timer (interval: ${CHECK_INTERVAL})...${NC}"
cat > /etc/systemd/system/backhaul-watchdog.timer <<EOF
[Unit]
Description=Run backhaul watchdog every ${CHECK_INTERVAL}

[Timer]
OnBootSec=1min
OnUnitActiveSec=${CHECK_INTERVAL}
Unit=backhaul-watchdog.service

[Install]
WantedBy=timers.target
EOF

# Reload and start timer
echo -e "${GREEN}🔄 Reloading systemd and enabling watchdog timer...${NC}"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now backhaul-watchdog.timer

# Final message
echo -e "\n${GREEN}✅ Watchdog setup complete!${NC}"
echo -e "🔍 To check the status: ${YELLOW}systemctl status backhaul-watchdog.timer${NC}"
