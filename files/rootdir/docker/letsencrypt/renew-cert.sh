#!/bin/sh
# vim:sw=4:ts=4:et

set -e

. /etc/dockerhost-envs

certbot renew -n --agree-tos --cert-name ${LETSENCRYPT_HOSTNAME} \
    --deploy-hook /etc/letsencrypt/upload-cert.sh
