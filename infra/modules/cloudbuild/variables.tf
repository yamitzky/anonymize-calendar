variable "service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "github_connection_id" {
  type        = string
  description = "GitHub connection ID in Cloud Build"
}

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

variable "region" {
  type        = string
  description = "Cloud Run region"
}

variable "registry_url" {
  type        = string
  description = "Name of the Artifact Registry repository"
}
