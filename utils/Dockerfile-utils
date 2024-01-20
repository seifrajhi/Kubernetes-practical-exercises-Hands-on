FROM ubuntu:bionic

RUN apt-get update \
  && apt-get install --no-install-recommends --yes --force-yes \
    locales \
    bind9-host \
    curl \
    dnsutils \
    httpie \
    iputils-ping \
    jq \
    netcat-openbsd \
    mongodb-clients \
    mysql-client \
    net-tools \
    postgresql-client \
    redis-tools \
    swaks \
    telnet \
    vim \
    nano \
    wget \
    influxdb-client \
    rabbitmq-server \
    python-setuptools \
    python-pip \
    openssh-client

RUN curl -O https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.7.14/bin/rabbitmqadmin \
  && mv rabbitmqadmin /usr/local/bin/ \
  && chmod +x /usr/local/bin/rabbitmqadmin

RUN pip install cqlsh

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
