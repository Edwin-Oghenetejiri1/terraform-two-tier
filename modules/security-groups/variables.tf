variable "my_ip_cidr_block" {
  description = "The CIDR block for your IP address"
  type        = string
}

variable "env_prefix" {
  description = "The prefix for the environment"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}