variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the SG will be created"
  type        = string
}

variable "ingress_ports" {
  description = "List of TCP ports to allow from 0.0.0.0/0"
  type        = list(number)
  default     = []
}