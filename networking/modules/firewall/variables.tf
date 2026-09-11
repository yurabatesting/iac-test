variable "firewall_name" {
  type = string
}

# menerima ID VPC dari modul networking
variable "network_id" {
  type = string
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