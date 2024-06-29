#!/bin/bash

# Update system packages
sudo apt update

# Install Apache web server
sudo apt install apache2 -y

# Install MySQL server
sudo apt install mysql-server -y

# Secure MySQL installation
sudo mysql_secure_installation

# Install PHP and required extensions
sudo apt install php libapache2-mod-php php-mysql -y

# Restart Apache web server
sudo systemctl restart apache2

# Download and extract WordPress
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz

# Move WordPress files to Apache web server root directory
sudo mv wordpress/* /var/www/html/

# Set permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Create MySQL database for WordPress
sudo mysql -u root -p -e "CREATE DATABASE wordpress;"
sudo mysql -u root -p -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"
sudo mysql -u root -p -e "EXIT"

# Download and install phpMyAdmin
sudo apt install phpmyadmin -y

# Configure phpMyAdmin
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin.conf
sudo systemctl reload apache2

# Cleanup
rm latest.tar.gz
rm -rf wordpress

# Install Certbot
sudo apt install certbot python3-certbot-apache -y

# Obtain SSL certificate using Certbot
sudo certbot --apache

# Enable reverse proxy
sudo a2enmod proxy
sudo a2enmod proxy_http

# Restart Apache web server
sudo systemctl restart apache2

echo "Reverse proxy and SSL certificate installation completed!"

echo "WordPress installation completed!"