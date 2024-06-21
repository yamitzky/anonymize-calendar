output "repository_id" {
  description = "The ID of the created Artifact Registry repository"
  value       = google_artifact_registry_repository.repository.id
}

output "repository_name" {
  description = "The name of the created Artifact Registry repository"
  value       = google_artifact_registry_repository.repository.name
}

output "repository_url" {
  description = "The URL of the created Artifact Registry repository"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository}"
}
