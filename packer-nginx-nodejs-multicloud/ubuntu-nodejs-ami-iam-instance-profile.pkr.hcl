# Note! 
# This template uses "iam_instance_profile" to define permissions in order to enable the http ports: 80 and 443

# This block defines the required plugins for the Packer build.
# The Amazon plugin is specified with its source and version to ensure compatibility.
packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Variables
variable "aws_region" {
  default = "us-east-1"
}

variable "ami_base" {
    default = "ami-042e8287309f5df03" # Ubuntu Server 20.04 LTS in the us-east-1 region
}

# Configuración de Packer
source "amazon-ebs" "ubuntu-nodejs" {
  region           = var.aws_region
  instance_type    = "t2.micro"
  ami_name         = "ubuntu-nodejs-nginx-ami-{{timestamp}}"
  source_ami       = var.ami_base
  ssh_username     = "ubuntu"
  associate_public_ip_address = true
  iam_instance_profile = "my-ec2-role" # Change for the user instance profile of aws account
}

# Bloque de construcción
build {
  sources = ["source.amazon-ebs.ubuntu-nodejs"]

  # Provisioner que configura las reglas del grupo de seguridad

  provisioner "shell" {
    only = ["amazon-ebs.ubuntu-nodejs"]
    
    inline = [
      # Instalar AWS CLI
      "sudo apt-get install -y curl unzip",
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "aws --version",
      # Obtener el ID de la instancia
      "INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || { echo 'Error fetching INSTANCE_ID'; exit 1; })",
      "echo INSTANCE_ID=$INSTANCE_ID",
      # Obtener el ID del grupo de seguridad
      "SG_ID=$(aws ec2 describe-instances --instance-id $INSTANCE_ID --region us-east-1 --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text || { echo 'Error fetching SG_ID'; exit 1; })",
      "echo SG_ID=$SG_ID",
      # Agregar reglas de ingreso
      "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 || { echo 'Error authorizing ingress for port 80'; exit 1; }",
      "aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 || { echo 'Error authorizing ingress for port 443'; exit 1; }"
    ]
  }


  # Provisioner que instala Node.js y configura la aplicación
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      # Instalar Node.js
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      # Crear aplicación Node.js
      "mkdir -p /home/ubuntu/app",
      "cat <<EOF > /home/ubuntu/app/server.js",
      "const http = require('http');",
      "const server = http.createServer((req, res) => {",
      "  if (req.url === '/hello' && req.method === 'GET') {",
      "    res.writeHead(200, {'Content-Type': 'text/plain'});",
      "    res.end('World');",
      "  } else {",
      "    res.writeHead(404, {'Content-Type': 'text/plain'});",
      "    res.end('Not Found');",
      "  }",
      "});",
      "server.listen(3000, () => console.log('Server running on port 3000'));",
      "EOF",
      # Instalar y configurar NGINX
      "sudo apt-get install -y nginx",
      "sudo rm /etc/nginx/sites-enabled/default",
      "cat <<EOF | sudo tee /etc/nginx/sites-available/app",
      "server {",
      "  listen 80;",
      "  server_name _;",
      "  location / {",
      "    proxy_pass http://localhost:3000;",
      "    proxy_http_version 1.1;",
      "    proxy_set_header Upgrade $$http_upgrade;",
      "    proxy_set_header Connection 'upgrade';",
      "    proxy_set_header Host $$host;",
      "    proxy_cache_bypass $$http_upgrade;",
      "  }",
      "}",
      "EOF",
      "sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app",
      "sudo systemctl restart nginx",
      # Configurar permisos y ejecutar la aplicación Node.js
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/app",
      "node /home/ubuntu/app/server.js &",
      ## Habilitar puertos 80 y 443 en el firewall
      #"sudo ufw allow 80",
      #"sudo ufw allow 443",
      #"sudo ufw --force enable"
    ]
  }
}
