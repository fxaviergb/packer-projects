
# Project: Multicloud Nginx and Node.js Images with Packer

This project uses Packer to create pre-configured virtual machine images with Nginx, Node.js, and PM2, tailored for deployments in multicloud environments such as AWS and Azure. It is ideal for those looking to standardize their deployment environments.

## Project Structure

- **`nginx-nodejs-ubuntu-image-multicloud.json`**: Main Packer configuration file that defines the image creation process.
- **`scripts/`**: Contains the scripts used during the creation and configuration of the images:
  - **`setup-nginx.sh`**: Installs and configures Nginx.
  - **`setup-node.sh`**: Installs Node.js and its dependencies.
  - **`setup-pm2.sh`**: Configures PM2 for Node.js process management.
  - **`deploy-aws-instance.sh`**: Deploys an instance on AWS using the created image.
  - **`deploy-azure-instance.sh`**: Deploys an instance on Azure using the created image.
- **`credentials.json`**: File for managing cloud access credentials. Must be properly configured before using the project.

## Prerequisites

1. **Packer** installed on your system.
2. **Cloud credentials** configured:
   - AWS: `~/.aws/credentials` file or environment variables configured.
   - Azure: `credentials.json` file or authenticated Azure CLI.
3. **Access to cloud accounts** with permissions to create resources.
4. **Install Packer Plugins**: Ensure the following plugins are installed on your local machine.

   ```bash
   packer plugins install github.com/hashicorp/amazon
   packer plugins install github.com/hashicorp/azure
   ```

5. **AWS Access**: Set up your AWS credentials using one of the methods described in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

6. **Scripts**: Ensure all scripts in the `scripts/` directory are executable.

   ```bash
   chmod +x scripts/*.sh
   ```

## How It Works

1. Packer uses the `nginx-nodejs-ubuntu-image-multicloud.json` configuration file to create a base Ubuntu image.
2. During the process, it executes the scripts in the `scripts/` directory to install and configure Nginx, Node.js, and PM2.
3. The resulting images are ready to be used as a base for deployments on AWS and Azure.

## Steps to Execute the Project

### 1. Configure Credentials

- **AWS**: Ensure `~/.aws/credentials` is configured with a valid profile.
- **Azure**: Modify the `credentials.json` file with the appropriate credentials or ensure you are authenticated with the Azure CLI.

### 2. Validate the Packer Configuration

Run:

```bash
packer validate nginx-nodejs-ubuntu-image-multicloud.json
```

This ensures the configuration file is valid.

### 3. Build the Image

For both clouds:

```bash
packer build -var-file=credentials.json nginx-nodejs-ubuntu-image-multicloud.json
```

For AWS:

```bash
packer build -only=amazon-ebs nginx-nodejs-ubuntu-image-multicloud.json
```

For Azure:

```bash
packer build -var-file=credentials.json -only=azure-arm nginx-nodejs-ubuntu-image-multicloud.json
```

### 4. Deploy Instances

The following deployment scripts are invoked in Packer’s post-processors and do not need to be run manually.

- AWS: Use the `deploy-aws-instance.sh` script to deploy an instance on AWS.

```bash
bash scripts/deploy-aws-instance.sh
```

- Azure: Use the `deploy-azure-instance.sh` script to deploy an instance on Azure.

```bash
bash scripts/deploy-azure-instance.sh
```

## Testing the Results

After launching an instance using the created image, follow these steps to test the Node.js application:

1. **Get the Public IP Address of the Instance**:
   For example, on AWS, go to the AWS Management Console, navigate to the EC2 section, and find the public IP address of your instance.

2. **Access the Application**: Open your web browser and go to `http://<PUBLIC_IP>` to verify that Nginx is correctly redirecting traffic to the Node.js application. You should see the following response:

     ```
     Hello WORLD. Reporting from Fernando Xavier!
     ```

3. **Use `curl` to Test**:
   Alternatively, you can use the `curl` command to test the application:
   ```bash
   curl http://<PUBLIC_IP>/
   ```

   The expected output is:
   ```
   Hello WORLD. Reporting from Fernando Xavier!
   ```

## Conclusion

This project simplifies the creation of standardized environments for web applications in public clouds. The included scripts and configurations enable efficient and replicable deployments.
