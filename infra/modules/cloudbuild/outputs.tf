output "artifact_url" {
  value = google_cloudbuild_trigger.main_branch_trigger.build[0].artifacts[0].images[0]
}
