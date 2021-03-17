#!/usr/bin/env bash

assigner_check() {
  assigners=$(echo "${TF_ASSIGNERS-}" | base64 -d)

  if ! grep "${GITLAB_USER_LOGIN-}" <<<"${assigners}"; then
    die "You are not allowed to run this operation\nPlease contact one of the repository maintainers below:\n${WHITE}${assigners}${NC}"
  fi
}