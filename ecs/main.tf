locals {
  project     = "sbcntr"
  environment = "NA"
}

#--------------------------------------------------
# ECS
#--------------------------------------------------

resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.project}-${local.environment}-backend"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
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
    Name        = "${local.project}-${local.environment}-esc-backend"
    Project     = local.project
    Environment = local.environment
  }
}
