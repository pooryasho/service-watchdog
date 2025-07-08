#!/bin/bash

set -e

# Color codes
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔧 Systemd Watchdog Setup Script${NC}"
echo -e "${YELLOW}This script installs a watchdog for any systemd service."
echo -e "It will restart the service if errors are detected in logs.${NC}\n"

# Ask for systemd service name
read -rp "$(echo -e ${CYAN}"🔍 Enter the name of the systemd service (e.g., nginx.service): "${NC})" SERVICE_NAME
if [[ -z "$SERVICE_NAME" ]]; then
    echo -e "${YELLOW}⚠️ Service name cannot be empty.${NC}"
    exit 1
fi

# Ask for the checking interval
read -rp "$(echo -e ${CYAN}"⏱️  Enter the interval to check the service (e.g., 30s, 1min) [default: 30s]: "${NC})" CHECK_INTERVAL
CHECK_INTERVAL=${CHECK_INTERVAL:-30s}

# Ask for cooldown time (in seconds)
read -rp "$(echo -e ${CYAN}"🛑 Enter cooldown time after a restart (in seconds) [default: 300]: "${NC})" COOLDOWN
COOLDOWN=${COOLDOWN:-300}

# Ask for script directory
read -rp "$(echo -e ${CYAN}"📂 Enter the full path where the watchdog script should be stored [default: /root/service-watchdogs]: "${NC})" SCRIPT_DIR
SCRIPT_DIR=${SCRIPT_DIR:-/root/service-watchdogs}

# Normalize service basename (e.g., nginx.service -> nginx)
SERVICE_BASENAME=$(basename "$SERVICE_NAME" .service)

# Paths
WATCHDOG_SCRIPT="${SCRIPT_DIR}/${SERVICE_BASENAME}-watchdog.sh"
WATCHDOG_SERVICE="/etc/systemd/system/${SERVICE_BASENAME}-watchdog.service"
WATCHDOG_TIMER="/etc/systemd/system/${SERVICE_BASENAME}-watchdog.timer"

# Create script directory
echo -e "${GREEN}📁 Creating directory: ${SCRIPT_DIR}...${NC}"
mkdir -p "${SCRIPT_DIR}"

# Create watchdog script
echo -e "${GREEN}📝 Writing watchdog script to ${WATCHDOG_SCRIPT}...${NC}"
cat > "${WATCHDOG_SCRIPT}" <<EOF
#!/bin/bash

STATE_FILE="/var/tmp/${SERVICE_BASENAME}_watchdog_last_action"

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

chmod +x "${WATCHDOG_SCRIPT}"

# Create systemd service file
echo -e "${GREEN}⚙️ Creating systemd service: ${WATCHDOG_SERVICE}...${NC}"
cat > "${WATCHDOG_SERVICE}" <<EOF
[Unit]
Description=${SERVICE_NAME} Watchdog
After=network.target

[Service]
Type=oneshot
ExecStart=${WATCHDOG_SCRIPT}
EOF

# Create systemd timer file
echo -e "${GREEN}🕒 Creating systemd timer (interval: ${CHECK_INTERVAL}) at ${WATCHDOG_TIMER}...${NC}"
cat > "${WATCHDOG_TIMER}" <<EOF
[Unit]
Description=Run watchdog for ${SERVICE_NAME} every ${CHECK_INTERVAL}

[Timer]
OnBootSec=1min
OnUnitActiveSec=${CHECK_INTERVAL}
Unit=${SERVICE_BASENAME}-watchdog.service

[Install]
WantedBy=timers.target
EOF

# Reload and start timer
echo -e "${GREEN}🔄 Reloading systemd and enabling timer...${NC}"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now "${SERVICE_BASENAME}-watchdog.timer"

# Final message
echo -e "\n${GREEN}✅ Watchdog setup complete for ${SERVICE_NAME}!${NC}"
echo -e "🔍 To check the status: ${YELLOW}systemctl status ${SERVICE_BASENAME}-watchdog.timer${NC}"
