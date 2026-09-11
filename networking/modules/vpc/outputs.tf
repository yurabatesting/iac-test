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