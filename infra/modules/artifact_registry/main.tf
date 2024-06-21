resource "google_artifact_registry_repository" "repository" {
  location      = var.location
  repository_id = var.repository
  description   = "Docker repository for ${var.repository}"
  format        = "DOCKER"

  project = var.project_id
}
