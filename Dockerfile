FROM richarvey/nginx-php-fpm:3.1.6

WORKDIR /var/www/html

# Copy composer files first for caching
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy application
COPY . .

# Environment configuration
ENV SKIP_COMPOSER 1
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr
ENV COMPOSER_ALLOW_SUPERUSER 1

# Database configuration
ENV DB_CONNECTION pgsql
ENV DB_HOST dpg-d0e9qq1r0fns73ctnvug-a
ENV DB_PORT 5432
ENV DB_DATABASE articlenew
ENV DB_USERNAME articlenew_user
ENV DB_PASSWORD ywfCDAvu7yD5EXj6rU4MaL9nIiAY8CRC

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Generate key and run migrations
RUN php artisan key:generate && \
    php artisan migrate --force

CMD ["/start.sh"]