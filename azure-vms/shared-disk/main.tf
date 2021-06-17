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

module "sd" {
  source = "../modules/azurerm-manageddisk"

  resource_group_name = "rg-rhelha"
  shared_disk_name    = "rhelha-cluster1-shareddisk01"
  shared_disk_size_gb = "256"
  max_shares          = "2"
  tags                = { environment = "development" }
}
