# Stage 1: Build environment
FROM composer:2.7 as builder

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --ignore-platform-reqs \
    --no-interaction

# Stage 2: Production image
FROM richarvey/nginx-php-fpm:3.1.6

# Install PostgreSQL and SSL dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    openssl \
    && docker-php-ext-install pdo pdo_pgsql

WORKDIR /var/www/html

# Copy built dependencies from builder
COPY --from=builder /app/vendor ./vendor

# Copy application files
COPY . .

# Configure environment
ENV WEBROOT=/var/www/html/public \
    APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr \
    DB_CONNECTION=pgsql \
    DB_HOST=dpg-d0e9qq1r0fns73ctnvug-a \
    DB_PORT=5432 \
    DB_DATABASE=articlenew \
    DB_USERNAME=articlenew_user \
    DB_PASSWORD=ywfCDAvu7yD5EXj6rU4MaL9nIiAY8CRC \
    DB_SSLMODE=require

# Configure PHP for PostgreSQL SSL
RUN echo "pdo_pgsql.default_ssl_mode=require" >> /usr/local/etc/php/conf.d/database.ini

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Generate keys and run migrations (only if DB is available)
RUN if [ -n "$DB_HOST" ]; then \
      php artisan key:generate && \
      php artisan config:cache && \
      php artisan route:cache && \
      php artisan migrate --seed; \
    fi

CMD ["/start.sh"]