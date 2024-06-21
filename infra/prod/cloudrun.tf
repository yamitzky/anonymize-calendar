module "cloudrun" {
  source = "../modules/cloudrun"

  service_name = var.cloud_run_service_name
  image        = var.cloud_run_image
  region       = var.region
}
