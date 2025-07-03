📦 Installer Explanation (install.sh)
🔧 What the installer does:
Prompts the user for:

The path to the backhaul.service (default: /root/backhaul/)

The interval for checking the service logs (e.g., every 30s, 1min)

A cooldown period to prevent restarting too often after an error

Creates a watchdog script at /root/backhaul-watchdog/backhaul-watchdog.sh

Configures a systemd service and timer to:

Periodically check journalctl logs for the word ERROR

Automatically restart the service when an error is found

Avoid restarts if an SSH session is active

Avoid restart spam with a user-defined cooldown

Starts the timer immediately and enables it on boot

✅ Why use it?
This script ensures backhaul.service remains reliable by restarting it only when needed, with safety checks to prevent interference during active admin sessions or rapid error loops.

# Installer Example Run Output:
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

🧹 Uninstaller Explanation (uninstall.sh)
The uninstaller cleanly removes the watchdog components from your system without touching your original files or project directory.

🧽 What the uninstaller does:
Stops and disables the systemd watchdog timer and service

Deletes the corresponding .service and .timer files from /etc/systemd/system/

Removes the internal state file used to track cooldowns (/var/tmp/backhaul_watchdog_last_action)

Reloads the systemd daemon to apply changes

Preserves the folder /root/backhaul-watchdog/ (in case you want to reinstall or review the script)

✅ Why it's safe:
Non-destructive: it only removes the installed components and doesn't touch your actual service or custom scripts

Clear console output with colored progress messages
# Uninstaller Example Run Output:
    🧹 Backhaul Watchdog Uninstaller
    This script will remove the watchdog timer, service, and logs.
    It will NOT delete the /root/backhaul-watchdog directory.

    ⛔ Stopping and disabling systemd units...
    🧽 Removing systemd service and timer files...
    🧹 Removing temporary state file...
    🔄 Reloading systemd daemon...

    ✅ Backhaul Watchdog has been successfully uninstalled!
    📁 The directory /root/backhaul-watchdog is preserved (you can delete it manually if needed).
