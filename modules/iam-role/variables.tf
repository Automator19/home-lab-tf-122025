variable "name" {
  description = "The name of the IAM role"
  type        = string
}

variable "trusted_service" {
  description = "The AWS service allowed to assume this role"
  type        = string
  default     = "ecs-tasks.amazonaws.com"
}

variable "policy_arns" {
  description = "List of ARNs of policies to attach to the role"
  type        = list(string)
  default     = []
}