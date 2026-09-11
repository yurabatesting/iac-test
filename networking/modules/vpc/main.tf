# membuat VPC tanpa subnet otomatis
resource "google_compute_network" "vpc" {
  for_each = var.vpc
  name                    = each.value.vpc_name
  auto_create_subnetworks = each.value.auto_create_subnetworks
}

# membuat subnet di dalam vpc
resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnet
  name = each.value.subnet_name
  ip_cidr_range = each.value.subnet_ip_range
  region = var.region
  network = google_compute_network.vpc[each.value.vpc_key].id
}
