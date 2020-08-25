FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app

COPY install.sh /app/install.sh
COPY terrascript /usr/local/bin/terrascript

RUN bash /app/install.sh