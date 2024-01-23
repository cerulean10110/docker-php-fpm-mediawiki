# using alpine
FROM alpine:3.16

ARG PHP_V=8

# working directory
WORKDIR /srv

# update packages
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk update; apk upgrade

# install php-fpm and extensions for mediawiki
RUN apk add --no-cache php${PHP_V}-fpm php${PHP_V}-xml php${PHP_V}-curl php${PHP_V}-intl
RUN apk add --no-cache php${PHP_V}-calendar php${PHP_V}-apcu php${PHP_V}-opcache
RUN apk add --no-cache php${PHP_V}-mysqli php${PHP_V}-pdo_mysql php${PHP_V}-redis
RUN apk add --no-cache php${PHP_V}-phar php${PHP_V}-mbstring

#php${PHP_V}-imagick -- dont work

# install composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# install basic utils
RUN apk add --no-cache diffutils vim bash lua5.1 curl python3

# rsvg-convert
RUN apk add --no-cache rsvg-convert

# directory permission
RUN apk add --no-cache -U shadow
RUN groupmod --gid 1001 www-data
RUN adduser -u 1001 -D -S -G www-data www-data

RUN rm -rf /var/cache/apk /etc/apk/cache

# php symbolic link
RUN ln -s /etc/php${PHP_V} /etc/php

# php config file
ARG PHP_INI=/etc/php/php.ini
ARG PHP_FPM_CONF=/etc/php/php-fpm.conf
ARG PHP_WWW_CONF=/etc/php/php-fpm.d/www.conf

RUN sed -i "s/memory_limit = 128M/memory_limit = 256M/g" ${PHP_INI}
RUN sed -i "s/;error_log = syslog/error_log = \/var\/log\/php\/error.log/g" ${PHP_INI}
RUN sed -i "s/post_max_size = /post_max_size = 20M;/g" ${PHP_INI}
RUN sed -i "s/upload_max_filesize = /upload_max_filesize = 20M;/g" ${PHP_INI}
RUN sed -i "s/;sendmail_path =/sendmail_path = sendmail -t -i -S 172.17.0.1/g" ${PHP_INI}
RUN echo "opcache.jit=tracing" >> ${PHP_INI}
RUN echo "opcache.jit_buffer_size=128M" >> ${PHP_INI}

RUN sed -i "s/pm.max_children = /pm.max_children = 30;/g" ${PHP_WWW_CONF}
RUN sed -i "s/pm.start_servers = /;pm.start_servers = ;/g" ${PHP_WWW_CONF}
RUN sed -i "s/pm.min_spare_servers = /pm.min_spare_servers = 5;/g" ${PHP_WWW_CONF}
RUN sed -i "s/pm.max_spare_servers = /pm.max_spare_servers = 15;/g" ${PHP_WWW_CONF}
RUN sed -i "s/pm.process_idle_timeout = /pm.process_idle_timeout = 600s;/g" ${PHP_WWW_CONF}
RUN sed -i "s/;pm.status_path = \/status/pm.status_path = \/status\/fpm/g" ${PHP_WWW_CONF}
RUN sed -i "s/;access.log = /access.log = \/var\/log\/php\/www.access.log;/g" ${PHP_WWW_CONF}
RUN sed -i 's/;access.format = /access.format = "%R - %u %t \\"%m %r%Q%q\\" %s %f %{mili}d %{kilo}M %C%%";/g' ${PHP_WWW_CONF}
