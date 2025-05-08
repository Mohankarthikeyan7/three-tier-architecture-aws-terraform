output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = data.terraform_remote_state.network.outputs.rds_sg_id
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "rds_username" {
  description = "The master username for the RDS instance"
  value       = aws_db_instance.main.username
}

output "rds_password" {
  description = "The master password for the RDS instance"
  value       = aws_db_instance.main.password
  sensitive   = true
} 