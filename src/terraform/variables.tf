variable "aws_access_key" {
  description = "AWS ACCESS KEY"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS SECRET KEY"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS REGION"
  type        = string
  default     = "us-east-1"
}

variable "ssh_dir" {
  type    = string
  default = "/home/allan/.ssh"
}
