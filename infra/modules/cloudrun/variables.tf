variable "service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "image" {
  type        = string
  description = "Docker image to deploy"
}

variable "region" {
  type        = string
  description = "Cloud Run region"
}
