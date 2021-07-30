terraform {
  required_version = "=1.0.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.69.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "vm" {
  source = "../modules/azurerm-linuxvm"

  resource_group_name        = "rg-rhelha"
  nsg_name                   = "az_nsg_01"
  vnet_name                  = "az_vnet_eastus"
  snet_name                  = "snet_general_001"
  host_name                  = "azvm002"
  private_ip_addr_allocation = "Static"
  public_ip_addr_allocation  = "Static"
  private_ipaddress          = "10.0.1.11"
  ip_addr_version            = "IPv4"
  vm_size                    = "Standard_A2_v2"
  admin_username             = "vmimport"
  ssh_pubkey_path            = "~/.ssh/id_rsa.pub"
  tags                       = { environment = "development", erequest = "#1234" }
  enable_avset               = true
  availability_set              = "AV_RHELHA"
  enable_ppg                 = true
  proximity_placement_group  = "ppg_rhelha"
}
