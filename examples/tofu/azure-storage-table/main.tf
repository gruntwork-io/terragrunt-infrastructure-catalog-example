terraform {
  required_version = ">= 1.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# The provider reads the subscription from the ARM_SUBSCRIPTION_ID environment variable.
provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "../../../modules/azure-resource-group"

  name     = "${var.name}-rg"
  location = var.location
}

module "storage_account" {
  source = "../../../modules/azure-storage-account"

  name                = var.name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

module "storage_table" {
  source = "../../../modules/azure-storage-table"

  name               = var.table_name
  storage_account_id = module.storage_account.id
}
