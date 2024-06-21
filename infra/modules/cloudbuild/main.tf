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
      args = ["build", "-t", "${var.registry_url}/app:$COMMIT_SHA", "."]
      dir  = "app"
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "${var.registry_url}/app:$COMMIT_SHA"]
      dir  = "app"
    }

    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
      entrypoint = "gcloud"
      args = [
        "run",
        "deploy",
        "${var.service_name}",
        "--platform",
        "managed",
        "--image",
        "${var.registry_url}/app:$COMMIT_SHA",
        "--region",
        "us-central1",
      ]
    }

    artifacts {
      images = ["${var.registry_url}/app:$COMMIT_SHA"]
    }
  }
}

resource "google_cloudbuildv2_repository" "my_repository" {
  name              = var.github_repo
  location          = var.region
  parent_connection = var.github_connection_id
  remote_uri        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
}
