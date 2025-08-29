# Базовый образ: Debian 11 (bullseye)
FROM debian:11-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=5.6.40
ARG OPENSSL_VER=1.0.2u

ADD oracle/instantclient_12_1.tar.gz /usr/local

RUN apt-get update && \
    apt-get -y install lsb-release ca-certificates curl software-properties-common apt-transport-https wget gnupg2 libldap2-dev libmemcached-dev memcached libzip-dev mc telnet libicu-dev libaio-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev imagemagick jq nginx build-essential autoconf libaio1 unzip && \
    sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - && \
    mkdir /run/php && \
    apt-get update && \
    apt-get install -y php5.6-dev php-pear php5.6-cli php5.6-fpm php5.6-zip php5.6-redis php5.6-xdebug php5.6-xsl php5.6-xml php5.6-xhprof php5.6-stomp php5.6-mbstring php5.6-memcache php5.6-memcached php5.6-ldap php5.6-json php5.6-soap php5.6-gd php5.6-exif php5.6-opcache php5.6-intl && \
    apt-get clean -y && \
     ln -s /usr/local/instantclient_12_1 /usr/local/instantclient \
    && ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so \
    && ln -s /usr/local/instantclient/lib* /usr/lib \
    && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \
    && rm -rf /var/lib/apt/lists/*

# Иногда phpize/php-config именуются с суффиксом 5.6 — задаём их явно
ENV PHPIZE=/usr/bin/phpize5.6 PHP_CONFIG=/usr/bin/php-config5.6

ENV LD_LIBRARY_PATH=/usr/local/instantclient:libclntsh.so.12.1
ENV ORACLE_HOME="/usr/local/instantclient"
ENV C_INCLUDE_PATH="/usr/local/instantclient/sdk/include"


# 2) Oracle Instant Client 12.1
RUN echo "/usr/local/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf \
 && ldconfig

# 3) Сборка и установка OCI8 через PECL
RUN printf "instantclient,/usr/local/instantclient\n" | pecl install -f oci8-2.0.12

# 4) Включаем расширение для CLI и FPM
RUN echo "extension=oci8.so" > /etc/php/5.6/mods-available/oci8.ini \
 && phpenmod -v 5.6 oci8


COPY php/conf/timezone.ini /etc/php/5.6/fpm/conf.d/timezone.ini
COPY php/conf/vars-dev.ini /etc/php/5.6/fpm/conf.d/vars-dev.ini
COPY php/conf/vars-pro.ini /etc/php/5.6/fpm/conf.d/vars-production.ini.disabled
COPY php/conf/xdebug.ini /etc/php/5.6/fpm/conf.d/xdebug.ini

COPY php/conf/timezone.ini /etc/php/5.6/cli/conf.d/timezone.ini
COPY php/conf/vars-dev.ini /etc/php/5.6/cli/conf.d/vars-dev.ini
COPY php/conf/vars-pro.ini /etc/php/5.6/cli/conf.d/vars-production.ini.disabled
COPY php/conf/xdebug.ini /etc/php/5.6/cli/conf.d/xdebug.ini


# Копирование конфига Nginx
COPY nginx/nginx.conf /etc/nginx/sites-enabled/default

WORKDIR /var/www/html

EXPOSE 80

# Запуск memcached, PHP-FPM и Nginx
CMD service memcached start && php-fpm5.6 -D && nginx -g 'daemon off;'
