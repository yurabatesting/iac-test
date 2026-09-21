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

# ------------------------------------------------------------------------
# BLOK PRIVATE SERVICES ACCESS (PSA)
# ------------------------------------------------------------------------

# Meratakan (flatten) daftar PSA dari seluruh VPC untuk diiterasi
locals {
  psa_list = flatten([
    for vpc_key, vpc_val in var.vpc : [
      for psa in vpc_val.psa_ranges : {
        vpc_key       = vpc_key
        range_name    = psa.name
        address       = psa.address
        prefix_length = psa.prefix_length
      }
    ]
  ])
}

# 1. Mengalokasikan IP (Mendukung pembuatan multiple IP dan manual IP)
resource "google_compute_global_address" "psa_range" {
  for_each = { for item in local.psa_list : "${item.vpc_key}-${item.range_name}" => item }

  name          = each.value.range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = google_compute_network.vpc[each.value.vpc_key].id

  # Memasukkan rentang IP manual jika didefinisikan
  address       = each.value.address
  prefix_length = each.value.prefix_length
}

# 2. Membuat 1 koneksi peering per VPC ke Google Services
resource "google_service_networking_connection" "private_vpc_connection" {
  # Hanya eksekusi pada VPC yang memiliki konfigurasi psa_ranges
  for_each = { for k, v in var.vpc : k => v if length(v.psa_ranges) > 0 }

  network                 = google_compute_network.vpc[each.key].id
  service                 = "servicenetworking.googleapis.com"
  
  # Mengambil semua nama range IP yang ada di VPC ini dan menggabungkannya
  reserved_peering_ranges = [for psa in each.value.psa_ranges : psa.name]

  depends_on = [google_compute_global_address.psa_range]
}