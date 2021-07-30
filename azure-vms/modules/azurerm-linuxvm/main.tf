terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.69.0"
    }
  }
}

locals {
  tags = var.tags
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = var.snet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_network_interface" "primary_nic" {
  name                = "${var.host_name}_nic1"
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_network_interface.primary_nic]
}

data "azurerm_public_ip" "public_ip" {
  name                = "${var.host_name}_pub_ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_public_ip.pip]
}

data "azurerm_storage_account" "stacbootdiaglnx" {
  name                = "stacbootdiaglnx"
  resource_group_name = data.azurerm_resource_group.rg.name
}

module "ppg_avset" {
  source = "../azurerm-ppg-avset"

  resource_group_name       = var.resource_group_name
  enable_ppg                = var.enable_ppg
  enable_avset              = var.enable_avset
  availability_set          = var.availability_set
  proximity_placement_group = var.proximity_placement_group
  tags                      = var.tags
}

resource "azurerm_network_interface" "primary_nic" {
  name                = "${var.host_name}_nic1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic1"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = var.private_ip_addr_allocation
    private_ip_address            = var.private_ipaddress
    private_ip_address_version    = var.ip_addr_version
    primary                       = true
    public_ip_address_id          = data.azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.host_name}_pub_ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = var.public_ip_addr_allocation

  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                       = var.host_name
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  network_interface_ids      = [data.azurerm_network_interface.primary_nic.id]
  allow_extension_operations = true
  #encryption_at_host_enabled   = true
  size                         = var.vm_size
  admin_username               = var.admin_username
  availability_set_id          = var.enable_avset == true ? module.ppg_avset.availability_set_id : null
  proximity_placement_group_id = var.enable_ppg == true ? module.ppg_avset.proximity_placement_group_id : null

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_pubkey_path)
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.os_version
  }


  /*
  license_type = var.license_type
  
  plan {
    name      = var.plan_name
    publisher = var.publisher
    product   = var.product
  }
*/

  os_disk {
    name                 = "${var.host_name}_osdisk"
    caching              = var.caching
    storage_account_type = var.storage_account_type
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.stacbootdiaglnx.primary_blob_endpoint
  }

  custom_data = filebase64("${path.module}/config/cloud-init.cfg")

  tags = local.tags

  depends_on = [azurerm_network_interface.primary_nic, module.ppg_avset]
}
