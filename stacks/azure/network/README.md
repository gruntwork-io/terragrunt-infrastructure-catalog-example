<!-- Frontmatter
tags: [azure]
-->

# Azure Network Stack

This is an example Terragrunt stack that provisions an
[Azure resource group](https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal), an
[Azure virtual network](https://learn.microsoft.com/azure/virtual-network/virtual-networks-overview) with its subnets, and an
[Azure network security group](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview) with one rule per entry in `inbound_rules`.
See the [Azure Network example](/examples/terragrunt/azure/stacks/network) for instructions on how to provision this stack.

Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with
[Terragrunt](https://github.com/gruntwork-io/terragrunt) in a way that keeps your [OpenTofu](https://opentofu.org/)
and [Terraform](https://www.terraform.io) code manageable. This is not production-ready code, so use at your own risk.
