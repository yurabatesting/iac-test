variable "redis_instances" {
  description = "Map konfigurasi untuk provision Google Cloud Redis (Memorystore)"
  type = map(object({
    # 1. Konfigurasi Dasar
    display_name            = optional(string, null)
    tier                    = optional(string, "BASIC")
    memory_size_gb          = optional(number, 1)
    region                  = string
    location_id             = optional(string, null)
    alternative_location_id = optional(string, null) # Untuk backup zone jika STANDARD_HA
    
    # 2. Network (Di-inject dari env/main.tf menggunakan merge seperti Cloud SQL)
    connect_mode            = optional(string, "PRIVATE_SERVICE_ACCESS")
    authorized_network      = string
    reserved_ip_range       = optional(string, null)
    
    # 3. Read Replica (Hanya aktif jika Tier = STANDARD_HA)
    replica_count           = optional(number, null)
    read_replicas_mode      = optional(string, "READ_REPLICAS_DISABLED")
    
    # 4. Security & Encryption
    auth_enabled            = optional(bool, false)
    transit_encryption_mode = optional(string, "DISABLED")
    customer_managed_key    = optional(string, null) # Null = Google Managed Encryption
    
    # 5. Version
    redis_version           = optional(string, null) # Null = Default versi dari GCP
    
    # 6. Snapshot (RDB)
    # Pilihan: "ONE_HOUR", "SIX_HOURS", "TWELVE_HOURS", "TWENTY_FOUR_HOURS"
    rdb_snapshot_period     = optional(string, null) # Null = Unchecked/Disabled
    
    # 7. Maintenance Window & Labels
    maintenance_day         = optional(string, null) # Contoh: "SUNDAY"
    maintenance_hour        = optional(number, null) # Contoh: 2 (Jam 2 Pagi)
    labels                  = optional(map(string), {})
  }))
}