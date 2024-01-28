FROM postgres:11.11-alpine

COPY ./initdb/*.sh /initdb/
COPY ./conf/*.conf /conf/
COPY ./scripts/*.sh /scripts/

RUN chmod +x /scripts/*.sh

ENV POSTGRES_PASSWORD=widgetario \
    POSTGRES_PRIMARY_NAME=products-db-0 \
    POSTGRES_PRIMARY_FQDN=products-db-0.products-db.default.svc.cluster.local \
    POSTGRES_SECONDARY_FQDN=products-db-1.products-db.default.svc.cluster.local

CMD ["sh", "/scripts/startup.sh"]