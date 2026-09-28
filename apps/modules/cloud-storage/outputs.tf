# 1. Output Map Seluruh Objek Bucket (Sangat berguna untuk referensi antar modul)
output "buckets" {
  description = "Seluruh objek resource Google Storage Bucket yang berhasil dibuat. Kunci (key) map adalah nama bucket."
  value       = google_storage_bucket.bucket
}

# 2. Output Spesifik: Daftar Nama Bucket Saja
output "bucket_names" {
  description = "Daftar (List) nama-nama bucket yang dibuat."
  value       = [for b in google_storage_bucket.bucket : b.name]
}

# 3. Output Spesifik: Map Nama Bucket dan URL-nya
output "bucket_urls" {
  description = "Map yang berisi Nama Bucket sebagai kunci dan URL gs:// sebagai nilainya."
  value = {
    for k, v in google_storage_bucket.bucket : k => v.url
  }
}