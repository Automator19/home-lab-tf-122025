variable "env_name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "config_folder" {
  description = "Absolute path to the folder containing YAML config files"
  type        = string
}
variable "key_name" {
  description = "Name of the SSH key pair to use for instances"
  type        = string
}