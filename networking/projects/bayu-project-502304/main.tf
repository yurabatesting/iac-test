variable "project_id" {}
variable "region" {}
variable "zone" {}
# variable "network_name" {}
# variable "subnet_name" {}
# variable "subnet_ip_range" {}
# variable "firewall_name" {}
variable "vpc" {}
variable "subnet" {}


provider "google" {
  project = var.project_id
  region = var.region
}

# panggil modul networking
module "vpc" {
  source = "../../modules/vpc"
  vpc = var.vpc
  region = var.region
  subnet = var.subnet
}

# # panggil modul firewall (ambil ID VPC dari module networking)
# module "firewall" {
#   source = "../../modules/firewall"
#   firewall_name = var.firewall_name
#   network_id = module.networking.network_id
# }