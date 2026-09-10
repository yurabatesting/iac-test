variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "network_name" {}
variable "subnet_name" {}
variable "subnet_ip_range" {}
variable "firewall_name" {}
variable "vm_name" {}
variable "machine_type" {}
variable "boot_disk_image" {}
variable "boot_disk_type" {}
variable "boot_disk_size" {}
variable "boot_disk_labels" {}
variable "desired_status" {}
variable "additional_disks" {}
variable "labels" {}

provider "google" {
  project = var.project_id
  region = var.region
}

# panggil modul networking
# module "networking" {
#   source = "../../modules/networking"
#   network_name = var.network_name
#   subnet_name = var.subnet_name
#   subnet_ip_range = var.subnet_ip_range
#   region = var.region
# }

# panggil modul firewall (ambil ID VPC dari module networking)
# module "firewall" {
#   source = "../../modules/firewall"
#   firewall_name = var.firewall_name
#   network_id = module.networking.network_id
# }

# panggil modul compute (ambil ID Subnet dari modul networking)
module "compute" {
  source = "../../modules/compute"
  vm_name = var.vm_name
  machine_type = var.machine_type
  zone = var.zone
  desired_status = var.desired_status

  # Lempar map disk tambahan
  # additional_disks = var.additional_disks

  boot_disk_image = var.boot_disk_image
  boot_disk_type = var.boot_disk_type
  boot_disk_size = var.boot_disk_size 
  boot_disk_labels = var.boot_disk_labels


  subnet_id = module.networking.subnet_id

  labels = var.labels
}

