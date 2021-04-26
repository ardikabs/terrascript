#!/usr/bin/env bash

fetch_terraform_if_not_exist() {
  if ! type terraform >/dev/null 2>&1; then
    wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip
    unzip -qq -o /tmp/terraform.zip -d /tmp/; rm -rf /tmp/terraform.zip
    mv "/tmp/terraform" "/tmp/terraform_${TERRAFORM_VERSION}"

    chmod +x "/tmp/terraform_${TERRAFORM_VERSION}"

    export TF_BIN="/tmp/terraform_${TERRAFORM_VERSION}"
  fi
}

assigner_check() {
  assigners=$(echo "${TF_ASSIGNERS-}" | base64 -d)

  if ! grep "${GITLAB_USER_LOGIN-}" <<<"${assigners}" >/dev/null; then
    msg "${RED}ABORT!${NC} You are not allowed to run this operation."
    msg "Please contact one of the repository maintainers below:\n"
    msg "${WHITE}${assigners}${NC}"
    return 77
  fi
}
