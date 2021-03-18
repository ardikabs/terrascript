#!/usr/bin/env bash

assigner_check() {
  assigners=$(echo "${TF_ASSIGNERS-}" | base64 -d)

  if ! grep "${GITLAB_USER_LOGIN-}" <<<"${assigners}" >/dev/null; then
    msg "${RED}ABORT!${NC} You are not allowed to run this operation."
    msg "Please contact one of the repository maintainers below:\n"
    msg "${WHITE}${assigners}${NC}"
    return 99
  fi
}