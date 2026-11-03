FROM debian:buster

RUN sed -i 's/deb.debian.org\/debian/archive.debian.org\/debian/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org\/debian-security/archive.debian.org\/debian-security/g' /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y \
        php7.3-fpm \
        php7.3-mysql \
        php7.3-curl \
        php7.3-gd \
        php7.3-intl \
        php7.3-mbstring \
        php7.3-xml \
        php7.3-zip \
        wget \
        mariadb-client \
        && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

WORKDIR /var/www/html

RUN wget https://wordpress.org/wordpress-6.4.7.tar.gz && \
    tar -xzf wordpress-6.4.7.tar.gz --strip-components=1 && \
    rm wordpress-6.4.7.tar.gz

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]