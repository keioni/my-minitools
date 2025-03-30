#!/bin/bash -eux
# allow from cloudflare IPv4 range

sudo ufw deny proto tcp from any to any port 443

sudo ufw allow proto tcp from 173.245.48.0/20 to any port 443
sudo ufw allow proto tcp from 103.21.244.0/22 to any port 443
sudo ufw allow proto tcp from 103.22.200.0/22 to any port 443
sudo ufw allow proto tcp from 103.31.4.0/22 to any port 443
sudo ufw allow proto tcp from 141.101.64.0/18 to any port 443
sudo ufw allow proto tcp from 108.162.192.0/18 to any port 443
sudo ufw allow proto tcp from 190.93.240.0/20 to any port 443
sudo ufw allow proto tcp from 188.114.96.0/20 to any port 443
sudo ufw allow proto tcp from 197.234.240.0/22 to any port 443
sudo ufw allow proto tcp from 198.41.128.0/17 to any port 443
sudo ufw allow proto tcp from 162.158.0.0/15 to any port 443
sudo ufw allow proto tcp from 104.16.0.0/13 to any port 443
sudo ufw allow proto tcp from 104.24.0.0/14 to any port 443
sudo ufw allow proto tcp from 172.64.0.0/13 to any port 443
sudo ufw allow proto tcp from 131.0.72.0/22 to any port 443

