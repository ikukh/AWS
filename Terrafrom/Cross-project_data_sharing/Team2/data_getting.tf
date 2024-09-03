resource "aws_security_group" "get_data_from_s3" {
  name = "Team2_gets_data_from_s3"
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  cidr_blocks       =  ["${data.terraform_remote_state.s3.outputs.eip_addr}/32"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.get_data_from_s3.id
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "test-terrafom-556621"
      key = "tfstate-files/terraform_data.tfstate"
      region = "eu-central-1"
  }
}