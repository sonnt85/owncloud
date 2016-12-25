#!/bin/bash
set -e

if [ ! -e '/var/www/html/owncloud/version.php' ]; then
	tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -
	chown -R www-data /var/www/html/owncloud
fi
service redis-server start
service ssh start
exec "$@"
