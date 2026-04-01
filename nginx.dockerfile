ARG NGINX_VERSION=1.29
ARG ALPINE_VERSION=3.22
ARG PROJECT_PATH

FROM nginx:${NGINX_VERSION}-alpine${ALPINE_VERSION} AS base

WORKDIR /application

RUN deluser www-data 2>/dev/null || true && \
    delgroup www-data 2>/dev/null || true && \
    addgroup -g 1000 www-data && \
    adduser -D -H -u 1000 -G www-data -s /sbin/nologin www-data

COPY configs/nginx/nginx.conf /etc/nginx/nginx.conf
COPY configs/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# production stage - with static assets baked in
FROM base AS production
ARG PROJECT_PATH

# copy static assets from Laravel public directory
COPY --chown=www-data:www-data ${PROJECT_PATH}/public /application/public

# development stage - expects volume mount (default)
FROM base AS development

# no static copy - static files will be mounted via volume
