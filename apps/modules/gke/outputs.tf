output "clusters" {
  description = "Detail informasi dari semua GKE Clusters yang berhasil dibuat"
  
  # Kita bungkus jadi satu objek yang rapi per kluster
  value = {
    for name, cluster in google_container_cluster.primary : name => {
      id             = cluster.id
      name           = cluster.name
      location       = cluster.location
      
      # Ini adalah IP Publik/Private dari Control Plane
      endpoint       = cluster.endpoint 
      
      # Ini adalah "Gembok" rahasia untuk bisa berkomunikasi dengan Kubernetes API
      ca_certificate = cluster.master_auth[0].cluster_ca_certificate
    }
  }
  
  # Sangat penting! CA Certificate adalah data sensitif, 
  # kita wajib menyuruh Terraform untuk menyembunyikannya dari log terminal.
  sensitive = true 
}

output "node_pools" {
  description = "Daftar ID dari semua Node Pools yang telah dibuat"
  value = {
    for key, pool in google_container_node_pool.pools : key => pool.id
  }
}