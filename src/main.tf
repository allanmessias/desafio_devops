provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "hello_world" {
  ami           = "ami-071226ecf16aa7d96"  # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "allandev"

  tags = {
    Name = "HelloWorldServer"
  }
}