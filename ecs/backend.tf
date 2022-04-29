terraform {
  backend "s3" {
    bucket = "tfstate-sbcntr"
    key    = "ecs/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
