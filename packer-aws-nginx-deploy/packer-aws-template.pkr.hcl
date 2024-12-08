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

# These variables allow customization of the build process without modifying the main template.
# They define the AWS region, the base AMI to use, and the instance type for the build.
variable "aws_region" {
  default = "us-east-1"
}

variable "source_ami" {
  default = "ami-042e8287309f5df03" # Ubuntu Server 20.04 LTS in the us-east-1 region
}

variable "instance_type" {
  default = "t2.micro"
}

# The source block specifies the configuration for creating the AMI using the Amazon EBS builder.
# It includes details such as the AWS region, the base AMI, the instance type, and SSH username.
# It also defines the name and description for the new AMI, as well as tags for categorization.
source "amazon-ebs" "example" {
  region           = var.aws_region
  source_ami       = var.source_ami
  instance_type    = var.instance_type
  ssh_username     = "ubuntu"
  ami_name         = "packer-example-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  ami_description  = "An example AMI built with Packer"
  tags = {
    Name        = "PackerExample"
    Environment = "Development"
  }
}

# The build block defines the steps to create the AMI.
# It references the source block and uses a shell provisioner to configure the instance.
# During provisioning, Nginx is installed, and the service is enabled to start at boot.
build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",                  # Update package lists
      "sudo apt-get install -y nginx",        # Install Nginx
      "sudo systemctl enable nginx"           # Enable Nginx to start at boot
    ]
  }
}
