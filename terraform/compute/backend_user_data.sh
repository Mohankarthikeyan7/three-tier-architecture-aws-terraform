#!/bin/bash

# Start and enable Apache
sudo systemctl enable httpd
sudo systemctl start httpd


cd /var/www/html

# Create index.html with success message
sudo echo "Success!" > index.html

# Clone repository with backend code
sudo git clone https://github.com/ajitinamdar-tech/three-tier-architecture-aws.git

# Create api directory and move backend files
sudo mkdir api
sudo mv three-tier-architecture-aws/backend/api/* api/

# Update database connection details
sudo sed -i "s/update-me-host/${db_host}/g" /var/www/html/api/db_connection.php
sudo sed -i "s/update-me-username/${db_username}/g" /var/www/html/api/db_connection.php
sudo sed -i "s/update-me-password/${db_password}/g" /var/www/html/api/db_connection.php

# Clean up - remove cloned repository
sudo rm -rf three-tier-architecture-aws