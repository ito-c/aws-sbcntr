data "aws_security_group" "sg_internal_alb" {
  tags = {
    Name = "sbcntr-NA-sg-internal-alb"
  }
}

output "sg_internal_alb_id" {
  description = "id of the sg for internal alb"
  value       = data.aws_security_group.sg_internal_alb.id
}
