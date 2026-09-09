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