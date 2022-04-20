locals {
  project     = "sbcntr"
  environment = "NA"
  namePrefix  = "${local.project}-${local.environment}"
  tool        = "terraform"
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
    Name        = "${local.namePrefix}-ecr-backend"
    Project     = local.project
    Environment = local.environment
    Resource    = "ecr-backend"
    Tool        = local.tool
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
    Name        = "${local.namePrefix}-ecr-frontend"
    Project     = local.project
    Environment = local.environment
    Resource    = "ecr-frontend"
    Tool        = local.tool
  }
}
