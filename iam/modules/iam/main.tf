locals {
  iam_flat = flatten([
    for key, data in var.iam_members : [
      for role in data.roles : {
        unique_key = "${data.member}=>${role}"
        member     = data.member
        role       = role
      }
    ]
  ])
  
  # Mengubah hasil flat menjadi Map untuk for_each
  iam_map = { for item in local.iam_flat : item.unique_key => item }
}

# 1. Jika target_type == "project", jalankan blok ini. Jika bukan, abaikan ({}).
resource "google_project_iam_member" "project" {
  for_each = var.target_type == "project" ? local.iam_map : {}

  project = var.target_id
  role    = each.value.role
  member  = each.value.member
}

# 2. Jika target_type == "folder", jalankan blok ini.
resource "google_folder_iam_member" "folder" {
  for_each = var.target_type == "folder" ? local.iam_map : {}

  folder = var.target_id
  role   = each.value.role
  member = each.value.member
}

# 3. Jika target_type == "organization", jalankan blok ini.
resource "google_organization_iam_member" "org" {
  for_each = var.target_type == "organization" ? local.iam_map : {}

  org_id = var.target_id
  role   = each.value.role
  member = each.value.member
}