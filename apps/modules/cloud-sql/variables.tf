variable "cloudsql" {
  description = "Map konfigurasi untuk memprovisikan beberapa instance Cloud SQL"
  type = map(object({
    # ----------------------------------------------------------------------
    # Parameter Wajib (Harus didefinisikan dalam .tfvars)
    # ----------------------------------------------------------------------
    instance_name    = string
    database_version = string
    region           = string
    root_password    = string
    network_id       = string
    tier             = string

    # ----------------------------------------------------------------------
    # Parameter Opsional (Memiliki nilai default)
    # ----------------------------------------------------------------------
    # Perlindungan & Ketersediaan
    deletion_protection = optional(bool, false)
    edition             = optional(string, "ENTERPRISE")
    availability_type   = optional(string, "ZONAL")
    activation_policy   = optional(string, "ALWAYS") # "ALWAYS" = nyala, "NEVER" = mati
    
    # Konfigurasi Storage
    disk_type           = optional(string, "PD_HDD")
    disk_size           = optional(number, 10) # Kapasiti asas (GB)
    disk_autoresize     = optional(bool, false)
    
    # Konfigurasi Jaringan & Keamanan
    enable_public_ip    = optional(bool, false)
    allocated_ip_range  = optional(string, null) # Tambahkan baris ini
    ssl_mode            = optional(string, "ENCRYPTED_ONLY") # ENCRYPTED_ONLY = Allow only SSL
    
    # Konfigurasi Lanjutan
    enable_data_cache   = optional(bool, false)
    allow_data_api      = optional(string, "ALLOW_DATA_API")
    enable_query_insights = optional(bool, true)            # Default: disable

    # Konfigurasi Backup (Default: Nonaktif)
    enable_backup            = optional(bool, false)
    retained_backups         = optional(number, 7)           # Menyimpan backup 7 hari terakhir jika aktif
    retain_backups_on_delete = optional(bool, false)         # Default: disable

    # Konfigurasi Final Backup (Default : Nonaktif)
    enable_final_backup         = optional(bool, false)
    final_backup_retention_days = optional(number, 7)

    # Konfigurasi Maintenance Window
    maintenance_day          = optional(number, 7)           # 1 = Senin, 7 = Minggu (Default: Minggu)
    maintenance_hour         = optional(number, 2)           # Format 24 jam (Default: Jam 2 pagi)

    # Konfigurasi Multi-Label
    labels = optional(map(string), {})
    
    # # Database Flags / Parameters
    # database_flags = optional(list(object({
    #   name  = string
    #   value = string
    # })), [])
    
  }))
  default = {}
}