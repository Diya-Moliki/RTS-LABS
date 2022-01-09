## Summary

Terraform code to create ECR, SG, ALB, RDS, IAM, and ECS EC2 resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | (Required) AWS Account ID. | string | n/a | yes |
| region | (Required) Region where resources will be created. | string | `ap-southeast-2` | yes |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `Development` | yes |

## Inputs for ECR module

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| encryption\_type | The encryption type to use for the repository. Valid values are `AES256` or `KMS` | `string` | `"AES256"` | no |
| image\_scanning\_configuration | Configuration block that defines image scanning configuration for the repository. By default, image scanning must be manually triggered. See the ECR User Guide for more information about image scanning. | `map` | `{}` | no |
| image\_tag\_mutability | The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. | `string` | `"MUTABLE"` | no |
| kms\_key | The ARN of the KMS key to use when encryption\_type is `KMS`. If not specified when encryption\_type is `KMS`, uses a new KMS key. Otherwise, uses the default AWS managed key for ECR. | `string` | n/a | no |
| lifecycle\_policy | Manages the ECR repository lifecycle policy | `string` | n/a | yes |
| name | Name of the repository. | `string` | n/a | yes |
| policy | Manages the ECR repository policy | `string` | n/a | yes |
| scan\_on\_push | Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false). | `bool` | `true` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| timeouts | Timeouts map. | `map` | `{}` | no |
| timeouts\_delete | How long to wait for a repository to be deleted. | `string` | n/a | no |

## Inputs for Security Groups

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc\_id | VPC id where the load balancer and other resources will be deployed. | `string` | `null` | yes |
| source\_address | (Optional) The address to allow to communicate with ALB. | `string` | `0.0.0.0/0` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Inputs for ALB

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_logs | Map containing access logging configuration for load balancer. | `map(string)` | `{}` | no |
| create\_lb | Controls if the Load Balancer should be created | `bool` | `true` | no |
| drop\_invalid\_header\_fields | Indicates whether invalid header fields are dropped in application load balancers. Defaults to false. | `bool` | `false` | no |
| enable\_cross\_zone\_load\_balancing | Indicates whether cross zone load balancing should be enabled in application load balancers. | `bool` | `false` | no |
| enable\_deletion\_protection | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| enable\_http2 | Indicates whether HTTP/2 is enabled in application load balancers. | `bool` | `true` | no |
| extra\_ssl\_certs | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate\_arn, https\_listener\_index (the index of the listener within https\_listeners which the cert applies toward). | `list(map(string))` | `[]` | no |
| http\_tcp\_listeners | A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index]) | `any` | `[]` | no |
| https\_listener\_rules | A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index]) | `any` | `[]` | no |
| https\_listeners | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to https\_listeners[count.index]) | `any` | `[]` | no |
| idle\_timeout | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| internal | Boolean determining if the load balancer is internal or externally facing. | `bool` | `false` | no |
| ip\_address\_type | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. | `string` | `"ipv4"` | no |
| lb\_tags | A map of tags to add to load balancer | `map(string)` | `{}` | no |
| listener\_ssl\_policy\_default | The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html). | `string` | `"ELBSecurityPolicy-2016-08"` | no |
| load\_balancer\_create\_timeout | Timeout value when creating the ALB. | `string` | `"10m"` | no |
| load\_balancer\_delete\_timeout | Timeout value when deleting the ALB. | `string` | `"10m"` | no |
| load\_balancer\_type | The type of load balancer to create. Possible values are application or network. | `string` | `"application"` | no |
| load\_balancer\_update\_timeout | Timeout value when updating the ALB. | `string` | `"10m"` | no |
| name | The resource name and Name tag of the load balancer. | `string` | `null` | no |
| name\_prefix | The resource name prefix and Name tag of the load balancer. Cannot be longer than 6 characters | `string` | `null` | no |
| security\_groups | The security groups to attach to the load balancer. e.g. ["sg-edcd9784","sg-edcd9785"] | `list(string)` | `[]` | no |
| subnet\_mapping | A list of subnet mapping blocks describing subnets to attach to network load balancer | `list(map(string))` | `[]` | no |
| subnets | A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f'] | `list(string)` | `null` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| target\_group\_tags | A map of tags to add to all target groups | `map(string)` | `{}` | no |
| target\_groups | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port | `any` | `[]` | no |
| vpc\_id | VPC id where the load balancer and other resources will be deployed. | `string` | `null` | no |

## Inputs for RDS Postgres

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

## Inputs for ECS (EC2)

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
| ecr\_arn | Full ARN of the repository |
| ecr\_name | The name of the repository. |
| ecr\_registry\_id | The registry ID where the repository was created. |
| ecr\_repository\_url | The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`) |
| alb\_sg\_id | The ID of the ALB Security Group. |
| ecs\_sg\_id | The ID of the ECS Security Group. |
| rds\_sg\_id | The ID of the RDS Security Group. |
| emr\_sg\_id | The ID of the EMR Security Group. |
| emr\_ms\_sg\_id | The ID of the EMR Managed Service Security Group. |
| http\_tcp\_listener\_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http\_tcp\_listener\_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https\_listener\_arns | The ARNs of the HTTPS load balancer listeners created. |
| https\_listener\_ids | The IDs of the load balancer listeners created. |
| target\_group\_arn\_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target\_group\_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target\_group\_attachments | ARNs of the target group attachment IDs. |
| target\_group\_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| this\_lb\_arn | The ID and ARN of the load balancer we created. |
| this\_lb\_arn\_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| this\_lb\_dns\_name | The DNS name of the load balancer. |
| this\_lb\_id | The ID and ARN of the load balancer we created. |
| this\_lb\_zone\_id | The zone\_id of the load balancer to assist with creating DNS records. |
| rds\_address | The hostname of the RDS instance. |
| ecs\_cluster\_arn | The Amazon Resource Name (ARN) that identifies the cluster. |
| ecs\_service\_cluster | Amazon Resource Name (ARN) of cluster which the service runs on. |
| ecs\_service\_id | ARN that identifies the service. |
| ecs\_service\_name | Name of the service. |
| ecs\_td\_arn | Full ARN of the Task Definition (including both family and revision) |
| ecs\_td\_family | The family of the Task Definition. |
| ecs\_td\_revision | The revision of the Task Definition. |
