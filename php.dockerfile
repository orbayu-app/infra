ARG PHP_VERSION=8.4
ARG ALPINE_VERSION=3.22
ARG COMPOSER_VERSION=2.9.5
ARG PROJECT_PATH

# composer stage - need separate to set version from arg
FROM composer:${COMPOSER_VERSION} AS composer

FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS base

WORKDIR /application

RUN deluser www-data 2>/dev/null || true && \
    delgroup www-data 2>/dev/null || true && \
    addgroup -g 1000 www-data && \
    adduser -D -H -u 1000 -G www-data -s /sbin/nologin www-data

COPY ./configs/php-fpm/zz-orbayu.conf /usr/local/etc/php-fpm.d/

# create empty .env for laravel to avoid errors
RUN touch .env

EXPOSE 9000

CMD ["php-fpm", "-F"]

# builder stage - install production dependencies
FROM base AS builder
ARG PROJECT_PATH

COPY --from=composer /usr/bin/composer /usr/bin/composer

# copy only composer files for caching
COPY --chown=www-data:www-data ${PROJECT_PATH}/composer.json ${PROJECT_PATH}/composer.lock ./

# install production dependencies (cached if composer files unchanged)
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# copy application code (needed for autoload classmap)
COPY --chown=www-data:www-data ${PROJECT_PATH} ./

# generate optimized autoloader for production
RUN composer dump-autoload --no-dev --optimize --no-scripts --classmap-authoritative

# test stage - with dev dependencies
FROM base AS test
ARG PROJECT_PATH

COPY --from=composer /usr/bin/composer /usr/bin/composer

# copy only composer files for caching
COPY --chown=www-data:www-data ${PROJECT_PATH}/composer.json ${PROJECT_PATH}/composer.lock ./

# install all dependencies including dev without scripts (cached if composer files unchanged)
RUN composer install --no-scripts --no-autoloader --no-interaction --prefer-dist

# copy application code (needed for autoload classmap)
COPY --chown=www-data:www-data ${PROJECT_PATH} ./

# generate optimized autoloader for production
RUN composer dump-autoload --optimize --no-scripts

# no code copy - code comes from volume
# production stage - minimal, without composer
FROM base AS production
ARG PROJECT_PATH

# copy application code
COPY --chown=www-data:www-data ${PROJECT_PATH} ./

# copy vendor from builder (after code to avoid overwriting)
COPY --from=builder --chown=www-data:www-data /application/vendor ./vendor

# development stage - no code copied, expects volume mount (default)
FROM base AS development

COPY --from=composer /usr/bin/composer /usr/bin/composer

# no code copy - code comes from volume
