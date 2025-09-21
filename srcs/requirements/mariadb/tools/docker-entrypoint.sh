#!/bin/sh
set -e

DATADIR="/var/lib/mysql"
INIT_FLAG="$DATADIR/.mariadb_initialized"
INIT_FILE="/tmp/init.sql"

if [ -z "$(ls -A "$DATADIR" 2>/dev/null)" ]; then
    echo "Initializing database..."
    
    ROOT_PASSWORD=$(cat "/run/secrets/db_root_password")
    USER_PASSWORD=$(cat "/run/secrets/db_password")
    
    sed -e "s/REPLACE_ROOT_PASSWORD/$ROOT_PASSWORD/g" \
        -e "s/REPLACE_DATABASE_NAME/$MYSQL_DATABASE/g" \
        -e "s/REPLACE_USERNAME/$MYSQL_USER/g" \
        -e "s/REPLACE_USER_PASSWORD/$USER_PASSWORD/g" \
        /docker-entrypoint-initdb.d/init-database.sql > "$INIT_FILE"

    mariadb-install-db --user=mysql --datadir="$DATADIR"
    
    echo "Database initialization complete"
fi

if [ -f "$INIT_FILE" ] && [ ! -f "$INIT_FLAG" ]; then
    echo "Starting MariaDB with init file..."
    touch "$INIT_FLAG"
    exec "$@" --init-file="$INIT_FILE"
else
    echo "Starting MariaDB with (already initialized)..."
    exec "$@"
fi
