FROM alpine:3.21

ARG NGINX_VERSION=1.26.3-r0


RUN apk update && apk add --no-cache \
	nginx=${NGINX_VERSION} \
	openssl \
	&& rm -rf /var/cache/apk/*

RUN adduser -D -g 'www' www

RUN mkdir -p /www /etc/ssl/certs /etc/ssl/private /var/log/nginx && \
	chown -R www:www /var/lib/nginx && \
	chown -R www:www /www

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/generate-certs.sh /usr/local/bin/generate-certs.sh
RUN chmod +x /usr/local/bin/generate-certs.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/generate-certs.sh"]
CMD ["nginx", "-g", "daemon off;"]
