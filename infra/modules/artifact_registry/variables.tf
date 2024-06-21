variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "location" {
  description = "The location of the repository."
  type        = string
}

variable "repository" {
  description = "The name of the Artifact Registry repository to create."
  type        = string
}
