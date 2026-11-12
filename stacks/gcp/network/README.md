<!-- Frontmatter
tags: [gcp]
-->

# GCP Network Stack

This is an example Terragrunt stack that provisions a [VPC network](https://cloud.google.com/vpc/docs/vpc) with its
subnets, and one [VPC firewall rule](https://cloud.google.com/firewall/docs/firewalls) per entry in `inbound_rules`.
See the [GCP Network example](/examples/terragrunt/gcp/stacks/network) for instructions on how to provision this stack.

Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with
[Terragrunt](https://github.com/gruntwork-io/terragrunt) in a way that keeps your [OpenTofu](https://opentofu.org/)
and [Terraform](https://www.terraform.io) code manageable. This is not production-ready code, so use at your own risk.
