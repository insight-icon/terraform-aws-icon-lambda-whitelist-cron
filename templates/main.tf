data aws_caller_identity "this" {}

provider "aws" {
  version = "~> 2.2"

  region = var.aws_region

  # Make it faster by skipping some things
  skip_get_ec2_platforms = true
  skip_metadata_api_check = true
  skip_region_validation = true
  skip_requesting_account_id = true
}

terraform {
  backend "s3" {}
}

variable "terraform_state_bucket" {}
variable "group" {}
variable "aws_region" {}
variable "sg_name" {}

data terraform_remote_state "sg" {
  backend = "s3"
  config {
    bucket = "terraform-states-${data.aws_caller_identity.this.account_id}"
    key = "${var.aws_region}/${var.group}/sg/terraform.tfstate"
    region = var.aws_region
  }
}

resource "aws_security_group_rule" "grpc_ingress" {
type = "ingress"
security_group_id = data.terraform_remote_state.sg.security_group_id
cidr_blocks = [{% for i in ip_list %}"{{ i }}/32"{{ "," if not loop.last }}{% endfor %}]
from_port = 7100
to_port = 7100
protocol = "tcp"
}

output "id" {
  value = data.terraform_remote_state.sg.outputs
}