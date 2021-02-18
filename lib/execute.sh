#!/usr/bin/env bash

execute() {
  local basedir
  local cachedir
  local target_dirs
  local action
  local destroy

  basedir="$(git rev-parse --show-toplevel)"
  cachedir=$(
    cachedir="${TF_PLUGIN_CACHE_DIR}"
    mkdir -p "${cachedir}"
    echo "${cachedir}"
  )

  target_dirs=$1
  action=$2

  if [ -n "${3-}" ]; then destroy="-destroy"; fi

  for tfpath in ${target_dirs}; do
    dir_with_files=$(find "${basedir}"/"${tfpath}" -maxdepth 1 -type f 2>/dev/null)
    if [ -n "${dir_with_files}" ]; then
      echo -e "[${BLUE}START${NC}]: ${WHITE}Starting Terraform task at${NC} ${CYAN}${tfpath}${NC}"

      (
        export TF_BACKEND_STATE=${tfpath%\/}/terraform.tfstate
        export TF_PLUGIN_CACHE_DIR=${cachedir}
        export TF_PLANFILE="/tmp/target.tfplan"

        TF_INIT="${TF_BIN} init"
        TF_VALIDATE="${TF_BIN} validate"
        TF_PLAN="${TF_BIN} plan -out ${TF_PLANFILE}"
        TF_APPLY="${TF_BIN} apply ${TF_PLANFILE}"

        cd "${basedir}"/"${tfpath}"
        sleep 1

        case ${action} in
          validate)
            eval "${TF_INIT} -backend=false"
            eval "${TF_VALIDATE}"
            ;;
          plan)
            eval "${TF_INIT} ${TF_BACKEND_CONFIG}"
            eval "${TF_PLAN} ${destroy}"
            ;;
          apply)
            eval "${TF_INIT} ${TF_BACKEND_CONFIG}"
            eval "${TF_PLAN} ${destroy}"
            eval "${TF_APPLY}"
            ;;
        esac
      ) || ERRORS+=("${tfpath}")

      echo -e "[${BLUE}DONE${NC}]: ${WHITE}Terraform task at ${CYAN}$tfpath\n${NC} is completed\n${NC}"
    fi
  done
}