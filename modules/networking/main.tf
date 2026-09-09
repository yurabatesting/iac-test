# membuat VPC tanpa subnet otomatis
resource "google_compute_network" "vpc" {
  name = var.network_name
  auto_create_subnetworks = false 
}

# membuat subnet di dalam vpc
resource "google_compute_subnetwork" "subnet" {
  name = var.subnet_name
  ip_cidr_range = var.subnet_ip_range
  region = var.region
  network = google_compute_network.vpc.id
}
