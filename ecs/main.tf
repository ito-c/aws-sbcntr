locals {
  project     = "sbcntr"
  environment = "NA"
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
            "awslogs-group" : "/ecs/{task-definition-name}",
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

  platform_version = "1.4.0"
  launch_type      = "FARGATE"
  cluster          = aws_ecs_cluster.backend.id
  task_definition  = aws_ecs_task_definition.backend.arn
  desired_count    = 2

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  tags = {
    Name        = "${local.project}-${local.environment}-esc-backend-service"
    Project     = local.project
    Environment = local.environment
  }
}
