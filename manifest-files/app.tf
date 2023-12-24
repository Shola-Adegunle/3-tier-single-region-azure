////////////////////////////////////////////////////////
//// CREATE APP VM SCALE SETS ////
////////////////////////////////////////////////////////
resource "azurerm_linux_virtual_machine_scale_set" "app_servers" {
  count               = length(var.availability_zones) #* desired_instance_per_zone # length(var.private_app_subnets) * length(var.availability_zones) # Number of VM instances in the VMSS
  name                = "app-vmss-${count.index + 4  }"                                                    # Name of the VMSS
  resource_group_name = azurerm_resource_group.terraform_rg.name                         # Resource group for the VMSS
  location            = azurerm_resource_group.terraform_rg.location                     # Location for the VMSS
  sku                 = "Standard_F2"                                                    # VM SKU
  instances           = 1                                                                # Number of instances per scale set

  admin_username = "adminuser" # Username for SSH access to VMs

  admin_ssh_key {
    username   = "adminuser"               # SSH username
    public_key = file("~/.ssh/id_rsa.pub") # SSH public key file
  }

  source_image_reference {
    publisher = "Canonical"    # Publisher of the VM image
    offer     = "UbuntuServer" # Offer of the VM image
    sku       = "16.04-LTS"    # SKU of the VM image
    version   = "latest"       # Version of the VM image
  }

  os_disk {
    storage_account_type = "Standard_LRS" # OS disk storage type
    caching              = "ReadWrite"    # OS disk caching
  }

  network_interface {
    name    = "primary-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      // Assign a subnet to each scale set instance
      subnet_id = element([for s in azurerm_subnet.private_web_subnets : s.id], count.index % length(var.private_web_subnets))
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]
    }
  }

  zones = var.availability_zones # Specifies the availability zones for VM instances
}


////////////////////////////////////////////////////////
//// CREATE APP VM AUTOSCALE SETTINGS ////
////////////////////////////////////////////////////////

resource "azurerm_monitor_autoscale_setting" "app_autoscale_settings" {
  name                = "app-autoscaling"                                      # Setting the name of the autoscale setting
  resource_group_name = azurerm_resource_group.terraform_rg.name               # Specifying the resource group name
  location            = azurerm_resource_group.terraform_rg.location           # Setting the location for the autoscale setting
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app_servers[0].id # Identifying the target resource for autoscaling

  profile {                 # Defining an autoscale profile
    name = "defaultProfile" # Giving the profile a name

    capacity {
      default = 2 # Setting the default capacity to 2 instances
      minimum = 2 # Ensuring a minimum of 2 instances
      maximum = 3 # Allowing a maximum of 3 instances
    }

    rule { # Defining a scale-up rule
      metric_trigger {
        metric_name        = "Percentage CPU"                                       # Triggering on CPU usage percentage
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_servers[0].id # Targeting the VMSS
        time_grain         = "PT1M"                                                 # Time granularity for metric data (1 minute)
        statistic          = "Average"                                              # Using average metric data
        time_window        = "PT5M"                                                 # Time window for the metric (5 minutes)
        time_aggregation   = "Average"                                              # Aggregating metric data using average
        operator           = "GreaterThan"                                          # Trigger when metric is greater than threshold
        threshold          = 75                                                     # Threshold for scaling up (CPU > 75%)
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"            # Metric namespace
        dimensions {
          name     = "AppName" # Dimension name (e.g., AppName)
          operator = "Equals"  # Dimension operator (e.g., Equals)
          values   = ["app1"]  # Dimension values to match (e.g., "app1")
        }
      }

      scale_action {
        direction = "Increase"    # Scale out (increase) action
        type      = "ChangeCount" # Type of scale action
        value     = "1"           # Increase VM count by 1
        cooldown  = "PT1M"        # Cooldown period after scaling (1 minute)
      }
    }

    rule { # Defining a scale-down rule
      metric_trigger {
        metric_name        = "Percentage CPU" # Triggering on CPU usage percentage
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_servers[0].id
        time_grain         = "PT1M"     # Time granularity for metric data (1 minute)
        statistic          = "Average"  # Using average metric data
        time_window        = "PT5M"     # Time window for the metric (5 minutes)
        time_aggregation   = "Average"  # Aggregating metric data using average
        operator           = "LessThan" # Trigger when metric is less than threshold
        threshold          = 25         # Threshold for scaling down (CPU < 25%)
      }

      scale_action {
        direction = "Decrease"    # Scale in (decrease) action
        type      = "ChangeCount" # Type of scale action
        value     = "1"           # Decrease VM count by 1
        cooldown  = "PT1M"        # Cooldown period after scaling (1 minute)
      }
    }
  }

  predictive {
    scale_mode      = "Enabled" # Enable predictive scaling
    look_ahead_time = "PT5M"    # Look-ahead time for predictive scaling (5 minutes)
  }

  notification {
    email {
      send_to_subscription_administrator = true                # Send notifications to subscription administrator
      custom_emails                      = [var.admin-email] # Send notifications to custom email addresses
    }
  }
}

