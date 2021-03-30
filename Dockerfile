#
# Dockerfile
#

# ------------------------------------------------------------------------------
# the base image for this is an alpine based nginx image
#FROM nginx:alpine
FROM shigeyf/az-cli-nginx-alpine:latest

# --- only for those using react router ---------------------------------
# if you are using react router
# you need to overwrite the default nginx configurations
# remove default nginx configuration file
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig
# --- only for those using react router ---------------------------------

# --- Copy Configuration Files ------------------------------------------ 
COPY files/rootdir/ /
RUN chmod -R +x /docker-entrypoint.d/*.sh
RUN chmod -R +x /docker/letsencrypt/*.sh
# --- Copy Configuration Files ------------------------------------------ 
# --- Setup Certbot (Let'sEncrypt) -------------------------------------- 
RUN apk update && apk add certbot openssl
# --- Setup Certbot (Let'sEncrypt) -------------------------------------- 
# --- Transfer Docker Host Enviroments ----------------------------------
ENV WEBSITE_SITE_NAME=$WEBSITE_SITE_NAME
ENV WEBSITES_RESOURCE_GROUP=$WEBSITES_RESOURCE_GROUP
ENV LETSENCRYPT_HOSTNAME=$LETSENCRYPT_HOSTNAME
ENV LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL
ENV AZURE_CLI_SERVICE_PRINCIPAL_ID=$AZURE_CLI_SERVICE_PRINCIPAL_ID
ENV AZURE_CLI_SERVICE_PRINCIPAL_TENANT_ID=$AZURE_CLI_SERVICE_PRINCIPAL_TENANT_ID
# --- Transfer Docker Host Enviroments ----------------------------------

# --- Install Cert for Azure CLI command --------------------------------
# Put your certificate in files/etc/az-cli for Azure CLI operations
#  after creating a service principal and a certificate.
# You can run the following Azure CLI command in your desktop environment
#  to create a service principal and a certificate.
# CMD> az ad sp create-for-rbac --name ServicePrincipalName --create-cert
RUN mkdir -p /etc/az-cli \
    && chmod -R 700 /etc/az-cli
# --- Install Cert for Azure CLI command --------------------------------

# expose port 80 to the outer world
#EXPOSE 80
# ------------------------------------------------------------------------------
