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

module "security_group" {
  source = "./security_group"
}

module "elb" {
  source = "./elb"
}

#--------------------------------------------------
# ECS task def
#--------------------------------------------------

resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.project}-${local.environment}-esc-backend-def"
  requires_compatibilities = ["FARGATE"]
  memory                   = 1024
  cpu                      = 512
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode(
    [
      {
        "name" : "app",
        "image" : "776035328952.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1",
        "cpu" : 256,
        "memory" : 512,
        # 1つでもコンテナが落ちたら全コンテナを停止
        "essential" : true,
        "portMappings" : [
          {
            "containerPort" : 80,
            "hostPort" : 80,
          }
        ]
        # ルートファイルシステムへの読み取り専用アクセスを許可
        "readonlyRootFilesystem" : true,
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "${local.project}-${local.environment}-esc-log-group",
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "ecs",
          }
        }
      }
    ]
  )

  tags = {
    Name        = "${local.project}-${local.environment}-esc-backend-def"
    Project     = local.project
    Environment = local.environment
  }
}

# IAM
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.project}-${local.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_managed_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#--------------------------------------------------
# ECS cluster
#--------------------------------------------------

resource "aws_ecs_cluster" "backend" {
  name = "${local.project}-${local.environment}-esc-backend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${local.project}-${local.environment}-esc-backend-cluster"
    Project     = local.project
    Environment = local.environment
  }
}

#--------------------------------------------------
# ECS service
#--------------------------------------------------

resource "aws_ecs_service" "backend" {
  name = "${local.project}-${local.environment}-esc-backend-service"

  platform_version                  = "1.4.0"
  launch_type                       = "FARGATE"
  cluster                           = aws_ecs_cluster.backend.id
  task_definition                   = aws_ecs_task_definition.backend.arn
  desired_count                     = 2
  health_check_grace_period_seconds = 120

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  network_configuration {
    subnets = [
      module.network.private_container_1a_id,
      module.network.private_container_1c_id
    ]
    assign_public_ip = false
    security_groups  = [module.security_group_for_backend_service.security_group_id]
  }

  deployment_controller {
    // blue/greenのためCODE_DEPLOY
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = module.elb.tg_blue_arn
    container_name   = "app" # 変数化したい
    container_port   = 80
  }

  lifecycle {
    // 値がCodeDeployに依存するためignore_changes
    ignore_changes = [
      load_balancer,
      desired_count,
      task_definition,
    ]
  }

  tags = {
    Name        = "${local.project}-${local.environment}-esc-backend-service"
    Project     = local.project
    Environment = local.environment
  }
}

module "security_group_for_backend_service" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  use_name_prefix = false
  name            = "${local.project}-${local.environment}-sg-backend-service"
  description     = "security group for backend service"
  vpc_id          = module.network.vpc_id

  # 内部ロードバランサから通信を受ける
  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "ingress from internal alb"
      source_security_group_id = module.security_group.sg_internal_alb_id
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = ""
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "${local.project}-${local.environment}-sg-backend-service"
    Environment = local.environment
    Project     = local.project
  }
}
