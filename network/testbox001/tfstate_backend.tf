terraform {
  backend "azurerm" {
    resource_group_name  = "rg-test"
    storage_account_name = "stacestustrfmstate"
    container_name       = "tfstate-0-21"
    key                  = "aws/testbox001/instance.state"
  }
}
