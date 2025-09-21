FROM alpine:3.21

ARG WORDPRESS_VERSION=6.4.3

RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-curl \
    php82-dom \
    php82-mbstring \
    php82-zip \
    php82-gd \
    php82-xml \
    php82-phar \
    php82-redis \
    php82-tokenizer \
    php82-ctype \
    wget \
    netcat-openbsd \
    openssl \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/bin/php82 /usr/bin/php

RUN addgroup -g 82 -S www-data || true && \
    adduser -u 82 -D -S -G www-data www-data || true

RUN mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /run/php

WORKDIR /tmp
RUN wget https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz && \
    tar -xzf wordpress-${WORDPRESS_VERSION}.tar.gz && \
    mv wordpress/* /var/www/html/ && \
    rm -rf wordpress-${WORDPRESS_VERSION}.tar.gz wordpress && \
    chown -R www-data:www-data /var/www/html

RUN wget -O /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v2.9.0/wp-cli-2.9.0.phar && \
    chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY tools/wordpress-entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["wordpress-entrypoint.sh"]
CMD ["php-fpm82", "--nodaemonize"] 