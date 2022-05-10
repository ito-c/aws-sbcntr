data "aws_resourcegroupstaggingapi_resources" "tg_blue" {
  # 何故か複数リソースが見つかってしまうため、tag_filterで代用
  # See: https://github.com/hashicorp/terraform-provider-aws/issues/12265#issuecomment-833361834
  # tags = {
  #   Name = "sbcntr-NA-tg-blue"
  # }

  tag_filter {
    key    = "Name"
    values = ["sbcntr-NA-tg-blue"]
  }
}

output "tg_blue_arn" {
  description = "arn of the tg of blue"
  value       = data.aws_resourcegroupstaggingapi_resources.tg_blue.resource_tag_mapping_list[0].resource_arn
}
