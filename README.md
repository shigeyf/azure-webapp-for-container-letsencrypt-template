# Azure Web App for Container - Let's Encrypt Docker template

This repository is a Docker template for Azure Web App for Containers in order to use a SSL certificate issued by Let's Enceypt for your custom SSL domain.

## Overview

Azure Web App (for Containers) provides *.azurewebsites.net domain with SSL certificate by default. If you want to use your custom domain with HTTPS/SSL, you will need to have your own SSL certificate for your custom SSL domain and bind it to you Azure Web App.

If you are using Azure Web App with Windows host (Windows Azure Web App Service Plan), you can use Azure Web App Site Extension feature. There is a site extension to support issuing Let's Encrypt certificate for your custom SSL domain, which is [SJKP Let's Encrypt Site Extension](https://github.com/sjkp/letsencrypt-siteextension) as third party OSS extension. But, you are using Azure Web App with Linux host (Linux Azure Web App Service Plan), you can not use the site extension. This is why I am motivated to create this repository.

This Docker image uses [certbot](https://certbot.eff.org/) to issue a free [Let's Encrypt](https://letsencrypt.org/) SSL certificate for your custom SSL domain in Docker guest container, and upload and bind the issued SSL certificate for your custom domain to and with your Azure Web App instance from container inside with Azure CLI.

## How to use this repository

### 1. Prerequisites

#### a. Get Azure CLI Credentials

You need to have a Service Principal account and certificate to operate your Azure Resources from Docker container inside; to install an issued Let's Encrypt SSL certificate to your Azure subscription and to bind the SSL certificate with registered custom domain).

To create a service principal and its own certificate, you can run the following Azure CLI command in your desktop environment.

```cmd
az ad sp create-for-rbac --name 
```

After creating a certificate, put your certificate as `azcli_sp_cert.pem` filename into `files/rootdiretc/az-cli` folder.

> SECURITY WARNING!: Please avoid publishing your custom Docker image due to the security reason, if your certificate for Azure CLI operations is contained in your custom Docker image!
> You can put your certificate into Azure Web App host (Docker host enviroment) and mount a host volume into your Docker container to refer your certifciate from scripts inside the container. In that case, you should modify Dockerfile so that a symbolic link file (`/etc/az-cli/az_sp_cert.pem`) in your Docker container refers the certificate file on the mounted volue (host volume).

Please see more details at Azure documentation; [Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)

#### b. Add required DNS records in your DNS domain service

Please follow the documentation to add required DNS records in your DNS domain service for your custom domain.
  * [Get a domain verification ID](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain#get-a-domain-verification-id)
  * [Map your domain](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain#map-your-domain)

### 2. Create your custom Docker image

You can simply use my public Docker image (`shigeyf/azwebappcontainer-letsencrypt-nginx`) from Docker Hub as a base image of your Docker image.

Or you can use this repository to create your custom Docker image.

### 3. Deploy your Web App in your Azure Subscription and configure App Settings in Your Azure Web App

#### a. Create an App Service Plan

Please follow the documentation:
  * [Create an App Service plan](https://docs.microsoft.com/en-us/azure/app-service/app-service-plan-manage#:~:text=%20Create%20an%20App%20Service%20plan%20%201,a%20plan%20by%20selecting%20Create%20new.%20More%20)

### b. Deploy an instance of Azure App Services

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

TO deploy an intance of Azure App Services (Web App for Containers) and configure App Settings into your Azure Web App, please see the `deploy-resources/azure-template` folder to deploy with Azure Template.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fshigeyf%2Fazure-webapp-for-container-letsencrypt-template%2Fmain%2Fdeploy-resources%2Fazure-template%2Ftemplate-all.json)

The parameters of Azure Deployment template is as follows:

| Name | Value |
| -- | -- |
| subscriptionId                    | Azure Subscription Id |
| name                              | A name for instance of Azure Web App for Containers |
| location                          | Location name |
| hostingPlanName                   | A name for App Service Plan |
| serverFarmResourceGroup           | A resource group name of App Service Plan |
| websiteCustomDomainName           | A custom domain name for your Azure Web App |
| webSitesResourceGroup             | A resource group name for your Azure Web App |
| alwaysOn                          | Enable AlwaysOn |
| linuxFxVersion                    | The Runtime stack of current web app |
| dockerRegistryUrl                 | Docker Registry URL |
| dockerRegistryUsername            | Docker Registry Username |
| dockerRegistryPassword            | Docker Registry Password |
| dockerRegistryStartupCommand      | Docker Registry Startup Command |
| enableAppServiceStorage           | Enable App Service Storage to mount the volume to the container |
| azureCliServicePrincipalId        | Your Azure Service Pricipal account Id which is used for Azure CLI operations |
| azureCliServicePrincipalTenantId  | Your Azure Tenant Id of your Azure Service Pricipal account which is used for Azure CLI operations |
| letsencryptEmail                  | E-mail address used in Let's Encrypt (certbot) |
