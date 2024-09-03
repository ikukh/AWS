provider "aws" {
  region = "eu-central-1"  # This AMI is for eu-central-1, change if using a different region
}

# VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "kubernetes-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "kubernetes-igw"
  }
}

# Subnets
resource "aws_subnet" "k8s_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "kubernetes-subnet-${count.index + 1}"
  }
}

# Route Table
resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name = "kubernetes-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "k8s_rta" {
  count          = 2
  subnet_id      = aws_subnet.k8s_subnet[count.index].id
  route_table_id = aws_route_table.k8s_rt.id
}

# Security Group for Master
resource "aws_security_group" "k8s_master_sg" {
  name        = "k8s-master-sg"
  description = "Security group for Kubernetes master"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes-master-sg"
  }
}

# Security Group for Workers
resource "aws_security_group" "k8s_worker_sg" {
  name        = "k8s-worker-sg"
  description = "Security group for Kubernetes workers"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.k8s_master_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes-worker-sg"
  }
}

# EC2 Instance for Master
resource "aws_instance" "k8s_master" {
  ami           = "ami-0e872aee57663ae2d"  # Ubuntu 20.04 LTS AMI ID for us-west-2
  instance_type = "t2.micro"
  key_name      = "Akey"  # Change this to your key pair

  vpc_security_group_ids = [aws_security_group.k8s_master_sg.id]
  subnet_id              = aws_subnet.k8s_subnet[0].id

  user_data = file("master-userdata.sh")

  tags = {
    Name = "kubernetes-master"
  }
}

# EC2 Instances for Workers
resource "aws_instance" "k8s_workers" {
  count         = 2
  ami           = "ami-0e872aee57663ae2d"  # Ubuntu 20.04 LTS AMI ID for us-west-2
  instance_type = "t2.micro"
  key_name      = "Akey"  # Change this to your key pair

  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id]
  subnet_id              = aws_subnet.k8s_subnet[count.index % 2].id

  user_data = file("worker-userdata.sh")

  tags = {
    Name = "kubernetes-worker-${count.index + 1}"
  }
}

# Output
output "master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_public_ips" {
  value = aws_instance.k8s_workers[*].public_ip
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}