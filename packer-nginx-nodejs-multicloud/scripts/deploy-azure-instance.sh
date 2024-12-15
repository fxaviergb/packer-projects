#!/bin/bash

# Obtener IP publica
PUBLIC_IP=$(az vm create \
  --resource-group packer-resource-group \
  --name nginx-nodejs-vm \
  --image nginx-nodejs-ubuntu-image \
  --admin-username ubuntu \
  --generate-ssh-keys \
  --query 'publicIpAddress' \
  --output tsv)

echo "Azure Public IP: $PUBLIC_IP"

# Obtener NSG
NSG_NAME=$(az network nsg list \
  --query "[?contains(name, 'nginx-nodejs-vm')].name | [0]" \
  --output tsv)

echo "NSG Name: $NSG_NAME"

# Configurar gruposde seguridad
az network nsg rule create --nsg-name nginx-nodejs-vmNSG --resource-group packer-resource-group --name AllowSSH --priority 1010 --protocol Tcp --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow > /dev/null 2>&1
az network nsg rule create --nsg-name nginx-nodejs-vmNSG --resource-group packer-resource-group --name AllowHTTP --priority 1020 --protocol Tcp --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 80 --access Allow > /dev/null 2>&1

echo "Finalizado!"