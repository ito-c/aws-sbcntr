data "aws_lb_target_group" "blue" {
  tags = {
    Name = "sbcntr-NA-tg-blue"
  }
}

output "tg_blue_arn" {
  description = "arn of the tg of blue"
  value       = data.aws_lb_target_group.blue.arn
}
