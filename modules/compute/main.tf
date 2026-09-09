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
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      type  = "pd-standard"
      size  = 10
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
