# 1. SSM Parameter (Stores the Config)
resource "aws_ssm_parameter" "config" {
  name      = "/${var.env}/otel/config"
  type      = "String"
  value     = var.otel_config_yaml
  overwrite = true
}

# 2. Execution Role (Calls your IAM Module)
module "execution_role" {
  source      = "../iam-role"
  name        = "otel-exec-${var.env}"
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

# Grant SSM Read Access to the Execution Role
resource "aws_iam_role_policy" "ssm_access" {
  name = "ssm-read"
  role = module.execution_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow", Action = "ssm:GetParameters", Resource = aws_ssm_parameter.config.arn
    }]
  })
}

# 3. Task Role (Calls your IAM Module)
module "task_role" {
  source      = "../iam-role"
  name        = "otel-task-${var.env}"
  policy_arns = ["arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"]
}

# 4. Security Group (Calls your SG Module)
module "sg" {
  source        = "../security-group"
  name          = "otel-sg-${var.env}"
  vpc_id        = var.vpc_id
  ingress_ports = [4317, 4318]
}

# 5. ECS Service (Calls your ECS Module)
module "ecs" {
  source             = "../ecs-fargate"
  service_name       = "otel-collector-${var.env}"
  cluster_id         = var.cluster_id
  subnets            = var.subnets
  security_groups    = [module.sg.id]
  execution_role_arn = module.execution_role.arn
  task_role_arn      = module.task_role.arn

  # Define the Container
  container_definitions = jsonencode([{
    name      = "otel-collector"
    image     = var.image_uri
    essential = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-create-group"  = "true"
        "awslogs-group"         = "/ecs/otel-${var.env}"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    portMappings = [
      { containerPort = 4317 }, 
      { containerPort = 4318 }
    ]
    secrets = [
      { name = "AOT_CONFIG_CONTENT", valueFrom = aws_ssm_parameter.config.name }
    ]
  }])
}