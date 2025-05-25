aws_region = "us-east-1"
environment = "dev"
project_name = "carcierge-staging-app"

# Key Pair
frontend_key_name = "frontend-key"
backend_key_name = "backend-key"

# Frontend Configuration
frontend_instance_type = "t3.micro"
frontend_desired_capacity = 2
frontend_max_size = 4
frontend_min_size = 1

# Backend Configuration
backend_instance_type = "t3.micro"
backend_desired_capacity = 2
backend_max_size = 4
backend_min_size = 1

# Terraform State Bucket
terraform_state_bucket = "carcierge-staging-aws-terraform" 