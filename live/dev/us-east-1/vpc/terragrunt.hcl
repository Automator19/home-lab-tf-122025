# 1. Inherit the configurations from the root live/terragrunt.hcl
include {
  path = find_in_parent_folders()
}

# 2. Point to the reusable VPC module
terraform {
  source = "../../../../modules/vpc"
}

# 3. Pass in the vars specific to Dev
inputs = {
  env_name           = "dev-homelab"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
}