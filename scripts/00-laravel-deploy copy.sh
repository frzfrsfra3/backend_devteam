#!/usr/bin/env bash
echo "checking files...."
ls -la /var/www/html
echo "Running composer"
composer global require hirak/prestissimo
composer install --no-dev --working-dir=/var/www/html

echo "generating application key..."
php artisan key:generate --show

echo "Caching config..."
php artisan config:cache

echo "Caching routes..."
php artisan route:cache

echo "Running migrations..."
php artisan migrate --force
echo "Running queue"
php artisan queue:work --tries=3 --timeout=90 &