# Security Group (SG) Rule Module

This is a convenience module for creating security group rules.

The defaults for this module make some assumptions about the type of rule you probably want to create.

- `type` defaults to `ingress`
- `protocol` defaults to `tcp`

Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with
[Terragrunt](https://github.com/gruntwork-io/terragrunt) in a way that keeps your [OpenTofu](https://opentofu.org/)
and [Terraform](https://www.terraform.io) code manageable. This is not production-ready code, so use at your own risk.
