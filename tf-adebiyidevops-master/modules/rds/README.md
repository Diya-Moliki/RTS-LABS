## Summary

This module creates the RDS Postgres and it's Security Group.

## Usage

```
module "rds" {
  source = "../modules/rds"

  private_subnets = local.private_subnets
  rds_sg_id       = module.security_groups.rds_sg_id

  db_identifier           = var.db_identifier
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_instance_class       = var.db_instance_class
  db_engine               = var.db_engine
  db_engine_version       = var.db_engine_version
  db_allocated_storage    = var.db_allocated_storage
  db_multi_az             = var.db_multi_az
  backup_retention_period = var.backup_retention_period
  storage_encrypted       = var.storage_encrypted
  skip_final_snapshot     = var.skip_final_snapshot
  tags                    = local.tags

}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| rds\_sg\_id | The Security Group ID for RDS. | `string` | n/a | yes |
| private\_subnets | The IDs of the Private Subnets. | `list(any)` | n/a | yes |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| db\_identifier | The name of the RDS instance. | `string` | n/a | yes |
| db\_name | The name of the database to create when the DB instance is created. | `string` | `null` | yes |
| db\_username | Username for the master DB user. | `string` | n/a | yes |
| db\_password | Password for the master DB user. | `string` | `""` | yes |
| db\_instance\_class | The instance type of the RDS instance. | `string` | n/a | yes |
| db\_engine | The database engine to use. | `string` | n/a | yes |
| db\_engine\_version | The engine version to use. | `string` | n/a | yes |
| db\_allocated\_storage | The amount of allocated storage. | `string` | n/a | yes |
| db_multi_az | Does the DB need multi-az for High Availability. | `bool` | `false` | no |
| backup_retention_period | The days to retain backups for. | `number` | `null` | no |
| storage_encrypted | Specifies whether the DB instance is encrypted. | `bool` | `true` | no |
| skip_final_snapshot | Determines whether a final DB snapshot is created before the DB instance is deleted. | `bool` | `true` | no |


## Outputs

| Name | Description |
|------|-------------|
| rds\_address | The hostname of the RDS instance. |
