provider "aws" {
  region = var.region
}

variable "region" {
  default = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "description"
    values = ["Canonical, Ubuntu, 24.04 LTS, amd64 noble image build on*"]
  }
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"
}

/* get ami-071de147bf3f27475 shold be ami-0e872aee57663ae2d */