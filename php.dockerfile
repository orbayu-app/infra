ARG PHP_VERSION=8.4
ARG ALPINE_VERSION=3.22

FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS base

WORKDIR /application

RUN deluser www-data 2>/dev/null || true && \
    delgroup www-data 2>/dev/null || true && \
    addgroup -g 1000 www-data && \
    adduser -D -H -u 1000 -G www-data -s /sbin/nologin www-data

COPY ./configs/php-fpm/zz-orbayu.conf /usr/local/etc/php-fpm.d/

COPY --from=composer:2.9.5 /usr/bin/composer /usr/bin/composer

CMD ["php-fpm", "-F"]
