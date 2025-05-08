#!/bin/bash

# Update backend ALB endpoint in Nginx configuration
sudo sed -i "s/update-me/${backend_alb_dns}/g" /etc/nginx/nginx.conf

# Restart Nginx to apply changes
# Configure Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

cd /usr/share/nginx/html
sudo git clone https://github.com/ajitinamdar-tech/three-tier-architecture-aws.git
mv /usr/share/nginx/html/three-tier-architecture-aws/frontend/* /usr/share/nginx/html/
sudo rm -rf /usr/share/nginx/html/three-tier-architecture-aws