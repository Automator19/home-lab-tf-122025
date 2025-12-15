output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "service_name" {
  value = module.ecs.service_name
}