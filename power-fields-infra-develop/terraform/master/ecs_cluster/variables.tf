variable "environment" {}

variable "tags" { type = map(string) }
variable "application_name" {
    default = "pf"
}
