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

variable "github_app_installation_id" {
  description = "The GitHub App installation ID"
  type        = number
}

variable "oauth_token_secret_name" {
  description = "The version of the OAuth token secret in Secret Manager"
  type        = string
  default     = "github-token"
}
