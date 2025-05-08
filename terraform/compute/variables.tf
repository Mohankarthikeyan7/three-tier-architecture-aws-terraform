variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "frontend_key_name" {
  description = "Name of the key pair to use for frontend EC2 instances"
  type        = string
}

variable "backend_key_name" {
  description = "Name of the key pair to use for backend EC2 instances"
  type        = string
}

# Frontend variables

variable "frontend_instance_type" {
  description = "Instance type for frontend instances"
  type        = string
  default     = "t3.micro"
}

variable "frontend_desired_capacity" {
  description = "Desired number of frontend instances"
  type        = number
  default     = 2
}

variable "frontend_max_size" {
  description = "Maximum number of frontend instances"
  type        = number
  default     = 4
}

variable "frontend_min_size" {
  description = "Minimum number of frontend instances"
  type        = number
  default     = 1
}

variable "backend_instance_type" {
  description = "Instance type for backend instances"
  type        = string
  default     = "t3.micro"
}

variable "backend_desired_capacity" {
  description = "Desired number of backend instances"
  type        = number
  default     = 2
}

variable "backend_max_size" {
  description = "Maximum number of backend instances"
  type        = number
  default     = 4
}

variable "backend_min_size" {
  description = "Minimum number of backend instances"
  type        = number
  default     = 1
}

# Terraform State Bucket
variable "terraform_state_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
} 