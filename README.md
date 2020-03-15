# Environment-configurable docker image with Nginx and automatic Let's Encrypt

The image is fully configurable via environment variables and
does not require the creation of configuration files.

Inspired by [nginx-le/nginx-le](https://github.com/nginx-le/nginx-le).

## Example `docker-compose.yml`

You only need to set `SERVER_NAMES`, `LE_EMAIL`
and `PROXY_PASS` OR `FASTCGI_PASS` to get started.

Configuration files are generated every time the container starts,
so there is no need to rebuild for the changes to take effect.

```yaml
version: '3.5'
services:
    nginx:
        image: avzd/nginx-le:latest

        environment:
            ## Space-separated list of domains to host
            SERVER_NAMES: api.example.com api2.example.com

            ## https://letsencrypt.org/docs/expiration-emails/
            LE_EMAIL: bob@example.com

            ## Uncomment this to run certbot with --dry-run
            # LE_DRY_RUN="yes"

            ## Simple proxy HTTP
            # PROXY_PASS: http://host:8080

            ## OR

            ## FastCGI (e.g. for php-fpm):
            # FASTCGI_PASS: http://host:9000
            # FASTCGI_PARAM_SCRIPT_FILENAME=/sources/index.php

            ## ...
            ## See all options in Dockerfile ENV

        # volumes:
            ## To make dhparams persistent
            # - /path/to/ssl:/etc/nginx/ssl

            ## To make certificates persistent
            # - /path/to/letsencrypt:/etc/letsencrypt

        restart: always

        logging:
            driver: json-file
            options:
                max-size: "10m"
                max-file: "5"

        ports:
            - "80:8080"
            - "443:4430"
```

## See also

 * [Traefik](https://containo.us/traefik/)
 * [nginx-le/nginx-le](https://github.com/nginx-le/nginx-le)
 * [gilyes/docker-nginx-letsencrypt-sample](https://github.com/gilyes/docker-nginx-letsencrypt-sample)
