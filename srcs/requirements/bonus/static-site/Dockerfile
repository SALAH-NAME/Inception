FROM alpine:3.21

RUN apk update && apk add --no-cache apache2

RUN mkdir -p /var/www/localhost/htdocs

RUN sed -i 's/Listen 80/Listen 8000/' /etc/apache2/httpd.conf

COPY tools/index.html /var/www/localhost/htdocs/index.html
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 8000

CMD ["httpd", "-D", "FOREGROUND"] 
