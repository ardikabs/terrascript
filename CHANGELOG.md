# 0.1.3 (Sept 21, 2020)
NOTES:
* Terraform v0.12.25
* Fix error occur while `terraform apply` on destroy scene

# 0.1.2 (Sept 16, 2020)
NOTES:
* Terraform v0.12.25
* Replace `git-diff` double-dot to triple-dot approach

# v0.1.1 (Sept 14, 2020)
NOTES:
* Break the execute action to be an `execute` function

# v0.1.0 (Aug 25, 2020)
NOTES:
* Initially put terrascript to be aware with changes on the following files: `*.tf`, `*.tfvars`, `*.json`
* Add TF_ASSIGNERS variable to refer the allowed user for running terrascript
* Tested for managing AWS resources with terraform