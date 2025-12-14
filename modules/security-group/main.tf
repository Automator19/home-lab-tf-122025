resource "aws_security_group" "this" {
  name        = var.name
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create one ingress rule for every port in the list
resource "aws_security_group_rule" "ingress" {
  count             = length(var.ingress_ports)
  type              = "ingress"
  from_port         = var.ingress_ports[count.index]
  to_port           = var.ingress_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}