variable "prefix" {
    default = "my_rg"
}


resource "azurerm_resource_group" "rg" {
    name = "${var.prefix}"
    location = "Australia Southeast"

    tags = {
        environment = "dev"
        source = "Terraform"
    }
}


resource "azurerm_virtual_network" "vn1" {
    name = "${var.prefix}-network"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location 
    resource_group_name = azurerm_resource_group.rg.name 
} 

resource "azurerm_subnet" "private1" {
    name = "private1"
    resource_group_name = azurerm_resource_group.rg.name 
    virtual_network_name = azurerm_virtual_network.vn1.name 
    address_prefixes = ["10.0.1.0/24"]

}

resource "azurerm_subnet" "private2" {
    name = "private2"
    resource_group_name = azurerm_resource_group.rg.name 
    virtual_network_name = azurerm_virtual_network.vn1.name 
    address_prefixes = ["10.0.2.0/24"]

}

resource "azurerm_network_interface" "main1" {
    name = "${var.prefix}-nic1"
    location = azurerm_resource_group.rg.location 
    resource_group_name = azurerm_resource_group.rg.name 

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = azurerm_subnet.private1.id 
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "main2" {
    name = "${var.prefix}-nic2"
    location = azurerm_resource_group.rg.location 
    resource_group_name = azurerm_resource_group.rg.name 

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = azurerm_subnet.private2.id 
        private_ip_address_allocation = "Dynamic"
    }
}

# resource "azurerm_virtual_machine" "vm1" {
#     name = "${var.prefix}-vm1"
#     location = azurerm_resource_group.rg.location
#     resource_group_name = azurerm_resource_group.rg.name 
#     network_interface_ids = [azurerm_network_interface.main1.id]
#     vm_size = "Standard_D2s_V3"
#     delete_os_disk_on_termination = true
#     delete_data_disks_on_termination = true

#     storage_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#    storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }


#    os_profile {
#     computer_name  = "hostname"
#     admin_username = var.username 
#     admin_password = var.password
#   }

#    os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_virtual_machine" "vm2" {
#     name = "${var.prefix}-vm2"
#     location = azurerm_resource_group.rg.location
#     resource_group_name = azurerm_resource_group.rg.name 
#     network_interface_ids = [azurerm_network_interface.main2.id]
#     vm_size = "Standard_D2s_V3"
#     delete_os_disk_on_termination = true
#     delete_data_disks_on_termination = true

#     storage_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#    storage_os_disk {
#     name              = "myosdisk2"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }


#    os_profile {
#     computer_name  = "hostname"
#     admin_username = var.username 
#     admin_password = var.password
#   }

#    os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = {
#     environment = "dev"
#   }
# }



variable "vm_count" {
  default = 2
}

resource "azurerm_virtual_machine" "vm" {
  count                = var.vm_count
  name                 = "${var.prefix}-vm${count.index + 1}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  network_interface_ids = [element([azurerm_network_interface.main1.id, azurerm_network_interface.main2.id], count.index % 2)]
  vm_size              = "Standard_D2s_V3"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm${count.index + 1}"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}
