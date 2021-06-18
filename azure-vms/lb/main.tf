terraform {
  required_version = "=0.14.7"
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

data "azurerm_resource_group" "rg" {
  name = "rg-rhelha"
}

data "azurerm_network_security_group" "nsg" {
  name                = "az_nsg_01"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "vnet" {
  name                = "az_vnet_eastus"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = "snet_general_001"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}


module "mylb" {
  source                                 = "../modules/azurerm-lb"
  resource_group_name                    = data.azurerm_resource_group.rg.name
  type                                   = "private"
  frontend_name                          = "ha-lb"
  frontend_subnet_id                     = data.azurerm_subnet.snet.id
  frontend_private_ip_address_allocation = "Static"
  frontend_private_ip_address            = "10.0.1.20"
  lb_sku                                 = "Basic"
  name                                   = "lb-aztest"
  enable_floating_ip                     = true

  remote_port = {
    ssh = ["Tcp", "22"]
  }

  lb_port = {
    http  = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }

  lb_probe = {
    http  = ["Tcp", "80", ""]
    http2 = ["Http", "1443", "/"]
  }

  tags = {
    Maintainer = "terraform"
  }
}
