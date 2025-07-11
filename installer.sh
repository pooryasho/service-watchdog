#!/bin/bash
set -e

# Color codes
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}🔧 Systemd Watchdog Setup Script${NC}"
echo -e "${YELLOW}This script installs a watchdog for any systemd service."
echo -e "It will restart the service if errors are detected in logs.${NC}\n"

# Ask for the systemd service basename
read -rp "$(echo -e ${CYAN}"🔍 Enter the systemd service name (e.g., nginx): "${NC})" SERVICE_BASENAME
if [[ -z "$SERVICE_BASENAME" ]]; then
    echo -e "${YELLOW}⚠️ Service name cannot be empty.${NC}"
    exit 1
fi

# Compose full service name
TARGET_SERVICE="${SERVICE_BASENAME}.service"

# Ask for the checking interval
read -rp "$(echo -e ${CYAN}"⏱️  Enter the interval to check the service (in seconds) (e.g., 30, 90) [default: 30s]: "${NC})" CHECK_INTERVAL
CHECK_INTERVAL=${CHECK_INTERVAL:-30s}

# Ask for cooldown time (in seconds)
read -rp "$(echo -e ${CYAN}"🛑 Enter cooldown time after a restart (in seconds) [default: 300]: "${NC})" COOLDOWN
COOLDOWN=${COOLDOWN:-300}

# Ask for script directory
read -rp "$(echo -e ${CYAN}"📂 Enter the full path where the watchdog script should be stored [default: /root/service-watchdog]: "${NC})" SCRIPT_DIR
SCRIPT_DIR=${SCRIPT_DIR:-/root/service-watchdogs}

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

# Check for "ERROR" in last 1 line of logs
LOG_OUTPUT=\$(journalctl -u ${TARGET_SERVICE} -n 3 --no-pager)

if echo "\$LOG_OUTPUT" | grep -Eq "ERROR|WARNING"; then
    echo "[Watchdog] ❌ ERROR or WARNING detected - restarting ${TARGET_SERVICE}..."
    systemctl restart ${TARGET_SERVICE}
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
Description=Watchdog for ${TARGET_SERVICE}
After=network.target

[Service]
Type=oneshot
ExecStart=${WATCHDOG_SCRIPT}
EOF

# Create systemd timer file
echo -e "${GREEN}🕒 Creating systemd timer (interval: ${CHECK_INTERVAL}) at ${WATCHDOG_TIMER}...${NC}"
cat > "${WATCHDOG_TIMER}" <<EOF
[Unit]
Description=Run ${SERVICE_BASENAME}-watchdog every ${CHECK_INTERVAL} seconds

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
echo -e "\n${GREEN}✅ Watchdog setup complete for ${TARGET_SERVICE}!${NC}"
echo -e "🔍 To check the status: ${YELLOW}systemctl status ${SERVICE_BASENAME}-watchdog.timer${NC}"
