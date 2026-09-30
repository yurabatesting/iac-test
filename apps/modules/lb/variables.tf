# ==============================================================================
# IDENTITAS & LOKASI
# ==============================================================================
# Menerima input nama LB. Nilai ini akan dipakai sebagai awalan (prefix) 
# untuk semua nama resource agar rapi (misal: lb-utama-cert, lb-utama-ip).
variable "lb_name" {
  description = "Nama Load Balancer"
  type        = string
}

# Menerima input zona. UMIG di GCP bersifat Zonal, jadi kita butuh 1 zona spesifik
# tempat VM existing Anda berada (contoh: "asia-southeast2-a").
variable "zone" {
  description = "Zona lokasi Unmanaged Instance Group"
  type        = string
}

variable "existing_ip_address" {
  description = "Masukkan IP Publik statis existing jika ada (misal: '34.120.x.x' atau self_link). Jika dikosongkan, modul akan membuat IP baru otomatis."
  type        = string
  default     = null
}

# ==============================================================================
# MULTI-DOMAIN & SSL
# ==============================================================================
# Menerima daftar domain. Karena tipenya list(string), Anda bisa mengisi 1 domain
# ["api.com"] atau lebih ["api.com", "web.com"]. Modul akan otomatis membuatkan
# Managed SSL Google untuk semua domain di dalam list ini.
variable "domains" {
  description = "Daftar domain untuk Google Managed SSL"
  type        = list(string)
}

# ==============================================================================
# BACKEND & ROUTING (Bisa 1 atau Lebih)
# ==============================================================================
# Inilah "Jantung" dari arsitektur kita. 
# Jika Anda butuh 1 backend: Cukup kirim 1 blok dengan is_default = true.
# Jika butuh 2 backend: Kirim 2 blok, satu is_default = true, satunya false + rutenya.
variable "backends" {
  description = "Pemetaan Backend Service dan URL Map"
  type = map(object({
    # Menandakan apakah ini backend utama penampung traffic (/*). 
    # Jika tidak diisi, otomatis bernilai false. Wajib ada 1 yg true!
    is_default = optional(bool, false)
    
    # Rute URL yang akan diarahkan ke backend ini (contoh: "/api/*" atau "/*")
    route_path = string
    
    # Daftar URL Self-Link dari VM existing Anda. 
    # Jika tidak diisi, akan membentuk UMIG kosong.
    instances  = optional(list(string), [])

    # Kita tambahkan pengaturan port DI DALAM blok masing-masing backend.
    # Jika tidak diisi di .tfvars, otomatis pakai port 80 dan "http".
    port       = optional(number, 80)
    port_name  = optional(string, "http")
  }))
}

# ==============================================================================
# PARAMETER JARINGAN BACKEND
# ==============================================================================
# Protokol yang dipakai Load Balancer untuk ngobrol dengan VM Anda.
variable "backend_protocol" {
  type    = string
  default = "HTTP"
}