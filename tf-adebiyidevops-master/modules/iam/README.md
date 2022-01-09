## Summary

Terraform module to create IAM resources required for ECS.

## Usage

```
module "iam" {

  source = "../modules/iam"

  tags = local.tags

}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_task\_execution\_role\_arn | The ARN for the ECS task execution role. |
| ecs\_task\_role\_arn | The ARN for the ECS task role. |
