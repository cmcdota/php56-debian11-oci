# Базовый образ: Debian 11 (bullseye)
FROM debian:11-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=5.6.40
ARG OPENSSL_VER=1.0.2u

COPY docker-php/* /usr/local/bin/

# 1) Репозитории + базовые утилиты
# Добавляем archive.debian.org и отключаем проверку "Valid-Until" для архивных реп.
RUN set -eux; \
  printf 'deb http://deb.debian.org/debian bullseye main contrib non-free\n' \
         'deb http://deb.debian.org/debian-security bullseye-security main contrib non-free\n' \
         'deb http://deb.debian.org/debian bullseye-updates main contrib non-free\n' \
         'deb https://archive.debian.org/debian/ archive main contrib non-free\n' \
    > /etc/apt/sources.list;

RUN apt-get update;
RUN apt-get install -y --no-install-recommends ca-certificates curl gnupg2 lsb-release apt-transport-https libldap2-dev libzip-dev mc telnet memcached libmemcached-dev nginx; \
        \
        # Основные репозитории Bullseye
        printf "deb http://deb.debian.org/debian bullseye main contrib non-free\n" > /etc/apt/sources.list; \
        printf "deb http://security.debian.org/debian-security bullseye-security main contrib non-free\n" >> /etc/apt/sources.list; \
        printf "deb http://deb.debian.org/debian bullseye-updates main contrib non-free\n" >> /etc/apt/sources.list; \
        \
        # Добавляем archive.debian.org (как просили). check-valid-until=no — чтобы не ругался на просроченные Release-файлы.
        printf "deb [check-valid-until=no] https://archive.debian.org/debian bullseye main contrib non-free\n" > /etc/apt/sources.list.d/archive.list; \
        \
        # Репозиторий Sury с множественными версиями PHP (в т.ч. 5.6) для Bullseye
        curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg; \
        echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
        \
        # Пинning: гарантируем, что php5.6 берём именно из Sury
        printf "Package: php5.6*\nPin: origin packages.sury.org\nPin-Priority: 1001\n" > /etc/apt/preferences.d/99-sury-php56.pref; \
        apt-get update;

RUN     apt-get install -y --no-install-recommends \
            php5.6-cli php5.6-common php5.6-curl php5.6-mbstring php5.6-xml php5.6-pgsql php5.6-fpm php5.6-gd php5.6-intl php5.6-zip  \
        apt-get clean; \
        rm -rf /var/lib/apt/lists/*

CMD ["bash"]