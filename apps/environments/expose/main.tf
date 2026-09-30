# ==============================================================================
# PROVIDER CONFIGURATION
# ==============================================================================
# Untuk mengunci version
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ==============================================================================
# DEKLARASI VARIABEL (Pengganti variables.tf)
# ==============================================================================
variable "project_id" {}
variable "region" {}
variable "lb_name" {}
variable "zone" {}
variable "domains" {}
variable "backends" {}
variable "existing_ip_address" {default = null}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ==============================================================================
# PEMANGGILAN MODUL LOAD BALANCER
# ==============================================================================
module "global_lb" {
  # Arahkan source ke folder modul yang sudah kita buat
  source = "../../modules/lb"

  # Melempar nilai dari .tfvars langsung ke dalam modul
  lb_name = var.lb_name
  zone    = var.zone
  domains = var.domains
  backends = var.backends
}

# ==============================================================================
# OUTPUT KELUARAN (Meneruskan dari modul ke layar terminal)
# ==============================================================================
output "ip_publik_lb" {
  value = module.global_lb.load_balancer_ip
}