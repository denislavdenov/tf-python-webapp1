variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "instance_type" {}

variable "subnet_id" {}

variable "security_group_id" {
  type = "list"
}

variable "region" {
  description = "Default AWS region"
  default     = "us-east-1"
}

variable "ami" {}

variable "webappip" {
  default = "172.31.16.10"
}

variable "dbip" {
  default = "172.31.16.20"
}