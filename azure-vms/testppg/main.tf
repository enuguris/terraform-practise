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

module "this" {
  source = "../modules/azurerm-ppg-avset"

  resource_group_name       = "rg-rhelha"
  enable_ppg                = true
  enable_avset              = true
  proximity_placement_group = "test-ppg"
  availability_set          = "test-avset"
  tags                      = { environment = "development" }
}

output "avset_id" {
  value = module.this.azurerm_availability_set_id
}

output "ppg_id" {
  value = module.this.proximity_placement_group_id
}
