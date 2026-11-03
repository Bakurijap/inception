#!/bin/bash

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
#runtime files and unix socket
chown -R mysql:mysql /var/lib/mysql
#dartabases and table files

if [ ! -f "/var/lib/mysql/.initialized" ]; then

    echo "Initializing MariaDB..."

    mysql_install_db \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --auth-root-authentication-method=normal

    mysqld \
        --user=mysql \
        --skip-networking \
        --skip-grant-tables \
        --socket=/run/mysqld/mysqld.sock &
# & means run this process in the backgrund
    pid="$!"

    echo "Waiting for MariaDB..."

    for i in {1..30}; do
        if mariadb \
            --socket=/run/mysqld/mysqld.sock \
            -uroot \
            -e "SELECT 1" >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    mariadb \
        --socket=/run/mysqld/mysqld.sock \
        -uroot << EOF

FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

EOF
    mysqladmin \
        --socket=/run/mysqld/mysqld.sock \
        -uroot \
        -p"${MYSQL_ROOT_PASSWORD}" \
        shutdown

    wait "$pid"

    touch /var/lib/mysql/.initialized

    echo "MariaDB initialized."

fi

exec mysqld --user=mysql --bind-address=0.0.0.0 --console