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