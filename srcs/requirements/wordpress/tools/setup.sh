#!/bin/bash

set -e

echo "Waiting for MariaDB..."

until mariadb \
    -h mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    -e "SELECT 1" >/dev/null 2>&1
do
    sleep 2
done

echo "MariaDB is ready."

if [ ! -f "/var/www/html/wp-config.php" ]; then

    echo "Creating wp-config.php..."

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/html/wp-config.php
    sed -i "s/localhost/mariadb/" /var/www/html/wp-config.php

fi

echo "Configuring PHP-FPM..."

sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.3/fpm/pool.d/www.conf

echo "Starting PHP-FPM..."

exec php-fpm7.3 -F