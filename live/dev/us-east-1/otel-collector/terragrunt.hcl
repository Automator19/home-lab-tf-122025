terraform {
  source = "../../../../modules/otel-collector-blueprint"
}

# ---------------------------------------------------------
# 1. Define the Dependency
# ---------------------------------------------------------
dependency "vpc" {
  config_path = "../vpc" # Path to your VPC terragrunt.hcl relative to this file

  # Optional: Fake data to allow 'terragrunt validate' to run before VPC exists
  mock_outputs = {
    vpc_id           = "vpc-fake-id"
    public_subnet_id = "subnet-fake-id"
  }
}

inputs = {
  env = "dev"

  # ---------------------------------------------------------
  # 2. Read outputs from the Dependency
  # ---------------------------------------------------------
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnets    = dependency.vpc.outputs.public_subnet_ids
  cluster_id = "otel-cluster" # Hardcode the Cluster ID if you haven't created a module for it yet
  otel_config_yaml = file("otel-config.yaml")
}