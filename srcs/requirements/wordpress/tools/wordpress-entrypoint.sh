#!/bin/sh
set -eu

check_env_vars() {
    local missing_vars=""
    
    [ -z "${WORDPRESS_DB_HOST:-}" ] && missing_vars="${missing_vars} WORDPRESS_DB_HOST"
    [ -z "${WORDPRESS_DB_NAME:-}" ] && missing_vars="${missing_vars} WORDPRESS_DB_NAME"
    [ -z "${WORDPRESS_DB_USER:-}" ] && missing_vars="${missing_vars} WORDPRESS_DB_USER"
    [ -z "${WORDPRESS_DB_PASSWORD_FILE:-}" ] && missing_vars="${missing_vars} WORDPRESS_DB_PASSWORD_FILE"
    [ -z "${WORDPRESS_URL:-}" ] && missing_vars="${missing_vars} WORDPRESS_URL"
    [ -z "${WORDPRESS_TITLE:-}" ] && missing_vars="${missing_vars} WORDPRESS_TITLE"
    [ -z "${WORDPRESS_ADMIN_USER:-}" ] && missing_vars="${missing_vars} WORDPRESS_ADMIN_USER"
    [ -z "${WORDPRESS_ADMIN_PASSWORD:-}" ] && missing_vars="${missing_vars} WORDPRESS_ADMIN_PASSWORD"
    [ -z "${WORDPRESS_ADMIN_EMAIL:-}" ] && missing_vars="${missing_vars} WORDPRESS_ADMIN_EMAIL"
    [ -z "${WORDPRESS_USER:-}" ] && missing_vars="${missing_vars} WORDPRESS_USER"
    [ -z "${WORDPRESS_USER_PASSWORD:-}" ] && missing_vars="${missing_vars} WORDPRESS_USER_PASSWORD"
    [ -z "${WORDPRESS_USER_EMAIL:-}" ] && missing_vars="${missing_vars} WORDPRESS_USER_EMAIL"
    
    if [ -n "$missing_vars" ]; then
        echo "ERROR: Missing required environment variables:$missing_vars"
        echo "Please set all required environment variables in your .env file"
        exit 1
    fi
}

wait_for_db() {
    echo "Waiting for database at ${WORDPRESS_DB_HOST}:3306..."
    for i in $(seq 1 30); do
        if nc -z "$WORDPRESS_DB_HOST" 3306; then
            echo "Database is ready!"
            return 0
        fi
        sleep 1
    done
    echo "ERROR: Database failed to become ready"
    exit 1
}

wait_for_redis() {
    echo "Waiting for Redis at redis:6379..."
    for i in $(seq 1 30); do
        if nc -z redis 6379; then
            echo "Redis is ready!"
            return 0
        fi
        sleep 1
    done
    echo "WARNING: Redis failed to become ready, proceeding without Redis cache"
    return 1
}

configure_wordpress() {
    echo "Configuring WordPress..."
    
    if [ ! -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
        echo "ERROR: Database password file not found: $WORDPRESS_DB_PASSWORD_FILE"
        exit 1
    fi
    WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
    
    wait_for_db
    
    if [ ! -f /var/www/html/wp-config.php ]; then
        echo "Creating wp-config.php..."
        cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
        
        sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
        sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/html/wp-config.php
        sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/html/wp-config.php
        sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/html/wp-config.php
        
        for key in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
            salt=$(openssl rand -base64 32 | tr -d '\n')
            sed -i "0,/put your unique phrase here/s/put your unique phrase here/$salt/" /var/www/html/wp-config.php
        done
    fi
    
    if [ ! -f /usr/local/bin/wp ]; then
        echo "WP-CLI Not found."
        exit 1
    fi
    
    if ! php82 /usr/local/bin/wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
        echo "Installing WordPress..."
        php82 /usr/local/bin/wp core install \
            --allow-root \
            --path=/var/www/html \
            --url="$WORDPRESS_URL" \
            --title="$WORDPRESS_TITLE" \
            --admin_user="$WORDPRESS_ADMIN_USER" \
            --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL" \
            --skip-email
        
        php82 /usr/local/bin/wp user create \
            "$WORDPRESS_USER" \
            "$WORDPRESS_USER_EMAIL" \
            --role=editor \
            --user_pass="$WORDPRESS_USER_PASSWORD" \
            --allow-root \
            --path=/var/www/html
        
        echo "Installing and activating Twentytwentyone theme..."
        php82 /usr/local/bin/wp theme install twentytwentyone \
            --activate \
            --allow-root \
            --path=/var/www/html
        
        echo "Configuring theme customizations..."
        php82 /usr/local/bin/wp option update \
            stylesheet twentytwentyone \
            --allow-root \
            --path=/var/www/html
        
        php82 /usr/local/bin/wp option update \
            template twentytwentyone \
            --allow-root \
            --path=/var/www/html
        
        echo "WordPress installation completed"
        
        if wait_for_redis; then
            echo "Installing Redis Object Cache plugin..."
            php82 /usr/local/bin/wp plugin install redis-cache \
                --activate \
                --allow-root \
                --path=/var/www/html
            
            echo "Configuring Redis cache..."
            php82 /usr/local/bin/wp config set WP_REDIS_HOST redis \
                --allow-root \
                --path=/var/www/html
            
            php82 /usr/local/bin/wp config set WP_REDIS_PORT 6379 \
                --allow-root \
                --path=/var/www/html
            
            php82 /usr/local/bin/wp config set WP_REDIS_DATABASE 0 \
                --allow-root \
                --path=/var/www/html
            
            php82 /usr/local/bin/wp config set WP_REDIS_TIMEOUT 1 \
                --allow-root \
                --path=/var/www/html
            
            php82 /usr/local/bin/wp config set WP_REDIS_READ_TIMEOUT 1 \
                --allow-root \
                --path=/var/www/html
            
            echo "Enabling Redis object cache..."
            php82 /usr/local/bin/wp redis enable \
                --allow-root \
                --path=/var/www/html || echo "Redis cache enable failed, but continuing..."
            
            echo "Redis cache configuration completed"
        fi
    fi
    
    chown -R www-data:www-data /var/www/html
    find /var/www/html -type f -exec chmod 644 {} \;
    find /var/www/html -type d -exec chmod 755 {} \;
    chmod 600 /var/www/html/wp-config.php
}

check_env_vars
configure_wordpress

echo "Starting PHP-FPM..."
exec "$@"
