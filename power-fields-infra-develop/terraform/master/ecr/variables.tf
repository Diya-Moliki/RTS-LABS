variable "environment" {}

variable "tags" { type = map(string) }
variable "name_prefix" {
    default = "powerfields"
}

variable hub_imgs {
    type = list(string)
    description = "Names of ECR repos for images to be imported from Docker Hub (manually)"
    default = []
}