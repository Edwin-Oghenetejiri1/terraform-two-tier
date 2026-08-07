resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = var.db_allocated_storage
  storage_type            = var.db_storage_type
  db_name                  = var.db_name
  engine                   = var.db_engine
  engine_version           = var.db_engine_version
  instance_class           = var.db_instance_class
  username                 = var.db_username
  password                 = var.db_password
  parameter_group_name     = "default.mysql8.0"
  skip_final_snapshot      = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  tags = {
    Name = "${var.project_name}-db"
  }
}