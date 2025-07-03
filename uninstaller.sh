#!/bin/bash

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Uninstalling Backhaul Watchdog...${NC}"

# Stop and disable systemd timer and service
systemctl stop backhaul-watchdog.timer || true
systemctl disable backhaul-watchdog.timer || true
systemctl disable backhaul-watchdog.service || true

# Remove systemd files
rm -f /etc/systemd/system/backhaul-watchdog.timer
rm -f /etc/systemd/system/backhaul-watchdog.service

# Remove watchdog directory and script
rm -rf /root/backhaul-watchdog

# Remove state file
rm -f /var/tmp/backhaul_watchdog_last_action

# Reload systemd to apply changes
systemctl daemon-reexec
systemctl daemon-reload

echo -e "${GREEN}✅ Backhaul Watchdog successfully uninstalled!${NC}"
