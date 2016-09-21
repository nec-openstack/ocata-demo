# docker build -t yuanying/ubuntu-ruby:2.3.1 .
FROM     drecom/ubuntu-ruby:2.3.1
MAINTAINER OTSUKA, Yuanying "yuan-docker@fraction.jp"

RUN apt-get update \
&&  apt-get upgrade -y --force-yes \
&&  apt-get install -y --force-yes \
    libsqlite3-dev \
&&  apt-get clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
