variable "vm_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "zone" {
  type = string
}

# menerima ID subnet dari module networking
variable "subnet_id" {
  type = string
}

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

variable "desired_status" {
  type = string
  default = "Running"
}

# Modifikasi daftar disk agar bisa menerima label khusus secara opsional
variable "additional_disks" {
  description = "Daftar additional disk yang akan dibuat dan dipasang ke VM"
  type = map(object({
    type = string
    size = number
    labels = optional(map(string), {}) # <- Fitur opsional!
  }))
  default = {} # Default kosong (0 disk) jika tidak diisi
}

# Variabel untuk Label Umum (berlaku untuk VM dan semua disk-nya)
variable "labels" {
  description = "Label umum untuk semua resource"
  type        = map(string)
  default     = {}
}
