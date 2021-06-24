terraform {
  required_version = "= 0.14.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.64.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "this" {
  source = "../modules/azurerm-get-subnetid"

  private_ip = "10.0.1.254"
}

output "subnetid" {
  value = module.this.subnetid
}
