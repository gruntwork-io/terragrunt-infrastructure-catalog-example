output "name" {
  description = "The name of the VPC network"
  value       = google_compute_network.network.name
}

output "id" {
  description = "The full resource path of the VPC network, in the form projects/<project>/global/networks/<name>"
  value       = google_compute_network.network.id
}

output "self_link" {
  description = "The URI of the VPC network"
  value       = google_compute_network.network.self_link
}

output "subnet_ids" {
  description = "The full resource paths of the subnets, keyed by the short name given in subnets"
  value       = { for key, subnet in google_compute_subnetwork.subnet : key => subnet.id }
}

output "subnet_names" {
  description = "The names of the subnets, keyed by the short name given in subnets"
  value       = { for key, subnet in google_compute_subnetwork.subnet : key => subnet.name }
}
