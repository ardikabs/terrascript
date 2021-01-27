#!/bin/bash

apt update -y && mkdir -p ~/.aws && \
apt install --no-install-recommends -y wget unzip ca-certificates git curl gawk openssh-client && \
wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip && \
unzip /tmp/terraform.zip && \
mv /app/terraform /usr/local/bin/ && \
rm -rf /var/lib/apt/lists/* && \
rm -Rf /usr/share/doc && \
rm -Rf /usr/share/man && \
rm -rf /tmp/terraform.zip && \
apt-get clean

mkdir -p /tmp/terraform-plugin-cache
mkdir -p ~/.ssh
chmod +x /usr/bin/terrascript