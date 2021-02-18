#!/usr/bin/env bash

select_backend() {

  if [ "$1" == "aws" ]; then
    export TF_BACKEND_CONFIG="-backend-config=\"bucket=\$TF_BACKEND_BUCKET\""
    export TF_BACKEND_CONFIG+=" -backend-config=\"dynamodb_table=\$TF_BACKEND_DYNAMODB_TABLE\""
    export TF_BACKEND_CONFIG+=" -backend-config=\"key=\$TF_BACKEND_STATE\""
  elif [ "$1" == "gcs" ]; then
    export TF_BACKEND_CONFIG="-backend-config=\"bucket=\$TF_BACKEND_BUCKET\""
    export TF_BACKEND_CONFIG+=" -backend-config=\"prefix=\$TF_BACKEND_STATE\""
  fi
}


run() {
  local repo
  local action
  local added_dirs
  local modified_dirs
  local deleted_dirs

  action=$1
  if [[ $action == "apply" ]]; then
    assigner_check
  fi

  repo="$(basename "$(git rev-parse --show-toplevel)")"

  # Git commit variables
  CURRENT_HEAD="$(git rev-parse HEAD)"
  PREVIOUS_HEAD="${TF_PREVIOUS_HEAD:-$(git rev-parse HEAD^1)}"

  # Select backend and forming -backend-config arguments for terraform
  select_backend "${TF_BACKEND:-aws}"

  # Perform scanning into repository for any changes in one of the following states
  # > Adding
  # > Modified
  # > Deleted

  echo -e "${RED}"
  echo -e "############################################################"
  echo -e "                 STARTING TERRAFORM TASK                    "
  echo -e "############################################################"
  echo -e "${NC}"

  added_dirs=$(git --no-pager diff "${PREVIOUS_HEAD}"..."${CURRENT_HEAD}" --dirstat-by-file --diff-filter=A -- '*.tf' '*.tfvars' '*.json' | awk '{ print $2 }')
  modified_dirs=$(git --no-pager diff "${PREVIOUS_HEAD}"..."${CURRENT_HEAD}" --dirstat-by-file --diff-filter=M -- '*.tf' '*.tfvars' '*.json' | awk '{ print $2 }')
  deleted_dirs=$(git --no-pager diff "${PREVIOUS_HEAD}"..."${CURRENT_HEAD}" --dirstat-by-file --diff-filter=D -- '*.tf' '*.tfvars' '*.json' | awk '{ print $2 }')

  if [ -n "${added_dirs}" ]; then
    execute "${added_dirs[@]}" "${action}"
  fi

  if [ -n "${modified_dirs}" ]; then
    execute "${modified_dirs[@]}" "${action}"
  fi

  if [ -n "${deleted_dirs}" ]; then
    git checkout "${PREVIOUS_HEAD}" >/dev/null 2>&1
    execute "${deleted_dirs[@]}" "${action}" destroy
    git checkout "${CURRENT_HEAD}" >/dev/null 2>&1
  fi

  echo -e "${PURPLE}"
  echo -e "############################################################"
  echo -e "                 END OF TERRAFORM TASK                      "
  echo -e "############################################################"
  echo -e "${NC}"

  if [ ${#ERRORS[@]} -ne 0 ]; then
    ERROR_MARK=runtime
    return 99
  fi

  echo -e "${LGREEN}"
  echo -e "#####################################################"
  echo -e "                 SUMMARY REPORT                      "
  echo -e "#####################################################"
  echo -e "${NC}"

  echo -e "Repository: ${YELLOW}${repo}${NC}\n"

  echo -e "${YELLOW}Added${NC} Resources \t: $(wc -w <<< "${added_dirs}" | sed -e 's/^[[:space:]]*//') resources"
  echo -e "${GREEN}Modified${NC} Resources \t: $(wc -w <<< "${modified_dirs}" | sed -e 's/^[[:space:]]*//') resources"
  echo -e "${RED}Deleted${NC} Resources \t: $(wc -w <<< "${deleted_dirs}" | sed -e 's/^[[:space:]]*//') resources"
  echo -e ""

  echo -e "Terraform Resources List:\n"

  for path in $added_dirs; do
    printf "%-24b %b\n" "[${YELLOW}ADDED${NC}]" "Resource ${YELLOW}${path}${NC}"
  done

  for path in $modified_dirs; do
    printf "%-24b %b\n" "[${GREEN}MODIFIED${NC}]" "Resource ${GREEN}${path}${NC}"
  done

  for path in $deleted_dirs; do
    printf "%-24b %b\n" "[${RED}DELETED${NC}]" "Resource ${RED}${path}${NC}"
  done
}
