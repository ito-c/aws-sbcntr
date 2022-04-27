locals {
  project     = "sbcntr"
  environment = "NA"
}

#--------------------------------------------------
# ECR
#--------------------------------------------------

resource "aws_ecr_repository" "sbcntr_backend" {
  name                 = "sbcntr-backend"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name        = "${local.project}-${local.environment}-ecr-backend"
    Project     = local.project
    Environment = local.environment
  }
}

resource "aws_ecr_repository" "sbcntr_frontend" {
  name                 = "sbcntr-frontend"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name        = "${local.project}-${local.environment}-ecr-frontend"
    Project     = local.project
    Environment = local.environment
  }
}

data "aws_iam_policy_document" "codedeploy_assumerole" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_code_deploy" {
  name               = "${local.project}-${local.environment}-ecs-code-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assumerole.json

  tags = {
    Name        = "${local.project}-${local.environment}-ecs-code-deploy-role"
    Project     = local.project
    Environment = local.environment
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.ecs_code_deploy.id
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
