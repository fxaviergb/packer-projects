#!/bin/bash
set -e

# Instalar PM2
sudo npm install -g pm2

# Crear aplicación Node.js
mkdir -p /home/ubuntu/app
cat <<EOF > /home/ubuntu/app/server.js
const http = require('http');
const server = http.createServer((req, res) => {
  if (req.url === '/' && req.method === 'GET') {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end('<html><body style="font-size:18px;">Hola estudiantes de la <span style="color:blue;">UNIR</span>. Se reporta <span style="color:green;">Fernando Xavier</span>!</body></html>');
  } else {
    res.writeHead(404, {'Content-Type': 'text/plain'});
    res.end('Uuups! Esta ruta no existe.');
  }
});
server.listen(3000, () => console.log('Server running on port 3000'));
EOF

# Configurar PM2
sudo chown -R ubuntu:ubuntu /home/ubuntu/app
pm2 start /home/ubuntu/app/server.js --name server
sudo pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save

echo "PM2 configurado correctamente."