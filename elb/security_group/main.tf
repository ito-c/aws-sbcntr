data "aws_security_group" "sg_public_management" {
  tags = {
    Name = "sbcntr-NA-sg-public-management"
  }
}

output "sg_public_management_id" {
  description = "id of the sg for public management"
  value       = data.aws_security_group.sg_public_management.id
}
