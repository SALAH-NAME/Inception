FROM alpine:3.21

ARG MARIADB_VERSION=11.4.8-r0

ENV DB_DATA_DIR="/var/lib/mysql" \
	DB_RUN_DIR="/var/run/mysqld" \
	DB_LOG_DIR="/var/log/mysql"

RUN	apk update && \
	apk add --no-cache mariadb=$MARIADB_VERSION mariadb-client=$MARIADB_VERSION mariadb-server-utils=$MARIADB_VERSION && \
	rm -f /var/cache/apk/*

RUN mkdir -p ${DB_DATA_DIR} ${DB_RUN_DIR} ${DB_LOG_DIR} /docker-entrypoint-initdb.d && \
	chown -R mysql:mysql ${DB_DATA_DIR} ${DB_RUN_DIR} ${DB_LOG_DIR}

VOLUME ${DB_DATA_DIR}

COPY	./conf/mariadb.cnf /etc/my.cnf.d/zzz-mariadb.cnf
COPY	./tools/init-database.sql /docker-entrypoint-initdb.d/
COPY	./tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN	chmod +x /usr/local/bin/docker-entrypoint.sh && \
	chown mysql:mysql /usr/local/bin/docker-entrypoint.sh

USER	mysql

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE	3306

CMD ["mariadbd","--user=mysql","--console","--bind-address=0.0.0.0"]
