#!/bin/sh
set -e

if [ -z "$FTP_USER" ] || [ -z "$FTP_PASSWORD" ]; then
    echo "Error: FTP_USER and FTP_PASSWORD environment variables must be set"
    exit 1
fi

if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "Creating FTP user: $FTP_USER"
    adduser -D -h /var/www/html -s /bin/false "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
else
    echo "FTP user $FTP_USER already exists"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

echo "$FTP_USER" > /etc/vsftpd.userlist

# if [ -d "/var/www/html" ]; then
#     chown -R "$FTP_USER:$FTP_USER" /var/www/html
#     chmod -R 755 /var/www/html
# else
#     echo "Warning: /var/www/html not available yet"
# fi

mkdir -p /var/run/vsftpd/empty

echo "FTP server starting with restricted user access..."
echo "Allowed user: $FTP_USER"
echo "Home directory: /var/www/html"

exec "$@"
