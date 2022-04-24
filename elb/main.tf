locals {
  project     = "sbcntr"
  environment = "NA"
}
#--------------------------------------------------
# Data only Modules
#--------------------------------------------------

module "network" {
  source = "./network"
}

#--------------------------------------------------
# elb
#--------------------------------------------------

# application load balancer
resource "aws_lb" "this" {
  name                       = "${local.project}-${local.environment}-alb"
  load_balancer_type         = "application"
  internal                   = true
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    module.network.private_container_1a_id,
    module.network.private_container_1c_id,
  ]
  security_groups = [module.security_group_for_internal_alb.security_group_id]

  tags = {
    Name        = "${local.project}-${local.environment}-alb"
    Environment = local.environment
    Project     = local.project
  }
}

# 内部ロードバランサ用のセキュリティグループ
module "security_group_for_internal_alb" {
  source      = "../modules/security_group"
  vpc_id      = module.network.vpc_id
  port        = "80"
  cidr_blocks = ["0.0.0.0/0"]

  environment = local.environment
  project     = local.project
  resource    = "internal-alb"
}

# blue listener
resource "aws_lb_listener" "blue" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.blue.arn
    type             = "forward"
  }
}

# green listener
resource "aws_lb_listener" "green" {
  load_balancer_arn = aws_lb.this.arn
  port              = "10080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.green.arn
    type             = "forward"
  }
}

# blue側ターゲットグループ
resource "aws_lb_target_group" "blue" {
  name     = "${local.project}-${local.environment}-tg-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200
  }

  tags = {
    Name        = "${local.project}-${local.environment}-tg-blue"
    Environment = local.environment
    Project     = local.project
  }
}

# green側ターゲットグループ
resource "aws_lb_target_group" "green" {
  name     = "${local.project}-${local.environment}-tg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200
  }

  tags = {
    Name        = "${local.project}-${local.environment}-tg-green"
    Environment = local.environment
    Project     = local.project
  }
}

# ターゲットの行き先リソース
# resource "aws_lb_target_group_attachment" "attach_web_ec2_1a" {
#   target_group_arn = aws_lb_target_group.ec2.arn
#   target_id        = local.target_id
#   port             = 80
# }


// TODO: 修正
# resource "aws_lb_listener_rule" "fixed_response" {
#   listener_arn = aws_lb_listener.alb_http_listener.arn

#   action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "これはHTTPです"
#       status_code  = "200"
#     }
#   }

#   condition {
#     path_pattern {
#       values = ["/test"]
#     }
#   }
# }

# resource "aws_lb_listener_rule" "health_check" {
#   listener_arn = aws_lb_listener.alb_http_listener.arn

#   action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "HEALTHY"
#       status_code  = "200"
#     }
#   }

#   condition {
#     query_string {
#       key   = "health"
#       value = "check"
#     }

#     query_string {
#       value = "bar"
#     }
#   }
# }

