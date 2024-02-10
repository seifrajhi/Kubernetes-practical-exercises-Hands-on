FROM mysql:latest

WORKDIR /scripts

COPY initialize-db.sh /scripts/initialize-db.sh

ENTRYPOINT [ "sh", "initialize-db.sh" ]