# Basic information 
variable "vm_name" {
  type = string
}
variable "desired_status" {
  type = string
  default = "Running"
}
variable "zone" {
  type = string
}
# Deletion Protection
variable "deletion_protection" {
  type    = bool
  default = false 
}


# ===============================================================================================
# Konfigurasi Machine Type
variable "machine_type" {
  type = string
}


# ===============================================================================================
# Konfigurasi Networking
# menerima ID subnet dari module networking
variable "subnet_id" {
  type = string
}
# External IP & Network Service Tier
variable "assign_external_ip" {
  type    = bool
  default = false # Default aman: Tanpa IP Publik
}
variable "network_tier" {
  type    = string
  default = "PREMIUM"
}
# Network Tags
variable "network_tags" {
  type    = list(string)
  default = []
}
# Hostname
variable "hostname" {
  type    = string
  default = null
}


# ===============================================================================================
# Konfigurasi Storage
variable "boot_disk_image" {
  type = string
  default = "ubuntu-os-cloud/ubuntu-2204-lts"
}
variable "boot_disk_type" {
  type = string
  default = "pd-standard"
}
variable "boot_disk_size" {
  type = number
  default = 10
}
variable "boot_disk_labels" {
  description = "Label tambahan khusus untuk boot disk"
  type        = map(string)
  default     = {} # Default kosong jika tidak ada label khusus
}
variable "additional_disks" {
  description = "Daftar additional disk yang akan dibuat dan dipasang ke VM"
  type = map(object({
    type = string
    size = number
    labels = optional(map(string), {}) # <- Fitur opsional!
  }))
  default = {} # Default kosong (0 disk) jika tidak diisi
}


# ===============================================================================================
# Konfigurasi Shielded VM
variable "enable_secure_boot" {
  type    = bool
  default = false
}
variable "enable_vtpm" {
  type    = bool
  default = true
}
variable "enable_integrity_monitoring" {
  type    = bool
  default = true
}
# VM Access (OS Login) & Manual SSH Key
variable "enable_oslogin" {
  description = "Control VM access through IAM permissions"
  type    = bool
  default = true # Rekomendasi industri untuk kontrol akses sentral
}
variable "enable_oslogin_2fa" {
  description = "Require 2-Step Verification"
  type        = bool
  default     = false
}
variable "block_project_ssh_keys" {
  description = "Block project-wide SSH keys"
  type        = bool
  default     = true # Mencegah kunci level project mengakses VM ini
}
variable "ssh_keys" {
  description = "Add manually generated SSH keys (Hanya berlaku jika enable_oslogin = false)"
  type    = string
  default = null
}


# ===============================================================================================
# Konfigurasi Service Account & Access Scope (Mengelola Workload Identity VM)
variable "service_account_email" {
  type    = string
  default = null # Jika null, menggunakan Default Compute SA
}
variable "access_scopes" {
  type    = list(string)
  default = ["https://www.googleapis.com/auth/cloud-platform"] # Full akses API (aman selama SA-nya dibatasi IAM)
}


# ===============================================================================================
# Variabel untuk Label Umum (berlaku untuk VM dan semua disk-nya)
variable "labels" {
  description = "Label umum untuk semua resource"
  type        = map(string)
  default     = {}
}
variable "install_ops_agent" {
  type    = string
  default = "TRUE" # Ops Agent otomatis terinstal via metadata
}
variable "custom_metadata" {
  type    = map(string)
  default = {}
}
variable "startup_script" {
  type    = string
  default = null
}







