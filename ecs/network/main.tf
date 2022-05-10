data "aws_vpc" "this" {
  tags = {
    Name = "sbcntr-NA-vpc"
  }
}

data "aws_subnet" "private_container_1a" {
  tags = {
    Name = "sbcntr-NA-private-subnet-container-1a"
  }
}

data "aws_subnet" "private_container_1c" {
  tags = {
    Name = "sbcntr-NA-private-subnet-container-1c"
  }
}

output "vpc_id" {
  description = "id of the vpc."
  value       = data.aws_vpc.this.id
}

output "private_container_1a_id" {
  description = "id of the private subnet 1a"
  value       = data.aws_subnet.private_container_1a.id
}

output "private_container_1c_id" {
  description = "id of the private subnet 1c"
  value       = data.aws_subnet.private_container_1c.id
}
