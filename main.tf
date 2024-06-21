# Main Terraform configuration file

terraform {
  required_version = ">= 0.12"
}

module "network" {
  source = "./modules/network"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "compute" {
  source = "./modules/compute"

  environment = var.environment
  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.subnet_ids
}
