FROM debian:stretch-slim

ARG TERRAFORM_VERSION
ARG GIT_COMMIT

ENV DEBIAN_FRONTEND noninteractive
ENV GIT_COMMIT=${GIT_COMMIT}

WORKDIR /app

COPY build/install.sh /app/install.sh
COPY terrascript /usr/bin/terrascript

RUN bash /app/install.sh

CMD ["terrascript"]