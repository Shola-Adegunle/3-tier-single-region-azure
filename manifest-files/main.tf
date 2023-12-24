terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
  backend "azurerm" {
   resource_group_name  = "terraform-state-rg"
   storage_account_name = "tf-state-sadey2k"
   container_name       = "tf-state-container-sadey2k"
   key                  = "dev-tfstate"

   }
}

provider "azurerm" {
  features {}
}
