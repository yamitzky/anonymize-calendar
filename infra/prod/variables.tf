variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "The name of the Cloud Run service and Artifact Registry repository"
  type        = string
  default     = "anonymize-calendar"
}

variable "github_owner" {
  description = "The GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "The GitHub branch to trigger builds from"
  type        = string
  default     = "^main$"
}

variable "github_connection_id" {
  description = "The ID of the GitHub connection in CloudBuild"
  type        = string
  default     = "github"
}

variable "calendar_salt_secret" {
  description = "Secret Manager secret ID for CALENDAR_SALT"
  type        = string
}
