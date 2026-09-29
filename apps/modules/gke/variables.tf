variable "gke_clusters" {
  description = "Konfigurasi GKE Standard Cluster (Nested Mega Map) dengan objektif Enterprise"
  type = map(object({
    # ==========================================
    # 1. CLUSTER BASIC
    # ==========================================
    location        = string # Wajib: Region atau Zone
    node_locations  = optional(list(string), []) # Default: Kosong (GKE akan auto-distribute ke zona di region tsb)
    release_channel = optional(string, "REGULAR") # Default: REGULAR channel
    cluster_version = optional(string, null) # Default: null (Mengikuti versi dari release_channel)
    deletion_protection = optional(bool, false) # Default: TRUE (Aman dari awal)
    
    # ==========================================
    # 2. AUTOMATION & MAINTENANCE
    # ==========================================
    # Format HH:MM dalam UTC. Default 17:00 UTC = 00:00 WIB (Tengah malam)
    maintenance_start_time = optional(string, "17:00") 

    # ==========================================
    # 3. FEATURES & OBSERVABILITY
    # ==========================================
    enable_backup        = optional(bool, false) # Default: Disable Backup for GKE
    monitoring_enable    = optional(list(string), ["SYSTEM_COMPONENTS"]) # Default: Enable All
    logging_enable       = optional(list(string), ["SYSTEM_COMPONENTS", "WORKLOADS"]) # Default: Enable All
    enable_cost_alloc    = optional(bool, true)  # Default: Enable Cost Allocation
    enable_managed_prom  = optional(bool, true)  # Default: Enable Managed Prometheus

    # ==========================================
    # 4. SECURITY & AUTH
    # ==========================================
    enable_binary_auth    = optional(bool, false) # Default: Disable Binary Auth
    enable_rbac_groups    = optional(bool, false) # Default: Disable Google Group RBAC
    rbac_security_group   = optional(string, null)
    enable_secret_manager = optional(bool, true)  # Default: Enable Secret Manager CSI
    enable_workload_id    = optional(bool, true) # Default: Disable Workload Identity

    # ==========================================
    # 5. NETWORKING & CONTROL PLANE
    # ==========================================
    network                      = string # Wajib: Nama VPC (ditarik dari data blok di env)
    subnetwork                   = string # Wajib: Nama Subnet
    ip_range_pods                = string # Wajib: Nama Secondary Range Pods
    ip_range_services            = string # Wajib: Nama Secondary Range Services
    master_ipv4_cidr_block       = string # Wajib: CIDR /28 untuk Control Plane (Syarat Private Nodes)
    enable_dataplane_v2          = optional(bool, true) # Default: Enable Dataplane V2
    enable_private_nodes         = optional(bool, true) # Default: Enable Private Nodes
    default_max_pods_per_node    = optional(number, 110) # Default: 110 max pods/node
    enable_http_load_balancing   = optional(bool, true) # Default: Enable HTTP LB (Ingress)
    enable_gateway_api           = optional(bool, true) # Default: Enable Gateway API
    disable_lb_firewall_creation = optional(bool, false) # Default: False (GKE Boleh Create FW Otomatis)
    enable_master_authorized_networks = optional(bool, false) # Default: Disable (Terbuka di VPC)
    master_authorized_networks = optional(list(object({
      cidr_block   = string
      display_name = string
    })), []) # Default: Kosong

    # ==========================================
    # 6. NODE POOLS (Nested Mega Map)
    # ==========================================
    node_pools = map(object({
      image_type        = optional(string, "COS_CONTAINERD") # Default OS
      machine_type      = optional(string, "e2-medium") # Default: e2-medium
      disk_type         = optional(string, "pd-standard") # Default: Standard Disk
      disk_size_gb      = optional(number, 20) # Default: 20 GB
      min_count         = optional(number, 1) # Default: 1 Node (Autoscaler minimum)
      max_count         = optional(number, 3) # Default: 3 Nodes (Autoscaler maksimum)
      max_pods_per_node = optional(number, null) # Default: Ikut default cluster
      network_tags      = optional(list(string), []) # Default: Kosong
      service_account   = optional(string, "default") # Default: Pakai default compute SA
      oauth_scopes      = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"]) # Default: Allow All API
      labels            = optional(map(string), {}) # Default: Kosong (GCP Resource Labels)
      kube_labels       = optional(map(string), {}) # Default: Kosong (Kubernetes Node Labels)
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), []) # Default: Kosong (Node Taints)
    }))
  }))
  default = {}
}