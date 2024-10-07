variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The region where resources will be deployed."
  type        = string
  default     = "us-central1"  # Adjust this based on your needs
}

variable "network_name" {
  description = "The name of the VPC network to create."
  type        = string
  default     = "tf-jenkins-network"  # Change as required
}

variable "subnet_name" {
  description = "The name of the subnet to create."
  type        = string
  default     = "tf-jenkins-subnet"  # Change as required
}

variable "firewall_name" {
  description = "The name of the firewall rule."
  type        = string
  default     = "tf-jenkins-firewall"  # Change as required
}

variable "public_ip_name" {
  description = "The name of the public IP address for the Jenkins server."
  type        = string
  default     = "tf-jenkins-public-ip"  # Change as required
}

variable "instance_name" {
  description = "The name of the Jenkins server instance."
  type        = string
  default     = "tf-jenkins-server"  # Change as required
}

variable "machine_type" {
  description = "The machine type for the Jenkins server instance."
  type        = string
  default     = "e2-medium"  # Adjust based on your resource needs
}

variable "zone" {
  description = "The zone where the Jenkins server instance will be deployed."
  type        = string
  default     = "us-central1-a"  # Adjust based on your needs
}

variable "jenkins_server_tag" {
  description = "The tag for the Jenkins server instance."
  type        = string
  default     = "jenkins-server"  # Change as required
}

variable "service_account_name" {
  description = "The name for the service account used by the Jenkins server."
  type        = string
  default     = "tf-jenkins-sa"  # Change as required
}
