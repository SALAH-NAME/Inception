#!/bin/sh
set -eu

echo "Loading Redis configuration from /etc/redis/redis.conf ..."

exec "$@"
