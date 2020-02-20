FROM nginx:1.17.8-alpine

RUN \
	rm -rf /etc/nginx/conf.d && \
	apk add  --update certbot openssl && \
	rm -rf /var/cache/apk/*

COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts /r/scripts
COPY etc /r/etc

ENV SERVER_NAMES="api.example.com api2.example.com" \
    LE_EMAIL="user@example.com" \
    LOCATION="/" \
    # You must only set PROXY_PASS or FASTCGI_PASS
    PROXY_PASS="" \
    FASTCGI_PASS="" \
    # Specially for php-fpm
    FASTCGI_PARAM_SCRIPT_FILENAME="" \
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

EXPOSE 80 443

CMD ["sh", "/entrypoint.sh"]
