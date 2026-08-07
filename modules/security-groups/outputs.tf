output "compute_security_group_id" {
  description = "ID of the security group attached to the compute instance"
  value       = aws_security_group.compute.id
}

output "db_security_group_id" {
  description = "ID of the security group attached to the database instance"
  value       = aws_security_group.db.id
}