terraform {
  backend "s3" {
    bucket = "carcierge-staging-aws-terraform"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
} 