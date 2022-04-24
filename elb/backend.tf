terraform {
  backend "s3" {
    bucket = "tfstate-sbcntr"
    key    = "elb/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
