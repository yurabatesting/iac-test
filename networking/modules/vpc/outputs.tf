# Mengeluarkan daftar nama VPC
output "vpc_names" {
  description = "Kamus berisi key dan nama VPC yang terbentuk"
  value = {
    # Format: { kunci => nama_vpc_di_gcp }
    for key, vpc in google_compute_network.vpc : key => vpc.name
  }
}

# Mengeluarkan daftar nama Subnet
output "subnet_names" {
  description = "Kamus berisi key dan nama Subnet yang terbentuk"
  value = {
    # Format: { kunci => nama_subnet_di_gcp }
    for key, subnet in google_compute_subnetwork.subnet : key => subnet.name
  }
}

# Mengeluarkan daftar VPC yang sudah memiliki koneksi Peering PSA
output "psa_connections" {
  description = "Kamus berisi ID koneksi Private Services Access (PSA) yang berhasil dibuat per VPC"
  value = {
    # Format: { kunci_vpc => ID_koneksi_peering }
    # Hanya VPC yang memiliki PSA (length(psa_ranges) > 0) yang akan masuk ke daftar ini
    for key, connection in google_service_networking_connection.private_vpc_connection : key => connection.id
  }
}