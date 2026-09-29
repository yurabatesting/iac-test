# Mengambil data project saat ini untuk konfigurasi Workload Identity
data "google_project" "current" {}

# ==============================================================================
# SANG OTAK: KONTROL PLANE GKE (CLUSTER)
# ==============================================================================
resource "google_container_cluster" "primary" {
  for_each = var.gke_clusters

  name     = each.key
  location = each.value.location
  deletion_protection = each.value.deletion_protection
  
  # Distribusi zona (jika di-set kosong, GKE akan otomatis menyebar ke 3 zona)
  node_locations = length(each.value.node_locations) > 0 ? each.value.node_locations : null

  # 1. HAPUS DEFAULT NODE POOL (Standar Mutlak Industri)
  remove_default_node_pool = true
  initial_node_count       = 1

  # 2. JARINGAN & VPC-NATIVE
  network    = each.value.network
  subnetwork = each.value.subnetwork
  
  # Dataplane V2 (eBPF)
  datapath_provider = each.value.enable_dataplane_v2 ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"

  # Konfigurasi VPC-Native (Alokasi IP Pods & Services)
  ip_allocation_policy {
    cluster_secondary_range_name  = each.value.ip_range_pods
    services_secondary_range_name = each.value.ip_range_services
  }

  # Konfigurasi Private Cluster (Otot tidak punya IP Publik, tapi Otak bisa diakses)
  private_cluster_config {
    enable_private_nodes    = each.value.enable_private_nodes
    enable_private_endpoint = false # False berarti bisa diakses dari laptop Anda
    master_ipv4_cidr_block  = each.value.master_ipv4_cidr_block
  }

  # Konfigurasi Master Authorized Networks (Akses Control Plane)
  dynamic "master_authorized_networks_config" {
    for_each = each.value.enable_master_authorized_networks ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = each.value.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # 3. FITUR, OBSERVABILITY & SECURITY
  release_channel {
    channel = each.value.release_channel
  }

  min_master_version = each.value.cluster_version

  maintenance_policy {
    daily_maintenance_window {
      start_time = each.value.maintenance_start_time
    }
  }

  cost_management_config {
    enabled = each.value.enable_cost_alloc
  }

  monitoring_config {
    enable_components = each.value.monitoring_enable
    managed_prometheus {
      enabled = each.value.enable_managed_prom
    }
  }

  logging_config {
    enable_components = each.value.logging_enable
  }

  secret_manager_config {
    enabled = each.value.enable_secret_manager
  }

  # Workload Identity (Sangat direkomendasikan untuk keamanan)
  dynamic "workload_identity_config" {
    for_each = each.value.enable_workload_id ? [1] : []
    content {
      workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
    }
  }

  addons_config {
    http_load_balancing {
      disabled = !each.value.enable_http_load_balancing
    }
    gke_backup_agent_config {
      enabled = each.value.enable_backup
    }
  }

  dynamic "gateway_api_config" {
    for_each = each.value.enable_gateway_api ? [1] : []
    content {
      channel = "CHANNEL_STANDARD"
    }
  }
}

# ==============================================================================
# SIHIR LOKAL: Meratakan (Flatten) Nested Mega Map untuk Node Pools
# ==============================================================================
locals {
  # Mengubah map di dalam map menjadi satu map datar agar bisa di-looping
  # Hasilnya nanti seperti: "cluster-utama-pool-umum" => { konfigurasi_pool }
  flat_node_pools = merge([
    for cluster_name, cluster_config in var.gke_clusters : {
      for pool_name, pool_config in cluster_config.node_pools :
      "${cluster_name}-${pool_name}" => merge(pool_config, {
        cluster_name = cluster_name
        pool_name    = pool_name
        location     = cluster_config.location
        workload_id  = cluster_config.enable_workload_id
      })
    }
  ]...)
}

# ==============================================================================
# SANG OTOT: KUMPULAN WORKER NODES (GKE NODE POOLS)
# ==============================================================================
resource "google_container_node_pool" "pools" {
  for_each = local.flat_node_pools

  # Menempelkan Node Pool ke Cluster yang tepat
  name     = each.value.pool_name
  cluster  = google_container_cluster.primary[each.value.cluster_name].id
  location = each.value.location

  initial_node_count = each.value.min_count

  # Mengaktifkan Autoscaler
  autoscaling {
    min_node_count = each.value.min_count
    max_node_count = each.value.max_count
  }

  max_pods_per_node = each.value.max_pods_per_node

  # Spesifikasi Mesin
  node_config {
    image_type      = each.value.image_type
    machine_type    = each.value.machine_type
    disk_type       = each.value.disk_type
    disk_size_gb    = each.value.disk_size_gb
    service_account = each.value.service_account
    oauth_scopes    = each.value.oauth_scopes

    tags   = each.value.network_tags
    labels = each.value.kube_labels

    # Inject Taints jika ada
    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Jika Workload Identity di kluster menyala, Node juga harus tahu
    dynamic "workload_metadata_config" {
      for_each = each.value.workload_id ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }
  }

  # 3. SIHIR PENUTUP MATA (Mencegah Terraform berantem dengan Autoscaler & GKE)
  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_count,
      node_config[0].labels,    # Mengabaikan label tambahan yang disuntikkan GKE otomatis
      node_config[0].metadata,  # Mengabaikan metadata SSH key yang dibuat GKE
      node_config[0].resource_labels
    ]
  }
}