resource "google_compute_firewall" "rule" {
  name    = var.name
  network = var.network

  direction = var.direction
  priority  = var.priority

  dynamic "allow" {
    for_each = var.action == "allow" ? [var.ports] : []

    content {
      protocol = var.protocol
      ports    = allow.value
    }
  }

  dynamic "deny" {
    for_each = var.action == "deny" ? [var.ports] : []

    content {
      protocol = var.protocol
      ports    = deny.value
    }
  }

  source_ranges = var.source_ranges

  # Without target tags, the rule applies to every instance in the network.
  target_tags = length(var.target_tags) > 0 ? var.target_tags : null
}
