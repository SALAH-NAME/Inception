#!/bin/sh
set -e

if [ -z "$FTP_USER" ] || [ -z "$FTP_PASSWORD" ]; then
    echo "Error: FTP_USER and FTP_PASSWORD environment variables must be set"
    exit 1
fi

if ! getent group www-data >/dev/null; then
    addgroup -g 82 www-data
fi

if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "Creating FTP user: $FTP_USER in www-data group"
    adduser -D -h /var/www/html -s /bin/false -G www-data "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
else
    echo "FTP user $FTP_USER already exists"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    if ! groups "$FTP_USER" | grep -q www-data; then
        echo "Adding $FTP_USER to www-data group..."
        addgroup "$FTP_USER" www-data
    fi
fi

echo "Setting proper permissions for WordPress directory..."
chown -R :82 /var/www/html 2>/dev/null || true
chmod -R g+w /var/www/html 2>/dev/null || true

echo "$FTP_USER" > /etc/vsftpd.userlist

mkdir -p /var/run/vsftpd/empty

echo "FTP server starting with restricted user access..."
echo "Allowed user: $FTP_USER"
echo "Home directory: /var/www/html"

exec "$@"
