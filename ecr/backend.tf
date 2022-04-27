terraform {
  backend "s3" {
    bucket = "tfstate-sbcntr"
    key    = "ecr/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
