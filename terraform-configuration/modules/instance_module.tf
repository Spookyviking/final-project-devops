terraform {
  required_version = "1.5.7"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.94.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "modules/service-admin.json"
  cloud_id                 = "<cloud_id>"
  folder_id                = "<folder_id>"
  zone                     = "ru-central1-a"
}

resource "yandex_compute_instance" "vm" {
  name = "${var.name_node}"
  platform_id = "standard-v3"

  resources {
	cores  = 2
	memory = 6
	core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = var.yandex_image_id
      size = 20
	}
  }
  network_interface {
    subnet_id = var.vpc_subnet_id
    ip_address = var.vpc_ip_address
	nat = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ubuntu_id_rsa.pub")}"
  }
}
