variable "env" { type = string }
variable "vpc_id" { type = string }
variable "cluster_id" { type = string }
variable "subnets" { type = list(string) }
variable "otel_config_yaml" { type = string }
variable "image_uri" { 
  default = "public.ecr.aws/aws-observability/aws-otel-collector:latest" 
}