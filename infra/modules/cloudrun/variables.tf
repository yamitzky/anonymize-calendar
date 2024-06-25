variable "service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "region" {
  type        = string
  description = "Cloud Run region"
}

variable "calendar_salt_secret" {
  type        = string
  description = "Secret Manager secret ID for CALENDAR_SALT"
}
