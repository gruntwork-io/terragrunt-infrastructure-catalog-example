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

module "vnet" {
  source = "../../../modules/azure-vnet"

  name                = var.name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.0.0.0/16"]

  subnets = {
    private = {
      address_prefixes = ["10.0.1.0/24"]
    }
    public = {
      address_prefixes = ["10.0.101.0/24"]
    }
  }
}
