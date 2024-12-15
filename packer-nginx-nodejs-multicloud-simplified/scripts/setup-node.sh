#!/bin/bash
set -e

# Actualizar e instalar Node.js
sudo apt-get update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs nginx

echo "NodeJS instalado correctamente."