export FIRST_SERVER_NAME=$(echo "${SERVER_NAMES}" | cut -d' ' -f1)

export SSL_CERT=/etc/letsencrypt/live/${FIRST_SERVER_NAME}/fullchain.pem
export SSL_KEY=/etc/letsencrypt/live/${FIRST_SERVER_NAME}/privkey.pem
export SSL_TRUSTED_CERT=/etc/letsencrypt/live/${FIRST_SERVER_NAME}/chain.pem
