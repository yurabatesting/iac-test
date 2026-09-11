variable "target_type" {
  description = "Pilih level IAM: 'project', 'folder', atau 'organization'"
  type        = string

  validation {
    condition     = contains(["project", "folder", "organization"], var.target_type)
    error_message = "target_type harus berupa 'project', 'folder', atau 'organization'."
  }
}

variable "target_id" {
  description = "Berisi Project ID, Folder ID, atau Org ID"
  type        = string
}

variable "iam_members" {
  description = "Kamus yang berisi penetapan Member dan daftar Role IAM"
  type = map(object({
    member = string
    roles  = list(string) # Diubah menjadi list untuk menampung banyak role
  }))
}