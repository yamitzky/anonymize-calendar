resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      # Cloud Buildでデプロイするため、placeholderを指定しておく
      image = "us-docker.pkg.dev/cloudrun/container/placeholder"
      ports {
        container_port = 8000
      }

      env {
        name = "CALENDAR_SALT"
        value_source {
          secret_key_ref {
            secret  = var.calendar_salt_secret
            version = "latest"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }
}

resource "google_cloud_run_service_iam_binding" "noauth" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}
