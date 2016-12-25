FROM php:5.6-apache

RUN apt-get update && apt-get install -y \
	bzip2 \
	libcurl4-openssl-dev \
	libfreetype6-dev \
	libicu-dev \
	libjpeg-dev \
	libldap2-dev \
	libmcrypt-dev \
	libmemcached-dev \
	libpng12-dev \
	libpq-dev \
	libxml2-dev \
	nano \
	net-tools \
	openssh-server \
	expect \
	apache2-utils
RUN apt-get update -y;\
cd /usr/src/; \
wget http://dev.mysql.com/get/mysql-apt-config_0.8.0-1_all.deb;\
apt-get install -y lsb-release;\
expect -c "\
   set timeout 60;\
   spawn dpkg -i mysql-apt-config_0.8.0-1_all.deb;\
   expect \"configure?\";\
   sleep 1;\
   send \"1\n\";\
   expect \"receive?\";\
   sleep 1;\
   send \"1\n\";\
   expect \"configure?\";\
   sleep 1;\
   send \"2\n\";\
   expect \"utilities\";\
   sleep 1;\
   send \"1\n\";\
   expect \"configure?\";\
   sleep 1;\
   send \"4\n\";\
   expect \"OK\";\
   sleep 1;\
   set timeout 600;\
   spawn apt-get update -y;\
   expect \"Reading package lists... Done\";\
   sleep 1;\
   spawn apt-get install -y mysql-server;\
   set timeout 600;\
   expect \"Enter root password:\";\
   sleep 1;\
   send \"ehomevn\n\";\
   expect \"enter root password:\";\
   sleep 1;\
   send \"ehomevn\n\";\
   interact;
";
# https://doc.owncloud.org/server/8.1/admin_manual/installation/source_installation.html#prerequisites
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install exif gd intl ldap mbstring mcrypt mysql opcache pdo_mysql pdo_pgsql pgsql zip;	

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod access_compat alias auth_basic authn_core authn_file\
    authz_core authz_host authz_user autoindex  dav dav_fs\
    deflate dir  env filter headers macro mime mpm_prefork \
    negotiation php5 proxy proxy_http proxy_wstunnel\
    rewrite setenvif socache_shmcb ssl status  

# PECL extensions
RUN set -ex \
	&& pecl install APCu-4.0.10 \
	&& pecl install memcached-2.2.0 \
	&& pecl install redis-2.2.8 \
	&& docker-php-ext-enable apcu memcached redis
RUN which redis-server || apt-get install -y redis-server; \
	sed -ire "s~^# maxmemory.+~maxmemory2gb~g" /etc/redis/redis.conf
ENV OWNCLOUD_VERSION 9.1.3
VOLUME /var/www/html
VOLUME /var/www/html/owncloud
RUN rm /etc/apache2/sites-available/*

RUN curl -fsSL -o owncloud.tar.bz2 \
		"https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2" \
	&& curl -fsSL -o owncloud.tar.bz2.asc \
		"https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
# gpg key from https://owncloud.org/owncloud.asc
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys E3036906AD9F30807351FAC32D5D5E97F6978A26 \
	&& gpg --batch --verify owncloud.tar.bz2.asc owncloud.tar.bz2 \
	&& rm -r "$GNUPGHOME" owncloud.tar.bz2.asc \
	&& tar -xjf owncloud.tar.bz2 -C /usr/src/ \
	&& rm owncloud.tar.bz2

COPY docker-entrypoint.sh /entrypoint.sh
RUN rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
