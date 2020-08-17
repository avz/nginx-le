#!/bin/sh

. /r/scripts/internal.env.sh

tt () {
	sh /r/scripts/tt.sh
}

tt < /r/etc/nginx/nginx.conf.tt > /etc/nginx/nginx.conf
tt < /r/etc/nginx/ssl.conf.tt > /etc/nginx/ssl.conf

if [ ! -f /etc/nginx/ssl/dhparams.pem ]; then
	mkdir -p /etc/nginx/ssl
    cd /etc/nginx/ssl

    openssl dhparam -out dhparams.pem 2048
    chmod 600 dhparams.pem
fi

rm -rf /etc/nginx/conf.d
mkdir -p /etc/nginx/conf.d

(
	sleep 5

	while true; do
		sh /r/scripts/le.sh

		tt < /r/etc/nginx/conf.d/service.conf.tt > /etc/nginx/conf.d/service.conf
		tt < /r/etc/nginx/conf.d/service.inc.tt > /etc/nginx/conf.d/service.inc

		nginx -s reload

		sleep $((24 + $RANDOM * 24 / 32768))h
	done
) &

nginx -g "daemon off;"
