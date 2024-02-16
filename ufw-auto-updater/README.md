# UFW Auto Updater
This script solves a problem when a machine needs to be accessible from the internet, but the IP address (from which users access the machine) changes frequently, however a DNS record is available.  
This script is intended to be used with UFW and runs periodically to update the firewall rules to allow access from the IP address of the DNS record.  
The rules are updated only if the IP address has changed since the last time the script was run.  
Every rule that needs to be checked should have a comment in the following format:
``` shell
# It is REQUIRED to use some IPv4 address in the rule, otherwise two rules would be created (v4 and v6), but the script would only update the v4 rule, leaving the v6 rule unchanged, which is a security risk.
sudo ufw allow from 1.1.1.1 to any port 1234 proto tcp comment "Some description;AUTO_UPDATE:example.com"
```
The `AUTO_UPDATE` part is used by the script to identify the rules that need to be updated. On every iteration the script will check if the IP address of `example.com` has changed and if it has, it will update the rule to allow access from the new IP address. Any changes will be logged to `/var/log/ufw-auto-updater/history.log`.

**WARNING: this is only suitable for rules that allow access from a single IPv4 address per rule (multiple rules can be used to allow access from multiple IPv4 addresses).**

1. Make sure dnsutils is installed
	``` shell
	sudo apt install dnsutils
	```
1. Create directory for the script
	``` shell
	sudo mkdir /var/lib/ufw-auto-updater
	cd /var/lib/ufw-auto-updater
	```
1. Create directory for the logfile
	``` shell
	sudo mkdir /var/log/ufw-auto-updater
	```
1. Deploy `ufw_auto_update.sh` to `/var/lib/ufw-auto-updater`
1. Open cron jobs for editing as root
	``` shell
	sudo crontab -e
	```
1. Add the following line to the end of the file
	- the `5` means that the script will be executed every 5 minutes
	``` shell
	*/5 * * * * /var/lib/ufw-auto-updater/ufw_auto_update.sh >> /var/log/ufw-auto-updater/history.log 2>&1
	```
1. Additionally, logrotate can be configured:  
	1. Add a new logrotate file like so:
		``` shell
		sudo vim /etc/logrotate.d/ufw-auto-updater
		```
	1. Add the following content to the file:
		``` shell
		/var/log/ufw-auto-updater/history.log {
			# Keep 7 days worth of logs
			rotate 7
			# Rotate daily
			daily
			# Compress the logs
			compress
			# Don't panic if not found
			missingok
			# Don't rotate log if file is empty
			notifempty
			# 
			create 640 root adm
			postrotate
				# Commands to run after log rotation, if any
			endscript
			# Add date instead of number to rotated log file
    		dateext
			# Date format of dateext
			dateformat -%Y-%m-%d-%s
		}
		```
	1. Test the configuration
		``` shell
		sudo logrotate --debug /etc/logrotate.d/ufw-auto-updater
		```