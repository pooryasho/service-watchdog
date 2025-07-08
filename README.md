📦 Installer — install.sh
Installs a systemd watchdog for any Linux service by name. It watches the logs and restarts the service if an error is found — with safety mechanisms to avoid SSH interference or restart loops.

🔧 What It Does
Prompts for:

✅ Service name (e.g., nginx.service)

⏱️ Check interval (e.g., 30s, 1min)

🛑 Cooldown after restart (default: 300 seconds)

📂 Storage path for watchdog script (e.g., /root/my-watchdogs)

Then it:

Creates a watchdog script:

/root/my-watchdogs/nginx-watchdog.sh (based on service name)

Sets up:

A systemd oneshot service

A systemd timer to run it periodically

Restarts the service on ERROR log matches

🔒 Safe Restart Conditions
Skips restart if:

👤 An SSH session is currently active

⏳ Last restart was within the cooldown period

✅ Why Use It?
Keeps any systemd service running

Lightweight and non-intrusive

Customizable and works with any service

Persistent across reboots

🧪 Installer Example Output

    🔧 Systemd Watchdog Setup Script
    This script installs a watchdog for any systemd service.
    It will restart the service if errors are detected in logs.

    🔍 Enter the name of the systemd service (e.g., nginx.service):
    ⏱️  Enter the interval to check the service (e.g., 30s, 1min) [default: 30s]:
    🛑 Enter cooldown time after a restart (in seconds) [default: 300]:
    📂 Enter the full path where the watchdog script should be stored [default: /root/service-watchdogs]:

    📁 Creating directory: /root/service-watchdogs...
    📝 Writing watchdog script to /root/service-watchdogs/nginx-watchdog.sh...
    ⚙️ Creating systemd service: /etc/systemd/system/nginx-watchdog.service...
    🕒 Creating systemd timer (interval: 30s) at /etc/systemd/system/nginx-watchdog.timer...
    🔄 Reloading systemd and enabling timer...

    ✅ Watchdog setup complete for nginx.service!
    🔍 To check the status: systemctl status nginx-watchdog.timer
