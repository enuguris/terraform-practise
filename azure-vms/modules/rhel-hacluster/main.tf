terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.64.0"
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

data "azurerm_proximity_placement_group" "ppg" {
  count               = var.enable_ppg ? 1 : 0
  name                = var.proximity_placement_group
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_proximity_placement_group.ppg]
}

data "azurerm_availability_set" "avset" {
  count               = var.enable_avset ? 1 : 0
  name                = var.availability_set
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_availability_set.avset]
}

data "azurerm_network_interface" "primary_nic" {
  for_each            = var.cluster
  name                = "${each.value.host_name}_nic1"
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_network_interface.primary_nic]
}

data "azurerm_storage_account" "stacbootdiaglnx" {
  name                = var.bootdiag_storage_account
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_managed_disk" "shareddisk" {
  name                = var.shared_disk_name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_template_deployment.sdisk_deployment]
}

data "azurerm_virtual_machine" "vm" {
  for_each            = var.cluster
  name                = each.value.host_name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_linux_virtual_machine.linuxvm]
}

########################################################################################
#										       #
#            PROXIMITY PLACEMENT GROUP AND AVAILABILITY SET RESOURCES                  #
#										       #
########################################################################################

resource "azurerm_proximity_placement_group" "ppg" {
  count               = var.enable_ppg ? 1 : 0
  name                = var.proximity_placement_group
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_availability_set" "avset" {
  count                        = var.enable_avset ? 1 : 0
  name                         = var.availability_set
  location                     = data.azurerm_resource_group.rg.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  proximity_placement_group_id = var.enable_ppg == true ? element(concat(data.azurerm_proximity_placement_group.ppg.*.id, [""]), 0) : null

  tags = var.tags
}

########################################################################################
#										       #
#                           LOAD BALANCER RESOURCES                                    #
#										       #
########################################################################################

resource "azurerm_lb" "azlb" {
  name                = var.lb_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.lb_sku
  tags                = var.tags

  frontend_ip_configuration {
    name                          = var.frontend_name
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = var.frontend_private_ip_address_allocation
  }
}

resource "azurerm_lb_backend_address_pool" "bg_pool" {
  name            = var.backend_address_pool_name
  loadbalancer_id = azurerm_lb.azlb.id
}

resource "azurerm_lb_probe" "azlb" {
  count               = length(var.lb_probe)
  name                = element(keys(var.lb_probe), count.index)
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.azlb.id
  protocol            = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 0)
  port                = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 1)
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 2)
}

resource "azurerm_lb_rule" "lb_rule" {
  count                          = length(var.lb_port)
  name                           = element(keys(var.lb_port), count.index)
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.azlb.id
  protocol                       = element(var.lb_port[element(keys(var.lb_port), count.index)], 1)
  frontend_port                  = element(var.lb_port[element(keys(var.lb_port), count.index)], 0)
  backend_port                   = element(var.lb_port[element(keys(var.lb_port), count.index)], 2)
  frontend_ip_configuration_name = var.frontend_name
  enable_floating_ip             = var.enable_floating_ip
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bg_pool.id
  idle_timeout_in_minutes        = var.idle_timeout_in_minutes
  probe_id                       = element(azurerm_lb_probe.azlb.*.id, count.index)
}

########################################################################################
#										       #
#                           SHARED DISK RESOURCES                                      #
#										       #
########################################################################################

resource "azurerm_template_deployment" "sdisk_deployment" {
  name                = "deployment-${var.shared_disk_name}"
  resource_group_name = var.resource_group_name

  template_body = file("${path.module}/az-shareddisk.json")

  parameters = {
    "dataDiskName"   = var.shared_disk_name
    "dataDiskSizeGB" = var.shared_disk_size_gb
    "maxShares"      = var.max_shares
  }

  deployment_mode = "Incremental"
}

########################################################################################
#										       #
#                     ASSOCIATE SHARED DISK TO LINUX VMS                               #
#										       #
########################################################################################

resource "azurerm_virtual_machine_data_disk_attachment" "sd_attach" {
  for_each           = var.cluster
  managed_disk_id    = data.azurerm_managed_disk.shareddisk.id
  virtual_machine_id = data.azurerm_virtual_machine.vm[each.key].id
  caching            = "None"
  lun                = "10"
}

########################################################################################
#										       #
#                              MANAGED DISKS                                           #
#										       #
########################################################################################

resource "azurerm_managed_disk" "data_disk" {
  for_each             = { for d in var.data_disks : format("%s_%s", d.host_name, d.disk_name) => d }
  name                 = each.key
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk_attach" {
  for_each           = { for d in var.data_disks : format("%s_%s", d.host_name, d.disk_name) => d }
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = data.azurerm_virtual_machine.vm[each.value.host_name].id
  caching            = each.value.caching
  lun                = each.value.lun_id
}

########################################################################################
#										       #
#                           NETWORK INTERFACE RESOURCES                                #
#										       #
########################################################################################

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
  }
}

########################################################################################
#										       #
#                ASSOCIATE NETWORK INTERFACE TO LOAD BALANCER BACKEND POOL             #
#										       #
########################################################################################

resource "azurerm_network_interface_backend_address_pool_association" "bgpool_assoc" {
  for_each                = var.cluster
  network_interface_id    = data.azurerm_network_interface.primary_nic[each.key].id
  ip_configuration_name   = element(data.azurerm_network_interface.primary_nic[each.key].ip_configuration.*.name, 0)
  backend_address_pool_id = azurerm_lb_backend_address_pool.bg_pool.id
}

########################################################################################
#										       #
#                      AZURE LINUX VM RESOURCE                                         #
#										       #
########################################################################################

resource "azurerm_linux_virtual_machine" "linuxvm" {
  for_each                     = var.cluster
  name                         = each.value.host_name
  location                     = data.azurerm_resource_group.rg.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  network_interface_ids        = [data.azurerm_network_interface.primary_nic[each.key].id]
  allow_extension_operations   = true
  size                         = var.vm_size
  admin_username               = var.admin_username
  availability_set_id          = var.enable_avset == true ? element(concat(data.azurerm_availability_set.avset.*.id, [""]), 0) : null
  proximity_placement_group_id = var.enable_ppg == true ? element(concat(data.azurerm_proximity_placement_group.ppg.*.id, [""]), 0) : null

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

  depends_on = [azurerm_network_interface.primary_nic, azurerm_template_deployment.sdisk_deployment]
}
