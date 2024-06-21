data "google_project" "project" {
}

resource "google_cloudbuild_trigger" "main_branch_trigger" {
  name        = "main-branch-trigger"
  description = "Trigger for main branch pushes"

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = var.github_branch
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  build {
    images = ["${var.registry_url}/app:$COMMIT_SHA"]

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "${var.registry_url}/app:$COMMIT_SHA", "./app"]
    }

    artifacts {
      images = ["${var.registry_url}/app:$COMMIT_SHA"]
    }
  }
}

data "google_iam_policy" "serviceagent_secretAccessor" {
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  }
}

resource "google_cloudbuildv2_connection" "github_connection" {
  name     = "github-connection"
  location = var.region

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = "projects/${var.project_id}/secrets/${var.oauth_token_secret_name}/versions/latest"
    }
  }
}

resource "google_cloudbuildv2_repository" "my_repository" {
  name              = var.github_repo
  location          = var.region
  parent_connection = google_cloudbuildv2_connection.github_connection.id
  remote_uri        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
}
