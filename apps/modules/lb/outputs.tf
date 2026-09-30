# ==============================================================================
# ALAMAT IP PUBLIK (Paling Penting!)
# ==============================================================================
output "load_balancer_ip" {
  description = "Alamat IP Publik Statis dari Load Balancer. Gunakan IP ini untuk dipasang di DNS (A Record)."
  # Jika pakai IP existing, keluarkan nilai IP existing. Jika buat baru, ambil dari index [0]
  value       = var.existing_ip_address != null ? var.existing_ip_address : google_compute_global_address.default[0].address
}

# ==============================================================================
# IDENTITAS RESOURCE (Untuk Integrasi dengan Modul Lain)
# ==============================================================================
output "umig_ids" {
  description = "Map yang berisi daftar ID dari Unmanaged Instance Group yang tercipta"
  # Menggunakan for-loop untuk merapikan output menjadi bentuk map { "frontend" = "id-umig-fe", "api" = "id-umig-api" }
  value       = { for k, v in google_compute_instance_group.umig : k => v.id }
}

output "backend_service_ids" {
  description = "Map yang berisi daftar ID dari Backend Service"
  value       = { for k, v in google_compute_backend_service.bes : k => v.id }
}