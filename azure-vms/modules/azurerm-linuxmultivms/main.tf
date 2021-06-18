terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.62.0"
    }
  }
}

locals {
  #  tags = var.tags
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
  for_each            = var.cluster
  name                = "${each.value.host_name}_nic1"
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_network_interface.primary_nic]
}

data "azurerm_public_ip" "public_ip" {
  for_each            = var.cluster
  name                = "${each.value.host_name}_pub_ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_public_ip.pip]
}

data "azurerm_storage_account" "stacbootdiaglnx" {
  name                = "stacbootdiaglnx"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_managed_disk" "shareddisk" {
  name                = var.shared_disk_name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [module.shared_disk]
}

data "azurerm_virtual_machine" "vm" {
  for_each            = var.cluster
  name                = each.value.host_name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_linux_virtual_machine.linuxvm]
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

module "shared_disk" {
  source = "../azurerm-shareddisk"

  count               = var.create_shareddisk == true ? 1 : 0
  shared_disk_name    = var.shared_disk_name
  resource_group_name = var.resource_group_name
  shared_disk_size_gb = var.shared_disk_size_gb
  max_shares          = var.max_shares
  tags                = var.tags
}

module "lb" {
  source                                 = "../azurerm-lb"
  resource_group_name                    = data.azurerm_resource_group.rg.name
  type                                   = var.lb_type
  frontend_name                          = var.frontend_name
  frontend_subnet_id                     = data.azurerm_subnet.snet.id
  frontend_private_ip_address_allocation = var.frontend_private_ip_address_allocation
  frontend_private_ip_address            = var.frontend_private_ip_address
  lb_sku                                 = var.lb_sku
  name                                   = var.lb_name
  enable_floating_ip                     = var.enable_floating_ip
  lb_port                                = var.lb_port
  lb_probe                               = var.lb_probe
  tags                                   = var.tags
}

resource "azurerm_network_interface" "primary_nic" {
  for_each            = var.cluster
  name                = "${each.value.host_name}_nic1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic1"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = each.value.private_ip_addr_allocation
    private_ip_address            = each.value.private_ipaddress
    primary                       = true
    public_ip_address_id          = data.azurerm_public_ip.public_ip[each.key].id
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "bgpool_assoc" {
  for_each                = var.cluster
  network_interface_id    = data.azurerm_network_interface.primary_nic[each.key].id
  ip_configuration_name   = element(data.azurerm_network_interface.primary_nic[each.key].ip_configuration.*.name, 0)
  backend_address_pool_id = module.lb.azurerm_lb_backend_address_pool_id
}

resource "azurerm_public_ip" "pip" {
  for_each            = var.cluster
  name                = "${each.value.host_name}_pub_ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = each.value.public_ip_addr_allocation

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "sd_attach" {
  for_each           = var.cluster
  managed_disk_id    = data.azurerm_managed_disk.shareddisk.id
  virtual_machine_id = data.azurerm_virtual_machine.vm[each.key].id
  caching            = "None"
  lun                = "10"
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  for_each                     = var.cluster
  name                         = each.value.host_name
  location                     = data.azurerm_resource_group.rg.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  network_interface_ids        = [data.azurerm_network_interface.primary_nic[each.key].id]
  allow_extension_operations   = true
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
    name                 = "${each.value.host_name}_osdisk"
    caching              = var.caching
    storage_account_type = var.storage_account_type
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.stacbootdiaglnx.primary_blob_endpoint
  }

  tags = var.tags

  depends_on = [azurerm_network_interface.primary_nic, module.ppg_avset, module.shared_disk]
}
