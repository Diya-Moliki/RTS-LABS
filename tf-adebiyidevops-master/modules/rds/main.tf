###############################################################################
# RDS
###############################################################################
resource "aws_db_subnet_group" "subnet_group" {
  name        = "subnet_group"
  description = "Subnet Group for the PostgresDB"

  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "postgresdb" {
  identifier = var.db_identifier
  name       = var.db_name
  username   = var.db_username
  password   = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.subnet_group.id
  vpc_security_group_ids = [var.rds_sg_id]
  instance_class         = var.db_instance_class
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  storage_type           = "gp2"
  allocated_storage      = var.db_allocated_storage

  backup_retention_period = var.backup_retention_period
  storage_encrypted       = var.storage_encrypted
  skip_final_snapshot     = var.skip_final_snapshot
  multi_az                = var.db_multi_az
  tags                    = var.tags
}
