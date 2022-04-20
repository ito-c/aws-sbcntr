terraform {
  backend "s3" {
    bucket = "tfstate-sbcntr"
    key    = "container/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
