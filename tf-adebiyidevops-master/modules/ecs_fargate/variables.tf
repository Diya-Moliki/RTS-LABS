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

variable "memory" {
  description = "The amount (in MiB) of memory used by the task."
  type        = string
  default     = "1024"
}

variable "cpu" {
  description = "The number of cpu units used by the task."
  type        = string
  default     = "512"
}

variable "task_role_arn" {
  description = "The ARN for the ECS task role."
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN for the ECS task execution role."
  type        = string
}

variable "container_definitions" {
  description = "A list of valid container definitions provided as a single valid JSON document."
}
