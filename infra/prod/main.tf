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

  github_owner               = var.github_owner
  github_repo                = var.github_repo
  github_branch              = var.github_branch
  project_id                 = var.project_id
  github_app_installation_id = var.github_app_installation_id
  region                     = var.region
  oauth_token_secret_name    = var.oauth_token_secret_name
  registry_url               = module.artifact_registry.repository_url
}

module "cloudrun" {
  source = "../modules/cloudrun"

  service_name = var.service_name
  image        = module.cloudbuild.artifact_url
  region       = var.region
}
