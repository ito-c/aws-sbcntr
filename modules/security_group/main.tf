resource "aws_security_group" "this" {
  name   = "${var.project}-${var.environment}-security-group-for-${var.resource}"
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-security-group-for-${var.resource}"
    Project     = var.project
    Environment = var.environment
    Resource    = var.resource
  }
}

resource "aws_security_group_rule" "ingress" {
  count = var.is_specified_sg ? 0 : 1

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_source_sg" {
  count = var.is_specified_sg ? 1 : 0

  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.source_security_group_id
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
