variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "network_name" {}
variable "subnet_name" {}
variable "subnet_ip_range" {}
variable "firewall_name" {}
variable "vm_name" {}
variable "machine_type" {}

provider "google" {
  project = var.project_id
  region = var.region
}

# panggil modul networking
module "networking" {
  source = "../../modules/networking"
  network_name = var.network_name
  subnet_name = var.subnet_name
  subnet_ip_range = var.subnet_ip_range
  region = var.region
}

# panggil modul firewall (ambil ID VPC dari module networking)
module "firewall" {
  source = "../../modules/firewall"
  firewall_name = var.firewall_name
  network_id = module.networking.network_id
}

# panggil modul compute (ambil ID Subnet dari modul networking)
module "compute" {
  source = "../../modules/compute"
  vm_name = var.vm_name
  machine_type = var.machine_type
  zone = var.zone
  subnet_id = module.networking.subnet_id
}