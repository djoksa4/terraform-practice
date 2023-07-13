resource "azurerm_resource_group" "rg" {
  name     = "rg-djordje-terraform-practice"
  location = "westeurope"
  tags = {
    environment = "practice"
  }
}



# Create virtual network
resource "azurerm_virtual_network" "vn" {
  name                = "vm-linux-terraform-practice-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "vm-linux-terraform-practice840"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "subnet1"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Create subnet
resource "azurerm_subnet" "sn" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.1.1.0/24"]
}


# Create public IPs
resource "azurerm_public_ip" "pip" {
  name                = "vm-linux-terraform-practice-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-linux-terraform-practice-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnyHTTPInbound"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAnyCustom3000Inbound"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}



# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                = "vm-linux-terraform-practice"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vm_size             = "Standard_D2ls_v5"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "vm-linux-practice_OsDisk_1_54642ddd2025432d99ae716dd0b2a728"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm-linux-terraform-practice"
    admin_username = "adminuser"
    admin_password = "P9TdhP{#!#s>PAA"
    custom_data    = "IyEvYmluL2Jhc2gKCiNJTlNUQUxMIFBPU1RHUkVTUUwKZWNobyAiPT09PT09PT09PT09PT09PT09PT09PT09PSBJTlNUQUxMSU5HIFBPU1RHUkVTUUwgPT09PT09PT09PT09PT09PT09PT09PT09PT09PSIKCiMgMS4gUmVmcmVzaCBsb2NhbCBwYWNrYWdlIGluZGV4OgphcHQgdXBkYXRlCgojIDIuIEluc3RhbGwgdGhlIFBvc3RncmVzIHBhY2thZ2UgYWxvbmcgd2l0aCBhIC1jb250cmliIHBhY2thZ2U6CmVjaG8gLWUgIjhcbjZcbiIgfCBERUJJQU5fRlJPTlRFTkQ9bm9uaW50ZXJhY3RpdmUgYXB0IGluc3RhbGwgcG9zdGdyZXNxbCBwb3N0Z3Jlc3FsLWNvbnRyaWIgLXkKCiMgMy4gRW5zdXJlIHRoYXQgdGhlIHNlcnZpY2UgaXMgc3RhcnRlZDoKc2VydmljZSBwb3N0Z3Jlc3FsIHN0YXJ0CgoKCiNDT05GSUdVUkUgUE9TVEdSRVNRTAplY2hvICI9PT09PT09PT09PT09PT09PT09PT09PT09IENPTkZJR1VSSU5HIFBPU1RHUkVTUUwgPT09PT09PT09PT09PT09PT09PT09PT09PT09IgoKIyAxLiBDcmVhdGUgYSBuZXcgUG9zdGdyZXNxbCByb2xlCnN1IC0gcG9zdGdyZXMgLWMgImNyZWF0ZXVzZXIgLS1zdXBlcnVzZXIgZGpvcmRqZSIKCiMgMi4gQ3JlYXRlIGEgbmV3IGRiCnN1IC0gcG9zdGdyZXMgLWMgImNyZWF0ZWRiIGRqb3JkamUiCgojIDMuIENyZWF0ZSBhIG5ldyB1c2VyCnVzZXJhZGQgLW0gLXMgL2Jpbi9iYXNoIGRqb3JkamUKCiMgNC4gU3dhcCB0byB0aGUgbmV3IHVzZXIgYW5kIG91dHB1dCBjb25uZWN0aW9uIGluZm8Kc3UgLSBkam9yZGplIC1jICJwc3FsIC1jICdcXGNvbm5pbmZvJyIK"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    
  }

}