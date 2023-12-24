resource "azurerm_network_security_group" "public_nsg" {
  name                = "public-nsg-${var.environment}"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name

  // Rule to allow inbound HTTP traffic
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  // Rule to allow inbound HTTPS traffic
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  // Rule to allow outbound traffic to the internet
  security_rule {
    name                       = "AllowOutboundInternet"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  // Add any other specific rules as required by your application

  tags = {
    environment = var.environment
  }
}

// Associating the NSG with the public subnet
resource "azurerm_subnet_network_security_group_association" "public_subnet_nsg_association" {
  count                     = length(azurerm_subnet.public_subnets)
  subnet_id                 = azurerm_subnet.public_subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}


/////////////////////////////////////////////////////////////
//// APP NSG
/////////////////////////////////////////////////////////////
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg-${var.environment}"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name

  // Define your rules here. Example: Allow HTTP/HTTPS from the web subnet
  security_rule {
    name                       = "AllowWebTraffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefixes    = var.private_web_subnets  // Adjust based on your web subnet CIDR
    destination_address_prefix = "*"
  }

  // Add other specific rules as required

  tags = {
    environment = var.environment
  }
}

// Associating the NSG with the app subnet
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_association" {
  count                     = length(azurerm_subnet.private_app_subnets)
  subnet_id                 = azurerm_subnet.private_app_subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

/////////////////////////////////////////////////////////////
//// DB NSG
/////////////////////////////////////////////////////////////
resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg-${var.environment}"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name


  // Rule to allow SQL traffic from the app subnets
  security_rule {
    name                       = "AllowSQLTraffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"  // SQL Server default port
    source_address_prefixes    = var.private_app_subnets  // Both app subnet CIDRs
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

// Associating the NSG with the db subnet
resource "azurerm_subnet_network_security_group_association" "db_subnet_nsg_association" {
  count                     = length(azurerm_subnet.private_db_subnets)
  subnet_id                 = azurerm_subnet.private_db_subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}