FROM php:8.3-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpq-dev \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip\
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql \
    && docker-php-ext-install zip \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install pcntl


COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . /var/www
RUN composer install

RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 1000 -d /home/dev dev
RUN mkdir -p /home/dev/.composer && \
    chown -R dev:dev /home/dev

# Set working directory
WORKDIR /var/www

# Copy existing application directory
COPY --chown=dev:dev . .

# Switch to non-root user
USER dev

# Install dependencies
#RUN composer install --no-interaction --no-progress --prefer-dist

# Switch back to root for operations that need it
USER root

# Set recommended directory permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

