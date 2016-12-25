#!/bin/bash
set -e

if [ ! -e '/var/www/html/owncloud/version.php' ]; then
	tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -
	chown -R www-data /var/www/html/owncloud
fi
service redis-server start
service ssh start
service apache2 start
function sigterm_handler() {
        echo "SIGTERM signal received, try to gracefully shutdown all services..."
        service mysql stop
	service redis-server stop 
	service apache2 stop
	service memcached stop
	exit 0
}

trap "sigterm_handler; exit" TERM
while((1));do sleep 10; done;
exec "$@"
