variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for the public subnets (one per AZ)"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for the private subnets (one per AZ)"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones to spread the subnets across"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC to attach networking resources to"
  type        = string
}