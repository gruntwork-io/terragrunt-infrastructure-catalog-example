output "name" {
  description = "The name of the VPC network"
  value       = module.vpc.name
}

output "id" {
  description = "The full resource path of the VPC network, in the form projects/<project>/global/networks/<name>"
  value       = module.vpc.id
}

output "subnet_names" {
  description = "The names of the subnets, keyed by the short name given in subnets"
  value       = module.vpc.subnet_names
}
