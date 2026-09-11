variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "firewall" {}
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

# panggil modul firewall (ambil ID VPC dari module networking)
module "firewall" {
  source = "../../modules/firewall"
  firewall = var.firewall
  # network_id = module.networking.network_id

  available_vpc = module.vpc.vpc_names
  # INSTRUKSI PENTING: 
  # Paksa Terraform untuk menunggu modul networking selesai 100% 
  # sebelum mulai membangun modul firewall.
  depends_on = [module.vpc]
}