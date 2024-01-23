#!/bin/sh

PHP_INI=/etc/php/php.ini
PHP_FPM_CONF=/etc/php/php-fpm.conf
PHP_WWW_CONF=/etc/php/php-fpm.d/www.conf

sed -i "s/memory_limit = 128M/memory_limit = 256M/g" $PHP_INI
sed -i "s/;error_log = syslog/error_log = \/var\/log\/php\/error.log/g" $PHP_INI
sed -i "s/post_max_size = /post_max_size = 20M;/g" $PHP_INI
sed -i "s/upload_max_filesize = /upload_max_filesize = 20M;/g" $PHP_INI
sed -i "s/;sendmail_path =/sendmail_path = sendmail -t -i -S 172.17.0.1/g" $PHP_INI
echo "opcache.jit=tracing" >> $PHP_INI
echo "opcache.jit_buffer_size=128M" >> $PHP_INI

sed -i "s/listen = /listen = 0.0.0.0:9000;/g" $PHP_WWW_CONF
sed -i "s/user = /user = www-data;/g" $PHP_WWW_CONF
sed -i "s/group = /group = www-data;/g" $PHP_WWW_CONF
sed -i "s/pm.max_children = /pm.max_children = 30;/g" $PHP_WWW_CONF
sed -i "s/pm.start_servers = /pm.start_servers = 10;/g" $PHP_WWW_CONF
sed -i "s/pm.min_spare_servers = /pm.min_spare_servers = 5;/g" $PHP_WWW_CONF
sed -i "s/pm.max_spare_servers = /pm.max_spare_servers = 15;/g" $PHP_WWW_CONF
sed -i "s/pm.process_idle_timeout = /pm.process_idle_timeout = 600s;/g" $PHP_WWW_CONF
sed -i "s/;pm.status_path = \/status/pm.status_path = \/status\/fpm/g" $PHP_WWW_CONF
sed -i "s/;access.log = /access.log = \/var\/log\/php\/www.access.log;/g" $PHP_WWW_CONF
sed -i 's/;access.format = /access.format = "%R - %u %t \\"%m %r%Q%q\\" %s %f %{mili}d %{kilo}M %C%%";/g' $PHP_WWW_CONF
