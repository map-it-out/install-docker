#!/bin/bash

# Check if DOMAIN parameter is provided
if [ -z "$1" ]; then
    echo "Error: DOMAIN parameter is missing."
    exit 1
fi

# Variables - replace these with your own values
DOMAIN="$1"

#!/bin/bash

sudo apt-get update

# Install Docker and Docker Compose
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce -y

sudo usermod -aG docker $USER
newgrp docker

sudo curl -L "https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Nginx and Certbot
sudo apt-get install -y nginx certbot python3-certbot-nginx

# Create docker-compose.yml file
mkdir -p wordpress-docker
cd wordpress-docker

# Start Docker Compose
sudo docker-compose up -d

# Configure Nginx as a reverse proxy
sudo tee /etc/nginx/sites-available/wordpress <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /phpmyadmin/ {
        proxy_pass http://localhost:8081/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Enable the Nginx configuration and restart Nginx
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Obtain an SSL certificate with Certbot
sudo certbot --nginx -d $DOMAIN

# Print the final message
echo "WordPress deployment with SSL completed. Access your site at https://$DOMAIN"
