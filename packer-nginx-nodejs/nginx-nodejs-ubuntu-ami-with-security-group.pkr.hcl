# Note! 
# This template uses "security_group_id" pre-configured that allow http 80, 22, etc
# Testing the result, invoke "curl http://<PUBLIC_IP>/hello"

# This block defines the required plugins for the Packer build.
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

variable "aws_ami_base" {
  default = "ami-042e8287309f5df03" # Ubuntu Server 20.04 LTS in the us-east-1 region
}

variable "aws_security_group_id" {
  default = "sg-09727ecb310615481" # Insert the pre-configured security-group-id !!!IMPORTANT
}

# Source: Amazon-EBS configuration
source "amazon-ebs" "nginx-nodejs-ubuntu" {
  region           = var.aws_region
  instance_type    = "t2.micro"
  ami_name         = "nginx-nodejs-ubuntu-ami-{{timestamp}}"
  source_ami       = var.aws_ami_base
  ssh_username     = "ubuntu"
  associate_public_ip_address = true
  security_group_id = var.aws_security_group_id
}

# Builders
build {
  sources = ["source.amazon-ebs.nginx-nodejs-ubuntu"]

  # Provisioner that install Node.js and make the app configuration
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      # Install Node.js
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      # Create a Node.js app
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
      # Install and configure NGINX
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
      # Configure NodeJS app permissions and execute
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/app",
      "node /home/ubuntu/app/server.js &"
    ]
  }
}
