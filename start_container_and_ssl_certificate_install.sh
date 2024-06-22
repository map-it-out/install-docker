#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

docker-compose up -d

domain="$1"

sudo certbot certonly --apache -d "$domain"

sudo apt install apache2 -y

sudo a2enmod proxy proxy_http ssl headers
sudo systemctl restart apache2

cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerName $domain

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =docker.mapitout.site
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<VirtualHost *:443>
    ServerName $domain

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/docker.mapitout.site/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/docker.mapitout.site/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
    
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"
</VirtualHost>
EOF

sudo a2ensite wordpress.conf
sudo a2enmod ssl
sudo systemctl reload apache2