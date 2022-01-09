variable "application_name" {
  default = "pf"
}

variable "client_name" {
  default = "rts"
}

variable "environment" {}

variable "tags" { type = map(string) }

variable "mfa_delete" {
  description = "Whether only root can delete the bucket. Should always be true in uat and prod. Can be set to false in lower envs."
  default     = true
  type        = bool
}

variable "public_files" {
  default = ""
  type    = string
}