variable "environment" {}
variable "zone" {}
variable "application_name" {}
variable "zone_id" {}
variable "tags" {
    type = map(string)
}
variable "rts_ips" {
    type = list(string)
    default = [
      "71.176.216.118/32",
      "52.70.46.182/32"
    ]
}