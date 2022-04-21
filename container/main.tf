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
