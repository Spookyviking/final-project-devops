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

resource "yandex_vpc_network" "network_1" {
  name = "network_1"
}

resource "yandex_vpc_subnet" "subnet_1" {
  name           = "subnet_1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

module "master" {
  source                = "./modules"
  name_node             = "master"  
  vpc_subnet_id         = yandex_vpc_subnet.subnet_1.id
  vpc_ip_address        = "192.168.10.10"
}

module "app" {
  source                = "./modules"
  name_node             = "app"
  vpc_subnet_id         = yandex_vpc_subnet.subnet_1.id
  vpc_ip_address        = "192.168.10.11"
}

module "srv" {
  source                = "./modules"
  name_node             = "srv"
  vpc_subnet_id         = yandex_vpc_subnet.subnet_1.id
  vpc_ip_address        = "192.168.10.12"
}

resource "null_resource" "create_inventory" {
  provisioner "local-exec" {
    command = "python3 ./create_inventory.py"
  }
  depends_on = [module.srv, module.app, module.master]
}

resource "null_resource" "exec_ansible_playbook_apt" {
  provisioner "local-exec" {
    command = "cd ~/final-project-devops/ansible-configuration && ansible-playbook ./playbooks/ansible-apt.yaml -u ubuntu"
  }
  depends_on = [null_resource.create_inventory]
}

resource "null_resource" "exec_ansible_playbook_k8s" {
  provisioner "local-exec" {
    command = "cd ~/final-project-devops/ansible-configuration && ansible-playbook ./playbooks/ansible-k8s.yaml -u ubuntu"
  }
  depends_on = [null_resource.exec_ansible_playbook_apt]
}