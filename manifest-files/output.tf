output "resource_group_name" {
  value = azurerm_resource_group.terraform_rg.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.terraform_vnet.name
}

output "public_subnet_ids" {
  value = [for subnet in azurerm_subnet.public_subnets : subnet.id]
}

output "private_web_subnet_ids" {
  value = [for subnet in azurerm_subnet.private_web_subnets : subnet.id]
}

output "private_app_subnet_ids" {
  value = [for subnet in azurerm_subnet.private_app_subnets : subnet.id]
}

output "private_db_subnet_ids" {
  value = [for subnet in azurerm_subnet.private_db_subnets : subnet.id]
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "nat_gateway_public_ips" {
  value = [for ip in azurerm_public_ip.terraform_public_ip : ip.ip_address]
}
