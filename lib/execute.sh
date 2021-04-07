#!/usr/bin/env bash

select_backend() {
  if [ -z "${TF_BACKEND_BUCKET-}" ]; then
    die "Required Terraform backend bucket (\$TF_BACKEND_BUCKET) environment variable is missing"
  fi

  # shellcheck disable=SC2016
  case $1 in
    aws)
      export TF_BACKEND_CONFIG="-backend-config=bucket=$TF_BACKEND_BUCKET \
        -backend-config=key=${TF_BACKEND_PREFIX:+${TF_BACKEND_PREFIX}/}\$TF_BACKEND_STATE \
        ${TF_BACKEND_DYNAMODB_TABLE:+-backend-config=dynamodb_table=$TF_BACKEND_DYNAMODB_TABLE}
      "
      ;;
    google)
      export TF_BACKEND_CONFIG="-backend-config=bucket=$TF_BACKEND_BUCKET \
        -backend-config=prefix=${TF_BACKEND_PREFIX:+${TF_BACKEND_PREFIX}/}\$TF_BACKEND_STATE
      "
      ;;
  esac
}

execute() {
  local basedir
  local target_dirs
  local action
  local destroy

  target_dirs=$1
  action=$2
  destroy=${3-}

  export TF_PLUGIN_CACHE_DIR; mkdir -p "$TF_PLUGIN_CACHE_DIR"

  basedir="$(git rev-parse --show-toplevel)"

  # Select backend and forming -backend-config arguments for terraform
  select_backend "${TF_BACKEND:-aws}"

  for tfpath in ${target_dirs}; do
    dir_with_files=$(find "${basedir}"/"${tfpath}" -maxdepth 1 -type f 2>/dev/null)
    if [ -n "${dir_with_files}" ]; then
      msg "[${BLUE}START${NC}]: ${WHITE}Starting Terraform task at${NC} ${CYAN}${tfpath}${NC}"

      TF_PLAN_DIR="${basedir}/.plan/${tfpath}"
      mkdir -p "$TF_PLAN_DIR"

      (
        export TF_PLAN_FILE="${TF_PLAN_DIR%\/}/default.tfplan"
        export TF_BACKEND_STATE="${tfpath%\/}/terraform.tfstate"

        TF_INIT="${TF_BIN} init"
        TF_VALIDATE="${TF_BIN} validate"
        TF_PLAN="${TF_BIN} plan -out ${TF_PLAN_FILE}"
        TF_APPLY="${TF_BIN} apply ${TF_PLAN_FILE}"

        cd "${basedir}"/"${tfpath}"
        sleep 1

        case ${action} in
          validate)
            eval "${TF_INIT} -backend=false"
            eval "${TF_VALIDATE}"
            ;;
          plan)
            eval "${TF_INIT} ${TF_BACKEND_CONFIG}"
            eval "${TF_PLAN} ${destroy:+-destroy}"
            ;;
          apply)
            eval "${TF_INIT} ${TF_BACKEND_CONFIG}"
            eval "${TF_APPLY}"
            ;;
        esac
      ) || ERRORS+=("${tfpath}")

      msg "[${BLUE}DONE${NC}]: ${WHITE}Terraform task at ${CYAN}$tfpath\n${NC} is completed\n${NC}"
    fi
  done
}