#!/bin/bash

apt-get update || exit $?
apt-get -y install wget apt-utils gnupg

apt-get -y install lsb-release sysvinit-utils apache2 supervisor openssh-server \
    php sudo net-tools tzdata libapache2-mod-php php-mysql php-mbstring php-sqlite3 \
    php-curl php-gd php-pear php-imap php-soap libphp-jpgraph smarty3 curl vim \
    dialog sqlite3 mariadb-client
# mariadb-server

apt-get -y install make

GITHUB_PROYECT=dinomi-framework-rebrand-yubox
GITHUB_RELEASE=yubox-rebrand-1.1.1
PHPVER=`php -r 'print ((int)(PHP_VERSION_ID/10000)).".".((int)((PHP_VERSION_ID % 10000) / 100));'`

cd /tmp/
wget https://github.com/yubox-node-org/$GITHUB_PROYECT/archive/refs/tags/$GITHUB_RELEASE.tar.gz
tar -xzf $GITHUB_RELEASE.tar.gz
# Crear los directorios requeridos por el framework
pushd $GITHUB_PROYECT-$GITHUB_RELEASE
mkdir /tmp/dummy-root
for D in `sed "s,__PHPVER__,$PHPVER,g" framework/setup/build/debian/dinomi-framework.dirs`
do
    mkdir -p /tmp/dummy-root/$D
    if [ ! -d /$D ] ; then
        echo "Creando directorio requerido /$D ..."
        mkdir -p /$D
    fi
done
mkdir -p /tmp/dummy-root/var/www/html/configs/
mkdir -p /tmp/dummy-root/var/www/html/images/
# El archivo rules es realmente un Makefile
framework/setup/build/debian/rules override_dh_auto_install PHPVER=$PHPVER DEB_BUILD_ROOT= DEB_BUILD_THEMES_EXTRA=/tmp/dummy-root DEB_BUILD_BRANDING=/tmp/dummy-root DEB_SOURCE=dinomi-framework DEB_VERSION_UPSTREAM_REVISION=1.1.1-0
mv /tmp/dummy-root/var/www/html/configs/branding.conf.php /var/www/html/configs/
mv /tmp/dummy-root/var/www/html/favicon.ico /var/www/html/
mv /tmp/dummy-root/var/www/html/images/* /var/www/html/images/
rm -rf /tmp/dummy-root/
popd
chmod 777 /var/www/db/
chown www-data.www-data /var/www/db/
chown www-data.www-data /var/www/backup/
chown www-data.www-data /var/log/elastix/
chown www-data.www-data /var/log/elastix/*
chown www-data.www-data /var/www/html/var/cache
chown www-data.www-data /var/www/html/var/templates_c
rm -f $GITHUB_RELEASE.tar.gz
rm -rf $GITHUB_PROYECT-$GITHUB_RELEASE/

/usr/bin/elastix-dbprocess install /usr/share/elastix/module_installer/dinomi-framework-1.1.1-0/setup/db
/usr/bin/elastix-menumerge /usr/share/elastix/module_installer/dinomi-framework-1.1.1-0/menu.xml

systemctl enable apache2.service
a2ensite default-ssl
a2enmod ssl
a2enmod rewrite

# FIN DE OPERACIONES GENÉRICAS DE DEBIAN

# INICIO DE OPERACIONES PARA PREPARAR CONTAINER

mkdir -p /var/log/supervisor

# Reunir todos los archivos persistentes conocidos en un solo lugar, para
# unificar los lugares a guardar como volúmenes.
mkdir -p /var/lib/dinomi-data
mv /var/www/db /var/lib/dinomi-data/var.www.db
ln -s /var/lib/dinomi-data/var.www.db /var/www/db

# Cambio de nombre de index.html para que index.php sea visible
mv /var/www/html/index.html /var/www/html/index-debian.html

# Conversión de ACLs de dinomi-framework a MySQL
mv /tmp/dinomi-acls-mysql/etc/dinomi-dsn/elx4-mysql.conf /var/lib/dinomi-data/
ln -s /var/lib/dinomi-data/elx4-mysql.conf /etc/dinomi-dsn/elx4-mysql.conf
rmdir /tmp/dinomi-acls-mysql/etc/dinomi-dsn/
mv /tmp/dinomi-acls-mysql/var/www/html/configs.d/elastix4-mysql.conf.php /var/lib/dinomi-data/
ln -s /var/lib/dinomi-data/elastix4-mysql.conf.php /var/www/html/configs.d/elastix4-mysql.conf.php
rmdir /tmp/dinomi-acls-mysql/var/www/html/configs.d/ \
    /tmp/dinomi-acls-mysql/var/www/html/ \
    /tmp/dinomi-acls-mysql/var/www/ \
    /tmp/dinomi-acls-mysql/var/ \
    /tmp/dinomi-acls-mysql/etc/

mkdir /var/spool/elastix-mysqldbscripts/
