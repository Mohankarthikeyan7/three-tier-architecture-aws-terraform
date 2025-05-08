output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.web_public[*].id
}

output "web_private_subnet_ids" {
  description = "List of web private subnet IDs"
  value       = aws_subnet.web_private[*].id
}

output "app_private_subnet_ids" {
  description = "List of app private subnet IDs"
  value       = aws_subnet.app_private[*].id
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "web_private_route_table_ids" {
  description = "List of web private route table IDs"
  value       = aws_route_table.web_private[*].id
}

output "app_private_route_table_ids" {
  description = "List of app private route table IDs"
  value       = aws_route_table.app_private[*].id
}

output "database_route_table_ids" {
  description = "List of database route table IDs"
  value       = aws_route_table.database[*].id
}

output "frontend_alb_sg_id" {
  description = "ID of the frontend ALB security group"
  value       = aws_security_group.frontend_alb.id
}

output "backend_alb_sg_id" {
  description = "ID of the backend ALB security group"
  value       = aws_security_group.backend_alb.id
}

output "frontend_sg_id" {
  description = "ID of the frontend instances security group"
  value       = aws_security_group.frontend.id
}

output "backend_sg_id" {
  description = "ID of the backend instances security group"
  value       = aws_security_group.backend.id
}

output "rds_sg_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}