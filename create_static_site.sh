#! /bin/sh

# Get domain name from parameter
domain="$1"

# Check if domain is defined
if [ -z "$domain" ]; then
    echo "Error: domain name is not defined"
    return 1
fi

# Prompt for directory where static site is deployed
echo -n "Enter the directory where the static site is deployed: "
read dir

# Check if directory exists
if [ ! -d "$dir" ]; then
    echo "Error: directory does not exist"
    return 1
fi

# Create new virtual host configuration file
sudo tee /etc/nginx/sites-available/"$domain" > /dev/null << EOF
server {
    listen 80;
    listen [::]:80;

    server_name $domain;

    root $dir;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
# Create symbolic link to file in sites-enabled directory
sudo ln -s /etc/nginx/sites-available/"$domain" /etc/nginx/sites-enabled/

# Test Nginx configuration syntax
sudo nginx -t


# Reload Nginx service to apply new configuration
sudo systemctl reload nginx

# Obtain SSL certificate using Certbot
sudo certbot --nginx -d "$domain"

echo "Virtual host for static site has been created and enabled"