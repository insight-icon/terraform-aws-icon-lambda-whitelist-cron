provider "aws" {
  version = "~> 2.2"

  region = "${var.aws_region}"

  # Make it faster by skipping some things
  skip_get_ec2_platforms = true
  skip_metadata_api_check = true
  skip_region_validation = true
  skip_requesting_account_id = true
}

terraform {
  backend "s3" {}
}

variable "terraform_state_bucket"{}

variable "group"{}

variable "aws_region"{}

variable "name"{}


data terraform_remote_state "sg" {
  backend = "s3"
  config {
    bucket = "terraform-states-$${data.aws_caller_identity.this.account_id}"
    key = "us-east-1/${var.group}/sg/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group_rule" "grpc_ingress" {
  type = "ingress"
  security_group_id = data.terraform_remote_state.sg.security_group_id
  cidr_blocks = [
    "20.20.1.254/32",
    "20.20.1.210/32",
    "20.20.1.212/32",
    "20.20.1.20/32",
    "20.20.1.19/32"]
  from_port = 7100
  to_port = 7100
  protocol = "tcp"
}