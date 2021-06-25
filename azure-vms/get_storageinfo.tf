/*

terraform {
required_version = "=0.14.7"
required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.62.0"
    }
}

*/

data "azurerm_storage_account" "stacbootdiaglnx" {
  name                = "stacbootdiaglnx"
  resource_group_name = "rg-rhelha"
  depends_on          = [azurerm_resource_group.rhelha]
}

output "stacbootdiaglnx_info" {
  value = data.azurerm_storage_account.stacbootdiaglnx.primary_blob_endpoint
}
