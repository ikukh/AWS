terraform {
    backend "s3" {
      bucket = "test-terrafom-556621"
      key = "tfstate-files/terraform_data.tfstate"
      region = "eu-central-1"
    }
}

resource "aws_eip" "ls" {
  domain = "vpc"
}

output "eip_addr" {
  value = aws_eip.ls.public_ip
}