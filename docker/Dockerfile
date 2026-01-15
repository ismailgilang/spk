# =================================================================
# BASE STAGE - Common dependencies for all stages
# =================================================================
FROM docker.io/dunglas/frankenphp:php8.3-alpine AS base

LABEL org.opencontainers.image.title="Modul SPK Dockerfile"
LABEL org.opencontainers.image.description="Production-ready Dockerfile untuk Modul SPK"
LABEL org.opencontainers.image.source=https://gitlab.com/alfalahdev/spk
LABEL org.opencontainers.image.licenses=MIT

ARG TZ="Asia/Jakarta"

ENV TERM=xterm-color \
    OCTANE_SERVER=frankenphp \
    TZ=${TZ}

# Set timezone and install base system dependencies
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && apk update && apk add --no-cache \
    linux-headers \
    mysql-client \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    freetype-dev \
    icu-dev \
    imagemagick-dev \
    ca-certificates \
    bash \
    vim \
    procps \
    curl \
    su-exec \
    shadow \
    && rm -rf /var/cache/apk/*

# Install common PHP extensions
RUN install-php-extensions \
    opcache pcntl pdo pdo_mysql mysqli mbstring zip gd \
    bcmath redis intl exif fileinfo imagick

WORKDIR /app

# =================================================================
# COMPOSER PROD DEPS STAGE
# =================================================================
FROM base AS composer_prod_deps

COPY --from=docker.io/composer:2.8 /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock ./

RUN composer install --no-interaction --no-plugins --no-scripts --no-dev --prefer-dist --optimize-autoloader \
    && composer clear-cache

# =================================================================
# FRONTEND BUILD STAGE - Build static assets
# =================================================================
FROM docker.io/node:22-alpine AS frontend_build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY vite.config.js ./
COPY resources ./resources

RUN npm run build

# =================================================================
# PRODUCTION STAGE - Final, optimized production image
# =================================================================
FROM base AS production

ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr \
    LOG_LEVEL=error

COPY --from=composer_prod_deps /app/vendor /app/vendor
COPY --from=frontend_build /app/public/build /app/public/build

COPY . .

# Copy and set permissions for the new entrypoint script
COPY docker/entrypoints/prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN ln -sf /app/storage /app/public/storage

# Create a non-root user with a default UID/GID (1000).
# The entrypoint script will dynamically change this at runtime if needed.
RUN addgroup -g 1000 -S laravel \
    && adduser -u 1000 -S laravel -G laravel -s /bin/bash -h /home/laravel

# Pre-create Laravel directories dengan permission yang benar
RUN mkdir -p /app/storage/framework/sessions \
    /app/storage/framework/views \
    /app/storage/framework/cache \
    /app/storage/logs \
    /app/bootstrap/cache \
    && chown -R laravel:laravel /app \
    && chmod -R 775 /app/storage /app/bootstrap/cache

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# =================================================================
# DEVELOPMENT STAGE - For local development with Xdebug
# =================================================================
FROM base AS development

# Install dev dependencies
RUN apk add --no-cache git openssh nodejs-current npm \
    && install-php-extensions xdebug

# Copy composer binary and install all dependencies, including dev
COPY --from=docker.io/composer:2.8 /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock ./

RUN composer install --no-interaction --no-plugins --no-scripts --prefer-dist \
    && composer clear-cache \
    && git config --global --add safe.directory /app

# Salin konfigurasi PHP development
COPY docker/configs/php/dev.ini /usr/local/etc/php/conf.d/99-custom-dev.ini

# Setup user dengan UID/GID default 1000
# Entrypoint akan menangani penyesuaian dinamis
RUN addgroup -g 1000 -S appuser \
    && adduser -u 1000 -S appuser -G appuser -s /bin/bash -h /home/appuser

# Pre-create directories dengan permission yang benar
RUN mkdir -p /app/storage/framework/sessions \
    /app/storage/framework/views \
    /app/storage/framework/cache \
    /app/storage/logs \
    /app/bootstrap/cache \
    && chown -R appuser:appuser /app \
    && chmod -R 775 /app/storage /app/bootstrap/cache

# Copy and set permissions for the entrypoint script
COPY docker/entrypoints/dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Start as root to allow entrypoint to adjust UID/GID
USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
