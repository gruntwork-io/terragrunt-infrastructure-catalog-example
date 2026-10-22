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

module "container_registry" {
  source = "../../../modules/azure-container-registry"

  name                = var.name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}
