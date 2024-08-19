provider "aws" {
  region = "eu-central-1"
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"
  instance_type = "t2.micro"
  ami = "ami-0e872aee57663ae2d"
}

resource "aws_eip" "elastic_ip1" {
  instance = module.ec2-instance.id
}



output "instance_ip_address" {
  value = ["Elastic IP:  ", aws_eip.elastic_ip1.public_ip]
}

output "from_module" {
  value = ["Instance IP:  ", module.ec2-instance.public_ip]
}

output "from_module2" {
  value = module.ec2-instance.id
} 

output "workspace" {
  value = format("Done from: %s workspace", local.workspace[terraform.workspace])
}

locals {
  workspace = {
    Space1 = "Space1"
    Space2 = "Space2"
  }
}
