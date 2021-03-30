#!/bin/sh
# vim:sw=4:ts=4:et

set -e
ME=$(basename $0)

mkdir -p /home/configs/letsencrypt
if [ -L /etc/letsencrypt ] && [ -e /etc/letsencrypt ]; then
    echo ""
else
    rm -f /etc/letsencrypt
    ln -s /home/configs/letsencrypt /etc/letsencrypt
fi

mkdir -p /var/www
mkdir -p /home/var/certbot
if [ -L /var/www/certbot ] && [ -e /var/www/certbot ]; then
    echo ""
else
    rm -f /var/www/certbot
    ln -s /home/var/certbot /var/www/certbot
fi

# copy shell scripts for certbot
cp /docker/letsencrypt/* /etc/letsencrypt

# Setup a initial cert if there is no issued cert.
(sleep 120; /etc/letsencrypt/issue-new-cert.sh) &

# Setup Corntab
cp /docker/letsencrypt/crontab.root /var/spool/cron/crontabs/root
chmod 600 /var/spool/cron/crontabs/root
