terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "srv1_rg" {
  name     = "${var.env_prefix}-srv1-rg"
  location = var.location
}

resource "azurerm_resource_group" "net_rg" {
  name     = "${var.env_prefix}-net-rg"
  location = var.location
}

resource "azurerm_resource_group" "aa_rg" {
  name     = "${var.env_prefix}-aa-rg"
  location = var.location
}

resource "azurerm_automation_account" "aa" {
  name                = "${var.env_prefix}-aa"
  location            = azurerm_resource_group.aa_rg.location
  resource_group_name = azurerm_resource_group.aa_rg.name
  sku_name            = "Basic"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env_prefix}-vnet"
  resource_group_name = azurerm_resource_group.net_rg.name
  location            = azurerm_resource_group.net_rg.location
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnets" {
    for_each = var.subnets
    name = each.value.name
    address_prefixes = [each.value.address]
    resource_group_name = azurerm_resource_group.net_rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_network_interface" "nic_srv1" {
  name                = "${var.env_prefix}_srv1_nic"
  location            = azurerm_resource_group.srv1_rg.location
  resource_group_name = azurerm_resource_group.srv1_rg.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = lookup(azurerm_subnet.subnets, "LAN").id
  }
  depends_on = [azurerm_subnet.subnets]
}

resource "azurerm_windows_virtual_machine" "vm_srv1" {
  name                = "${var.env_prefix}_srv1"
  computer_name = "srv1"
  resource_group_name = azurerm_resource_group.srv1_rg.name
  location            = azurerm_resource_group.srv1_rg.location
  size                = var.vm_size
  admin_username      = var.local_username
  admin_password      = var.local_password
  network_interface_ids = [
    azurerm_network_interface.nic_srv1.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
    identity {
    type = "SystemAssigned"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}