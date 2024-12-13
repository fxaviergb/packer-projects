#!/bin/bash
set -e

# Instalar y configurar Nginx
cat <<EOF | sudo tee /etc/nginx/sites-available/app
server {
  listen 80;
  server_name _;
  location / {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
  }
}
EOF
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app
sudo nginx -t && sudo systemctl restart nginx

echo "Nginx configurado correctamente."