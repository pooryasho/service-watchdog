🛠️ Install Watchdog
This script sets up a watchdog that monitors a systemd service by scanning its logs for errors. If an error is detected and certain conditions are met (e.g., no active SSH session, cooldown passed), the service is automatically restarted.

Install Steps:

    bash installer.sh
    
You will be prompted to enter:

✅ Service name – e.g., nginx

⏱️ Check interval (in seconds) – e.g., 30, 90

🕑 Cooldown (in seconds) – e.g., 300

📂 Watchdog script directory – e.g., /root/service-watchdogs

This will:

Create a script: /root/service-watchdogs/nginx-watchdog.sh

Create systemd unit files:

/etc/systemd/system/nginx-watchdog.service

/etc/systemd/system/nginx-watchdog.timer

Enable and start the timer.

To verify status:

    systemctl status nginx-watchdog.timer
    
🧹 Uninstall Watchdog
This script removes a previously installed watchdog setup, including its script, timer, service, and state file.

Uninstall Steps:

    bash uninstaller.sh
    
You will be prompted to enter:

🧾 Service name – e.g., nginx

📂 Watchdog script directory – e.g., /root/service-watchdogs

This will:

Stop and disable the timer and service:

nginx-watchdog.timer

nginx-watchdog.service

Delete:

Watchdog script: /root/service-watchdogs/nginx-watchdog.sh

Systemd files

Cooldown state file: /var/tmp/nginx_watchdog_last_action
