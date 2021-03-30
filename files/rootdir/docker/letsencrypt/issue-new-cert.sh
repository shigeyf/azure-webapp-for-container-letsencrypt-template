#!/bin/sh
# vim:sw=4:ts=4:et

set -e

. /etc/dockerhost-envs

_WEBROOT=/var/www/certbot
_CERTROOT=/etc/letsencrypt/live/${LETSENCRYPT_HOSTNAME}
_CERT_FINGERPRINT=`openssl x509 -in ${_CERTROOT}/cert.pem -noout -fingerprint | sed 's/SHA1[ ]Fingerprint=//' | sed 's/://g'`

echo "Issuing a new SSL certificate for ${LETSENCRYPT_HOSTNAME}"
certbot certonly -n --agree-tos --keep --webroot -w ${_WEBROOT} -d ${LETSENCRYPT_HOSTNAME} \
    --email ${LETSENCRYPT_EMAIL} \
    && if [ ${_CERT_FINGERPRINT} != `openssl x509 -in ${_CERTROOT}/cert.pem -noout -fingerprint | sed 's/SHA1[ ]Fingerprint=//' | sed 's/://g'` ]; \
        then /etc/letsencrypt/upload-cert.sh; \
        fi
