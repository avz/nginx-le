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

log Cleanup https config to avoid nginx shutdown because cert files was not found

rm -f /etc/nginx/conf.d/service.https.conf
mkdir -p /etc/nginx/conf.d

(
	log Waiting for nginx is ready to accept http-challenge
	sleep 5

	while true; do
		log Try to renew or obtain new certs

		sh /r/scripts/le.sh

		if [ -f "${SSL_CERT}" ]; then
			tt < /r/etc/nginx/conf.d/service.https.conf.tt > /etc/nginx/conf.d/service.https.conf
		else
			error Certificates not found. HTTPS disabled!

			rm -f /etc/nginx/conf.d/service.https.conf
		fi

		tt < /r/etc/nginx/conf.d/service.http.conf.tt > /etc/nginx/conf.d/service.http.conf
		tt < /r/etc/nginx/conf.d/service.inc.tt > /etc/nginx/conf.d/service.inc

		log Reloading nginx config
		nginx -s reload

		sl=$((24 + $RANDOM * 24 / 32768))

		log Going to sleep for $sl hours

		sleep ${sl}h
	done
) &

exec nginx -g "daemon off;"
