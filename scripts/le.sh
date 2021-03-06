#!/bin/sh

renewInterval=$((27 * 24 * 60 * 60 + ($RANDOM * 4 * 24 * 60 * 60 / 36768)))

log () {
	echo "$(date -Iseconds) [avzd/nginx-le] $@"
}

certIsExists () {
	test -f "${SSL_CERT}"
}

certRenewIsRequired () {
	! openssl x509 -checkend "${renewInterval}" -in "${SSL_CERT}" > /dev/null
}

certDomains () {
	openssl x509 -in "${SSL_CERT}" -text -noout | egrep -o 'DNS.*' | sed -e 's/DNS://g' | tr -d ' ' | tr , ' '
}

domainsListsIsSame () {
	test -z "$(echo "${1}" "${2}" | tr ' ' '\n' | sort | uniq -u)"
}

if certIsExists; then
	existCertDomains=$(certDomains)

	log "Found existing certificate for ${existCertDomains} (${SSL_CERT})"

	if ! domainsListsIsSame "${SERVER_NAMES}" "${existCertDomains}"; then
		log "Certificate ${SSL_CERT} contains [${existCertDomains}] but [${SERVER_NAMES}] is expected." \
			" Please remove existent certificates or change requested SERVER_NAMES" >&2

		exit 1
	fi

	if ! certRenewIsRequired; then
		log 'Certificate renew is not required'

		exit 0
	fi
fi

dryRun=

if [ ! -z "${LE_DRY_RUN}" ]; then
	dryRun=--dry-run
fi

certbot certonly \
	-t \
	-n \
	${dryRun} \
	--agree-tos \
	--renew-by-default \
	--email "${LE_EMAIL}" \
	--webroot \
	-w /usr/share/nginx/html \
	-d "$(echo "${SERVER_NAMES}" | tr ' ' ',')"
