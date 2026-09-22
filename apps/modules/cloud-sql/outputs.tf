output "instance_names" {
  description = "Kamus berisi key dan nama instance Cloud SQL di GCP"
  value = {
    for k, db in google_sql_database_instance.instance : k => db.name
  }
}

output "private_ip_addresses" {
  description = "Kamus berisi key dan Private IP dari masing-masing database"
  value = {
    for k, db in google_sql_database_instance.instance : k => db.private_ip_address
  }
}

output "connection_names" {
  description = "Kamus berisi key dan connection name (dibutuhkan jika mengakses via Cloud SQL Auth Proxy)"
  value = {
    for k, db in google_sql_database_instance.instance : k => db.connection_name
  }
}