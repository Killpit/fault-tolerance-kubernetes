provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a VPC network
resource "google_compute_network" "tf-jenkins-network" {
  name = var.network_name
}

# Create a subnet
resource "google_compute_subnetwork" "tf-jenkins-subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.tf-jenkins-network.name
  ip_cidr_range = "10.0.2.0/24"
}

# Firewall rules (equivalent to security group in AWS)
resource "google_compute_firewall" "tf-jenkins-firewall" {
  name    = var.firewall_name
  network = google_compute_network.tf-jenkins-network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Public IP address for Jenkins server
resource "google_compute_address" "tf-jenkins-public-ip" {
  name   = var.public_ip_name
  region = var.region
}

# Create a Jenkins server instance
resource "google_compute_instance" "tf-jenkins-server" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"  # No AMI equivalent, using Ubuntu image family
      size  = 16  # Equivalent to volume_size in AWS
      type  = "pd-standard"  # Persistent disk equivalent to gp2
    }
  }

  network_interface {
    network    = google_compute_network.tf-jenkins-network.name
    subnetwork = google_compute_subnetwork.tf-jenkins-subnet.name

    access_config {
      nat_ip = google_compute_address.tf-jenkins-public-ip.address
    }
  }

  metadata_startup_script = file("jenkinsdata.sh")  # Equivalent to user_data in AWS

  tags = [var.jenkins_server_tag]

  service_account {
    email  = google_service_account.tf-jenkins-sa.email
    scopes = ["cloud-platform"]  # Equivalent to IAM roles in AWS for instance profile
  }

  metadata = {
    enable-oslogin = "TRUE"  # No SSH key used
  }
}

# Create a service account (equivalent to IAM role in AWS)
resource "google_service_account" "tf-jenkins-sa" {
  account_id   = var.service_account_name
  display_name = "Jenkins Server Service Account"
}

# IAM role for the service account (similar to the aws_iam_role in AWS)
resource "google_project_iam_member" "tf-jenkins-sa-role" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.tf-jenkins-sa.email}"
}

# Output Jenkins URL
output "JenkinsURL" {
  value = "http://${google_compute_address.tf-jenkins-public-ip.address}:8080"
}
