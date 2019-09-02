variable "name" {}

variable "environment" {}

variable "terraform_state_region" {}

//variable "tags" {
//  type = "map"
//}

variable "subnet_ids" {
  type = "list"
}

variable "security_group_ids" {
  type = "list"
}