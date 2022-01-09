variable "zone" {
  type    = string
  default = "powerfields-dev.io"
}

variable "random_suffix" {
  type = list(string)
  description = "because idk where these suffixes came from"
  default = [
  "nwkhwu",
  "jktha9"
  ]
}

variable "region" {
    default = "us-east-1"
}

variable "tags" {
    type = map(string)
}