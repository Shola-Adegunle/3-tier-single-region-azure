variable "location" {
  type = string
  description = "The Azure region to deploy all resources in."
}

variable "rg_name" {
  type = string
  description = "The name of the resource group in which to create all resources."
}

variable "admin-email" {
  type = string
  description = "Admin email for notifications and alerts."
  sensitive = true
}

variable "environment" {
  type = string
  description = "Deployment environment (e.g., dev, staging, prod)."
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones in the region."
}

variable "vnet_name" {
  type = string
  description = "The name of the virtual network."
}

variable "vnet_cidr" {
  type = string
  description = "The CIDR block of the virtual network."
}

variable "public_subnets" {
  type = list(string)
  description = "List of CIDR blocks for the public subnets."
}

variable "private_web_subnets" {
  type = list(string)
  description = "List of CIDR blocks for the private web subnets."
}

variable "private_app_subnets" {
  type = list(string)
  description = "List of CIDR blocks for the private app subnets."
}

variable "private_db_subnets" {
  type = list(string)
  description = "List of CIDR blocks for the private database subnets."
}
