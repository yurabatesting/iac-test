locals {
  # Memecah 1 member dengan 3 role menjadi 3 kombinasi data yang berbeda
  iam_flat = flatten([
    for key, data in var.iam_members : [
      for role in data.roles : {
        # Membuat ID unik untuk perulangan (misal: "user:budi@x.com=>roles/viewer")
        unique_key = "${data.member}=>${role}"
        member     = data.member
        role       = role
      }
    ]
  ])
}

resource "google_project_iam_member" "project_members" {
  # Mengubah hasil flatten (List) kembali menjadi Map agar bisa di-looping
  for_each = { for item in local.iam_flat : item.unique_key => item }
  
  # 2. Panggil atribut project menggunakan hasil tangkapan data source
  project = var.project_id

  # Atribut project dihapus. Terraform akan otomatis mengambil dari blok provider
  role   = each.value.role
  member = each.value.member
} 