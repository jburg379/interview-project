variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "custom_ip" {
  description = "IP address to ssh to the management EC2"
  type = string
}

variable "ami_id" {
  description = "aws linux ami for the EC2 instances"
  type = string
  default = "ami-0b6c6ebed2801a5cb"
  
}

variable "instance_type" {
  description = "instance type for the EC2 instances"
  type = string
  default = "t2.micro"
}

variable "key_name" {
  description = "key name for the aws key pair"
  type = string
  default = "project"
}