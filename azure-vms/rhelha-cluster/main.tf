terraform {
  required_version = "=0.14.7"
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

module "hacluster" {
  source = "../modules/rhel-hacluster"

  cluster = {
    node1 = {
      host_name                  = "azvm001"
      private_ip_addr_allocation = "Static"
      private_ipaddress          = "10.0.1.10"
    },
    node2 = {
      host_name                  = "azvm002"
      private_ip_addr_allocation = "Static"
      private_ipaddress          = "10.0.1.11"
    }
  }

  resource_group_name       = "rg-rhelha"
  nsg_name                  = "az_nsg_01"
  vnet_name                 = "az_vnet_eastus"
  snet_name                 = "snet_general_001"
  vm_size                   = "Standard_D2s_v3"
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

  lb_type                                = "private"
  frontend_name                          = "ha-lb"
  frontend_private_ip_address_allocation = "Static"
  frontend_private_ip_address            = "10.0.1.20"
  backend_address_pool_name              = "bgpool_ha"
  lb_sku                                 = "Basic"
  lb_name                                = "lb-rhelha"
  enable_floating_ip                     = true

  lb_port = {
    http  = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }

  lb_probe = {
    http  = ["Tcp", "80", ""]
    http2 = ["Http", "1443", "/"]
  }

  tags = { environment = "development" }
}
