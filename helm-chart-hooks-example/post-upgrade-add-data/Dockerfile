FROM mysql:latest

WORKDIR /scripts

COPY add-data.sh /scripts/add-data.sh

ENTRYPOINT [ "sh", "add-data.sh" ]