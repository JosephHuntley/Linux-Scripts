#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo zypper refresh && sudo zypper update -y

# Install required packages
echo "Installing necessary packages..."
sudo zypper install -y apache2 mariadb mariadb-client php php-mysql git unzip

# Enable Apache2 and MariaDB to start on boot
echo "Enabling Apache2 and MariaDB services..."
sudo systemctl enable apache2
sudo systemctl enable mariadb

# Start Apache2 and MariaDB
echo "Starting Apache2 and MariaDB services..."
sudo systemctl start apache2
sudo systemctl start mariadb

# Secure MariaDB installation (Optional: Disable password validation)
echo "Securing MariaDB installation..."
sudo mysql_secure_installation <<EOF

Y
n
Y
Y
Y
EOF

# Set up DVWA database
echo "Setting up DVWA database..."
sudo mysql -u root <<EOF
CREATE DATABASE dvwa;
CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';
FLUSH PRIVILEGES;
EOF

# Clone the DVWA repository
echo "Cloning DVWA repository..."
cd /srv/www/htdocs
sudo git clone https://github.com/digininja/DVWA.git
cd DVWA

# Set correct permissions
echo "Setting permissions for DVWA..."
sudo chown -R wwwrun:www /srv/www/htdocs/DVWA
sudo chmod -R 755 /srv/www/htdocs/DVWA

# Copy the configuration file
echo "Configuring DVWA..."
sudo cp config/config.inc.php.dist config/config.inc.php
sudo sed -i "s/'db_password' => ''/'db_password' => 'p@ssw0rd'/g" config/config.inc.php

# Configure PHP settings
echo "Adjusting PHP settings..."
sudo sed -i "s/allow_url_include = Off/allow_url_include = On/g" /etc/php*/apache2/php.ini
sudo sed -i "s/display_errors = Off/display_errors = On/g" /etc/php*/apache2/php.ini

# Restart Apache2 to apply changes
echo "Restarting Apache2..."
sudo systemctl restart apache2

# Final message
echo "DVWA installation is complete. Access it at http://localhost/DVWA"
echo "Use the default credentials: admin/password after completing the DVWA setup wizard."
