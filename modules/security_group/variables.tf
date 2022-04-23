variable "vpc_id" {}
variable "port" {}
variable "cidr_blocks" {
  description = "cidr blocks"
  type        = list(string)
  default     = ["Your Value Here"]
}
variable "is_specified_sg" {
  description = "whether or not given sg id"
  default     = false
}
variable "source_security_group_id" {
  description = "specify security group id"
  default     = "Your Value Here"
}
variable "resource" {
  description = "project name"
  type        = string
}
variable "project" {
  description = "project name"
  type        = string
}
variable "environment" {
  description = "environment"
  type        = string
}
