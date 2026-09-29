resource "google_storage_bucket" "bucket" {
  for_each = var.buckets

  # 1. Konfigurasi Dasar
  name          = each.key
  location      = each.value.location
  storage_class = each.value.storage_class
  force_destroy = each.value.force_destroy

  # 2. Access Control & Public Access
  uniform_bucket_level_access = each.value.uniform_bucket_level_access
  public_access_prevention    = each.value.enforce_public_access

  # 3. Object Versioning
  versioning {
    enabled = each.value.versioning_enabled
  }

  # 4. Hierarchical Namespace (HNS)
  dynamic "hierarchical_namespace" {
    # Hanya buat blok ini jika nilainya true
    for_each = each.value.hierarchical_namespace ? [1] : []
    content {
      enabled = true
    }
  }

  # 5. Soft Delete Policy
  dynamic "soft_delete_policy" {
    for_each = each.value.soft_delete_duration_sec != null ? [1] : []
    content {
      retention_duration_seconds = each.value.soft_delete_duration_sec
    }
  }

  # 6. Bucket Retention Policy
  dynamic "retention_policy" {
    for_each = each.value.bucket_retention_period_sec != null ? [1] : []
    content {
      retention_period = each.value.bucket_retention_period_sec
      is_locked        = each.value.bucket_retention_is_locked
    }
  }

  # 7. Object Retention
  enable_object_retention = each.value.enable_object_retention

  # 8. Data Encryption (Customer-Managed Encryption Keys / CMEK)
  dynamic "encryption" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = each.value.kms_key_name
    }
  }

  # 9. Blok Dual-Region
  dynamic "custom_placement_config" {
    # Render hanya jika list lokasi lebih dari 0
    for_each = length(each.value.custom_placement_config_locations) > 0 ? [1] : []
    content {
      data_locations = each.value.custom_placement_config_locations
    }
  }

  # 10. Blok IP Filter
  dynamic "ip_filter" {
    for_each = each.value.ip_filter != null ? [1] : []
    
    content {
      mode                           = each.value.ip_filter.mode
      allow_all_service_agent_access = each.value.ip_filter.allow_all_service_agent_access
      allow_cross_org_vpcs           = each.value.ip_filter.allow_cross_org_vpcs

      # A. Render IP Publik
      dynamic "public_network_source" {
        for_each = length(each.value.ip_filter.allowed_public_ips) > 0 ? [1] : []
        content {
          allowed_ip_cidr_ranges = each.value.ip_filter.allowed_public_ips
        }
      }

      # B. REVISI: Render VPC Network (Bisa lebih dari 1 VPC)
      dynamic "vpc_network_sources" {
        # Loop ini akan membedah list object VPC yang Anda buat di .tfvars
        for_each = each.value.ip_filter.allowed_vpc_networks
        content {
          network                = vpc_network_sources.value.network
          allowed_ip_cidr_ranges = vpc_network_sources.value.allowed_ip_cidr_ranges
        }
      }
    }
  }

  # 11. TAMBAHKAN INI: untuk label
  labels        = each.value.labels

  # 12. TAMBAHKAN INI: Blok Dynamic untuk Website Statis
  dynamic "website" {
    for_each = each.value.website != null ? [1] : []
    content {
      main_page_suffix = each.value.website.main_page_suffix
      not_found_page   = each.value.website.not_found_page
    }
  }

  # TAMBAHKAN BLOK INI DI BAGIAN BAWAH
  lifecycle {
    prevent_destroy = true
  }
}