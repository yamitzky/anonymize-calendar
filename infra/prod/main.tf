# Production environment

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "artifact_registry" {
  source     = "../modules/artifact_registry"
  project_id = var.project_id
  location   = var.region
  repository = var.service_name
}

module "cloudbuild" {
  source = "../modules/cloudbuild"

  github_owner         = var.github_owner
  github_repo          = var.github_repo
  github_branch        = var.github_branch
  github_connection_id = var.github_connection_id
  project_id           = var.project_id
  region               = var.region
  service_name         = var.service_name
  registry_url         = module.artifact_registry.repository_url
}

module "cloudrun" {
  source = "../modules/cloudrun"

  service_name = var.service_name
  image        = module.cloudbuild.artifact_url
  region       = var.region
}
