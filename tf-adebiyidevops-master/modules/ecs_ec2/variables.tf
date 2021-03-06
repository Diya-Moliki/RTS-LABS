###############################################################################
# Variables - ECS
###############################################################################
variable "name" {
  description = "Name of the app."
  type        = string
}

variable "private_subnets" {
  description = "The IDs of the Private Subnets."
  type        = list(any)
}

variable "ecs_sg_id" {
  description = "The Security Group ID for ECS."
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the Target Group."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "container_name" {
  description = "The name of the container."
  type        = string
}

variable "container_port" {
  description = "The Port number for the container to use."
  type        = number
}

variable "desired_count" {
  description = "Desired number of tasks to run."
  type        = number
  default     = 1
}

variable "max_count_ec2" {
  description = "Max number of ec2 to run."
  type        = number
  default     = 3
}

variable "min_count_ec2" {
  description = "Minimum number of ec2 to run."
  type        = number
  default     = 2
}

variable "desired_count_ec2" {
  description = "Desired number of ec2 to run."
  type        = number
  default     = 2
}

variable "ec2_instance_type" {
  description = "EC2 instance type to use."
  type        = string
  default     = "t3.micro"
}

variable "container_definitions" {
  description = "A list of valid container definitions provided as a single valid JSON document."
}
