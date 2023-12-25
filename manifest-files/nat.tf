////////////////////////////////////////////////////////
//// NAT PUBLIC IP ////
////////////////////////////////////////////////////////
resource "azurerm_public_ip" "terraform_public_ip" {
  count               = length(var.public_subnets)
  name                = "terraform-PIP-${count.index + 1}-${var.environment}"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

////////////////////////////////////////////////////////
//// NAT GATEWAY ////
////////////////////////////////////////////////////////
resource "azurerm_nat_gateway" "nat_gateway" {
  count                   = length(var.public_subnets)
  name                    = "nat-gateway-${count.index + 1}-${var.environment}"
  location                = azurerm_resource_group.terraform_rg.location
  resource_group_name     = azurerm_resource_group.terraform_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  # zones                   = var.availability_zones //NAT Gateways not supporting multiple availability zones

  tags = {
    environment = var.environment
  }
}

////////////////////////////////////////////////////////
//// NAT IP ASSOCIATION ////
////////////////////////////////////////////////////////
resource "azurerm_nat_gateway_public_ip_association" "ip_association" {
  count                = length(var.public_subnets)
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway[count.index].id
  public_ip_address_id = azurerm_public_ip.terraform_public_ip[count.index].id
}

////////////////////////////////////////////////////////
//// NAT GATEWAY ASSOCIATION ////
////////////////////////////////////////////////////////
resource "azurerm_subnet_nat_gateway_association" "nat_association" {
  count          = length(azurerm_subnet.public_subnets)
  subnet_id      = azurerm_subnet.public_subnets[count.index].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway[count.index].id
}
