FROM paliari/apache-php56-oci8:1.0.4-pro

COPY conf/vars-dev.ini /usr/local/etc/php/conf.d/vars.ini

RUN apt-get update && apt-get -y install curl git \
  && cp -f "/usr/local/etc/php/php.ini-development" /usr/local/etc/php/php.ini \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
