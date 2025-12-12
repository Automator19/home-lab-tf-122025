include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../../modules/ec2"
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id           = "vpc-mock"
    public_subnet_id = "subnet-mock"
  }
}

inputs = {
  # Unique name for this stack
  env_name = "dev-grafana" 
  key_name = "homelab-key"
  # This automatically looks in the 'ansible/configs' folder
  config_folder = "${get_terragrunt_dir()}/configs"
  user_data_file = "${get_terragrunt_dir()}/setup.sh"

  vpc_id    = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.public_subnet_id
}