#!/bin/bash

set -e

# Color codes
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Uninstalling Watchdog...${NC}"

# Ask for the systemd service name
read -rp "$(echo -e ${CYAN}"🔍 Enter the name of the systemd service (e.g., nginx.service): "${NC})" SERVICE_NAME
BASENAME=$(basename "$SERVICE_NAME" .service)

# Ask for the watchdog script directory
read -rp "$(echo -e ${CYAN}"📁 Enter the path where the watchdog script was saved (e.g., /root/my-watchdog): "${NC})" WATCHDOG_DIR

WATCHDOG_SCRIPT="${WATCHDOG_DIR}/${BASENAME}-watchdog.sh"
STATE_FILE="/var/tmp/${BASENAME}_watchdog_last_action"

# Stop and disable systemd timer and service
systemctl stop ${BASENAME}-watchdog.timer || true
systemctl disable ${BASENAME}-watchdog.timer || true
systemctl disable ${BASENAME}-watchdog.service || true

# Remove systemd files
rm -f /etc/systemd/system/${BASENAME}-watchdog.timer
rm -f /etc/systemd/system/${BASENAME}-watchdog.service

# Remove watchdog script only
rm -f "$WATCHDOG_SCRIPT"

# Remove state file
rm -f "$STATE_FILE"

# Reload systemd
systemctl daemon-reexec
systemctl daemon-reload

echo -e "${GREEN}✅ Watchdog for ${SERVICE_NAME} successfully uninstalled!${NC}"
