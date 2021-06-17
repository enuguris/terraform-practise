terraform {
  required_version = "= 0.14.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.62.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rhelha" {
  name     = "rg-rhelha"
  location = "East US"
}

data "azurerm_resource_group" "rg_ds" {
  name = "rg-rhelha"
}

resource "azurerm_network_security_group" "az_nsg_01" {
  name                = "az_nsg_01"
  location            = data.azurerm_resource_group.rg_ds.location
  resource_group_name = data.azurerm_resource_group.rg_ds.name

  security_rule {
    name                       = "Allow_All"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "development"
  }
}

data "azurerm_network_security_group" "ds_az_nsg_01" {
  name                = "az_nsg_01"
  resource_group_name = data.azurerm_resource_group.rg_ds.name
}

resource "azurerm_virtual_network" "main" {
  name                = "az_vnet_eastus"
  location            = data.azurerm_resource_group.rg_ds.location
  resource_group_name = data.azurerm_resource_group.rg_ds.name
  address_space       = ["10.0.0.0/16"]
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "snet_general_001"
    address_prefix = "10.0.1.0/24"
    security_group = data.azurerm_network_security_group.ds_az_nsg_01.id
  }
}

data "azurerm_virtual_network" "ds_vnet_main" {
  name                = "az_vnet_eastus"
  resource_group_name = data.azurerm_resource_group.rg_ds.name
}

data "azurerm_subnet" "ds_snet_general_001" {
  name                 = element(data.azurerm_virtual_network.ds_vnet_main.subnets, 0)
  virtual_network_name = data.azurerm_virtual_network.ds_vnet_main.name
  resource_group_name  = data.azurerm_resource_group.rg_ds.name
}

resource "azurerm_storage_account" "stacbootdiaglnx" {
  name                     = "stacbootdiaglnx"
  resource_group_name      = data.azurerm_resource_group.rg_ds.name
  location                 = data.azurerm_resource_group.rg_ds.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

/*
resource "azurerm_network_interface" "rhel8-ha-node1_nic1" {
  name                = "rhel8-ha-node1_nic1"
  location            = data.azurerm_resource_group.rg_ds.location
  resource_group_name = data.azurerm_resource_group.rg_ds.name

  ip_configuration {
    name                          = "eth0"
    subnet_id                     = data.azurerm_subnet.ds_snet_general_001.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    private_ip_address_version    = "IPv4"
    primary                       = true
    public_ip_address_id          = data.azurerm_public_ip.ds-pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = data.azurerm_resource_group.rg_ds.name
  location            = data.azurerm_resource_group.rg_ds.location
  allocation_method   = "Static"

  tags = {
    environment = "development"
  }
}

data "azurerm_network_interface" "primary-nic" {
  name                = "rhel8-ha-node1_nic1"
  resource_group_name = data.azurerm_resource_group.rg_ds.name
}

data "azurerm_public_ip" "ds-pip" {
  name                = "pip"
  resource_group_name = data.azurerm_resource_group.rg_ds.name
}

resource "azurerm_linux_virtual_machine" "rhel8-ha-node1" {
  name                  = "rhel8-ha-node1"
  location              = data.azurerm_resource_group.rg_ds.location
  resource_group_name   = data.azurerm_resource_group.rg_ds.name
  network_interface_ids = [data.azurerm_network_interface.primary-nic.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "vmimport"

  admin_ssh_key {
    username   = "vmimport"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_4"
    version   = "latest"
  }

  license_type = "RHEL_BYOS"

  plan {
    name      = "8_4"
    publisher = "RedHat"
    product   = "RHEL"
  }

  os_disk {
    name                 = "rhel8-ha-node1_osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "development"
  }
}
*/
