variable "name" {}
variable "group" {}
variable "environment" {}
variable "key" {}
variable "lock_table" {}
variable "sg_name" {}

variable "terraform_state_bucket" {}

//variable "tags" {
//  type = "map"
//}

variable "subnet_ids" {
  type = "list"
}

variable "security_group_ids" {
  type = "list"
}