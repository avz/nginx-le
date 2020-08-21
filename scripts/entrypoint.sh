#!/bin/sh

. /r/scripts/internal.env.sh

tt () {
	sh /r/scripts/tt.sh
}

log () {
	echo "$(date -Iseconds) [avzd/nginx-le] $@"
}

error () {
	echo "$(date -Iseconds) [avzd/nginx-le] ERROR: $@" >&2
}

tt < /r/etc/nginx/nginx.conf.tt > /etc/nginx/nginx.conf
tt < /r/etc/nginx/ssl.conf.tt > /etc/nginx/ssl.conf

if [ ! -f /etc/nginx/ssl/dhparams.pem ]; then
	log dhparams.pem is not found. Let\'s create them

	mkdir -p /etc/nginx/ssl
    cd /etc/nginx/ssl

    openssl dhparam -out dhparams.pem 2048
    chmod 600 dhparams.pem
fi

if [ ! -f "${SSL_CERT}" ]; then
	log Cleanup https config to avoid nginx shutdown because cert files was not found

	rm -f /etc/nginx/conf.d/service.https.conf
fi

mkdir -p /etc/nginx/conf.d

tt < /r/etc/nginx/conf.d/service.http.conf.tt > /etc/nginx/conf.d/service.http.conf
tt < /r/etc/nginx/conf.d/service.inc.tt > /etc/nginx/conf.d/service.inc

(
	log Waiting for nginx is ready to accept http-challenge...

	while ! curl -s -m 1 -f localhost:8080/.well-known/health-check; do
		log Nginx is not ready yet

		sleep 0.5
	done

	log Nginx is ready to serve http-challenge

	while true; do
		log Try to renew or obtain new certs

		sh /r/scripts/le.sh

		if [ -f "${SSL_CERT}" ]; then
			tt < /r/etc/nginx/conf.d/service.https.conf.tt > /etc/nginx/conf.d/service.https.conf

			log Reloading nginx config
			nginx -s reload
		else
			error Unable to obtain cert!
		fi

		sl=$((24 + $RANDOM * 24 / 32768))

		log Going to sleep for $sl hours

		sleep ${sl}h
	done
) &

log Starting nginx

exec nginx -g "daemon off;"
