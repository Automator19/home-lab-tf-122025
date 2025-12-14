variable "service_name" {
  description = "Name of the service and task family"
  type        = string
}

variable "cluster_id" {
  description = "ARN or ID of the ECS Cluster"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for the task"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "ARN of the Task Execution Role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the Task Role"
  type        = string
}

variable "container_definitions" {
  description = "JSON string containing the container definition"
  type        = string
}

variable "cpu" {
  description = "Fargate CPU units (e.g., 256, 512, 1024)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate Memory (MB)"
  type        = number
  default     = 1024
}