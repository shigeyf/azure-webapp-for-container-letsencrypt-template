#!/bin/sh
# vim:sw=4:ts=4:et

set -e

. /etc/dockerhost-envs

echo "Uploading new SSL certificate for ${LETSENCRYPT_HOSTNAME}"

_CERTROOT=/etc/letsencrypt/live/${LETSENCRYPT_HOSTNAME}
_PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!@#$%^&*()_+{}|:<>?=' | fold -w 32 | grep -i '[!@#$%^&*()_+{}|:<>?=]' | head -n 1`
_PFX=/root/${LETSENCRYPT_HOSTNAME}-certificate.pfx
_AZCERT=/etc/az-cli/azcli_sp_cert.pem
_CERT_FINGERPRINT=`openssl x509 -in ${_CERTROOT}/cert.pem -noout -fingerprint | sed 's/SHA1[ ]Fingerprint=//' | sed 's/://g'`

rm -f /root/passwd ${_PFX}
echo ${_PASSWORD} > /root/passwd
cat /root/passwd | openssl pkcs12 -export -out ${_PFX} \
        -inkey ${_CERTROOT}/privkey.pem -in ${_CERTROOT}/cert.pem -certfile ${_CERTROOT}/chain.pem \
        -password stdin \
    && az login --service-principal --username ${AZURE_CLI_SERVICE_PRINCIPAL_ID} --password ${_AZCERT} \
        --tenant ${AZURE_CLI_SERVICE_PRINCIPAL_TENANT_ID} \
    && az webapp config ssl upload -n ${WEBSITE_SITE_NAME} -g ${WEBSITES_RESOURCE_GROUP} \
        --certificate-file ${_PFX} --certificate-password ${_PASSWORD} \
    && az webapp config ssl bind -n ${WEBSITE_SITE_NAME} -g ${WEBSITES_RESOURCE_GROUP} --ssl-type SNI \
        --certificate-thumbprint `openssl x509 -in ${_CERTROOT}/cert.pem -noout -fingerprint | sed 's/SHA1[ ]Fingerprint=//' | sed 's/://g'`

if [ -f ${_CERTROOT}/fingerprint.bind ]; then
    if [ `cat ${_CERTROOT}/fingerprint.bind` != ${_CERT_FINGERPRINT} ]; then
        az webapp config ssl delete -g ${WEBSITES_RESOURCE_GROUP} \
            --certificate-thumbprint `${_CERTROOT}/fingerprint.bind`
    fi
fi

echo ${_CERT_FINGERPRINT} > ${_CERTROOT}/fingerprint.bind
