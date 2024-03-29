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
    public_ip_address_id = azurerm_public_ip.pip_srv1.id
    subnet_id = lookup(azurerm_subnet.subnets, "LAN").id
  }
  depends_on = [azurerm_subnet.subnets]
}

resource "azurerm_public_ip" "pip_srv1" {
  name                = "${var.env_prefix}_srv1_pip"
  resource_group_name = azurerm_resource_group.srv1_rg.name
  location            = azurerm_resource_group.srv1_rg.location
  allocation_method   = "Static"
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

resource "azurerm_virtual_machine_extension" "gc_srv1" {
  name                       = "AzurePolicyforWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_srv1.id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.29"
  auto_upgrade_minor_version = "true"
}

resource "azurerm_policy_virtual_machine_configuration_assignment" "gc_srv1_assign" {
  name               = "AzureWindowsBaseline"
  location           = azurerm_windows_virtual_machine.vm_srv1.location
  virtual_machine_id = azurerm_windows_virtual_machine.vm_srv1.id

  configuration {
    assignment_type = "ApplyAndMonitor"
    version         = "1.*"

    parameter {
      name  = "Minimum Password Length;ExpectedValue"
      value = "16"
    }
    parameter {
      name  = "Minimum Password Age;ExpectedValue"
      value = "0"
    }
    parameter {
      name  = "Maximum Password Age;ExpectedValue"
      value = "30,45"
    }
    parameter {
      name  = "Enforce Password History;ExpectedValue"
      value = "10"
    }
    parameter {
      name  = "Password Must Meet Complexity Requirements;ExpectedValue"
      value = "1"
    }
  }
  depends_on = [azurerm_virtual_machine_extension.gc_srv1]
}