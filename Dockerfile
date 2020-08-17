FROM nginx:1.17.8-alpine

RUN \
	rm -rf /etc/nginx/conf.d \
	&& apk add  --update certbot openssl \
	&& rm -rf /var/cache/apk/* \
	&& addgroup -g 2001 -S nginx-le \
	&& adduser -S -D -H -u 2001 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx-le nginx-le \
	&& mkdir -p /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt \
	&& chown -R nginx-le:nginx-le /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt \
	&& mkdir -p /etc/nginx/ssl \
	&& chown -R nginx-le:nginx-le /etc/nginx \
	&& mkdir -p /usr/share/nginx/html/.well-known \
	&& chown -R nginx-le:nginx-le /usr/share/nginx/html/.well-known

COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts /r/scripts
COPY etc /r/etc

ENV SERVER_NAMES="api.example.com api2.example.com" \
    LE_EMAIL="user@example.com" \
    LOCATION="/" \
    FAVICON_LOCAL_PATH="" \
    FORCE_REDIRECT_TO_HTTPS="true" \
    # You must only set PROXY_PASS or FASTCGI_PASS
    PROXY_PASS="" \
    PROXY_CONNECT_TIMEOUT="60" \
    PROXY_SEND_TIMEOUT="60" \
    PROXY_READ_TIMEOUT="60" \
    FASTCGI_PASS="" \
    # Specially for php-fpm
    FASTCGI_PARAM_SCRIPT_FILENAME="" \
    FASTCGI_READ_TIMEOUT="60" \
    WORKER_CONNECTIONS="1024" \
    # Set empty string to disable
    GZIP_ENABLED="true" \
    GZIP_TYPES="text/plain application/json text/css application/javascript application/x-javascript text/javascript text/xml application/xml application/rss+xml application/atom+xml application/rdf+xml" \
    # Set empty string to disable
    CORS_ENABLED="true" \
    CORS_ALLOW_ORIGIN="*" \
    CORS_ALLOW_METHODS="GET, PUT, POST, DELETE, OPTIONS" \
    CORS_ALLOW_CREDENTIALS="true" \
    CORS_ALLOW_HEADERS="Authorization,DNT,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type" \
    CLIENT_MAX_BODY_SIZE="8M" \
    # Required by ssl_stapling
    RESOLVER="8.8.8.8" \
    # Set "1" to add --dry-run to certbot
    LE_DRY_RUN=""

EXPOSE 8080 4430

USER 2001

CMD ["sh", "/entrypoint.sh"]
