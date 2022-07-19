locals {
  project_id       ="guardicore-27479746"
  network          ="main2"
  image            ="ubuntu-minimal-1804-lts"
  ssh_user         ="ansible"
  private_key_path ="/home/yuval/.ssh/ansible_ed25519"

}  


provider "google" {
  credentials = file("/home/yuval/traning/terraform/guardicore-27479746-2741882c9e36.json")
  project     = "guardicore-27479746"
  region      = "us-east1"
}

# Main VPC
# https://www.terraform.io/docs/providers/google/r/compute_network.html#example-usage-network-basic
resource "google_compute_network" "main2" {
  name                    = "main2"
  auto_create_subnetworks = false
} 

# Public Subnet
# https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html

resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-east1"
  network       = google_compute_network.main2.id
}

#resource "google_service_account" "access-terraform " {
#  account_id = ""
#}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.main2.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22","80", "8080", "1000-2000"]
  }
  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = ["access-terraform@guardicore-27479746.iam.gserviceaccount.com"]  
}

resource "google_compute_instance" "nginx" {
  name         = "nginx"
  machine_type = "e2-standard-2"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-1804-lts"
    }
  }

  
  network_interface {
    network = "main2"
    subnetwork = "public-subnet"
    access_config {}
  }

  service_account {
    email  = "access-terraform@guardicore-27479746.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook  -i ${google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
}

 
output "nginx_ip" {
  value = google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip
}
