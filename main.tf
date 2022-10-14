terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }

  required_version = "1.3.2"
}

provider "azurerm" {
    features {}
      
}
resource "azurerm_resource_group" "paulugohrg1" {
  name     = "paulugohrg1"
  location = "West Europe"
}

resource "azurerm_virtual_network" "paulVnet" {
  name                = "paulVnet"
  location            = azurerm_resource_group.paulugohrg1.location
  resource_group_name = azurerm_resource_group.paulugohrg1.name
  address_space       = ["10.0.0.0/16"]

    tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "paulsubnet" {
  name                 = "paulsubnet"
  resource_group_name  = azurerm_resource_group.paulugohrg1.name
  virtual_network_name = azurerm_virtual_network.paulVnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "paulsg" {
  name                = "paulsg"
  location            = azurerm_resource_group.paulugohrg1.location
  resource_group_name = azurerm_resource_group.paulugohrg1.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_rule" "paul-rule" {
  name                        = "paul-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.paulugohrg1.name
  network_security_group_name = azurerm_network_security_group.paulsg.name
}

resource "azurerm_subnet_network_security_group_association" "paulsecgroup" {
  subnet_id                 = azurerm_subnet.paulsubnet.id
  network_security_group_id = azurerm_network_security_group.paulsg.id
}

resource "azurerm_network_interface" "paul-nic" {
  name                = "paul-nic"
  location            = azurerm_resource_group.paulugohrg1.location
  resource_group_name = azurerm_resource_group.paulugohrg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.paulsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "paulugoh10VM" {
  name                = "paulugoh10VM"
  resource_group_name = azurerm_resource_group.paulugohrg1.name
  location            = azurerm_resource_group.paulugohrg1.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password = "tek01@"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.paul-nic.id,
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}