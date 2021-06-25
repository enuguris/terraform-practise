terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.64.0"
    }
  }
}

data "azurerm_resources" "vnet_resources" {
  type = "Microsoft.Network/virtualNetworks"
}

data "azurerm_virtual_network" "example" {
  for_each            = local.vnet_rg_map
  name                = each.key
  resource_group_name = each.value
}

data "azurerm_subnet" "all_subnets" {
  for_each             = { for s in local.snet_vnet_rg_map : s.id => s }
  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

locals {
  private_ip = var.private_ip

  vnet_ids = [for vnet in data.azurerm_resources.vnet_resources.resources : vnet["id"]]

  vnet_rg_map = { for id in local.vnet_ids :
  regex("^.*virtualNetworks/(.*)$", id)[0] => regex("^.*resourceGroups/(.*)/providers.*$", id)[0] }

  snet_vnet_rg_map = flatten([for k, v in data.azurerm_virtual_network.example :
    flatten([for snet_name in v.subnets :
      { subnet_name          = snet_name,
        virtual_network_name = v.name,
        resource_group_name  = v.resource_group_name,
        id                   = format("%s_%s", snet_name, v.name)
    }])
  ])

  selected_subnet_id = [
    for k, v in {
      for s in data.azurerm_subnet.all_subnets :
      s.id => (cidrhost(format("%s/%s", local.private_ip, split("/", s.address_prefix)[1]), 0) == split("/", s.address_prefix)[0] ? true : false)
    } : k if v == true
  ]
}
