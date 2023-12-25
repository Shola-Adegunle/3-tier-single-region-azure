terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
  backend "azurerm" {
   resource_group_name  = "terraform-state-rg"
   storage_account_name = "tfstatesadey2k"
   container_name       = "dev-state-file"
   key                  = "dev-3tier"

   }
}

provider "azurerm" {
  features {}
}
