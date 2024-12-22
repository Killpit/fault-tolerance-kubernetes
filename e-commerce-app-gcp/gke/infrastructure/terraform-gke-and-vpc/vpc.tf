resource "google_compute_network" "vpc_network" {
  project                                   = "my-project-name"
  name                                      = "vpc-network"
  auto_create_subnetworks                   = true
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"
}