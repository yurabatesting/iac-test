resource "google_redis_instance" "cache" {
  for_each = var.redis_instances

  # 1. Identitas & Lokasi
  name                    = each.key
  display_name            = each.value.display_name
  region                  = each.value.region
  location_id             = each.value.location_id
  alternative_location_id = each.value.alternative_location_id

  # 2. Spesifikasi Mesin
  tier           = each.value.tier
  memory_size_gb = each.value.memory_size_gb
  redis_version  = each.value.redis_version

  # 3. Jaringan (VPC)
  connect_mode       = each.value.connect_mode
  authorized_network = each.value.authorized_network
  reserved_ip_range  = each.value.reserved_ip_range

  # 4. Keamanan & Enkripsi
  auth_enabled            = each.value.auth_enabled
  transit_encryption_mode = each.value.transit_encryption_mode
  customer_managed_key    = each.value.customer_managed_key

  # 5. High Availability (Read Replicas)
  # Hanya berefek jika tier = "STANDARD_HA"
  replica_count      = each.value.replica_count
  read_replicas_mode = each.value.read_replicas_mode

  # 6. Snapshot / Backup (RDB)
  # Menggunakan dynamic block agar tidak error jika tidak dipakai
  dynamic "persistence_config" {
    for_each = each.value.rdb_snapshot_period != null ? [1] : []
    
    content {
      persistence_mode    = "RDB"
      rdb_snapshot_period = each.value.rdb_snapshot_period
    }
  }

  # 7. Jadwal Maintenance Mingguan
  # Menggunakan dynamic block agar hanya aktif jika hari & jam disetel
  dynamic "maintenance_policy" {
    for_each = (each.value.maintenance_day != null && each.value.maintenance_hour != null) ? [1] : []
    
    content {
      weekly_maintenance_window {
        day = each.value.maintenance_day
        start_time {
          hours   = each.value.maintenance_hour
          minutes = 0
          seconds = 0
          nanos   = 0
        }
      }
    }
  }

  # 8. Labels
  labels = each.value.labels

  # 9. Proteksi Infrastruktur (Wajib hardcode nilai boolean/list di blok ini)
  lifecycle {
    prevent_destroy = true 
    ignore_changes  = [redis_configs] 
  }
}