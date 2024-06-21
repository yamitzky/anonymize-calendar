output "service_url" {
  value = module.cloudrun.service_url
}

output "artifact_registry_repository" {
  value = module.artifact_registry.repository_url
}
