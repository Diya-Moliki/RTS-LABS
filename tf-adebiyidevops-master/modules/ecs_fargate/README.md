## Summary

Terraform module to create ECS (Fargate) resources.

## Usage

```
module "ecs_cluster1" {
  source = "../modules/ecs_cluster"

  name = var.name_ecs_1
  tags = local.tags

  private_subnets  = local.private_subnets
  ecs_sg_id        = module.security_groups.ecs_sg_id
  target_group_arn = module.alb.target_group_arns[0]
  container_name   = var.container_name_ecs_1
  container_port   = var.container_port_ecs_1
  desired_count    = var.desired_count_ecs_1

  memory                = var.memory_ecs_1
  cpu                   = var.cpu_ecs_1
  task_role_arn         = module.iam.ecs_task_role_arn
  execution_role_arn    = module.iam.ecs_task_execution_role_arn
  container_definitions = var.container_definitions_ecs_1

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
| memory | The amount (in MiB) of memory used by the task. | `string` | `1024` | no |
| cpu | The number of cpu units used by the task. | `string` | `512` | no |
| task\_role\_arn | The ARN for the ECS task role. | `string` | n/a | yes |
| execution\_role\_arn | The ARN for the ECS task execution role. | `string` | n/a | yes |
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
