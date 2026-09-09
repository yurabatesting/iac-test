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

variable "desired_status" {
  type = string
  default = "Running"
}