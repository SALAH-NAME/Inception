FROM alpine:3.21

RUN apk update && apk add --no-cache vsftpd \
		lftp

RUN mkdir -p /srv/ftp /var/log/vsftpd /etc/vsftpd

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21 30000-30009

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf"]
