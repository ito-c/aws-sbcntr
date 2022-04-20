terraform {
  backend "s3" {
    bucket = "tfstate-sbcntr"
    key    = "network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
