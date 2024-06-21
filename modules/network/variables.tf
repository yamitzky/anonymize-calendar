# Variables for the network module

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
