# ==============================================================================
# 1. UNMANAGED INSTANCE GROUP (UMIG)
# ==============================================================================
# Membuat UMIG secara dinamis. Jika variabel 'backends' berisi 2 blok, 
# maka resource ini akan diputar (looping) dan mencetak 2 UMIG.
resource "google_compute_instance_group" "umig" {
  for_each    = var.backends

  name        = "${var.lb_name}-umig-${each.key}"
  description = "UMIG untuk rute ${each.value.route_path}"
  zone        = var.zone
  
  # Memasukkan VM existing yang Anda berikan via variabel
  instances   = each.value.instances

  # Mendaftarkan port aplikasi ke dalam UMIG
  named_port {
    name = each.value.port_name
    port = each.value.port
  }
}

# ==============================================================================
# 2. HEALTH CHECK & BACKEND SERVICE
# ==============================================================================
# Health Check sekarang di-looping (dibuat per backend) agar bisa 
# menembak ke port yang berbeda-beda. Namanya saya ganti jadi "hc".
resource "google_compute_health_check" "hc" {
  for_each           = var.backends

  name               = "${var.lb_name}-hc-${each.key}"
  check_interval_sec = 5
  timeout_sec        = 5
  
  http_health_check {
    port = each.value.port # Menembak port spesifik milik backend ini
  }
}

# Membuat Backend Service sebanyak jumlah blok di variabel 'backends'.
resource "google_compute_backend_service" "bes" {
  for_each              = var.backends
  name                  = "${var.lb_name}-bes-${each.key}"
  port_name             = each.value.port_name
  protocol              = var.backend_protocol
  load_balancing_scheme = "EXTERNAL"
  
  # Menempelkan Health Check yang dibuat di atas
  health_checks         = [google_compute_health_check.hc[each.key].id]

  # Menyambungkan Backend Service ini ke UMIG yang bersesuaian (berdasarkan nama kunci)
  backend {
    group = google_compute_instance_group.umig[each.key].id
  }

  # Mencegah Terraform menimpa konfigurasi Cloud Armor/CDN jika ada tim
  # yang mengubahnya secara manual dari Console GCP.
  lifecycle {
    ignore_changes = [security_policy, enable_cdn, cdn_policy]
  }
}

# ==============================================================================
# 3. URL MAP (PENGATUR ROUTING MULTI-BACKEND)
# ==============================================================================
# Baris ini mencari nama kunci backend yang ditandai 'is_default = true'.
# Hasilnya disimpan di memori sementara (local) agar bisa dipanggil ke bawah.
locals {
  default_backend_key = [for k, v in var.backends : k if v.is_default][0]
}

# Membuat "Buku Rute" (URL Map). Ini yang membagi traffic ke UMIG yang tepat.
resource "google_compute_url_map" "default" {
  name            = "${var.lb_name}-url-map"
  
  # Menentukan backend utama. Jika URL tidak dikenal, lempar ke sini.
  default_service = google_compute_backend_service.bes[local.default_backend_key].id

  # Menangkap semua nama host/domain (/*)
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.bes[local.default_backend_key].id

    # Blok dinamis: Jika Anda punya backend selain default (misal "/api/*"),
    # blok ini otomatis mencetak aturannya. Jika Anda cuma punya 1 backend,
    # blok ini tidak akan mencetak apa-apa.
    dynamic "path_rule" {
      for_each = { for k, v in var.backends : k => v if !v.is_default }
      content {
        paths   = [path_rule.value.route_path]
        service = google_compute_backend_service.bes[path_rule.key].id
      }
    }
  }
}

# ==============================================================================
# 4. GOOGLE MANAGED SSL & IP PUBLIK (MULTI-DOMAIN)
# ==============================================================================
# Meminta GCP menerbitkan Sertifikat SSL berdasarkan var.domains.
# Akan sukses meskipun isinya 1 domain atau 5 domain sekaligus.
resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.lb_name}-cert"
  managed {
    domains = var.domains
  }
}

# Jika existing_ip_address kosong (null), buat 1 IP baru. Jika ada isinya, buat 0 (jangan buat IP).
resource "google_compute_global_address" "default" {
  count = var.existing_ip_address == null ? 1 : 0
  name  = "${var.lb_name}-ip"
}

# Trik cerdas untuk menentukan IP mana yang akan dipakai oleh Forwarding Rule
locals {
  # Jika ada IP existing, pakai itu. Jika tidak, ambil ID dari IP baru yang dibuat di atas.
  lb_ip = var.existing_ip_address != null ? var.existing_ip_address : google_compute_global_address.default[0].id
}

# ==============================================================================
# 5. PINTU HTTPS (PORT 443)
# ==============================================================================
# Menghubungkan SSL dan URL Map ke sebuah Target Proxy HTTPS
resource "google_compute_target_https_proxy" "default" {
  name             = "${var.lb_name}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# Membuka gerbang masuk dari internet di Port 443 dan menempelkannya ke IP Publik.
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.lb_name}-https-rule"
  target                = google_compute_target_https_proxy.default.id
  port_range            = "443"
  ip_address            = local.lb_ip
  load_balancing_scheme = "EXTERNAL"
}

# ==============================================================================
# 6. PINTU HTTP & REDIRECT KE HTTPS (PORT 80)
# ==============================================================================
# Membuat URL Map khusus yang misinya cuma satu: Menolak traffic dan
# memaksa browser user pindah ke HTTPS (kode HTTP 301).
resource "google_compute_url_map" "https_redirect" {
  name = "${var.lb_name}-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false # Menjaga agar link seperti ?id=123 tidak hilang
  }
}

# Proxy yang mendengarkan traffic HTTP dan melemparnya ke URL Map Redirect
resource "google_compute_target_http_proxy" "http_redirect" {
  name    = "${var.lb_name}-http-proxy"
  url_map = google_compute_url_map.https_redirect.id
}

# Membuka gerbang masuk dari internet di Port 80 (menggunakan IP Publik yang
# sama persis dengan IP HTTPS di atas).
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.lb_name}-http-rule"
  target                = google_compute_target_http_proxy.http_redirect.id
  port_range            = "80"
  ip_address            = local.lb_ip
  load_balancing_scheme = "EXTERNAL"
}