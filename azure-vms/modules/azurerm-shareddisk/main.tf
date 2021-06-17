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
