# Python-based Temperature Monitor
This is a simple Python-based temperature monitor script that monitors output of the following commands in a sqlite database every 10 seconds:  

- `vcgencmd measure_temp`  
- `cat /sys/class/hwmon/hwmon*/*pwm*`  
- `cat /sys/class/thermal/cooling_device*/cur_state`  

These commands are expected to work on a Raspberry Pi with a PoE Hat. The database is created in the following location: `/mnt/data/temp_readings.sqlite`.  
The frequency of the readings can be changed by modifying line 66 in the temp_monitor.py file: `time.sleep(10)`, where `10` is the number of seconds between readings.
## Installation
1. Make directory `customscripts` in `/etc` like so: `sudo mkdir /etc/customscripts`
1. Create directory `data` in `/mnt` like so: `sudo mkdir /mnt/data`
1. Copy `temp_monitor.py` to `/etc/customscripts` like so: `sudo cp temp_monitor.py /etc/customscripts`
1. Make `temp_monitor.py` executable like so: `sudo chmod +x /etc/customscripts/temp_monitor.py`
1. Copy `temp_monitor.service` to `/etc/systemd/system` like so: `sudo cp temp_monitor.service /etc/systemd/system`
1. Reload systemd like so: `sudo systemctl daemon-reload`
1. Enable the service like so: `sudo systemctl enable temp_monitor`
1. Start the service like so: `sudo systemctl start temp_monitor`
1. Check the status of the service like so: `sudo systemctl status temp_monitor`
1. Check the database like so: `sqlite3 /mnt/data/temp_readings.sqlite`
1. Check the tables in the database like so: `.tables`
1. Check the data in the database like so: `select * from temperature_readings;`
1. Exit the database like so: `.exit`
