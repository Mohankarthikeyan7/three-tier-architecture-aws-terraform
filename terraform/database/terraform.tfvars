aws_region = "us-east-1"
environment = "dev"
project_name = "carcierge-staging-app"

# Database Configuration
db_instance_class   = "db.t3.micro"
db_engine           = "postgres"
db_engine_version   = "15.5"
db_name             = "appdb"
db_username         = "admin"
db_password         = "G0R0cks$$"
db_allocated_storage = 20
db_storage_type     = "gp3"


# Terraform State Bucket
terraform_state_bucket = "carcierge-staging-aws-terraform" 