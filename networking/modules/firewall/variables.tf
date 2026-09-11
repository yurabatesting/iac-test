# variable "firewall_name" {
#   type = string
# }

# # menerima ID VPC dari modul networking
# variable "network_id" {
#   type = string
# }

variable "firewall" {
  description = "Template untuk membuat Firewall"
  type = map(object({
    firewall_name = string
    vpc_key = string
    source_ranges = list(string)
    allow = list(object({
      protocol = string
      ports = list(string)
    }))
  }))
}

# Variabel baru untuk menampung lemparan output dari Modul VPC
variable "available_vpc" {
  description = "Daftar VPC yang tersedia dari modul network"
  type        = map(string) 
}