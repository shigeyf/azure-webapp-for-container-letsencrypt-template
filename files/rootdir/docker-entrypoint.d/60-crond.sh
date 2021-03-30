#!/bin/sh
# vim:sw=4:ts=4:et

set -e
ME=$(basename $0)

echo "$ME: info: Starting cron daemon."
/usr/sbin/crond -l 2 && echo "$ME: info: Started cron daemon."
