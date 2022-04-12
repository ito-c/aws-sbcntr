terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws = ">= 3.37.0"
  }
  backend "s3" {
    bucket = "tfstate-sbcntr"
    key    = "network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

locals {
  projectName = "sbcntr"
  environment = "NA"
  namePrefix  = "${local.projectName}-${local.environment}"
  toolName    = "terraform"
}

#--------------------------------------------------
# VPC
#--------------------------------------------------

resource "aws_vpc" "sbcntr" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name         = "${local.namePrefix}-vpc"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "vpc"
    Tool         = local.toolName
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
    Name         = "${local.namePrefix}-public-subnet-ingress-1a"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "public-subnet-ingress-1a"
    Tool         = local.toolName

  }
}

resource "aws_subnet" "public_ingress_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name         = "${local.namePrefix}-public-subnet-ingress-1c"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "public-subnet-ingress-1c"
    Tool         = local.toolName
  }
}

# 管理用

resource "aws_subnet" "private_management_1a" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 240)
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name         = "${local.namePrefix}-public-subnet-management-1a"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "public-subnet-management-1a"
    Tool         = local.toolName
  }
}

resource "aws_subnet" "private_management_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 241)
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name         = "${local.namePrefix}-public-subnet-management-1c"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "public-subnet-management-1c"
    Tool         = local.toolName
  }
}

resource "aws_internet_gateway" "sbcntr" {
  vpc_id = aws_vpc.sbcntr.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sbcntr.id

  tags = {
    Name         = "${local.namePrefix}-public-rtb"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "public-rtb"
    Tool         = local.toolName
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

resource "aws_route_table_association" "private_management_1a" {
  subnet_id      = aws_subnet.private_management_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_management_1c" {
  subnet_id      = aws_subnet.private_management_1c.id
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
    Name         = "${local.namePrefix}-private-subnet-container-1a"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "private-subnet-container-1a"
    Tool         = local.toolName
  }
}

resource "aws_subnet" "private_container_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 9)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name         = "${local.namePrefix}-private-subnet-container-1c"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "private-subnet-container-1c"
    Tool         = local.toolName
  }
}

# DB用

resource "aws_subnet" "private_db_1a" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 16)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name         = "${local.namePrefix}-private-subnet-db-1a"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "private-subnet-db-1a"
    Tool         = local.toolName
  }
}

resource "aws_subnet" "private_db_1c" {
  vpc_id                  = aws_vpc.sbcntr.id
  cidr_block              = cidrsubnet(aws_vpc.sbcntr.cidr_block, 8, 17)
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name         = "${local.namePrefix}-private-subnet-db-1c"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "private-subnet-db-1c"
    Tool         = local.toolName
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.sbcntr.id

  tags = {
    Name         = "${local.namePrefix}-private-rtb"
    ProjectName  = local.projectName
    Environment  = local.environment
    ResourceName = "private-rtb"
    Tool         = local.toolName
  }
}

# デフォルトでローカルを向いているのでルートの追加は不要？

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
