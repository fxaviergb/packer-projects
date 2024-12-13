
# Packer Template: Nginx and Node.js on AWS

This repository contains a Packer template to build an Amazon Machine Image (AMI) with Nginx, Node.js, and PM2 installed. The template uses shell scripts to automate the provisioning and configuration of the environment.

## Repository Structure

```
packer-nginx-nodejs-multicloud/
├── scripts/
│   ├── deploy-aws-instance.sh   # Deployment script
│   ├── setup-nginx.sh           # Script to install and configure Nginx
│   ├── setup-node.sh            # Script to install Node.js
│   ├── setup-pm2.sh             # Script to install and configure PM2
│   └── nginx-nodejs-ubuntu-ami-multicloud.json  # Packer template for multicloud
├── README.md                    # Project documentation
```

## Prerequisites

1. **Install Packer**: Ensure that Packer is installed on your local machine.

   - [Packer installation guide](https://developer.hashicorp.com/packer/downloads)

2. **AWS Access**: Set up your AWS credentials using one of the methods described in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

3. **Scripts**: Ensure all scripts in the `scripts/` directory are executable.

   ```bash
   chmod +x scripts/*.sh
   ```

## How It Works

### Template Overview

- **Builders**: The template uses the `amazon-ebs` builder to create an AMI from a base image.
- **Provisioners**: The provisioners execute shell scripts to:
  - Install Node.js (`setup-node.sh`)
  - Configure Nginx as a reverse proxy (`setup-nginx.sh`)
  - Install and set up PM2 for process management (`setup-pm2.sh`)
- **Post-processors**: A local shell script (`deploy-aws-instance.sh`) is run after building the AMI.

### Configuration

The Packer template is located in `nginx-nodejs-ubuntu-ami-multicloud.json` and includes the following variables:

- **`aws_region`**: Specifies the AWS region to use (default: `us-east-1`).
- **`aws_ami_base`**: Defines the base AMI (default: `ami-042e8287309f5df03`).

## Steps to Build the AMI

1. **Validate the Template**

   ```bash
   packer validate nginx-nodejs-ubuntu-ami-multicloud.json
   ```

2. **Build the AMI**

   ```bash
   packer build -var 'aws_region=us-east-1' -var 'aws_ami_base=ami-042e8287309f5df03' nginx-nodejs-ubuntu-ami-multicloud.json
   ```

3. **Deploy the AMI**
   Once the AMI is built, you can use the deployment script to launch an EC2 instance with the created AMI:

   ```bash
   ./scripts/deploy-aws-instance.sh
   ```

## Script Details

### `setup-node.sh`

- Updates and upgrades the system packages.
- Installs Node.js and npm using the NodeSource setup script.

### `setup-nginx.sh`

- Installs Nginx.
- Configures Nginx as a reverse proxy to forward traffic to the Node.js application.

### `setup-pm2.sh`

- Installs PM2 globally using npm.
- Starts the Node.js application using PM2.
- Configures PM2 to restart the application on system reboot.

### `deploy-aws-instance.sh`

- Automates the deployment of an EC2 instance using the created AMI.
- Configures networking and security groups for the instance.

## Testing the Deployment

1. After deployment, access the server's public IP in your browser.
2. Ensure the application is running and accessible through Nginx.

## License

This project is licensed under the MIT License.