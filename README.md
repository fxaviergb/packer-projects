# packer-projects
Packer is a tool that lets you create identical machine images for multiple platforms from a single source template. This repository contains some examples to use Packer.

## Repository Objective

The main objective of this repository is to provide a simple and reusable template for:

- Automating the creation of custom machine images (AMIs).
- Deploying specific configurations (such as NGINX and Node.js) in a reproducible manner.
- Reducing manual errors in operating system setup.
- Facilitating application portability across different cloud providers.

## Benefits of Using Packer

Packer is an open-source tool that automates the creation of machine images across multiple cloud and virtualization platforms. Key benefits include:

- **Efficiency:** Automates the image creation process, saving time and effort.
- **Reproducibility:** Ensures created images are consistent, regardless of how many times they're built.
- **Multicloud Compatibility:** Supports AWS, Azure, Google Cloud, VMware, and more.
- **Infrastructure as Code (IaC):** Uses declarative definitions in HCL or JSON format.

## Installing Packer

Follow the steps below to install Packer on your local machine:

### 1. Download Packer

Visit the [official Packer downloads page](https://www.packer.io/downloads) and select the version suitable for your operating system.

### 2. Installation on Linux/macOS

1. Download the corresponding zip file.
2. Unzip the file:
   ```bash
   unzip packer_<VERSION>_linux_amd64.zip
   ```
3. Move the binary to a directory in your `PATH`:
   ```bash
   sudo mv packer /usr/local/bin/
   ```
4. Verify the installation:
   ```bash
   packer --version
   ```

### 3. Installation on Windows

1. Download the corresponding zip file.
2. Unzip the file and add the binary location to the `PATH` environment variable.
3. Verify the installation:
   ```cmd
   packer --version
   ```

## Important Packer Commands

Below are some of the most important commands for working with Packer:

- **`packer init`**
  Initializes the environment and downloads the necessary plugins defined in the `.pkr.hcl` file.
  ```bash
  packer init <file.pkr.hcl>
  ```

- **`packer validate`**
  Validates that the configuration file is syntactically correct.
  ```bash
  packer validate <file.pkr.hcl>
  ```

- **`packer build`**
  Builds the machine image based on the provided configuration.
  ```bash
  packer build <file.pkr.hcl>
  ```

- **`packer fmt`**
  Formats the configuration file to adhere to recommended style guidelines.
  ```bash
  packer fmt <file.pkr.hcl>
  ```

- **`packer inspect`**
  Displays the details of the sources defined in a `.pkr.hcl` file.
  ```bash
  packer inspect <file.pkr.hcl>
  ```

## Repository Structure

```
packer-projects/
├── packer-aws-nginx-deploy/
│   ├── packer-aws-template.pkr.hcl
│   ├── README.md
├── packer-nginx-nodejs-multicloud/
│   ├── ubuntu-nodejs-ami.pkr.hcl
│   ├── .gitignore
│   ├── LICENSE
│   ├── README.md
```

- **`packer-aws-template.pkr.hcl`:** Base configuration for creating AMIs on AWS.
- **`ubuntu-nodejs-ami.pkr.hcl`:** Customized configuration for installing NGINX and Node.js.

## How to Use This Repository

1. Clone the repository:
   ```bash
   git clone <REPOSITORY-URL>
   cd packer-projects/packer-nginx-nodejs-multicloud
   ```

2. Initialize Packer:
   ```bash
   packer init ubuntu-nodejs-ami.pkr.hcl
   ```

3. Validate the configuration:
   ```bash
   packer validate ubuntu-nodejs-ami.pkr.hcl
   ```

4. Build the image:
   ```bash
   packer build ubuntu-nodejs-ami.pkr.hcl
   ```

## License

This repository is licensed under the MIT License. See the `LICENSE` file for more details.