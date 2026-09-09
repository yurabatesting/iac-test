resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  # TAMBAHKAN BARIS INI
  # Menginstruksikan GCP agar memastikan VM dalam keadaan mati (berhenti)
  desired_status = "TERMINATED"

  boot_disk {
    initialize_params {
      # menggunakan image ubuntu
      image = var.boot_disk_image
      type  = var.boot_disk_type
      size  = var.boot_disk_size
    }
  }

  network_interface {
    # vm dipasang ke subnet yg dikirim dari module networking
    subnetwork = var.subnet_id
    # Block ini dikosongkan agar VM tidak mendapat IP Publik (lebih aman)
    # Anda tetap bisa SSH via IAP karena firewall sudah dibuka
    # access_config { }
  }
}
