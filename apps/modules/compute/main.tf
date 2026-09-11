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

  hostname            = var.hostname
  tags                = var.network_tags
  deletion_protection = var.deletion_protection

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
    
    # Blok access_config hanya dibuat jika assign_external_ip = true
    dynamic "access_config" {
      for_each = var.assign_external_ip ? [1] : []
      content {
        network_tier = var.network_tier
      }
    }
  }

  # Mengelola identitas VM (Workload Identity di level Compute Engine)
  service_account {
    email  = var.service_account_email
    scopes = var.access_scopes
  }

  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }

  # Automation
  metadata_startup_script = var.startup_script

  # Metadata dikompilasi menggunakan fungsi merge()
  # Konversi boolean Terraform menjadi string metadata GCP
  metadata = merge(
    {
      "enable-oslogin"         = var.enable_oslogin ? "TRUE" : "FALSE"
      "enable-oslogin-2fa"     = var.enable_oslogin_2fa ? "TRUE" : "FALSE"
      "block-project-ssh-keys" = var.block_project_ssh_keys ? "TRUE" : "FALSE"
      "install-ops-agent"      = var.install_ops_agent
    },
    
    # Hanya tambahkan ssh-keys jika nilainya tidak kosong
    var.ssh_keys != null ? { "ssh-keys" = var.ssh_keys } : {},
    
    # Gabungkan dengan metadata tambahan lainnya jika ada
    var.custom_metadata
  )

  labels = var.labels # VM mendapatkan label umum
}

