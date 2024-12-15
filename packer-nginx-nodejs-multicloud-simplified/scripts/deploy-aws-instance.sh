#!/bin/bash

# Define el prefijo del nombre de las AMIs
AMI_NAME_PREFIX="nginx-nodejs-ubuntu-ami-"

# Obtén el ID de la AMI más reciente que coincida con el prefijo
echo "Buscando la AMI mas reciente cuyo nombre comienza con '${AMI_NAME_PREFIX}'..."
AMI_ID=$(aws ec2 describe-images --owners self --filters "Name=name,Values=${AMI_NAME_PREFIX}*" --query "Images | sort_by(@, &CreationDate)[-1].ImageId" --output text)

# Verifica si el ID es válido
if [ "$AMI_ID" = "None" ] || [ -z "$AMI_ID" ]; then
  echo "Error: No se encontró ninguna AMI con el nombre que inicia con '${AMI_NAME_PREFIX}'."
  exit 1
else
  echo "AMI ID obtenida: $AMI_ID"
fi

# Obtener la subred predeterminada
DEFAULT_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=default-for-az,Values=true" --query "Subnets[0].SubnetId" --output text)
echo "Subred predeterminada seleccionada con ID: $DEFAULT_SUBNET_ID"

# Creación o reutilización del Security Group predeterminado
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query "SecurityGroups[0].GroupId" --output text)
echo "Security Group predeterminado seleccionado con ID: $SG_ID"

# Abrir los puertos necesarios (si no están abiertos)
echo "Configurando reglas de seguridad..."
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 2>/dev/null || echo "Regla de SSH ya existe"
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || echo "Regla de HTTP ya existe"

# Lanzar instancia EC2
echo "Iniciando instancia EC2..."
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro --subnet-id $DEFAULT_SUBNET_ID --security-group-ids $SG_ID --query "Instances[0].InstanceId" --output text)
echo "Instancia EC2 creada con ID: $INSTANCE_ID"