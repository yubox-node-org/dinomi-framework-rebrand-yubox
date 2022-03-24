#!/bin/bash

if [ ! -e /var/www/db/acl.db ] ; then
    echo "Migración de ACLs a MySQL ya realizada, no se hace nada."
    exit 0;
fi

if [ ! -e /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql ] ; then
    touch /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql
    cat /tmp/dinomi-acls-mysql/elx4-elastixframework-mysql.sql >> /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql
    /tmp/dinomi-acls-mysql/elx4-migrate-mysql -R -o - >> /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql
    rm -rf /tmp/dinomi-acls-mysql/

    echo 'GRANT USAGE ON *.* TO `'$DINOMI_MYSQL_WEB_USER'`@`%` IDENTIFIED BY "'$DINOMI_MYSQL_WEB_PASSWORD'";' >> /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql
    echo 'GRANT SELECT, INSERT, UPDATE, DELETE ON `elxframework`.* TO `'$DINOMI_MYSQL_WEB_USER'`@`%` ;' >> /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql
fi

cat > /var/lib/dinomi-data/elx4-mysql.conf <<DINOMI_DSN
[elx4]
DBUSER=$DINOMI_MYSQL_WEB_USER
DBPASSWORD=$DINOMI_MYSQL_WEB_PASSWORD
DBHOST=$DINOMI_MYSQL_HOSTNAME
charset=utf8

DINOMI_DSN

# Esperar a que el servidor MySQL esté activo...
while ! echo 'SHOW DATABASES;' | mysql -h $DINOMI_MYSQL_HOSTNAME -u root -p$DINOMI_MYSQL_ROOT_PASSWORD  ; do
    sleep 5
done

# Ejecutar la migración completa de ACLS...
if mysql -h $DINOMI_MYSQL_HOSTNAME -u root -p$DINOMI_MYSQL_ROOT_PASSWORD < /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql ; then
    echo "Migración correctamente realizada..."
    rm /var/spool/elastix-mysqldbscripts/elx4-elastixframework-mysql-full.sql
fi
