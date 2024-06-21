variable "github_owner" {
  type        = string
  description = "GitHub repository owner"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch to trigger builds"
  default     = "^main$"
}

variable "project_id" {
  type        = string
  description = "Google Cloud project ID"
}

variable "github_app_installation_id" {
  type        = number
  description = "GitHub App installation ID"
}

variable "region" {
  type        = string
  description = "Cloud Run region"
}

variable "oauth_token_secret_name" {
  type        = string
  description = "The version of the OAuth token secret in Secret Manager"
}
