data aws_caller_identity "this" {}

data terraform_remote_state "sg" {
  backend = "s3"
  config {
    bucket = "terraform-states-${data.aws_caller_identity.this.account_id}"
    key = "us-east-1/{{ environment }}/init/security_groups/terraform.tfstate"
    region = "us-east-1"
  }
}

{% for i in ip_list %}
resource "aws_security_group_rule" "grpc_ingress" {
  type              = "ingress"
  security_group_id = data.terraform_remote_state.sg.security_group_id
  cidr_blocks       = ["{{ i }}/32"]
  from_port         = 7100
  to_port           = 7100
  protocol          = "tcp"
}
{% endfor %}