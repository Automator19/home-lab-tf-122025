resource "aws_ecs_cluster" "this" {
  name = var.name

  # Enable Container Insights (optional, good for monitoring)
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}