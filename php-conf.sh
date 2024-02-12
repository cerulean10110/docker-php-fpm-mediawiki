#!/bin/sh

PHP_INI=/etc/php/php.ini
PHP_FPM_CONF=/etc/php/php-fpm.conf
PHP_WWW_CONF=/etc/php/php-fpm.d/www.conf
PHP_LOG_CONF=/etc/php/php-fpm.d/logging.conf

sed -i "s/memory_limit = 128M/memory_limit = 256M/g" $PHP_INI
sed -i "s/post_max_size = /post_max_size = 20M;/g" $PHP_INI
sed -i "s/upload_max_filesize = /upload_max_filesize = 20M;/g" $PHP_INI
sed -i "s/;sendmail_path =/sendmail_path = sendmail -t -i -S 172.17.0.1/g" $PHP_INI
echo "opcache.jit=tracing" >> $PHP_INI
echo "opcache.jit_buffer_size=128M" >> $PHP_INI
echo "error_log = /proc/self/fd/2/g" >> $PHP_INI

sed -i "s/listen = /listen = 0.0.0.0:9000;/g" $PHP_WWW_CONF
sed -i "s/pm.max_children = /pm.max_children = 30;/g" $PHP_WWW_CONF
sed -i "s/pm.start_servers = /pm.start_servers = 10;/g" $PHP_WWW_CONF
sed -i "s/pm.min_spare_servers = /pm.min_spare_servers = 5;/g" $PHP_WWW_CONF
sed -i "s/pm.max_spare_servers = /pm.max_spare_servers = 15;/g" $PHP_WWW_CONF
sed -i "s/pm.process_idle_timeout = /pm.process_idle_timeout = 600s;/g" $PHP_WWW_CONF
sed -i "s/;pm.status_path = \/status/pm.status_path = \/status\/fpm/g" $PHP_WWW_CONF
sed -i "s/user = /user = 1000;/" $PHP_WWW_CONF
sed -i "s/group = /group = 1000;/" $PHP_WWW_CONF

log_conf="
[global]
error_log = /proc/self/fd/2

; https://github.com/docker-library/php/pull/725#issuecomment-443540114
log_limit = 8192

[www]
; php-fpm closes STDOUT on startup, so sending logs to /proc/self/fd/1 does not work.
; https://bugs.php.net/bug.php?id=73886
access.log = /proc/self/fd/2
access.format = "%R - %u %t \\"%m %r%Q%q\\" %s %f %{mili}d %{kilo}M %C%%"

clear_env = no

; Ensure worker stdout and stderr are sent to the main error log.
catch_workers_output = yes
decorate_workers_output = yes
"
echo "$log_conf" > $PHP_LOG_CONF