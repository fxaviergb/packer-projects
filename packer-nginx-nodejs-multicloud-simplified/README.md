# Proyecto: Imágenes Nginx y Node.js Multinube con Packer

Este proyecto utiliza Packer para crear imágenes de máquinas virtuales preconfiguradas con Nginx, Node.js y PM2, adaptadas para despliegues en entornos multinube como AWS y Azure. Es ideal para quienes desean estandarizar sus entornos de despliegue.

## Estructura del Proyecto

- **`nginx-nodejs-ubuntu-image-multicloud.json`**: Archivo de configuración principal de Packer que define el proceso de creación de imágenes.
- **`scripts/`**: Contiene los scripts utilizados durante la creación y configuración de las imágenes:
  - **`setup-nginx.sh`**: Instala y configura Nginx.
  - **`setup-node.sh`**: Instala Node.js y sus dependencias.
  - **`setup-pm2.sh`**: Configura PM2 para la gestión de procesos de Node.js.
  - **`deploy-aws-instance.sh`**: Despliega una instancia en AWS utilizando la imagen creada.
  - **`deploy-azure-instance.sh`**: Despliega una instancia en Azure utilizando la imagen creada.
- **`credentials.json`**: Archivo para manejar credenciales de acceso a las nubes. Debe ser configurado adecuadamente antes de usar el proyecto.

## Pre-requisitos

1. **Packer** instalado en su sistema.
2. **Credenciales de nube** configuradas:
   - AWS: Archivo `~/.aws/credentials` o variables de entorno configuradas.
   - Azure: Archivo `credentials.json` o CLI de Azure autenticada.
3. **Acceso a las cuentas de nube** con permisos para crear recursos.
4. **Install Packer Plugins**: Ensure that next Plugins are installed on your local machine.

   ```bash
   packer plugins install github.com/hashicorp/amazon
   packer plugins install github.com/hashicorp/azure
   ```

5. **AWS Access**: Set up your AWS credentials using one of the methods described in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

6. **Scripts**: Ensure all scripts in the `scripts/` directory are executable.

   ```bash
   chmod +x scripts/*.sh
   ```

## Cómo Funciona

1. Packer utiliza el archivo de configuración `nginx-nodejs-ubuntu-image-multicloud.json` para crear una imagen base de Ubuntu.
2. Durante el proceso, ejecuta los scripts del directorio `scripts/` para instalar y configurar Nginx, Node.js y PM2.
3. Las imaganes resultante están listas para ser utilizadas como base en despliegues de AWS y Azure.

## Pasos para Ejecutar el Proyecto

### 1. Configurar Credenciales

- **AWS**: Asegúrese de tener configurado `~/.aws/credentials` con un perfil válido.
- **Azure**: Modifique el archivo `credentials.json` con las credenciales adecuadas o asegúrese de estar autenticado con la CLI de Azure.

### 2. Validar la Configuración de Packer

Ejecute:

```bash
packer validate nginx-nodejs-ubuntu-image-multicloud.json
```

Esto asegura que el archivo de configuración sea válido.

### 3. Construir la Imagen

Para las dos nubes:

```bash
packer build -var-file=credentials.json nginx-nodejs-ubuntu-image-multicloud.json
```

Para AWS:

```bash
packer build -only=amazon-ebs nginx-nodejs-ubuntu-image-multicloud.json
```

Para Azure:

```bash
packer build -var-file=credentials.json -only=azure-arm nginx-nodejs-ubuntu-image-multicloud.json
```


### 4. Desplegar Instancias

Los siguientes scripts de espliegue son llamados en los post-processors de Packer, por lo que no requieren ser ejecutados de forma manual.

- AWS: Use el script `deploy-aws-instance.sh` para desplegar una instancia en AWS.

```bash
bash scripts/deploy-aws-instance.sh
```

- Azure: Use el script `deploy-azure-instance.sh` para desplegar una instancia en Azure.

```bash
bash scripts/deploy-azure-instance.sh
```

## Pruebas de los Resultados

Después de lanzar una instancia utilizando la imagen creada, siga estos pasos para probar la aplicación Node.js:

1. **Obtener la Dirección IP Pública de la Instancia**:
   Por ejemplo, en AWS vaya a la Consola de Administración de AWS, navegue a la sección de EC2 y encuentre la dirección IP pública de su instancia.

2. **Acceder a la Aplicación**: Abra su navegador web y vaya a `http://<IP_PUBLICA>` para verificar que Nginx está redirigiendo correctamente el tráfico a la aplicación Node.js. Debería ver la siguiente respuesta:

     ```
     Hola MUNDO. Se reporta Fernando Xavier!
     ```

3. **Usar `curl` para Probar**:
   Alternativamente, puede usar el comando `curl` para probar la aplicación:
   ```bash
   curl http://<IP_PUBLICA>/
   ```

   La salida esperada es:
   ```
   Hola MUNDO. Se reporta Fernando Xavier!
   ```

## Conclusión

Este proyecto simplifica la creación de entornos estandarizados para aplicaciones web en nubes públicas. Los scripts y configuraciones incluidos permiten un despliegue eficiente y replicable.
