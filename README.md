📦 Installer — install.sh
Installs a systemd watchdog that monitors your backhaul.service. If an error is detected in the logs, it restarts the service — with cooldown and SSH safeguards in place.

🔧 What It Does
Prompts for:

✅ Service name (e.g., backhaul.service)

⏱️ Check interval (e.g., 30s, 1min)

🛑 Cooldown after restart (default: 300 seconds)

Creates a watchdog script in:
/root/backhaul-watchdog/backhaul-watchdog.sh

Sets up:

A systemd timer to run periodically

A systemd oneshot service to evaluate logs

Restarts service on ERROR log match

Skips restart if:

An SSH session is active

Last restart was within cooldown

✅ Why Use It?
Keeps your backhaul.service running automatically without interfering during active sessions or looping restarts. Lightweight, configurable, and persistent across reboots.

🧪 Installer Example Output

    🔧 Backhaul Watchdog Setup Script
    This script will install a watchdog for your backhaul.service
    It will restart the service if errors are detected in logs.

    🔍 Enter the name of the systemd service (default: backhaul.service):
    ⏱️  Enter the interval to check the service (e.g., 30s, 1min) [default: 30s]:
    🛑 Enter cooldown time after a restart (in seconds) [default: 300]:

    📁 Creating /root/backhaul-watchdog directory...
    📝 Writing watchdog script...
    ⚙️ Creating systemd service...
    🕒 Creating systemd timer (interval: 30s)...
    🔄 Reloading systemd and enabling watchdog timer...

    ✅ Watchdog setup complete!
    🔍 To check the status: systemctl status backhaul-watchdog.timer
    
🧹 Uninstaller — uninstall.sh
Cleanly removes the watchdog without touching your code or service.

🧽 What It Does
Stops & disables:

backhaul-watchdog.timer

backhaul-watchdog.service

Removes:

/etc/systemd/system/backhaul-watchdog.{timer,service}

Cooldown state file: /var/tmp/backhaul_watchdog_last_action

Reloads systemd

Keeps your scripts in: /root/backhaul-watchdog/

✅ Why It’s Safe
Non-destructive — only removes systemd integration

Color-coded and readable console output

You can re-install anytime without reconfiguration

🧪 Uninstaller Example Output

    🧹 Backhaul Watchdog Uninstaller
    This script will remove the watchdog timer, service, and logs.
    It will NOT delete the /root/backhaul-watchdog directory.

    ⛔ Stopping and disabling systemd units...
    🧽 Removing systemd service and timer files...
    🧹 Removing temporary state file...
    🔄 Reloading systemd daemon...

    ✅ Backhaul Watchdog has been successfully uninstalled!
    📁 The directory /root/backhaul-watchdog is preserved (you can delete it manually if needed).
