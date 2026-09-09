# mengembalikan ID VPC agar bisa digunakan oleh firewall dan vm
output "network_id" {
  value = google_compute_network.vpc.id
}

# mengembalikan ID subnet agar vm tahu harus masuk ke mana
output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}