# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
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

