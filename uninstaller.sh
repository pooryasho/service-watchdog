#!/bin/bash
set -e

# Color codes
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Uninstalling Watchdog...${NC}"

# Ask for the systemd service name (without .service)
read -rp "$(echo -e ${CYAN}"🔍 Enter the name of the service you want to remove the watchdog for (e.g., nginx): "${NC})" SERVICE_BASENAME
if [[ -z "$SERVICE_BASENAME" ]]; then
    echo -e "${YELLOW}⚠️ Service name cannot be empty.${NC}"
    exit 1
fi

# Ask for the script directory
read -rp "$(echo -e ${CYAN}"📂 Enter the path where the watchdog script was saved (e.g., /root/service-watchdogs): "${NC})" SCRIPT_DIR
if [[ -z "$SCRIPT_DIR" ]]; then
    echo -e "${YELLOW}⚠️ Script path cannot be empty.${NC}"
    exit 1
fi

# Paths
WATCHDOG_SCRIPT="${SCRIPT_DIR}/${SERVICE_BASENAME}-watchdog.sh"
STATE_FILE="/var/tmp/${SERVICE_BASENAME}_watchdog_last_action"
WATCHDOG_SERVICE="/etc/systemd/system/${SERVICE_BASENAME}-watchdog.service"
WATCHDOG_TIMER="/etc/systemd/system/${SERVICE_BASENAME}-watchdog.timer"

# Stop and disable systemd units
systemctl stop "${SERVICE_BASENAME}-watchdog.timer" || true
systemctl disable "${SERVICE_BASENAME}-watchdog.timer" || true
systemctl disable "${SERVICE_BASENAME}-watchdog.service" || true

# Remove unit files and watchdog script
rm -f "$WATCHDOG_TIMER"
rm -f "$WATCHDOG_SERVICE"
rm -f "$WATCHDOG_SCRIPT"
rm -f "$STATE_FILE"

# Reload systemd
systemctl daemon-reexec
systemctl daemon-reload

echo -e "${GREEN}✅ Watchdog for ${SERVICE_BASENAME}.service successfully uninstalled!${NC}"
