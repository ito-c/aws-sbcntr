locals {
  project     = "sbcntr"
  environment = "NA"
  namePrefix  = "${local.project}-${local.environment}"
}

#--------------------------------------------------
# VPC
#--------------------------------------------------

resource "aws_vpc" "sbcntr" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.namePrefix}-vpc"
    Project     = local.project
    Environment = local.environment
    Resource    = "vpc"
  }
}

#--------------------------------------------------
# Public subnet
#--------------------------------------------------

# ingress用
resource "aws_subnet" "public_ingress_1a" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 0)
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name        = "${local.namePrefix}-public-subnet-ingress-1a"
    Project     = local.project
    Environment = local.environment
    Resource    = "public-subnet-ingress-1a"
  }
}

resource "aws_subnet" "public_ingress_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name        = "${local.namePrefix}-public-subnet-ingress-1c"
    Project     = local.project
    Environment = local.environment
    Resource    = "public-subnet-ingress-1c"
  }
}

# 管理用
resource "aws_subnet" "public_management_1a" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 240)
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name        = "${local.namePrefix}-public-subnet-management-1a"
    Project     = local.project
    Environment = local.environment
    Resource    = "public-subnet-management-1a"
  }
}

resource "aws_subnet" "public_management_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 241)
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name        = "${local.namePrefix}-public-subnet-management-1c"
    Project     = local.project
    Environment = local.environment
    Resource    = "public-subnet-management-1c"
  }
}

# 管理用のセキュリティグループ(ec2へ移動の可能性あり)
module "sg_public_management" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  use_name_prefix = false
  name            = "${local.project}-${local.environment}-sg-public-management"
  description     = "security group for public-management"
  vpc_id          = aws_vpc.sbcntr.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "ingress"
      cidr_blocks = "0.0.0.0/0"
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
    Name        = "${local.project}-${local.environment}-sg-public-management"
    Environment = local.environment
    Project     = local.project
  }
}

resource "aws_internet_gateway" "sbcntr" {
  vpc_id = aws_vpc.sbcntr.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sbcntr.id

  tags = {
    Name        = "${local.namePrefix}-public-rtb"
    Project     = local.project
    Environment = local.environment
    Resource    = "public-rtb"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.sbcntr.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_ingress_1a" {
  subnet_id      = aws_subnet.public_ingress_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_ingress_1c" {
  subnet_id      = aws_subnet.public_ingress_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_management_1a" {
  subnet_id      = aws_subnet.public_management_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_management_1c" {
  subnet_id      = aws_subnet.public_management_1c.id
  route_table_id = aws_route_table.public.id
}

#--------------------------------------------------
# Private subnet
#--------------------------------------------------

# アプリケーション用
resource "aws_subnet" "private_container_1a" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 8)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name        = "${local.namePrefix}-private-subnet-container-1a"
    Project     = local.project
    Environment = local.environment
    Resource    = "private-subnet-container-1a"
  }
}

resource "aws_subnet" "private_container_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 9)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name        = "${local.namePrefix}-private-subnet-container-1c"
    Project     = local.project
    Environment = local.environment
    Resource    = "private-subnet-container-1c"
  }
}

# DB用
resource "aws_subnet" "private_db_1a" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 16)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name        = "${local.namePrefix}-private-subnet-db-1a"
    Project     = local.project
    Environment = local.environment
    Resource    = "private-subnet-db-1a"
  }
}

resource "aws_subnet" "private_db_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 17)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name        = "${local.namePrefix}-private-subnet-db-1c"
    Project     = local.project
    Environment = local.environment
    Resource    = "private-subnet-db-1c"
  }
}

# ECRのVPCエンドポイント用サブネット
resource "aws_subnet" "private_egress_1a" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 248)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name        = "${local.namePrefix}-private-egress-1a"
    Project     = local.project
    Environment = local.environment
    Resource    = "private-egress-1a"
  }
}

resource "aws_subnet" "private_egress_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 249)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name        = "${local.namePrefix}-private-egress-1c"
    Project     = local.project
    Environment = local.environment
    Resource    = "private-egress-1c"
  }
}

# VPCエンドポイント
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.sbcntr.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_egress_1a.id, aws_subnet.private_egress_1c.id]
  private_dns_enabled = true
  security_group_ids  = [module.security_group_for_vpc_endpoint.security_group_id]

  tags = {
    Name        = "${local.namePrefix}-vpce-ecr-api"
    Project     = local.project
    Environment = local.environment
    Resource    = "vpce-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.sbcntr.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_egress_1a.id, aws_subnet.private_egress_1c.id]
  private_dns_enabled = true
  security_group_ids  = [module.security_group_for_vpc_endpoint.security_group_id]

  tags = {
    Name        = "${local.namePrefix}-vpce-ecr-dkr"
    Project     = local.project
    Environment = local.environment
    Resource    = "vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.sbcntr.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_egress_1a.id, aws_subnet.private_egress_1c.id]
  private_dns_enabled = true
  security_group_ids  = [module.security_group_for_vpc_endpoint.security_group_id]

  tags = {
    Name        = "${local.namePrefix}-vpce-logs"
    Project     = local.project
    Environment = local.environment
    Resource    = "vpce-logs"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.sbcntr.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name        = "${local.namePrefix}-vpce-s3"
    Project     = local.project
    Environment = local.environment
    Resource    = "vpce-s3"
  }
}

# VPCエンドポイントのセキュリティグループ
module "security_group_for_vpc_endpoint" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  use_name_prefix = false
  name            = "${local.project}-${local.environment}-sg-vpc-endpoint"
  description     = "security group for vpc-endpoint"
  vpc_id          = aws_vpc.sbcntr.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "ingress"
      cidr_blocks = "0.0.0.0/0"
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
    Name        = "${local.project}-${local.environment}-sg-vpc-endpoint"
    Environment = local.environment
    Project     = local.project
  }
}

# ルートテーブル
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.sbcntr.id

  tags = {
    Name        = "${local.namePrefix}-private-rtb"
    Project     = local.project
    Environment = local.environment
    Resource    = "private-rtb"
  }
}

resource "aws_route_table_association" "private_container_1a" {
  subnet_id      = aws_subnet.private_container_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_container_1c" {
  subnet_id      = aws_subnet.private_container_1c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_1a" {
  subnet_id      = aws_subnet.private_db_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_1c" {
  subnet_id      = aws_subnet.private_db_1c.id
  route_table_id = aws_route_table.private.id
}
