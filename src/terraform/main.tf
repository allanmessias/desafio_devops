terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

# Using environment variables to connect to aws provider through our IaC code.
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Creating our vpc
resource "aws_vpc" "ascan_challenge_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Creating public subnet
resource "aws_subnet" "ascan_challenge_public_subnet" {
  vpc_id                  = aws_vpc.ascan_challenge_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Creating a gateway for internet access
resource "aws_internet_gateway" "ascan_challenge_gw" {
  vpc_id = aws_vpc.ascan_challenge_vpc.id
}

# Create route table
resource "aws_route_table" "public_ascan_challenge_rt" {
  vpc_id = aws_vpc.ascan_challenge_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ascan_challenge_gw.id
  }
}

# Route table association
resource "aws_route_table_association" "public_assoc" {
  subnet_id       = aws_subnet.ascan_challenge_public_subnet.id
  route_table_id  = aws_route_table.public_ascan_challenge_rt.id
}

# Creating security group
resource "aws_security_group" "ascan_challenge_sg" {
  vpc_id = aws_vpc.ascan_challenge_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my_key" {
  key_name    = "my_key"
  public_key  = file("${var.ssh_dir}/allandev.pub")
}


resource "aws_instance" "ascan_challenge_server" {
  ami                         = "ami-071226ecf16aa7d96"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ascan_challenge_server_profile.name
  subnet_id                   = aws_subnet.ascan_challenge_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ascan_challenge_sg.id]
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true
  user_data                   = file("../../start_up.sh")
  tags = {
    Name = "Terraform-EC2-Docker"
  }
}

# Creates the repository for the image
resource "aws_ecr_repository" "ascan_challenge_repo" {
  name                 = "ascan_challenge_repo"
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Creates the IAM role for the EC2 to access the repo 
resource "aws_iam_role" "ascan_challenge_server_role" {
  name = "ec2_ecr_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action     = "sts:AssumeRole"
      Effect     = "Allow"
      Principal  = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ascan_challenge_access" {
  role       = aws_iam_role.ascan_challenge_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attaching the role to the aws instance 
resource "aws_iam_instance_profile" "ascan_challenge_server_profile" {
  name       = "ascan_challenge_ecr_profile"
  role       = aws_iam_role.ascan_challenge_server_role.name
}

resource "aws_eip" "eip" {
  instance = aws_instance.ascan_challenge_server.id
}


output "server_ip" {
  value = aws_eip.eip.public_ip
}





