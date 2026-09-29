output "redis_instances" {
  description = "Informasi koneksi lengkap (IP, Port, Password) untuk seluruh Redis yang diprovisikan"
  
  # Looping seluruh Redis yang berhasil dibuat dari main.tf
  value = {
    for k, v in google_redis_instance.cache : k => {
      instance_id   = v.id
      
      # Endpoint Utama (Untuk koneksi Read & Write)
      host          = v.host
      port          = v.port
      
      # Endpoint Read Replica (Hanya berisi jika tier STANDARD_HA & Read Replica aktif)
      read_endpoint = v.read_endpoint
      read_port     = v.read_endpoint_port
      
      # Password Redis (Hanya berisi jika auth_enabled = true)
      auth_string   = v.auth_string
    }
  }

  # WAJIB TRUE: Karena ada 'auth_string' (password), Terraform mewajibkan 
  # output ini disembunyikan di layar terminal demi keamanan.
  sensitive = true
}