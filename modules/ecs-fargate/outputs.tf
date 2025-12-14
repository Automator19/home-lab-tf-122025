output "service_name" {
  description = "Name of the created service"
  value       = aws_ecs_service.this.name
}