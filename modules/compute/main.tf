resource "google_compute_disk" "boot_disk" {
  name    = "${var.vm_name}-boot"
  zone    = var.zone
  image   = var.boot_disk_image
  type    = var.boot_disk_type
  size    = var.boot_disk_size
  
  # MENGGABUNGKAN: Label Umum + Label Bawaan Role
  labels = merge(
    var.labels, 
    { disk_role = "boot" },
    var.boot_disk_labels
  )
}

resource "google_compute_disk" "add_disk" {
  for_each = var.additional_disks # Melakukan perulangan sebanyak isi map

  # Nama disk akan menjadi gabungan nama VM dan kunci map (contoh: vm-dev-disk1)
  name  = "${var.vm_name}-${each.key}" 
  zone  = var.zone
  type  = each.value.type
  size  = each.value.size

  # MENGGABUNGKAN: Label Umum + Label Bawaan Role + Label Khusus Disk
  labels = merge(
    var.labels,
    { disk_role = each.key },
    each.value.labels)
}

resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  # TAMBAHKAN BARIS INI
  # Menginstruksikan GCP agar memastikan VM dalam keadaan mati (berhenti)
  desired_status = var.desired_status

  # panggil boot disk menggunakan source
  boot_disk { 
    source = google_compute_disk.boot_disk.id
  }

  # DYNAMIC BLOCK: Akan membuat blok attached_disk sebanyak jumlah data_disks
  # Jika additional_disks kosong, blok ini otomatis tidak akan dibuat
  dynamic "attached_disk" {
    for_each = google_compute_disk.add_disk
    content {
      source = attached_disk.value.id
    }
  }

  network_interface {
    # vm dipasang ke subnet yg dikirim dari module networking
    subnetwork = var.subnet_id
    # Block ini dikosongkan agar VM tidak mendapat IP Publik (lebih aman)
    # Anda tetap bisa SSH via IAP karena firewall sudah dibuka
    # access_config { }
  }

  labels = var.labels # VM mendapatkan label umum
}

