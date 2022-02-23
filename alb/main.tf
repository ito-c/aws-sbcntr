terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws = ">= 3.37.0"
  }
  backend "s3" {
    bucket = "tfstate-terraform-template"
    key    = "alb/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

locals {
  namePrefix  = "terraform-template-dev"
  projectName = "terraform-template"
  environment = "dev"
  toolName    = "terraform"
}

#--------------------------------------------------
# Data only Modules
#--------------------------------------------------

module "network" {
  source = "./network"
}

# data "terraform_remote_state" "network" {
#   backend = "s3"

#   config = {
#     bucket = "tfstate-terraform-study"
#     key    = "network/terraform.tfstate"
#     region = "ap-northeast-1"
#   }
# }

# data "terraform_remote_state" "s3" {
#   backend = "s3"

#   config = {
#     bucket = "tfstate-terraform-study"
#     key    = "s3/terraform.tfstate"
#     region = "ap-northeast-1"
#   }
# }

#--------------------------------------------------
# Securiry Group
#--------------------------------------------------

module "security_group_for_alb" {
  source = "../modules/security_group"
  # vpc_id      = data.terraform_remote_state.network.outputs.terraform_study_vpc_id
  vpc_id      = module.network.vpc_id
  port        = "80"
  cidr_blocks = ["0.0.0.0/0"]

  environment   = local.environment
  project_name  = local.projectName
  resource_name = "alb"
  tool_name     = local.toolName
}


#--------------------------------------------------
# ALB
#--------------------------------------------------

data "aws_s3_bucket" "alb_log" {
  tags = {
    ProjectName  = "terraform-template"
    Environment  = "dev"
    ResourceName = "alb-log-bucket"
  }
}

resource "aws_lb" "alb" {
  name                       = "${local.namePrefix}-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    module.network.public_subnet_1a_id,
    module.network.public_subnet_1c_id,
    # data.terraform_remote_state.network.outputs.terraform_study_subnet_public_0_id,
    # data.terraform_remote_state.network.outputs.terraform_study_subnet_public_1_id
  ]

  access_logs {
    # bucket  = data.terraform_remote_state.s3.outputs.alb_log_id
    bucket  = module.aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.security_group_for_alb.security_group_id
  ]

  tags = {
    Name         = "${local.namePrefix}-alb"
    Environment  = local.environment
    ProjectName  = local.projectName
    ResourceName = "alb"
    Tool         = local.toolName
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "これはHTTPです"
      status_code  = "200"
    }
  }
}
