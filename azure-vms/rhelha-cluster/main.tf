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

module "hacluster" {
  source = "../modules/azurerm-linuxmultivms"

  cluster = {
    node1 = {
      host_name                  = "azvm001"
      private_ip_addr_allocation = "Static"
      public_ip_addr_allocation  = "Static"
      private_ipaddress          = "10.0.1.10"
      ip_addr_version            = "IPv4"
    },
    node2 = {
      host_name                  = "azvm002"
      private_ip_addr_allocation = "Static"
      public_ip_addr_allocation  = "Static"
      private_ipaddress          = "10.0.1.11"
      ip_addr_version            = "IPv4"
    }
  }

  resource_group_name       = "rg-rhelha"
  nsg_name                  = "az_nsg_01"
  vnet_name                 = "az_vnet_eastus"
  snet_name                 = "snet_general_001"
  vm_size                   = "Standard_D4s_v3"
  admin_username            = "vmimport"
  ssh_pubkey_path           = "~/.ssh/id_rsa.pub"
  enable_avset              = true
  enable_ppg                = true
  availability_set          = "AV_RHELHA"
  proximity_placement_group = "ppg_rhelha"
  create_shareddisk         = true
  max_shares                = "2"
  shared_disk_size_gb       = "256"
  shared_disk_name          = "rhelha-cluster1-shareddisk01"
  tags                      = { environment = "development" }
}
