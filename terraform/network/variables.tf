variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_public_subnets" {
  description = "CIDR blocks for web public subnets"
  type        = list(string)
}

variable "web_private_subnets" {
  description = "CIDR blocks for web private subnets"
  type        = list(string)
}

variable "app_private_subnets" {
  description = "CIDR blocks for app private subnets"
  type        = list(string)
}

variable "database_subnets" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
} 