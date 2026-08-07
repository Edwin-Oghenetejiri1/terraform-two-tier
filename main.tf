module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr_block = var.vpc_cidr_block
  vpc_name       = var.vpc_name
}

module "networking" {
  source = "./modules/networking"

  vpc_id                     = module.vpc.vpc_id
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  azs                        = var.azs
}

module "security_groups" {
  source = "./modules/security-groups"

  vpc_id           = module.vpc.vpc_id
  my_ip_cidr_block = var.my_ip_cidr_block
  env_prefix       = var.env_prefix
}

module "compute" {
  source = "./modules/compute"

  instance_type     = var.instance_type
  key_name          = var.key_name
  public_key_path   = var.public_key_path
  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.security_groups.compute_security_group_id
  env_prefix        = var.env_prefix
}

module "database" {
  source = "./modules/database"

  db_allocated_storage  = var.db_allocated_storage
  db_storage_type       = var.db_storage_type
  db_name               = var.db_name
  db_engine             = var.db_engine
  db_engine_version     = var.db_engine_version
  db_instance_class     = var.db_instance_class
  db_username           = var.db_username
  db_password           = var.db_password
  private_subnet_ids    = module.networking.private_subnet_ids
  db_security_group_id  = module.security_groups.db_security_group_id
  project_name          = var.env_prefix
}