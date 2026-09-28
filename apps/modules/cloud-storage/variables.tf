variable "buckets" {
  description = "Map konfigurasi untuk membuat satu atau banyak Cloud Storage Bucket"
  type = map(object({
    # 1. Konfigurasi Dasar
    location                          = string
    storage_class                     = optional(string, "STANDARD")
    force_destroy                     = optional(bool, false)
    
    # 2. Keamanan & Akses (Default aman untuk Enterprise)
    uniform_bucket_level_access       = optional(bool, true)
    enforce_public_access             = optional(string, "enforced") 
    
    # 3. Fitur Objek & Struktur
    versioning_enabled                = optional(bool, false)
    hierarchical_namespace            = optional(bool, false)
    
    # 4. Data Protection & Retention
    soft_delete_duration_sec          = optional(number, 604800) # Default GCP: 7 hari
    bucket_retention_period_sec       = optional(number, null)
    bucket_retention_is_locked        = optional(bool, false)
    enable_object_retention           = optional(bool, false)
    
    # 5. Data Encryption (CMEK)
    kms_key_name                      = optional(string, null)
    
    # 6. Dual-Region Handling
    # Isi dengan 2 region jika location menggunakan multi-region (misal: "ASIA")
    custom_placement_config_locations = optional(list(string), [])
    
    # 7. IP Filtering (Kosongkan/null jika tidak dibutuhkan)
    ip_filter = optional(object({
      mode                           = string # "Enabled" atau "Disabled"
      allow_all_service_agent_access = optional(bool, null)
      allow_cross_org_vpcs           = optional(bool, null)
      
      # Untuk IP Publik biasa
      allowed_public_ips             = optional(list(string), [])
      
      # REVISI: Untuk VPC, wajib menyertakan Network ID & IP Range
      allowed_vpc_networks           = optional(list(object({
        network                = string
        allowed_ip_cidr_ranges = list(string)
      })), [])
    }), null)

    # 8. TAMBAHKAN BARIS INI: Parameter untuk label (default map kosong)
    labels                            = optional(map(string), {})


    # 9. TAMBAHKAN INI: Konfigurasi Website Statis
    website = optional(object({
      main_page_suffix = string                 # Biasanya "index.html"
      not_found_page   = optional(string, null) # Biasanya "404.html"
    }), null)
  }))
}