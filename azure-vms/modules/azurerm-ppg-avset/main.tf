terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.62.0"
    }
  }
}

locals {
  tags = var.tags
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
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
