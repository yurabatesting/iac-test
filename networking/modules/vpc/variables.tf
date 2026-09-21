# variable "network_name" {
#   type = string
# }

# variable "subnet_name" {
#   type = string
# }

# variable "subnet_ip_range" {
#   type = string
# }

variable "region" {
  type = string
}

variable "vpc" {
  description = "Variable untuk membuat vpc"
  type = map(object({
    vpc_name = string
    auto_create_subnetworks = bool
    
    # Mengganti enable_psa dengan konfigurasi daftar rentang IP PSA
    psa_ranges = optional(list(object({
      name          = string
      address       = optional(string)       # Opsional: Jika kosong, Google akan memberikan IP acak
      prefix_length = optional(number, 24)   # Opsional: Default otomatis menggunakan /24
    })), []) # Default berupa list kosong [] jika atribut ini tidak ditulis di .tfvars
  }))
}

variable "subnet" {
  description = "Variable untuk membuat subnet"
  type = map(object({
    subnet_name = string
    subnet_ip_range = string
    vpc_key = string
  }))
}