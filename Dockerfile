# Базовый образ: Debian 11 (bullseye)
FROM debian:11-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=5.6.40
ARG OPENSSL_VER=1.0.2u

ADD oracle/instantclient_12_1.tar.gz /usr/local
COPY docker-php/* /usr/local/bin/

RUN apt-get update
RUN apt-get -y install lsb-release ca-certificates curl software-properties-common apt-transport-https wget gnupg2 libldap2-dev libmemcached-dev memcached libzip-dev mc telnet libicu-dev libaio-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev imagemagick jq nginx
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

RUN wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -

RUN mkdir /run/php
RUN apt-get update

RUN apt-get install php5.6-cli php5.6-fpm php5.6-zip php5.6-redis php5.6-xdebug php5.6-xsl php5.6-xml php5.6-xhprof php5.6-stomp php5.6-mbstring php5.6-memcache php5.6-memcached php5.6-ldap php5.6-json php5.6-soap php5.6-gd php5.6-exif php5.6-opcache php5.6-intl

#Oracle OCI Client:

RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient \
  && ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so \
  && ln -s /usr/local/instantclient/lib* /usr/lib \
  && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \





CMD ["tail", "-f", "/dev/null"]
