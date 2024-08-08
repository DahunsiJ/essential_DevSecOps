# Azure Provider source and version being used
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = ""
  tenant_id       = ""
  client_id       = ""
  client_secret   = ""
  features {}
}


# terraform {
#   backend "azurerm" {
#     resource_group_name   = "myResourceGroup"
#     storage_account_name  = "mystorageaccount"
#     container_name        = "tfstate"
#     key                   = "terraform.tfstate"
#   }
# }

