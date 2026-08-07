variable "db_allocated_storage" {
  description = "Allocated storage for the DB instance (in GB)"
  type        = number
}

variable "db_storage_type" {
  description = "Storage type for the DB instance (e.g. gp2, gp3)"
  type        = string
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
}

variable "db_engine" {
  description = "Database engine (e.g. mysql, postgres)"
  type        = string
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the DB (e.g. db.t3.micro)"
  type        = string
}

variable "db_username" {
  description = "Master username for the DB"
  type        = string
}

variable "db_password" {
  description = "Master password for the DB"
  type        = string
  sensitive   = true
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID allowing access only from the compute SG"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
}
