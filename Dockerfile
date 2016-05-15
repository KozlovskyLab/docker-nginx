FROM debian:testing
MAINTAINER Vladimir Kozlovski <inbox@vladkozlovski.com>
ENV DEBIAN_FRONTEND noninteractive

ENV BUILD_DEPENDENCIES wget libpcre3-dev libssl-dev gcc make

RUN apt-get update && \
    apt-get install -y --no-install-recommends libssl1.0.2 $BUILD_DEPENDENCIES && \
    rm -rf /var/lib/apt/lists/*

ENV NGINX_VERSION 1.9.9

# apk --update add openssl-dev pcre-dev zlib-dev wget build-base && \

RUN \
    apt-get update -y && \
    apt-get install -y ${BUILD_DEPENDENCIES} --no-install-recommends && \

    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/nginx-${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install && \

    # cleanup
    rm -rf /tmp/src && \
    apt-get purge -y --auto-remove ${BUILD_DEPENDENCIES} && \
    rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

# Added 25, 587 ports to expose for mail proxy
EXPOSE 80 443 25 587

CMD ["nginx", "-g", "daemon off;"]
