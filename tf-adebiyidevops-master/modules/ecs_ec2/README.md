## Summary

Terraform module to create ECS (EC2) resources.

## Usage

```
module "ecs_ec2" {
  source = "../modules/ecs_ec2"

  name = var.name_ecs
  tags = local.tags

  private_subnets   = module.application-vpc.private_subnets
  ecs_sg_id         = module.security_groups.ecs_sg_id
  target_group_arn  = module.alb.target_group_arns[0]
  container_name    = var.container_name_ecs
  container_port    = var.container_port_ecs
  desired_count     = var.desired_count_ecs
  ec2_instance_type = var.ec2_instance_type
  max_count_ec2     = var.max_count_ec2
  min_count_ec2     = var.min_count_ec2
  desired_count_ec2 = var.desired_count_ec2

  container_definitions = var.container_definitions

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the app. | `string` | n/a | yes |
| private\_subnets | The IDs of the Private Subnets. | `list(any)` | n/a | yes |
| ecs\_sg\_id | The Security Group ID for ECS. | `string` | n/a | yes |
| target\_group\_arn | The ARN of the Target Group. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| container\_name | The name of the container. | `string` | n/a | yes |
| container\_port | The Port number for the container to use. | `number` | n/a | yes |
| desired\_count | Desired number of tasks to run. | `number` | `1` | no |
| max\_count\_ec2 | Max number of ec2 to run. | `number` | `3` | no |
| min\_count\_ec2 | Minimum number of ec2 to run. | `number` | `2` | no |
| desired\_count\_ec2 | Desired number of ec2 to run. | `number` | `2` | no |
| ec2\_instance\_type | EC2 instance type to use. | `string` | `"t3.micro"` | no |
| container\_definitions | A list of valid container definitions provided as a single valid JSON document. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster\_arn | The Amazon Resource Name (ARN) that identifies the cluster. |
| ecs\_service\_cluster | Amazon Resource Name (ARN) of cluster which the service runs on. |
| ecs\_service\_id | ARN that identifies the service. |
| ecs\_service\_name | Name of the service. |
| ecs\_td\_arn | Full ARN of the Task Definition (including both family and revision) |
| ecs\_td\_family | The family of the Task Definition. |
| ecs\_td\_revision | The revision of the Task Definition. |
