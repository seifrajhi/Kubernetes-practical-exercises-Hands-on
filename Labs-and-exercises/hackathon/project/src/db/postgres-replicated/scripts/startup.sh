#!/bin/sh
/scripts/wait-service.sh
/scripts/initialize-replication.sh
    
if [ "$HOSTNAME" == "$POSTGRES_PRIMARY_NAME" ]; then
    echo '** Postgres primary **'      
    /docker-entrypoint.sh postgres -c config_file=/conf/primary.conf -c hba_file=/conf/pg_hba.conf
else
    echo '** Postgres standby - initializing replication**'
    if [ -z "$(ls -A ${PGDATA})" ]; then
        pg_basebackup -R -h "$POSTGRES_PRIMARY_FQDN" -D "$PGDATA" -P -U replication
        chown -R postgres:postgres $PGDATA
    fi
    /docker-entrypoint.sh postgres -c config_file=/conf/standby.conf
fi