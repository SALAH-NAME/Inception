#!/bin/sh
set -eu

check_env_vars() {
    local missing_vars=""
    
    [ -z "${DOMAIN_NAME:-}" ] && missing_vars="${missing_vars} DOMAIN_NAME"
    [ -z "${SSL_COUNTRY:-}" ] && missing_vars="${missing_vars} SSL_COUNTRY"
    [ -z "${SSL_STATE:-}" ] && missing_vars="${missing_vars} SSL_STATE"
    [ -z "${SSL_CITY:-}" ] && missing_vars="${missing_vars} SSL_CITY"
    [ -z "${SSL_ORGANIZATION:-}" ] && missing_vars="${missing_vars} SSL_ORGANIZATION"
    [ -z "${SSL_OU:-}" ] && missing_vars="${missing_vars} SSL_OU"
    
    if [ -n "$missing_vars" ]; then
        echo "ERROR: Missing required environment variables:$missing_vars"
        echo "Please set all required environment variables in your .env file"
        exit 1
    fi
}

template_nginx_config() {
    echo "Templating nginx configuration for domain: ${DOMAIN_NAME}"

    sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

    echo "NGINX configuration templated successfully"
}

generate_ssl_certs() {
    cert_dir="/etc/ssl"
    crt="${cert_dir}/certs/selfsigned.crt"
    key="${cert_dir}/private/selfsigned.key"

    mkdir -p "${cert_dir}/certs" "${cert_dir}/private"
    if [ ! -f "$crt" ] || [ ! -f "$key" ]; then
        echo "Generating SSL certificates for domain: ${DOMAIN_NAME}"
        umask 077
        openssl req -x509 -nodes -days 365 \
            -newkey rsa:2048 \
            -keyout "$key" \
            -out "$crt" \
            -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_CITY}/O=${SSL_ORGANIZATION}/OU=${SSL_OU}/CN=${DOMAIN_NAME}" \
            -addext "subjectAltName=DNS:${DOMAIN_NAME}"
        chmod 600 "$key"
        chmod 644 "$crt"
        chown www:www "$key" "$crt"
        
        echo "SSL certificates generated successfully"
    else
        echo "SSL certificates already exist"
    fi
}

check_env_vars
template_nginx_config
generate_ssl_certs

echo "Starting NGINX..."
exec "$@"
