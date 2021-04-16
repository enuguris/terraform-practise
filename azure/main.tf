provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "rg-test"
}

data "azurerm_storage_account" "tf_stac" {
  name                = "stacestustrfmstate"
  resource_group_name = "rg-test"
}

resource "azurerm_storage_account" "stacestustrfmstate" {
  name                     = "stacestustrfmstate"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "development"
  }
}

resource "azurerm_storage_container" "tfstate-0-21" {
  name                  = "tfstate-0-21"
  storage_account_name  = data.azurerm_storage_account.tf_stac.name
  container_access_type = "private"
}
