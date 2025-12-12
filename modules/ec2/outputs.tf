output "instance_ips" {
  description = "Map of instance names to their Public IPs"
  value = {
    for name, instance in aws_instance.app : name => instance.public_ip
  }
}

output "debug_files_found" {
  value = local.yaml_files
}

output "debug_config_path" {
  value = var.config_folder
}