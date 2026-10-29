FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --no-scripts
COPY . .
RUN composer dump-autoload --no-dev --optimize --no-scripts

FROM php:8.3-apache
RUN apt-get update && apt-get install -y --no-install-recommends libicu-dev libzip-dev libonig-dev unzip \
    && docker-php-ext-install pdo_mysql intl zip mbstring opcache \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*
COPY docker/apache-vhost.conf /etc/apache2/sites-available/000-default.conf
WORKDIR /var/www/html
COPY --from=vendor /app /var/www/html
RUN mkdir -p public/uploads/payment_screenshots \
    && chown -R www-data:www-data storage bootstrap/cache public/uploads
COPY docker/entrypoint.sh /usr/local/bin/tuition-entrypoint
RUN chmod +x /usr/local/bin/tuition-entrypoint
EXPOSE 80
ENTRYPOINT ["tuition-entrypoint"]
