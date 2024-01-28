#!/bin/sh
if [ "$HOSTNAME" == "$POSTGRES_PRIMARY_NAME" ]; then
    echo '** Postgres primary - creating init scripts **'
    cp /initdb/*.sh /docker-entrypoint-initdb.d/
    ls -l /docker-entrypoint-initdb.d
else
    echo '** Postgres standby - waiting on primary **'
    until pg_isready -h "$POSTGRES_PRIMARY_FQDN"; do echo Waiting for db to be ready; sleep 1; done        
fi