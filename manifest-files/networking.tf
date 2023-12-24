//////////////////////////////////////////////////////////
/// RESOURCE GROUP ///
//////////////////////////////////////////////////////////
resource "azurerm_resource_group" "terraform_rg" {
  name     = var.rg_name
  location = var.location
}

//////////////////////////////////////////////////////////
/// VNET ///
//////////////////////////////////////////////////////////
resource "azurerm_virtual_network" "terraform_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  address_space       = ["10.0.0.0/16"]
}

//////////////////////////////////////////////////////////
/// SUBNETS ///
//////////////////////////////////////////////////////////
resource "azurerm_subnet" "public_subnets" {
  count                = length(var.public_subnets)
  name                 = "public-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = [var.public_subnets[count.index]]
}

resource "azurerm_subnet" "private_web_subnets" {
  count                = length(var.private_web_subnets)
  name                 = "private-web-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = [var.private_web_subnets[count.index]]
}

resource "azurerm_subnet" "private_app_subnets" {
  count                = length(var.private_app_subnets)
  name                 = "private-app-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = [var.private_app_subnets[count.index]]
}

resource "azurerm_subnet" "private_db_subnets" {
  count                = length(var.private_db_subnets)
  name                 = "private-db-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = [var.private_db_subnets[count.index]]
}


