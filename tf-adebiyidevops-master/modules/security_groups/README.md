## Summary

Terraform module to create Security Groups

## Usage

```
module "security_groups" {
  source = "../modules/security_groups"

  vpc_id                 = module.vpc.vpc_id
  source_address_for_alb = var.source_address_for_alb

  tags = local.tags

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc\_id | VPC id where the load balancer and other resources will be deployed. | `string` | `null` | yes |
| source\_address\_for\_alb | (Optional) The address to allow to communicate with ALB. | `string` | `0.0.0.0/0` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |


## Outputs

| Name | Description |
|------|-------------|
| alb\_sg\_id | The ID of the ALB Security Group. |
| ecs\_sg\_id | The ID of the ECS Security Group. |
| rds\_sg\_id | The ID of the RDS Security Group. |
