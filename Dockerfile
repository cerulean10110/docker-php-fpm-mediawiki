# using alpine
FROM alpine:3.17

ARG PHP_V=81

# working directory
WORKDIR /srv

# update packages
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk update; apk upgrade

# install php-fpm and extensions for mediawiki
RUN apk add php${PHP_V}-fpm php${PHP_V}-apcu php${PHP_V}-opcache
RUN apk add php${PHP_V}-mysqli php${PHP_V}-pdo_mysql php${PHP_V}-pecl-memcached
RUN apk add php${PHP_V}-calendar php${PHP_V}-phar
RUN apk add php${PHP_V}-xml php${PHP_V}-curl icu-libs php${PHP_V}-intl \
    php${PHP_V}-ctype php${PHP_V}-iconv php${PHP_V}-fileinfo php${PHP_V}-mbstring \
    php${PHP_V}-dom php${PHP_V}-xmlreader php${PHP_V}-xmlwriter php${PHP_V}-simplexml php${PHP_V}-tokenizer

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
RUN ln -s /var/log/php${PHP_V} /var/log/php
RUN ln -s /usr/sbin/php-fpm${PHP_V} /usr/bin/php-fpm
RUN ln -s /usr/bin/php${PHP_V} /usr/bin/php

# php config file
COPY php-conf.sh .
RUN sh php-conf.sh; rm php-conf.sh

STOPSIGNAL SIGQUIT

EXPOSE 9000

CMD [ "php-fpm", "-F"]