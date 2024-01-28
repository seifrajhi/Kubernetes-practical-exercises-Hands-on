#!/bin/sh
if [ "$HOSTNAME" == "$POSTGRES_PRIMARY_NAME" ]; then
    echo '** Postgres primary **'
else
    echo '** Postgres standby - waiting on DNS for primary **'
    until nslookup ${POSTGRES_PRIMARY_FQDN}; do echo Waiting for ${POSTGRES_PRIMARY_FQDN}; sleep 1; done
fi