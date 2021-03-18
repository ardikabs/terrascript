#!/usr/bin/env bash

run() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    die "current directory is not a git repository (${repo_dir-})"
  fi

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

  # Perform scanning into repository for any changes in one of the following states
  # > Adding
  # > Modified
  # > Deleted

  msg "${RED}"
  msg "############################################################"
  msg "                 STARTING TERRAFORM TASK                    "
  msg "############################################################"
  msg "${NC}"

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
    execute "${deleted_dirs[@]}" "${action}" "destroy"
    git checkout "${CURRENT_HEAD}" >/dev/null 2>&1
  fi

  msg "${PURPLE}"
  msg "############################################################"
  msg "                 END OF TERRAFORM TASK                      "
  msg "############################################################"
  msg "${NC}"

  if [ ${#ERRORS[@]} -ne 0 ]; then
    export ERROR_MARK=runtime
    return 10
  fi

  msg "${LGREEN}"
  msg "#####################################################"
  msg "                 SUMMARY REPORT                      "
  msg "#####################################################"
  msg "${NC}"

  msg "Repository: ${YELLOW}${repo}${NC}\n"

  msg "${YELLOW}Added${NC} Resources \t: $(wc -w <<< "${added_dirs}" | sed -e 's/^[[:space:]]*//') resources"
  msg "${GREEN}Modified${NC} Resources \t: $(wc -w <<< "${modified_dirs}" | sed -e 's/^[[:space:]]*//') resources"
  msg "${RED}Deleted${NC} Resources \t: $(wc -w <<< "${deleted_dirs}" | sed -e 's/^[[:space:]]*//') resources"
  msg ""

  msg "Terraform Resources List:\n"

  for path in $added_dirs; do
    printf >&2 "%-24b %b\n" "[${YELLOW}ADDED${NC}]" "Resource ${YELLOW}${path}${NC}"
  done

  for path in $modified_dirs; do
    printf >&2 "%-24b %b\n" "[${GREEN}MODIFIED${NC}]" "Resource ${GREEN}${path}${NC}"
  done

  for path in $deleted_dirs; do
    printf >&2 "%-24b %b\n" "[${RED}DELETED${NC}]" "Resource ${RED}${path}${NC}"
  done
}
