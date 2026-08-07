output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance - use this to view the webpage"
  value       = module.compute.instance_public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = module.compute.instance_public_dns
}

output "db_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = module.database.db_endpoint
  sensitive   = true
}