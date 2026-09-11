variable "project_id" {}
variable "region" {}
variable "zone" {}
variable "vm_name" {}
variable "machine_type" {}
variable "boot_disk_image" {}
variable "boot_disk_type" {}
variable "boot_disk_size" {}
variable "boot_disk_labels" {}
variable "desired_status" {}
variable "additional_disks" {}
variable "labels" {}
variable "existing_subnet_name" {}

provider "google" {
  project = var.project_id
  region = var.region
}

# MENCARI JARINGAN EXISTING DI GCP
data "google_compute_subnetwork" "app_subnet" {
  # Masukkan nama subnet secara langsung atau via variabel
  name   = var.existing_subnet_name 
  region = var.region
}

# panggil modul compute (ambil ID Subnet dari modul networking)
module "compute" {
  source = "../../modules/compute"
  
  vm_name = var.vm_name
  machine_type = var.machine_type
  zone = var.zone
  desired_status = var.desired_status

  boot_disk_image = var.boot_disk_image
  boot_disk_type = var.boot_disk_type
  boot_disk_size = var.boot_disk_size 
  boot_disk_labels = var.boot_disk_labels

  # Lempar map disk tambahan
  additional_disks = var.additional_disks

  # INJEKSI JARINGAN EXISTING: Masukkan ID dari hasil pencarian data di atas
  subnet_id        = data.google_compute_subnetwork.app_subnet.id

  labels = var.labels
}

