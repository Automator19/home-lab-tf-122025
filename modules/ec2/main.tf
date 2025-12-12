# 1. Find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. Define the firewall (Security Group)
resource "aws_security_group" "app_sg" {
  name        = "${var.env_name}-app-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Read YAML files from the config folder
locals {
  # Finds all files ending in .yaml in the specific folder
  yaml_files = fileset(var.config_folder, "*.yaml")

  # Decodes them into a map: { "frontend" = { ... }, "backend" = { ... } }
  instances = {
    for file in local.yaml_files :
    trimsuffix(file, ".yaml") => yamldecode(file("${var.config_folder}/${file}"))
  }
}

# 4. Create the Instances (Loop)
resource "aws_instance" "app" {
  for_each = local.instances

  ami                         = data.aws_ami.amazon_linux.id
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name =  var.key_name
  instance_type = try(each.value.instance_type, "t3.micro") # Dynamic Inputs from YAML 
  user_data = fileexists("${var.config_folder}/${each.key}.sh") ? file("${var.config_folder}/${each.key}.sh") : null
  

  # Cost Savings: Use Spot Instances
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }

  tags = {
    Name = each.key # Result would be dev-projectname-dashboard
    Role = try(each.value.role, "worker")
  }
}