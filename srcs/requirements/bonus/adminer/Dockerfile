FROM alpine:3.21

RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-session \
    php82-pdo \
    php82-pdo_mysql \
    php82-mbstring \
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/bin/php82 /usr/bin/php

RUN addgroup -g 82 -S www-data || true && \
    adduser -u 82 -D -S -G www-data www-data || true

RUN mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /run/php

RUN wget https://github.com/vrana/adminer/releases/download/v5.4.0/adminer-5.4.0.php \
		-O /var/www/html/adminer.php

COPY ./tools/adminer.css /var/www/html/adminer.css
COPY ./tools/static.php /var/www/html/static.php
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 9000

CMD ["php-fpm82", "--nodaemonize"] 
