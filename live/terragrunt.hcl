# live/terragrunt.hcl
# -------------------------------------------------------------------
# This is the root config that is inherited by all child modules. 
# -------------------------------------------------------------------
locals {
  # 1. Load the Environment Variable (e.g. dev or prod) from env.hcl
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.env_vars.locals.env_name

  # 2. Load Regional Variables (e.g. us-east-x) from region.hcl
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region = local.region_vars.locals.aws_region

  # 3. Define Project Name (for tagging and naming)
  project_name = "homelab"
}

# -----------------------------------------------------------------
# REMOTE STATE (S3 & DynamoDB)
# -----------------------------------------------------------------

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "my-homelab-terraform-state-12345" 
    # This automatically sets the key based on the folder you are in! e.g., "dev/us-east-1/vpc/terraform.tfstate"
    key = "${path_relative_to_include()}/terraform.tfstate"
    # State file will be stored in us-east-1 regardless of where the resources are depployed
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "${local.project_name}-lock-table"
  }
}

# ------------------------------------------------------------------
# GLOBAL PROVIDERS (AWS)
# ------------------------------------------------------------------

# This generates the provider block for every module
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  profile = "homelab"
  default_tags {
    tags = {
      Environment = "${local.env}"
      Project = "${local.project_name}"
      ManagedBy   = "Terragrunt"
    }
  }
}
EOF
}