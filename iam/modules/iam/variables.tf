variable "project_id" {
  description = "ID Project GCP"
  type        = string
}

variable "iam_members" {
  description = "Kamus yang berisi penetapan Member dan daftar Role IAM"
  type = map(object({
    member = string
    roles  = list(string) # Diubah menjadi list untuk menampung banyak role
  }))
}