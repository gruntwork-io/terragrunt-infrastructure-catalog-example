<!-- Frontmatter
tags: [azure]
-->

# Azure App Foundation Stack

This is an example Terragrunt stack that provisions the pieces an application needs before it can run: an
[Azure resource group](https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal), an
[Azure storage account](https://learn.microsoft.com/azure/storage/common/storage-account-overview) with a table in
[Azure Table Storage](https://learn.microsoft.com/azure/storage/tables/table-storage-overview), an
[Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-intro), the
[user-assigned managed identity](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/overview) the application runs as, and optional
[Azure Monitor metric alerts](https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-metric-overview). See the
[Azure App Foundation example](/examples/terragrunt/azure/stacks/app-foundation) for instructions on how to provision this stack.

Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with
[Terragrunt](https://github.com/gruntwork-io/terragrunt) in a way that keeps your [OpenTofu](https://opentofu.org/)
and [Terraform](https://www.terraform.io) code manageable. This is not production-ready code, so use at your own risk.
