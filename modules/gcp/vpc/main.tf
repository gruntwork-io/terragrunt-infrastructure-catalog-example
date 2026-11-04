# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE VPC NETWORK
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "network" {
  name                    = var.name
  auto_create_subnetworks = false
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets

  # Subnet names are unique per region across the whole project, not per network.
  name          = "${var.name}-${each.key}"
  network       = google_compute_network.network.id
  region        = var.region
  ip_cidr_range = each.value.ip_cidr_range

  # Lets VMs without an external IP address reach Google APIs such as Cloud Storage.
  private_ip_google_access = true
}
