FROM debian:stretch-slim

ARG TERRAFORM_VERSION
ARG GIT_COMMIT

ENV DEBIAN_FRONTEND noninteractive
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.12.26}
ENV GIT_COMMIT=${GIT_COMMIT}

COPY build/entrypoint.sh docker-entrypoint.sh
COPY terrascript /usr/bin/terrascript
COPY lib /opt/terrascript/lib

RUN apt update -y && \
    apt install --no-install-recommends -y \
        wget \
        unzip \
        ca-certificates \
        git \
        curl \
        gawk \
        openssh-client && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man && \
    apt-get clean && \
    mkdir -p ~/.aws && \
    mkdir -p ~/.ssh /tmp/terraform-plugin-cache && \
    chmod +x /docker-entrypoint.sh && \
    chmod +x /usr/bin/terrascript

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/terrascript"]