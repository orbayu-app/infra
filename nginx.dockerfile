ARG NGINX_VERSION=1.29
ARG ALPINE_VERSION=3.22

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
