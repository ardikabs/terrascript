#!/bin/bash

wget -q -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip
unzip -qq -o /tmp/terraform.zip -d /usr/local/bin; rm -rf /tmp/terraform.zip

exec "$@"