# Variables for the root module

variable "environment" {
  description = "The deployment environment (dev or prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
