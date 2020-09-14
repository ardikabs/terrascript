FROM debian:stretch-slim

ARG TERRAFORM_VERSION=0.12.26

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app

COPY install.sh /app/install.sh
COPY terrascript /usr/local/bin/terrascript

RUN bash /app/install.sh