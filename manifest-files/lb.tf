resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-pip"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "terraform_lb" {
  name                = "terraform-lb"
  location            = azurerm_resource_group.terraform_rg.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-frontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name            = "lb_backend"
  loadbalancer_id = azurerm_lb.terraform_lb.id
}

resource "azurerm_lb_nat_pool" "lb_nat_pool" {
  name                           = "lb_nat_pool"
  resource_group_name            = azurerm_resource_group.terraform_rg.name
  loadbalancer_id                = azurerm_lb.terraform_lb.id
  protocol                       = "Tcp"
  frontend_port_start            = "50000"
  frontend_port_end              = "50119"
  backend_port                   = 22
  frontend_ip_configuration_name = "lb-frontend"
}

resource "azurerm_lb_probe" "azurerm_lb_probe" {
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
  loadbalancer_id = azurerm_lb.terraform_lb.id
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "lb-rule"
  loadbalancer_id                = azurerm_lb.terraform_lb.id
  frontend_ip_configuration_name = "lb-frontend"
  frontend_port                  = 80
  backend_port                   = 80
  protocol                       = "Tcp"
  probe_id                       = azurerm_lb_probe.azurerm_lb_probe.id
}
