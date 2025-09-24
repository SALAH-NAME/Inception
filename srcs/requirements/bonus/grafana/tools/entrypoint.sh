#!/bin/sh
set -eu

echo "🚀 Starting Grafana for Inception monitoring..."

missing_vars=""

[ -z "${GF_SECURITY_ADMIN_USER:-}" ] && missing_vars="${missing_vars} GF_SECURITY_ADMIN_USER"
[ -z "${GF_SECURITY_ADMIN_PASSWORD:-}" ] && missing_vars="${missing_vars} GF_SECURITY_ADMIN_PASSWORD"
[ -z "${GF_SECURITY_SECRET_KEY:-}" ] && missing_vars="${missing_vars} GF_SECURITY_SECRET_KEY"

if [ -n "$missing_vars" ]; then
    echo "ERROR: Missing required environment variables:$missing_vars"
    echo "Please set all required environment variables in your .env file"
    exit 1
fi

if [ -f "/run/secrets/db_password" ]; then
    export GF_MARIADB_PASSWORD="$(cat /run/secrets/db_password)"
    echo "📊 Database password loaded from secrets"
else
    echo "⚠️  Warning: No database password found in secrets"
fi

echo "📊 Grafana starting with admin user: $GF_SECURITY_ADMIN_USER"

exec "$@"
