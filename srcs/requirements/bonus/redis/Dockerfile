FROM alpine:3.21

RUN apk update && apk add --no-cache redis

COPY ./conf/redis.conf /etc/redis/redis.conf
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p /var/lib/redis /var/log/redis /var/run/redis
RUN chown redis:redis /var/lib/redis /var/log/redis /var/run/redis
RUN chmod 750 /var/lib/redis /var/log/redis && chmod 755 /var/run/redis
RUN chmod +x /usr/local/bin/entrypoint.sh

USER redis

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["redis-server", "/etc/redis/redis.conf"]
