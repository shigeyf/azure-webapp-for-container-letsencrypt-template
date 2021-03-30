# Azure Web App for Container - Let's Encrypt Docker template

This repository is a Docker template for Azure Web App for Containers in order to use a SSL certificate issued by Let's Enceypt for your custom SSL domain.

## Overview

Azure Web App (for Containers) provides *.azurewebsites.net domain with SSL certificate by default. If you want to use your custom domain with HTTPS/SSL, you will need to have your own SSL certificate for your custom SSL domain and bind it to you Azure Web App.

If you are using Azure Web App with Windows host (Windows Azure Web App Service Plan), you can use Azure Web App Site Extension feature. There is a site extension to support issuing Let's Encrypt certificate for your custom SSL domain, which is [SJKP Let's Encrypt Site Extension](https://github.com/sjkp/letsencrypt-siteextension) as third party OSS extension. But, you are using Azure Web App with Linux host (Linux Azure Web App Service Plan), you can not use the site extension. This is why I am motivated to create this repository.

This Docker image uses [certbot](https://certbot.eff.org/) to issue a free [Let's Encrypt](https://letsencrypt.org/) SSL certificate for your custom SSL domain in Docker guest container, and upload and bind the issued SSL certificate for your custom domain to and with your Azure Web App instance from container inside with Azure CLI.

## How to use this repository

### Prerequisites

You need to have a Service Principal account and certificate to operate your Azure Resources from Docker container inside.

To create a service principal and its own certificate, you can run the following Azure CLI command in your desktop environment.

```cmd
az ad sp create-for-rbac --name 
```

After creating a certificate, put your certificate as `azcli_sp_cert.pem` filename into `files/rootdiretc/az-cli` folder.

> SECURITY WARNING!: Please avoid publishing your custom Docker image due to the security reason, if your certificate for Azure CLI operations is contained in your custom Docker image!
> You can put your certificate into Azure Web App host (Docker host enviroment) and mount a host volume into your Docker container to refer your certifciate from scripts inside the container. In that case, you should modify Dockerfile so that a symbolic link file (`/etc/az-cli/az_sp_cert.pem`) in your Docker container refers the certificate file on the mounted volue (host volume).

### Create your custom Docker image

You can simply use my public Docker image ('shigeyf/azwebappcontainer-letsencrypt-nginx') from Docker Hub as a base image of your Docker image.

Or you can use this repository to create your custom Docker image.

### Prepare App Settings in Your Azure Web App

This Docker image uses multiple Environment Variables of Docker Host to pass your customized parameters (such as Web App name, your custom SSL domain name, etc.) to certbot modules inside the Docker container.

You need to set up the following enviroment variables as App Settings of your Azure Web App.

| Name | Value |
| -- | -- |
| AZURE_CLI_SERVICE_PRINCIPAL_ID | Your Azure Service Pricipal account Id which is used for Azure CLI operations |
| AZURE_CLI_SERVICE_PRINCIPAL_TENANT_ID | Your Azure Tenant Id of your Azure Service Pricipal account which is used for Azure CLI operations |
| LETSENCRYPT_EMAIL | Your email address to get notifications from Let's Encrypt |
| LETSENCRYPT_HOSTNAME | Your custom domain/host name |
| WEBSITE_SITE_NAME | A name of your Azure Web App |
| WEBSITES_RESOURCE_GROUP | A resource group name of your Azure Web App |

> NOTE: You can use Azure Template to create your Azure Web App or deploy App Settings into your Azure Web App. Please see the `deploy-resources/azure-template` folder.
