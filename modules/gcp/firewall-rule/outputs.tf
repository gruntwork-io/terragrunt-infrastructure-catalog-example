output "name" {
  description = "The name of the firewall rule"
  value       = google_compute_firewall.rule.name
}

output "id" {
  description = "The full resource path of the firewall rule, in the form projects/<project>/global/firewalls/<name>"
  value       = google_compute_firewall.rule.id
}
