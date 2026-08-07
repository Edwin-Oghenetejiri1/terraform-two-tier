variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the instance"
  type        = string
}


variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
}

variable "public_key_path" {
  description = "The path to the public key file for the key pair"
  type        = string
}

variable "env_prefix" {
  description = "The prefix for the environment"
  type        = string
}

