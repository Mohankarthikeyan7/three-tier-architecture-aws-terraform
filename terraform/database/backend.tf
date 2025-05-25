terraform {
  backend "s3" {
    bucket = "carcierge-staging-aws-terraform"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
} 