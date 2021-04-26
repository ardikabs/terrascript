# 0.1.7 (April 26, 2021)
NOTES:
* Add support for terrascript itself to be able download Terraform binary if not exist

# 0.1.6 (March 18, 2021)
NOTES:
* Terraformless, download terraform binary on-demand from entrypoint. Need `$TERRAFORM_VERSION` to specify specific version.
+ Add exit_handler.
+ Rework execute process.
+ Modify gitlabci template, make apply job depend on plan job.
+ Restructure directory to library based.
+ Add warning when environment variable TF_BACKEND_BUCKET is missing.
+ Add warning when running terrascript on non-git repository.
+ Add TF_BACKEND_PREFIX for prefix on the bucket path.

# 0.1.5 (Jan 27, 2021)
NOTES:
* Terraform 0.12.26
* Reuse subshell
* Modify message format

# 0.1.4 (Oct 6, 2020)
NOTES:
* Terraform 0.12.25
* Fix multiple directories scene
* Add summary report

# 0.1.3 (Sept 21, 2020)
NOTES:
* Terraform 0.12.25
* Fix error occur while `terraform apply` on destroy scene

# 0.1.2 (Sept 16, 2020)
NOTES:
* Terraform 0.12.25
* Replace `git-diff` double-dot to triple-dot approach

# 0.1.1 (Sept 14, 2020)
NOTES:
* Break the execute action to be an `execute` function

# 0.1.0 (Aug 25, 2020)
NOTES:
* Initially put terrascript to be aware with changes on the following files: `*.tf`, `*.tfvars`, `*.json`
* Add TF_ASSIGNERS variable to refer the allowed user for running terrascript
* Tested for managing AWS resources with terraform