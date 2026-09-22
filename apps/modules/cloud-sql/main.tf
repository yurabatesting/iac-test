resource "google_sql_database_instance" "instance" {
  # Menggunakan for_each agar bisa memprovisikan multiple Cloud SQL
  for_each = var.cloudsql

  # 1. Instance Info
  name             = each.value.instance_name
  database_version = each.value.database_version
  region           = each.value.region
  
  # Kata sandi untuk user default (root untuk MySQL, postgres untuk PostgreSQL)
  root_password    = each.value.root_password

  # Mencegah database terkunci saat Anda ingin melakukan 'terraform destroy' di tahap belajar
  deletion_protection = each.value.deletion_protection

  settings {
    # 3. Machine Configuration
    tier = each.value.tier
    edition           = each.value.edition # ENTERPRISE (default) atau ENTERPRISE_PLUS

    # 2. Zonal Availability (ZONAL = Single zone, REGIONAL = High Availability)
    availability_type = each.value.availability_type
    
    # Tambahkan baris ini untuk mengontrol status nyala/mati instance
    activation_policy = each.value.activation_policy
    retain_backups_on_delete = each.value.retain_backups_on_delete


    # 4. Storage Configuration
    disk_type       = each.value.disk_type
    disk_size       = each.value.disk_size
    disk_autoresize = each.value.disk_autoresize

    # 5. Connection IP Configuration
    ip_configuration {
      ipv4_enabled    = each.value.enable_public_ip
      
      # Menyambungkan ke VPC yang sudah memiliki PSA
      private_network = each.value.network_id
      # Memaksa Cloud SQL menggunakan nama PSA tertentu. 
      # Jika kosong (null), GCP akan memilih IP dari PSA mana saja secara acak.
      allocated_ip_range = each.value.allocated_ip_range

      # SSL Mode (Default: ENCRYPTED_ONLY)
      ssl_mode = each.value.ssl_mode
    }

    # 6. Konfigurasi Data Cache (Hanya berlaku untuk Cloud SQL edisi Enterprise Plus)
    data_cache_config {
      data_cache_enabled = each.value.enable_data_cache
    }

    # 7. Konfigurasi Data API Authorisation (Berdasarkan referensi Anda)
    # Belum support untuk terraform
    data_api_access = each.value.allow_data_api


    # 8. Backup Configuration & Retain after Delete
    backup_configuration {
      enabled = each.value.enable_backup
      
      backup_retention_settings {
        retained_backups         = each.value.retained_backups
        # retain_backups_on_delete = each.value.retain_backups_on_delete
      }
    }

    # 9. Final Backup on Instance Deletion
    final_backup_config {
      enabled        = each.value.enable_final_backup
      # Jika enabled = true, gunakan angka hari. Jika false, set menjadi null agar diabaikan GCP.
      retention_days = each.value.enable_final_backup ? each.value.final_backup_retention_days : null
    }

    # 10. Maintenance Window
    maintenance_window {
      day          = each.value.maintenance_day   # 1-7 (Senin-Minggu)
      hour         = each.value.maintenance_hour  # 0-23
    }

    # 11. Database Flags / Parameters
    # # Menggunakan dynamic block agar Terraform bisa melooping list of objects
    # dynamic "database_flags" {
    #   for_each = each.value.database_flags != null ? each.value.database_flags : []
    #   content {
    #     name  = database_flags.value.name
    #     value = database_flags.value.value
    #   }
    # }

    # 12. Query Insights (Observabilitas Kueri Lambat)
    insights_config {
      query_insights_enabled = each.value.enable_query_insights
    }

    # 13. Konfigurasi Label (Mendukung lebih dari 1 label via Key-Value)
    user_labels = each.value.labels
  }

  # Mengabaikan perubahan flag di luar Terraform (menghindari error configuration drift)
  lifecycle {
    ignore_changes = [
      settings[0].database_flags
    ]
  }
}