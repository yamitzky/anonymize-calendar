module "cloudbuild" {
  source = "../modules/cloudbuild"

  github_owner               = var.github_owner
  github_repo                = var.github_repo
  github_branch              = var.github_branch
  project_id                 = var.project_id
  github_app_installation_id = var.github_app_installation_id
  region                     = var.region
  oauth_token_secret_name    = var.oauth_token_secret_name
}
