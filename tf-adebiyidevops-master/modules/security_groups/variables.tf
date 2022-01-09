###############################################################################
# Variables - Security Groups
###############################################################################
variable "vpc_id" {
  description = "VPC id where the load balancer and other resources will be deployed."
  type        = string
  default     = null
}

variable "source_address_for_alb" {
  description = "(Optional) The address to allow to communicate with ALB."
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
