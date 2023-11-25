# Basic commands to set up a Debian system to my liking
## Update and upgrade
```bash
sudo apt update && sudo apt full-upgrade -y
```
## Check timezone
```bash
timedatectl
```
## Set timezone
```bash
sudo timedatectl set-timezone Europe/London
```
## Install essential packages and utilities (assuming sudo is installed)
```bash
sudo apt install zip unzip git curl wget vim tmux htop net-tools stress python3 python3-pip php openvpn ufw sqlite3 -y
```
## On a Raspberry Pi with PoE hat, amend dtoverlay in /boot/config.txt
```bash
# Raspbian
sudo vim /boot/config.txt

# Ubuntu
sudo vim /boot/firmware/config.txt
```
add the following lines (amend values to your liking):
```bash
# PoE Hat Fan Speeds
dtparam=poe_fan_temp0=50000,poe_fan_temp0_hyst=5000
dtparam=poe_fan_temp1=60000,poe_fan_temp1_hyst=10000
dtparam=poe_fan_temp2=70000,poe_fan_temp2_hyst=10000
dtparam=poe_fan_temp3=80000,poe_fan_temp3_hyst=10000
```
## Set up firewall
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
```