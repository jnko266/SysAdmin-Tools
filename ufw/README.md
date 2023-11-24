# UFW (Uncomplicated Firewall)
## Some basic commands
``` shell
sudo ufw status
sudo ufw enable
sudo ufw disable
sudo ufw reload
```
## Defaults
``` shell
sudo ufw default deny incoming
sudo ufw default allow outgoing
```
## Allow SSH
``` shell
sudo ufw allow ssh
```
## Allow HTTP
``` shell
sudo ufw allow http
```
## Allow HTTPS
``` shell
sudo ufw allow https
```
## Allow port X
``` shell
# Simple
sudo ufw allow X

# Range
sudo ufw allow X:Y

# Protocol
sudo ufw allow X/tcp
sudo ufw allow X/udp
sudo ufw allow X/icmp

# From a specific subnet
sudo ufw allow from 1.2.3.4/24 to any port X comment "Rule description"

# Same as above, but including the protocol
sudo ufw allow from 1.2.3.4/24 proto tcp to any port X comment "Rule description"
```
