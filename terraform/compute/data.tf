data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "network/terraform.tfstate"
    region = var.aws_region
  }
}

# RDS Data Source
data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "database/terraform.tfstate"
    region = var.aws_region
  }
}

data "local_file" "frontend_ami" {
  filename = "${path.module}/ami_ids/frontend_ami.txt"
}

data "local_file" "backend_ami" {
  filename = "${path.module}/ami_ids/backend_ami.txt"
}

locals {
  frontend_ami_id = trimspace(data.local_file.frontend_ami.content)
  backend_ami_id  = trimspace(data.local_file.backend_ami.content)
} 