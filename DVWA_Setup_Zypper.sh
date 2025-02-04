#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo zypper refresh && sudo zypper update -y

# Install required packages
echo "Installing necessary packages..."
sudo zypper install -y apache2 mariadb mariadb-client php8 php8-mysql git unzip

# Enable Apache2 and MariaDB to start on boot
echo "Enabling Apache2 and MariaDB services..."
sudo systemctl enable apache2
sudo systemctl enable mariadb

# Start Apache2 and MariaDB
echo "Starting Apache2 and MariaDB services..."
sudo systemctl start apache2
sudo systemctl start mariadb

# Secure MariaDB installation (skipping root password change if already set)
echo "Securing MariaDB installation..."
sudo mysql_secure_installation <<EOF

Y
n
Y
Y
Y
EOF

# Set up DVWA database if it doesn't exist
echo "Setting up DVWA database..."
sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS dvwa;"
sudo mysql -u root -e "CREATE USER IF NOT EXISTS 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Clone the DVWA repository if it doesn't exist
cd /srv/www/htdocs
if [ ! -d "DVWA" ]; then
    echo "Cloning DVWA repository..."
    sudo git clone https://github.com/digininja/DVWA.git
else
    echo "DVWA repository already exists. Skipping clone."
fi
cd DVWA

# Set correct permissions
echo "Setting permissions for DVWA..."
sudo chown -R wwwrun:www /srv/www/htdocs/DVWA
sudo chmod -R 755 /srv/www/htdocs/DVWA

# Copy and configure the DVWA settings file
echo "Configuring DVWA..."
if [ ! -f "config/config.inc.php" ]; then
    sudo cp config/config.inc.php.dist config/config.inc.php
fi
sudo sed -i "s/'db_password' => ''/'db_password' => 'p@ssw0rd'/g" config/config.inc.php

# Adjust PHP settings (correct path for openSUSE)
echo "Adjusting PHP settings..."
sudo sed -i "s/allow_url_include = Off/allow_url_include = On/g" /etc/php8/php.ini
sudo sed -i "s/display_errors = Off/display_errors = On/g" /etc/php8/php.ini

# Restart Apache2 to apply changes
echo "Restarting Apache2..."
sudo systemctl restart apache2

# Final message
echo "✅ DVWA installation is complete. Access it at: http://localhost/DVWA"
echo "➡️ Default credentials: admin/password (after completing setup wizard)"
